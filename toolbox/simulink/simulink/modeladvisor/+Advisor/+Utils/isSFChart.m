function bResult=isSFChart(blockHandle)
    bResult=false;%#ok<NASGU>
    if~isnumeric(blockHandle)
        blockHandle=get_param(blockHandle,'Handle');
    end
    try
        bResult=sfprivate('block2chart',blockHandle)~=0;
    catch
        bResult=false;
    end
end