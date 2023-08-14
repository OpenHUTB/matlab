function fadingInactiveCB(cbinfo,~)




    modelHandle=cbinfo.model.handle;
    if(strcmp(get_param(modelHandle,'VariantFading'),'on'))
        set_param(modelHandle,'VariantFading','off');
    else
        set_param(modelHandle,'VariantFading','on');
        set_param(modelHandle,'SimulationCommand','update');
    end
end
