function qnxSetupFcn()






    fullpathToUtility=slrealtime.internal.getSupportPackageRoot;
    if~isempty(fullpathToUtility)

        setenv('SLREALTIME_QNX_SP_ROOT',fullpathToUtility);




        setenv('SLREALTIME_QNX_VERSION','qnx710');


        destLicFile=fullfile(getenv('USERPROFILE'),'.qnx','license','licenses');
        srcLicFile=fullfile(fullpathToUtility,getenv('SLREALTIME_QNX_VERSION'),'license','licenses');
        slrealtime.internal.setupQNXLicense(destLicFile,srcLicFile,true);

    end

    qnxLoc=getenv('SLREALTIME_QNX_SP_ROOT');
    if strcmpi(computer('arch'),'glnxa64')


        setenv('SLREALTIME_CODER_TOOLS',fullfile(matlabroot,'toolbox/slrealtime/simulink/coder/tools'));
    end

    if isempty(qnxLoc)

        diag=MSLException([],message('slrealtime:supportpackage:supportPackageRequiredMsgInFun'));
        throw(diag);
    end

end
