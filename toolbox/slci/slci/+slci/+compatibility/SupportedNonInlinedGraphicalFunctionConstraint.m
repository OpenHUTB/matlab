





classdef SupportedNonInlinedGraphicalFunctionConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Supported non inlined Graphical Function configuration';
        end


        function obj=SupportedNonInlinedGraphicalFunctionConstraint()
            obj.setEnum('SupportedNonInlinedGraphicalFunction');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end



        function out=check(aObj)
            out=[];
            if(aObj.getOwner().isInlined())
                return;
            end

            modelName=aObj.ParentModel().getName();

            codeInterfPackaging=get_param(modelName,'CodeInterfacePackaging');
            if~strcmpi(codeInterfPackaging,'Nonreusable function')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
            end
        end
    end

end
