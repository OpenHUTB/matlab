function obj=loadobj(B)














    obj=ModelAdvisor.ConfigUI;
    fnames=fieldnames(B);
    for i=1:length(fnames)





        if~strcmp(fnames{i},'class')&&~strcmp(fnames{i},'Path')&&~strcmp(fnames{i},'SelectedGUI')
            obj.(fnames{i})=B.(fnames{i});
        end
    end
