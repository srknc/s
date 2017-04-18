#!/usr/bin/ruby -w
require 'optparse'
require 'ostruct'
require 'json'

class My
  def initialize
      ### default parameters from file
      vars_file = File.read('conf/vars.json')
      @vars = JSON.parse(vars_file)

      ### read template files
      @ec2_def_temp = File.read('templates/ec2_main.json')
      @ec2_instance_def_temp = File.read('templates/ec2_instance.json')

      ### command line parameters
      options = OpenStruct.new
      OptionParser.new do |opt|
       opt.on('-n', '--instances [instance count]', 'Instance Count') { |o| options.instances = o }
       opt.on('-t', '--instance_type [instance type]', 'Instance Type') { |o| options.instance_type = o }
       opt.on('-s', '--allow_ssh_from [ip address]', 'Allow SSH') { |o| options.allow_ssh_from = o }
      end.parse!

      # check parameters
      if options.instances.to_i != 0 and options.allow_ssh_from.is_a? Integer
        @instances = options.instances
      else
        @instances = 1
      end

      if (options.instance_type.is_a? String)
        @vars['ec2']['instance_type'] = options.instance_type
      end

      if (options.allow_ssh_from.is_a? String)
        @vars['ec2']['sg']['src'] = options.allow_ssh_from.concat('/32')
      end

   end

   def ec2

     ec2_definations = @ec2_def_temp
     ec2_definations_instance = @ec2_instance_def_temp
     vars = @vars

     ec2_instance_definations=''
     for i in 1..(@instances.to_i)
       if i == 1
           n = ''
       else
           n = i
       end

       ec2_instance_definations.concat(ec2_definations_instance)
       ec2_instance_definations = ec2_instance_definations.gsub('###n###', n.to_s)
       ec2_instance_definations = ec2_instance_definations.gsub('###ImageId###', vars['ec2']['ami'])
       ec2_instance_definations = ec2_instance_definations.gsub('###InstanceType###', vars['ec2']['instance_type'])

     end

     ## TODO: use templating engine
     ec2_definations = ec2_definations.gsub('###ec2_defination###', ec2_instance_definations)
     ec2_definations = ec2_definations.gsub('###sg_desc###', vars['ec2']['sg']['desc'])
     ec2_definations = ec2_definations.gsub('###sg_src###', vars['ec2']['sg']['src'])
     ec2_definations = ec2_definations.gsub('###sg_from_port###', vars['ec2']['sg']['from_port'])
     ec2_definations = ec2_definations.gsub('###sg_proto###', vars['ec2']['sg']['proto'])
     ec2_definations = ec2_definations.gsub('###sg_to_port###', vars['ec2']['sg']['to_port'])

     return ec2_definations
   end

end
