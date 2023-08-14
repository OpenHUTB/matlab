



classdef LookupObjTableAndBreakpointDataTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'LookupObjTableAndBreakpointDataType',...
            aObj.ParentBlock().getName());
        end
    end

    methods

        function obj=LookupObjTableAndBreakpointDataTypeConstraint()
            obj.setEnum('LookupObjTableAndBreakpointDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            thisBlock=aObj.ParentBlock;
            aBlk=thisBlock.getParam('Object');
            assert(strcmpi(thisBlock.getParam('BlockType'),'Lookup_n-D'));
            dataSpec=thisBlock.getParam('DataSpecification');
            try
                num_of_tab_dim=slResolve(aBlk.NumberOfTableDimensions,...
                aBlk.Handle);
            catch ME
                num_of_tab_dim=0;
            end
            if strcmpi(dataSpec,'Lookup table object')&&...
                (num_of_tab_dim>0)
                paramDataTypeStr=slci.internal.getRuntimeParamFromBlock(...
                thisBlock.getUDDObject,...
                'Table',...
                'DataType');
                for i=1:num_of_tab_dim
                    bpDataTypeStr=slci.internal.getRuntimeParamFromBlock(...
                    aBlk,...
                    ['BreakpointsForDimension',num2str(i)],...
                    'DataType');
                    if~strcmpi(paramDataTypeStr,bpDataTypeStr)
                        out=aObj.getIncompatibility();
                        break;
                    end
                end
            end
        end
    end
end


