function open(model,app)



    if nargin<2

        cp=simulinkcoder.internal.CodePerspective.getInstance;
        app=cp.getInfo(model);
    end

    if strcmp(app,'SimulinkCoder')
        simulinkcoder.internal.wizard.slcoderWizard(model,'Start');
    elseif strcmp(app,'EmbeddedCoder')
        coder.internal.wizard.slcoderWizard(model,'Start');
    end

