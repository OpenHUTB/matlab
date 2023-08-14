

function CustomWebBlockPropCB_ddg(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end


    lockAspectRatio=dlg.getWidgetValue('lockAspectRatio');

    if lockAspectRatio
        lockAspectRatio='on';
    else
        lockAspectRatio='off';
    end

    set_param(blockHandle,'fixedAspectRatio',lockAspectRatio);
end
