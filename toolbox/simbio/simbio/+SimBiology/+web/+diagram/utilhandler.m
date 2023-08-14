function out=utilhandler(action,varargin)











    out=[];

    switch(action)
    case 'verifyUndoStackSize'
        verifyUndoStackSize(varargin{:});
    case 'applyBlockStyle'
        out=applyBlockStyle(varargin{:});
    case 'getBlocksFromSessionID'
        out=getBlocksFromSessionID(varargin{:});
    case 'getBlocksFromUUID'
        out=getBlocksFromUUID(varargin{:});
    case 'getBlocksWalkDiagram'
        out=getBlocksWalkDiagram(varargin{:});
    case 'getBlockWithUUIDWalkDiagram'
        out=getBlockWithUUIDWalkDiagram(varargin{:});
    case 'getConnections'
        out=getConnections(varargin{:});
    case 'getImageData'
        out=getImageData(varargin{:});
    case 'getLineSessionIDs'
        out=getLineSessionIDs(varargin{:});
    case 'getParametersToAdd'
        out=getParametersToAdd(varargin{:});
    case 'getSplitBlock'
        out=getSplitBlock(varargin{:});
    case 'isShowLines'
        out=isShowLines(varargin{:});
    case 'keepParameterBlock'
        out=keepParameterBlock(varargin{:});
    case 'logical2string'
        out=logical2string(varargin{:});
    case 'setZIndex'
        setZIndex(varargin{:});
    case 'smartConcat'
        out=smartConcat(varargin{:});
    case 'getBlockAppearanceProperties'
        out=getBlockAppearanceProperties;
    case 'getBlockInfo'
        out=getBlockInfo(varargin{:});
    case 'setBlockInfo'
        setBlockInfo(varargin{:});
    end

end

function out=applyBlockStyle(inputs)


    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)applyBlockStyleOperations(operations,model,inputs));
    end

    blocks=inputs.blocks;
    out.sessionID=blocks(1).sessionID;
    out.uuid=blocks(1).diagramUUID;
    out.values=inputs.values;

end

function applyBlockStyleOperations(operations,model,inputs)

    blocks=inputs.blocks;
    props=inputs.values;
    props=rmfield(props,{'clipBoardType','clipBoardID'});
    currentValues={};
    newValues={};
    transaction=SimBiology.Transaction.create(model);

    for i=1:numel(blocks)
        block=getBlocksFromUUID(model,blocks(i).sessionID,blocks(i).diagramUUID);
        if~isempty(block)

            oldvalue=struct;
            oldvalue.facecolor=getAttributeValue(block,'facecolor');
            oldvalue.edgecolor=getAttributeValue(block,'edgecolor');
            oldvalue.textcolor=getAttributeValue(block,'textcolor');
            oldvalue.fontSize=getAttributeValue(block,'fontSize');
            oldvalue.fontFamily=getAttributeValue(block,'fontFamily');
            oldvalue.fontWeight=getAttributeValue(block,'fontWeight');
            oldvalue.textLocation=getAttributeValue(block,'textLocation');
            oldvalue.shapeRadius=getAttributeValue(block,'shapeRadius');
            oldvalue.shape=getAttributeValue(block,'shape');
            oldvalue.rotate=getAttributeValue(block,'rotate');
            oldvalue.imageData=getAttributeValue(block,'imageData');


            operations.setAttributeValue(block,'facecolor',props.facecolor);
            operations.setAttributeValue(block,'edgecolor',props.edgecolor);
            operations.setAttributeValue(block,'textcolor',props.textcolor);
            operations.setAttributeValue(block,'fontSize',props.fontSize);
            operations.setAttributeValue(block,'fontFamily',props.fontFamily);
            operations.setAttributeValue(block,'fontWeight',props.fontWeight);
            operations.setAttributeValue(block,'textLocation',props.textLocation);
            operations.setAttributeValue(block,'shapeRadius',props.shapeRadius);
            operations.setAttributeValue(block,'shape',props.shape);
            operations.setAttributeValue(block,'rotate',props.rotate);
            operations.setAttributeValue(block,'imageData',props.imageData);


            currentValue=struct;
            currentValue.sessionID=blocks(i).sessionID;
            currentValue.diagramUUID=blocks(i).diagramUUID;
            currentValue.values=oldvalue;

            newValue=struct;
            newValue.sessionID=blocks(i).sessionID;
            newValue.diagramUUID=blocks(i).diagramUUID;
            newValue.values=props;

            currentValues{end+1}=currentValue;%#ok<*AGROW>
            newValues{end+1}=newValue;%#ok<*AGROW>
        end
    end

    currentValues=[currentValues{:}];
    newValues=[newValues{:}];

    transaction.push(@()SimBiology.web.diagram.undo.blockAttributeLambda(model,currentValues,newValues));
    transaction.commit();

