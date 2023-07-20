function objs=getAllVideoinputObjects(this)










    root=this.treePanel.rootNode;

    objs=java.util.Vector();

    doChild(root);

    function doChild(parent)
        children=parent.getChildren();
        for ii=1:length(children)

            doChild(children{ii});
        end

        if isa(parent,'iatbrowser.FormatNode')
            if~isempty(parent.VideoinputObject)
                objs.add(...
                com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.VideoInputObject(...
                imaqgate('privateGetField',parent.VideoinputObject,'uddobject'),...
                parent.Parent.DisplayName,...
                parent.Format));
            end
        end
    end

end