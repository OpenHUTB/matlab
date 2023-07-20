function[ResultDescription,ResultHandles]=execCheckBlockSpecificQuestionableFixedPoint(system)




    ResultHandles={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    mdladvObj.setCheckResultStatus(false);
    ResultDescription={};
    system=getfullname(system);

    results{1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{1}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpSumBlockCheckTitle'));
    results{1}.setSubBar(false);


    results_sum_blk=check_sum_blocks(system);
    if~isempty(results_sum_blk)
        results{1}.setSubResultStatus('warn');
    else
        results{1}.setSubResultStatus('pass');
    end
    results=[results,results_sum_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpRelopBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_relop_blk=check_relop_blocks(system);
    if~isempty(results_relop_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_relop_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpConversionBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_conversion_blk=check_conversion_blocks(system);
    if~isempty(results_conversion_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_conversion_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);



    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpSwitchBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_switch_blk=check_switch_blocks(system);
    if~isempty(results_switch_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_switch_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpLogicBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_logic_blk=check_logic_blocks(system);
    if~isempty(results_logic_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_logic_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpSaturateBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_saturate_blk=check_saturate_blocks(system);
    if~isempty(results_saturate_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_saturate_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpMinMaxBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_minmax_blk=check_minmax_blocks(system);
    if~isempty(results_minmax_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_minmax_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpDIntBlockCheckTitle'));
    results{end}.setSubBar(false);
    results_dint_blk=check_dintegrate_blocks(system);
    if~isempty(results_dint_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_dint_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckCompToContBlockTitle'));
    results{end}.setSubBar(false);
    results_cmp_blk=check_cmptoconst_blocks(system);
    if~isempty(results_cmp_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_cmp_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckLookupBlockTitle'));
    results{end}.setSubBar(false);
    results_lookup_blk=check_lookuptable_blocks(system);
    if~isempty(results_lookup_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_lookup_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckIntDivNetSlopeTitle'));
    results{end}.setSubBar(false);
    results_int_div_netslope=check_int_div_netslope(system,mdladvObj);
    if~isempty(results_int_div_netslope)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_int_div_netslope];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckMultipleOpSingleBlockTitle'));
    results{end}.setSubBar(false);
    results_multipleops_single_blk=check_multipleops_single_blk(system,mdladvObj);
    if~isempty(results_multipleops_single_blk)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_multipleops_single_blk];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);


    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckSaturationTitle'));
    results{end}.setSubBar(false);
    results_exp_sat=checkExpensiveSaturation(system);
    if~isempty(results_exp_sat)
        results{end}.setSubResultStatus('warn');
    else
        results{end}.setSubResultStatus('pass');
    end
    results=[results,results_exp_sat];

    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
    results{end}.setSubBar(true);

    ResultDescription=[ResultDescription,results];

    mdladvObj.setCheckResultStatus(getResultsStatus(ResultDescription));


    function results=check_relop_blocks(curModel)
        results={};
        relopInputBiasResults={};
        relopInputSlopeResults={};
        relopOutputBiasResults={};
        relopOutputSlopeResults={};

        foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','RelationalOperator');
        for iBlk=1:length(foundBlks)
            curBlk=foundBlks{iBlk};
            pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
            nOps=length(pdt.Inport);
            fxpPropY=getFixptProps(pdt.Outport{1});

            if(fxpPropY.Bias~=0)
                relopOutputBiasResults{end+1}=curBlk;
            end

            if(fxpPropY.SlopeAdjustmentFactor~=1)
                relopOutputSlopeResults{end+1}=curBlk;
            end
            fxpPropUBias=[];
            fxpPropUSaf=[];

            for iOps=1:nOps
                fxpPropU=getFixptProps(pdt.Inport{iOps});
                if(isempty(fxpPropUBias))
                    fxpPropUBias=fxpPropU.Bias;
                else
                    if(fxpPropU.Bias~=fxpPropUBias)
                        relopInputBiasResults{end+1}=curBlk;
                    end
                end

                if(isempty(fxpPropUSaf))
                    fxpPropUSaf=fxpPropU.SlopeAdjustmentFactor;
                else
                    if(fxpPropU.SlopeAdjustmentFactor~=fxpPropUSaf)
                        relopInputSlopeResults{end+1}=curBlk;
                    end
                end
            end
        end

        if~isempty(relopInputBiasResults)
            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelopMismatchBias'));
            currResult.setListObj(relopInputBiasResults);
            currResult.setSubBar(false);
            results{end+1}=currResult;
        end

        if~isempty(relopInputSlopeResults)
            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_MismatchSlope'));
            currResult.setListObj(relopInputSlopeResults);
            currResult.setSubBar(false);
            results{end+1}=currResult;
        end

        if~isempty(relopOutputBiasResults)
            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelopOutputBiasNotZero'));
            currResult.setListObj(relopOutputBiasResults);
            currResult.setSubBar(false);
            results{end+1}=currResult;
        end

        if~isempty(relopOutputSlopeResults)
            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelopOutputSlopeNotOne'));
            currResult.setListObj(relopOutputSlopeResults);
            currResult.setSubBar(false);
            results{end+1}=currResult;
        end


        function results=check_conversion_blocks(curModel)
            results={};
            conversionInputBiasResults={};
            conversionInputSlopeResults={};

            foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','SubSystem');
            for iBlk=1:length(foundBlks)

                curBlk=foundBlks{iBlk};
                maskType=get_param(curBlk,'MaskType');
                if(strcmp(maskType,'Conversion Inherited'))
                    pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');

                    fxpPropU=getFixptProps(pdt.Inport{1});
                    fxpPropUBias1=fxpPropU.Bias;
                    fxpPropUSaf1=fxpPropU.SlopeAdjustmentFactor;

                    fxpPropU=getFixptProps(pdt.Inport{2});
                    fxpPropUBias2=fxpPropU.Bias;
                    fxpPropUSaf2=fxpPropU.SlopeAdjustmentFactor;

                    if(fxpPropUBias1~=fxpPropUBias2)
                        conversionInputBiasResults{end+1}=curBlk;
                    end

                    if(fxpPropUSaf1~=fxpPropUSaf2)
                        conversionInputSlopeResults{end+1}=curBlk;
                    end
                end
            end

            if~isempty(conversionInputBiasResults)
                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckConversionInheritedMismatchBias'));
                currResult.setListObj(conversionInputBiasResults);
                currResult.setSubBar(false);
                results{end+1}=currResult;
            end

            if~isempty(conversionInputSlopeResults)
                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckConversionInherited_MismatchSlope'));
                currResult.setListObj(conversionInputSlopeResults);
                currResult.setSubBar(false);
                results{end+1}=currResult;
            end



            function results=check_switch_blocks(curModel)
                results={};
                switchBiasResults={};
                switchSlopeResults={};

                foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','Switch');
                for iBlk=1:length(foundBlks)
                    curBlk=foundBlks{iBlk};
                    pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');

                    inputType1=pdt.Inport{1};
                    inputType2=pdt.Inport{3};



                    if(~fixed.internal.type.isNameOfNumericType(inputType1)||~fixed.internal.type.isNameOfNumericType(inputType2))
                        return;
                    end

                    fxpPropY=getFixptProps(pdt.Outport{1});
                    fxpPropYBias=fxpPropY.Bias;
                    fxpPropYSaf=fxpPropY.SlopeAdjustmentFactor;

                    fxpPropU=getFixptProps(inputType1);
                    fxpPropUBias1=fxpPropU.Bias;
                    fxpPropUSaf1=fxpPropU.SlopeAdjustmentFactor;

                    fxpPropU=getFixptProps(inputType2);
                    fxpPropUBias2=fxpPropU.Bias;
                    fxpPropUSaf2=fxpPropU.SlopeAdjustmentFactor;

                    if(fxpPropYBias~=fxpPropUBias1)||(fxpPropYBias~=fxpPropUBias2)
                        switchBiasResults{end+1}=curBlk;
                    end

                    if(fxpPropYSaf~=fxpPropUSaf1)||(fxpPropYSaf~=fxpPropUSaf2)
                        switchSlopeResults{end+1}=curBlk;
                    end

                end

                if~isempty(switchBiasResults)
                    currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                    currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSwitchMismatchBias'));
                    currResult.setListObj(switchBiasResults);
                    currResult.setSubBar(false);
                    results{end+1}=currResult;
                end

                if~isempty(switchSlopeResults)
                    currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                    currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSwitchMismatchSlope'));
                    currResult.setListObj(switchSlopeResults);
                    currResult.setSubBar(false);
                    results{end+1}=currResult;
                end


                function results=check_logic_blocks(curModel)
                    results={};
                    logicBiasResults={};
                    logicSlopeResults={};

                    foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','Logic');
                    for iBlk=1:length(foundBlks)
                        curBlk=foundBlks{iBlk};
                        pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');

                        fxpPropY=getFixptProps(pdt.Outport{1});
                        fxpPropYBias=fxpPropY.Bias;
                        fxpPropYSaf=fxpPropY.SlopeAdjustmentFactor;

                        if(fxpPropYBias~=0)
                            logicBiasResults{end+1}=curBlk;
                        end

                        if(fxpPropYSaf~=1)
                            logicSlopeResults{end+1}=curBlk;
                        end

                    end

                    if~isempty(logicBiasResults)
                        currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                        currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckLogicOutputBiasNotZero'));
                        currResult.setListObj(logicBiasResults);
                        currResult.setSubBar(false);
                        results{end+1}=currResult;
                    end

                    if~isempty(logicSlopeResults)
                        currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                        currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckLogicOutputSlopeNotOne'));
                        currResult.setListObj(logicSlopeResults);
                        currResult.setSubBar(false);
                        results{end+1}=currResult;
                    end



                    function results=check_saturate_blocks(curModel)
                        results={};
                        saturateBiasResults={};
                        saturateSlopeResults={};

                        foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','Saturate');
                        for iBlk=1:length(foundBlks)
                            curBlk=foundBlks{iBlk};
                            pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');


                            fxpPropY=getFixptProps(pdt.Outport{1});
                            fxpPropYBias=fxpPropY.Bias;
                            fxpPropYSaf=fxpPropY.SlopeAdjustmentFactor;

                            fxpPropU=getFixptProps(pdt.Inport{1});
                            fxpPropUBias=fxpPropU.Bias;
                            fxpPropUSaf=fxpPropU.SlopeAdjustmentFactor;

                            if(fxpPropYBias~=fxpPropUBias)
                                saturateBiasResults{end+1}=curBlk;
                            end

                            if(fxpPropYSaf~=fxpPropUSaf)
                                saturateSlopeResults{end+1}=curBlk;
                            end

                        end

                        if~isempty(saturateBiasResults)
                            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSaturateMismatchBias'));
                            currResult.setListObj(saturateBiasResults);
                            currResult.setSubBar(false);
                            results{end+1}=currResult;
                        end

                        if~isempty(saturateSlopeResults)
                            currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                            currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSaturateMismatchSlope'));
                            currResult.setListObj(saturateSlopeResults);
                            currResult.setSubBar(false);
                            results{end+1}=currResult;
                        end


                        function results=check_sum_blocks(curModel)




                            results={};
                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);
                            sumMinMaxResults={};
                            sumBiasResults={};
                            sumSlopeResults={};
                            sumMsbLsbResults={};

                            foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','Sum');
                            for iBlk=1:length(foundBlks)
                                curBlk=foundBlks{iBlk};
                                pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                satMode=get_param(curBlk,'SaturateOnIntegerOverflow');
                                rndMode=get_param(curBlk,'RndMeth');


                                outDtRule=get_param(curBlk,'OutDataTypeStr');
                                accumDtRule=get_param(curBlk,'AccumDataTypeStr');


                                isMSBRule=false;
                                isLSBRule=false;
                                if contains(outDtRule,'Inherit: Keep MSB','IgnoreCase',true)
                                    isMSBRule=true;
                                elseif contains(outDtRule,'Inherit: Keep LSB','IgnoreCase',true)
                                    isLSBRule=true;
                                end

                                isAccumInternalRule=contains(accumDtRule,'Inherit: Inherit via internal rule','IgnoreCase',true);
                                if~isAccumInternalRule&&(isMSBRule||isLSBRule)


                                    sumMsbLsbResults{end+1}=curBlk;
                                end

                                ops=get_param(curBlk,'Inputs');
                                ops=strrep(ops,'|','');

                                if~strncmp('+',ops,1)&&~strncmp('-',ops,1)
                                    ops=repmat('+',1,eval(ops));
                                end
                                nOps=length(ops);
                                fxpPropY=getFixptProps(pdt.Outport{1});
                                netBias=0;

                                for iOps=1:nOps
                                    fxpPropU=getFixptProps(pdt.Inport{iOps});

                                    if ops(iOps)=='+'
                                        netBias=netBias+fxpPropU.Bias;
                                    else
                                        netBias=netBias-fxpPropU.Bias;
                                    end

                                    [minMaxResults,slopeResults]=sumCheck(curBlk,fxpPropU,fxpPropY,satMode,rndMode,mdladvObj);
                                    sumMinMaxResults=[sumMinMaxResults,minMaxResults];%#ok<*AGROW>
                                    sumSlopeResults=[sumSlopeResults,slopeResults];
                                end

                                if nOps==1
                                    pdim=get_param(curBlk,'CompiledPortWidths');
                                    netBias=netBias*pdim.Inport(1);
                                end

                                netBias=netBias-fxpPropY.Bias;

                                if netBias~=0
                                    sumBiasResults{end+1}=curBlk;
                                end


                            end

                            if~isempty(sumMsbLsbResults)
                                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSumMsbLsbAccumMismatch'));
                                currResult.setListObj(sumMsbLsbResults);
                                currResult.setSubBar(false);
                                results{end+1}=currResult;
                            end

                            if~isempty(sumBiasResults)
                                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSumMismatchBias'));
                                currResult.setListObj(sumBiasResults);
                                currResult.setSubBar(false);
                                results{end+1}=currResult;
                            end

                            if~isempty(sumSlopeResults)
                                currResult=ModelAdvisor.FormatTemplate('TableTemplate');
                                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSumMismatchSlope'));
                                currResult.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpInpSAFCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpOutSAFCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpNetSAFCol')});

                                for idx=1:numel(sumSlopeResults)
                                    currResult.addRow({sumSlopeResults{idx}.path,sumSlopeResults{idx}.USlope,sumSlopeResults{idx}.YSlope,sumSlopeResults{idx}.NetSlopeAdj});
                                end
                                currResult.setSubBar(false);
                                results{end+1}=currResult;
                            end

                            if~isempty(sumMinMaxResults)
                                currResult=ModelAdvisor.FormatTemplate('TableTemplate');
                                currResult.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckSumMinMax',sumMinMaxResults{1}.BiasNote));
                                currResult.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpInpMinCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpInpMaxCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpOutMinCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpOutMaxCol')});

                                for idx=1:numel(sumMinMaxResults)
                                    currResult.addRow({sumMinMaxResults{idx}.path,sumMinMaxResults{idx}.UMin,sumMinMaxResults{idx}.UMax,sumMinMaxResults{idx}.YMin,sumMinMaxResults{idx}.YMax});
                                end
                                currResult.setSubBar(false);
                                results{end+1}=currResult;
                            end



                            function[minMaxResults,slopeResults]=sumCheck(curBlk,fxpPropU,fxpPropY,satMode,rndMode,mdladvObj)%#ok

                                minMaxResults={};
                                slopeResults={};
                                if(fxpPropU.isfixed&&fxpPropY.isfixed)
                                    fxpPropU_nobias=fxpPropU;
                                    fxpPropU_nobias.Bias=0;

                                    uMin=num2fixpt(-realmax,fxpPropU_nobias,[],'Nearest','on');
                                    uMax=num2fixpt(realmax,fxpPropU_nobias,[],'Nearest','on');

                                    fxpPropY_nobias=fxpPropY;
                                    fxpPropY_nobias.Bias=0;

                                    yMin=num2fixpt(-realmax,fxpPropY_nobias,[],'Nearest','on');
                                    yMax=num2fixpt(realmax,fxpPropY_nobias,[],'Nearest','on');

                                    if(uMin<yMin)||(uMax>yMax)
                                        if(fxpPropU.Bias~=0)||(fxpPropY.Bias~=0)
                                            biasNote=DAStudio.message('Simulink:tools:FxpSumCheckBiasNote');
                                        else
                                            biasNote='';
                                        end


                                        if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                            minMaxResults{end+1}.path=curBlk;
                                            minMaxResults{end}.BiasNote=biasNote;
                                            minMaxResults{end}.UMin=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(uMin);
                                            minMaxResults{end}.UMax=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(uMax);
                                            minMaxResults{end}.YMin=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(yMin);
                                            minMaxResults{end}.YMax=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(yMax);
                                        end
                                    end

                                    netSlopeAdj=(fxpPropU.SlopeAdjustmentFactor/fxpPropY.SlopeAdjustmentFactor);



                                    quantNetSlopeAdj=num2fixpt(netSlopeAdj,sfix(33),fixptbestprec(netSlopeAdj,sfix(33)));

                                    if round(log2(quantNetSlopeAdj))~=log2(quantNetSlopeAdj)
                                        if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                            slopeResults{end+1}.path=curBlk;
                                            slopeResults{end}.USlope=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropU.SlopeAdjustmentFactor);
                                            slopeResults{end}.YSlope=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropY.SlopeAdjustmentFactor);
                                            slopeResults{end}.NetSlopeAdj=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(netSlopeAdj);
                                        end
                                    end
                                end


                                function results=check_dintegrate_blocks(curModel)
                                    results={};
                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);



                                    foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','DiscreteIntegrator','InitialConditionMode','Output');

                                    curBlks={};
                                    cnt=1;
                                    for i=1:numel(foundBlks)
                                        if~isempty(mdladvObj.filterResultWithExclusion(foundBlks{i}))
                                            curBlks{cnt}=foundBlks{i};
                                            cnt=cnt+1;
                                        end
                                    end
                                    if~isempty(curBlks)
                                        results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
                                        results{end}.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckDIntegrateBlock'));
                                        results{end}.setListObj(curBlks);
                                        results{end}.setSubBar(false);
                                    end


                                    function results=check_minmax_blocks(curModel)

                                        results={};
                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);

                                        foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType','MinMax');


                                        foundBlksOld=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','MaskType','Fixed-Point MinMax');
                                        foundBlks=[foundBlks,foundBlksOld].';

                                        minmaxres1=ModelAdvisor.FormatTemplate('ListTemplate');
                                        minmaxres1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckMinmaxNotSame'));
                                        minmaxres1.setSubBar(false);
                                        notSameMinMaxBlks={};

                                        minmaxres2=ModelAdvisor.FormatTemplate('TableTemplate');
                                        minmaxres2.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckMinmaxMinMax'));
                                        minmaxres2.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpInpMinCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpInpMaxCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpOutMinCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpOutMaxCol')});
                                        minmaxres2.setSubBar(false);

                                        hasTableInfo1=false;

                                        minmaxres3=ModelAdvisor.FormatTemplate('TableTemplate');
                                        minmaxres3.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckMinmaxSlope'));
                                        minmaxres3.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpInpSlopeCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpOutSlopeCol')});
                                        minmaxres3.setSubBar(false);
                                        hasTableInfo2=false;

                                        minmaxres4=ModelAdvisor.FormatTemplate('TableTemplate');
                                        minmaxres4.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckMinmaxFracSlope'));
                                        minmaxres4.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpInpSAFCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpOutSAFCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpNetSAFCol')});
                                        minmaxres4.setSubBar(false);
                                        hasTableInfo3=false;

                                        for iBlk=1:length(foundBlks)
                                            curBlk=foundBlks{iBlk};

                                            pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');

                                            fxpPropY=getFixptProps(pdt.Outport{1});

                                            for iOps=1:length(pdt.Inport)
                                                fxpPropU=getFixptProps(pdt.Inport{iOps});

                                                [notSameType,minMaxDiff,slopeDiff,fracSlopeDiff]=minmaxCheck(curBlk,fxpPropU,fxpPropY,mdladvObj);

                                                if~isempty(notSameType)
                                                    notSameMinMaxBlks=[notSameMinMaxBlks,notSameType];
                                                end

                                                if~isempty(minMaxDiff)
                                                    hasTableInfo1=true;
                                                    for idx=1:length(minMaxDiff)
                                                        if~isempty(mdladvObj.filterResultWithExclusion(minMaxDiff{idx}.path))
                                                            minmaxres2.addRow({minMaxDiff{idx}.path,minMaxDiff{idx}.uMin,minMaxDiff{idx}.uMax,minMaxDiff{idx}.yMin,minMaxDiff{idx}.yMax});
                                                        end
                                                    end
                                                end

                                                if~isempty(slopeDiff)
                                                    hasTableInfo2=true;
                                                    for idx=1:length(slopeDiff)
                                                        if~isempty(mdladvObj.filterResultWithExclusion(slopeDiff{idx}.path))
                                                            minmaxres3.addRow({slopeDiff{idx}.path,slopeDiff{idx}.uSlope,slopeDiff{idx}.ySlope});
                                                        end
                                                    end
                                                end

                                                if~isempty(fracSlopeDiff)
                                                    hasTableInfo3=true;
                                                    for idx=1:length(fracSlopeDiff)
                                                        if~isempty(mdladvObj.filterResultWithExclusion(fracSlopeDiff{idx}.path))
                                                            minmaxres4.addRow({fracSlopeDiff{idx}.path,fracSlopeDiff{idx}.uSlopeAdj,fracSlopeDiff{idx}.ySlopeAdj,fracSlopeDiff{idx}.netSlopeAdj});
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                        if~isempty(notSameMinMaxBlks)
                                            minmaxres1.setListObj(notSameMinMaxBlks);
                                            results{end+1}=minmaxres1;
                                        end

                                        if hasTableInfo1
                                            results{end+1}=minmaxres2;
                                        end

                                        if hasTableInfo2
                                            results{end+1}=minmaxres3;
                                        end

                                        if hasTableInfo3
                                            results{end+1}=minmaxres4;
                                            results{end}.setSubBar(false);
                                        end



                                        function[notSameType,minMaxDiff,slopeDiff,fracSlopeDiff]=minmaxCheck(curBlk,fxpPropU,fxpPropY,mdladvObj)
                                            notSameType={};
                                            minMaxDiff={};
                                            slopeDiff={};
                                            fracSlopeDiff={};

                                            if~isequal(fxpPropU,fxpPropY)
                                                notSameType{end+1}=curBlk;
                                            end

                                            if(fxpPropU.isfixed&&fxpPropY.isfixed)
                                                uMin=num2fixpt(-realmax,fxpPropU,[],'Nearest','on');
                                                uMax=num2fixpt(realmax,fxpPropU,[],'Nearest','on');

                                                yMin=num2fixpt(-realmax,fxpPropY,[],'Nearest','on');
                                                yMax=num2fixpt(realmax,fxpPropY,[],'Nearest','on');

                                                netSlopeAdj=(fxpPropU.SlopeAdjustmentFactor/fxpPropY.SlopeAdjustmentFactor);

                                                if uMin<yMin||uMax>yMax
                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                        minMaxDiff{end+1}.path=curBlk;
                                                        minMaxDiff{end}.uMin=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(uMin);
                                                        minMaxDiff{end}.uMax=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(uMax);
                                                        minMaxDiff{end}.yMin=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(yMin);
                                                        minMaxDiff{end}.yMax=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(yMax);
                                                    end
                                                end

                                                if fxpPropU.Slope<fxpPropY.Slope
                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                        slopeDiff{end+1}.path=curBlk;
                                                        slopeDiff{end}.uSlope=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropU.Slope);
                                                        slopeDiff{end}.ySlope=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropY.Slope);
                                                    end
                                                end



                                                quantNetSlopeAdj=num2fixpt(netSlopeAdj,sfix(33),fixptbestprec(netSlopeAdj,sfix(33)));

                                                if round(log2(quantNetSlopeAdj))~=log2(quantNetSlopeAdj)
                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                        fracSlopeDiff{end+1}.path=curBlk;
                                                        fracSlopeDiff{end}.uSlopeAdj=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropU.SlopeAdjustmentFactor);
                                                        fracSlopeDiff{end}.ySlopeAdj=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fxpPropY.SlopeAdjustmentFactor);
                                                        fracSlopeDiff{end}.netSlopeAdj=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(netSlopeAdj);
                                                    end
                                                end

                                            end


                                            function results=check_cmptoconst_blocks(curModel)
                                                results={};
                                                rows={};
                                                zeroRows={};
                                                constRows={};
                                                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);

                                                foundBlks=[local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','MaskType','Compare To Zero');...
                                                local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','MaskType','Compare To Constant')];

                                                results1=ModelAdvisor.FormatTemplate('TableTemplate');
                                                results1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckCmpToZero'));
                                                results1.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpInpDTCol')});
                                                results1.setSubBar(false);
                                                hasTableData1=false;

                                                results2=ModelAdvisor.FormatTemplate('TableTemplate');
                                                results2.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckCmpToConst'));
                                                results2.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpInpDTCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpConstValCol')});
                                                results2.setSubBar(false);
                                                hasTableData2=false;

                                                results3=ModelAdvisor.FormatTemplate('TableTemplate');
                                                results3.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckCmpToConstAlwaysSame'));
                                                results3.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpInpDTCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpConstValCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpCompResCol')});
                                                results3.setSubBar(false);
                                                hasTableData3=false;

                                                for iBlk=1:length(foundBlks)
                                                    curBlk=foundBlks{iBlk};
                                                    pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                    if strcmp(get_param(curBlk,'MaskType'),'Compare To Zero')
                                                        constValue=0;
                                                    else
                                                        constValue=slResolve(get_param(curBlk,'const'),curBlk);
                                                    end
                                                    cmpBlkOp=get_param(curBlk,'relop');


                                                    fxpPropU=getFixptProps(pdt.Inport{1});

                                                    DblValue=double(constValue);




                                                    if any(isinf(DblValue(:)))||any(isnan(DblValue(:)))

                                                        continue;
                                                    else
                                                        minOutOfRange=fixptCompMinMaxValue(min(DblValue(:)),fxpPropU.WordLength,fxpPropU.IsSigned,fxpPropU.FixedExponent,fxpPropU.SlopeAdjustmentFactor,fxpPropU.Bias);
                                                        maxOutOfRange=fixptCompMinMaxValue(max(DblValue(:)),fxpPropU.WordLength,fxpPropU.IsSigned,fxpPropU.FixedExponent,fxpPropU.SlopeAdjustmentFactor,fxpPropU.Bias);
                                                        if minOutOfRange==0
                                                            outOfRange=maxOutOfRange;
                                                            constValue=max(DblValue(:));
                                                        else
                                                            outOfRange=minOutOfRange;
                                                            constValue=min(DblValue(:));
                                                        end

                                                        if(outOfRange==1)||(outOfRange==-1)
                                                            if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                if strcmp(get_param(curBlk,'MaskType'),'Compare To Zero')
                                                                    zeroRows{end+1}={curBlk,pdt.Inport{1}};
                                                                else
                                                                    constRows{end+1}={curBlk,pdt.Inport{1},constValue};
                                                                end
                                                            end
                                                        end

                                                        if(outOfRange==0.5)


                                                            if strcmp(cmpBlkOp,'<=')
                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                    rows{end+1}={curBlk,pdt.Inport{1},SimulinkFixedPoint.DataType.compactButAccurateNum2Str(constValue),'true'};
                                                                end
                                                            end
                                                            if strcmp(cmpBlkOp,'>')
                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                    rows{end+1}={curBlk,pdt.Inport{1},SimulinkFixedPoint.DataType.compactButAccurateNum2Str(constValue),'false'};
                                                                end
                                                            end
                                                        end
                                                        if(outOfRange==-0.5)


                                                            if strcmp(cmpBlkOp,'>=')
                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                    rows{end+1}={curBlk,pdt.Inport{1},SimulinkFixedPoint.DataType.compactButAccurateNum2Str(constValue),'true'};
                                                                end
                                                            end
                                                            if strcmp(cmpBlkOp,'<')
                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                    rows{end+1}={curBlk,pdt.Inport{1},SimulinkFixedPoint.DataType.compactButAccurateNum2Str(constValue),'false'};
                                                                end
                                                            end
                                                        end
                                                    end
                                                end

                                                if~isempty(zeroRows)
                                                    hasTableData1=true;
                                                    for idx=1:numel(zeroRows)
                                                        results1.addRow(zeroRows{idx});
                                                    end
                                                end
                                                if~isempty(constRows)
                                                    hasTableData2=true;
                                                    for idx=1:numel(constRows)
                                                        results2.addRow(constRows{idx});
                                                    end
                                                end
                                                if~isempty(rows)
                                                    hasTableData3=true;
                                                    for idx=1:numel(rows)
                                                        results3.addRow(rows{idx});
                                                    end
                                                end

                                                if hasTableData1
                                                    results{end+1}=results1;
                                                end

                                                if hasTableData2
                                                    results{end+1}=results2;
                                                end

                                                if hasTableData3
                                                    results{end+1}=results3;
                                                end


                                                function results=checkExpensiveSaturation(curModel)

                                                    results={};
                                                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);



                                                    hScope=get_param(curModel,'Handle');
                                                    hBlocks=local_findSystem(hScope,'SaturateOnIntegerOverflow','on');

                                                    nofloatBlocks={};

                                                    for i=1:length(hBlocks)

                                                        comPortDataTypeStructure=get_param(hBlocks{i},'CompiledPortDataTypes');
                                                        curBlockObj=get_param(hBlocks{i},'Object');
                                                        if~isempty(comPortDataTypeStructure)&&isfield(comPortDataTypeStructure,'Outport')
                                                            possibleMoot=locSwitchBlockSaturMoot(curBlockObj,comPortDataTypeStructure);
                                                            if~possibleMoot
                                                                suspeciousTypes=setdiff(unique(comPortDataTypeStructure.Outport),{'double','single'});

                                                                if~isempty(suspeciousTypes)

                                                                    suspeciousTypes=Advisor.Utils.Simulink.outDataTypeStr2baseType(bdroot(curModel),suspeciousTypes);

                                                                    if~isempty(setdiff(suspeciousTypes,{'double','single'}))
                                                                        if~isempty(mdladvObj.filterResultWithExclusion(hBlocks{i}))
                                                                            nofloatBlocks{end+1}=hBlocks{i};
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end

                                                    currentResult=nofloatBlocks;

                                                    if~isempty(currentResult)
                                                        currentDescription=ModelAdvisor.FormatTemplate('ListTemplate');
                                                        currentDescription.setSubTitle('Saturate on integer overflow');
                                                        currentDescription.setInformation(DAStudio.message('ModelAdvisor:engine:CheckExpensiveBlockWarn'));
                                                        currentDescription.setListObj(currentResult);
                                                        currentDescription.setSubBar(false);
                                                        results{end+1}=currentDescription;
                                                    end


                                                    results=[results,check_ModelIntDivSettings(getfullname(curModel))];


                                                    function results=check_ModelIntDivSettings(curRoot)
                                                        results={};

                                                        isSubsystem=~strcmp(bdroot(curRoot),curRoot);

                                                        if isSubsystem

                                                            curRoot=bdroot(curRoot);
                                                        end

                                                        cs=getActiveConfigSet(curRoot);
                                                        if strcmp(get_param(cs,'IsERTTarget'),'on')
                                                            optcs=cs.getComponent('Optimization');
                                                            if strcmp(optcs.NoFixptDivByZeroProtection,'off')
                                                                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                currResult.setSubResultStatusText(...
                                                                DAStudio.message('ModelAdvisor:engine:FxpCheckDivZeroProtect',encodedModelName(curRoot)));
                                                                currResult.setSubBar(false);
                                                                currResult.setListObj({get_param(curRoot,'Name')});
                                                                results{end+1}=currResult;
                                                            end
                                                        end

                                                        if~isempty(results)
                                                            results{1}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckHardwareIntDivAndRounding'));
                                                            results{end}.setSubBar(false);
                                                        end


                                                        function results=check_lookuptable_blocks(curModel)


                                                            results={};
                                                            try
                                                                currResult=check_lookup_spacing(curModel);
                                                                results=[results,currResult];
                                                            catch ME1
                                                                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                currResult.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpCheckFailed',...
                                                                'LookupBreakpointSpacing',ME1.message));
                                                                currResult.setListObj({get_param(curModel,'Name')});
                                                                currResult.setSubBar(false);
                                                                results{end+1}=currResult;
                                                            end



                                                            try
                                                                currResult=check_PreLookup_division(curModel);
                                                                results=[results,currResult];
                                                            catch ME1
                                                                currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                currResult.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpCheckFailed',...
                                                                'PreLookupBlocks',ME1.message));
                                                                currResult.setListObj({get_param(curModel,'Name')});
                                                                currResult.setSubBar(false);
                                                                results{end+1}=currResult;
                                                            end
                                                            if~isempty(results)
                                                                results{end}.setSubBar(false);
                                                            end


                                                            function results=check_lookup_spacing(curModel)


                                                                lookupResults={};
                                                                lookup2dResults={};
                                                                lookupndResults={};
                                                                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);
                                                                foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','graphical','BlockType','Lookup');
                                                                lookupResults=[lookupResults,evenSpacing(foundBlks,{'InputValues'},mdladvObj)];


                                                                foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','graphical','BlockType','Lookup2D');
                                                                lookup2dResults=[lookup2dResults,evenSpacing(foundBlks,{'RowIndex','ColumnIndex'},mdladvObj)];

                                                                results=[lookupResults,lookup2dResults,lookupndResults];


                                                                function notes=check_PreLookup_division(curModel)
                                                                    notes=check_PLU_LookupND_division(curModel,'PreLookup');


                                                                    function results=check_PLU_LookupND_division(curModel,blockType)
                                                                        results={};
                                                                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(curModel);
                                                                        foundBlks=local_findSystem(curModel,'FollowLinks','on','LookUnderMasks','all','BlockType',blockType);
                                                                        for iBlk=1:length(foundBlks)
                                                                            curBlk=foundBlks{iBlk};

                                                                            blkHasDivision=strcmp(get_param(curBlk,'IndexSearchMethod'),'Evenly spaced points');
                                                                            if(blkHasDivision)
                                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                    currResult=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                    currResult.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpPreLookupDivision'));
                                                                                    currResult.setListObj({curBlk});
                                                                                    currResult.setSubBar(false);
                                                                                    results{end+1}=currResult;%#ok<*AGROW>
                                                                                end
                                                                            end
                                                                        end


                                                                        function results=check_int_div_netslope(system,mdladvObj)

                                                                            results={};
                                                                            curRoot=bdroot(system);

                                                                            if~isMicroprocessor(curRoot)

                                                                                return;
                                                                            end
                                                                            isUseOptimizationNetSlope=get_param(curRoot,'UseDivisionForNetSlopeComputation');
                                                                            optimizationCheckOn.AllowDiv=false;
                                                                            optimizationCheckOn.ReciprocalOnly=false;
                                                                            if strcmp(isUseOptimizationNetSlope,'on')


                                                                                optimizationCheckOn.AllowDiv=true;
                                                                            elseif strcmp(isUseOptimizationNetSlope,'UseDivisionForReciprocalsOfIntegersOnly')
                                                                                optimizationCheckOn.ReciprocalOnly=true;
                                                                            end
                                                                            hwIntDivRndMeth=get_param(curRoot,'ProdIntDivRoundTo');

                                                                            dtc_foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','BlockType','DataTypeConversion');



                                                                            dot_prod_foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','BlockType','DotProduct');


                                                                            dot_prod_old_foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','MaskType','Fixed-Point Dot Product');
                                                                            all_dot_prod_blks=[dot_prod_foundBlks,dot_prod_old_foundBlks];


                                                                            gain_foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','BlockType','Gain');


                                                                            prod_foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','BlockType','Product');

                                                                            dtc_results=check_int_div_netslope_dtc(dtc_foundBlks,optimizationCheckOn,hwIntDivRndMeth,mdladvObj,curRoot);
                                                                            dot_prod_resStruct=check_int_div_netslope_dot_prod_blks(all_dot_prod_blks,optimizationCheckOn,hwIntDivRndMeth,mdladvObj);
                                                                            gain_resStruct=check_int_div_netslope_gain(gain_foundBlks,optimizationCheckOn,hwIntDivRndMeth,mdladvObj);
                                                                            prod_resStruct=check_int_div_netslope_prod(prod_foundBlks,optimizationCheckOn,hwIntDivRndMeth,mdladvObj);
                                                                            mul_resStruct={dot_prod_resStruct,gain_resStruct,prod_resStruct};


                                                                            mul_resStruct=mul_resStruct(~cellfun('isempty',mul_resStruct));

                                                                            mul_results={};
                                                                            if~isempty(mul_resStruct)
                                                                                blkList=[];
                                                                                for resStructIter=1:length(mul_resStruct)
                                                                                    netSlopeMsg='';
                                                                                    tempResStruct=mul_resStruct{resStructIter};
                                                                                    for blkIter=1:numel(tempResStruct)
                                                                                        if~isempty(tempResStruct(blkIter).netSlopeMsg)
                                                                                            netSlopeMsg=tempResStruct(blkIter).netSlopeMsg;
                                                                                            blkList=[blkList,tempResStruct(blkIter).blkList];
                                                                                        end
                                                                                    end
                                                                                end
                                                                                if~strcmp(netSlopeMsg,'')
                                                                                    mul_results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                    mul_results{end}.setSubBar(false);
                                                                                    mul_results{end}.setSubResultStatusText(netSlopeMsg);
                                                                                    mul_results{end}.setListObj(blkList);
                                                                                end
                                                                            end
                                                                            results=[dtc_results,mul_results];

                                                                            function[suffixStr,isNeedChanges]=netSlopeStringMsgSuffix(optimizationCheckOn,isReciprocalOfInt)
                                                                                isNeedChanges=false;
                                                                                if optimizationCheckOn.AllowDiv

                                                                                    suffixStr='SetOnRationalApprox';
                                                                                elseif optimizationCheckOn.ReciprocalOnly&&isReciprocalOfInt



                                                                                    suffixStr='SetOnReciprocalOfInt';
                                                                                elseif~isReciprocalOfInt




                                                                                    suffixStr='SetOffRationalApprox';
                                                                                    if optimizationCheckOn.ReciprocalOnly

                                                                                        suffixStr='SetOffRationalApproxSetOnReciprocalOfInt';
                                                                                    end
                                                                                    isNeedChanges=true;
                                                                                else


                                                                                    suffixStr='SetOffReciprocalOfInt';
                                                                                    isNeedChanges=true;
                                                                                end


                                                                                function results=check_int_div_netslope_dtc(foundBlks,optimizationCheckOn,hwIntDivRndMeth,mdladvObj,curRoot)

                                                                                    results={};
                                                                                    isNeedChanges=false;
                                                                                    wordSizes=getMicroSizes(curRoot);
                                                                                    allowedWLs=[wordSizes.char
                                                                                    wordSizes.short
                                                                                    wordSizes.int
                                                                                    wordSizes.long].';
                                                                                    if wordSizes.longlongmode==1
                                                                                        allowedWLs=[wordSizes.char
                                                                                        wordSizes.short
                                                                                        wordSizes.int
                                                                                        wordSizes.long
                                                                                        wordSizes.longlong].';
                                                                                    end
                                                                                    for iBlk=1:length(foundBlks)
                                                                                        curBlk=foundBlks{iBlk};
                                                                                        pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                                                        curBlkObj=get_param(curBlk,'Object');
                                                                                        if~strcmp(pdt.Inport{1},pdt.Outport{1})
                                                                                            changeToFitInSingleWord=false;




                                                                                            try
                                                                                                fxpPropU=getFixptProps(pdt.Inport{1});
                                                                                            catch ex %#ok

                                                                                                continue;
                                                                                            end

                                                                                            if isDataTypeMultiWord(fxpPropU,wordSizes)

                                                                                                changeToFitInSingleWord=true;
                                                                                                fxpPropU.WordLength=wordSizes.chunksize;
                                                                                            end

                                                                                            fxpPropY=getFixptProps(pdt.Outport{1});
                                                                                            if isDataTypeMultiWord(fxpPropY,wordSizes)

                                                                                                changeToFitInSingleWord=true;
                                                                                                fxpPropY.WordLength=wordSizes.chunksize;
                                                                                            end


                                                                                            checkUseRndMode='Simplest';

                                                                                            checkUseSatMode=curBlkObj.SaturateOnIntegerOverflow;
                                                                                            if strcmp(hwIntDivRndMeth,'Undefined')
                                                                                                checkHwIntDivRndMeth='Zero';
                                                                                            else
                                                                                                checkHwIntDivRndMeth=hwIntDivRndMeth;
                                                                                            end

                                                                                            [reciprocalOfInt,rationalApprox]=fixpt_data_type_rules('CheckCastUseIntDivNetSlope',...
                                                                                            'u_dt',fxpPropU,...
                                                                                            'y_dt',fxpPropY,...
                                                                                            'hardwareWL',allowedWLs,...
                                                                                            'hardwareRndMeth',checkHwIntDivRndMeth,...
                                                                                            'rndMeth',checkUseRndMode,...
                                                                                            'doSatur',checkUseSatMode);


                                                                                            if reciprocalOfInt||rationalApprox



                                                                                                [suffixStr,isNeedChanges]=netSlopeStringMsgSuffix(optimizationCheckOn,reciprocalOfInt);
                                                                                                stackNotes=DAStudio.message(strcat('Simulink:tools:FxpCheckCastOpt',suffixStr));

                                                                                                if changeToFitInSingleWord

                                                                                                    stackNotes=strcat(stackNotes,DAStudio.message('Simulink:tools:FxpCheckMultiWord'));
                                                                                                    isNeedChanges=true;
                                                                                                end
                                                                                                if~strcmpi(curBlkObj.RndMeth,'Simplest')

                                                                                                    if~strcmp(hwIntDivRndMeth,curBlkObj.RndMeth)
                                                                                                        stackNotes=strcat(stackNotes,DAStudio.message('Simulink:tools:FxpNetSlopeChangeRndMethod'));
                                                                                                        isNeedChanges=true;
                                                                                                    end
                                                                                                end
                                                                                                if strcmp(hwIntDivRndMeth,'Undefined')
                                                                                                    stackNotes=strcat(stackNotes,DAStudio.message('Simulink:tools:FxpNetSlopeChangeHWRndMeth'));
                                                                                                    isNeedChanges=true;
                                                                                                end
                                                                                            end
                                                                                            if isNeedChanges
                                                                                                if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                    results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                    results{end}.setSubBar(false);
                                                                                                    results{end}.setSubResultStatusText(stackNotes);
                                                                                                    results{end}.setListObj({curBlk});
                                                                                                end
                                                                                            end
                                                                                        end
                                                                                    end

                                                                                    function[resStruct]=getMulResStruct(resStruct,useDivNetSlopeTag,issueTag,curBlk)




                                                                                        if strcmp(useDivNetSlopeTag,'')
                                                                                            return
                                                                                        end
                                                                                        if isempty(resStruct)

                                                                                            resStruct=repmat(struct('netSlopeMsg','','blkList',{}),1,31);
                                                                                        end
                                                                                        resIndex=0;
                                                                                        netSlopeMsg=DAStudio.message(strcat('Simulink:tools:',useDivNetSlopeTag));
                                                                                        switch useDivNetSlopeTag
                                                                                        case 'FxpCheckMulOptSetOffRationalApprox'


                                                                                            resIndex=8;
                                                                                        case 'FxpCheckMulOptSetOffReciprocalOfInt'



                                                                                            resIndex=16;
                                                                                        case 'FxpCheckMulOptSetOffRationalApproxSetOnReciprocalOfInt'



                                                                                            resIndex=24;
                                                                                        end
                                                                                        if contains(issueTag,'FxpCheckMultiWord')

                                                                                            resIndex=resIndex+1;
                                                                                            netSlopeMsg=strcat(netSlopeMsg,DAStudio.message('Simulink:tools:FxpCheckMultiWord'));
                                                                                        end
                                                                                        if contains(issueTag,'FxpNetSlopeChangeRndMethod')

                                                                                            resIndex=resIndex+2;
                                                                                            netSlopeMsg=strcat(netSlopeMsg,DAStudio.message('Simulink:tools:FxpNetSlopeChangeRndMethod'));
                                                                                        end
                                                                                        if contains(issueTag,'FxpNetSlopeChangeHWRndMeth')

                                                                                            resIndex=resIndex+4;
                                                                                            netSlopeMsg=strcat(netSlopeMsg,DAStudio.message('Simulink:tools:FxpNetSlopeChangeHWRndMeth'));
                                                                                        end
                                                                                        if resIndex==0

                                                                                            return;
                                                                                        end
                                                                                        resStruct(resIndex).netSlopeMsg=netSlopeMsg;
                                                                                        resStruct(resIndex).blkList=[resStruct(resIndex).blkList,{curBlk}];


                                                                                        function[resStruct]=check_int_div_netslope_dot_prod_blks(foundBlks,~,~,~)

                                                                                            resStruct=[];
                                                                                            for iBlk=1:length(foundBlks)
                                                                                                curBlk=foundBlks{iBlk};
                                                                                                pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                                                                fxpPropU=getFixptProps(pdt.Inport{1});
                                                                                                fxpPropU2=getFixptProps(pdt.Inport{2});
                                                                                                fxpPropY=getFixptProps(pdt.Outport{1});
                                                                                                satMode=get_param(curBlk,'SaturateOnIntegerOverflow');
                                                                                                [useDivNetSlopeTag,issueTag]=mulCheck(curBlk,fxpPropU,fxpPropU2,fxpPropY,satMode);
                                                                                                resStruct=getMulResStruct(resStruct,useDivNetSlopeTag,issueTag,curBlk);
                                                                                            end


                                                                                            function[resStruct]=check_int_div_netslope_gain(foundBlks,~,~,~)

                                                                                                resStruct=[];
                                                                                                for iBlk=1:length(foundBlks)
                                                                                                    curBlk=foundBlks{iBlk};
                                                                                                    pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                                                                    fxpPropU=getFixptProps(pdt.Inport{1});
                                                                                                    fxpPropY=getFixptProps(pdt.Outport{1});
                                                                                                    rtp=get_runtimeparam_by_name(curBlk,'Gain');
                                                                                                    if(~isempty(rtp))
                                                                                                        fxpPropK=getFixptProps(rtp.AliasedThroughDatatype);
                                                                                                    else
                                                                                                        fxpPropK=fxpPropU;
                                                                                                    end
                                                                                                    satMode=get_param(curBlk,'SaturateOnIntegerOverflow');
                                                                                                    [useDivNetSlopeTag,issueTag]=mulCheck(curBlk,fxpPropU,fxpPropK,fxpPropY,satMode);
                                                                                                    resStruct=getMulResStruct(resStruct,useDivNetSlopeTag,issueTag,curBlk);
                                                                                                end

                                                                                                function resStruct=check_int_div_netslope_prod(foundBlks,~,~,~)

                                                                                                    resStruct=[];
                                                                                                    for iBlk=1:length(foundBlks)
                                                                                                        curBlk=foundBlks{iBlk};
                                                                                                        pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                                                                        satMode=get_param(curBlk,'SaturateOnIntegerOverflow');

                                                                                                        ops=get_param(curBlk,'Inputs');
                                                                                                        if~strncmp('*',ops,1)&&~strncmp('/',ops,1)
                                                                                                            ops=repmat('*',1,eval(ops));
                                                                                                        end
                                                                                                        nOps=length(ops);
                                                                                                        if nOps==1
                                                                                                            fxpPropU=getFixptProps(pdt.Inport{1});
                                                                                                            fxpPropY=getFixptProps(pdt.Outport{1});
                                                                                                            [useDivNetSlopeTag,issueTag]=mulCheck(curBlk,fxpPropU,fxpPropU,fxpPropY,satMode);
                                                                                                            resStruct=getMulResStruct(resStruct,useDivNetSlopeTag,issueTag,curBlk);
                                                                                                        elseif nOps>=2
                                                                                                            fxpPropY=getFixptProps(pdt.Outport{1});
                                                                                                            for iOps=2:nOps
                                                                                                                curOp=ops(iOps);
                                                                                                                if curOp=='*'
                                                                                                                    fxpPropULeft=getFixptProps(pdt.Inport{iOps-1});
                                                                                                                    fxpPropURght=getFixptProps(pdt.Inport{iOps});
                                                                                                                    [useDivNetSlopeTag,issueTag]=mulCheck(curBlk,fxpPropULeft,fxpPropURght,fxpPropY,satMode);
                                                                                                                    resStruct=getMulResStruct(resStruct,useDivNetSlopeTag,issueTag,curBlk);
                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                    end



                                                                                                    function results=check_multipleops_single_blk(system,mdladvObj)

                                                                                                        results={};
                                                                                                        many_mul_blks={};
                                                                                                        many_div_blks={};

                                                                                                        foundBlks=local_findSystem(system,'FollowLinks','on','LookUnderMasks','all','BlockType','Product');
                                                                                                        for iBlk=1:length(foundBlks)
                                                                                                            curBlk=foundBlks{iBlk};
                                                                                                            pdt=get_param(curBlk,'CompiledPortAliasedThruDataTypes');
                                                                                                            BlkhasfloatOutport=false;
                                                                                                            if~isempty(pdt.Outport)
                                                                                                                if strcmp(pdt.Outport{1},'single')||strcmp(pdt.Outport{1},'double')
                                                                                                                    BlkhasfloatOutport=true;
                                                                                                                end
                                                                                                            end
                                                                                                            ops=get_param(curBlk,'Inputs');

                                                                                                            if~strncmp('*',ops,1)&&~strncmp('/',ops,1)
                                                                                                                ops=repmat('*',1,eval(ops));
                                                                                                            end

                                                                                                            nOps=length(ops);

                                                                                                            if nOps==1
                                                                                                                pdim=get_param(curBlk,'CompiledPortWidths');
                                                                                                                if ops=='*'



                                                                                                                    if pdim.Inport(1)>2&&~BlkhasfloatOutport
                                                                                                                        if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                            many_mul_blks=[many_mul_blks,{curBlk}];
                                                                                                                        end


                                                                                                                    end
                                                                                                                end
                                                                                                            elseif nOps>=2
                                                                                                                if length(ops)>2&&~BlkhasfloatOutport
                                                                                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                        many_mul_blks=[many_mul_blks,{curBlk}];
                                                                                                                    end


                                                                                                                end
                                                                                                                if sum(ops=='/')>1
                                                                                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                        many_div_blks=[many_div_blks,{curBlk}];
                                                                                                                    end


                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                        if~isempty(many_mul_blks)
                                                                                                            results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                            results{end}.setSubBar(false);
                                                                                                            results{end}.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpManyMulDivSameBlock'));
                                                                                                            results{end}.setListObj(many_mul_blks);
                                                                                                        end

                                                                                                        if~isempty(many_div_blks)
                                                                                                            results{end+1}=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                            results{end}.setSubBar(false);
                                                                                                            results{end}.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpManyDivSameBlock'));
                                                                                                            results{end}.setListObj(many_div_blks);
                                                                                                        end


                                                                                                        function[useDivNetSlopeTag,issueTag]=mulCheck(curBlk,fxpPropU0,fxpPropU1,fxpPropY,satMode)

                                                                                                            curRoot=bdroot(curBlk);
                                                                                                            [isMicro,~]=check_embedded_hw_is_micro(curBlk);
                                                                                                            useDivNetSlopeTag='';
                                                                                                            issueTag='';
                                                                                                            if~isMicro;return;end
                                                                                                            isNeedChanges=false;

                                                                                                            isUseOptimizationNetSlope=get_param(curRoot,'UseDivisionForNetSlopeComputation');
                                                                                                            optimizationCheckOn.AllowDiv=false;
                                                                                                            optimizationCheckOn.ReciprocalOnly=false;
                                                                                                            if strcmp(isUseOptimizationNetSlope,'on')


                                                                                                                optimizationCheckOn.AllowDiv=true;
                                                                                                            elseif strcmp(isUseOptimizationNetSlope,'UseDivisionForReciprocalsOfIntegersOnly')
                                                                                                                optimizationCheckOn.ReciprocalOnly=true;
                                                                                                            end


                                                                                                            checkUseRndMode='Simplest';

                                                                                                            hwIntDivRndMeth=get_param(curRoot,'ProdIntDivRoundTo');
                                                                                                            wordSizes=getMicroSizes(curRoot);
                                                                                                            allowedWLs=[wordSizes.char
                                                                                                            wordSizes.short
                                                                                                            wordSizes.int
                                                                                                            wordSizes.long].';

                                                                                                            if wordSizes.longlongmode==1
                                                                                                                allowedWLs=[wordSizes.char
                                                                                                                wordSizes.short
                                                                                                                wordSizes.int
                                                                                                                wordSizes.long
                                                                                                                wordSizes.longlong].';
                                                                                                            end

                                                                                                            changeToFitInSingleWord=false;

                                                                                                            if isDataTypeMultiWord(fxpPropU0,wordSizes)

                                                                                                                changeToFitInSingleWord=true;
                                                                                                                fxpPropU0.WordLength=wordSizes.chunksize;
                                                                                                            end
                                                                                                            if isDataTypeMultiWord(fxpPropU1,wordSizes)

                                                                                                                changeToFitInSingleWord=true;
                                                                                                                fxpPropU1.WordLength=wordSizes.chunksize;
                                                                                                            end

                                                                                                            if isDataTypeMultiWord(fxpPropY,wordSizes)

                                                                                                                changeToFitInSingleWord=true;
                                                                                                                fxpPropY.WordLength=wordSizes.chunksize;
                                                                                                            end

                                                                                                            if strcmp(hwIntDivRndMeth,'Undefined')
                                                                                                                checkHwIntDivRndMeth='Zero';
                                                                                                            else
                                                                                                                checkHwIntDivRndMeth=hwIntDivRndMeth;
                                                                                                            end
                                                                                                            [reciprocalOfInt,rationalApprox]=fixpt_data_type_rules('CheckMulUseIntDivNetSlope',...
                                                                                                            'u0_dt',fxpPropU0,...
                                                                                                            'u1_dt',fxpPropU1,...
                                                                                                            'y_dt',fxpPropY,...
                                                                                                            'hardwareWL',allowedWLs,...
                                                                                                            'hardwareRndMeth',checkHwIntDivRndMeth,...
                                                                                                            'rndMeth',checkUseRndMode,...
                                                                                                            'doSatur',satMode);
                                                                                                            if reciprocalOfInt||rationalApprox



                                                                                                                [suffixStr,isNeedChanges]=netSlopeStringMsgSuffix(optimizationCheckOn,reciprocalOfInt);
                                                                                                                useDivNetSlopeTag=strcat('FxpCheckMulOpt',suffixStr);

                                                                                                                if changeToFitInSingleWord

                                                                                                                    isNeedChanges=true;
                                                                                                                    issueTag=[issueTag,'_FxpCheckMultiWord'];
                                                                                                                end

                                                                                                                curBlkObj=get_param(curBlk,'Object');
                                                                                                                if~strcmpi(curBlkObj.RndMeth,'Simplest')

                                                                                                                    if~strcmp(hwIntDivRndMeth,curBlkObj.RndMeth)
                                                                                                                        isNeedChanges=true;
                                                                                                                        issueTag=[issueTag,'_FxpNetSlopeChangeRndMethod'];
                                                                                                                    end
                                                                                                                end
                                                                                                                if strcmp(hwIntDivRndMeth,'Undefined')
                                                                                                                    isNeedChanges=true;
                                                                                                                    issueTag=[issueTag,'_FxpNetSlopeChangeHWRndMeth'];
                                                                                                                end
                                                                                                            end
                                                                                                            if~isNeedChanges
                                                                                                                issueTag='';
                                                                                                            end


                                                                                                            function res=get_runtimeparam_by_name(curBlk,paramName)
                                                                                                                rto=[];
                                                                                                                try
                                                                                                                    rto=get_param(curBlk,'RuntimeObject');
                                                                                                                catch ME1

                                                                                                                    if ME1.identifier~="Simulink:Engine:RTI_REDUCED_BLOCK"
                                                                                                                        rethrow(ME1);
                                                                                                                    end
                                                                                                                end

                                                                                                                res=[];

                                                                                                                if(~isempty(rto))
                                                                                                                    for i=1:rto.NumRuntimePrms

                                                                                                                        curRuntimePrm=rto.RuntimePrm(i);

                                                                                                                        if(~isempty(curRuntimePrm)&&...
                                                                                                                            strcmp(curRuntimePrm.Name,paramName))

                                                                                                                            res=curRuntimePrm;
                                                                                                                            break;
                                                                                                                        end
                                                                                                                    end
                                                                                                                end


                                                                                                                function results=evenSpacing(foundBlks,searchParam,mdladvObj)







                                                                                                                    results={};
                                                                                                                    currResultUnevenSpaced=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                    currResultUnevenSpaced.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpEvenSpacingSignificant'));
                                                                                                                    currResultUnevenSpaced.setSubBar(false);

                                                                                                                    currResultUnevenSpacedSlight=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                    currResultUnevenSpacedSlight.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpEvenSpacingSlight'));
                                                                                                                    currResultUnevenSpacedSlight.setSubBar(false);

                                                                                                                    currResultUnevenSpacePerfect=ModelAdvisor.FormatTemplate('ListTemplate');
                                                                                                                    currResultUnevenSpacePerfect.setSubResultStatusText(DAStudio.message('Simulink:tools:FxpEvenSpacingPerfect'));
                                                                                                                    currResultUnevenSpacePerfect.setSubBar(false);

                                                                                                                    UnevenSpacedBlks={};
                                                                                                                    UnevenSpacedSlight={};
                                                                                                                    UnevenSpacePerfect={};

                                                                                                                    for iBlk=1:length(foundBlks)
                                                                                                                        curBlk=foundBlks{iBlk};
                                                                                                                        for i=1:numel(searchParam)
                                                                                                                            param=searchParam{i};
                                                                                                                            runtimeParam=get_runtimeparam_by_name(curBlk,param);
                                                                                                                            if(~isempty(runtimeParam))
                                                                                                                                fxpProp=getFixptProps(runtimeParam.AliasedThroughDatatype);
                                                                                                                                xdata=double(runtimeParam.Data);
                                                                                                                            else
                                                                                                                                fxpProp=fixdt('double');
                                                                                                                                xdata=0.0;
                                                                                                                            end

                                                                                                                            if fxpProp.isfixed
                                                                                                                                [~,spacingStatus,evenSpacingValue]=fixpt_evenspace_cleanup(xdata,fxpProp);
                                                                                                                                switch spacingStatus
                                                                                                                                case 'Significantly uneven spacing'
                                                                                                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                                        UnevenSpacedBlks=[UnevenSpacedBlks,{curBlk}];
                                                                                                                                    end
                                                                                                                                case 'Slightly uneven spacing, modified to be evenly spaced'
                                                                                                                                    if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                                        UnevenSpacedSlight=[UnevenSpacedSlight,{curBlk}];
                                                                                                                                    end
                                                                                                                                case 'Perfectly even spacing'
                                                                                                                                    [fff,eee]=log2(evenSpacingValue);%#ok
                                                                                                                                    if fff~=0.5
                                                                                                                                        if~isempty(mdladvObj.filterResultWithExclusion(curBlk))
                                                                                                                                            UnevenSpacePerfect=[UnevenSpacePerfect,{curBlk}];
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                    end
                                                                                                                    if~isempty(UnevenSpacedBlks)
                                                                                                                        currResultUnevenSpaced.setListObj(UnevenSpacedBlks);
                                                                                                                        results{end+1}=currResultUnevenSpaced;
                                                                                                                    end

                                                                                                                    if~isempty(UnevenSpacedSlight)
                                                                                                                        currResultUnevenSpacedSlight.setListObj(UnevenSpacedSlight);
                                                                                                                        results{end+1}=currResultUnevenSpacedSlight;
                                                                                                                    end

                                                                                                                    if~isempty(UnevenSpacePerfect)
                                                                                                                        currResultUnevenSpacePerfect.setListObj(UnevenSpacePerfect);
                                                                                                                        results{end+1}=currResultUnevenSpacePerfect;
                                                                                                                    end


                                                                                                                    function fixptProps=getFixptProps(aliasThruDataType)
                                                                                                                        hClass=Simulink.getMetaClassIfValidEnumDataType(aliasThruDataType);

                                                                                                                        if~isempty(hClass)

                                                                                                                            fixptProps=fixdt('int32');
                                                                                                                        else
                                                                                                                            fixptProps=fixdt(aliasThruDataType);
                                                                                                                        end


                                                                                                                        function vEncodedModelName=encodedModelName(curRoot)

                                                                                                                            vEncodedModelName=modeladvisorprivate('HTMLjsencode',get_param(curRoot,'Name'),'encode');
                                                                                                                            vEncodedModelName=[vEncodedModelName{:}];


                                                                                                                            function[isMicro,notes]=check_embedded_hw_is_micro(curBlk)

                                                                                                                                isMicro=true;
                                                                                                                                notes='';
                                                                                                                                curRoot=bdroot(curBlk);

                                                                                                                                if~isMicroprocessor(curRoot)
                                                                                                                                    isMicro=false;
                                                                                                                                    notes=DAStudio.message(...
                                                                                                                                    'Simulink:tools:FxpEmbeddedHardwareNotMicro',...
                                                                                                                                    encodedModelName(curRoot));
                                                                                                                                end


                                                                                                                                function res=isMicroprocessor(curModel)

                                                                                                                                    res=true;
                                                                                                                                    curRoot=bdroot(curModel);
                                                                                                                                    cs=getActiveConfigSet(curRoot);

                                                                                                                                    devType=lower(get_param(cs,'ProdHWDeviceType'));

                                                                                                                                    asic='asic';
                                                                                                                                    fpga='fpga';
                                                                                                                                    unconstr='unconstr';

                                                                                                                                    if(strncmp(devType,asic,length(asic))||...
                                                                                                                                        strncmp(devType,fpga,length(fpga))||...
                                                                                                                                        strncmp(devType,unconstr,length(unconstr)))
                                                                                                                                        res=false;
                                                                                                                                    end


                                                                                                                                    function wordSizes=getMicroSizes(curRoot)

                                                                                                                                        cs=getActiveConfigSet(curRoot);
                                                                                                                                        wordSizes.char=get_param(cs,'ProdBitPerChar');
                                                                                                                                        wordSizes.short=get_param(cs,'ProdBitPerShort');
                                                                                                                                        wordSizes.int=get_param(cs,'ProdBitPerInt');
                                                                                                                                        wordSizes.long=get_param(cs,'ProdBitPerLong');
                                                                                                                                        wordSizes.longlong=get_param(cs,'ProdBitPerLongLong');
                                                                                                                                        wordSizes.longlongmode=int32(strcmp(get_param(cs,'ProdLongLongMode'),'on'));

                                                                                                                                        chunkSize=wordSizes.long;
                                                                                                                                        if(wordSizes.longlong>wordSizes.long)&&(wordSizes.longlongmode==1)
                                                                                                                                            chunkSize=wordSizes.longlong;
                                                                                                                                        end
                                                                                                                                        wordSizes.chunksize=chunkSize;


                                                                                                                                        function boolIsMultiWord=isDataTypeMultiWord(fxptype,wordSizes)

                                                                                                                                            if fxptype.isfixed&&(fxptype.WordLength>wordSizes.chunksize)
                                                                                                                                                boolIsMultiWord=true;
                                                                                                                                                return;
                                                                                                                                            end
                                                                                                                                            boolIsMultiWord=false;



                                                                                                                                            function possibleMoot=locSwitchBlockSaturMoot(curBlockObj,compiledPortDataType)



                                                                                                                                                possibleMoot=false;
                                                                                                                                                if isa(curBlockObj,'Simulink.Switch')||isa(curBlockObj,'Simulink.MultiPortSwitch')

                                                                                                                                                    allInportTypes=unique(compiledPortDataType.Inport);
                                                                                                                                                    allOutportTypes=unique(compiledPortDataType.Outport);

                                                                                                                                                    if isequal(allInportTypes,allOutportTypes)
                                                                                                                                                        possibleMoot=true;
                                                                                                                                                    end
                                                                                                                                                end


                                                                                                                                                function status=getResultsStatus(resultSet)

                                                                                                                                                    warn=false;
                                                                                                                                                    fail=false;
                                                                                                                                                    for idx=1:numel(resultSet)
                                                                                                                                                        if strcmp(resultSet{idx}.SubResultStatus,'Warn')
                                                                                                                                                            warn=true;
                                                                                                                                                        elseif strcmp(resultSet{idx}.SubResultStatus,'Fail')
                                                                                                                                                            fail=true;
                                                                                                                                                        end
                                                                                                                                                    end

                                                                                                                                                    if fail
                                                                                                                                                        status=false;
                                                                                                                                                    elseif warn
                                                                                                                                                        status=false;
                                                                                                                                                    else
                                                                                                                                                        status=true;
                                                                                                                                                    end


