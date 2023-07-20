classdef ServiceComponentSpreadsheet<autosar.ui.bsw.Spreadsheet




    methods
        function obj=ServiceComponentSpreadsheet(dlgSource)
            obj=obj@autosar.ui.bsw.Spreadsheet(dlgSource,'m_MappingChildren');
        end
    end

    methods(Access=protected)
        function aChildren=loadChildrenImpl(this,blkH)
            clientPortNames=eval(get_param(blkH,'ClientPortNames'));
            portDefinedArgs=eval(get_param(blkH,'ClientPortPortDefinedArguments'));

            try



                idTypes=eval(get_param(blkH,'IdTypes'));
            catch E
                if strcmp(E.identifier,'Simulink:Commands:ParamUnknown')
                    idTypes={};
                else
                    E.rethrow();
                end
            end

            aChildren=autosar.ui.bsw.ServiceComponentSpreadsheetRow.empty(length(clientPortNames),0);
            for ii=1:length(clientPortNames)
                portName=clientPortNames{ii};
                portDefinedArg=portDefinedArgs{ii};

                if isempty(idTypes)
                    idType='';
                else
                    idType=idTypes{ii};
                end

                clientPortData=autosar.ui.bsw.ClientPort(portName,idType,portDefinedArg);

                aChildren(ii)=...
                autosar.ui.bsw.ServiceComponentSpreadsheetRow(this.DlgSource,...
                clientPortData);
            end
        end

        function clearUnusedValues(this,blkH)%#ok<INUSD>

        end
    end
end


