function out1=getCustomDdgWidget(source,h,tsName,...
    tsTypeName,layoutRow,layoutPrompt,layoutValue,varargin)



    try
        if slfeature('EnableAdvancedSampleTimeWidget')>0||...
            slfeature('HideSampleTimeWidgetWithDefaultValue')>0
            out1=create_sampletime_widget_impl(source,h,tsName,...
            tsTypeName,layoutRow,layoutPrompt,layoutValue,varargin{:});
        else
            out1=create_widget(source,h,tsName,layoutRow,layoutPrompt,layoutValue);
        end
    catch ex


        disp(ex.getReport)


        out1=create_widget(source,h,tsName,...
        layoutRow,layoutPrompt,layoutValue);
    end

end

function out1=create_sampletime_widget_impl(source,h,tsName,...
    tsTypeName,layoutRow,layoutPrompt,layoutValue,varargin)



    if~isempty(varargin)
        showDialogWidget=varargin{1};
    else
        showDialogWidget=false;
    end


    assert(...
    strcmp(h.IntrinsicDialogParameters.(tsName).Prompt,...
    DAStudio.message('Simulink:blkprm_prompts:AllSrcBlksSampleTime'))||...
    strcmp(h.IntrinsicDialogParameters.(tsName).Prompt,...
    DAStudio.message('Simulink:blkprm_prompts:AllBlksSampleTime')));



    if slfeature('EnableAdvancedSampleTimeWidget')>0&&showDialogWidget
        w=Simulink.SampleTimeWidget.getSampleTimeWidget(tsName,...
        -1,h.getPropValue(tsName),...
        tsTypeName,localConvertNameForLocale(h.getPropValue(tsTypeName)),...
        source,varargin{:});





        w.Name=DAStudio.message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');

    else


        w=Simulink.SampleTimeWidget.getSampleTimeWidget(tsName,...
        -1,h.getPropValue(tsName),...
        '','',source,varargin{:});

    end

    w.RowSpan=[layoutRow,layoutRow];
    w.ColSpan=[1,(layoutPrompt+layoutValue)];


    out1=w;

end


