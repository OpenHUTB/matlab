classdef BaseWorkspace<Simulink.io.FileType





    properties(Hidden)

aBaseWorkspace
    end



    methods


        function theReader=BaseWorkspace(varargin)

            theReader=theReader@Simulink.io.FileType(varargin{:});
            theReader.FileName='';
            try
                theReader.aBaseWorkspace=iofile.BaseWorkspace(theReader.FileName);
            catch ME
                throwAsCaller(ME);
            end
        end



        function[didWrite,errMsg]=export(aFile,fileName,cellOfVarNames,cellOfVarValues,isAppend)

            if isStringScalar(fileName)
                fileName=char(fileName);
            end

            if isstring(cellOfVarNames)
                cellOfVarNames=cellstr(cellOfVarNames);
            end

            if~iscellstr(cellOfVarNames)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNames');
            end

            if length(cellOfVarNames)~=length(cellOfVarValues)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNamesAndVals');
            end

            if~islogical(isAppend)&&~isnumeric(isAppend)
                DAStudio.error('sl_web_widgets:customfiles:isAppendLogical');
            end

            [didWrite,errMsg]=exportImpl(aFile,fileName,cellOfVarNames,cellOfVarValues,isAppend);
        end
    end


    methods(Hidden)


        function aList=whosImpl(aFile)%#ok<*MANU>
            checkList=whos(aFile.aBaseWorkspace);
            aList=[];
            if isempty(checkList)
                return
            end

            aList=struct;

            numVars=length(checkList);

            filterIDX=zeros(1,numVars);
            for kVar=1:numVars
                aList(kVar).name=checkList(kVar).name;
                varFromWS=evalin('base',aList(kVar).name);
                if~isVarSupported(aFile,varFromWS)

                    filterIDX(kVar)=1;
                else

                    aList(kVar).type=message('sl_web_widgets:customfiles:datasetType').getString;
                    outType=Simulink.io.FileType.getVariableTypeFromVariable(varFromWS);

                    if~isempty(outType)
                        aList(kVar).type=outType;
                    end
                end

            end

            aList(logical(filterIDX))=[];
        end


        function varOut=loadAVariableImpl(aFile,varName)%#ok<*INUSD,*STOUT>
            try
                varOut=loadAVariable(aFile.aBaseWorkspace,varName);
                if~isVarSupported(aFile,varOut)
                    DAStudio.error('sl_web_widgets:customfiles:slBaseWorkspaceLoadVarFiltered',varName);
                end
            catch ME
                throwAsCaller(ME);
            end


        end


        function matFileData=loadImpl(aFile)
            try
                matFileData=load(aFile.aBaseWorkspace);

                if isempty(matFileData)

                    DAStudio.error('sl_web_widgets:customfiles:slBaseWorkspaceLoadEmpty');
                end

                variableNames=fieldnames(matFileData);

                if isempty(variableNames)

                    DAStudio.error('sl_web_widgets:customfiles:slBaseWorkspaceLoadEmpty');
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
                        DAStudio.error('sl_web_widgets:customfiles:slBaseWorkspaceLoadEmpty');
                    end

                end

            catch ME
                throwAsCaller(ME);
            end
        end


        function validateFileNameImpl(aFile,str)




        end


        function[didWrite,errMsg]=exportImpl(~,~,cellOfVarNames,cellOfVarValues,isAppend)
            didWrite=true;
            errMsg='';



            N=length(cellOfVarNames);
            for k=1:N

                assignin('base',cellOfVarNames{k},cellOfVarValues{k});
            end


        end

    end


    methods(Static)


        function isSupported=isFileSupported(~)

            isSupported=true;

        end


        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_web_widgets:customfiles:slBaseWorkspaceDescription');
        end

    end
end
