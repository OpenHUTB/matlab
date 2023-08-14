classdef FaultSpreadsheetRow<autosar.ui.bsw.SpreadsheetRow





    properties(SetAccess=private,GetAccess=public)
        EventId;
    end

    properties(Access=public,Constant=true)

        EventIdColumn=autosar.ui.bsw.ServiceComponentSpreadsheetRow.IdColumn;
    end

    methods
        function this=FaultSpreadsheetRow(dlgSource,eventId)
            this=this@autosar.ui.bsw.SpreadsheetRow(dlgSource,true);
            this.EventId=eventId;
        end

        function aLabel=getDisplayLabel(this)
            aLabel=this.EventId;
        end

        function bIsValid=isValidPropertyImpl(this,aPropName)
            switch aPropName
            case this.EventIdColumn
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function bIsReadOnly=isReadonlyPropertyImpl(this,aPropName)%#ok<INUSD>
            bIsReadOnly=true;
        end

        function propType=getPropDataTypeImpl(this,aPropName)%#ok<INUSD>
            propType='text';
        end

        function aPropValue=getPropValueImpl(this,aPropName)
            switch aPropName
            case this.EventIdColumn
                mappingChildren=this.getMappingSpreadsheetRows();
                eventPorts=arrayfun(@(x)strcmp(x.IdType,'EventId'),[mappingChildren.ClientPort]);
                portIds=arrayfun(@(x)x.PortDefinedArgument,[mappingChildren(eventPorts).ClientPort],'UniformOutput',false);
                portNames=arrayfun(@(x)x.Name,[mappingChildren(eventPorts).ClientPort],'UniformOutput',false);

                portsWithThisEventIdIdx=strcmp(this.EventId,portIds);
                portNamesWithFid=portNames(portsWithThisEventIdIdx);

                portNamesStr=autosar.api.Utils.cell2str(portNamesWithFid);
                portNamesStr=strrep(portNamesStr,'''','');

                aPropValue=sprintf('EventId %s: %s',this.EventId,portNamesStr);
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setPropValueImpl(this,aPropName,aPropValue)
            switch aPropName
            case this.EventIdColumn
                this.EventId=aPropValue;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function newRow=addFault(this,faultName)
            fault=autosar.ui.bsw.Fault.create(faultName);
            newRow=autosar.ui.bsw.FaultSpreadsheetInnerRow(this.DlgSource,this,fault);
            this.addHierarchicalChild(newRow);
        end

        function faultName=getNewFaultName(this)
            eventId=this.EventId;
            potentialName=sprintf('DemEvent%sFault',eventId);
            index=1;
            faultName=[potentialName,num2str(index)];

            children=this.Children;
            if~isempty(children)
                uiFaults=[children.Fault];
                currentUiFaultNames={uiFaults.FaultName};

                while any(strcmp(faultName,currentUiFaultNames))
                    index=index+1;
                    faultName=[potentialName,num2str(index)];
                end
            end
        end
    end
end



