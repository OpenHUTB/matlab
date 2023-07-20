

function selectionRows=getSFChartActivityInSelection(selectionHandles)
    selectionRows={};
    for idx=1:numel(selectionHandles)

        handle=selectionHandles(idx);
        if isprop(handle,'SFBlockType')
            blockType=get(handle,'SFBlockType');
            if strcmp(blockType,'Chart')||...
                strcmp(blockType,'State Transition Table')


                chart=sfprivate('block2handle',handle);
                if strcmp(chart.Decomposition,'EXCLUSIVE_OR')
                    [hasChildren,hasLeaves]=locGetHasObjectChildrenAndLeaves(chart.Id);
                    if hasChildren
                        selectionRows{end+1}=locBindableRowForChart(chart,'child activity');%#ok<*AGROW>
                    end
                    if hasLeaves
                        selectionRows{end+1}=locBindableRowForChart(chart,'leaf activity');%#ok<*AGROW>
                    end
                end
            end
        end
    end
end

function bindableRow=locBindableRowForChart(chart,activity)
    type=BindMode.BindableTypeEnum.SFCHART;
    name=chart.Name;
    path=chart.Path;
    sid=Simulink.ID.getSID(chart);
    metadata=BindMode.SFChartMetaData(name,path,sid,activity);
    bindableRow=BindMode.BindableRow(false,type,name,metadata);
end

function[hasChildren,hasLeaves]=locGetHasObjectChildrenAndLeaves(id)
    hasChildren=false;
    hasLeaves=false;
    children=sf('SubstatesOf',id);
    if~isempty(children)
        hasChildren=true;
        leaves=ismember(sf('LeafstatesIn',id),children);
        leaves(leaves~=0)=[];
        if~isempty(leaves)
            hasLeaves=true;
        end
    end
end
