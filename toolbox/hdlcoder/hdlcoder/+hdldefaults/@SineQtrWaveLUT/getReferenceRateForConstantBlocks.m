
function refRate=getReferenceRateForConstantBlocks(this,hN,hC)%#ok<INUSD,INUSL>

    refRate=hN.PirInputSignals(1).SimulinkRate;
end
