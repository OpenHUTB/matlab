function[status,dscr]=ImplementImageWithCVMatDepend(~,~)

    supportPackageInstalled=matlabshared.supportpkg.getInstalled;
    opencvIsInstalled=~isempty(supportPackageInstalled)&&...
    any(ismember({supportPackageInstalled.Name},'Computer Vision Toolbox Interface for OpenCV in Simulink'));
    inSandbox=exist(fullfile(matlabroot,'test','toolbox','simulink','configsets'),'dir')~=0;
    if opencvIsInstalled||inSandbox
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.UnAvailable;
    end
    dscr='';

end
