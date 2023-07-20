function revertDictionary(argIn,varargin)




    narginchk(1,2);

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

    st=ed.getStudio;


    if ed.isVisible&&~isempty(st)

        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorRevertingInProgressStatusMsg'));
        try
            edRoot=ed.getSource;
            node=edRoot.find(nodeName);
            assert(node.hasDictionaryConnection);
            if node.NodeConnection.hasUnsavedChanges
                node.NodeConnection.discardChanges;
                node.refresh;
                if~inClose
                    node.notifySLDDChanged;
                    deps=node.NodeConnection.Dependencies;
                    for i=1:length(deps)
                        [~,slddDepName,~]=fileparts(deps{i});
                        depNode=edRoot.find(slddDepName);
                        if~isempty(depNode)&&strcmp(depNode.NodeConnection.filespec,deps{i})
                            depNode.MarkForRefresh=true;
                        end
                    end
                    ed.getTreeComp.update(true);
                    ed.getTreeComp.view(node);
                end
            end
        catch ME
            Simulink.typeeditor.utils.reportError(ME.message);
        end
    end
    st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
end