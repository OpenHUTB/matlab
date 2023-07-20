function retval=getBreakpointData(bpData)





    if(~iscell(bpData))
        bpData={bpData};
    end

    dataSize=numel(bpData);
    retval=cell(1,dataSize);


    for ii=1:numel(bpData)
        breakPoint=bpData{ii};
        retval{ii}=double(min(breakPoint));
    end
end
