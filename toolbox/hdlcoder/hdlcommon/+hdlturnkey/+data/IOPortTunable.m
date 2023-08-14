


classdef IOPortTunable<hdlturnkey.data.IOPortBase


    properties

        CompFullName='';
    end

    methods

        function obj=IOPortTunable(varargin)

            obj=obj@hdlturnkey.data.IOPortBase(varargin{:});
            obj.isTunable=true;
        end

        function portTypeStr=getPortTypeStr(obj)

            if obj.PortType==hdlturnkey.IOType.IN

                portTypeStr='Tunable Parameter';
            else

                portTypeStr='Outport';
            end
        end

    end
end
