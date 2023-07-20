function initializeDialogForLogAndVisualization(this)



    sig=this.findInstrumentedSignal();
    dlg=this.findDialog();
    if~isempty(sig)&&~isempty(dlg)


        if sig.IsFrameBased_
            val=1;
        else
            val=0;
        end
        dlg.setWidgetValue(this.FRAME_MODE_TAG,val);


        if Simulink.sdi.enableSDIVideo>1
            val=locConvertVisualModeStrToIndex(sig.VisualType_);
            dlg.setWidgetValue(this.VISUAL_TYPE_TAG,val);
        end


        [this.LineSettings,complexFormat]=...
        Simulink.sdi.internal.sigSettingsDlg.getDefaultValues(this.DlgUUID);
        if~isempty(this.LineSettings.Axes)
            dlg.setWidgetValue(this.SUBPLOT_TAG,locConvertVectorToString(this.LineSettings.Axes));
        end


        dlg.setWidgetValue(this.COMPLEX_FORMAT_TAG,complexFormat);

        dlg.enableApplyButton(false);
    end
end


function ret=locConvertVectorToString(vec)
    ret=sprintf('%d,',vec);
    ret(end)=[];
end


function ret=locConvertVisualModeStrToIndex(str)
    switch lower(str)
    case 'video'
        ret=1;
    otherwise
        ret=0;
    end
end
