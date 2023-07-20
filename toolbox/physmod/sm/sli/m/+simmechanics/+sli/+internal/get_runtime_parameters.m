function rtpNames=get_runtime_parameters(blkType)





    rtpNames={};
    rtps=[];
    blkInfoMap=simmechanics.sli.internal.getTypeIdBlockInfoMap;

    if(blkInfoMap.isKey(blkType))
        blkInfo=blkInfoMap(blkType);

        configSettings={blkInfo.MaskParameters.RuntimeConfigurable};
        isConfig=strcmpi(configSettings,'on');

        rtps=blkInfo.MaskParameters(isConfig);
    end

    if~isempty(rtps)
        rtpNames={rtps.VarName};
    end
