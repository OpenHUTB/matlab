function addNodeStyle(this)




    styler=this.Editor.getStyler();


    entities=this.Syntax.root.entities;
    nEntities=numel(this.Syntax.root.entities);

    for entityIndex=1:nEntities
        styler.add({entities(entityIndex).uuid},'evolutionNode');
        if~strcmp(entities(entityIndex).type,'evolutions.ActiveEvolutionGlyph')
            styler.add({entities(entityIndex).uuid},'evolutionTreeNode');
        else
            styler.remove({entities(entityIndex).uuid},'diagram-entity');
        end

    end



    activeId=this.ActiveEi.Id;
    activeNode=this.EvolutionIdToNode(activeId);











    styler.add({activeNode.uuid},'evolutionActive');
end


