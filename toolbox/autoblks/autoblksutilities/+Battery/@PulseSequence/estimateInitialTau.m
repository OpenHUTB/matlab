function Param=estimateInitialTau(psObj,varargin)


































    p=inputParser;
    p.addParameter('ShowPlots',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('PlotDelay',0,@(x)validateattributes(x,{'numeric'},{'scalar','nonnegative'}));
    p.addParameter('ReusePlotFigure',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('UpdateEndingEm',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('UseLoadData',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(varargin{:});





    UpdateEndingEm=p.Results.UpdateEndingEm;
    UseLoadData=p.Results.UseLoadData;


    for psIdx=1:numel(psObj)


        Param=psObj(psIdx).Parameters;
        NumRC=Param.NumRC;
        NumTC=Param.NumTimeConst;

        socIdx=getSocIdxForPulses(psObj(psIdx));



        for pIdx=1:psObj(psIdx).NumPulses
            thisIdx=sort(socIdx([pIdx,pIdx+1]));
            psObj(psIdx).Pulse(pIdx).Parameters.Tx=Param.Tx(:,thisIdx,:);
            psObj(psIdx).Pulse(pIdx).Parameters.TxMin=Param.TxMin(:,thisIdx,:);
            psObj(psIdx).Pulse(pIdx).Parameters.TxMax=Param.TxMax(:,thisIdx,:);
        end


        if NumTC==2||~UseLoadData||UpdateEndingEm
            psObj(psIdx).Pulse.estimateRelaxationTau(varargin{:});
        end


        if UpdateEndingEm
            for pIdx=1:(psObj(psIdx).NumPulses-1)
                if psObj(psIdx).Pulse(pIdx).IsDischarge
                    NewEm=psObj(psIdx).Pulse(pIdx).Parameters.Em(1);
                else
                    NewEm=psObj(psIdx).Pulse(pIdx).Parameters.Em(2);
                end
                if psObj(psIdx).Pulse(pIdx+1).IsDischarge
                    psObj(psIdx).Pulse(pIdx+1).Parameters.Em(2)=NewEm;
                else
                    psObj(psIdx).Pulse(pIdx+1).Parameters.Em(1)=NewEm;
                end
            end
        end






        if NumTC==2||UseLoadData
            psObj(psIdx).Pulse.estimateLoadTau(varargin{:});
        end







        PParam=[psObj(psIdx).Pulse.Parameters];
        AllTx=reshape([PParam.Tx],NumRC,2,[],NumTC);
        AllTx=squeeze(AllTx(:,1,:,:));




        Param.Tx(:,socIdx(2:end),:)=AllTx;
        Param.Tx(:,socIdx(1),:)=Param.Tx(:,socIdx(2),:);





        if UpdateEndingEm
            AllEm=reshape([PParam.Em],2,[]);
            AllEm1=AllEm(1,:);
            AllEm2=AllEm(2,:);
            AllEm=[AllEm2(1),(AllEm2(2:end)+AllEm1(1:end-1))/2,AllEm1(end)];

            Param.Em=AllEm(1,socIdx);
        end


        psObj(psIdx).Parameters=Param;

    end
