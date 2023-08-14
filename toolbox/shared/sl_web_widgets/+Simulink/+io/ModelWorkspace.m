classdef ModelWorkspace<Simulink.io.FileType&Simulink.io.BaseWorkspace










    methods


        function theReader=ModelWorkspace(varargin)

            theReader=theReader@Simulink.io.BaseWorkspace(varargin{:});
            if nargin>=1
                theReader.FileName=varargin{1};
            end
        end

    end


    methods(Hidden)


        function aList=whosImpl(aFile)%#ok<*MANU>
            aList=[];
            [~,fileName,~]=fileparts(aFile.FileName);

            if~exist(fileName,'file')
                error(message('sl_web_widgets:customfiles:slModelWorkspaceModelNotFound',aFile.FileName));
            end

            if~bdIsLoaded(fileName)
                load_system(fileName);
            end

            modelWorkspace=get_param(fileName,'ModelWorkspace');
            checkList=whos(modelWorkspace);
            if isempty(checkList)
                return
            end

            aList=struct;

            numVars=length(checkList);

            filterIDX=zeros(1,numVars);
            for kVar=1:numVars
                aList(kVar).name=checkList(kVar).name;
                varFromWS=getVariable(modelWorkspace,aList(kVar).name);
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
                [~,fileName,~]=fileparts(aFile.FileName);

                if~exist(aFile.FileName,'file')
                    error(message('sl_web_widgets:customfiles:slModelWorkspaceModelNotFound',aFile.FileName));
                end

                if~bdIsLoaded(fileName)
                    load_system(fileName);
                end

                modelWorkspace=get_param(fileName,'ModelWorkspace');
                varOutMWS=getVariable(modelWorkspace,varName);


                if~isVarSupported(aFile,varOutMWS)

                    DAStudio.error('sl_web_widgets:customfiles:slModelWorkspaceLoadVarFiltered',varName);
                end

                varOut.(varName)=varOutMWS;
            catch ME
                throwAsCaller(ME);
            end


        end


        function matFileData=loadImpl(aFile)

            try
                aList=whos(aFile);

                if isempty(aList)

                    DAStudio.error('sl_web_widgets:customfiles:slModelWorkspaceLoadEmpty');
                end

                variableNames={aList(:).name};
                matFileData=struct;


                for k=1:length(variableNames)
                    outVar=loadAVariableImpl(aFile,variableNames{k});
                    matFileData.(variableNames{k})=outVar.(variableNames{k});
                end

            catch ME
                throwAsCaller(ME);
            end
        end


        function[didWrite,errMsg]=exportImpl(~,fileName,cellOfVarNames,cellOfVarValues,isAppend)
            didWrite=true;
            errMsg='';

            try
                [~,fileName,~]=fileparts(fileName);

                if~exist(fileName,'file')
                    error(message('sl_web_widgets:customfiles:slModelWorkspaceModelNotFound',fileName));
                end

                if~bdIsLoaded(fileName)
                    load_system(fileName);
                end
                modelWorkspace=get_param(fileName,'ModelWorkspace');
            catch ME
                throwAsCaller(ME);
            end


            N=length(cellOfVarNames);

            try
                for k=1:N

                    modelWorkspace.assignin(cellOfVarNames{k},cellOfVarValues{k});
                end
            catch ME_ASSIGN
                throwAsCaller(ME_ASSIGN);
            end
        end


        function validateFileNameImpl(aFile,str)


            if(isempty(str))
                return;
            end


            [~,~,ext]=fileparts(str);
            if~strcmp(ext,'.slx')&&~strcmp(ext,'.mdl')
                DAStudio.error('sl_web_widgets:customfiles:invalidFileTypeModelWS',str);
            end
        end
    end


    methods(Static)


        function isSupported=isFileSupported(fileLocation)


            isSupported=false;

            [~,~,ext]=fileparts(fileLocation);
            if strcmpi(ext,'.mdl')||strcmpi(ext,'.slx')

                isSupported=true;
            end

        end


        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_web_widgets:customfiles:slModelWorkspaceDescription');
        end

    end

end
