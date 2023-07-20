function Param=estimateParameters(psObj,varargin)











































































    if matlab.internal.parallel.isPCTInstalled()&&matlab.internal.parallel.isPCTLicensed()
        UseParallel='always';
    else
        UseParallel='never';
    end


    validateattributes(psObj,{'Battery.PulseSequence'},{'scalar'})


    NumPulses=numel(psObj.Pulse);


    p=inputParser;
    p.addParameter('CarryParamToNextPulse',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
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
    p.addParameter('PulseNumbers',1:NumPulses,@(x)validateattributes(x,{'numeric'},{'vector','positive','integer','increasing','<=',NumPulses}));
    p.parse(varargin{:});


    CarryParamToNextPulse=p.Results.CarryParamToNextPulse;
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
    PulseNumbers=p.Results.PulseNumbers;





    ParamMgr=Battery.DistributedParameterManager();


    Param=psObj.Parameters;


    [expObj,rObj]=createSdoExperiment(psObj.Pulse(1));


    SDOOptimizeOptions.OptimizedModel=expObj.ModelName;


    load_system(expObj.ModelName);


    if strcmp(SDOOptimizeOptions.UseParallel,'always')

        if isempty(gcp('nocreate'))
            parpool();
        end
        SDOOptimizeOptions.ParallelPathDependencies=sdo.getModelDependencies(expObj.ModelName);
    end


    socIdx=getSocIdxForPulses(psObj);


    pObj=[psObj.Pulse];



    for pIdx=reshape(PulseNumbers,1,[])






        try
            [expObj,rObj]=createSdoExperiment(pObj(pIdx));
        catch err
            fprintf(getString(message('autoblks:autoblkErrorMsg:errSDO',pIdx,err.message)));
            break;
        end

        expObj=i_UpdateParameters(expObj,Param,socIdx(pIdx:pIdx+1));



        if pIdx==1
            expObj.Parameters(1).Free(:)=true;
            expObj.Parameters(2).Free(:)=true;
            expObj.Parameters(3).Free(:)=true;
            expObj.Parameters(4).Free(:)=true;
        end



        thisSocTableIdx=sort(socIdx(pIdx:pIdx+1));
        if pIdx>1&&CarryParamToNextPulse
            idxOfEnd=thisSocTableIdx(end)==socIdx(pIdx:pIdx+1);
            expObj.Parameters(3).Value(:,idxOfEnd)=expObj.Parameters(3).Value(:,~idxOfEnd);
            expObj.Parameters(4).Value(:,idxOfEnd)=expObj.Parameters(4).Value(:,~idxOfEnd);
        end


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





        estFcn=@(paramObj)i_EstimObjective(paramObj,expObj,simObj,rObj);


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


            set(h.Title,'String',getString(message('autoblks:autoblkUtilMisc:estSDO',pIdx,numel(pObj))));
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





        if EstimateEm&&RetainEm
            Param.Em(:,thisSocTableIdx)=newParamObj(1).Value;
        end
        if EstimateR0&&RetainR0
            Param.R0(:,thisSocTableIdx)=newParamObj(2).Value;
        end
        Param.Rx(:,thisSocTableIdx)=newParamObj(3).Value;
        Param.Tx(:,thisSocTableIdx,:)=newParamObj(4).Value;





    end


    psObj.Parameters=Param;



    function expObj=i_UpdateParameters(expObj,paramObj,socIdx)




        thisSocTableIdx=sort(socIdx);




        idxOfEnd=thisSocTableIdx==socIdx(end);


        expObj.Parameters(1).Value=paramObj.Em(:,thisSocTableIdx);
        expObj.Parameters(1).Minimum=paramObj.EmMin(:,thisSocTableIdx);
        expObj.Parameters(1).Maximum=paramObj.EmMax(:,thisSocTableIdx);
        expObj.Parameters(1).Free(:,idxOfEnd)=true;
        expObj.Parameters(1).Free(:,~idxOfEnd)=false;

        expObj.Parameters(2).Value=paramObj.R0(:,thisSocTableIdx);
        expObj.Parameters(2).Minimum=paramObj.R0Min(:,thisSocTableIdx);
        expObj.Parameters(2).Maximum=paramObj.R0Max(:,thisSocTableIdx);
        expObj.Parameters(2).Free(:,idxOfEnd)=true;
        expObj.Parameters(2).Free(:,~idxOfEnd)=false;

        expObj.Parameters(3).Value=paramObj.Rx(:,thisSocTableIdx);
        expObj.Parameters(3).Minimum=paramObj.RxMin(:,thisSocTableIdx);
        expObj.Parameters(3).Maximum=paramObj.RxMax(:,thisSocTableIdx);
        expObj.Parameters(3).Free(:,idxOfEnd)=true;
        expObj.Parameters(3).Free(:,~idxOfEnd)=false;

        expObj.Parameters(4).Value=paramObj.Tx(:,thisSocTableIdx,:);
        expObj.Parameters(4).Minimum=paramObj.TxMin(:,thisSocTableIdx,:);
        expObj.Parameters(4).Maximum=paramObj.TxMax(:,thisSocTableIdx,:);
        expObj.Parameters(4).Free(:,idxOfEnd)=true;
        expObj.Parameters(4).Free(:,~idxOfEnd)=false;



        function vals=i_EstimObjective(paramObj,expObj,simObj,rObj)


            expObj=expObj.setEstimatedValues(paramObj);


            [~,~,~,vals.F]=Battery.getSimulationOutputs(expObj,simObj,rObj);



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
