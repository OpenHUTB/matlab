function[testSeqs,indxToLinkPath]=findTestSeq(sfContext,slContext)





    indxToLinkPath=containers.Map('KeyType','double','ValueType','any');

    if isempty(meta.package.fromName('Stateflow'))

        testSeqs=[];
        return;
    elseif nargin<1
        sfContext=get(rptgen_sf.appdata_sf,'CurrentObject');
    elseif~isempty(sfContext)
        sfContext=find(slroot,'ID',sfContext);
    end

    if isempty(sfContext)||~ishandle(sfContext)

        if nargin<2
            sfContext=getContextObject(rptgen_sl.appdata_sl);
        else
            sfContext=slContext;
        end

        if isempty(sfContext)
            sfContext=slroot;
            searchTerms={};
        else
            sfContext=get_param(sfContext,'Object');
            if isa(sfContext,'Simulink.SubSystem')
                searchTerms={'-depth',2};




            else
                searchTerms={};
            end
        end
    elseif isa(sfContext,'Stateflow.Machine')||...
        isa(sfContext,'Stateflow.Chart')
        searchTerms={};
    else
        searchTerms={'-depth',1};
    end

    testSeqs=...
    find(sfContext,searchTerms{:},'-isa','Stateflow.ReactiveTestingTableChart');

    linkCharts=find(sfContext,searchTerms{:},'-isa','Stateflow.LinkChart');

    nLinkCharts=length(linkCharts);
    for i=1:nLinkCharts
        linkChart=linkCharts(i);
        chartId=sfprivate('block2chart',sf('get',linkChart.Id,'.handle'));
        chartObj=idToHandle(sfroot,chartId);
        if isa(chartObj,'Stateflow.ReactiveTestingTableChart')
            testSeqs=[testSeqs,chartObj];%#ok<AGROW>
            idx=length(testSeqs);
            indxToLinkPath(idx)=linkChart.Path;
        end
    end
end