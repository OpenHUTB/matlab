function adderComp=getAddComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,accumType,inputSigns,desc,slbh,...
    nfpOptions,traceComment)



    if nargin<12
        traceComment='';
    end

    if nargin<11
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if~isfield(nfpOptions,'CustomLatency')
        nfpOptions.CustomLatency=int8(0);
    end

    if nargin<10
        slbh=-1;
    end

    if nargin<9
        desc='';
    end

    if nargin<8
        inputSigns='++';
    end

    if nargin<7
        accumType=[];
    end

    if nargin<6
        compName='adder';
    end

    if nargin<5
        satMode='Wrap';
    end

    if nargin<4
        rndMode='Floor';
    end

    numInputPorts=numel(hInSignals);
    nDims=1;


    assert((numel(inputSigns)==numInputPorts),...
    'The total number of inputs should match total number of signs');


    if hInSignals(1).Type.isMatrix&&(numInputPorts==1)

        [hCInputSignals,~,hOutSignals,~,nDims]=splitMatrix2SpecifiedDims(hN,hInSignals,hOutSignals);
    else


        if(length(inputSigns)>=2)&&(inputSigns(1)=='-')&&contains(inputSigns,'+')
            hCInputSignals=hdlhandles(1,numel(hInSignals));
            sz=length(inputSigns);
            for ii=2:sz
                if(inputSigns(ii)=='+')

                    inputSigns(ii)='-';
                    inputSigns(1)='+';


                    hCInputSignals(1)=hInSignals(ii);
                    for kk=2:ii

                        hCInputSignals(kk)=hInSignals(kk-1);
                    end
                    for kk=ii+1:sz

                        hCInputSignals(kk)=hInSignals(kk);
                    end
                    break;
                end
            end
        else
            hCInputSignals=hInSignals;
        end
    end


    for ii=1:nDims
        sum_out=hOutSignals(ii);
        if numInputPorts==1

            sum_in=hCInputSignals(ii);
        else

            sum_in=hCInputSignals;
        end

        if strcmp(inputSigns,'-')&&(numInputPorts==1)&&(prod(sum_in.Type.getDimensions)==1)

            adderComp=pirelab.getUnaryMinusComp(hN,sum_in,sum_out,satMode,[compName,'_uminus']);
        else

            adderComp=elaborate_addComp(hN,sum_in,sum_out,rndMode,satMode,compName,accumType,inputSigns,...
            desc,slbh,nfpOptions,traceComment);
        end
    end

end

function adderComp=elaborate_addComp(hN,hInSignals,hOutSignal,rndMode,satMode,compName,accumType,inputSigns,...
    desc,slbh,nfpOptions,traceComment)

    inSigs=pirelab.convertRowVecsToUnorderedVecs(hN,hInSignals);
    numInSigs=numel(inSigs);

    if numInSigs==1&&inSigs.Type.isArrayType&&hOutSignal.Type.isArrayType

        if isempty(accumType)
            accumType=hOutSignal.Type;
        end
        accumTp=pirelab.getTypeInfoAsFi(accumType,rndMode,satMode);
        if isfloat(accumTp)
            rmode=[];
            omode=[];
        else
            rmode=accumTp.RoundMode;
            omode=accumTp.OverflowMode;
        end
        if strcmp(inputSigns,'+')
            adderComp=pirelab.getDTCComp(hN,inSigs,hOutSignal,rmode,omode);
        else
            adderComp=pirelab.getUnaryMinusComp(hN,inSigs,hOutSignal,omode);
        end
    elseif(numel(inputSigns)==1&&numInSigs==1)
        adderComp=elaborate_soe2CoreComp(hN,inSigs,hOutSignal,rndMode,satMode,compName,...
        accumType,inputSigns,desc,slbh,nfpOptions);
    else
        if(length(inputSigns)==2)
            if targetmapping.mode(hOutSignal)

                adderComp=targetmapping.getTwoInputAddComp(hN,inSigs,hOutSignal,...
                rndMode,satMode,compName,accumType,inputSigns,desc,slbh,nfpOptions);
                adderComp.addTraceabilityComment(traceComment);
            else
                adderComp=pircore.getAddComp(hN,inSigs,hOutSignal,...
                rndMode,satMode,compName,accumType,inputSigns,desc,...
                slbh,nfpOptions);
                adderComp.addTraceabilityComment(traceComment);
            end
        else

            adderComp=pirelab.getAddTreeComp(hN,inSigs,hOutSignal,...
            rndMode,satMode,compName,accumType,inputSigns,desc,...
            slbh,nfpOptions);
        end
    end
end

function soeComp=elaborate_soe2CoreComp(hN,inSigs,hOutSignal,rndMode,satMode,compName,...
    accumType,inputSigns,desc,slbh,nfpOptions)

    if inSigs(1).Type.isArrayType
        splitSignalComp=inSigs.split;
        inSigs=splitSignalComp.PirOutputSignals;
        if strcmp(inputSigns,'-')


            if numel(inSigs)==2
                soeComp=pirelab.getAddTreeComp(hN,[inSigs(1),inSigs(2)],hOutSignal,...
                rndMode,satMode,compName,accumType,'--',desc,slbh,nfpOptions);
                return;
            else


                op_stage_outSig=hN.addSignal(hOutSignal.Type,[compName,'_op_stage']);
                op_stage_outSig.SimulinkRate=hOutSignal.SimulinkRate;
                pirelab.getAddTreeComp(hN,[inSigs(1),inSigs(2)],op_stage_outSig,...
                rndMode,satMode,compName,accumType,'--',desc,slbh,nfpOptions);




                inSigs=[op_stage_outSig;inSigs(3:numel(inSigs))];
                inputSigns=['+',repmat('-',[1,numel(inSigs)-1])];
            end
        else

            inputSigns=repmat('+',[1,numel(inSigs)]);
        end
    end

    if(numel(inSigs)==1)
        soeComp=pircore.getAddComp(hN,inSigs,hOutSignal,...
        rndMode,satMode,compName,accumType,inputSigns,desc,slbh,nfpOptions);
    else
        soeComp=pirelab.getAddTreeComp(hN,inSigs,hOutSignal,...
        rndMode,satMode,compName,accumType,inputSigns,desc,slbh,nfpOptions);
    end
end


