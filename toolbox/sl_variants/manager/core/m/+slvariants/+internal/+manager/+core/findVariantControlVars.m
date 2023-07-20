function usageInfo=findVariantControlVars(modelName,varargin)













    load_system(modelName);
    bdH=get_param(modelName,'Handle');
    searchReferencedModels=true;
    if numel(varargin)>0
        searchReferencedModels=varargin{1};
    end
    usageInfoForHierarchy=slvariants.internal.manager.core.getVariantControlUsageInfo(bdH,searchReferencedModels);
    usageInfoPerModelMap=usageInfoForHierarchy.UsageInfo;
    modelNames=usageInfoPerModelMap.keys();


    usageInfo=struct('Name','','Value',{},'Exists',{},...
    'Usage',{},...
    'Source','','SourceType','');

    for modelIdx=1:numel(modelNames)
        dataDictionary=get_param(modelNames{modelIdx},'DataDictionary');
        if isempty(dataDictionary)
            ctrlVarSrc=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource;
            ctrlVarSrcType=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource;
        else
            ctrlVarSrc=dataDictionary;
            ctrlVarSrcType=slvariants.internal.manager.ui.config.VMgrConstants.DataDictionarySource;
        end
        dataAccessor=Simulink.data.DataAccessor.create(modelNames{modelIdx});
        usageInfoPerModel=usageInfoPerModelMap.getByKey(modelNames{modelIdx});
        varCtrlsMap=usageInfoPerModel.varCtrlInfo;
        varCtrls=varCtrlsMap.keys();
        for idx=1:numel(varCtrls)
            inArgs={varCtrls{idx},modelNames{modelIdx},dataAccessor,ctrlVarSrc,ctrlVarSrcType};


            usageInfo(end+1,1)=getVarCtrlInfo(inArgs);%#ok<AGROW>
        end


        usageInfo=getUsageAfterDeleteStruct(usageInfo);

        [~,idx]=unique(strcat({usageInfo.Name},{usageInfo.Source},{usageInfo.Usage}),'stable');
        usageInfo=struct(usageInfo(idx));


        varCtrlParams=usageInfoPerModel.varCtrlParamInfo.keys();

        for prmIdx=1:numel(varCtrlParams)
            varCtrls=usageInfoPerModel.varCtrlParamInfo.getByKey(varCtrlParams{prmIdx}).VariantControlVars;
            for idx=1:double(varCtrls.Size())
                ctrVar=varCtrls.at(idx);
                inArgs={ctrVar,modelNames{modelIdx},dataAccessor,ctrlVarSrc,ctrlVarSrcType};
                varCtrlInfo=getVarCtrlInfo(inArgs);
                if~varCtrlInfo.Exists
                    varCtrlInfo.Value=Simulink.VariantControl(Value=0);
                end
                usageInfo(end+1,1)=varCtrlInfo;%#ok<AGROW>
            end
        end


        [~,idx]=unique(strcat({usageInfo.Name},{usageInfo.Source},{usageInfo.Usage}),'stable');
        usageInfo=struct(usageInfo(idx));

    end
end

function varCtrlInfo=getVarCtrlInfo(inArgs)
    numOfInputArgs=5;
    if numel(inArgs)~=numOfInputArgs
        return;
    end
    ctrlVar=inArgs{1};
    modelName=inArgs{2};
    dataAccessor=inArgs{3};
    ctrlVarSrc=inArgs{4};
    ctrlVarSrcType=inArgs{5};

    varCtrlInfo=struct('Name',ctrlVar,'Value',0,'Exists',false,...
    'Usage',modelName,...
    'Source',ctrlVarSrc,...
    'SourceType',ctrlVarSrcType);

    if contains(ctrlVar,'.')
        structVarName=strsplit(ctrlVar,'.');
        structVarName=structVarName{1};
        varId=dataAccessor.identifyByName(structVarName);
        if isempty(varId)

            return;
        end
        try
            varCtrlInfo.Value=Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(modelName,ctrlVar);
            varCtrlInfo.Exists=true;
        catch
            varCtrlInfo.Value=0;
        end

        if isempty(varCtrlInfo.Value)
            varCtrlInfo.Value=0;
        end

        varCtrlInfo.Source=varId.getDataSourceFriendlyName;
    else
        varId=dataAccessor.identifyByName(ctrlVar);
        if isempty(varId)

            return;
        end
        varId=varId(1);
        varCtrlInfo.Value=dataAccessor.getVariable(varId);
        varCtrlInfo.Source=varId.getDataSourceFriendlyName;
        varCtrlInfo.Exists=true;
    end
    if endsWith(varCtrlInfo.Source,'.sldd')
        varCtrlInfo.SourceType=slvariants.internal.manager.ui.config.VMgrConstants.DataDictionarySource;
    else
        varCtrlInfo.SourceType=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceSource;
    end
end



function usageInfo=getUsageAfterDeleteStruct(usageInfo)
    structCtrlVars={};
    N=numel(usageInfo);
    for i=N:-1:1
        ctrlVarName=usageInfo(i).Name;
        if contains(ctrlVarName,'.')
            structVarName=strsplit(ctrlVarName,'.');
            structCtrlVars=[structCtrlVars,structVarName{1}];%#ok<AGROW>
        end
    end
    for i=N:-1:1
        if any(strcmp(usageInfo(i).Name,structCtrlVars))
            usageInfo(i)=[];
        end
    end
end


