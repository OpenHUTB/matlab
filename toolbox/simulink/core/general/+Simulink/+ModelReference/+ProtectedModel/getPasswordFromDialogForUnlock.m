function shouldContinue=getPasswordFromDialogForUnlock(model,closeNag,varargin)



    import Simulink.ModelReference.ProtectedModel.*;

    narginchk(2,8);


    if nargin>=3
        relationship=varargin{1};
    else
        relationship='';
    end



    if nargin>=4
        priorAttemptSuccessful=varargin{2};
    else
        priorAttemptSuccessful=true;
    end



    if nargin>=5&&~isempty(varargin{3})
        assert(bdIsLoaded(varargin{3}),['Parent model of ',model,'is not loaded!']);
        topMdl=varargin{3};
    else
        topMdl='';
    end



    if nargin>=6
        assert(islogical(varargin{4}));
        nonblocking=varargin{4};
    else
        nonblocking=false;
    end

    if nargin>=7&&~isempty(varargin{5})
        hiddenFigure=varargin{5};
    else
        hiddenFigure=figure('visible','off');
        removeHiddenFigure=onCleanup(@()delete(hiddenFigure));
    end

    if nargin==8
        inAuthorizeLoop=varargin{6};
    else
        inAuthorizeLoop=false;
    end



    [opts,~]=getOptions(model);
    encryptionCategories={};
    if opts.isViewEncrypted
        encryptionCategories{end+1}='VIEW';
    end
    if opts.isSimEncrypted
        encryptionCategories{end+1}='SIM';
    end
    if opts.isRTWEncrypted
        encryptionCategories{end+1}='RTW';
    end
    if opts.isModifyEncrypted
        encryptionCategories{end+1}='MODIFY';
    end
    if opts.isHDLEncrypted
        encryptionCategories{end+1}='HDL';
    end

    pwDlg=PasswordEntryDialog(encryptionCategories,model,hiddenFigure,false);
    pwDlg.setInAuthorizeLoop(inAuthorizeLoop);
    if~priorAttemptSuccessful
        pwDlg.showWrongPasswordMessage();
    end
    if nonblocking
        pwDlg.makeNonBlocking()
    end
    if~isempty(relationship)
        category=getEncryptionCategoryForRelationship(model,relationship);
        pwDlg.setRequiredCategory(category);
    end
    dlg=DAStudio.Dialog(pwDlg);
    dlg.show;



    if~isempty(relationship)
        category=getEncryptionCategoryForRelationship(model,relationship);
        dlg.setFocus(['protectedMdlPW_editPassword',category]);
    end


    if~isempty(topMdl)
        pwDlg.installModelCloseListener(dlg,topMdl);
    end



    if slsvTestingHook('ProtectedModelNonBlocking')||nonblocking
        shouldContinue='Done';
    else
        waitfor(dlg,'dialogTag');
        shouldContinue=get(hiddenFigure,'Name');
    end



end


