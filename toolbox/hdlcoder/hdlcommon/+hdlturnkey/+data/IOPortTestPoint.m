


classdef(Hidden=true)IOPortTestPoint<hdlturnkey.data.IOPortBase


    properties





        TestPointSignalDriver='';

        TestPointSignalPortIndex=-1;
    end

    methods
        function obj=IOPortTestPoint(varargin)

            obj=obj@hdlturnkey.data.IOPortBase(varargin{:});

            obj.PortType=hdlturnkey.IOType.OUT;
            obj.isTestPoint=true;
        end

        function portTypeStr=getPortTypeStr(obj)%#ok<MANU>

            portTypeStr='Test point';
        end

        function testPointLink=getTestPointLink(obj)




            hPorts=get_param(obj.TestPointSignalDriver,'PortHandles');

            hTestPoint=getfield(hPorts,'Outport',{obj.TestPointSignalPortIndex});


            testPointLink=hdlhtml.reportingWizard.generateSystemLinkForSignal(obj.PortName,hTestPoint);
        end
    end
end