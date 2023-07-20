




classdef FcnBlock<slci.simulink.Block

    properties
        fAsts={};
        fContainsUnsupportedAst=false;
    end

    methods(Access=private)


        function populateAst(aObj)
            expr=get_param(aObj.getSID(),'Expression');
            try
                ast=aObj.makeAst(expr);
            catch ME
                ast=slci.ast.SFAstUnsupported({},{});
                if(strcmpi(ME.identifier,'Slci:slci:mtreeParseError'))
                    aObj.fContainsUnsupportedAst=true;
                end
            end
            aObj.fAsts{1}=ast;
        end


        function ast=makeAst(aObj,mexpr)
            ast=slci.matlab.astTranslator.translateMATLABExpr(mexpr,aObj);
        end

    end

    methods

        function asts=getAsts(aObj)
            asts=aObj.fAsts;
        end

        function out=getContainsFailedParse(aObj)
            out=aObj.fContainsUnsupportedAst;
        end




        function obj=FcnBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.populateAst();
            obj.addConstraint(slci.compatibility.FcnUnsupportedAstConstraint);
            obj.addConstraint(slci.compatibility.FcnWorkspaceVarConstraint);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end
    end
end

