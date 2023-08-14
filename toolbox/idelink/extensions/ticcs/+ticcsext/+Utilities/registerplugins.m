function varargout=registerplugins(register)





    linkfoundation.autointerface.baselink.checkPlatformSupport(mfilename,...
    ticcsext.Utilities.getPlatformsSupported(),'ticcs');

    if nargin==0
        register=true;
    end

    ocxfname=ticcsext.Utilities.LfCProperty('inprocFile-current-client');
    dllfname=ticcsext.Utilities.LfCProperty('inprocFile-current-server');
    pname='cc_app.exe';
    fname='CCS';
    keyname='Matlab.Application';

    [isok,msg]=linkfoundation.util.registerplugins(register,dllfname,ocxfname,pname,fname,keyname);
    if nargout>0
        varargout{1}=isok;
        varargout{2}=msg;
    else
        disp(msg);
    end


