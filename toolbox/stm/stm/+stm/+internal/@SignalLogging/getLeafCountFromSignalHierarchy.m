function leafCount=getLeafCountFromSignalHierarchy(hierStruct)



    import stm.internal.SignalLogging.*;
    if~isempty(hierStruct.Children)
        leafCount=sum(arrayfun(@(hStruct)getLeafCountFromSignalHierarchy(hStruct),hierStruct.Children));
    else
        leafCount=1;
    end
end