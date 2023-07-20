function ts=createTimeseriesForExport(time,data,info,bAllEmptyChunks,bCreateSeed)




    if bCreateSeed
        ts=locCreateSeed(info);
        return
    end


    if bAllEmptyChunks
        len=length(data);
        ts(len)=timeseries();
        return
    end


    data=cellfun(...
    @(dataVec,timeVec,typeVec,is1d,compressLen,strVals)loc_castCustomTypes(dataVec,timeVec,typeVec,is1d,compressLen,strVals),...
    data,...
    time,...
    {info.Type}',...
    {info.Is1D}',...
    {info.CompressedTimeLen}',...
    {info.StringValues}',...
    'uniformoutput',false);








    canBeMassConstructed=~cellfun(@(dataVec,timeVec,hasDups,hasInterp3d,fixedInc,isVarDims)(...
    length(size(dataVec))>2||...
    length(timeVec)==1||...
    ~isreal(dataVec)||...
    hasDups||...
    hasInterp3d||...
    fixedInc>0||...
    isVarDims),...
    data,...
    time,...
    {info.HasDuplicateTimes}',...
    {info.InterpretAs3D}',...
    {info.CompressedTimeInc}',...
    {info.IsVarDims}');
    cannotBeMassConstructed=find(~canBeMassConstructed);


    if isempty(cannotBeMassConstructed)
        ts=timeseries.utcreatearraywithoutcheck(...
        data(canBeMassConstructed),time(canBeMassConstructed));
    else


        ts=repmat(timeseries,1,length(data));


        if any(canBeMassConstructed)
            ts(canBeMassConstructed)=timeseries.utcreatearraywithoutcheck(...
            data(canBeMassConstructed),time(canBeMassConstructed));
        end


        for idx=1:length(cannotBeMassConstructed)
            tsIdx=cannotBeMassConstructed(idx);

            dataVal=data{tsIdx};

            if length(size(dataVal))==2&&isCustomConstructedType(info(tsIdx))
                dataVal=dataVal.';
            end


            if info(tsIdx).CompressedTimeInc>0&&info(tsIdx).CompressedTimeLen>0
                if info(tsIdx).CompressedTimeLen==1
                    ts(tsIdx)=...
                    timeseries.utcreatewithoutcheck(dataVal,...
                    info(tsIdx).CompressedTimeStart,...
                    info(tsIdx).InterpretAs3D,...
                    info(tsIdx).HasDuplicateTimes);
                else
                    ts(tsIdx)=timeseries.utcreateuniformwithoutcheck(...
                    dataVal,...
                    info(tsIdx).CompressedTimeLen,...
                    info(tsIdx).CompressedTimeStart,...
                    info(tsIdx).CompressedTimeInc,...
                    info(tsIdx).InterpretAs3D);
                end
            else

                timeVal=transpose(time{tsIdx});


                ts(tsIdx)=...
                timeseries.utcreatewithoutcheck(dataVal,...
                timeVal,...
                info(tsIdx).InterpretAs3D,...
                info(tsIdx).HasDuplicateTimes);
            end
        end
    end


    ts=loc_setTSInfo(ts,info);
end


function val=isCustomConstructedType(info)
    val=false;
    if isfield(info.Type,'Label')||...
        isfield(info.Type,'Signedness')||...
        isfield(info.Type,'Half')||...
        (~isempty(info.StringValues)||ischar(info.StringValues))
        val=true;
    end
end


function data=loc_castCustomTypes(data,time,type,is1D,compressLen,strVals)

    if iscell(data)
        for idx=1:numel(data)
            if is1D
                data{idx}=data{idx}.';
            end
            data{idx}=loc_castCustomTypes(data{idx},time,type,true,1,strVals);
        end
        return
    end


    if isfield(type,'Label')
        try
            data=Simulink.sdi.internal.createEnumValuesFromClassDefinition(...
            type.Name,...
            type.Label,...
            type.Value,...
            data,...
            false);
        catch me


            Simulink.sdi.internal.warning(me.identifier,me.message);
        end


    elseif isfield(type,'Signedness')
        data=Simulink.sdi.internal.createFiObjectFromMetadataAndRealWorldValues(...
        type,...
        data,...
        false);
        if isempty(data)&&~isfi(data)

            if compressLen>0
                numTimePts=compressLen;
            else
                numTimePts=length(time);
            end
            data=nan(1,numTimePts);
        end


    elseif isfield(type,'Half')
        data=half.typecast(data);
    end


    if~is1D&&(length(time)==1||compressLen==1)&&ismatrix(data)
        data=transpose(data);
    end


    if~isempty(strVals)||ischar(strVals)
        data=Simulink.sdi.internal.convertNumericToString(data,strVals);
    end
end


function ts=loc_setTSInfo(ts,info)
    for idx=1:length(ts)
        if info(idx).HasDuplicateTimes
            ts(idx).TimeInfo.DuplicateTimes=true;
        end
        ts(idx).DataInfo.Interpolation=tsdata.interpolation(info(idx).Interp);
        if~isempty(info(idx).Units)
            ts(idx).Datainfo.Units=Simulink.SimulationData.Unit(info(idx).Units);
        end
    end
end


function ts=locCreateSeed(info)

    len=numel(info);
    ts(len)=timeseries();
    for idx=1:len
        typeStr=locGetSeedTypeFromInfo(info(idx));
        ts(idx)=Simulink.SimulationData.utCreateTimeseriesSeed(typeStr,info(idx).Units);
    end
end


function ret=locGetSeedTypeFromInfo(info)
    ret='';
    if isfield(info.Type,'Label')

        ret=info.Type.Name;
    elseif isfield(info.Type,'Signedness')

        if isfield(info.Type,'NumericDataType')&&strcmp(info.Type,'ScaledDouble')
            if isfield(info.Type,'SlopeAdjustmentFactor')
                ret='fiScaledDoubleSlopeBiasScaling';
            else
                ret='fiScaledDoubleBinaryPointScaling';
            end
        elseif isfield(info.Type,'FractionLength')
            ret='fiFixptBinaryPointScaling';
        elseif isfield(info.Type,'SlopeAdjustmentFactor')
            ret='fiFixptSlopeBiasScaling';
        else
            ret='fi()';
        end
    end
end
