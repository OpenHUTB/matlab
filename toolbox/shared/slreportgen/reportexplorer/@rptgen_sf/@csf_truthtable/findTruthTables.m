function ttList=findTruthTables(sfContext,slContext)









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





    ttList={};



    ttables=find(sfContext,searchTerms{:},'-isa','Stateflow.TruthTable');
    for i=1:length(ttables)
        ttList=[ttList,{ttables(i)}];%#ok<AGROW>
    end



    linkCharts=find(sfContext,searchTerms{:},'-isa','Stateflow.LinkChart');
    for i=1:length(linkCharts)
        linkChart=linkCharts(i);
        chartId=sfprivate('block2chart',sf('get',linkChart.Id,'.handle'));
        chartObj=idToHandle(sfroot,chartId);
        if isa(chartObj,'Stateflow.TruthTableChart')
            ttList=[ttList,{chartObj}];%#ok<AGROW>
        end
    end
