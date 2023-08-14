function settings=getButtonSettingsForDialog(blockHandle,config)
    settings=[];
    if isfield(config,'components')&&~isempty(config.components)
        components=config.components;
        for index=1:length(components)
            component=components(index);
            if isfield(component,'name')&&strcmp(component.name,'ButtonStateComponent')
                if isfield(component,'settings')
                    settings=component.settings;



                    multipleValues=false;
                    if isfield(component.settings,'states')&&numel(component.settings.states)>0
                        numStates=2;
                        if strcmp(component.settings.buttonType,'latch')
                            numStates=4;
                        end
                        buttonText=component.settings.states(1).label.text.content;
                        for stateIndex=2:numStates
                            if~strcmp(buttonText,component.settings.states(stateIndex).label.text.content)
                                multipleValues=true;
                                break;
                            end
                        end
                    else
                        buttonText='';
                    end
                    settings.buttonText=buttonText;
                    settings.buttonTextHasMultipleValues=multipleValues;
                end
                break;
            end
        end
    end
    if isempty(settings)


        settings.buttonType='Momentary';
        settings.buttonText='Button';
        settings.buttonTextHasMultipleValues=false;
        settings.onValue=1;
        settings.clickFcn='';
        settings.pressFcn='';
        settings.pressDelay=500;
        settings.repeatInterval=1;
    end
end
