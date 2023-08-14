classdef CloseElementVisitor<evolutions.internal.filetypehandler.Visitor




    methods(Access=protected)
        function visitMFile(~,~)

        end

        function visitMlxFile(~,~)

        end

        function visitModelFile(~,fileType)
            filePath=fileType.FilePath;
            [~,modelName,~]=fileparts(filePath);
            if bdIsLoaded(modelName)
                close_system(modelName,0);
            end
        end

        function visitDDFile(~,fileType)
            filePath=fileType.FilePath;
            [~,fileName,fileExtention]=fileparts(filePath);
            openDDs=Simulink.data.dictionary.getOpenDictionaryPaths(sprintf('%s%s',fileName,fileExtention));
            if(ismember(filePath,openDDs))

                ddConnection=Simulink.dd.open(filePath);
                isDirty=ddConnection.hasUnsavedChanges;
                ddConnection.close();

                if(isDirty)
                    ddObj=Simulink.data.dictionary.open([fileName,fileExtention]);
                    discardChanges(ddObj);
                end
                Simulink.data.dictionary.closeAll([fileName,fileExtention]);
            end
        end

        function visitMexFile(~,fileType)
            filePath=fileType.FilePath;
            [~,mexFileName,~]=fileparts(filePath);
            evalin('base',sprintf('clear %s',mexFileName));
        end
    end
end


