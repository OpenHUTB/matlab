function delayComp=getFrameBasedIntDelayComp(hN,hInSignals,hOutSignals,delayNumber,compName,ic,resetType,hasExtEnable,extResetType,ramBased,isDefaultHwSemantics,desc,slHandle,isFrameProcessing)








    if(nargin<13)
        slHandle=-1;
    end

    if(nargin<12)
        desc='';
    end

    if(nargin<11)
        isDefaultHwSemantics=true;
    end

    if(nargin<10)
        ramBased=false;
    end



    if(nargin<9)
        extResetType='';
    end

    if(nargin<8)
        hasExtEnable=false;
    end

    if(nargin<7)
        resetType='';
    end

    if(nargin<6)
        ic=0;
    end

    if(nargin<5)
        compName='intdelay';
    end

    hasExtReset=~isempty(extResetType);

    if hasExtEnable&&hasExtReset
        delayType=hdldelaytypeenum.DelayEnabledResettable;
    elseif hasExtEnable&&~hasExtReset
        delayType=hdldelaytypeenum.DelayEnabled;
    elseif~hasExtEnable&&hasExtReset
        delayType=hdldelaytypeenum.DelayResettable;
    else
        delayType=hdldelaytypeenum.Delay;
    end

    if isDefaultHwSemantics&&delayType~=hdldelaytypeenum.Delay
        hN.setHasSLHWFriendlySemantics(true);
    end

    if delayNumber==0
        hDinSignal=hInSignals(1);




        hwSemantics=hN.hasSLHWFriendlySemantics||hN.getWithinHWFriendlyHierarchy;
        if~hwSemantics&&...
            (delayType==hdldelaytypeenum.DelayEnabled||...
            delayType==hdldelaytypeenum.DelayEnabledResettable)
            hExtEnbSignal=delayType.getEnbSignals(hInSignals);
            delayComp=pirelab.getSwitchComp(hN,[hDinSignal,hOutSignals],...
            hOutSignals,hExtEnbSignal,[compName,'_enb'],'==',1);%#ok
            compPath=[hN.FullPath,'/',compName];
            error(message('hdlcoder:validate:Classic0DelayEn',compPath));
        else
            delayComp=pirelab.getWireComp(hN,hDinSignal,hOutSignals,...
            compName,desc,slHandle);
        end
    else
        delayComp=elabIntDelayFrameProccesing(hN,hInSignals,hOutSignals,...
        delayNumber,compName,ic,resetType,hasExtEnable,extResetType,ramBased,false);
    end


    function idComp=elabIntDelayFrameProccesing(hN,hInSignals,hOutSignals,numDelays,compName,...
        ic,resetType,hasExtEnable,extResetType,rambased,false)

        inVectSize=hInSignals(1).Type.Dimensions;
        if numDelays==0
            idComp=pirelab.getWireComp(hN,hInSignals,hOutSignals);
        elseif numDelays==inVectSize
            idComp=pirelab.getIntDelayComp(hN,hInSignals,hOutSignals,1,...
            compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
        elseif numDelays<inVectSize
            dataInType=pirgetdatatypeinfo(hInSignals(1).Type);
            iscomplex=dataInType.iscomplex;
            signed=dataInType.issigned;
            WLength=dataInType.wordsize;
            FLength=dataInType.binarypoint;
            numDims='1';
            indexMode='Zero-based';
            indexOptionArray={'Index vector (dialog)'};
            outputSizeArray={'1'};

            if iscomplex
                sigType=pir_complex_t(hN.getType('FixedPoint','Signed',signed,...
                'WordLength',WLength,'FractionLength',FLength));
            else
                sigType=hN.getType('FixedPoint','Signed',signed,...
                'WordLength',WLength,'FractionLength',FLength);
            end
            if(inVectSize-numDelays)==1
                sliceVec1Type=sigType;
            else
                sliceVec1Type=hN.getType('Array','BaseType',sigType,'Dimensions',inVectSize-numDelays);
            end
            if(numDelays)==1
                sliceVec2Type=sigType;
            else
                sliceVec2Type=hN.getType('Array','BaseType',sigType,'Dimensions',numDelays);
            end

            sliceVec1=hN.addSignal2('Name','sliceVec1','Type',sliceVec1Type);
            sliceVec2=hN.addSignal2('Name','sliceVec2','Type',sliceVec2Type);
            sliceVec2Reg=hN.addSignal2('Name','sliceVec2Reg','Type',sliceVec2Type);


            indexParamArray={(0:1:inVectSize-numDelays-1)};
            pirelab.getSelectorComp(hN,hInSignals(1),sliceVec1,...
            indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims,compName);
            indexParamArray={(inVectSize-numDelays:1:inVectSize-1)};
            pirelab.getSelectorComp(hN,hInSignals(1),sliceVec2,...
            indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims,compName);

            if hasExtEnable
                pirelab.getIntDelayComp(hN,[sliceVec2,hInSignals(2)],sliceVec2Reg,1,...
                compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
            else
                pirelab.getIntDelayComp(hN,sliceVec2,sliceVec2Reg,1,...
                compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
            end

            idComp=pirelab.getConcatenateComp(hN,[sliceVec2Reg,sliceVec1],hOutSignals,'Vector','1');
        else
            dataInType=pirgetdatatypeinfo(hInSignals(1).Type);
            iscomplex=dataInType.iscomplex;
            signed=dataInType.issigned;
            WLength=dataInType.wordsize;
            FLength=dataInType.binarypoint;
            numDims='1';
            indexMode='Zero-based';
            indexOptionArray={'Index vector (dialog)'};
            outputSizeArray={'1'};

            partialDelays=mod(numDelays,inVectSize);
            additionalDelay=floor(double(numDelays)/double(inVectSize));

            if iscomplex
                sigType=pir_complex_t(hN.getType('FixedPoint','Signed',signed,...
                'WordLength',WLength,'FractionLength',FLength));
            else
                sigType=hN.getType('FixedPoint','Signed',signed,...
                'WordLength',WLength,'FractionLength',FLength);
            end

            if(inVectSize-partialDelays)==1
                sliceVec1Type=sigType;
            else
                sliceVec1Type=hN.getType('Array','BaseType',sigType,'Dimensions',inVectSize-partialDelays);
            end

            concatVecType=hN.getType('Array','BaseType',sigType,'Dimensions',inVectSize);
            concatVec=hN.addSignal2('Name','concatVec','Type',concatVecType);

            if partialDelays==0
                pirelab.getWireComp(hN,hInSignals,concatVec);
            else
                if(partialDelays)==1
                    sliceVec2Type=sigType;
                else
                    sliceVec2Type=hN.getType('Array','BaseType',sigType,'Dimensions',partialDelays);
                end

                sliceVec1=hN.addSignal2('Name','sliceVec1','Type',sliceVec1Type);
                sliceVec2=hN.addSignal2('Name','sliceVec2','Type',sliceVec2Type);
                sliceVec2Reg=hN.addSignal2('Name','sliceVec2Reg','Type',sliceVec2Type);


                indexParamArray={(0:1:inVectSize-partialDelays-1)};
                pirelab.getSelectorComp(hN,hInSignals(1),sliceVec1,...
                indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims,compName);
                indexParamArray={(inVectSize-partialDelays:1:inVectSize-1)};
                pirelab.getSelectorComp(hN,hInSignals(1),sliceVec2,...
                indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims,compName);

                if hasExtEnable
                    pirelab.getIntDelayComp(hN,[sliceVec2,hInSignals(2)],sliceVec2Reg,1,...
                    compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
                else
                    pirelab.getIntDelayComp(hN,sliceVec2,sliceVec2Reg,1,...
                    compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
                end

                pirelab.getConcatenateComp(hN,[sliceVec2Reg,sliceVec1],concatVec,'Vector',1);
            end

            for loop=1:additionalDelay
                outSignal(loop)=hN.addSignal2('Name',['outSignal_',int2str(loop)],'Type',concatVecType);%#ok<AGROW>
                if hasExtEnable
                    pirelab.getIntDelayComp(hN,[concatVec,hInSignals(2)],outSignal(loop),1,...
                    compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
                else
                    pirelab.getIntDelayComp(hN,concatVec,outSignal(loop),1,...
                    compName,ic,resetType,hasExtEnable,extResetType,rambased,false);
                end
                concatVec=outSignal(loop);
            end

            idComp=pirelab.getWireComp(hN,outSignal(additionalDelay),hOutSignals);
        end
