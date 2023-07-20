



function[refModelNames,refModelHandles,topModelIsSILPIL,hasNormalModeRefModel,modelInfoMap]=...
    getRecordingModels(topModelName,opts,fromCvSim,topModelSimMode)

    persistent fieldComparisonInfo
    if isempty(fieldComparisonInfo)


        fieldComparisonInfo={...
        {'sil','topsil'},'sil',[SlCov.CovMode.ModelRefSIL,SlCov.CovMode.SIL];...
        {'pil','toppil'},'pil',[SlCov.CovMode.ModelRefPIL,SlCov.CovMode.PIL]...
        };
    end


    if ishandle(topModelName)
        topModelName=get_param(topModelName,'Name');
    end

    if nargin<3
        fromCvSim=false;
    end


    if(nargin<4)||isempty(topModelSimMode)
        topModelSimMode=lower(get_param(topModelName,'SimulationMode'));
    end
    modelRefInfo=SlCov.Utils.extractModelReferenceInfo(topModelName,topModelSimMode,true);
    hasNormalModeRefModel=~isempty(unique(modelRefInfo.normal));


    allowedSimModeStr={SlCov.Utils.SIM_SIL_MODE_STR,SlCov.Utils.SIM_PIL_MODE_STR};

    topModelIsSILPIL=ismember(topModelSimMode,allowedSimModeStr);


    allModeNames=fieldnames(modelRefInfo);
    hasRefModel=false;
    for ii=1:numel(allModeNames)
        if~isempty(modelRefInfo.(allModeNames{ii}))
            hasRefModel=true;
            break
        end
    end

    if~hasRefModel||~opts.modelRefEnable

        hasNormalModeRefModel=false;
        refModelNames=cell(1,0);
        refModelHandles=zeros(1,0);
        modelInfoMap=[];
    else


        if strcmpi(opts.covModelRefEnable,'filtered')
            modelRefExcludedStr=opts.covModelRefExcluded;
        else
            modelRefExcludedStr='';
        end
        modelRefExcludedInfo=SlCov.Utils.extractExcludedModelInfo(modelRefExcludedStr);


        modelInfoMap=containers.Map('KeyType','char','ValueType','any');
        for ii=1:size(fieldComparisonInfo,1)
            excludedMdlNames=modelRefExcludedInfo.(fieldComparisonInfo{ii,2});
            modelRefInfoFields=fieldComparisonInfo{ii,1};
            modelRefInfoModes=fieldComparisonInfo{ii,3};
            for jj=1:numel(modelRefInfoFields)

                incMdlNames=modelRefInfo.(modelRefInfoFields{jj});
                incMdlNames(ismember(incMdlNames,excludedMdlNames))=[];


                for kk=1:numel(incMdlNames)
                    if modelInfoMap.isKey(incMdlNames{kk})
                        modeList=modelInfoMap(incMdlNames{kk});
                    else
                        modeList=SlCov.CovMode.empty();
                    end

                    modelInfoMap(incMdlNames{kk})=unique([modeList,modelRefInfoModes(jj)]);
                end
            end
        end


        refModelNames=modelInfoMap.keys();
        refModelHandles=get_param(refModelNames,'Handle');
        refModelHandles=[refModelHandles{:}];
        refModelHandles=refModelHandles(:)';
    end



    if opts.recordCoverage||(fromCvSim&&isempty(refModelNames))

        topModel=false;
        if strcmpi(topModelSimMode,SlCov.Utils.SIM_SIL_MODE_STR)
            topModel=true;
        elseif strcmpi(topModelSimMode,SlCov.Utils.SIM_PIL_MODE_STR)
            topModel=true;
        end

        if topModel
            refModelNames=[{topModelName},refModelNames];
            refModelHandles=[get_param(topModelName,'Handle'),refModelHandles];
        end
    end
