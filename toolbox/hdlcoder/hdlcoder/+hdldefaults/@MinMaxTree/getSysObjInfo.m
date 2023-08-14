function blockInfo=getSysObjInfo(this,sysObj)%#ok<INUSL>



    if isa(sysObj,'dsp.Minimum')
        blockInfo.compType='min';
        runningProp='RunningMinimum';
    else
        blockInfo.compType='max';
        runningProp='RunningMaximum';
    end

    if sysObj.(runningProp)
        blockInfo.fcnString='Running';
        blockInfo.idxBase=0;
    else
        valPort=sysObj.ValueOutputPort;
        idxPort=sysObj.IndexOutputPort;

        if valPort&&idxPort
            blockInfo.fcnString='Value and Index';
            blockInfo.idxBase=sysObj.IndexBase;
        elseif valPort&&~idxPort
            blockInfo.fcnString='Value';
            blockInfo.idxBase=0;
        elseif~valPort&&idxPort
            blockInfo.fcnString='Index';
            blockInfo.idxBase=sysObj.IndexBase;
        end
    end

    blockInfo.blockType='dsp';
    blockInfo.rndMode='Floor';
    blockInfo.satMode=false;
    blockInfo.isDSP=true;

