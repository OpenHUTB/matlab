


classdef Interrupt<hdlturnkey.interface.InterruptBase&...
    hdlturnkey.interface.IPWorkflowBase


    properties
        InterruptConnection='';
    end

    methods
        function obj=Interrupt(varargin)

            p=inputParser;
            p.addParameter('InterfaceID','Interrupt From DUT');
            p.addParameter('InterruptAssertedLevel','Active-high');
            p.addParameter('InterruptConnection','');

            p.parse(varargin{:});
            inputArgs=p.Results;


            if strcmpi(inputArgs.InterruptAssertedLevel,'Active-high')
                ActiveLow=false;
            else
                ActiveLow=true;
            end


            obj=obj@hdlturnkey.interface.InterruptBase(...
            'InterfaceID',inputArgs.InterfaceID,...
            'ActiveLow',ActiveLow);


            obj.InterruptConnection=inputArgs.InterruptConnection;


            obj.EnableAddr=4;
            obj.ClearAddr=5;
            obj.StatusAddr=6;



            obj.isDefaultBusInterfaceRequired=true;
        end

    end


    methods
        function hInterface=getBusInterface(~,hElab)

            hInterface=hElab.hTurnkey.getDefaultBusInterface;
        end

    end


    methods

        function generateRDInsertIPVivadoTcl(obj,fid,~)


            hdlturnkey.tool.generateVivadoTclFindAndDeleteConstant(...
            fid,obj.InterruptConnection);


            hdlturnkey.tool.generateVivadoTclInternalConnection(...
            fid,obj.InterruptConnection,obj.OutportNames{1});

        end
    end
end
