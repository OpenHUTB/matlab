function[enumName,networks]=getClassifierEnumName(model,block)

    blocks=getClassifierBlocks(model);
    networks=cell(size(blocks));

    for i=1:length(blocks)
        networks{i}=deep.blocks.internal.getSelectedNetwork(blocks{i});
    end

    [names,~,idx]=unique(networks);
    numUniqueNames=length(names);

    [~,names,~]=fileparts(names);
    if numUniqueNames==1
        names={names};
    end

    suffix='_labels';
    names=matlab.lang.makeValidName(names);
    names=matlab.lang.makeUniqueStrings(names,{},namelengthmax-length(suffix));
    names=strcat(names,suffix);
    enumName=names{idx(strcmp(blocks,block))};

end


function blocks=getClassifierBlocks(model)

    imageClassifierBlock='deeplib/Image Classifier';
    statefulClassifyBlock='deeplib/Stateful Classify';
    objectDetectorBlock='visionanalysis/Deep Learning Object Detector';

    info=libinfo(model);
    indices=false(1,numel(info));

    for i=1:numel(info)
        block=info(i).Block;
        while~isempty(block)
            if strcmp(block,imageClassifierBlock)||...
                strcmp(block,statefulClassifyBlock)||...
                strcmp(block,objectDetectorBlock)

                indices(i)=true;
                break;
            else
                library=strtok(block,'/');
                load_system(library);
                block=get_param(block,"ReferenceBlock");
            end
        end
    end

    blocks={info(indices).Block};

end
