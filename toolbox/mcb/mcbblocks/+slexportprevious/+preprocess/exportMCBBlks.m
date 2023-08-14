function exportMCBBlks(obj)





    if isReleaseOrEarlier(obj.ver,'R2021b')
        exportVer=obj.ver;


        mdlBlkName=obj.findLibraryLinksTo("slpidlib/PID Controller");

        if~isempty(mdlBlkName)
            for idx=1:length(mdlBlkName)



                sid=get_param(mdlBlkName{idx},'SID');
                LimOutput=get_param(mdlBlkName{1},'LimitOutput');
                UpperSaturationLimit=get_param(mdlBlkName{idx},'UpperSaturationLimit');
                LowerSaturationLimit=get_param(mdlBlkName{idx},'LowerSaturationLimit');
                ExtReset=get_param(mdlBlkName{idx},'ExternalReset');
                IntegratorFF=get_param(mdlBlkName{idx},'InitialConditionSource');
                IntegratorInitCondition=get_param(mdlBlkName{1},'InitialConditionForIntegrator');
                [~,librarySourceBlock]=slInternal('getBlocksProductInfoAndLibrary',mdlBlkName{idx});


                if(strcmp(librarySourceBlock,'mcbcontrolslib/PI Controller')||strcmp(librarySourceBlock,'mcblib/Controls/Controllers/PI Controller'))
                    if(strcmp(LimOutput,'off')&&strcmp(UpperSaturationLimit,'inf')&&strcmp(LowerSaturationLimit,'-inf')&&strcmp(ExtReset,'none')...
                        &&strcmp(IntegratorFF,'internal')&&strcmp(IntegratorInitCondition,'0'))



                        obj.appendRule(['<Block<SID|"',sid,'"><SourceBlock:repval "mcbcontrolslib/Discrete PI Controller">>']);



                        obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UpperSaturationLimit',exportVer));
                        obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'LowerSaturationLimit',exportVer));
                    else

                        obj.appendRule(['<Block<SID|"',sid,'"><SourceBlock:repval "mcbcontrolslib/Discrete PI Controller  with anti-windup && reset">>']);
                    end



                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Form',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'TimeDomain',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UseExternalTs',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SampleTime',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorMethod',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterMethod',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ControllerParametersSource',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'P',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'I',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UseKiTs',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'D',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'N',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UseFilter',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'TunerSelectOption',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ZeroCross',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'InitialConditionSource',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'InitialConditionForIntegrator',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'InitialConditionForFilter',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DifferentiatorICPrevScaledInput',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ExternalReset',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IgnoreLimit',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'TrackingMode',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Kt',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'LimitOutput',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SatLimitsSource',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'LinearizeAsGain',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'AntiWindupMode',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Kb',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'RndMeth',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SaturateOnIntegerOverflow',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'LockScale',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'PGainOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'PProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'POutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'POutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IGainOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DGainOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NGainOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SaturationOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SaturationOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SaturationOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'PParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'PParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'PParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtParamDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtParamMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtParamMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KbOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'KtOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI1OutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI1OutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI1OutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI2OutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI2OutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI2OutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI3OutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI3OutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI3OutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI4OutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI4OutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI4OutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI1AccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI2AccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI3AccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumI4AccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DifferentiatorOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DifferentiatorOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DifferentiatorOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffNumProductOutputDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffDenProductOutputDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffNumAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffDenAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffOutCoefDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffOutCoefMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterDiffOutCoefMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ReciprocalOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ReciprocalOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ReciprocalOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDenOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDenOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDenOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumNumOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumNumOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumNumOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumDenAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'SumNumAccumDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DivideOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DivideOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'DivideOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UdiffTsProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UdiffTsProdOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UdiffTsProdOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NTsProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NTsProdOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'NTsProdOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UintegralTsProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UintegralTsProdOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UintegralTsProdOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UngainTsProdOutDataTypeStr',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UngainTsProdOutMin',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'UngainTsProdOutMax',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorContinuousStateAttributes',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorStateIdentifier',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'IntegratorStateMustResolveToSignalObject',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterContinuousStateAttributes',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterStateIdentifier',exportVer));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FilterStateMustResolveToSignalObject',exportVer));

                end
            end
        end


        mdlBlkName=obj.findLibraryLinksTo("instrumentseriallib/Serial Send");
        for idx=1:length(mdlBlkName)

            aMode=get_param(mdlBlkName{idx},'aMode');


            if(~isempty(mdlBlkName)&&strcmp(aMode,'5'))
                sid=get_param(mdlBlkName{idx},'SID');
                obj.appendRule(['<Block<SID|"',sid,'"><SourceBlock:repval "mcbhostblockslib/Host Serial Transmit">>']);


                header=get_param(mdlBlkName{idx},'Header');
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Header','header'));
                if(strcmp(header,'[]'))
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'header',convertStringsToChars("''")));
                end


                terminator=get_param(mdlBlkName{idx},'Terminator');
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Terminator','tail'));
                if(strcmp(terminator,'Custom terminator'))
                    tail=get_param(mdlBlkName{idx},'CustomTerminator');
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'tail',tail));
                elseif(strcmp(terminator,'<none>'))
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'tail',convertStringsToChars("''")));
                end


                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'EnableBlockingMode','enableBlockingMode'));


                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'aMode',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Port',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'CustomTerminator',exportVer));
            end
        end


        mdlBlkName=obj.findLibraryLinksTo("instrumentseriallib/Serial Receive");
        for idx=1:length(mdlBlkName)

            aMode=get_param(mdlBlkName{idx},'aMode');


            if(~isempty(mdlBlkName)&&strcmp(aMode,'5'))
                sid=get_param(mdlBlkName{idx},'SID');
                obj.appendRule(['<Block<SID|"',sid,'"><SourceBlock:repval "mcbhostblockslib/Host Serial Receive">>']);


                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'DataType','dataType'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'DataSize','dataDim'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'CustomValue','errValue'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'SampleTime','sampleTime'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'EnableBlockingMode','blockingMode'));


                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Header','dataHead'));
                toggleHeader=get_param(mdlBlkName{idx},'ToggleHeader');
                if(strcmp(toggleHeader,'off'))
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'dataHead',convertStringsToChars("''")));
                end


                toggleTerminator=get_param(mdlBlkName{idx},'ToggleTerminator');
                terminatorSel=get_param(mdlBlkName{idx},'Terminator');
                if(strcmp(toggleTerminator,'off'))
                    obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Terminator','dataTail'));
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'dataTail',convertStringsToChars("''")));
                elseif(strcmp(terminatorSel,'Custom terminator'))
                    obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'CustomTerminator','dataTail'));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Terminator',exportVer));
                else
                    obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Terminator','dataTail'));
                    obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'CustomTerminator',exportVer));
                end

                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'ActionDataUnavailable','errOption'));
                errOption=get_param(mdlBlkName{idx},'ActionDataUnavailable');
                if(strcmp(errOption,'Output last received value'))
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'errOption','Output the last received value'));
                end


                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'aMode',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'Port',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'InputFormat',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ToggleTerminator',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'ToggleHeader',exportVer));
            end
        end


        mdlBlkName=obj.findLibraryLinksTo("instrumentseriallib/Serial Configuration");
        for idx=1:length(mdlBlkName)

            aMode=get_param(mdlBlkName{idx},'aMode');


            if(~isempty(mdlBlkName)&&strcmp(aMode,'5'))
                sid=get_param(mdlBlkName{idx},'SID');
                obj.appendRule(['<Block<SID|"',sid,'"><SourceBlock:repval "mcbhostblockslib/Host Serial Setup">>']);


                portValue=get_param(mdlBlkName{idx},'Port');
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Port','comPortSer1'));
                if strcmpi(portValue,'<Select a port...>')
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'comPortSer1','''Please_select_a_port'''));
                else
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'comPortSer1',convertStringsToChars(join(["'",portValue,"'"],''))));
                end


                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'BaudRate','baudRateA'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'DataBits','charLenA'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'StopBits','stopBitA'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Parity','parityA'));
                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'Timeout','timeoutA'));


                obj.appendRule(parameterRenameRule(exportVer.isSLX,sid,'ByteOrder','ByteOrderA'));
                byteOrder=get_param(mdlBlkName{idx},'ByteOrder');
                if strcmpi(byteOrder,'little-endian')
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrderA','LittleEndian'));
                else
                    obj.appendRule(changeParameterValueRule(exportVer.isSLX,sid,'ByteOrderA','BigEndian'));
                end


                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'aMode',exportVer));
                obj.appendRule(slexportprevious.rulefactory.removeInstanceParameter(sprintf('<BlockType|"Reference"><SID|"%s">',sid),'FlowControl',exportVer));
            end
        end
    end
    if isReleaseOrEarlier(obj.ver,'R2022a')
        mdlBlkName=obj.findLibraryLinksTo("mcbpmsmnonlinearlib/PMSM FeedForward Control");
        for idx=1:length(mdlBlkName)
            obj.appendRules('<Block<SourceBlock|"mcbpmsmnonlinearlib/PMSM FeedForward Control":repval "mcbcontrolslib/PMSM Feed Forward Control">>');
        end
        mdlBlkName=obj.findLibraryLinksTo("mcbpmsmnonlinearlib/PMSM Torque Estimator");
        for idx=1:length(mdlBlkName)
            obj.appendRules('<Block<SourceBlock|"mcbpmsmnonlinearlib/PMSM Torque Estimator":repval "mcbcontrolslib/PMSM Torque Estimator">>');
        end
        mdlBlkName=obj.findLibraryLinksTo("mcbresolverdecoderlib/Resolver Decoder");
        for idx=1:length(mdlBlkName)
            obj.appendRules('<Block<SourceBlock|"mcbresolverdecoderlib/Resolver Decoder":repval "mcbpositiondecoderlib/Resolver Decoder">>');
        end
    end


    function rule=parameterRenameRule(isSLX,sid,currentName,newName)

        if isSLX
            rule=sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData<%s:rename %s>>>',sid,currentName,newName);
        else
            rule=sprintf('<Block<SID|"%s"><%s:rename %s>>',sid,currentName,newName);
        end
    end


    function rule=changeParameterValueRule(isSLX,sid,name,value)

        if isSLX
            rule=sprintf('<Block<BlockType|"Reference"><SID|"%s"><InstanceData<%s:repval "%s">>>',sid,name,value);
        else
            rule=sprintf('<Block<SID|"%s"><%s:repval "%s">>',sid,name,value);
        end
    end
end