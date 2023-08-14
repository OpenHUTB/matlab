classdef FiMMatrixSpreadsheetInnerRow<autosar.ui.bsw.SpreadsheetRow





    properties(SetAccess=private,GetAccess=public)
        FidMask;
        Parent;
    end

    properties(Access=public,Constant=true)
        IdColumn=DAStudio.message('autosarstandard:ui:uiRTEIdColumn');
        EventIdColumn=DAStudio.message('autosarstandard:ui:uiRTEPortsColumn');
        MaskColumn=DAStudio.message('autosarstandard:ui:uiRTEFiMMaskColumn');
    end

    methods
        function this=FiMMatrixSpreadsheetInnerRow(dlgSource,parent,fidMask)
            this=this@autosar.ui.bsw.SpreadsheetRow(dlgSource,false);
            this.Parent=parent;
            this.FidMask=fidMask;
        end

        function aLabel=getDisplayLabel(this)
            aLabel=this.FidMask.FID;
        end

        function bIsValid=isValidPropertyImpl(this,aPropName)
            switch aPropName
            case{this.IdColumn,this.EventIdColumn,this.MaskColumn}
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function bIsReadOnly=isReadonlyPropertyImpl(this,aPropName)
            switch aPropName
            case{this.EventIdColumn}
                bIsReadOnly=true;
            otherwise
                bIsReadOnly=false;
            end
        end

        function propType=getPropDataTypeImpl(this,aPropName)
            switch aPropName
            case this.EventIdColumn
                propType='text';
            case{this.MaskColumn,this.IdColumn}
                propType='enum';
            otherwise
                propType='text';
            end
        end

        function propValues=getPropAllowedValuesImpl(this,aPropName)
            switch aPropName
            case this.MaskColumn
                propValues={'LAST_FAILED','NOT_TESTED','TESTED','TESTED_AND_FAILED'};
            case this.IdColumn
                mappingChildren=this.DlgSource.UserData.m_MappingChildren;
                eventIdPorts=arrayfun(@(x)strcmp(x.IdType,'EventId'),[mappingChildren.ClientPort]);
                eventIds=arrayfun(@(x)str2double(x.PortDefinedArgument),[mappingChildren(eventIdPorts).ClientPort]);

                propValues=arrayfun(@(x)num2str(x),sort(eventIds),'UniformOutput',false);
            otherwise
                propValues={};
            end
        end

        function aPropValue=getPropValueImpl(this,aPropName)
            switch aPropName
            case this.IdColumn
                aPropValue=this.FidMask.EventId;
            case this.EventIdColumn
                mappingChildren=this.DlgSource.UserData.m_MappingChildren;
                eventIdPorts=arrayfun(@(x)strcmp(x.IdType,'EventId'),[mappingChildren.ClientPort]);
                eventIds=arrayfun(@(x)x.PortDefinedArgument,[mappingChildren(eventIdPorts).ClientPort],'UniformOutput',false);
                eventPortNames=arrayfun(@(x)x.Name,[mappingChildren(eventIdPorts).ClientPort],'UniformOutput',false);

                portsWithThisEventIdIdx=strcmp(this.FidMask.EventId,eventIds);
                portNamesWithEventId=eventPortNames(portsWithThisEventIdIdx);

                portNamesStr=autosar.api.Utils.cell2str(portNamesWithEventId);
                portNamesStr=strrep(portNamesStr,'''','');

                aPropValue=portNamesStr;
            case this.MaskColumn
                aPropValue=this.FidMask.Mask;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setPropValueImpl(this,aPropName,aPropValue)
            switch aPropName
            case this.IdColumn
                this.FidMask.setEventId(aPropValue);
            case this.MaskColumn
                this.FidMask.setMask(aPropValue);
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end
    end
end


