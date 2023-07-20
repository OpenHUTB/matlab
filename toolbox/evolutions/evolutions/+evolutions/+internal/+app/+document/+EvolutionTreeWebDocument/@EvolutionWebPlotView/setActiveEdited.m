function setActiveEdited(this)

    activeId=this.ActiveEi.Id;
    activeNode=this.EvolutionIdToNode(activeId);
    styler=this.Editor.getStyler();

    styler.remove({activeNode.uuid},'evolutionActive');
    styler.add({activeNode.uuid},'evolutionActiveEdited');
end