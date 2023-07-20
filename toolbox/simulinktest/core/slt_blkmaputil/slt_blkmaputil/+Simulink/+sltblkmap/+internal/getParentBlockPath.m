function bpList=getParentBlockPath(selection)



    if isstruct(selection)
        bpList=getParentBlockPathInSFEditor(selection);
    else
        bpList=getParentBlockPathInSLEditor(selection);
    end

end

function bpList=getParentBlockPathInSLEditor(selection)

    if isnumeric(selection)
        selection=get_param(selection,'Object');
    end
    if iscell(selection)
        selection=cell2mat(selection);
    end

    bpList=[];
    proxyBlkH=[];
    if isa(selection,'Simulink.Block')
        proxyBlkH=selection.Handle;
    elseif isa(selection,'Simulink.Port')
        proxyBlkH=get_param(selection(1).Parent,'Handle');
    else

        for j=1:numel(selection)
            if selection(j).SrcPortHandle~=-1
                proxyBlkH=get_param(get_param(selection(j).SrcPortHandle,'Parent'),'Handle');
                break;
            end
        end
        if isempty(proxyBlkH)
            return;
        end
    end

    lastActiveEditor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(get_param(proxyBlkH,'Parent'),'handle'));
    if isempty(lastActiveEditor)

        bpList=proxyBlkH;
        return;
    end

    parentHid=lastActiveEditor.getHierarchyId;
    blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(parentHid,proxyBlkH);
    bpList=cellfun(@(x)get_param(x,'Handle'),blockPath.convertToCell);

end

function bpList=getParentBlockPathInSFEditor(selection)

    sfObj=idToHandle(sfroot,selection.SFObj);
    isDiagram=selection.IsDiagram;

    if isa(sfObj,'Stateflow.Chart')||isa(sfObj,'Stateflow.ReactiveTestingTableChart')...
        ||isa(sfObj,'Stateflow.StateTransitionTableChart')||isa(sfObj,'Stateflow.TruthTableChart')
        chart=sfObj;
    else
        chart=sfObj.Chart;
    end
    chartH=sfprivate('chart2block',chart.Id);

    if isa(sfObj,'Stateflow.Chart')||isa(sfObj,'Stateflow.ReactiveTestingTableChart')||...
        isa(sfObj,'Stateflow.StateTransitionTableChart')||isa(sfObj,'Stateflow.TruthTableChart')||(isa(sfObj,'Stateflow.State')&&isDiagram)
        ed=StateflowDI.SFDomain.getLastActiveEditorFor(sfObj.Id);
    else
        ed=StateflowDI.SFDomain.getLastActiveEditorFor(sfObj.Subviewer.Id);
    end

    hid=ed.getHierarchyId;
    blockPath=GLUE2.HierarchyService.getPaths(hid);
    bpList=[cellfun(@(x)get_param(x,'Handle'),blockPath(1:end-1));chartH];

end
