function[ttList,indxToLinkPath]=findSTTs(sfContext,slContext)









    if isempty(meta.package.fromName('Stateflow'))

        ttList=[];
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
                searchTerms={'-depth',3};





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

    ttList=find(sfContext,searchTerms{:},'-isa','Stateflow.StateTransitionTableChart');

    indxToLinkPath=containers.Map('KeyType','double','ValueType','any');
    linkCharts=find(sfContext,searchTerms{:},'-isa','Stateflow.LinkChart');
    nLinkCharts=length(linkCharts);
    for i=1:nLinkCharts
        linkChart=linkCharts(i);
        chartId=sfprivate('block2chart',sf('get',linkChart.Id,'.handle'));
        chartObj=idToHandle(sfroot,chartId);
        if isa(chartObj,'Stateflow.StateTransitionTableChart')
            ttList=[ttList,chartObj];%#ok<AGROW>
            idx=length(ttList);
            indxToLinkPath(idx)=linkChart.Path;
        end
    end