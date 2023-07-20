function saveDictionary(argIn,varargin)




    ed=Simulink.typeeditor.app.Editor.getInstance;

    inClose=false;
    if nargin>1
        inClose=varargin{1};
        nodeName=argIn;
    else
        if isa(argIn,'dig.CallbackInfo')
            nodeName=ed.getTreeComp.getSelection{end}.Name;
        else
            nodeName=argIn;
        end
    end


    if ed.isVisible


        st=ed.getStudio;
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorSavingInProgressStatusMsg'));

        edRoot=ed.getSource;
        node=edRoot.find(nodeName);
        try
            if~isempty(node)
                assert(node.NodeConnection.hasUnsavedChanges);
                node.NodeConnection.saveChanges;
                if~inClose
                    ed.getTreeComp.update(true);
                end
            end
        catch ME
            Simulink.typeeditor.utils.reportError(ME.message);
        end

        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
        ed.update;
    end
end