end

function setZIndex(inputs)

    model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.modelSessionID);

    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        syntax.modify(@(operations)setZIndexOperations(operations,model,inputs));
    end

end

function setZIndexOperations(operations,model,inputs)

    blocks=inputs.blocks;
    currentValues={};
    newValues={};
    transaction=SimBiology.Transaction.create(model);

    for i=1:numel(blocks)
        block=getBlocksFromUUID(model,blocks(i).sessionID,blocks(i).diagramUUID);
        if~isempty(block)

            oldvalue=struct('zIndex',getAttributeValue(block,'zIndex'));
            newvalue=struct('zIndex',blocks(i).value);


            operations.setAttributeValue(block,'zIndex',blocks(i).value);


            currentValue=struct;
            currentValue.sessionID=blocks(i).sessionID;
            currentValue.diagramUUID=blocks(i).diagramUUID;
            currentValue.values=oldvalue;

            newValue=struct;
            newValue.sessionID=blocks(i).sessionID;
            newValue.diagramUUID=blocks(i).diagramUUID;
            newValue.values=newvalue;

            currentValues{end+1}=currentValue;
            newValues{end+1}=newValue;
        end
    end

    currentValues=[currentValues{:}];
    newValues=[newValues{:}];

    transaction.push(@()SimBiology.web.diagram.undo.blockAttributeLambda(model,currentValues,newValues));
    transaction.commit();

end

function blocks=getBlocksFromSessionID(model,sessionIDs)

    sessionIDs=unique(sessionIDs);
    blocks=[];

    for i=1:length(sessionIDs)
        next=model.getEntitiesInMap(sessionIDs(i));
        for j=1:numel(next)
            if(next(j).isValid)
                blocks=[blocks;next(j)];
            end
        end
    end

end

function blocks=getBlocksFromUUID(model,sessionIDs,UUIDs)




    blocks=getBlocksFromSessionID(model,sessionIDs);
    if~isempty(blocks)
        blockUUIDs={blocks.uuid};
        blocks=blocks(ismember(blockUUIDs,UUIDs));
    end

end

function blocks=getBlocksWalkDiagram(syntax)

    blocks=getBlocksWalkDiagramRecursive(syntax.root,[]);

end

function blocks=getBlocksWalkDiagramRecursive(root,blocks)

    entities=root.entities;


    for i=1:numel(entities)
        if(entities(i).isValid)
            if strcmp(entities(i).type,'compartment')
                subdiagram=entities(i).subdiagram;
                if subdiagram.isValid

                    blocks=vertcat(blocks,entities(i));



                    blocks=getBlocksWalkDiagramRecursive(subdiagram,blocks);
                else

                    blocks=vertcat(blocks,entities(i));
                end
            else
                blocks=vertcat(blocks,entities(i));
            end
        end
    end

end

function blocks=getBlockWithUUIDWalkDiagram(syntax,UUID)

    blocks=getBlockWithUUIDWalkDiagramRecursive(syntax.root,[],UUID);

end

function block=getBlockWithUUIDWalkDiagramRecursive(root,block,UUID)

    if~isempty(block)
        return;
    end

    entities=root.entities;


    for i=1:numel(entities)
        if(entities(i).isValid)
            if strcmp(entities(i).uuid,UUID)
                block=entities(i);
                return;
            end
            if strcmp(entities(i).type,'compartment')
                subdiagram=entities(i).subdiagram;
                if subdiagram.isValid
                    block=getBlockWithUUIDWalkDiagramRecursive(subdiagram,block,UUID);
                end
            end
        end
    end

end

function out=getConnections(model,blocks)

    out={};

    for i=1:numel(blocks)
        connections=blocks(i).connections;
        for j=1:numel(connections)
            sourceBlock=connections(j).source;
            destinationBlock=connections(j).destination;

            if strcmp(sourceBlock.uuid,blocks(i).uuid)
                sessionID=destinationBlock.getAttribute('sessionID').value;
                out{end+1}=sbioselect(model,'SessionID',sessionID);
            elseif strcmp(destinationBlock.uuid,blocks(i).uuid)
                sessionID=sourceBlock.getAttribute('sessionID').value;
                out{end+1}=sbioselect(model,'SessionID',sessionID);
            end
        end
    end

    out=[out{:}];

end

