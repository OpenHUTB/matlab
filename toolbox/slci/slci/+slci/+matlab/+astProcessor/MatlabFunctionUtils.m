




classdef MatlabFunctionUtils

    methods(Static=true)


        function flag=isRootFunction(ast)
            assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));

            rootAstOwner=ast.getRootAstOwner();
            assert(isa(rootAstOwner,'slci.matlab.EMChart'));
            rootId=rootAstOwner.getRootFunctionID();
            flag=(rootId~=-1)&&(rootId==ast.getFunctionID());
        end


        function flag=isSameScript(ast1,ast2)
            if(ast1==ast2)
                flag=true;
            else
                [has1,scriptPath1]=...
                slci.matlab.astProcessor.MatlabFunctionUtils.getScriptPath(ast1);
                [has2,scriptPath2]=...
                slci.matlab.astProcessor.MatlabFunctionUtils.getScriptPath(ast2);
                flag=has1&&has2&&strcmp(scriptPath1,scriptPath2);
            end
        end


        function[flag,scriptPath]=getScriptPath(ast)


            flag=false;
            scriptPath='';

            rootAst=ast.getRootAst();
            assert(isa(rootAst,'slci.ast.SFAstMatlabFunctionDef'));
            fid=rootAst.getFunctionID();
            if(fid~=-1)
                chart=rootAst.getRootAstOwner();
                assert(isa(chart,'slci.matlab.EMChart'));
                if chart.getScriptInfo().hasScriptPath(fid)
                    flag=true;
                    scriptPath=chart.getScriptInfo().getScriptPath(fid);
                end
            end
        end
    end

end
