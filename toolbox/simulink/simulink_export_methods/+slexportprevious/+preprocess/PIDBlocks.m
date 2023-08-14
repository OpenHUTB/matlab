function PIDBlocks(obj)






    if isR2022aOrEarlier(obj.ver)



        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"slpidlib/PID Controller">';...
        '<SourceBlock|"slpidlib/PID Controller (2DOF)">'};


        paramsToRemove={'LimitIntegrator'
'UpperIntegratorSaturationLimit'
'LowerIntegratorSaturationLimit'
'ClampingZeroOutDataTypeStr'
'ClampingZeroOutMin'
'ClampingZeroOutMax'
'FilterDenConstantOutDataTypeStr'
'FilterDenConstantOutMin'
'FilterDenConstantOutMax'
'PCopyOutDataTypeStr'
'PCopyOutMin'
'PCopyOutMax'
'NCopyOutDataTypeStr'
'NCopyOutMin'
        'NCopyOutMax'};
        idx=0;

        ruleRemovePIDVariantParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDVariantParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDVariantParams);
    end

    if isR2021bOrEarlier(obj.ver)



        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"slpidlib/PID Controller">';...
        '<SourceBlock|"slpidlib/PID Controller (2DOF)">'};


        paramsToRemove={'UseKiTs'};
        idx=0;

        ruleRemovePIDVariantParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDVariantParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDVariantParams);
    end

    if isR2021aOrEarlier(obj.ver)




        obj.appendRules('<Block<SourceBlock|"slpidlib/PID Controller":repval "pid_lib/PID Controller">>');


        obj.appendRules('<Block<SourceBlock|"slpidlib/PID Controller (2DOF)":repval "pid_lib/PID Controller (2DOF)">>');
    end

    if isR2020aOrEarlier(obj.ver)




        obj.appendRules('<Block<SourceBlock|"pid_lib/PID Controller":repval "simulink/Continuous/PID Controller">>');


        obj.appendRules('<Block<SourceBlock|"pid_lib/PID Controller (2DOF)":repval "simulink/Continuous/PID Controller (2DOF)">>');





        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"simulink/Continuous/PID Controller">';...
        '<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">'};


        paramsToRemove={'SatLimitsSource';'ExternalSaturationOutDataTypeStr'};

        ruleRemovePIDVariantParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        idx=0;
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDVariantParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDVariantParams);
    end

    if isR2019bOrEarlier(obj.ver)




        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"simulink/Continuous/PID Controller">';...
        '<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">'};


        paramsToRemove={'UseExternalTs'
'UdiffTsProdOutDataTypeStr'
'UdiffTsProdOutMin'
'UdiffTsProdOutMax'
'NTsProdOutDataTypeStr'
'NTsProdOutMin'
'NTsProdOutMax'
'UintegralTsProdOutDataTypeStr'
'UintegralTsProdOutMin'
'UintegralTsProdOutMax'
'UngainTsProdOutDataTypeStr'
'UngainTsProdOutMin'
'UngainTsProdOutMax'
'TsampFilterVariant'
'TsampNgainVariant'
        'TsampIntegralVariant'};
        idx=0;

        ruleRemovePIDVariantParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDVariantParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDVariantParams);
    end

    if isR2018aOrEarlier(obj.ver)



        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"simulink/Continuous/PID Controller">';...
        '<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">'};


        paramsToRemove={'SumI4OutDataTypeStr'
'SumI4OutMin'
'SumI4OutMax'
'SumI4AccumDataTypeStr'
'ParallelPVariant'
'IdealPVariant'
'IVariant'
'DVariant'
'IntegratorVariant'
'SatVariant'
'AWVariant'
'PCopyVariant'
'TRVariant'
'FdbkBlocksVariant'
'IdealPFdbkVariant'
'SatFdbkVariant'
'DerivativeFilterVariant'
'NVariant'
'NCopyVariant'
'FilterICVariant'
'IntegratorICVariant'
'ExternalResetVariant'
'TRSumVariant'
'SumFdbkVariant'
'SumVariant'
'bVariant'
        'cVariant'};
        idx=0;

        ruleRemovePIDVariantParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDVariantParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDVariantParams);
    end

    if isR2017bOrEarlier(obj.ver)


        srcBlocks={'<SourceBlock|"simulink/Continuous/PID Controller">';...
        '<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">'};
        param='<InitialConditionSetting|Auto:repval "State (most efficient)">';

        for ii=1:length(srcBlocks)
            block=['<BlockType|Reference>',srcBlocks{ii}];
            if obj.ver.isR2015aOrEarlier||~obj.ver.isSLX
                Rule=sprintf('<Block%s%s>',block,param);
            else
                Rule=sprintf('<Block%s<InstanceData%s>>',block,param);
            end
            obj.appendRules(Rule);
        end

    end

    if isR2017aOrEarlier(obj.ver)



        import slexportprevious.rulefactory.*


        srcBlocks={'<SourceBlock|"simulink/Continuous/PID Controller">';...
        '<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">'};


        paramsToRemove={'FilterDiffNumProductOutputDataTypeStr';...
        'FilterDiffDenProductOutputDataTypeStr';...
        'FilterDiffNumAccumDataTypeStr';...
        'FilterDiffDenAccumDataTypeStr';...
        'FilterDiffOutCoefMin';...
        'FilterDiffOutCoefMax';...
        'FilterDiffOutCoefDataTypeStr';...
        'SumDenAccumDataTypeStr';...
        'SumDenOutMin';...
        'SumDenOutMax';...
        'SumDenOutDataTypeStr';...
        'SumNumAccumDataTypeStr';...
        'SumNumOutMin';...
        'SumNumOutMax';...
        'SumNumOutDataTypeStr';...
        'ReciprocalOutMin';...
        'ReciprocalOutMax';...
        'ReciprocalOutDataTypeStr';...
        'DivideOutMin';...
        'DivideOutMax';...
        'DivideOutDataTypeStr';...
        'TunerSelectOption'};
        idx=0;

        ruleRemovePIDFilterIntegratorParams=cell(1,length(srcBlocks)*length(paramsToRemove));
        for ii=1:length(srcBlocks)
            for jj=1:length(paramsToRemove)
                idx=idx+1;
                ruleRemovePIDFilterIntegratorParams{idx}=removeInstanceParameter(srcBlocks{ii},paramsToRemove{jj},obj.ver);
            end
        end
        obj.appendRules(ruleRemovePIDFilterIntegratorParams);
    end

    if isR2016bOrEarlier(obj.ver)



        import slexportprevious.rulefactory.*
        ruleRemovePIDInitialConditionSetting{1}=removeInstanceParameter('<SourceBlock|"simulink/Continuous/PID Controller">','InitialConditionSetting',obj.ver);
        ruleRemovePIDInitialConditionSetting{2}=removeInstanceParameter('<SourceBlock|"simulink/Continuous/PID Controller (2DOF)">','InitialConditionSetting',obj.ver);
        obj.appendRules(ruleRemovePIDInitialConditionSetting);
    end

    if isR2009aOrEarlier(obj.ver)




        pidBlks=obj.findBlocksWithMaskType('PID 1dof');
        obj.replaceWithEmptySubsystem(pidBlks);


        pidBlks=obj.findBlocksWithMaskType('PID 2dof');
        obj.replaceWithEmptySubsystem(pidBlks);
    end
