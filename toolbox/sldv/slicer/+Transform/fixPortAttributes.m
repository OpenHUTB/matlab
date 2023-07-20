function simStateSlice=fixPortAttributes(slicedMdl,deviation,UImode,msObj)







    simStateSlice=[];

    fixedIdx=true(1,numel(deviation));
    Mex1=cell(1,numel(deviation));
    for i=1:length(deviation)
        dev=deviation(i);
        try
            switch dev.Attribute
            case 'CompiledPortAliasedThruDataType'
                dtStr=dev.OrigAttr;
                if sldvshareprivate('util_is_simulink_builtin',dtStr)
                    locSetParam(dev.SliceBlockHandle,'OutDataTypeStr',dtStr);
                    deviation(i).FixedAttr=dtStr;
                elseif sldvshareprivate('util_is_enum_type',dtStr)
                    locSetParam(dev.SliceBlockHandle,'OutDataTypeStr',['Enum: ',dtStr]);
                    deviation(i).FixedAttr=dtStr;
                elseif sldvshareprivate('util_is_fxp_type',dtStr,get_param(slicedMdl,'Handle'))
                    locSetParam(dev.SliceBlockHandle,'OutDataTypeStr',sprintf('fixdt(''%s'')',dtStr));
                    deviation(i).FixedAttr=dtStr;
                else
                    Mex1{end+1}=Transform.utilThrowPortAttrError(dev,'error');%#ok<AGROW>
                    fixedIdx(i)=false;
                end
            case 'CompiledPortDesignMax'
                DesignMax=num2str(dev.OrigAttr);
                locSetParam(dev.SliceBlockHandle,'OutMax',DesignMax);
                deviation(i).FixedAttr=DesignMax;
            case 'CompiledPortDesignMin'
                DesignMin=num2str(dev.OrigAttr);
                locSetParam(dev.SliceBlockHandle,'OutMin',DesignMin);
                deviation(i).FixedAttr=DesignMin;
            case 'CompiledPortDimensions'
                objParams=get_param(dev.SliceBlockHandle,'ObjectParameters');
                if isfield(objParams,'PortDimensions')
                    DimensionStr=getDimensionsStr(dev.OrigAttr);
                    locSetParam(dev.SliceBlockHandle,'PortDimensions',DimensionStr);
                    deviation(i).FixedAttr=DimensionStr;
                end
            case 'CompiledSampleTime'
                SampleTimeStr=getSampleTimeStr(dev.OrigAttr);
                if~isempty(SampleTimeStr)
                    locSetParam(dev.SliceBlockHandle,'SampleTime',SampleTimeStr);
                    deviation(i).FixedAttr=SampleTimeStr;
                end
            case 'CompiledPortComplexSignal'
                objParams=get_param(dev.SliceBlockHandle,'ObjectParameters');
                if isfield(objParams,'SignalType')
                    Complexity=getComplexityStr(dev.OrigAttr);
                    locSetParam(dev.SliceBlockHandle,'SignalType',Complexity);
                    deviation(i).FixedAttr=Complexity;
                end
            case 'CompiledPortFrameData'
                objParams=get_param(dev.SliceBlockHandle,'ObjectParameters');
                if isfield(objParams,'SamplingMode')
                    SamplingMode=getFrameDataStr(dev.OrigAttr);
                    locSetParam(dev.SliceBlockHandle,'SamplingMode',SamplingMode);
                    deviation(i).FixedAttr=SamplingMode;
                end
            otherwise




                Mex1{i}=Transform.utilThrowPortAttrError(dev,'error');
                fixedIdx(i)=false;
            end
        catch ex %#ok<NASGU>

            Mex1{i}=Transform.utilThrowPortAttrError(dev,'error');
            fixedIdx(i)=false;
        end
    end

    if UImode

        generateErrorInMessageViewer(Mex1,fixedIdx,true);
    else

    end


    try
        simHandler=[];
        if msObj.isSimStateSlice
            simHandler=Transform.configureSlicedModel4SimState(slicedMdl,msObj,false);
        end
        simStateSlice=Transform.compileSlicedModel(msObj,slicedMdl,simHandler);
        termCleanUp=onCleanup(@()Transform.terminateSlicedModel(msObj,slicedMdl,simHandler));

    catch ex
        Mex2=MException('ModelSlicer:SlicedModelFailedToCompile',...
        getString(message('Sldv:ModelSlicer:Transform:FailedCompileSlicedModel')));
        Mex2=Mex2.addCause(ex);
        if UImode
            modelslicerprivate('MessageHandler','error',Mex2);
            return;
        else
            throw(Mex2);
        end
    end


    Mex3={};
    infoIdx=[];
    errNum=1;
    for i=1:length(deviation)
        if~fixedIdx(i)
            continue;
        end
        try
            dev=deviation(i);
            fixed=true;
            if strcmp(dev.Attribute,'CompiledSampleTime')



                sliceAttr=get(dev.SliceBlockHandle,dev.Attribute);
                origAttr=get(dev.OrigBlockHandle,dev.Attribute);
                if~isequal(sliceAttr,origAttr)
                    dev.PrevAttr=getSampleTimeStr(dev.PrevAttr);
                    dev.OrigAttr=getSampleTimeStr(dev.OrigAttr);
                    fixed=false;
                end
            else
                sliceAttr=get(dev.SlicePortHandle,dev.Attribute);
                if~isequal(dev.OrigAttr,sliceAttr)
                    fixed=false;
                end
            end
            if~fixed
                Mex3{errNum}=Transform.utilThrowPortAttrError(dev,'error');%#ok<AGROW>
                infoIdx(errNum)=false;%#ok<AGROW>
            else
                Mex3{errNum}=Transform.utilThrowPortAttrError(dev,'info');%#ok<AGROW>
                infoIdx(errNum)=true;%#ok<AGROW>
            end
            errNum=errNum+1;
        catch
        end
    end

    if~isempty(Mex3)
        if UImode
            generateErrorInMessageViewer(Mex3,infoIdx,false);
        else

            ex=generateErrorException(Mex3,infoIdx);
            if~isempty(ex)
                Transform.terminateSlicedModel(msObj,slicedMdl);
                throw(ex);
            end
        end
    end
    Transform.terminateSlicedModel(msObj,slicedMdl,simHandler);
    if isempty(simStateSlice)


        save_system(slicedMdl,which(slicedMdl),'OverwriteIfChangedOnDisk',true);
    end
