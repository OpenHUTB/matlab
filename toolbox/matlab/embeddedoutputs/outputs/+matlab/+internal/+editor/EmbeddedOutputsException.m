classdef EmbeddedOutputsException<matlab.internal.editor.EvaluatorException







    properties(Constant=true,Access=private)

        CLEAN_MESSAGE_REGEX=['[^',10,']*',10,'?</a>',10,'?'];










        NO_HOTLINKS_CLEAN_MESSAGE_REGEX='.+filename[^:]+: ?(\d+)(\D+: ?\d+)?\n';
        FILE_NAME_PLACEHOLDER='filename';
    end

    properties(Access=private)
PrunedStack
    end

    methods
        function obj=EmbeddedOutputsException(mException,tempFilePath,actualFilePath)



            import matlab.internal.editor.EmbeddedOutputsException



            obj@matlab.internal.editor.EvaluatorException(mException,tempFilePath,mException.arguments);



            obj.message=EmbeddedOutputsException.cleanMessage(mException.message,actualFilePath);



            obj.PrunedStack=EmbeddedOutputsException.pruneSelfFromStack(mException.stack,tempFilePath);
        end

    end

    methods(Access=protected)
        function stack=getStack(obj)






            stack=obj.PrunedStack;
        end

    end

    methods(Static,Hidden)
        function prunedStack=pruneSelfFromStack(stack,filePath)




            import matlab.internal.editor.DiagnosticOutputUtilities

            prunedStack=stack;

            indexOfFile=DiagnosticOutputUtilities.findIndexForFile(stack,filePath);
            if~isempty(indexOfFile)
                prunedStack=stack(1:indexOfFile-1);
            end
        end

        function cleanedMessage=cleanMessage(message,filePath)




            import matlab.internal.editor.EmbeddedOutputsException



            escapedFilePath=regexptranslate('escape',filePath);



            noHotlinksRegexp=strrep(...
            EmbeddedOutputsException.NO_HOTLINKS_CLEAN_MESSAGE_REGEX,...
            EmbeddedOutputsException.FILE_NAME_PLACEHOLDER,...
            escapedFilePath);

            combinedRegex=['(',EmbeddedOutputsException.CLEAN_MESSAGE_REGEX,'|',noHotlinksRegexp,')'];
            cleanedMessage=message;
            partToRemove=regexp(message,combinedRegex,'match');
            if contains(partToRemove,filePath)
                cleanedMessage=regexprep(message,combinedRegex,'','once');
            end
        end
    end
end

