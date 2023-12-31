function hList=loop_getLoopObjects(c)






    [hList,currContext]=getContextObject(rptgen_sf.appdata_sf);

    if c.isSFFilterList
        searchTerms=rptgen_sf.findTerms(c.SFFilterTerms);
    else
        searchTerms={};
    end

    if~isempty(hList)&all(ishandle(hList))
        if c.SkipAutogenerated
            searchTerms=[searchTerms(:);{'-function';@isNotAutogenerated}];
        end

        hList=find(hList,'-isa','Stateflow.Object',searchTerms{:});
        hList=hList(:);
    else
        hList=[];
    end


    function tf=isNotAutogenerated(sfID)




        tf=rptgen_sf.isNotAutogenerated(sfID);
