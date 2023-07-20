function v=validateSinglerateSharing(this,~,~)


    maxOversampling=hdlgetparameter('maxoversampling');
    loopOptimization=getImplParams(this,'LoopOptimization');
    loopStreaming=strcmpi(loopOptimization,'Streaming');
    ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
    ramMapping=strcmpi(ramMapping,'on');
    sharingFactor=getImplParams(this,'SharingFactor');
    sharingOn=~isempty(sharingFactor)&&sharingFactor>1;
    singleratesharing=maxOversampling==1;

    v=hdlvalidatestruct;
    if singleratesharing&&loopStreaming
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:singlerateloopstreaming'));
    end

    if singleratesharing&&ramMapping
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:singleraterammapping'));
    end

    if singleratesharing&&sharingOn
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:singleratemlsharing'));
    end
end



