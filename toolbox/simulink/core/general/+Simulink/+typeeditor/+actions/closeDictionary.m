function closeDictionary(argIn,varargin)




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

        try
            edRoot=ed.getSource;
            node=edRoot.find(nodeName);
            if~isempty(node)
                assert(node.hasDictionaryConnection);
                if node.NodeConnection.hasUnsavedChanges
                    st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg'));
                    [~,name,ext]=fileparts(node.NodeConnection.filespec);
                    nodeName=name;
                    saveBtn=DAStudio.message('SLDD:sldd:PromptForSave');
                    discardBtn=DAStudio.message('SLDD:sldd:PromptForDiscard');
                    cancelBtn=DAStudio.message('SLDD:sldd:PromptForCancel');
                    button=questdlg(DAStudio.message('SLDD:sldd:PromptOnClose',[name,ext]),...
                    DAStudio.message('SLDD:sldd:ClosePromptTitle'),...
                    saveBtn,discardBtn,cancelBtn,saveBtn);

                    if isempty(button)||strcmp(button,cancelBtn)
                        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
                        return;
                    else
                        switch button
                        case saveBtn
                            Simulink.typeeditor.actions.saveDictionary(nodeName,inClose);
                        case discardBtn
                            Simulink.typeeditor.actions.revertDictionary(nodeName,inClose);
                        otherwise
                            assert(false);
                        end
                    end
                end
                st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorClosingInProgressStatusMsg'));
                edRoot.deleteChild(nodeName,inClose);
            end
        catch ME
            Simulink.typeeditor.utils.reportError(ME.message);
        end
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
    end
end