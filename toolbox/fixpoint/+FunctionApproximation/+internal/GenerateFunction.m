classdef GenerateFunction<handle


    properties
        DocumentObj;
    end

    methods
        function this=GenerateFunction(tableData,problem,fileName,fileLocation)











            if isa(problem.FunctionToApproximate,'function_handle')
                functionName=func2str(problem.FunctionToApproximate);
            else
                functionName=problem.FunctionToApproximate;
            end
            commentsToAdd=splitlines(FunctionApproximation.internal.approximationblock.getProblemDescriptionForApproximationBlock(problem));

            scriptGenerator=FunctionApproximation.internal.LUTScriptGenerator(tableData,problem.InputTypes,problem.OutputType,problem.Options.BreakpointSpecification);
            codeString=scriptGenerator.getMATLABScript();
            codeString=scriptGenerator.getCommentstoAddString(codeString,functionName,commentsToAdd);

            this.DocumentObj=stringToFileConversion(this,tableData,problem.InputTypes,fileName,fileLocation,codeString);
        end

        function docObj=stringToFileConversion(~,tableData,inputType,filename,fileLocation,codeString)
            fileName=strsplit(filename,'.');
            codeString=strrep(codeString,'#FILENAME',fileName{1});

            stringToLoadMatFile=FunctionApproximation.internal.getStringToLoadMatFile(tableData.TableValues,fileName{1});
            codeString=strrep(codeString,'#LOAD_MAT_FILE',stringToLoadMatFile);

            if~isempty(fileLocation)
                cd(fileLocation);
            end

            [success,diagnostic]=FunctionApproximation.internal.Utils.convertStringToFile(codeString,filename);



            if~success
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end

            docObj=matlab.desktop.editor.openDocument(which(filename));
            docObj.smartIndentContents;
            docObj.save;








            if numel(tableData.TableValues)>=1000
                FunctionApproximation.internal.generateMatFile(tableData,inputType,fileName{1});
            end
        end
    end
end

