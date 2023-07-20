




classdef PasswordEntryDialog<handle
    properties
        fCategories={};
        fModel='';
        fPasswordSim='';
        fPasswordRTW='';
        fPasswordView='';
        fPasswordModify='';
        fPasswordHDL='';

        fPasswordSimVerify='';
        fPasswordRTWVerify='';
        fPasswordViewVerify='';
        fPasswordModifyVerify='';
        fPasswordHDLVerify='';

        fDoProtect=false;
        fShowWrongPasswordMessage=false;

        fCategoryToMentionInDescription;
        fNonBlocking;
        fHiddenFigure;
        fGuiEntry=true;
        fRequiredCategory;






        fInAuthorizeLoop;

        hModelCloseListener;
    end

    methods
        function obj=PasswordEntryDialog(categories,modelname,hiddenFigure,protecting)
            for i=1:length(categories)
                category=categories{i};
                assert(strcmp(category,'SIM')||...
                strcmp(category,'RTW')||...
                strcmp(category,'VIEW')||...
                strcmp(category,'MODIFY')||...
                strcmp(category,'HDL'));
            end
            assert(ishghandle(hiddenFigure),'Expecting figure handle');

            obj.fCategories=categories;
            obj.fModel=modelname;
            obj.fDoProtect=protecting;
            obj.fNonBlocking=false;
            obj.fHiddenFigure=hiddenFigure;
            obj.fCategoryToMentionInDescription='';
            obj.fInAuthorizeLoop=false;
        end

        function setInAuthorizeLoop(obj,val)
            obj.fInAuthorizeLoop=val;
        end

        function makeNonBlocking(obj)
            obj.fNonBlocking=true;
        end

        function out=isBlocking(obj)
            out=slsvTestingHook('ProtectedModelNonBlocking')==0&&~obj.fNonBlocking;
        end

        function describeCategoryInDescriptionLabel(obj,category)
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL'));

            obj.fCategoryToMentionInDescription=category;
        end

        function showWrongPasswordMessage(obj)
            obj.fShowWrongPasswordMessage=true;
        end

        function out=getShowWrongPasswordMessage(obj)
            out=obj.fShowWrongPasswordMessage;
        end

        function out=doesEncryptionCategoryHaveTheRightPassword(obj,category)
            out=Simulink.ModelReference.ProtectedModel.PasswordManager.doesEncryptionCategoryHaveTheRightPassword(obj.fModel,category);
        end

        function checkPasswordsAgainstVerifyPasswords(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            import Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.*;
            erroringCategories='';
            categories=getCategories();
            for i=1:length(categories)
                category=categories{i};
                if~isempty(any(strcmp(category,obj.fCategories)))
                    if~strcmp(obj.(getPropName(category)),obj.(getPropVerifyName(category)))&&~isempty(obj.(getPropName(category)))
                        erroringCategories=sprintf([erroringCategories,'\n',getStringForEncryptionCategory(category)]);
                    end
                end
            end

            if~isempty(erroringCategories)
                DAStudio.error('Simulink:protectedModel:EncryptPasswordMismatchError',...
                erroringCategories);
            end
        end

        function checkPasswords(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            import Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.*;
            categories=getCategories();


            if obj.currentlyProtecting()
                obj.checkPasswordsAgainstVerifyPasswords();
            end




            if obj.currentlyUnlocking()
                erroringCategories='';
                for i=1:length(categories)
                    if obj.supportsCategory(categories{i})
                        if~obj.doesEncryptionCategoryHaveTheRightPassword(categories{i})
                            erroringCategories=sprintf([erroringCategories,'\n',getStringForEncryptionCategory(categories{i})]);
                        end
                    end
                end
                if~isempty(erroringCategories)
                    throwWrongPasswordExceptionWithHyperlink(obj.fModel,erroringCategories);
                end
            end

        end

        function out=supportsCategory(obj,category)
            import Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.*;
            out=~isempty(any(strcmp(category,obj.fCategories)))&&...
            (~isempty(obj.(getPropName(category)))||strcmp(category,obj.fRequiredCategory));
        end

        function out=currentlyUnlocking(obj)

            out=~obj.fDoProtect;
        end

        function out=currentlyProtecting(obj)
            out=obj.fDoProtect;
        end


        function installModelCloseListener(obj,dlg,parentMdl)


            blkDiagram=get_param(parentMdl,'Object');
            obj.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',...
            @(src,ev,dlg)Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.removeDlg(dlg));

        end


        function schema=getDialogSchema(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            tag_prefix='protectedMdlPW_';

            lblMessage.Type='text';
            lblMessage.RowSpan=[1,1];
            lblMessage.ColSpan=[1,1];
            lblMessage.Tag=[tag_prefix,'Message'];


            if obj.fShowWrongPasswordMessage&&~obj.currentlyProtecting()
                lblMessage.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelWrongPasswordTryAgain');
                lblMessage.ForegroundColor=[255,0,0];
            elseif~obj.fShowWrongPasswordMessage&&~obj.currentlyProtecting()
                if isempty(obj.fCategoryToMentionInDescription)
                    lblMessage.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelPasswordEntryDialogDesc',obj.fModel);
                else
                    lblMessage.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelPasswordEntryDialogDescWithCategory',obj.fCategoryToMentionInDescription,obj.fModel);
                end
            else
                lblMessage.Name=DAStudio.message('Simulink:protectedModel:ProtectedModelPasswordEntryDialogDescProtecting',obj.fModel);
            end

            grpMessage.Type='group';
            grpMessage.LayoutGrid=[1,1];
            grpMessage.Items={lblMessage};


            enableSim=false;
            enableModify=false;
            enableView=false;
            enableCG=false;
            enableHDL=false;

            items={};
            for i=1:length(obj.fCategories)
                category=obj.fCategories{i};



                if strcmp(category,'MODIFY')
                    prompt=getStringForEncryptionCategory('MODIFY');
                    enableModify=true;
                elseif strcmp(category,'VIEW')
                    prompt=getStringForEncryptionCategory('VIEW');
                    enableView=true;
                elseif strcmp(category,'SIM')
                    prompt=getStringForEncryptionCategory('SIM');
                    enableSim=true;
                elseif strcmp(category,'RTW')
                    prompt=getStringForEncryptionCategory('RTW');
                    enableCG=true;
                elseif strcmp(category,'HDL')
                    prompt=getStringForEncryptionCategory('HDL');
                    enableHDL=true;
                else
                    DAStudio.error('Simulink:protectedModel:ProtectedModelInvalidEncryptionCategory',category);
                end

                lblPasswordEntry.Type='text';
                lblPasswordEntry.RowSpan=[i,i];
                lblPasswordEntry.ColSpan=[1,1];
                lblPasswordEntry.Name=prompt;
                lblPasswordEntry.Tag=[tag_prefix,'PasswordLabel',sprintf('%d',i)];
                items=[items,{lblPasswordEntry}];%#ok<AGROW>
            end
            if obj.currentlyProtecting()
                mode='createFromCommandLine';
            else
                mode='unlocking';
            end


            [passwordItems,passwordHDLItems,numRows]=getPasswordEntrySchema(enableSim,...
            enableCG,...
            enableHDL,...
            enableView,...
            enableModify,...
            tag_prefix,...
            mode,...
            obj.fModel);
            passwordItems=[passwordItems,passwordHDLItems];
            grpPasswords.Type='panel';
            grpPasswords.Visible=true;
            grpPasswords.Tag=[tag_prefix,'Passwords'];
            grpPasswords.Items=passwordItems;
            grpPasswords.LayoutGrid=[numRows,2];
            grpPasswords.RowSpan=[1,numRows];
            grpPasswords.ColSpan=[2,3];


            grpPasswordEntry.Type='panel';
            grpPasswordEntry.LayoutGrid=[1,1];
            grpPasswordEntry.Items=[items,grpPasswords];

            schema.DialogTitle=DAStudio.message('Simulink:protectedModel:ProtectedModelPasswordEntryDlgTitle',obj.fModel);
            schema.DialogTag=[tag_prefix,'dialog'];

            schema.StandaloneButtonSet={'OK','Cancel'};
            schema.IsScrollable=true;
            schema.Sticky=true;
            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.closeCB';
            schema.Items={grpMessage,grpPasswordEntry};

        end





        function dataType=getPropDataType(~,propName)
            stringTypeProps={'fPasswordSim','fPasswordRTW','fPasswordView','fPasswordModify','fPasswordHDL',...
            'fPasswordSimVerify','fPasswordRTWVerify','fPasswordViewVerify','fPasswordModifyVerify','fPasswordHDLVerify'};
            if any(strcmp(propName,stringTypeProps))
                dataType='string';
            else
                dataType='invalid';
            end
        end

        function out=wrongLength(~,me)
            out=strcmp(me.identifier,'Simulink:protectedModel:EncryptPasswordTooShort')||...
            strcmp(me.identifier,'Simulink:protectedModel:EncryptPasswordTooLong');
        end

        function out=wrongPassword(~,me)
            out=strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelUnlockWrongPassword');
        end

        function out=verifyFail(~,me)
            out=strcmp(me.identifier,'Simulink:protectedModel:EncryptPasswordMismatchError');
        end

        function out=noModifyPassword(~,me)
            out=strcmp(me.identifier,'Simulink:protectedModel:ModifySupportRequiresPassword');
        end

        function fetchAndSetPasswords(obj,dlg,cat)
            import Simulink.ModelReference.ProtectedModel.*;
            if strcmp(cat,'SIM')
                obj.fPasswordSim=dlg.getWidgetValue('protectedMdlPW_SimPassword');
                if~isempty(obj.fPasswordSim)
                    obj.fPasswordSimVerify=dlg.getWidgetValue('protectedMdlPW_SimPasswordVerify');
                    setPasswordForSimulation(obj.fModel,obj.fPasswordSim);
                end
            elseif strcmp(cat,'RTW')
                obj.fPasswordRTW=dlg.getWidgetValue('protectedMdlPW_CodegenPassword');
                if~isempty(obj.fPasswordRTW)
                    obj.fPasswordRTWVerify=dlg.getWidgetValue('protectedMdlPW_CodegenPasswordVerify');
                    setPasswordForCodeGeneration(obj.fModel,obj.fPasswordRTW);
                end
            elseif strcmp(cat,'VIEW')
                obj.fPasswordView=dlg.getWidgetValue('protectedMdlPW_ViewPassword');
                if~isempty(obj.fPasswordView)
                    obj.fPasswordViewVerify=dlg.getWidgetValue('protectedMdlPW_ViewPasswordVerify');
                    setPasswordForView(obj.fModel,obj.fPasswordView);
                end
            elseif strcmp(cat,'MODIFY')
                obj.fPasswordModify=dlg.getWidgetValue('protectedMdlPW_EditPassword');
                if~isempty(obj.fPasswordModify)
                    obj.fPasswordModifyVerify=dlg.getWidgetValue('protectedMdlPW_EditPasswordVerify');
                    setPasswordForModify(obj.fModel,obj.fPasswordModify);
                else
                    DAStudio.error('Simulink:protectedModel:ModifySupportRequiresPassword');
                end
            elseif strcmp(cat,'HDL')
                obj.fPasswordHDL=dlg.getWidgetValue('protectedMdlPW_HDLCodegenPassword');
                if~isempty(obj.fPasswordHDL)
                    obj.fPasswordHDLVerify=dlg.getWidgetValue('protectedMdlPW_HDLCodegenPasswordVerify');
                    setPasswordForHDLCodeGeneration(obj.fModel,obj.fPasswordHDL);
                end
            else
                DAStudio.error('Simulink:protectedModel:ProtectedModelInvalidEncryptionCategory',cat);
            end
        end
        function setRequiredCategory(obj,category)
            assert(strcmp(category,'SIM')||...
            strcmp(category,'RTW')||...
            strcmp(category,'VIEW')||...
            strcmp(category,'MODIFY')||...
            strcmp(category,'HDL'));

            obj.fRequiredCategory=category;
        end

    end

    methods(Static)


        function closeCB(dlg,closeaction)
            import Simulink.ModelReference.ProtectedModel.*;
            if strcmp(closeaction,'ok')
                dlgsrc=dlg.getDialogSource;
                try
                    for i=1:length(dlgsrc.fCategories)
                        cat=dlgsrc.fCategories{i};
                        dlgsrc.fetchAndSetPasswords(dlg,cat);
                    end






                    dlgsrc.checkPasswords();

                catch me
                    if dlgsrc.currentlyUnlocking()


                        if~dlgsrc.doesEncryptionCategoryHaveTheRightPassword('SIM')
                            PasswordManager.clearEncryptionCategoryForModel(dlgsrc.fModel,'SIM');
                        end

                        if~dlgsrc.doesEncryptionCategoryHaveTheRightPassword('RTW')
                            PasswordManager.clearEncryptionCategoryForModel(dlgsrc.fModel,'RTW');
                        end

                        if~dlgsrc.doesEncryptionCategoryHaveTheRightPassword('VIEW')
                            PasswordManager.clearEncryptionCategoryForModel(dlgsrc.fModel,'VIEW');
                        end

                        if~dlgsrc.doesEncryptionCategoryHaveTheRightPassword('MODIFY')
                            PasswordManager.clearEncryptionCategoryForModel(dlgsrc.fModel,'MODIFY');
                        end

                        if~dlgsrc.doesEncryptionCategoryHaveTheRightPassword('HDL')
                            PasswordManager.clearEncryptionCategoryForModel(dlgsrc.fModel,'HDL');
                        end
                    else
                        clearPasswordsForModel(dlgsrc.fModel);
                    end

                    if dlgsrc.isBlocking()
                        set(dlgsrc.fHiddenFigure,'UserData',me);
                        if dlgsrc.wrongPassword(me)||dlgsrc.wrongLength(me)
                            set(dlgsrc.fHiddenFigure,'Name','WrongPassword');
                        elseif dlgsrc.verifyFail(me)
                            set(dlgsrc.fHiddenFigure,'Name','VerifyFail');
                        elseif dlgsrc.noModifyPassword(me)
                            set(dlgsrc.fHiddenFigure,'Name','NoModifyPassword');
                        else
                            set(dlgsrc.fHiddenFigure,'Name','Error!');
                        end
                    end



                    if dlgsrc.fGuiEntry&&~dlgsrc.fInAuthorizeLoop
                        coder.internal.createAndPushNag(me);
                    end

                    return;
                end

                if dlgsrc.isBlocking()
                    set(dlgsrc.fHiddenFigure,'Name','Done');
                end
            else

                dlgsrc=dlg.getDialogSource;
                if dlgsrc.isBlocking()
                    set(dlgsrc.fHiddenFigure,'Name','NotDone');
                end
            end
        end




        function removeDlg(dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end
    end
    methods(Access=private,Static)
        function out=getCategories()
            out={'MODIFY','SIM','RTW','VIEW','HDL'};
        end

        function out=getPropName(category)
            import Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.*;
            out='';
            passwordFields={'fPasswordModify','fPasswordSim','fPasswordRTW','fPasswordView','fPasswordHDL'};
            categories=getCategories();
            for i=1:length(categories)
                if strcmp(category,categories{i})
                    out=passwordFields{i};
                end
            end
        end

        function out=getPropVerifyName(category)
            import Simulink.ModelReference.ProtectedModel.PasswordEntryDialog.*;
            out='';
            passwordFields={'fPasswordModifyVerify','fPasswordSimVerify','fPasswordRTWVerify','fPasswordViewVerify','fPasswordHDLVerify'};
            categories=getCategories();
            for i=1:length(categories)
                if strcmp(category,categories{i})
                    out=passwordFields{i};
                end
            end
        end
    end
end

