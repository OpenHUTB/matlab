function MaskSection(fncname,cbinfo,action)



    fcn=str2func(fncname);
    fcn(cbinfo,action);
end

function schema=RemoveIconImage(cbinfo,action)%#ok<DEFNU>
    if isempty(action.callback)
        action.setCallbackFromArray(...
        @SLStudio.Utils.removeImageFromMaskCB,...
        dig.model.FunctionType.Action);
    end

    action.enabled=...
    ~SLStudio.Utils.isSimulationRunning(cbinfo)&&...
    SLStudio.Utils.isImageAlreadyAddedToMask(cbinfo)&&...
    strcmp(SLStudio.Utils.getAddEditIconImageMaskState(cbinfo),'Enabled');
end
