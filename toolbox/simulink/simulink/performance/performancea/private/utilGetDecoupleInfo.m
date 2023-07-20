function compInfo=utilGetDecoupleInfo(model)


    compInfo={};


    compiledHmax=get_param(model,'ContMaxStepSize');
    DiscDriContblkList=feval(model,'get','discDerivSig');
    numDiscDriCont=length(DiscDriContblkList);
    discDriContSampleTimes=[];
    for i=1:numDiscDriCont
        discTs=get_param(DiscDriContblkList(i).block,'CompiledSampleTime');

        if iscell(discTs)
            for j=1:length(discTs)
                discDriContSampleTimes(end+1)=discTs{j}(1);
            end
        else
            discDriContSampleTimes(end+1)=discTs(1);
        end
    end


    sDiscTs=Inf;
    sampleTimes=get_param(model,'SampleTimes');
    for i=1:length(sampleTimes)
        if~isempty(sampleTimes(i).Value)&&isnumeric(sampleTimes(i).Value)
            discTs=sampleTimes(i).Value(1);
            if(discTs>0)&&(discTs<sDiscTs)&&~ismember(discTs,discDriContSampleTimes)
                sDiscTs=discTs;
            end
        end
    end

    ratio=sDiscTs/compiledHmax;
    if ratio<1
        newDecoupleCD=true;
    else
        newDecoupleCD=false;
    end

    compInfo{1}=newDecoupleCD;
    compInfo{2}=compiledHmax;
    compInfo{3}=sDiscTs;
end
