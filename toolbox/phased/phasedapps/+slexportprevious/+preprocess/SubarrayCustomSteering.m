function SubarrayCustomSteering(obj)



    SubarrayBlocks=obj.findBlocksOfType('MATLABSystem');
    if isR2017aOrEarlier(obj.ver)
        release_str=obj.ver.release;
        for i=1:numel(SubarrayBlocks)
            blk=SubarrayBlocks{i};
            blkSystem=get_param(blk,'System');
            if strcmp(blkSystem,'phased.Radiator')||...
                strcmp(blkSystem,'phased.Collector')||...
                strcmp(blkSystem,'phased.WidebandRadiator')||...
                strcmp(blkSystem,'phased.WidebandCollector')
                custStr=get_param(blk,'Sensor');
                custStr=replaceSubarrayCustomSteeringString(custStr,release_str);

                set_param(blk,'Sensor',custStr);

            elseif strcmp(blkSystem,'phased.PhaseShiftBeamformer')||...
                strcmp(blkSystem,'phased.MVDRBeamformer')||...
                strcmp(blkSystem,'phased.TimeDelayBeamformer')||...
                strcmp(blkSystem,'phased.FrostBeamformer')||...
                strcmp(blkSystem,'phased.TimeDelayLCMVBeamformer')||...
                strcmp(blkSystem,'phased.GSCBeamformer')||...
                strcmp(blkSystem,'phased.SubbandPhaseShiftBeamformer')||...
                strcmp(blkSystem,'phased.SubbandMVDRBeamformer')||...
                strcmp(blkSystem,'phased.BeamscanEstimator')||...
                strcmp(blkSystem,'phased.BeamscanEstimator2D')||...
                strcmp(blkSystem,'phased.MVDREstimator')||...
                strcmp(blkSystem,'phased.MVDREstimator2D')||...
                strcmp(blkSystem,'phased.MUSICEstimator')||...
                strcmp(blkSystem,'phased.MUSICEstimator2D')||...
                strcmp(blkSystem,'phased.BeamspaceESPRITEstimator')||...
                strcmp(blkSystem,'phased.ESPRITEstimator')||...
                strcmp(blkSystem,'phased.GCCEstimator')||...
                strcmp(blkSystem,'phased.RootMUSICEstimator')||...
                strcmp(blkSystem,'phased.RootWSFEstimator')||...
                strcmp(blkSystem,'phased.SumDifferenceMonopulseTracker')||...
                strcmp(blkSystem,'phased.SumDifferenceMonopulseTracker2D')||...
                strcmp(blkSystem,'phased.AnleDopplerResponse')||...
                strcmp(blkSystem,'phased.DPCACanceller')||...
                strcmp(blkSystem,'phased.ADPCACanceller')||...
                strcmp(blkSystem,'phased.STAPSMIBeamformer')

                custStr=get_param(blk,'SensorArray');
                custStr=replaceSubarrayCustomSteeringString(custStr,release_str);

                set_param(blk,'SensorArray',custStr);
            end
        end
    end
end

function custStr=replaceSubarrayCustomSteeringString(custStr,release_str)
    tgtstr='''SubarraySteering'',''Custom''';
    tgtstridx=strfind(custStr,tgtstr);
    if~isempty(tgtstridx)
        tgtstrendidx=tgtstridx+length(tgtstr)-1;
        if custStr(tgtstrendidx+1)==','
            tgtstrendidx=tgtstrendidx+1;
        elseif custStr(tgtstridx-1)==','
            tgtstridx=tgtstridx-1;
        end
        custStr(tgtstridx:tgtstrendidx)='';
        warning(message('phased:system:array:SubarrayCustomSteeringExportToPreviousWarning',...
        'SubarraySteering','Custom',release_str));
    end
end
