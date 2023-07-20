function schema=reqTableIncludeModelRF(cbInfo)




    schema=sl_toggle_schema;
    schema.autoDisableWhen='Locked';
    schema.state='Enabled';
    schema.callback=@SFStudio.internal.reqTableIncludeModelCB;

    chartId=SFStudio.Utils.getChartId(cbInfo);
    if sf('get',chartId,'.reqTable.includeEntireModelForAnalysis')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end
