function res=ioConnectedToIRTFunction(model)
    res=false;
    inportBlks=find_system(model,'SearchDepth',1,'type','Block','BlockType','Inport');
    outportBlks=find_system(model,'SearchDepth',1,'type','Block','BlockType','Outport');
    ioBlks=[inportBlks;outportBlks];
    for i=1:length(ioBlks)
        sampleTs=get_param(ioBlks{i},'CompiledSampleTime');
        if~iscell(sampleTs)
            sampleTs={sampleTs};
        end
        for j=1:length(sampleTs)
            elemTs=sampleTs{j};
            if~isfinite(elemTs(1))&&elemTs(2)>0&&isfinite(elemTs(2))
                res=true;
                break;
            end
        end
    end
end
