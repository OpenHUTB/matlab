function slcoderWizard(system,first_question_id)



    model=bdroot(system);
    env=get_param(model,'CoderWizard');
    if nargin<2
        first_question_id='System';
    end
    if isempty(env)
        env=coder.internal.wizard.launchBackend(system,first_question_id);
    else

        if~isa(env,'coder.internal.wizard.Wizard')
            delete(env.Gui);
            set_param(model,'CoderWizard',[]);
            env=simulinkcoder.internal.wizard.launchBackend(system,first_question_id);
        end
    end

    if(ischar(system)&&~strcmp(system,model))||(~ischar(system)&&system~=model)



        if isempty(env.SourceSubsystem)||...
            get_param(env.SourceSubsystem,'handle')~=get_param(system,'handle')


            [exc,isCompatible]=coder.internal.wizard.Wizard.subsysIsQuickStartCompatible(model,system);
            if~isCompatible&&~isempty(exc)
                errordlg(exc.message,message('RTW:wizard:SubsystemErrorDialogTitle').getString());
                delete(env.Gui);
                set_param(model,'CoderWizard',[]);
                return;
            end
            env.Gui.start;
            env.selectSubsystem(system);
            if~isempty(env.CurrentQuestion)&&~strcmp(env.CurrentQuestion.Id,first_question_id)

                env.Gui.switchTopic(1);
            end
        else
            env.Gui.show;
        end
    else

        env.Gui.start;
    end
end