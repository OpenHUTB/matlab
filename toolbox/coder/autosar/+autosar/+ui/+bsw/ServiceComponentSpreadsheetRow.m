classdef ServiceComponentSpreadsheetRow<autosar.ui.bsw.SpreadsheetRow




    properties(SetAccess=private,GetAccess=public)
        ClientPort;
    end

    properties(Access=public,Constant=true)
        ClientPortColumn=DAStudio.message('autosarstandard:ui:uiRTEPortColumn');
        IdColumn=DAStudio.message('autosarstandard:ui:uiRTEIdColumn');
        IdTypeColumn=DAStudio.message('autosarstandard:ui:uiRTEIdTypeColumn');
        BlockIdColumn=DAStudio.message('autosarstandard:ui:uiRTEBlockIdColumn');
    end

    methods
        function this=ServiceComponentSpreadsheetRow(dlgSource,clientPort)
            this=this@autosar.ui.bsw.SpreadsheetRow(dlgSource,false);
            this.ClientPort=clientPort;
        end

        function aLabel=getDisplayLabel(this)
            aLabel=this.ClientPort.Name;
        end

        function bIsValid=isValidPropertyImpl(this,aPropName)
            switch aPropName
            case{this.ClientPortColumn,this.IdColumn,...
                this.BlockIdColumn,this.IdTypeColumn}
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function bIsReadOnly=isReadonlyPropertyImpl(this,aPropName)
            switch aPropName
            case{this.IdColumn,this.BlockIdColumn}
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end

        function propType=getPropDataTypeImpl(this,aPropName)
            switch aPropName
            case{this.IdTypeColumn,this.ClientPortColumn}
                propType='text';
            otherwise
                propType='edit';
            end
        end

        function aPropValue=getPropValueImpl(this,aPropName)
            switch aPropName
            case this.ClientPortColumn
                aPropValue=this.ClientPort.Name;
            case{this.IdColumn,this.BlockIdColumn}
                aPropValue=this.ClientPort.PortDefinedArgument;
            case this.IdTypeColumn
                aPropValue=this.ClientPort.IdType;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setPropValueImpl(this,aPropName,aPropValue)
            this.checkPropValue(aPropName,aPropValue)
            switch aPropName
            case this.ClientPortColumn
                this.ClientPort.setName(aPropValue);
            case this.IdColumn
                if isempty(this.ClientPort.IdType)
                    DAStudio.error('autosarstandard:bsw:DscRequiresUpdate');
                end
                switch this.ClientPort.IdType
                case 'FID'
                    this.updateFimMatrix(aPropValue);
                case 'EventId'
                    clientPorts=[this.DlgSource.UserData.m_MappingChildren.ClientPort];
                    numEventsSharingPort=sum(arrayfun(@(x)(strcmp(x.PortDefinedArgument,this.ClientPort.PortDefinedArgument)&&strcmp(x.IdType,'EventId')),clientPorts));
                    if numEventsSharingPort==1





                        this.updateFimMatrix(aPropValue);
                    end
                otherwise

                end
                this.ClientPort.setPortDefinedArgument(aPropValue);
            case this.BlockIdColumn
                this.updateNvmInitValues(aPropValue);
                this.ClientPort.setPortDefinedArgument(aPropValue);
            otherwise
                assert(false,'Accessing unexpected property');
            end

            this.updateFiMSpreadhseet();

            if slfeature('NVRAMInitialValue')
                this.updateNvInitValSpreadhseet();
            end
        end

    end

    methods(Access=private)
        function updateFimMatrix(this,aPropValue)

            fimMatrix=this.getFiMSpreadsheetRows();
            if isempty(fimMatrix)
                return;
            end

            mappingChildren=this.getMappingSpreadsheetRows();
            clientPorts=[mappingChildren.ClientPort];
            otherClientPorts=clientPorts;
            otherClientPorts(this.ClientPort==clientPorts)=[];
            otherPortsSharingId=arrayfun(@(x)strcmp(x.IdType,this.ClientPort.IdType)&&strcmp(x.PortDefinedArgument,this.ClientPort.PortDefinedArgument),otherClientPorts);

            if any(otherPortsSharingId)



                return;
            end

            switch this.ClientPort.IdType
            case 'EventId'

                for ii=1:length(fimMatrix)
                    FidRow=fimMatrix(ii);
                    FidInnerRows=FidRow.getHierarchicalChildren();
                    for jj=1:numel(FidInnerRows)
                        eventMaskRow=FidInnerRows(jj);
                        if strcmp(eventMaskRow.FidMask.EventId,this.ClientPort.PortDefinedArgument)

                            eventMaskRow.FidMask.setEventId(aPropValue);
                        end
                    end
                end
            case 'FID'
                for ii=1:length(fimMatrix)
                    FidRow=fimMatrix(ii);
                    FidInnerRows=FidRow.getHierarchicalChildren();
                    if strcmp(FidRow.FID,this.ClientPort.PortDefinedArgument)
                        FidRow.setFID(aPropValue);
                        for jj=1:numel(FidInnerRows)
                            eventMaskRow=FidInnerRows(jj);
                            eventMaskRow.FidMask.setFID(aPropValue);
                        end
                    end
                end
            otherwise

            end
        end

        function updateNvmInitValues(this,aPropValue)
            if~slfeature('NVRAMInitialValue')
                return;
            end
            initValSpreadsheetRows=this.getNvInitValueSpreadsheetRows();
            initValuesBlockIds={initValSpreadsheetRows.BlockId};
            existingRowIndex=strcmp(initValuesBlockIds,this.ClientPort.PortDefinedArgument);
            rowRequiringUpdate=initValSpreadsheetRows(existingRowIndex);
            existingTargetRow=initValSpreadsheetRows(strcmp(initValuesBlockIds,aPropValue));

            if isempty(existingTargetRow)


                mappingChildren=this.getMappingSpreadsheetRows();
                clientPorts=[mappingChildren.ClientPort];
                if sum(strcmp({clientPorts.PortDefinedArgument},this.ClientPort.PortDefinedArgument))>1

                    this.DlgSource.UserData.m_InitValues(end+1)=...
                    autosar.ui.bsw.NvMInitValSpreadsheetRow(this.DlgSource,aPropValue);
                else
                    rowRequiringUpdate.setBlockId(aPropValue);
                end
            else


                this.DlgSource.UserData.m_InitValues=this.DlgSource.UserData.m_InitValues(~existingRowIndex);
            end

        end

        function checkPropValue(this,aPropName,aPropValue)
            switch aPropName
            case this.IdColumn
                value=str2double(aPropValue);
                if isnan(value)||...
                    value>intmax('uint16')||...
                    value<=0
                    DAStudio.error('autosarstandard:bsw:IdOutOfRange');
                end
            otherwise

            end
        end
    end
end



