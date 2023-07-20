function resultJSON=getRecentConfigurations(varargin)
    PrefFile=fullfile(prefdir,'mdladvprefs.mat');
    if exist(PrefFile,'file')
        mdladvprefs=load(PrefFile);
        if~isfield(mdladvprefs,'RecentConfigurations')
            mdladvprefs.RecentConfigurations={};
        end
    else
        mdladvprefs.RecentConfigurations={};
    end
    RecentConfigurations=mdladvprefs.RecentConfigurations;
    if nargin>0
        if numel(RecentConfigurations)>2
            RecentConfigurations{1}=RecentConfigurations{2};
            RecentConfigurations{2}=RecentConfigurations{3};
            RecentConfigurations{3}=varargin{1};
        else
            RecentConfigurations{end+1}=varargin{1};
        end
        save(PrefFile,'RecentConfigurations','-append');
    end





    filepath='';
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath',filepath,'value',jsonencode(RecentConfigurations));
    resultJSON=jsonencode(result);
end

function resultJSON=setRecentConfigurations(appID,maType)
    am=Advisor.Manager.getInstance;
    appObj=am.getApplication('ID',appID);
    maObj=appObj.getRootMAObj;
    json=Advisor.Utils.exportJSON(maObj,maType);
    filepath=maObj.ConfigFilePath;
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath',filepath,'value',json);
    resultJSON=jsonencode(result);
end