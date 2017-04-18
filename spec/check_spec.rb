require 'Robot'

defaultOutput = File.read('./spec/expected.json')

describe Robot do
  describe '.ec2' do
    context 'ec2 method' do
      it 'check' do
        expect(Robot.new.ec2).to eql(defaultOutput)
      end
    end
  end
end
