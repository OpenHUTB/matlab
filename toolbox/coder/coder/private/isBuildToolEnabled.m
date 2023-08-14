function resp=isBuildToolEnabled(configInfo)





    idelinkExists=((isfolder(fullfile(matlabroot,'toolbox','idelink')))&&...
    ~isempty(which('linkfoundation.xmakefile.XMakefilePreferences.getMATLABIntegrationEnable')));

    if idelinkExists
        if nargin==0
            resp=linkfoundation.xmakefile.XMakefilePreferences.getMATLABIntegrationEnable();
        else
            resp=(isprop(configInfo,'BuildToolEnable')&&(configInfo.BuildToolEnable));
        end
    else
        resp=false;
    end
