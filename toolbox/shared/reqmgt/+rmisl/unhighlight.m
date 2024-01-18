function result=unhighlight(modelH)

    persistent relayForHarness
    if isempty(relayForHarness)
        relayForHarness=false;
    end
    if~relayForHarness&&rmisl.isComponentHarness(modelH)

        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelH);
        result=rmisl.unhighlight(bdroot(harnessInfo.ownerHandle));
        return;
    end
    SLStudio.Utils.RemoveHighlighting(modelH);

    action_highlight('purge');

    rmidispblock('updateall',modelH);
    rmiut.closeDlg(getString(message('Slvnv:reqmgt:highlightObjectsWithReqs')))

    if exist('rmi.Informer','class')==8&&rmi.Informer.isVisible()
        rmi.Informer.close();
    end

    result=true;

    if~relayForHarness
        activeHarnessInfo=Simulink.harness.internal.getActiveHarness(modelH);
        if~isempty(activeHarnessInfo)
            harnessH=get_param(activeHarnessInfo.name,'Handle');
            relayForHarness=true;%#ok<NASGU>
            rmisl.unhighlight(harnessH);
            relayForHarness=false;
        end
    end
end

