function[outputsig,validout,delay]=elabInlineGainSum(this,net,blockInfo,numerator,delayline,validin,name,genValid)




    if nargin==7
        genValid=true;
    end

    if blockInfo.FrameSize==1
        numFilts=1;
    else
        numFilts=2;
    end
    Ntaps=numel(numerator);
    delay=0;
    inputRate=validin.SimulinkRate;
    ctrlType=pir_boolean_t();


    for currentFilt=1:numFilts

        if blockInfo.FrameSize==1
            tapName=name;
            offset=0;
        else
            if currentFilt==1
                tapName=[name,'high'];
                offset=blockInfo.FrameSize-1;
            else
                tapName=[name,'low'];
                offset=blockInfo.FrameSize;
            end
        end

        for ii=1:Ntaps
            currentTap=int2str(ii+offset);
            currentName=[currentTap,tapName];
            if Ntaps==1
                dlSig=delayline;
            else
                dlSig=indexSignal(delayline,ii+offset);
            end
            gainOut(ii)=this.elabPipeGain(net,blockInfo,numerator(ii),dlSig,validin,currentName);%#ok
        end
        if currentFilt==1
            delay=delay+4;
        end

        if Ntaps==1
            outputsig(currentFilt)=gainOut(1);%#ok
        else
            sumVect=gainOut;
            Levels=ceil(log2(Ntaps));
            for l=1:Levels
                N=numel(sumVect);
                i=1;
                for p=1:2:N
                    newSumType=net.getType('FixedPoint','Signed',true,...
                    'WordLength',sumVect(1).Type.WordLength+1,...
                    'FractionLength',sumVect(1).Type.FractionLength);
                    regOutSig=net.addSignal(newSumType,[sprintf('sumregL%dV%d',l,i),tapName]);
                    regOutSig.SimulinkRate=inputRate;
                    regOut(i)=regOutSig;%#ok
                    sumOut=net.addSignal(newSumType,[sprintf('sumL%dV%d',l,i),tapName]);
                    if p~=N
                        pirelab.getAddComp(net,[sumVect(p),sumVect(p+1)],sumOut);
                    else
                        pirelab.getDTCComp(net,sumVect(p),sumOut,'Floor','Wrap');
                    end
                    pirelab.getUnitDelayEnabledComp(net,sumOut,regOut(i),validin,[sprintf('sumL%dV%dReg',l,i),tapName]);
                    i=i+1;
                end
                if currentFilt==1
                    delay=delay+1;
                end
                sumVect=regOut(1:i-1);
            end
            outputsig(currentFilt)=regOut(1);%#ok
        end
    end
    delay=delay+1;
    validout=validin;


    function val=indexSignal(signal,index)
        if numel(signal)>1
            val=signal(index);
        else
            val=signal.PirOutputSignals(index);
        end
    end


end
