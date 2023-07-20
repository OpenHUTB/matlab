function hList=loop_getLoopObjects(c)






    hList=[];

    if c.isSFFilterList
        filterTerms=rptgen_sf.findTerms(c.SFFilterTerms);
    else
        filterTerms={};
    end

    adSF=rptgen_sf.appdata_sf;
    currObj=getContextObject(adSF);

    if isempty(currObj)
        hList=[];
    elseif isa(currObj,'Simulink.Root')||isa(currObj,'Stateflow.Root')
        hList=currObj;
        filterTerms=[{'-isa','Stateflow.Machine'},filterTerms];
        depthTerms={};
    elseif~isempty(findprop(currObj,'Machine'))
        hList=currObj.Machine;
        if~isempty(filterTerms)


            filterTerms=[{'-isa';'Stateflow.Machine';'-depth';1};filterTerms(:)];
        end
    else

        hList=[];
    end

    if~isempty(hList)&~isempty(filterTerms);
        hList=find(hList,filterTerms{:});
    end

    hList=hList(:);