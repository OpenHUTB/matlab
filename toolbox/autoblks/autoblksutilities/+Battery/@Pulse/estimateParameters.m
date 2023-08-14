function estimateParameters(pObj,varargin)



































































    if matlab.internal.parallel.isPCTInstalled()&&matlab.internal.parallel.isPCTLicensed()
        UseParallel='always';
    else
        UseParallel='never';
    end


    p=inputParser;
    p.addParameter('EstimateEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RelConstrRx',inf,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('RelConstrTx',inf,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('SDOOptimizeOptions',sdo.OptimizeOptions('Method','lsqnonlin','UseParallel',UseParallel),...
    @(x)validateattributes(x,{'sdo.OptimizeOptions'},{'scalar'}));
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('ReusePlotFigure',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',5,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.parse(varargin{:});


    EstimateEm=p.Results.EstimateEm;
    EstimateR0=p.Results.EstimateR0;
    RetainEm=p.Results.RetainEm;
    RetainR0=p.Results.RetainR0;
    RelConstrRx=p.Results.RelConstrRx;
    RelConstrTx=p.Results.RelConstrTx;
    SDOOptimizeOptions=p.Results.SDOOptimizeOptions;
    ShowPlots=p.Results.ShowPlots;
    ReusePlotFigure=p.Results.ReusePlotFigure;
    PlotDelay=p.Results.PlotDelay;





    ParamMgr=Battery.DistributedParameterManager();


    expObj=createSdoExperiment(pObj(1));


    SDOOptimizeOptions.OptimizedModel=expObj.ModelName;


    load_system(expObj.ModelName);


    if strcmp(SDOOptimizeOptions.UseParallel,'always')

        if isempty(gcp('nocreate'))
            parpool();
        end
        SDOOptimizeOptions.ParallelPathDependencies=sdo.getModelDependencies(expObj.ModelName);
    end



    for pIdx=1:numel(pObj)




        expObj=createSdoExperiment(pObj(pIdx),expObj);


        ParamMgr.setParameter('Em',expObj.Parameters(1).Value);
        ParamMgr.setParameter('R0',expObj.Parameters(2).Value);
        ParamMgr.setParameter('Rx',expObj.Parameters(3).Value);
        ParamMgr.setParameter('Tx',expObj.Parameters(4).Value);
        ParamMgr.setParameter('SOC_LUT',pObj(pIdx).Parameters.SOC);
        ParamMgr.setParameter('InitialCapVoltage',pObj(pIdx).InitialCapVoltage);
        ParamMgr.setParameter('InitialChargeDeficitAh',pObj(pIdx).InitialChargeDeficitAh);
        ParamMgr.setParameter('CapacityAh',pObj(pIdx).Parent.CapacityAh);
        ParamMgr.distributeParameters();


        if~EstimateEm
            expObj.Parameters(1).Free(:)=false;
        end
        if~EstimateR0
            expObj.Parameters(2).Free(:)=false;
        end



        simObj=expObj.createSimulator();





        estFcn=@(paramObj)i_EstimObjective(paramObj,expObj,simObj);


        tStart=tic;
        newParamObj=sdo.optimize(estFcn,expObj.Parameters,SDOOptimizeOptions);
        tElapsed=toc(tStart);
        fprintf(getString(message('autoblks:autoblkUtilMisc:estDur',num2str(round(tElapsed,2)))));





        if ShowPlots


            if~exist('h','var')||~isfield(h,'Fig')||~ishghandle(h.Fig)||~ReusePlotFigure
                h=i_CreateFigure();
            end


            [tBef,vBef,tResBef,vResBef]=Battery.getSimulationOutputs(expObj,simObj);
            vResBef_mV=abs(vResBef)*1000;
            vResBef_Mean_mV=mean(vResBef_mV);


            expObj=expObj.setEstimatedValues(newParamObj);
            [tAft,vAft,tResAft,vResAft]=Battery.getSimulationOutputs(expObj,simObj);
            vResAft_mV=abs(vResAft)*1000;
            vResAft_Mean_mV=mean(vResAft_mV);


            set(h.Title,'String',getString(message('autoblks:autoblkUtilMisc:hTitleSDO',pIdx,numel(pObj))));
            set(h.DataLine,'XData',pObj(pIdx).Time,'YData',pObj(pIdx).Voltage);
            set(h.BeforeLine,'XData',tBef,'YData',vBef)
            set(h.BeforeResLine,'XData',tResBef,'YData',vResBef_mV)
            set(h.FitLine,'XData',tAft,'YData',vAft)
            set(h.FitResLine,'XData',tResAft,'YData',vResAft_mV)
            LegendString=get(h.Legend,'String');
            LegendString{2}=getString(message('autoblks:autoblkUtilMisc:mResBef',num2str(round(vResBef_Mean_mV,2))));
            LegendString{3}=getString(message('autoblks:autoblkUtilMisc:mResAft',num2str(round(vResAft_Mean_mV,2))));
            set(h.Legend,'String',LegendString)
drawnow
            axis(h.Axes(2),'tight');
            axis(h.Axes(1),'tight');
            pause(PlotDelay);

        end





        Param=pObj(pIdx).Parameters;
        if EstimateEm&&RetainEm
            Param.Em=newParamObj(1).Value;
        end
        if EstimateR0&&RetainR0
            Param.R0=newParamObj(2).Value;
        end
        Param.Rx=newParamObj(3).Value;
        Param.Tx=newParamObj(4).Value;


        pObj(pIdx).Parameters=Param;


    end



    function vals=i_EstimObjective(paramObj,expObj,simObj)


        expObj=expObj.setEstimatedValues(paramObj);


        [~,~,~,vals.F]=Battery.getSimulationOutputs(expObj,simObj);



        function h=i_CreateFigure()

            h.Fig=figure(...
            'Name','SDO Estimation',...
            'NumberTitle','off',...
            'WindowStyle','docked');
            h.Axes(1)=axes('Parent',h.Fig,...
            'Units','normalized',...
            'Position',[0.11,0.33,0.8,0.6],...
            'XTickLabel',[],...
            'FontSize',12);
            h.Axes(2)=axes('Parent',h.Fig,...
            'Units','normalized',...
            'Position',[0.11,0.11,0.8,0.16],...
            'FontSize',12);
            h.DataLine=line('Parent',h.Axes(1),'XData',NaN,'YData',NaN,...
            'LineStyle','none',...
            'MarkerEdgeColor',[0,0,1],...
            'Marker','o',...
            'MarkerSize',6);
            h.BeforeLine=line('Parent',h.Axes(1),'XData',NaN,'YData',NaN,...
            'Color',[1,.8,0],...
            'LineWidth',2,...
            'MarkerEdgeColor',[1,.8,0],...
            'Marker','x',...
            'MarkerSize',3);
            h.FitLine=line('Parent',h.Axes(1),'XData',NaN,'YData',NaN,...
            'Color',[1,0,0],...
            'LineWidth',2,...
            'MarkerEdgeColor',[1,0,0],...
            'Marker','x',...
            'MarkerSize',3);
            h.BeforeResLine=line('Parent',h.Axes(2),'XData',NaN,'YData',NaN,...
            'Color',[1,.8,0],...
            'LineWidth',2);
            h.FitResLine=line('Parent',h.Axes(2),'XData',NaN,'YData',NaN,...
            'Color',[1,0,0],...
            'LineWidth',2);
            h.Title=title(h.Axes(1),'SDO Estimation 0 of N');
            h.XLabel=xlabel(h.Axes(2),'time (s)');
            h.YLabel(1)=ylabel(h.Axes(1),'voltage (V)');
            h.YLabel(2)=ylabel(h.Axes(2),'residual (mV)');
            grid(h.Axes(1),'on')
            grid(h.Axes(2),'on')
            linkaxes(h.Axes,'x');
            axis(h.Axes(1),'tight');
            axis(h.Axes(2),'tight');
            h.Legend=legend(h.Axes(1),...
            [h.DataLine;h.BeforeLine;h.FitLine],...
            'Data','Before','After');
drawnow
