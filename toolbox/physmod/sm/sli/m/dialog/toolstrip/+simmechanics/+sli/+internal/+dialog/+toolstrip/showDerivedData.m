function showDerivedData(cbInfo)
    cbInfo.Context.Object.ShowDerivedData=cbInfo.EventData;
    sm_block_dialog_pi(cbInfo.Context.Object.BlockHandle,'deriveddata',cbInfo.EventData);
end

