function RadarSubarrayCustomSteering(obj)



    SubarrayBlocks=obj.findBlocksOfType('MATLABSystem');
    if isR2017aOrEarlier(obj.ver)
        ws=warning('off','shared_channel:arrayelemdef:ObsoletePropertyByTwoProperties');
        release_str=obj.ver.release;
        for i=1:numel(SubarrayBlocks)
            blk=SubarrayBlocks{i};
            blkSystem=get_param(blk,'System');
            if strcmp(blkSystem,'radar.internal.SimulinkConstantGammaClutter')||...
                strcmp(blkSystem,'gpuConstantGammaClutter')
                custStr=get_param(blk,'Sensor');
                custStr=replaceSubarrayCustomSteeringString(custStr,release_str);

                set_param(blk,'Sensor',custStr);

            end
        end
        warning(ws);
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
