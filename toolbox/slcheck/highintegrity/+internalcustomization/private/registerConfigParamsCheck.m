function registerConfigParamsCheck(GuidelineID,varargin)
    if nargin==1
        licenses={HighIntegrity_License};
    else
        licenses={HighIntegrity_License,varargin{1}{:}};
    end
    rec=getNewCheckObject(['mathworks.hism.',GuidelineID],true,[],'None');

    rec.setLicense(licenses);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end
