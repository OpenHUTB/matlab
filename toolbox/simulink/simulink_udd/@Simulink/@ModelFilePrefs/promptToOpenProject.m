function previous=promptToOpenProject(enabled)




    s=settings;
    if~s.hasGroup('Simulink')
        s.addGroup('Simulink');
    end

    sg=s.Simulink;
    if~sg.hasSetting('PromptToOpenProjectContainingModel')
        sg.addSetting(...
        'PromptToOpenProjectContainingModel',...
        'PersonalValue',true);
    end

    previous=sg.PromptToOpenProjectContainingModel.ActiveValue;
    if nargin>0
        sg.PromptToOpenProjectContainingModel.PersonalValue=enabled;
    end

end

