classdef NvMInitValSpreadsheetRow<autosar.ui.bsw.SpreadsheetRow




    properties(SetAccess=private,GetAccess=public)
        BlockId;
        InitValStr;
    end

    properties(Access=public,Constant=true)
        IdColumn=DAStudio.message('autosarstandard:ui:uiRTEBlockIdColumn');
        NvBlockPortsColumn=DAStudio.message('autosarstandard:ui:uiRTEPortsColumn');
        InitValColumn=DAStudio.message('autosarstandard:ui:uiNvMInitValueColumn');
    end

    methods
        function this=NvMInitValSpreadsheetRow(dlgSource,blockId)
            this=this@autosar.ui.bsw.SpreadsheetRow(dlgSource,false);
            this.BlockId=blockId;
            this.InitValStr='0';
        end

        function aLabel=getDisplayLabel(this)
            aLabel=this.BlockId;
        end

        function bIsValid=isValidPropertyImpl(this,aPropName)
            switch aPropName
            case{this.NvBlockPortsColumn
                this.InitValColumn
                this.IdColumn}
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function bIsReadOnly=isReadonlyPropertyImpl(this,aPropName)
            switch aPropName
            case this.InitValColumn
                bIsReadOnly=false;
            otherwise
                bIsReadOnly=true;
            end
        end

        function propType=getPropDataTypeImpl(this,aPropName)%#ok<INUSD>
            propType='text';
        end

        function aPropValue=getPropValueImpl(this,aPropName)
            switch aPropName
            case this.IdColumn
                aPropValue=this.BlockId;
            case this.NvBlockPortsColumn
                clientPorts=this.getClientPortsForThisRow();
                clientPortsData={clientPorts.ClientPort};
                portNames=cellfun(@(x)x.Name,clientPortsData,'UniformOutput',false);

                portNamesStr=autosar.api.Utils.cell2str(portNames);
                portNamesStr=strrep(portNamesStr,'''','');

                aPropValue=sprintf('%s',portNamesStr);
            case this.InitValColumn
                aPropValue=this.InitValStr;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setPropValueImpl(this,aPropName,aPropValue)
            switch(aPropName)
            case this.InitValColumn
                this.InitValStr=aPropValue;
            otherwise
                assert(false,'Accessing unexpected property');
            end
        end

        function setBlockId(this,value)
            this.BlockId=value;
        end

        function setInitVal(this,value)
            this.InitValStr=value;
        end
    end

    methods(Access=private)
        function clientPorts=getClientPortsForThisRow(this)
            mappingChildren=this.getMappingSpreadsheetRows();
            nvBlockPorts=arrayfun(@(x)strcmp(x.IdType,'BlockId'),[mappingChildren.ClientPort]);
            portIds=arrayfun(@(x)x.PortDefinedArgument,[mappingChildren(nvBlockPorts).ClientPort],'UniformOutput',false);

            portsWithThisBlockIdIdx=strcmp(this.BlockId,portIds);
            clientPorts=mappingChildren(portsWithThisBlockIdIdx);
        end
    end
end


