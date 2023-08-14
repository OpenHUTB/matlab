function out=palettehandler(action,varargin)











    switch(action)
    case 'addBlockToLibrary'
        out=addBlockToLibrary(action,varargin{:});
    case 'createPalette'
        createPalette(varargin{:});
    case 'removeBlockFromLibrary'
        out=removeBlockFromLibrary(action,varargin{:});
    case 'importOldCustomPalettes'
        out=importOldCustomPalettes(varargin{:});
    end

end

function createPalette(operations,prototypeOperations,customBlockLibrary,diagram)


    keys=prototypeOperations.getPrototypeKeys;



    for i=1:numel(keys)
        prototypeOperations.removePrototype(keys{i});
    end

    timeStamp=now;



    e=operations.createEntity(diagram);
    operations.setType(e,'compartment');
    operations.setSize(e,200,200);
    prototypeOperations.addPrototype(sprintf('builtin_1_compartment_%f',timeStamp),'Palette',getBlockTitle('compartment'),e);

    e=operations.createEntity(diagram);
    operations.setType(e,'species');
    operations.setSize(e,32,16);
    prototypeOperations.addPrototype(sprintf('builtin_2_species_%f',timeStamp),'Palette',getBlockTitle('species'),e);

    e=operations.createEntity(diagram);
    operations.setType(e,'reaction');
    operations.setSize(e,15,15);
    prototypeOperations.addPrototype(sprintf('builtin_3_reaction_%f',timeStamp),'Palette',getBlockTitle('reaction'),e);

    e=operations.createEntity(diagram);
    operations.setType(e,'repeatedAssignment');
    operations.setSize(e,20,20);
    prototypeOperations.addPrototype(sprintf('builtin_5_repeatedAssignment_%f',timeStamp),'Palette',getBlockTitle('repeatedAssignment'),e);

    e=operations.createEntity(diagram);
    operations.setType(e,'rate');
    operations.setSize(e,20,20);
    prototypeOperations.addPrototype(sprintf('builtin_6_rate_%f',timeStamp),'Palette',getBlockTitle('rate'),e);

    e=operations.createEntity(diagram);
    operations.setType(e,'annotation');
    operations.setSize(e,54,24);
    prototypeOperations.addPrototype(sprintf('builtin_9_annotation_%f',timeStamp),'Palette',getBlockTitle('annotation'),e);


    for i=1:numel(customBlockLibrary)
        addCustomBlockToPalette(operations,prototypeOperations,customBlockLibrary(i),diagram);
    end

end

function addCustomBlockToPalette(operations,prototypeOperations,customBlock,diagram)

    e=operations.createEntity(diagram);
    operations.setType(e,customBlock.type);
    operations.setSize(e,customBlock.props.width,customBlock.props.height);

    props=customBlock.props;
    propNames=fields(props);
    for i=1:numel(propNames)
        operations.setAttributeValue(e,propNames{i},props.(propNames{i}));
    end

    prototypeOperations.addPrototype(customBlock.key,'CustomPalette',getBlockTitle(customBlock.type),e);

end

function out=addBlockToLibrary(action,inputs)





    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.activeModelSessionID);


    blocks=model.getEntitiesInMap(inputs.sessionID);
    UUIDs={blocks.uuid};
    block=blocks(ismember(UUIDs,inputs.uuid));

    if~isempty(block)
        customBlockLibrary=inputs.customBlockLibrary;


        blockProps=getDefaultProperties(block.type);
        propNames=fields(blockProps);

        for i=1:numel(propNames)

            if block.hasAttribute(propNames{i})
                blockProps.(propNames{i})=block.getAttribute(propNames{i}).value;
            end
        end




        blockSize=block.getSize();
        blockProps.width=blockSize.width;
        blockProps.height=blockSize.height;

        customBlock=struct;
        customBlock.type=block.type;
        customBlock.key=sprintf('userdefined_%d_%s_%f',numel(customBlockLibrary)+1,customBlock.type,now);
        customBlock.props=blockProps;


        if isempty(customBlockLibrary)
            customBlockLibrary=customBlock;
        else
            customBlockLibrary(end+1)=customBlock;
        end


        for i=1:numel(inputs.allOpenModels)

            model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.allOpenModels(i));
            if~isempty(model)&&model.hasDiagramSyntax
                syntax=model.getDiagramSyntax;
                syntax.modifyPrototypes(@(operations,prototypeOperations,diagram)createPalette(operations,prototypeOperations,customBlockLibrary,diagram));
            end
        end
    end


    saveCustomBlockLibraryInPreferences(customBlockLibrary);

    out={action,customBlockLibrary};

