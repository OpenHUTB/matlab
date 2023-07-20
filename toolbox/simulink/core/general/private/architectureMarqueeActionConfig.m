function config=architectureMarqueeActionConfig()































    config=[
    struct('name','SL.MA.CreateSubsystem',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-subsystem-16.svg',...
    'checker',@MACanCreateRectangularObject,...
    'handler',@MACreateSubsystem,...
    'tooltip',DAStudio.message('Simulink:studio:MACreateSubsystem'),...
    'priority','normal'),...
...
    struct('name','SL.MA.AreaCreationToolCreateArea',...
    'icon','/toolbox/shared/dastudio/resources/create_area_cue_16.png',...
    'hoverIcon','/toolbox/shared/dastudio/resources/create_area_cue_16_hover.png',...
    'checker',@MACanCreateRectangularObject,...
    'handler',@MACreateArea,...
    'tooltip',DAStudio.message('Simulink:studio:SLAreaCreationToolCreateArea'),...
    'priority','normal'),...
...
    struct('name','SL.MA.RouteLines',...
    'icon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',...
    'hoverIcon','/toolbox/shared/dastudio/resources/glue/Selection/icon-reroute-lines-16.svg',...
    'checker',@MACanRouteLines,...
    'handler',@MARouteLines,...
    'tooltip',DAStudio.message('Simulink:studio:MARouteLines'),...
    'priority','normal'),...
...
    ];

end

function result=MACanRouteLines(editor,marqueeBounds)%#ok<INUSD>
    result=false;

    if~builtin('slf_feature','get','ChannelRoutingActions')
        return;
    end

    if editor.isLocked
        return;
    end

    selection=editor.getSelection;
    for i=1:selection.size
        if(isa(selection.at(i),'SLM3I.Segment'))
            result=true;
            break;
        end
    end
end

function MARouteLines(editor,marqueeBounds)
    if MACanRouteLines(editor,marqueeBounds)
        SLM3I.SLDomain.routeSegments(editor,editor.getSelection,true);
    end
end

function result=MACanCreateRectangularObject(editor,marqueeBounds)%#ok<INUSD>
    result=false;
    if~editor.isLocked
        selection=editor.getSelection;
        for i=1:selection.size
            currentItem=selection.at(i);
            if(isa(currentItem,'SLM3I.Block')||isa(currentItem,'SLM3I.Annotation'))...
                &&SLM3I.Util.isValidDiagramElement(currentItem)
                result=true;
                break;
            end
        end
    end
end

function MACreateSubsystem(editor,marqueeBounds)
    if MACanCreateRectangularObject(editor,marqueeBounds)

        SLM3I.SLDomain.createSubsystem(editor,editor.getSelection);
    end
end

function MACreateArea(editor,marqueeBounds)
    if MACanCreateRectangularObject(editor,marqueeBounds)
        SLM3I.SLDomain.createArea(editor,marqueeBounds);
    end
end