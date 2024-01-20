function report(varargin)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end
    Simulink.sdi.Instance.offscreenBrowser();

    setupData=locGetSetupData();
    setupData.appName='sdi';
    message.publish('/sdi2/progressUpdate',setupData);
    tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',...
    struct('dataIO','end','appName',setupData.appName,'spinnerStatus','stopSpinner')));

    Simulink.sdi.Instance.engine.report(varargin{:});
end


function setupData=locGetSetupData()
    setupData=struct;
    setupData.dataIO='begin';
    setupData.isModal=true;
    setupData.spinnerStatus='startSpinner';
end
