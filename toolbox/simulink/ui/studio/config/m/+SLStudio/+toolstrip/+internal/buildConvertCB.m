



function buildConvertCB(obj,systemSelectorActionName,cbinfo)
    if isprop(obj,'Handle')

        set_param(obj.Handle,'TreatAsAtomicUnit','on');
    else

        [state,~]=SFStudio.Utils.getRootStateAndModel(cbinfo);

        if~state.isAtomicSubchart
            sfprivate('toggleIsAtomicSubchart',cbinfo.studio.App.getActiveEditor,state);
        end
    end

    ts=cbinfo.studio.getToolStrip();
    as=ts.getActionService();
    as.refreshAction(systemSelectorActionName);
end