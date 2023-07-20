function open(topMdl,varargin)


    topMdl=convertStringsToChars(topMdl);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if nargin==1
        targetType={'SIM','RTW'};
    else
        targetType=varargin(1);
    end

    bDir=RTW.getBuildDir(topMdl);
    buildStatusDB=[];
    for k=1:length(targetType)
        switch upper(targetType{k})
        case 'SIM'
            tmpMatFile=fullfile(bDir.CodeGenFolder,bDir.ModelRefRelativeRootSimDir,...
            ['buildStatusDB_',topMdl,'.mat']);
        case 'RTW'
            tmpMatFile=fullfile(bDir.CodeGenFolder,bDir.ModelRefRelativeRootTgtDir,...
            ['buildStatusDB_',topMdl,'.mat']);
        otherwise
            DAStudio.error('RTW:buildStatus:invalidTargetType',upper(targetType{k}));
        end
        if exist(tmpMatFile,'file')
            data=load(tmpMatFile);
            buildStatusDB=[buildStatusDB,data.buildStatusDB];%#ok<AGROW>
        end
    end

    if isempty(buildStatusDB)

        buildStatusDB=coder.internal.buildstatus.BuildStatusDB(topMdl,{},0,'NONE',[]);
    end


    buildStatusMgr=coder.internal.buildstatus.BuildStatusUIMgr(topMdl,...
    buildStatusDB(1));
    buildStatusMgr.openBuildStatusDialog;


    for k=1:length(buildStatusDB)
        buildStatusMgr.setBuildStatusDB(buildStatusDB(k));
        buildStatusMgr.openBuildStatusTab('load');
    end

end