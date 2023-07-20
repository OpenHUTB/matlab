

classdef Utils

    properties(Constant,Hidden=true)
        SIM_SIL_MODE_STR='software-in-the-loop (sil)'
        SIM_PIL_MODE_STR='processor-in-the-loop (pil)'
        SIM_NORMAL_MODE_STR='normal'
        SIM_ACCEL_MODE_STR='accelerator'
        SIM_RACCEL_MODE_STR='rapid-accelerator'
        SIM_EXTERNAL_MODE_STR='external'

        MAX_PATH_LENGTH=260
    end

    methods(Static)




        function modelInfo=extractExcludedModelInfo(excludedModelStr)

            narginchk(1,1);


            modelInfo=struct('normal',{{}},'sil',{{}},'pil',{{}},'accel',{{}});

            if isempty(excludedModelStr)
                return
            else
                validateattributes(excludedModelStr,...
                {'char'},{'nrows',1},'extractExcludedModelInfo','',1);
            end


            modelList=regexp(excludedModelStr,'([^\s,]+)[\s,]*','tokens');
            modelList=[modelList{:}];

            allModeNames=fieldnames(modelInfo);

            for ii=1:numel(modelList)

                name=regexpi(modelList{ii},'^([^:]+):(sil|pil|normal|accel)$','tokens');
                if isempty(name)


                    fNames=allModeNames;
                    modelName=modelList{ii};
                else

                    fNames={lower(name{1}{2})};
                    modelName=name{1}{1};
                end


                for jj=1:numel(fNames)
                    modelInfo.(fNames{jj}){end+1}=modelName;
                end
            end


            for f=allModeNames
                val=modelInfo.(f{1});
                if~isempty(val)
                    modelInfo.(f{1})=unique(val);
                end
            end
        end




        function modelInfo=extractModelReferenceInfo(modelName,simMode,keepLoadedModels)

            narginchk(1,3);


            modelInfo=struct('accel',{{}},'normal',{{}},...
            'sil',{{}},'pil',{{}},'topsil',{{}},'toppil',{{}});


            loadedModels=find_system('type','block_diagram');
            modelsToClose={};


            if ischar(modelName)
                loadModelIfRequired(modelName);
            elseif is_simulink_handle(modelName)
                modelName=get_param(modelName,'Name');
            end

            if nargin<3
                keepLoadedModels=true;
            end

            if nargin<2
                simMode=get_param(modelName,'SimulationMode');
            end


            normalSimModeStr=SlCov.Utils.SIM_NORMAL_MODE_STR;
            accelSimModeStr=SlCov.Utils.SIM_ACCEL_MODE_STR;
            silSimModeStr=SlCov.Utils.SIM_SIL_MODE_STR;
            pilSimModeStr=SlCov.Utils.SIM_PIL_MODE_STR;

            allowedSimModeStr={accelSimModeStr,normalSimModeStr,silSimModeStr,pilSimModeStr};
            modeFieldNames=fieldnames(modelInfo);

            simModeIdx=find(strcmpi(simMode,allowedSimModeStr),1);
            if isempty(simModeIdx)
                return
            end


            visitedMdls=containers.Map('KeyType','char','valueType','logical');



            if coder.connectivity.XILSubsystemUtils.isAtomicSubsystem(modelName)

                harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelName);
                xilMdlName=harnessInfo.model;
                xilSimModeOffSet=0;
                xilMdlBlk=get_param([modelName,'/XILSSBlock'],'handle');

                xilMdlSimModeIdx=find(...
                strcmpi(get_param(xilMdlBlk,'SimulationMode'),allowedSimModeStr),1);


                if(xilMdlSimModeIdx>2)&&strcmpi(get_param(xilMdlBlk,'CodeInterface'),'top model')
                    xilSimModeOffSet=2;
                end

                modelInfo.(modeFieldNames{xilMdlSimModeIdx+xilSimModeOffSet}){end+1}=xilMdlName;
            else
                recurseIntoModelBlocks(modelName,simModeIdx);
            end


            if~keepLoadedModels
                cellfun(@(x)close_system(x,0),modelsToClose);
            end

            function recurseIntoModelBlocks(pModelName,pSimModeIdx)




                mdlBlks=find_system(pModelName,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','BlockType','ModelReference');


                mdlBlks(strcmpi(get_param(mdlBlks,'ProtectedModel'),'on'))=[];



                for ii=1:numel(mdlBlks)
                    mdlName=get_param(mdlBlks{ii},'ModelName');
                    simModeOffSet=0;
                    if pSimModeIdx>2


                        mdlSimModeIdx=pSimModeIdx;
                    else


                        mdlSimModeIdx=find(...
                        strcmpi(get_param(mdlBlks{ii},'SimulationMode'),allowedSimModeStr),1);


                        if(mdlSimModeIdx>2)&&strcmpi(get_param(mdlBlks{ii},'CodeInterface'),'top model')
                            simModeOffSet=2;
                        end
                    end


                    key=sprintf('%s_%d',mdlName,mdlSimModeIdx+simModeOffSet);
                    if visitedMdls.isKey(key)
                        continue
                    end
                    visitedMdls(key)=true;


                    modelInfo.(modeFieldNames{mdlSimModeIdx+simModeOffSet}){end+1}=mdlName;


                    loadModelIfRequired(mdlName);
                    recurseIntoModelBlocks(mdlName,mdlSimModeIdx);
                end
            end

            function loadModelIfRequired(mdlName)
                if~any(strcmp(mdlName,loadedModels))
                    load_system(mdlName);
                    loadedModels{end+1}=mdlName;
                    modelsToClose{end+1}=mdlName;
                end
            end

        end




        function status=isfile(fileName)


            info=dir(fileName);
            status=(numel(info)==1)&&(info.isdir==0);




        end





        function fileName=fixLongFileName(fileName)
            if ispc&&(numel(fileName)>SlCov.Utils.MAX_PATH_LENGTH)
                if isletter(fileName(1))&&fileName(2)==':'
                    fileName=['\\?\',fileName];
                elseif fileName(1)=='\'&&fileName(2)=='\'
                    fileName=['\\?\UNC\',fileName(3:end)];
                end
            end
        end





        function sfunName=fixSFunctionName(sfunName)
            sfunName=regexprep(strtrim(sfunName),'^''(.*)''$','$1');
        end
    end

end
