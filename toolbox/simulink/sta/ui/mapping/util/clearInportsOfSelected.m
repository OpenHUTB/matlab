function clearInportsOfSelected(modelName)



    if Simulink.iospecification.InportProperty.checkModelName(modelName)
        [inportH,~,~,~,~]=...
        Simulink.iospecification.InportProperty.getInportProperties(modelName);


        [enableH,~,~,~]=...
        Simulink.iospecification.InportProperty.getEnableProperties(modelName);


        [triggerH,~,~,~]=...
        Simulink.iospecification.InportProperty.getTriggerProperties(modelName);


        [shadowH,~,~,~,~]=...
        Simulink.iospecification.InportProperty.getInportShadowProperties(modelName);

        allRootPortH=[inportH',enableH,triggerH,shadowH'];


        for k=1:length(allRootPortH)
            set_param(allRootPortH{k},'Selected','off');
        end
    end