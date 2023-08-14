function h=plotSimulationResults(pObj)





















%#ok<*AGROW>


    ParamMgr=Battery.DistributedParameterManager();


    expObj=createSdoExperiment(pObj(1));


    load_system(expObj.ModelName);


    for pIdx=1:numel(pObj)


        expObj=createSdoExperiment(pObj(pIdx),expObj);


        ParamMgr.setParameter('Em',expObj.Parameters(1).Value);
        ParamMgr.setParameter('R0',expObj.Parameters(2).Value);
        ParamMgr.setParameter('Rx',expObj.Parameters(3).Value);
        ParamMgr.setParameter('Tx',expObj.Parameters(4).Value);
        ParamMgr.setParameter('SOC_LUT',pObj.Parameters.SOC);
        ParamMgr.setParameter('InitialCapVoltage',pObj.InitialCapVoltage);
        ParamMgr.setParameter('InitialChargeDeficitAh',pObj.InitialChargeDeficitAh);
        ParamMgr.setParameter('CapacityAh',pObj.Parent.CapacityAh);
        ParamMgr.distributeParameters();



        simObj=expObj.createSimulator();


        [t,v,tRes,vRes]=Battery.getSimulationOutputs(expObj,simObj);
        vRes_mV=abs(vRes)*1000;
        vRes_Mean_mV=mean(vRes_mV);


        h(pIdx).Fig=figure(...
        'Name',getString(message('autoblks:autoblkUtilMisc:pulseName',pIdx,numel(pObj))),...
        'NumberTitle','off',...
        'WindowStyle','docked');
        h(pIdx).Axes(1)=axes('Parent',h(pIdx).Fig,...
        'Units','normalized',...
        'Position',[0.11,0.33,0.8,0.6],...
        'XTickLabel',[],...
        'FontSize',12);
        h(pIdx).Axes(2)=axes('Parent',h(pIdx).Fig,...
        'Units','normalized',...
        'Position',[0.11,0.11,0.8,0.16],...
        'FontSize',12);


        h(pIdx).DataLine=line('Parent',h(pIdx).Axes(1),...
        'XData',pObj(pIdx).Time,...
        'YData',pObj(pIdx).Voltage,...
        'LineStyle','none',...
        'MarkerEdgeColor',[0,0,1],...
        'Marker','o',...
        'MarkerSize',6);
        h(pIdx).FitLine=line('Parent',h(pIdx).Axes(1),...
        'XData',t,...
        'YData',v,...
        'Color',[1,0,0],...
        'LineWidth',2,...
        'MarkerEdgeColor',[1,0,0],...
        'Marker','x',...
        'MarkerSize',3);
        h(pIdx).FitResLine=line('Parent',h(pIdx).Axes(2),...
        'XData',tRes,...
        'YData',vRes_mV,...
        'Color',[1,0,0],...
        'LineWidth',2);


        h(pIdx).Title=title(h(pIdx).Axes(1),...
        getString(message('autoblks:autoblkUtilMisc:pulseName',pIdx,numel(pObj))));
        h(pIdx).XLabel=xlabel(h(pIdx).Axes(2),getString(message('autoblks:autoblkUtilMisc:xLabel')));
        h(pIdx).YLabel(1)=ylabel(h(pIdx).Axes(1),getString(message('autoblks:autoblkUtilMisc:yLabelV')));
        h(pIdx).YLabel(2)=ylabel(h(pIdx).Axes(2),getString(message('autoblks:autoblkUtilMisc:yLabelR')));
        h(pIdx).Legend=legend(h(pIdx).Axes(1),...
        [h(pIdx).DataLine;h(pIdx).FitLine],...
        'Data',getString(message('autoblks:autoblkUtilMisc:mResSim',num2str(round(vRes_Mean_mV,2)))));


        grid(h(pIdx).Axes(1),'on')
        grid(h(pIdx).Axes(2),'on')
        linkaxes(h(pIdx).Axes,'x');
        axis(h(pIdx).Axes(1),'tight');
        axis(h(pIdx).Axes(2),'tight');

    end



