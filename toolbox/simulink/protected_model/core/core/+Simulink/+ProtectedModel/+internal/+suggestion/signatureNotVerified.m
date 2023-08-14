function out=signatureNotVerified(model)





    ok=getString(message('Simulink:protectedModel:SignatureNotVerifiedSuggestionOK'));
    cancel=getString(message('Simulink:protectedModel:SignatureNotVerifiedSuggestionCancel'));
    dp=DAStudio.DialogProvider;
    d=questdlg(dp,...
    getString(message('Simulink:protectedModel:SignatureNotVerifiedSuggestionMessage',model)),...
    getString(message('Simulink:protectedModel:SignatureNotVerifiedSuggestionTitle')),...
    {ok,cancel},cancel,...
    []);

    d.show;
    waitfor(d,'dialogTag','');
    choice=dp.pDialogData.QuestDlgValue;

    if strcmp(choice,ok)

        Simulink.ProtectedModel.suppressSignatureVerification(model);
        out=getString(message('Simulink:protectedModel:SignatureNotVerifiedSuggestionSuccess',model));
    else

        throw(MSLException([],message('Simulink:protectedModel:SignatureNotVerifiedSuggestionCanceled')));
    end
