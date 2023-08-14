function DSMaskLoad(hBlk)







    set_param(hBlk,'LoadFlag','0');

    blkHandle=get_param(hBlk,'object');
    expStrings=blkHandle.Signals;
    actStrings=derivedSignals.util.SerializeSubsystem(hBlk);


    if strcmp(expStrings,actStrings)
        return;
    end

    locLoadFromSignals(hBlk);





































































end

function locLoadFromSignals(hBlk)


    blkHandle=get_param(hBlk,'object');
    signals=regexp(blkHandle.Signals,'#','split')';
    blockNames=regexp(blkHandle.BlockNames,'#','split')';
    selectedSignal=blkHandle.SelectedSignal;
    if strcmp(selectedSignal,'0')

        selectedSignal='1';
    end
    derivedSignals.util.ApplySignals(hBlk,signals,selectedSignal,blockNames);

end