end

function out=removeBlockFromLibrary(action,inputs)


    customBlockLibrary=inputs.customBlockLibrary;
    for i=numel(customBlockLibrary):-1:1
        if ismember(customBlockLibrary(i).key,inputs.blockToRemove)
            customBlockLibrary(i)=[];
        end
    end

    for i=1:numel(inputs.allOpenModels)
        model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.allOpenModels(i));
        if~isempty(model)&&model.hasDiagramSyntax
            syntax=model.getDiagramSyntax;
            syntax.modifyPrototypes(@(operations,prototypeOperations,diagram)createPalette(operations,prototypeOperations,customBlockLibrary,diagram));
        end
    end


    saveCustomBlockLibraryInPreferences(customBlockLibrary);

    out={action,customBlockLibrary};

end

function saveCustomBlockLibraryInPreferences(customBlockLibrary)

    preferences=struct;
    prefFileName=SimBiology.web.desktophandler('getModelBuilderPreferenceFileName');
    if exist(prefFileName,'file')
        preferences=load(prefFileName);
        preferences=preferences.preferences;
        preferences=preferences.preferences;
    end


    preferences.customBlockLibrary=customBlockLibrary;

    preferences=struct('preferences',preferences);
    save(prefFileName,'preferences');

end

function out=importOldCustomPalettes(customLibraries)

    out=[];
    index=1;

    for i=1:numel(customLibraries)
        fname=fullfile(customLibraries(i).folder,customLibraries(i).name);
        propertyInfo=SimBiology.web.diagram.convertDiagramViewFile(fname);



        blockTypes=fields(propertyInfo);
        for j=1:numel(blockTypes)
            blocks=propertyInfo.(blockTypes{j});

            if~iscell(blocks)
                blocks={blocks};
            end

            for k=1:numel(blocks)
                blockDefinition=createPaletteBlockForOldLibrary(blocks{k},index);
                if~isempty(blockDefinition)
                    index=index+1;

                    if isempty(out)
                        out=blockDefinition;
                    else
                        out(end+1)=blockDefinition;%#ok<AGROW>
                    end
                end
            end
        end
    end

end

function newBlock=createPaletteBlockForOldLibrary(oldBlockDefinition,index)
    props=[];
    newBlock=[];
    type=[];


    if strcmp(oldBlockDefinition.type,'rule')&&isfield(oldBlockDefinition,'ruleType')&&SimBiology.web.diagramhandler('isSupportedRuleType',oldBlockDefinition.ruleType)
        props=SimBiology.web.diagramhandler('getDefaultProperties',oldBlockDefinition.ruleType);
        type=oldBlockDefinition.ruleType;

    elseif SimBiology.web.diagramhandler('isSupportedBlockType',oldBlockDefinition.type)
        props=SimBiology.web.diagramhandler('getDefaultProperties',oldBlockDefinition.type);
        type=oldBlockDefinition.type;
    end

    if~isempty(props)

        blockProps=fields(oldBlockDefinition);
        for i=1:numel(blockProps)
            if strcmp(blockProps{i},'size')
                props.width=oldBlockDefinition.size(1);
                props.height=oldBlockDefinition.size(2);

            elseif isfield(props,blockProps{i})
                props.(blockProps{i})=oldBlockDefinition.(blockProps{i});
            end
        end


        newBlock=struct('props',props,'type',type,'key',sprintf('userdefined_%d_%s_%f',index+1,type,now));
    end

end

function out=getBlockTitle(type)

    out=type;
    switch type
    case 'species'
        out='Species';
    case 'compartment'
        out='Compartment';
    case 'reaction'
        out='Reaction';
    case 'repeatedAssignment'
        out='Repeated Assignment';
    case 'rate'
        out='Rate Rule';
    case 'annotation'
        out='Text';
    end

end

function blockProps=getDefaultProperties(type)

    blockProps=SimBiology.web.diagramhandler('getDefaultProperties',type);

end