end

function ex=generateErrorException(mex,fixedIdx)



    errIdx=find(~fixedIdx);
    ex=[];
    for n=errIdx
        if~isempty(mex{n})
            if isempty(ex)
                ex=mex{n};
            else
                ex=ex.addCause(mex{n});
            end
        end
    end
end

function generateErrorInMessageViewer(mex,fixedIdx,onlyInfo)
    for n=1:length(mex)
        if~isempty(mex{n})
            if fixedIdx(n)
                modelslicerprivate('MessageHandler','info',mex{n})
            elseif~onlyInfo
                modelslicerprivate('MessageHandler','error',mex{n})
            end
        end
    end
end




function dimsStr=getDimensionsStr(compDims)
    assert(~isempty(compDims));
    if(compDims(1)>=2)
        nDims=compDims(1);
        dimsStr='';
        spcVal='';
        for k=1:nDims
            if k>1
                spcVal=' ';
            end
            dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
        end
        dimsStr=['[',dimsStr,']'];
    else
        dimsStr=sprintf('%d',compDims(2));
    end

end

function tsStr=getSampleTimeStr(compTs)
    assert(~isempty(compTs));



    if iscell(compTs)
        tsStr='';
    else






        if isinf(compTs(1))

            tsStr='inf';
        else
            if(length(compTs)==2)&&(compTs(1)==0)&&(compTs(2)==0)

                tsStr='0';
            else

                if(compTs(1)==-1&&compTs(2)==-1)
                    ts=compTs(3:4);
                else
                    ts=compTs;
                end

                tsStr=['[',sprintf('%.17g',ts(1)),',',sprintf('%.17g',ts(2)),']'];
            end
        end
    end
end

function Complexity=getComplexityStr(compComplex)
    if(compComplex==0)
        Complexity='real';
    else
        Complexity='complex';
    end
end
function SamplingMode=getFrameDataStr(compFrame)
    if compFrame==0
        SamplingMode='Sample based';
    else
        SamplingMode='Frame based';
    end
end

function locSetParam(h,param,val)


    if slfeature('CompositePortsAtRoot')==1...
        &&Simulink.BlockDiagram.Internal.isCompositePortBlock(h)...
        &&Simulink.BlockDiagram.Internal.isNonSupportedParamValueForBEP(param,val)
        throw(Transform.utilThrowPortAttrError(dev,'error'));
    else
        set_param(h,param,val);
    end
end
