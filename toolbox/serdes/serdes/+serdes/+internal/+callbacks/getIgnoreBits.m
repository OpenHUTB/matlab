




function ignoreBits=getIgnoreBits(mws)
    txTree=mws.getVariable('TxTree');
    txIgnoreBits=txTree.getReservedParameter('Ignore_Bits');
    rxTree=mws.getVariable('RxTree');
    rxIgnoreBits=rxTree.getReservedParameter('Ignore_Bits');

    if~isempty(txIgnoreBits)&&~isempty(rxIgnoreBits)
        ignoreBits=max(txIgnoreBits.CurrentValue,rxIgnoreBits.CurrentValue);
    elseif~isempty(txIgnoreBits)
        ignoreBits=txIgnoreBits.CurrentValue;
    elseif~isempty(rxIgnoreBits)
        ignoreBits=rxIgnoreBits.CurrentValue;
    else
        ignoreBits=0;
    end
end