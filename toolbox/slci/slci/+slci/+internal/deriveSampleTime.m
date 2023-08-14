












function sampleTime=deriveSampleTime(blkHandle)
    oldF=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);

    compiledSampleTime=get_param(blkHandle,'CompiledSampleTime');



    blockType=get_param(blkHandle,'BlockType');
    if strcmpi(blockType,'RootInportFunctionCallGenerator')
compiledSampleTime...
        =ignoreDiscreteRateFromRootInportFunctionCallGenerator(compiledSampleTime);
    end

    sampleTime=getDiscreteSampleTimes(compiledSampleTime);



    if isempty(sampleTime)



        if isTriggeredSampleTime(compiledSampleTime)

            sampleTime=deriveTriggeredToDiscreteSampleTime(blkHandle);
        elseif isConstantSampleTime(compiledSampleTime)||...
            isParameterSampleTime(compiledSampleTime)

            sampleTime=deriveConstantToDiscreteSampleTime(blkHandle);
        elseif isAsyncSampleTime(compiledSampleTime)
            sampleTime={compiledSampleTime};
        elseif isContinuousSampleTime(compiledSampleTime)



            if~iscell(compiledSampleTime)
                sampleTime={compiledSampleTime};
            else
                sampleTime=compiledSampleTime;
            end
        elseif isFixedInMinorStepSampleTime(compiledSampleTime)
            if~iscell(compiledSampleTime)
                sampleTime={compiledSampleTime};
            else
                sampleTime=compiledSampleTime;
            end
        end

    end

    assert(~isempty(sampleTime));

    slfeature('EngineInterface',oldF);
end


function out=getDiscreteSampleTimes(compiledSampleTime)
    out={};
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            tCompiledSampleTime=compiledSampleTime{i};
            if isDiscreteSampleTime(tCompiledSampleTime)
                out(end+1)={tCompiledSampleTime};%#ok
            end
        end
    else
        if isDiscreteSampleTime(compiledSampleTime)
            out(end+1)={compiledSampleTime};
        end
    end
end


function out=deriveTriggeredToDiscreteSampleTime(blkHandle)
    sampleTime=get_param(blkHandle,'CompiledSampleTime');
    parentHandle=blkHandle;


    while isTriggeredSampleTime(sampleTime)
        parentName=get_param(parentHandle,'Parent');
        try
            parentHandle=get_param(parentName,'Handle');
        catch


            out={[-1,-1]};
            return;
        end

        parentType=get_param(parentHandle,'Type');
        if strcmpi(parentType,'block_diagram')


            out={[-1,-1]};
            return;
        end

        sampleTime=get_param(parentHandle,'CompiledSampleTime');
    end

    sampleTime=filterParameterSampleTime(sampleTime);

    if(iscell(sampleTime))
        out=sampleTime(1);
        return;
    end

    out={sampleTime};
end


function out=deriveConstantToDiscreteSampleTime(blkHandle)
    out=dfsDerive(blkHandle);
end


function sampleTime=dfsDerive(blkHandle)
    compiledSampleTime=get_param(blkHandle,'CompiledSampleTime');

    discreteSampleTime=getDiscreteSampleTimes(compiledSampleTime);
    if~isempty(discreteSampleTime)
        sampleTime=discreteSampleTime;
        return;
    end


    blockType=get_param(blkHandle,'BlockType');
    if strcmpi(blockType,'Outport')...
        &&(isConstantSampleTime(compiledSampleTime)...
        ||isParameterSampleTime(compiledSampleTime))
        sampleTime=deriveConstantOrParameterSampleTime(compiledSampleTime);
        return;
    end


    if isTriggeredSampleTime(compiledSampleTime)
        sampleTime=deriveTriggeredToDiscreteSampleTime(blkHandle);
        return;
    end


    try
        blkObj=get_param(blkHandle,'Object');
        dsts=blkObj.getActualDst;
        if isempty(dsts)

            if(isConstantSampleTime(compiledSampleTime)...
                ||isParameterSampleTime(compiledSampleTime))
                sampleTime=deriveConstantOrParameterSampleTime(compiledSampleTime);
            elseif isFixedInMinorStepSampleTime(compiledSampleTime)
                if iscell(compiledSampleTime)
                    sampleTime=compiledSampleTime;
                else
                    sampleTime={compiledSampleTime};
                end
            end
            return;
        end
        dstPortHdls=dsts(:,1);
        samplePeriod=[];
        sampleOffset=[];
        for i=1:numel(dstPortHdls)
            blk=get_param(dstPortHdls(i),'Parent');
            dstBlkHandle=get_param(blk,'Handle');
            if strcmpi(get_param(dstBlkHandle,'BlockType'),'RateTransition')
                portSampleTime=get_param(dstPortHdls(i),'CompiledSampleTime');
                assert(~iscell(portSampleTime)&&...
                isDiscreteSampleTime(portSampleTime));
                inputSampleTime={portSampleTime};
            else
                inputSampleTime=dfsDerive(dstBlkHandle);
            end

            assert(numel(samplePeriod)==numel(sampleOffset));
            [samplePeriod,sampleOffset]...
            =getUniqueSampleTimes(samplePeriod,sampleOffset,inputSampleTime);
        end
    catch
        if(isConstantSampleTime(compiledSampleTime)...
            ||isParameterSampleTime(compiledSampleTime))
            sampleTime=deriveConstantOrParameterSampleTime(compiledSampleTime);
        elseif isFixedInMinorStepSampleTime(compiledSampleTime)
            if iscell(compiledSampleTime)
                sampleTime=compiledSampleTime;
            else
                sampleTime={compiledSampleTime};
            end
        end
        return;
    end
    if any((samplePeriod==-1)&(sampleOffset==-1))
        sampleTime={[-1,-1]};
        return;
    elseif any(isinf(samplePeriod)&(sampleOffset==0))
        sampleTime={[inf,0]};
        return;
    elseif any(isinf(samplePeriod)&isinf(sampleOffset))
        sampleTime={[inf,inf]};
        return;
    end
    if strcmpi(get_param(blkHandle,'BlockType'),'Ground')
        sampleTime={};
        for i=1:numel(samplePeriod)
            sampleTime{end+1}=[samplePeriod(i),sampleOffset(i)];%#ok
        end
    else
        [period,offset]=gcdOfSampleTimes(samplePeriod,sampleOffset);
        sampleTime={[period,offset]};
    end
