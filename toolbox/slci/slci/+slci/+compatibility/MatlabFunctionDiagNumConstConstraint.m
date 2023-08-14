





classdef MatlabFunctionDiagNumConstConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Diagonal number in diag() built-in function must be literal const integer';
        end


        function obj=MatlabFunctionDiagNumConstConstraint
            obj.setEnum('MatlabFunctionDiagNumConst');
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstDiag'));
            children=owner.getChildren();

            if numel(children)>1

                supported=false;
                [success,value]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(children{2});
                if success

                    supported=isequal(value,floor(value));
                end

                if~supported
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum()...
                    );
                end
            end
        end

    end

end
