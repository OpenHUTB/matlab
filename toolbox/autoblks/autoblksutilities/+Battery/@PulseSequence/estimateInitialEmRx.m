function Param=estimateInitialEmRx(psObj,varargin)



























































    p=inputParser;
    p.addParameter('EstimateEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('EstimateR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainEm',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('RetainR0',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('ShowBeforePlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('IgnoreRelaxation',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});


    EstimateEm=p.Results.EstimateEm;
    EstimateR0=p.Results.EstimateR0;
    RetainEm=p.Results.RetainEm;
    RetainR0=p.Results.RetainR0;





    for psIdx=1:numel(psObj)


        Param=psObj(psIdx).Parameters;
        NumRC=Param.NumRC;


        socIdx=getSocIdxForPulses(psObj(psIdx));



        for pIdx=1:psObj(psIdx).NumPulses
            thisIdx=sort(socIdx([pIdx,pIdx+1]));
            psObj(psIdx).Pulse(pIdx).Parameters.EmMin=Param.EmMin(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.EmMax=Param.EmMax(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.Em=Param.Em(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0Min=Param.R0Min(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0Max=Param.R0Max(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.R0=Param.R0(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.RxMin=Param.RxMin(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.RxMax=Param.RxMax(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.Rx=Param.Rx(:,thisIdx);
            psObj(psIdx).Pulse(pIdx).Parameters.TxMin=Param.TxMin(:,thisIdx,:);
            psObj(psIdx).Pulse(pIdx).Parameters.TxMax=Param.TxMax(:,thisIdx,:);
            psObj(psIdx).Pulse(pIdx).Parameters.Tx=Param.Tx(:,thisIdx,:);
        end


        psObj(psIdx).Pulse.estimateLinearEmRx(varargin{:});



        PParam=[psObj(psIdx).Pulse.Parameters];

        AllEm=reshape([PParam.Em],2,[]);
        AllEm1=AllEm(1,:);
        AllEm2=AllEm(2,:);
        AllEm=[AllEm2(1),(AllEm2(2:end)+AllEm1(1:end-1))/2,AllEm1(end)];

        AllR0=reshape([PParam.R0],2,[]);
        AllR01=AllR0(1,:);
        AllR02=AllR0(2,:);
        AllR0=[AllR02(1),(AllR02(2:end)+AllR01(1:end-1))/2,AllR01(end)];

        PParam=[psObj(psIdx).Pulse.Parameters];
        AllRx=reshape([PParam.Rx],NumRC,2,[]);


        AllRx1=reshape(AllRx(:,1,:),NumRC,[]);
        AllRx2=reshape(AllRx(:,2,:),NumRC,[]);
        AllRx=[AllRx2(:,1),(AllRx2(:,2:end)+AllRx1(:,1:end-1))/2,AllRx1(:,end)];





        if EstimateEm&&RetainEm
            Param.Em=AllEm(1,socIdx);
        end
        if EstimateR0&&RetainR0
            Param.R0=AllR0(1,socIdx);
        end
        Param.Rx(:,socIdx)=AllRx;


        psObj(psIdx).Parameters=Param;

    end
