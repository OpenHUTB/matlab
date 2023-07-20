function showStyleDialog(this)









    if isempty(this.StyleDialog)

        okCallback=makeCallback(this,@updateStyle,'OK');
        applyCallback=makeCallback(this,@updateStyle,'Apply');
        displaySelectedCallback='';
        hideCallback=makeCallback(this,@hideStyleDialog);
        ip=getStyleDialogInput(this);
        this.StyleDialog=dsp.scopes.GraphicalPropertyEditorSpectrumScope(...
        ip,okCallback,applyCallback,displaySelectedCallback,hideCallback);
    else
        if this.StyleDialog.Visible

            this.StyleDialog.Visible=true;
        else

            ip=getStyleDialogInput(this);
            initialize(this.StyleDialog,ip);
            this.StyleDialog.Visible=true;
        end
    end
end
