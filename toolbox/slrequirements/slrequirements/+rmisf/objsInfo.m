function[fullname,shortname,types]=objsInfo(objH,isas,parentsH)



    if nargin<2
        if length(objH)>1
            error(message('Slvnv:reqmgt:rmisf:objinfo'))
        end
        isas=sf('get',objH,'.isa');
    end

    sfisa=rmisf.sfisa;
    isTrans=(isas==sfisa.transition);
    hasTrans=any(isTrans);
    isState=(isas==sfisa.state);
    hasState=any(isState);
    isChart=(isas==sfisa.chart);
    hasChart=any(isChart);

    if hasState
        stateNames=sf('get',objH(isState),'.name');
        shortname(isState)=deblank(cellstr(stateNames));
        for idx=find(isState')
            fullname{idx}=sf('FullNameOf',objH(idx),'/');%#ok<*AGROW>
        end
    end

    if hasChart
        chartNames=sf('get',objH(isChart),'.name');
        shortname(isChart)=deblank(cellstr(chartNames));
        shortname=strrep(shortname,'/','//');
    end

    if hasTrans
        filteredTrans=rmisf.filterTransForSync(objH(isTrans),parentsH(isTrans),false);
        [fullname(isTrans),shortname(isTrans)]=rmisf.transPaths(filteredTrans);

























    end

    for idx=find(isChart')
        fullname{idx}=sf('FullNameOf',objH(idx),'/');
    end

    types(isState)={'Stateflow State'};
    types(isTrans)={'Stateflow Transition'};
    types(isChart)={'Stateflow Chart'};
end
