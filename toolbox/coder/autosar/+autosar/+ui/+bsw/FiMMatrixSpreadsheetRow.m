classdef FiMMatrixSpreadsheetRow<autosar.ui.bsw.SpreadsheetRow





    properties(SetAccess=private,GetAccess=public)
        FID;
    end

    properties(Access=public,Constant=true)

        FIDColumn=autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow.IdColumn;
    end

    methods
        function this=FiMMatrixSpreadsheetRow(dlgSource,fid)
            this=this@autosar.ui.bsw.SpreadsheetRow(dlgSource,true);
            this.FID=fid;
        end

        function aLabel=getDisplayLabel(this)
            aLabel=this.FID;
        end

        function bIsValid=isValidPropertyImpl(this,aPropName)
            switch aPropName
            case this.FIDColumn
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
            case this.FIDColumn
                mappingChildren=this.getMappingSpreadsheetRows();
                fidPorts=arrayfun(@(x)strcmp(x.IdType,'FID'),[mappingChildren.ClientPort]);
                portIds=arrayfun(@(x)x.PortDefinedArgument,[mappingChildren(fidPorts).ClientPort],'UniformOutput',false);
                portNames=arrayfun(@(x)x.Name,[mappingChildren(fidPorts).ClientPort],'UniformOutput',false);

                portsWithThisFidIdx=strcmp(this.FID,portIds);
                portNamesWithFid=portNames(portsWithThisFidIdx);

                portNamesStr=autosar.api.Utils.cell2str(portNamesWithFid);
                portNamesStr=strrep(portNamesStr,'''','');

                aPropValue=sprintf('FID %s: %s',this.FID,portNamesStr);
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setPropValueImpl(this,aPropName,aPropValue)
            switch aPropName
            case this.FIDColumn
                this.FID=aPropValue;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setFID(this,value)
            this.FID=value;
        end

        function addInhibitionCondition(this,fidMask)
            newRow=autosar.ui.bsw.FiMMatrixSpreadsheetInnerRow(this.DlgSource,this,fidMask);
            this.addHierarchicalChild(newRow);
        end
    end
end



