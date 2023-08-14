classdef MatFile<Simulink.io.FileType





    properties(Hidden)

aMatFile
    end



    methods


        function theReader=MatFile(varargin)

            theReader=theReader@Simulink.io.FileType(varargin{:});

            if~isempty(theReader.FileName)
                try
                    theReader.aMatFile=iofile.STAMatFile(theReader.FileName);
                catch ME
                    throwAsCaller(ME);
                end
            end
        end

    end


    methods(Hidden)


        function aList=whosImpl(aFile)%#ok<*MANU>
            unsortedMatFileData=load(aFile.FileName);
            theNameOfTheFields=fieldnames(unsortedMatFileData);

            aList=struct;

            FOUND_VALID=false;
            for k=1:length(theNameOfTheFields)

                if isVarSupported(aFile,unsortedMatFileData.(theNameOfTheFields{k}))
                    aList(k).name=theNameOfTheFields{k};
                    FOUND_VALID=true;


                    aList(k).type=message('sl_web_widgets:customfiles:datasetType').getString;

                    outType=Simulink.io.FileType.getVariableTypeFromVariable(unsortedMatFileData.(theNameOfTheFields{k}));

                    if~isempty(outType)
                        aList(k).type=outType;
                    end

                end

            end

            if~FOUND_VALID
                aList=[];
            end

        end


        function varOut=loadAVariableImpl(aFile,varName)%#ok<*INUSD,*STOUT>
            try
                refreshMatFileProperty(aFile);
                varOut=loadAVariable(aFile.aMatFile,varName);

                if~isVarSupported(aFile,varOut)
                    DAStudio.error('sl_web_widgets:customfiles:slMatFileLoadVarFiltered',aFile.FileName,varName);
                end

            catch ME
                throwAsCaller(ME);
            end


        end


        function matFileData=loadImpl(aFile)
            try
                refreshMatFileProperty(aFile);
                matFileData=load(aFile.aMatFile);

                if isempty(matFileData)

                    DAStudio.error('sl_web_widgets:customfiles:slMatFileLoadEmpty',aFile.FileName);
                end

                variableNames=fieldnames(matFileData);

                if isempty(variableNames)

                    DAStudio.error('sl_web_widgets:customfiles:slMatFileLoadEmpty',aFile.FileName);
                end

                fieldsToRemove=cell(1,length(variableNames));
                for kName=1:length(variableNames)
                    if~isVarSupported(aFile,matFileData.(variableNames{kName}))
                        fieldsToRemove{kName}=variableNames{kName};
                    end
                end


                fieldsToRemove(cellfun(@isempty,fieldsToRemove))=[];

                if~isempty(fieldsToRemove)
                    matFileData=rmfield(matFileData,fieldsToRemove);

                    if isempty(fieldnames(matFileData))
                        DAStudio.error('sl_web_widgets:customfiles:slMatFileLoadEmpty',...
                        aFile.FileName);
                    end

                end

            catch ME
                throwAsCaller(ME);
            end
        end


        function validateFileNameImpl(aFile,str)



            if(isempty(str))
                return;
            end


            [~,~,ext]=fileparts(str);
            if~strcmp(ext,'.mat')
                DAStudio.error('sl_iofile:matfile:invalidFileType',str)
            end
        end


        function[didWrite,errMsg]=exportImpl(~,fileName,cellOfVarNames,cellOfVarValues,isAppend)
            try
                [didWrite,errMsg]=iofile.MatFile.save(...
                fileName,cellOfVarNames,cellOfVarValues,isAppend);
            catch ME
                throwAsCaller(ME);
            end
        end

    end


    methods(Access=protected)


        function refreshMatFileProperty(aFile)


            if isempty(aFile.aMatFile)||~strcmpi(aFile.FileName,aFile.aMatFile.FileName)
                try
                    aFile.aMatFile=iofile.STAMatFile(aFile.FileName);
                catch ME
                    throwAsCaller(ME);
                end
            end
        end
    end



    methods(Static)


        function isSupported=isFileSupported(fileLocation)
            isSupported=false;

            [~,~,ext]=fileparts(fileLocation);
            if strcmpi(ext,'.mat')

                isSupported=true;
            end

        end


        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_web_widgets:customfiles:slMatFileDescription');
        end

    end


end
