

classdef MLFuncDefNonInlinedGlobalVarConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function block with noninlined user defined '...
            ,'functions with global variable defined must not be '...
            ,'inside a reusable subsystem or void-void subsystem, '...
            ,'and CodeInterfacePackaging must be ''Nonreusable function'''];
        end


        function obj=MLFuncDefNonInlinedGlobalVarConstraint()
            obj.setEnum('MLFuncDefNonInlinedGlobalVar');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            ast=aObj.getOwner();
            assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
            if slci.matlab.astProcessor.MatlabFunctionUtils.isRootFunction(ast)

                return;
            end
            isNonInline=(ast.getInline==slci.compatibility.CoderInlineEnum.Never);
            hasGlobalVars=~isempty(ast.getGlobalSymbols)...
            ||~isempty(ast.getPersistentArgs());

            if isNonInline&&hasGlobalVars
                blk=ast.ParentBlock;

                mdlName=ast.ParentModel.getSystemName;
                codeInterfPackaging=get_param(mdlName,'CodeInterfacePackaging');
                if~strcmpi(codeInterfPackaging,'Nonreusable function')...
                    ||aObj.isInsideNonInlinedSubSystem(blk.getHandle)
                    out=slci.compatibility.Incompatibility(aObj,...
                    aObj.getEnum());
                end
            end
        end

    end

    methods(Access=private)

        function out=isInsideNonInlinedSubSystem(aObj,blkHandle)
            out=false;

            if strcmpi(get_param(blkHandle,'Type'),'block')
                blk_type=get_param(blkHandle,'BlockType');
                if strcmpi(blk_type,'SubSystem')
                    isInlined=slci.internal.isSubsystemInlined(blkHandle);
                    if~isInlined
                        out=true;
                        return;
                    end
                end
                parentHdl=get_param(blkHandle,'Parent');
                out=aObj.isInsideNonInlinedSubSystem(parentHdl);
            end
        end
    end

end