end



function[samplePeriod,sampleOffset]=getUniqueSampleTimes(samplePeriod,sampleOffset,inputSampleTime)
    objectSampleTime=[];
    for idx=1:numel(samplePeriod)
        objectSampleTime=[objectSampleTime,slci.internal.SampleTime(...
        [samplePeriod(idx),sampleOffset(idx)])];
    end

    for idx1=1:numel(inputSampleTime)
        objectSampleTimeToFind=slci.internal.SampleTime(inputSampleTime{idx1});


        if(findSampleTime(objectSampleTimeToFind,objectSampleTime)==-1)
            objectSampleTime=[objectSampleTime,objectSampleTimeToFind];
            samplePeriod=[samplePeriod,objectSampleTimeToFind.getPeriod()];%#ok
            sampleOffset=[sampleOffset,objectSampleTimeToFind.getOffset()];%#ok
        end
    end
end


function index=findSampleTime(sampleTimeToFind,sampleTimeList)
    index=-1;
    for i=1:numel(sampleTimeList)
        if(isequal(sampleTimeToFind,sampleTimeList(i)))
            index=i;
            return;
        end
    end
end


function[period,offset]=gcdOfSampleTimes(samplePeriod,sampleOffset)
    period=computeGCD(samplePeriod);
    offset=computeGCD(sampleOffset);
end


function out=computeGCD(u)
    p=u(1);
    for i=2:numel(u)
        [~,D1]=rat(p);
        [~,D2]=rat(u(i));
        m=max(D1,D2);
        p1=p*m;
        p2=u(i)*m;
        p=double(gcd(int32(p1),int32(p2)))/m;
    end
    out=p;
end




function out=isDiscreteSampleTime(compiledSampleTime)
    out=false;
    s=slci.internal.SampleTime(compiledSampleTime);
    if s.isDiscrete()
        out=true;
    end
end


function out=isTriggeredSampleTime(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);
            out=s.isTriggered();
            if out
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isTriggered();
    end
end


function out=isAsyncSampleTime(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);
            out=s.isAsync();
            if out
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isAsync();
    end
end


function out=isContinuousSampleTime(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);
            out=s.isContinuous();
            if out
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isContinuous();
    end
end


function out=isFixedInMinorStepSampleTime(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);
            out=s.isFixedInMinorStep();
            if out
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isFixedInMinorStep();
    end
end



function out=isConstantSampleTime(compiledSampleTime)
    out=true;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);

            if~s.isConstant()
                out=false;
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isConstant();
    end
end





function out=isParameterSampleTime(compiledSampleTime)
    out=false;
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            aSampleTime=compiledSampleTime{i};
            assert(numel(aSampleTime)==2);
            s=slci.internal.SampleTime(aSampleTime);


            if s.isParameter()
                out=true;
            elseif~s.isConstant()
                out=false;
                return;
            end
        end
    else
        assert(numel(compiledSampleTime)==2);
        s=slci.internal.SampleTime(compiledSampleTime);
        out=s.isParameter();
    end
end


function out=filterParameterSampleTime(compiledSampleTime)
    if iscell(compiledSampleTime)&&(numel(compiledSampleTime)>1)
        out={};
        for i=1:numel(compiledSampleTime)
            if~isParameterSampleTime(compiledSampleTime{i})
                out{end+1}=compiledSampleTime{i};%#ok
            end
        end
    else
        out=compiledSampleTime;
    end

    if iscell(out)&&(numel(out)==1)
        out=cell2mat(out);
    end
end


function out=filterConstantSampleTime(compiledSampleTime)
    if iscell(compiledSampleTime)&&(numel(compiledSampleTime)>1)
        out={};
        for i=1:numel(compiledSampleTime)
            if~isConstantSampleTime(compiledSampleTime{i})
                out{end+1}=compiledSampleTime{i};%#ok
            end
        end
    else
        out=compiledSampleTime;
    end

    if iscell(out)&&(numel(out)==1)
        out=cell2mat(out);
    end
end


function sampleTime=deriveConstantOrParameterSampleTime(compiledSampleTime)
    sampleTime=compiledSampleTime;
    if(~iscell(compiledSampleTime))
        sampleTime={compiledSampleTime};
        return;
    end
    assert(iscell(compiledSampleTime));
    if isConstantSampleTime(compiledSampleTime)

        sampleTime=compiledSampleTime(1);
    elseif isParameterSampleTime(compiledSampleTime)
        sampleTime=filterConstantSampleTime(compiledSampleTime);
        assert(~iscell(sampleTime));
        sampleTime={sampleTime};
    end
    return;
end

function out=ignoreDiscreteRateFromRootInportFunctionCallGenerator(compiledSampleTime)
    out={};
    if iscell(compiledSampleTime)
        for i=1:numel(compiledSampleTime)
            if~isDiscreteSampleTime(compiledSampleTime{i})
                out{end+1}=compiledSampleTime{i};%#ok
            end
        end
        if(numel(out)==1)
            out=out{1};
        end
    else
        out=compiledSampleTime;
    end
end
