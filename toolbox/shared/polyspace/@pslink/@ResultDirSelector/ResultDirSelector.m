

function this=ResultDirSelector(systemH,isMdlRef,options)

    narginchk(1,3);

    if nargin<2
        isMdlRef=false;
    end

    if nargin<3
        options=[];
    end

    this=pslink.ResultDirSelector;

    systemName=getfullname(systemH);
    modelName=bdroot(systemName);
    try
        sysID=Simulink.ID.getSID(systemName);
    catch Me %#ok<NASGU>
        sysID=getfullname(systemName);
    end



    mdlRefs=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',true);
    sysResultInfo=pslink.verifier.ResultInfo.getInfo(systemName,3,isMdlRef,options);

    this.isModel=strcmp(systemName,modelName);

    this.treeItems={};
    this.goodTreeItems=[];
    this.treeItemsList={};
    this.isMdlRef=isMdlRef;


    if isempty(sysResultInfo)||~strcmp(sysID,sysResultInfo.systemID)||isempty(sysResultInfo.resultDir)
        return
    end


    useCfg=false;
    if~isempty(sysResultInfo.configFileName)&&~isempty(sysResultInfo.topModuleName)
        rootDir=fileparts(sysResultInfo.resultDir);
        cfgFileName=fullfile(rootDir,sysResultInfo.configFileName);
        if exist(rootDir,'dir')==7&&exist(cfgFileName,'file')==2
            useCfg=true;
            cfgFileObj=pslink.verifier.ConfigFile(cfgFileName);
            sysResDir=cfgFileObj.getResults(true,sysResultInfo.topModuleName);
            if isempty(sysResDir)
                sysResDir=cfgFileObj.getResults(false,sysResultInfo.topModuleName);
            end
            if~isempty(sysResDir)
                sysResultInfo.resultDir=sysResDir{end,1};
            end
        end
    end

    this.sysDir=sysResultInfo.resultDir;
    this.isBugFinder=strcmpi(sysResultInfo.productMode,'bugfinder');
    sysTreeItem={[systemName,' (',sysResultInfo.resultDir,')']};

    if~iscell(sysResultInfo.mdlRefInfo)||size(sysResultInfo.mdlRefInfo,2)~=3
        return
    end

    mrefTreeItems={};
    for ii=1:size(sysResultInfo.mdlRefInfo,1)
        if~ismember(sysResultInfo.mdlRefInfo{ii,1},mdlRefs)||~ischar(sysResultInfo.mdlRefInfo{ii,2})
            continue
        end


        if useCfg
            mdlRefResDir=cfgFileObj.getResults(true,sysResultInfo.mdlRefInfo{ii,1});
            if isempty(mdlRefResDir)
                mdlRefResDir=cfgFileObj.getResults(false,sysResultInfo.mdlRefInfo{ii,1});
            end
            if~isempty(mdlRefResDir)
                sysResultInfo.mdlRefInfo{ii,2}=mdlRefResDir{end,1};
            end
        end

        this.mrefDir{end+1}=sysResultInfo.mdlRefInfo{ii,2};
        mrefTreeItems=[mrefTreeItems,{[sysResultInfo.mdlRefInfo{ii,1},' (',sysResultInfo.mdlRefInfo{ii,2},')']}];%#ok<AGROW>
    end



    if~isempty(sysTreeItem)
        this.treeItems=sysTreeItem;
        this.treeItemsList=sysTreeItem;
        this.goodTreeItems=true;
    end
    if~isempty(mrefTreeItems)
        this.treeItems=[this.treeItems,{pslinkprivate('pslinkMessage','get','pslink:resDirSelectorRefModels'),mrefTreeItems}];
        this.treeItemsList=[this.treeItemsList,{pslinkprivate('pslinkMessage','get','pslink:resDirSelectorRefModels')},mrefTreeItems];
        this.goodTreeItems=[this.goodTreeItems,false,true(1,numel(mrefTreeItems))];
    end

    idx=find(this.goodTreeItems,1);
    if~isempty(idx)
        this.selectedItem=this.treeItemsList{idx};
    end


