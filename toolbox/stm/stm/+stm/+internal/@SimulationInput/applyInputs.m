



function applyInputs(this)
    reader=stm.internal.InputReader.getReader(this.SimIn,this.RunTestCfg,this.SimWatcher);
    assert(numel(reader)<=2);

    arrayfun(@setup,reader);
    arrayfun(@override,reader);
    arrayfun(@getExternalInputRunData,reader);
    arrayfun(@setStopTime,reader);
    arrayfun(@setMappingStatusMessage,reader);
    arrayfun(@teardown,reader);
end
