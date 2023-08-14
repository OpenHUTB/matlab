function elabConnectMultiToOutput(this,hN,inSig,totalLatency,blockInfo)%#ok<INUSL>






    outSig=hN.PirOutputSignals;



    dtcOutType=outSig(1).Type;
    dtcOutName=[inSig(1).Name,'_conv'];
    dtcOutSig=hN.addSignal(dtcOutType,dtcOutName);

    dataSplit=inSig(1).split.PirOutputSignals;

    for ii=1:1:blockInfo.NumberOfPixels
        dtcOutSigSc(ii)=hN.addSignal(dtcOutType.BaseType,[dtcOutName,num2str(ii)]);%#ok<*AGROW> 

        pirelab.getDTCComp(hN,dataSplit(ii),dtcOutSigSc(ii),...
        blockInfo.RoundingMethod,blockInfo.OverflowAction);
    end

    pirelab.getMuxComp(hN,dtcOutSigSc(:),dtcOutSig);


    pirelab.getUnitDelayComp(hN,dtcOutSig,outSig(1),'dataOut');


    totalLatency=totalLatency+1;









    deComment={'Delay Pixel',...
    'Delay Horizontal Start',...
    'Delay Horizontal End',...
    'Delay Vertical Start',...
    'Delay Vertical End',...
    'Delay Valid'};

    kernelTapLatency=floor(double(blockInfo.NumMatrices)/2);
    nonKernelLatency=totalLatency-(floor(blockInfo.KernelWidth/2));
    processData=inSig(7);

    dlyType=outSig(2).Type;
    validKernelREG=hN.addSignal(dlyType,'validKernelREG');
    validREG=hN.addSignal(dlyType,'validREG');
    for ii=2:numel(outSig)
        if strcmpi(blockInfo.PaddingMethodString,'None')


            dlyName=[inSig(ii).Name,'_reg'];
            dlySig(ii)=hN.addSignal(dlyType,dlyName);

            if ii==3||ii==5
                de1=pirelab.getIntDelayComp(hN,inSig(ii),dlySig(ii),kernelTapLatency,...
                [outSig(ii).Name,'_tap_latency']);
                de1.addComment(deComment{ii-1});
            elseif ii==6
                pirelab.getUnitDelayEnabledResettableComp(hN,inSig(3),validREG,inSig(3),dlySig(3),'validREG',0,'',true,'',-1,true);

                de1=pirelab.getIntDelayEnabledResettableComp(hN,inSig(ii),validKernelREG,processData,inSig(3),kernelTapLatency,...
                [outSig(ii).Name,'_tap_latency']);
                de1.addComment(deComment{ii-1});

                pirelab.getLogicComp(hN,[validKernelREG,validREG],dlySig(ii),'or');
            else
                de1=pirelab.getIntDelayEnabledComp(hN,inSig(ii),dlySig(ii),processData,kernelTapLatency,...
                [outSig(ii).Name,'_tap_latency']);
                de1.addComment(deComment{ii-1});
            end




            pickSigType=dlyType;
            pickSigName=[dlySig(ii).Name,'_vldSig'];
            pickSig(ii)=hN.addSignal(pickSigType,pickSigName);
            processOREndLine=hN.addSignal(dlyType,'processOREndLine');
            pirelab.getLogicComp(hN,[processData,validREG],processOREndLine,'or');
            pirelab.getLogicComp(hN,[dlySig(ii),processOREndLine],pickSig(ii),'and');
...
...
...
...
...
...
...
...
...
...
...
...
...


            de2=pirelab.getIntDelayComp(hN,pickSig(ii),outSig(ii),nonKernelLatency,...
            [outSig(ii).Name,'_fir_latency']);
            de2.addComment(deComment{ii-1});

        else



            dlyName=[inSig(ii).Name,'_reg'];
            dlySig=hN.addSignal(dlyType,dlyName);

            de1=pirelab.getIntDelayEnabledComp(hN,inSig(ii),dlySig,processData,kernelTapLatency,...
            [outSig(ii).Name,'_tap_latency']);
            de1.addComment(deComment{ii-1});




            pickSigType=dlyType;
            pickSigName=[dlySig.Name,'_vldSig'];
            pickSig=hN.addSignal(pickSigType,pickSigName);
            pirelab.getLogicComp(hN,[dlySig,processData],pickSig,'and');
...
...
...
...
...
...
...
...
...
...
...
...
...


            de2=pirelab.getIntDelayComp(hN,pickSig,outSig(ii),nonKernelLatency,...
            [outSig(ii).Name,'_fir_latency']);
            de2.addComment(deComment{ii-1});
        end
    end

end
