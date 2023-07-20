function highlightObservedSFState(sfId)

    if ishandle(sfId)
        sfId=sfprivate('block2chart',sfId);
    end
    sfHdl=idToHandle(sfroot,sfId);
    if isa(sfHdl,'Stateflow.Chart')||isa(sfHdl,'Stateflow.ReactiveTestingTableChart')||isa(sfHdl,'Stateflow.StateTransitionTableChart')




        stateId=sfprivate('get_state_for_atomic_subchart',sfId);
        if stateId~=0

            ascHdl=idToHandle(sfroot,stateId);
            sv=ascHdl.Subviewer;
            sv.view;
            sf('Highlight',ascHdl.Chart.Id,ascHdl.Id);
            return;
        end
        blkH=sfprivate('chart2block',sfId);
        SLStudio.HighlightSignal.removeHighlighting(bdroot(blkH));
        SLStudio.EmphasisStyleSheet.applyStyler(bdroot(blkH),blkH);
        sys=get_param(blkH,'Parent');
        if~strcmp(get_param(sys,'Open'),'on')
            open_system(sys,'force','Window');
        else
            open_system(sys);
        end
    else
        sv=sfHdl.Subviewer;
        sv.view;
        sf('Highlight',sfHdl.Chart.Id,sfHdl.Id);
    end

end

