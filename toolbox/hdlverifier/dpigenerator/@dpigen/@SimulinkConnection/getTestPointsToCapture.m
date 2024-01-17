function[TestPointsToCaptureKeys,TestPointsLoggingSignalNames,TestPointLoggingFlatNames,TestPointLoggingRawNames]=getTestPointsToCapture(this)

    TestPointContainer=dpigenerator_getvariable('TestPointContainer');
    UniqueBaseRate=min(dpigenerator_getvariable('InputAndOutputSamplePeriods'));

    OutportSrcSID=l_getOutportSrcSID(this);

    TestPointsToCaptureKeys={};
    TestPointsLoggingSignalNames={};
    TestPointLoggingFlatNames={};
    TestPointLoggingRawNames={};

    idx_num=1;
    for idx=keys(TestPointContainer)
        keyval=idx{1};
        SrcBlockPortHandles=get_param(Simulink.ID.getHandle(TestPointContainer(keyval).SID),'PortHandles');
        if~strcmp(get_param(SrcBlockPortHandles.Outport(str2double(keyval(end))),'TestPoint'),'on')
            warning(message('HDLLink:DPIG:MaskedOrLibSusysNotLogged',Simulink.ID.getFullName(TestPointContainer(keyval).SID)));
            continue;
        end
        if~strcmp(get_param(SrcBlockPortHandles.Outport(str2double(keyval(end))),'DataLogging'),'on')

            continue;
        end

        if TestPointContainer(keyval).SamplePeriod~=UniqueBaseRate

            warning(message('HDLLink:DPIG:MultiRateTestPointNotLoggedForTB',Simulink.ID.getFullName(TestPointContainer(keyval).SID)));

            continue;
        end

        if any(strcmp(TestPointContainer(keyval).SID,OutportSrcSID))
            warning(message('HDLLink:DPIG:TestPointLogSameAsBlockIO'));
            continue;
        end

        TestPointsToCaptureKeys{idx_num}=keyval;%#ok<AGROW>

        if TestPointContainer(keyval).Duplicate
            TestPointsLoggingSignalNames{idx_num}=Simulink.BlockPath(Simulink.ID.getFullName(TestPointContainer(keyval).SID));%#ok<AGROW>
        else
            TestPointsLoggingSignalNames{idx_num}=TestPointContainer(keyval).RawSignalName;%#ok<AGROW>
        end
        if~isempty(TestPointContainer(keyval).StructInfo)
            for idx2=1:length(TestPointContainer(keyval).StructInfo)
                n_getFlatName(TestPointContainer(keyval).StructInfo(num2str(idx2)));
            end
        else
            TestPointLoggingFlatNames{end+1}=TestPointContainer(keyval).FlatName;%#ok<AGROW>
        end

        TestPointLoggingRawNames{idx_num}=TestPointContainer(keyval).RawSignalName;%#ok<AGROW>
        idx_num=idx_num+1;
    end


    function n_getFlatName(testPointInfo)
        if~isempty(testPointInfo.StructInfo)
            for idx3=1:length(testPointInfo.StructInfo)
                n_getFlatName(testPointInfo.StructInfo(num2str(idx3)));
            end
        else
            TestPointLoggingFlatNames{end+1}=testPointInfo.FlatName;
        end
    end

    function OutputSrcSid=l_getOutportSrcSID(this)

        TopLevelName=dpigenerator_getvariable('dpigSubsystemPath');
        dutName=this.System;


        hSubsystem=get_param(dutName,'handle');



        oph=find_system(hSubsystem,...
        'SearchDepth',1,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'BlockType','Outport');

        OutputSrcSid=cell(1,length(oph));
        for ii=1:length(oph)
            pconn=get_param(oph(ii),'PortConnectivity');
            OutputSrcSid{ii}=[TopLevelName,':',get_param(pconn(1).SrcBlock,'SID')];
        end
    end
end
