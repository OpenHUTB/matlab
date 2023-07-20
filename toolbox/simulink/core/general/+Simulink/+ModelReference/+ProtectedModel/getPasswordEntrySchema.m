function[items,itemsHDL,rowCounter]=getPasswordEntrySchema(...
    simPassword,...
    rtwPassword,...
    hdlPassword,...
    viewPassword,...
    modifyPassword,...
    tag_prefix,...
    mode,...
    model)




    assert(strcmp(mode,'createFromGUI')||...
    strcmp(mode,'createFromCommandLine')||...
    strcmp(mode,'unlocking'));
    import Simulink.ModelReference.ProtectedModel.*;

    rowCounter=1;
    items={};
    itemsHDL={};

    showVerifyPassword=strcmp(mode,'createFromGUI')||strcmp(mode,'createFromCommandLine');
    enableAll=strcmp(mode,'createFromCommandLine');
    optional=~strcmp(mode,'unlocking');
    if modifyPassword

        editModifyPassword=locGetPasswordWidget(tag_prefix,'EditPassword',rowCounter,1,...
        DAStudio.message('Simulink:protectedModel:chkEncryptPasswordEdit'),false,strcmp(mode,'createFromGUI'));
        editModifyPassword=locSetEnableForUnlock('MODIFY',editModifyPassword,mode,model);
        items=[items,{editModifyPassword}];
        if showVerifyPassword

            editModifyPasswordVerify=locGetPasswordWidget(tag_prefix,'EditPasswordVerify',rowCounter,2,...
            '',true,strcmp(mode,'createFromGUI'));
            editModifyPasswordVerify=locSetEnableForUnlock('MODIFY',editModifyPasswordVerify,mode,model);
            items=[items,{editModifyPasswordVerify}];
        end
        rowCounter=rowCounter+1;

    end

    if viewPassword

        editViewPassword=locGetPasswordWidget(tag_prefix,'ViewPassword',rowCounter,1,...
        DAStudio.message('Simulink:protectedModel:chkEncryptPasswordView'),false,optional);
        editViewPassword=locSetEnableForUnlock('VIEW',editViewPassword,mode,model);

        items=[items,{editViewPassword}];
        if showVerifyPassword

            editViewPasswordVerify=locGetPasswordWidget(tag_prefix,'ViewPasswordVerify',rowCounter,2,...
            '',true,optional);
            editViewPasswordVerify=locSetEnableForUnlock('VIEW',editViewPasswordVerify,mode,model);
            items=[items,{editViewPasswordVerify}];
        end
        rowCounter=rowCounter+1;
    end

    if simPassword

        editSimPassword=locGetPasswordWidget(tag_prefix,'SimPassword',rowCounter,1,...
        DAStudio.message('Simulink:protectedModel:chkEncryptPasswordSim'),false,optional);
        editSimPassword=locSetEnableForUnlock('SIM',editSimPassword,mode,model);
        items=[items,{editSimPassword}];

        if showVerifyPassword

            editSimPasswordVerify=locGetPasswordWidget(tag_prefix,'SimPasswordVerify',rowCounter,2,...
            '',true,optional);
            editSimPasswordVerify=locSetEnableForUnlock('SIM',editSimPasswordVerify,mode,model);
            items=[items,{editSimPasswordVerify}];
        end
        rowCounter=rowCounter+1;
    end

    if rtwPassword

        editCodegenPassword=locGetPasswordWidget(tag_prefix,'CodegenPassword',rowCounter,1,...
        DAStudio.message('Simulink:protectedModel:chkEncryptPasswordCodeGeneration'),false,optional);
        editCodegenPassword=locSetEnableForUnlock('RTW',editCodegenPassword,mode,model);
        items=[items,{editCodegenPassword}];

        if showVerifyPassword

            editCodegenPasswordVerify=locGetPasswordWidget(tag_prefix,'CodegenPasswordVerify',rowCounter,2,...
            '',true,optional);
            editCodegenPasswordVerify=locSetEnableForUnlock('RTW',editCodegenPasswordVerify,mode,model);
            items=[items,{editCodegenPasswordVerify}];
        end


        if hdlPassword
            rowCounter=rowCounter+1;
        end
    end

    if hdlPassword

        editHDLCodegenPassword=locGetPasswordWidget(tag_prefix,'HDLCodegenPassword',rowCounter,1,...
        DAStudio.message('Simulink:protectedModel:chkEncryptPasswordHDLCodeGeneration'),false,optional);
        editHDLCodegenPassword=locSetEnableForUnlock('HDL',editHDLCodegenPassword,mode,model);
        itemsHDL=[itemsHDL,{editHDLCodegenPassword}];

        if showVerifyPassword

            editHDLCodegenPasswordVerify=locGetPasswordWidget(tag_prefix,'HDLCodegenPasswordVerify',rowCounter,2,...
            '',true,optional);
            editHDLCodegenPasswordVerify=locSetEnableForUnlock('HDL',editHDLCodegenPasswordVerify,mode,model);
            itemsHDL=[itemsHDL,{editHDLCodegenPasswordVerify}];
        end
    end

    if enableAll
        for i=1:length(items)
            items{i}.Enabled=true;%#ok<AGROW>
        end
        for i=1:length(itemsHDL)
            itemsHDL{i}.Enabled=true;%#ok<AGROW>
        end
    end
end

function editPassword=locSetEnableForUnlock(cat,editPassword,mode,model)
    import Simulink.ModelReference.ProtectedModel.*;
    if strcmp(mode,'unlocking')
        if PasswordManager.doesEncryptionCategoryHaveTheRightPassword(model,cat)
            editPassword.PlaceholderText=DAStudio.message('Simulink:protectedModel:EncryptPasswordEditBoxAuthorized');
            editPassword.Enabled=false;
        else
            editPassword.Enabled=true;
        end
    elseif strcmp(cat,'SIM')&&strcmp(mode,'createFromGUI')
        editPassword.Enabled=true;
    else
        editPassword.Enabled=false;
    end
end

function widget=locGetPasswordWidget(tag_prefix,tag,row,col,tooltip,verifying,optional)
    widget.Type='edit';
    widget.RowSpan=[row,row];
    widget.ColSpan=[col,col];
    widget.Mode=1;
    widget.Graphical=1;
    widget.EchoMode='password';
    widget.Tag=[tag_prefix,tag];




    if verifying
        widget.ToolTip=DAStudio.message('Simulink:protectedModel:EncryptPasswordVerifyEditBoxToolTipText');

        if optional
            widget.PlaceholderText=DAStudio.message('Simulink:protectedModel:EncryptPasswordEditBoxTextReEnter');
        else
            widget.PlaceholderText=DAStudio.message('Simulink:protectedModel:EncryptPasswordReEntryEditBoxText');
        end
    else
        widget.ToolTip=DAStudio.message('Simulink:protectedModel:EncryptPasswordEditBoxToolTipText',tooltip);

        if optional
            widget.PlaceholderText=DAStudio.message('Simulink:protectedModel:EncryptPasswordEditBoxText');
        else
            widget.PlaceholderText=DAStudio.message('Simulink:protectedModel:EncryptPasswordEntryEditBoxText');
        end
    end

end

