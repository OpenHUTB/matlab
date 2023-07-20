function config=autosarMarqueeActionConfig()































    config=[
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


