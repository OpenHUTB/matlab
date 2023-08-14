function expandScriptPanelCallBack(varargin)







    if isa(varargin{1},'DAStudio.Dialog')


        dlg=varargin{1};

        scriptPanelState=varargin{3};



        scriptEditorTag='ScriptReference_matlabeditor';








        if scriptPanelState&&isempty(dlg.getWidgetValue(scriptEditorTag))
            scriptEditorValue=...
            Simulink.internal.SlimDialog.generateScriptReference(...
            dlg.getSource.getBlock.getFullName...
            );
            dlg.setWidgetValue(scriptEditorTag,scriptEditorValue);
            dlg.clearWidgetDirtyFlag(scriptEditorTag);
        end
    end

end
