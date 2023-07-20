classdef DiagnosticOutputUtilities






    properties(Constant=true,Access=private)

        CLEAN_MESSAGE_REGEX=['[^',10,']*',10,'?</a>',10,'?'];










        NO_HOTLINKS_CLEAN_MESSAGE_REGEX='.+LiveEditorEvaluationHelper\w*\.m[^:]+: ?(\d+)( \D+: ?\d+)?\n';

    end

    methods(Static,Hidden)
        function cleanedMessage=cleanMessage(message)





            import matlab.internal.editor.DiagnosticOutputUtilities;

            cleanedMessage=message;



            if~isempty(strfind(message,tempdir))||~isempty(strfind(message,prefdir))||~isempty(strfind(message,userpath))

                combinedRegex=['(',DiagnosticOutputUtilities.CLEAN_MESSAGE_REGEX,'|',DiagnosticOutputUtilities.NO_HOTLINKS_CLEAN_MESSAGE_REGEX,')'];
                cleanedMessage=regexprep(message,combinedRegex,'','once');
            end
        end




        function lineInFile=getLineNumberFromStack(stack,filePath)



            import matlab.internal.editor.DiagnosticOutputUtilities

            lineInFile=-1;


            if isempty(stack)
                return
            end


            fileNameIndex=DiagnosticOutputUtilities.findIndexForFile(stack,filePath);


            if isempty(fileNameIndex)
                return
            end




            if fileNameIndex==0
                return
            end

            lineInFile=stack(fileNameIndex).line;
        end



        function index=findIndexForFile(stack,filePath)


            index=[];
            startFrame=numel(stack);
            for i=startFrame:-1:1
                if(strcmp(stack(i).file,filePath))
                    index=i;
                    return;
                end
            end
        end


        function errText=cleanErrorText(errorText,fullFilePath,editorId)



            [~,fileName,extension]=fileparts(fullFilePath);
            tmpFolder=matlab.internal.editor.eval.TempFolder.getInstance().CurrentFolder;
            tmpFile=['LiveEditorEvaluationHelperE',editorId];
            tmpFileWithExtension=[tmpFile,'.m'];
            tmpFileFullPath=[tmpFolder,filesep,tmpFileWithExtension];

            errorText=strrep(errorText,tmpFileFullPath,fullFilePath);
            errorText=strrep(errorText,tmpFileWithExtension,[fileName,extension]);
            errorText=strrep(errorText,tmpFile,fileName);

            errText=errorText;
        end

    end
end

