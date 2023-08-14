function[sfObjIsa,sfReqInfo]=getReqInfoForObjects(modelH,sfObjs)






    sfIsa=rmisf.sfisa;
    sfObjCnt=length(sfObjs);
    sfObjIsa=-1*ones(sfObjCnt,1);
    sfReqInfo=cell(sfObjCnt,1);

    stateIds=sf('get',sfObjs,'state.id');
    if~isempty(stateIds)
        [isState,~]=rmiut.findidx(stateIds,sfObjs);
        sfObjIsa(isState)=sfIsa.state;
        sfReqInfo(isState)=rmisl.getReqInfoForObjects(sfObjs(isState),modelH,true);
    end

    chartIds=sf('get',sfObjs,'chart.id');
    if~isempty(chartIds)

        [isChart,~]=rmiut.findidx(chartIds,sfObjs);
        sfObjIsa(isChart)=sfIsa.chart;
        sfReqInfo(isChart)=rmisl.getReqInfoForObjects(sfObjs(isChart),modelH,true);
    end

    transIds=sf('get',sfObjs,'trans.id');
    if~isempty(transIds)
        [isTrans,~]=rmiut.findidx(transIds,sfObjs);
        sfObjIsa(isTrans)=sfIsa.transition;
        sfReqInfo(isTrans)=rmisl.getReqInfoForObjects(sfObjs(isTrans),modelH,true);
    end

end

