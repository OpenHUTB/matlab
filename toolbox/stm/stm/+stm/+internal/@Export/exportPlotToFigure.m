function exportPlotToFigure(clientID,axesID,copyType)





    engine=Simulink.sdi.Instance.engine;

    clientObj=Simulink.sdi.WebClient(clientID);
    axesIDs=unique([clientObj.Axes.ParentAxisID]);


    prefStruct=Simulink.sdi.getViewPreferences();
    numPrefRows=int8(prefStruct.plotPref.numPlotRows);
    numPrefsCols=int8(prefStruct.plotPref.numPlotCols);


    oCp=onCleanup(@()Simulink.sdi.setSubPlotLayout(numPrefRows,numPrefsCols));


    temp=mod(axesIDs,8);
    nSTMrows=max(temp);
    nstmCols=numel(find(temp==1));



    Simulink.sdi.setSubPlotLayout(nSTMrows,nstmCols);


    engine.exportPlotToFigure(clientID,axesID,copyType);
end