function out=getImageData(filename)

    out='';

    if exist(filename,'file')==2

        fid=fopen(filename,'r');
        bytes=fread(fid,'uint8=>uint8');
        fclose(fid);


        convertedPath=strrep(filename,'\','/');
        [~,fname,ext]=fileparts(convertedPath);
        fname=[fname,ext];
        ext=ext(2:end);

        imageData=sprintf('data:image/%s;base64,%s',ext,matlab.net.base64encode(bytes));
        out=struct('imageData',imageData,'filename',fname);
    end

end

function out=getLineSessionIDs(line)

    sourceBlock=line.source;
    destinationBlock=line.destination;
    sourceSessionID=sourceBlock.getAttribute('sessionID').value;
    destinationSessionID=destinationBlock.getAttribute('sessionID').value;
    out=[sourceSessionID,destinationSessionID];

end

function params=getParametersToAdd(rules,events)

    params={};


    for i=1:numel(rules)
        lhs=parserule(rules(i));
        if~isempty(lhs)
            obj=resolveobject(rules(i),lhs{1});
            if isa(obj,'SimBiology.Parameter')
                params{end+1}=obj;
            end
        end
    end

    for i=1:numel(events)
        lhs=parseeventfcns(events(i));
        for j=1:length(lhs)
            if~isempty(lhs{j})
                obj=resolveobject(events(i),lhs{j}{1});
                if isa(obj,'SimBiology.Parameter')
                    params{end+1}=obj;
                end
            end
        end
    end

    if~isempty(params)
        params=unique([params{:}]);
    else
        params=[];
    end

end

function block=getSplitBlock(model,species,expression)

    block=[];
    blocks=model.getEntitiesInMap(species.SessionID);
    exprBlock=model.getEntitiesInMap(expression.SessionID);

    for i=1:numel(blocks)
        connections=blocks(i).connections;
        for j=1:numel(connections)
            sourceBlock=connections(j).source;
            destinationBlock=connections(j).destination;

            if strcmp(sourceBlock.uuid,exprBlock.uuid)||strcmp(destinationBlock.uuid,exprBlock.uuid)
                block=blocks(i);
                return;
            end
        end
    end

end

function out=isShowLines(model,obj)

    block=model.getEntitiesInMap(obj.SessionID);
    out=strcmp(getAttributeValue(block,'lines'),'show');

end

function out=keepParameterBlock(param,objToExclude)

    if~isa(param,'SimBiology.Parameter')
        out=true;
        return;
    end

    out=false;
    usages=findUsages(param);

    for i=1:numel(usages)
        if~isempty(objToExclude)&&(usages(i)==objToExclude)

        elseif isa(usages(i),'SimBiology.Rule')

            lhs=parserule(usages(i));
            next=resolveobject(usages(i),lhs{1});
            if next==param
                out=true;
                break;
            end
        elseif isa(usages(i),'SimBiology.Event')

            lhs=parseeventfcns(usages(i));
            for j=1:length(lhs)
                next=resolveobject(usages(i),lhs{j}{1});
                if next==param
                    out=true;
                    break;
                end
            end
        end
    end

end

function props=getBlockAppearanceProperties

    props={'textcolor','facecolor','edgecolor','textLocation',...
    'fontFamily','fontWeight','fontSize','shape','shapeRadius',...
    'rotate','textAlign','lines','imageData'};

end

function blockInfo=getBlockInfo(block,varargin)

    if nargin==1
        blockInfo=struct;
    else
        blockInfo=varargin{1};
    end

    props=getBlockAppearanceProperties;
    for i=1:numel(props)
        blockInfo.(props{i})=getAttributeValue(block,props{i});
    end

end

function setBlockInfo(operations,block,blockInfo)

    props=getBlockAppearanceProperties;
    for i=1:numel(props)
        operations.setAttributeValue(block,props{i},blockInfo.(props{i}));
    end

end

function verifyUndoStackSize(model)


    commandProcessor=model.getDiagramEditor.commandProcessor;
    if((commandProcessor.undoDepth+100)>commandProcessor.maxDepth)
        commandProcessor.maxDepth=commandProcessor.maxDepth+1000;
    end

end

function out=smartConcat(var1,var2)


    if size(var1,1)==1
        var1=var1';
    end

    if size(var2,1)==1
        var2=var2';
    end

    out=vertcat(var1,var2);

end

function out=logical2string(val)

    out='false';
    if val
        out='true';
    end

end

function out=getAttributeValue(blocks,property)

    out=SimBiology.web.diagramhandler('getAttributeValue',blocks,property);
end
