



classdef MatlabFunctionIfCondDimConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Matlab function if statement condition must be scalar';
        end


        function obj=MatlabFunctionIfCondDimConstraint
            obj.setEnum('MatlabFunctionIfCondDim');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstIf'));
            ifhead=owner.getIfHeadAST();

            assert(iscell(ifhead)&&numel(ifhead)==1);
            condAst=ifhead{1}.getCondAST();
            assert(iscell(condAst)&&numel(condAst)==1);
            isSupported=aObj.isSupportedCond(condAst{1});

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end

    methods(Access=private)

        function isSupported=isSupportedCond(aObj,condAst)
            dataDim=condAst.getDataDim();
            isSupported=true;
            if~isequal(dataDim,-1)

                [flag,dataDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,dataDim);
                if~flag
                    isSupported=false;
                    return;
                end
                isSupported=(prod(dataDim)==1);
            end
        end
    end
end