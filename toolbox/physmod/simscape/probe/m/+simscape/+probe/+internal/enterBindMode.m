function enterBindMode(blockHandle)




    assert(ishandle(blockHandle));
    assert(isscalar(blockHandle));
    assert(string(get_param(blockHandle,'BlockType'))=="SimscapeProbe");

    sourceData=simscape.probe.internal.BindModeSourceData(blockHandle);
    BindMode.BindMode.enableBindMode(sourceData);

end