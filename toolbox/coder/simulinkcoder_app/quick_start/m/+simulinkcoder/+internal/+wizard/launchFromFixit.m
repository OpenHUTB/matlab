function launchFromFixit(system,first_question_id)
    model=bdroot(system);
    if strcmp(get_param(model,'IsERTTarget'),'on')
        coder.internal.wizard.slcoderWizard(system,first_question_id);
    else
        simulinkcoder.internal.wizard.slcoderWizard(system,'Start');
    end
end