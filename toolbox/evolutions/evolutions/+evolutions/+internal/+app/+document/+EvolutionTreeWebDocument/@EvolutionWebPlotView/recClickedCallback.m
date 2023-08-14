function recClickedCallback(this,~,change)





    selectedNode=[];
    styler=this.Editor.getStyler();
    nEntities=numel(change.selected);
    if(nEntities==1)
        entity=change.delta.selected;
        if entity.type=="diagram.Entity"||entity.type=="evolutions.ActiveEvolutionGlyph"
            this.changeSelectedAndNotify(entity);
            notify(this,'NodeClicked');
        end
        if entity.type=="diagram.Connection"||entity.type=="diagram.Port"
            this.changeSelectedEdge(entity);
            notify(this,'EdgeClicked');
        end
    else
        this.changeSelectedAndNotify(selectedNode);
        for entityIndex=1:nEntities
            entity=change.delta.selected(1);
            if entity.type=="diagram.Entity"
                this.changeSelectedAndNotify(entity);
                styler.remove({entity.uuid},'evolutionSelected');
                notify(this,'NodeClicked');
            end
        end
    end
end
