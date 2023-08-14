function open(fileName,varargin)







    import Simulink.ModelReference.ProtectedModel.*;
    try
        narginchk(1,4);

        type='';
        modelBlock='';
        blockingDialogSupported=true;
        fileName=Simulink.ModelReference.ProtectedModel.getCharArray(fileName);
        if nargin>1
            modelBlock=Simulink.ModelReference.ProtectedModel.getCharArray(varargin{1});
        end
        if nargin>2
            type=Simulink.ModelReference.ProtectedModel.getCharArray(varargin{2});
        end
        if nargin>3
            blockingDialogSupported=~varargin{3};
        end

        [opts,~]=getOptions(fileName,'runConsistencyChecksNoPlatform');

        if~isempty(opts)
            locCheckArgs(opts,modelBlock,type);
            locOpen(opts,fileName,type,blockingDialogSupported);
        else
            DAStudio.error('Simulink:protectedModel:unableToFindProtectedModelFile',fileName);
        end
    catch me
        throwAsCaller(me);
    end
end

function locCheckArgs(opts,modelBlock,type)

    if~opts.webview&&strcmpi(type,'webview')

        DAStudio.error('Simulink:protectedModel:CannotOpenProtectedModelWebviewFileMessage',opts.modelName);
    elseif~opts.report&&strcmpi(type,'report')

        DAStudio.error('Simulink:protectedModel:CannotOpenProtectedModelReportFileMessage',opts.modelName);
    elseif~opts.report&&~opts.webview

        if~isempty(modelBlock)
            DAStudio.error('Simulink:protectedModel:CannotOpenProtectedModelMessage',modelBlock,opts.modelName);
        else
            DAStudio.error('Simulink:protectedModel:CannotOpenProtectedModelFileMessage',opts.modelName);
        end
    end
end

function locOpen(opts,fileName,type,blockingDialogSupported)
    import Simulink.ModelReference.ProtectedModel.*;
    if~blockingDialogSupported
        disableGUIPassword('set');
        ocDisableGUIPWD=onCleanup(@()(disableGUIPassword('reset')));
    end

    if~isempty(type)
        switch lower(type)
        case 'report'
            displayReport(fileName);
        case 'webview'
            displayWebview(fileName);
        otherwise
            DAStudio.error('Simulink:protectedModel:ProtectedModelOpenUnrecognizedOption',type);
        end
    else


        if opts.webview
            displayWebview(fileName);
        elseif opts.report
            displayReport(fileName);
        end
    end

end

