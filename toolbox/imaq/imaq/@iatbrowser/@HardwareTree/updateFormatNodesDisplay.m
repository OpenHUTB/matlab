function objs=updateFormatNodesDisplay(this)

    root=this.rootNode;

    objs=java.util.Vector();

    doChild(root);

    function doChild(parent)
        children=parent.getChildren();
        for ii=1:length(children)

            doChild(children{ii});
        end

        if isa(parent,'iatbrowser.FormatNode')
            if~isempty(parent.VideoinputObject)
                parent.updateDisplay();
            end
        end
    end
    javaMethodEDT('updateUI',java(this.javaTreePeer));
end