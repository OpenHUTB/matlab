function v=validateBlock(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        v=hdlvalidatestruct;
        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
        insig=hC.PirInputSignals(1);
        frameMode=(hdlissignaltype(insig,'column_vector')||...
        hdlissignaltype(insig,'unordered_vector'))&&...
        ~hdlissignaltype(insig,'scalar');
        if frameMode&&nfpMode


            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcommon:nativefloatingpoint:IntDelayFrameMode'));
        end


        if hC.PirOutputSignals(1).Type.isMatrix
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:matrix:IntDelayFrameMode'));
        end
    else
        v=hdlimplbase.EmlImplBase.validateRegisterRates(hC);

        [~,~,hasExtEnable,~,~,extrtype,rambased,isVarDelay,~]=...
        getBlockInfo(this,hC);

        if~isempty(rambased)&&strcmpi(rambased,'on')
            rambased=true;
        else
            rambased=false;
        end
        slbh=hC.SimulinkHandle;

        hasExtReset=~strcmpi(extrtype,'None');

        if(strcmp(hdlfeature('VarDelaySupport'),'off'))
            v=checkParam(v,slbh,'DelayLengthSource','Dialog','hdlcoder:validate:IntDelayDelaylen');
        else

            if(rambased&&isVarDelay)
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:RAMBasedVariableDelay'));
            end

            if(isVarDelay&&(~hdlissignaltype(hC.PirInputSignals(1),'scalar')...
                ||~hdlissignaltype(hC.PirInputSignals(2),'scalar')))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VectorInputVariableDelay'));
            end

            if(isVarDelay&&hC.PirInputSignals(1).Type.isRecordType)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:VariableDelayRecordType'));
            end
        end



        if hasExtReset
            if hasExtEnable
                delayType=hdldelaytypeenum.DelayEnabledResettable;
            else
                delayType=hdldelaytypeenum.DelayResettable;
            end


            if(isVarDelay)
                delayType=convertToVariableDelay(delayType);
            end


            x0Port=~strcmp(get_param(slbh,'InitialConditionSource'),'Dialog');
            extent=numel(hC.PirInputSignals)-x0Port;


            hExtRstSignal=delayType.getRstSignal(hC.PirInputSignals(1:extent));
            extRstType=hExtRstSignal.Type;
            isExtResetUfix1=extRstType.isWordType&&extRstType.Signed==0&&...
            extRstType.WordLength==1&&extRstType.FractionLength==0;
            if~extRstType.isBooleanType&&~isExtResetUfix1
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IntDelayExtResetType'));
            end
        elseif hasExtEnable
            delayType=hdldelaytypeenum.DelayEnabled;

            if(isVarDelay)
                delayType=convertToVariableDelay(delayType);
            end
        end

        if hasExtEnable

            hExtEnbSignals=delayType.getEnbSignals(hC.PirInputSignals);
            for ii=1:length(hExtEnbSignals)
                extEnbType=hExtEnbSignals(ii).Type;
                isExtEnbUfix1=extEnbType.isWordType&&extEnbType.Signed==0&&...
                extEnbType.WordLength==1&&extEnbType.FractionLength==0;
                if~extEnbType.isBooleanType&&~isExtEnbUfix1
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IntDelayExtEnableType'));%#ok<AGROW>
                end
            end
        end

        hwFriendly=this.isInHwFriendly(hC);
        hN=hC.Owner;
        hwSemantics=hwFriendly||hN.hasSLHWFriendlySemantics;
        numDelays=hdlslResolve('NumDelays',slbh);
        if~hwSemantics&&hasExtEnable&&numDelays==0
            compPath=[hC.Owner.FullPath,'/',hC.Name];
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:Classic0DelayEn',compPath));
        end


        ipmode=get_param(hC.SimulinkHandle,'InputProcessing');
        nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
        frameMode=this.isFrameProcessing(hC,ipmode);

        if hwFriendly



            v=checkParam(v,slbh,'ExternalReset',{'None','Level hold'},...
            'hdlcoder:validate:IntDelayExternalResetSync');
        elseif nfpMode&&frameMode


            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcommon:nativefloatingpoint:IntDelayFrameMode'));
        else
            v=checkParam(v,slbh,'ExternalReset',{'None','Level'},...
            'hdlcoder:validate:IntDelayExternalResetClassic');
        end




        if frameMode&&(hasExtReset||hasExtEnable)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:IntDelayFrameModeResetEnable'));
        end



        if contains(get_param(slbh,'InputProcessing'),'frame')&&...
            hC.PirOutputSignals(1).Type.isMatrix
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:matrix:IntDelayFrameMode'));
        end

        if hC.Owner.hasResettableInstances&&rambased
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IntDelayRAMResetSS'));
        elseif~hasExtReset

            ic=this.getInitialValue(hC,slbh);
            if rambased&&~isempty(ic)&&all(ic)
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IntDelayRAMIC'));
            end
        elseif rambased
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IntDelayRAMExtReset'));
        end

        if rambased&&hasExtEnable
            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:IntDelayRAMEnable'));
        end

        v=hdlimplbase.EmlImplBase.baseValidateRegister(v,hC);

        v=checkParam(v,slbh,'InitialConditionSource','Dialog','hdlcoder:validate:IntDelayIC');


    end
end


function v=checkParam(v,slbh,param,expectedValues,errmsg)
    slbParamValue=get_param(slbh,param);
    isMatched=any(strcmp(expectedValues,slbParamValue));

    if~isMatched
        v(end+1)=hdlvalidatestruct(1,message(errmsg));
    end
end


