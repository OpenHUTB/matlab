function str=getOptionalTraceInfoString(m)


    if(getNumDatasets(m.PolariObj)>1)&&...
        (getDataSetIndex(m)==p.pCurrentDataSetIndex)

        str=[' ',internal.polariCommon.getUTFCircleChar('A')];
    else
        str='';
    end

end
