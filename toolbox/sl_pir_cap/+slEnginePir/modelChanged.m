function loadedModels=modelChanged(mdls)







    loadedModels={};
    for ii=1:length(mdls)
        mdlname=mdls{ii};

        if~bdIsLoaded(mdlname)
            if exist(mdlname,'file')>0
                load_system(mdlname);
                [~,modelNameWithoutExtension,~]=fileparts(mdlname);
                loadedModels=[loadedModels;modelNameWithoutExtension];
            else
                continue;
            end
        end



        if strcmp(get_param(mdlname,'Dirty'),'on')
            DAStudio.error('sl_pir_cpp:creator:DirtyModel',mdlname);
        end





    end

end


