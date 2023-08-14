


classdef ProcessingSystem<handle


    properties(SetAccess=protected)
DeviceTreeName





FPGANode

SystemInit
    end

    methods

        function obj=ProcessingSystem(varargin)


            p=inputParser;
            p.addParameter('DeviceTreeName','');
            p.addParameter('FPGANode','');

            p.parse(varargin{:});

            obj.DeviceTreeName=p.Results.DeviceTreeName;
            obj.FPGANode=p.Results.FPGANode;
        end
    end


    methods



    end

    methods(Access=protected)

    end


end
