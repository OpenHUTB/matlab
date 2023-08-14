function toggleFrames(cbInfo)

    cbInfo.Context.Object.ShowFrames=cbInfo.EventData;
    sm_block_dialog_pi(cbInfo.Context.Object.BlockHandle,'toggleframes',cbInfo.EventData);