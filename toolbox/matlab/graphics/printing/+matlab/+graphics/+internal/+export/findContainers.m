function containers=findContainers(candidate)




    if isa(candidate,'matlab.ui.container.internal.UIContainer')||...
        ishghandle(candidate,'figure')
        containers={candidate};
        children=allchild(candidate);
        for i=1:length(children)
            if isa(children(i),'matlab.ui.container.internal.UIContainer')
                containers=[containers,matlab.graphics.internal.export.findContainers(children(i))];%#ok<AGROW>
            end
        end
    else
        containers=[];
    end
end
