function slcoderWizard(system,first_question_id)



    model=bdroot(system);
    env=get_param(model,'CoderWizard');
    if nargin<2
        first_question_id='Start';
    end


    if~isa(env,'simulinkcoder.internal.wizard.Wizard')
        if~isempty(env)
            delete(env.Gui);
            set_param(model,'CoderWizard',[]);
        end
        env=simulinkcoder.internal.wizard.launchBackend(model,first_question_id);
    end


    env.Gui.start;


