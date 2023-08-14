function ShowBlockConditionalPauseDialog(modelH,blockH)

    blockMap=SLStudio.GetBlockConditionalPauseDialogMap();

    if~blockMap.isKey(blockH)
        blockMap(blockH)=SLStudio.BlockConditionalPauseDialog(modelH,blockH);
    end

    obj=blockMap(blockH);
    obj.showBlockConditionalPauseDialog;

end
