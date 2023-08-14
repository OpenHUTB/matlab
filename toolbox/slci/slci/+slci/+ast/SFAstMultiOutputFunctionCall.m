


classdef SFAstMultiOutputFunctionCall<slci.ast.SFAstFunction

    methods


        function out=isSFSLFunction(aObj)
            aName=aObj.fName;
            switch aName

            case aObj.MATH_FNS
                out=false;
            otherwise
                fnPath=aObj.getFunctionPath;
                out=aObj.ParentChart.isSFSLFunction(fnPath);
            end
        end


        function aObj=SFAstMultiOutputFunctionCall(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAstFunction(aAstObj,aParent);

            aFuncTrimmed=strrep(aAstObj.sourceSnippet,'...','');
            aFuncSplitted=regexp(aFuncTrimmed,'=','split');



            aNameAndInputs=regexp(aFuncSplitted{2},'(','split');

            aObj.fName=strtrim(aNameAndInputs{1});
            aObj.fSfId=aAstObj.id;
        end

    end
end
