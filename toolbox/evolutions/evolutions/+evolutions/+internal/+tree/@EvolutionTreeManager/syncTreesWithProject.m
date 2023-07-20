function syncTreesWithProject(obj)





    for idx=1:numel(obj.Infos)
        tree=obj.Infos(idx);


        try
            evolutions.internal.syncActiveWithProject(tree);
            evolutions.internal.session.EventHandler.publish('TreeChanged',...
            evolutions.internal.ui.GenericEventData(tree));
        catch ME

            evolutions.internal.session.EventHandler.publish('Warning',...
            evolutions.internal.ui.GenericEventData(struct('msgId',...
            ME.identifier,'msg',ME.message)));
        end
    end

end
