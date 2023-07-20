function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);


    inportnames={};
    outportnames={};

    inportnames{1}='In';
    inportnames{2}='validIn';

    if blockInfo.outMode(1)
        outportnames{1}='magnitude';
        outportnames{2}='validOut';

    elseif blockInfo.outMode(2)
        outportnames{1}='angle';
        outportnames{2}='validOut';

    elseif blockInfo.outMode(3)
        outportnames{1}='magnitude';
        outportnames{2}='angle';
        outportnames{3}='validOut';

    end

    inSig=hC.PirInputSignals;
    if hdlissignalscalar(inSig(1))


        topNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'Name','HDL_CMA_core',...
        'RefComponent',hC,...
        'InportNames',inportnames,...
        'OutportNames',outportnames...
        );

        validNet=topNet;
        validIn=topNet.PirInputSignals(2);
        validOut=topNet.PirOutputSignals(end);
    else
        topNetVec=pirelab.createNewNetworkWithInterface(...
        'Name','HDL_CMA_vector',...
        'Network',hN,...
        'RefComponent',hC,...
        'InportNames',inportnames,...
        'OutportNames',outportnames...
        );

        topNetVec.addComment('Complex to Magnitude-Angle - core instantion for vector support');


        core_inportnames=inportnames;
        core_inportnames{end}='resetIn';
        core_outportnames=outportnames(1:end-1);


        core_inporttypes(1)=inSig(1).Type.BaseType;
        core_inporttypes(2)=inSig(2).Type;


        core_inportrates=repmat(inSig(1).SimulinkRate,1,2);

        outSig=hC.PirOutputSignals;
        core_numOutSig=numel(outSig)-1;

        core_outporttypes=repmat(outSig(1).Type.BaseType,1,core_numOutSig);
        for ii=2:core_numOutSig
            core_outporttypes(ii)=outSig(ii).Type.BaseType;
        end


        topNet=pirelab.createNewNetwork(...
        'Network',topNetVec,...
        'Name','HDL_CMA_core',...
        'InportNames',core_inportnames,...
        'InportTypes',core_inporttypes,...
        'InportRates',core_inportrates,...
        'OutportNames',core_outportnames,...
        'OutportTypes',core_outporttypes...
        );

        validNet=topNetVec;
        validIn=topNetVec.PirInputSignals(2);
        validOut=topNetVec.PirOutputSignals(end);
    end

    topNet.addComment('Complex to Magnitude-Angle');



    if blockInfo.outMode(1)
        resetIn=this.elaborateCORDICMag(topNet,blockInfo,validNet,validIn,validOut);
    elseif blockInfo.outMode(2)
        resetIn=this.elaborateCORDICAngle(topNet,blockInfo,validNet,validIn,validOut);
    elseif blockInfo.outMode(3)
        resetIn=this.elaborateCORDICMagAngle(topNet,blockInfo,validNet,validIn,validOut);
    end


    if hdlissignalscalar(inSig(1))


        for ii=1:numel(hC.PirInputSignals)
            topNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
        end
        for ii=1:numel(hC.PirOutputSignals)
            topNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
        end
        nComp=pirelab.instantiateNetwork(hN,topNet,...
        hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
    else
        inVecSig=topNetVec.PirInputSignals;
        outVecSig=topNetVec.PirOutputSignals;

        vecSize=inVecSig(1).Type.Dimensions;
        in1Sigs=inVecSig(1).split.PirOutputSignals;
        outSigTypes=[];

        for ii=1:core_numOutSig
            outSigTypes=[outSigTypes;outVecSig(ii).Type.BaseType];%#ok<AGROW>
        end
        for ii=1:vecSize
            for jj=1:core_numOutSig

                tempOutSig(jj,ii)=topNetVec.addSignal2('Type',outSigTypes(jj),...
                'Name',[topNetVec.PirOutputPorts(jj).Name,'_',num2str(ii-1)],...
                'SimulinkRate',inSig(1).SimulinkRate);%#ok<AGROW>
            end

            outDataSigs=tempOutSig(:,ii);
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


            inDataSigs=[in1Sigs(ii);resetIn];
            pirelab.instantiateNetwork(topNetVec,topNet,...
            inDataSigs,outDataSigs,[hC.Name,'_',num2str(ii-1)]);
        end



        for ii=1:core_numOutSig
            pirelab.getMuxComp(topNetVec,tempOutSig(ii,:),outVecSig(ii),['outMux_',num2str(ii)]);
        end

        for ii=1:numel(hC.PirInputSignals)
            topNetVec.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
        end
        for ii=1:numel(hC.PirOutputSignals)
            topNetVec.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
        end
        nComp=pirelab.instantiateNetwork(hN,topNetVec,...
        hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

    end

end
