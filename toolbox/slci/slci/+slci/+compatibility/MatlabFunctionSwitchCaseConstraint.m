


classdef MatlabFunctionSwitchCaseConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function switch statement must not have '...
            ,'cell array as its case selection'];
        end


        function obj=MatlabFunctionSwitchCaseConstraint
            obj.setEnum('MatlabFunctionSwitchCase');
            obj.setFatal(false);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstSwitch'));


            isUnsupported=aObj.hasCellArray(owner);
            if isUnsupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end

        end

    end

    methods(Access=private)


        function out=hasCellArray(~,switchAst)
            assert(isa(switchAst,'slci.ast.SFAstSwitch'));
            out=false;

            caseAsts=switchAst.getCaseAST;
            for i=1:numel(caseAsts)
                condAst=caseAsts{i}.getCondAST;
                assert(iscell(condAst)&&numel(condAst)==1);
                caseCondAst=condAst{1};

                if isa(caseCondAst,'slci.ast.SFAstLC')
                    out=true;
                    return;
                end
            end
        end

    end
end