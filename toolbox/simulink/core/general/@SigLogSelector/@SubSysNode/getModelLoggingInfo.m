function mi=getModelLoggingInfo(h)





    mi=[];


    topMdl=h.getTopModelName;
    if isempty(topMdl)||~bdIsLoaded(topMdl)




        return;
    end


    mi=get_param(topMdl,'DataLoggingOverride');
    assert(~isempty(mi));

end
