


classdef LookupndTableDataDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'LookupndTableDataDataType',...
            aObj.ParentBlock().getName());
        end

    end

    methods
        function obj=LookupndTableDataDataTypeConstraint()
            obj.setEnum('LookupndTableDataDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            thisBlock=aObj.ParentBlock;
            aBlk=thisBlock.getParam('Object');
            dataSpec=thisBlock.getParam('DataSpecification');
            tableDataTypeStr=thisBlock.getParam('TableDataTypeStr');
            if strcmpi(dataSpec,'Lookup table object')
                tableDataTypeStr=slci.internal.getRuntimeParamFromBlock(...
                thisBlock.getUDDObject,...
                'Table',...
                'DataType');
            end
            compiledPortDataTypes=aObj.ParentBlock().getParam('CompiledPortDataTypes');
            if~strcmpi(tableDataTypeStr,'Inherit: Same as output')&&...
                ~strcmpi(tableDataTypeStr,compiledPortDataTypes.Outport{1})
                if~(slcifeature('VLUTObject')&&slci.internal.hasTunableLUTObject(aBlk)&&...
                    any(strcmpi(tableDataTypeStr,{'double','single'}))&&...
                    any(strcmpi(compiledPortDataTypes.Outport{1},{'double','single'})))
                    out=aObj.getIncompatibility();
                end
            end
        end
    end
end


