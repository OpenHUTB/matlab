


classdef Interrupt<hdlturnkey.interface.InterruptBase


    properties

    end

    methods

        function obj=Interrupt(varargin)


            p=inputParser;
            p.addParameter('FPGAPinMap',{});
            p.addParameter('PluginBoard',[]);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj=obj@hdlturnkey.interface.InterruptBase();


            obj.FPGAPinMap=inputArgs.FPGAPinMap;


            obj.OutportNames={'LINTi_n'};


            obj.EnableAddr=8193;
            obj.ClearAddr=8194;
            obj.StatusAddr=8195;
        end

    end


    methods
        function hInterface=getBusInterface(~,hElab)

            hInterface=hElab.hTurnkey.getPCIInterface;
        end

    end

end

