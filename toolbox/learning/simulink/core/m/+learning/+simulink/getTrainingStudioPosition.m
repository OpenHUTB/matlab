function position=getTrainingStudioPosition(model_name)

    if bdIsLoaded(model_name)
        studios=DAS.Studio.getAllStudios();
        for i=1:length(studios)

            if isequal(bdroot(studios{i}.App.getActiveEditor.getName()),model_name)


                position=studios{i}.App.getActiveEditor.getStudio.getStudioPosition();
                position(3)=position(3)+position(1);
                position(4)=position(4)+position(2);
                break;
            end
        end
    else
        ss=get(groot,'ScreenSize');
        position=[1,1,.9*ss(3),ss(4)-100];
    end

end
