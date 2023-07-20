function topoPlotCallback(obj,~)






    userData=obj.CurrentObject.UserData;
    if isa(userData,'digraph')
        g=userData;
        coordinates=obj.CurrentObject.Parent.CurrentPoint;

        if numel(coordinates)==6

            d=(obj.CurrentObject.XData-coordinates(1,1)).^2+(obj.CurrentObject.YData-coordinates(1,2)).^2;
            [~,index]=min(d);
            if~isempty(g.Nodes.SID{index})
                open_system(Simulink.ID.getModel(g.Nodes.SID{index}));
                Simulink.ID.hilite(g.Nodes.SID{index});
            end
        end
    end
end
