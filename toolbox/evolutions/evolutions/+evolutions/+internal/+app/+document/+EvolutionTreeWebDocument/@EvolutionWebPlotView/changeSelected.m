function changeSelected(this,node)




    styler=this.Editor.getStyler();

    if~isempty(this.SelectedNode)

        styler.remove({this.SelectedNode.uuid},'evolutionSelected');
        styler.remove({this.SelectedNode.uuid},'evolutionFocus');
    end

    if~isempty(node)
        if~isa(node,'diagram.interface.Element')

            if isempty(this.EvolutionIdToNode)
                return;
            end
            node=this.EvolutionIdToNode(node.Id);
        end
        styler.add({node.uuid},'evolutionSelected');
    end

    this.SelectedNode=node;
end
