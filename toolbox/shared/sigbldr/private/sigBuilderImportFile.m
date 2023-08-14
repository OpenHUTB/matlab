function sigBuilderImportFile(dialog,varargin)



    persistent theImportDialog;

    action='open';
    if nargin==2
        action=varargin{1};
    end

    switch(action)
    case 'open'
        UD=get(dialog,'UserData');
        UD=cant_undo(UD);
        theImportDialog=sigbldr.controllers.SBFileImportDialogControllerWeb(UD);
        theImportDialog.show;
    case 'close'
        if~isempty(theImportDialog)&&isvalid(theImportDialog)
            theImportDialog.dispose;
        end
    end
