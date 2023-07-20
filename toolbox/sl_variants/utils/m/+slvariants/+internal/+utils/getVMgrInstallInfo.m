function[isInstalled,err,isMATLABOnline]=getVMgrInstallInfo(varargin)








    narginchk(1,1);
    nargoutchk(0,3);
    isInstalled=false;
    err='';

    import matlab.internal.lang.capability.Capability;
    isMATLABOnline=~Capability.isSupported(Capability.LocalClient);

    featureName=varargin{1};

    if strcmp(featureName,'Simulink.VariantManager.findVariantControlVars')

        isInstalled=license('test','Simulink_Design_Verifier');
        if isInstalled
            return;
        end
    end

    if isMATLABOnline



        err=MException(message('Simulink:VariantManager:MATLABOnlineNotSupported',featureName));
        return;
    end

    fileName=which('slvmgr.ver');
    isInstalled=~isempty(fileName)&&exist(fileName,'file')~=0;
    if~isInstalled
        err=MException(message('Simulink:VariantManager:NeedVariantManagerSPKG',featureName));
    end

end




