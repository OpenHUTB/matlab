function loadDiagramOldVersion16bOrNewer(operations,syntax,model,inputs)




    xmlObject=readstruct(inputs.viewFile,'FileType','xml');


    imgFolder='';
    if~isempty(inputs.imageFile)
        imgFolder=tempname;


        unzip(inputs.imageFile,imgFolder);


        cleanupVar=onCleanup(@()rmdir(imgFolder,'s'));
    end


    createBlocksUsing16bView(operations,syntax.root,model,xmlObject,imgFolder);


    connectBlocksUsing16bView(operations,model,xmlObject);


    reparentAllBlocks(operations,model);

end

function createBlocksUsing16bView(operations,root,model,xmlObject,imgFolder)


    blocks=xmlObject.blocks.block;
    uuids=cell(1,numel(blocks));

    for i=1:numel(blocks)
        uuids{i}=getAttribute(blocks(i),'uuid');
    end

    compartments=sbioselect(model,'Type','compartment');
    for i=1:numel(compartments)
        idx=ismember(uuids,compartments(i).uuid);
        if any(idx)
            b=createBlock(operations,model,root,compartments(i));
            configureBlockUsingXML(operations,b,compartments(i),blocks(idx),imgFolder);

            if~isempty(b)
                species=compartments(i).Species;
                for j=1:numel(species)
                    idx=ismember(uuids,species(j).uuid);
                    if any(idx)
                        idx=find(idx);
                        for k=1:numel(idx)
                            b=createBlock(operations,model,root,species(j));
                            configureBlockUsingXML(operations,b,species(j),blocks(idx(k)),imgFolder);
                        end
                    end
                end
            end
        end
    end

    rules=sbioselect(model.Rules,'RuleType',getSupportedRuleTypes);
    params=getParametersToAdd(rules,model.Events);

    for i=1:numel(params)
        idx=ismember(uuids,params(i).uuid);
        if any(idx)
            b=createBlock(operations,model,root,params(i));
            configureBlockUsingXML(operations,b,params(i),blocks(idx),imgFolder);
        end
    end

    reactions=model.Reactions;
    for i=1:numel(reactions)
        idx=ismember(uuids,reactions(i).uuid);
        if any(idx)
            b=createBlock(operations,model,root,reactions(i));
            configureBlockUsingXML(operations,b,reactions(i),blocks(idx),imgFolder);
        end
    end

    for i=1:numel(rules)
        idx=ismember(uuids,rules(i).uuid);
        if any(idx)
            b=createBlock(operations,model,root,rules(i));
            configureBlockUsingXML(operations,b,rules(i),blocks(idx),imgFolder);
        end
    end


    species=model.Species;
    for i=1:numel(species)
        sblocks=model.getEntitiesInMap(species(i).SessionID);
        if numel(sblocks)>1
            for j=1:numel(sblocks)
                operations.setAttributeValue(sblocks(j),'cloneIndex',j);
            end
        end
    end

    textID=-1;
    for i=1:numel(blocks)
        if strcmp(blocks(i).typeAttribute,'Text')
            textBlock=blocks(i);
            bounds=textBlock.bounds;
            value=textBlock.text;
            createAnnotationBlock(operations,model,value,bounds,textID);
            textID=textID-1;
        end
    end

end

function createAnnotationBlock(operations,model,value,bounds,sessionID)



    obj.Name='';
    obj.Type='annotation';
    obj.SessionID=sessionID;
    obj.UUID=-1;


    if~isempty(model)&&model.hasDiagramSyntax
        syntax=model.getDiagramSyntax;
        newBlock=SimBiology.web.diagramhandler('createBlock',operations,model,syntax.root,obj);


        operations.setAttributeValue(newBlock,'annotation',value);
        operations.setAttributeValue(newBlock,'uuid',newBlock.uuid);
        operations.setAttributeValue(newBlock,'parentSessionID',model.SessionID);

        operations.setSize(newBlock,bounds.widthAttribute,bounds.heightAttribute);
        operations.setPosition(newBlock,bounds.xAttribute,bounds.yAttribute);
    end

end

function configureBlockUsingXML(operations,b,obj,blockNode,imgFolder)


    props=getDefaultProperties(obj.type);


    if~isempty(blockNode)

        graphicalId=getAttribute(blockNode,'graphicalid');
        operations.setAttributeValue(b,'graphicalId',graphicalId);


        bounds=blockNode.bounds;
        props.width=getAttribute(bounds,'width');
        props.height=getAttribute(bounds,'height');


        fontInfo=getField(blockNode,'font');
        if~isempty(fontInfo)
            props.fontFamily=getAttribute(fontInfo,'name');
            props.fontWeight=getFontWeight(getAttribute(fontInfo,'style'));
            props.fontSize=getAttribute(fontInfo,'size');
        end

        foreground=getField(blockNode,'foreground');
        if~isempty(foreground)
            props.edgecolor=getColorString(foreground);
        end

        background=getField(blockNode,'background');
        if~isempty(background)
            props.facecolor=getColorString(background);
        end

        textcolor=getField(blockNode,'textcolor');
        if~isempty(textcolor)
            props.textcolor=getColorString(textcolor);
        end

        textposition=getField(blockNode,'textposition');
        if~isempty(textposition)
            props.textLocation=getTextPosition(textposition);
        end

        pin=getField(blockNode,'pinned');
        if~isempty(pin)
            props.pin=pin;
        end


        if strcmp(obj.type,'compartment')
            visible='true';
        else
            visible=getField(blockNode,'visible');
        end
        if~isempty(visible)
            props.visible=visible;
        end

        cloned=getField(blockNode,'cloned');
        if~isempty(cloned)
            props.cloned=cloned;
        end

        orientation=getField(blockNode,'orientation');
        if~isempty(orientation)
            props.rotate=rad2deg(orientation);
        end

        imageString=getField(blockNode,'imagestring');
        if~isempty(imageString)

            convertedPath=strrep(imageString,'\','/');
            [~,filename,ext]=fileparts(convertedPath);


            imageFile=fullfile(imgFolder,'images',[filename,ext]);


            imageInfo=SimBiology.web.diagram.utilhandler('getImageData',imageFile);
            if~isempty(imageInfo)
                props.shape=imageInfo.filename;
                props.imageData=imageInfo.imageData;
            end
        end

        blockshape=getField(blockNode,'blockshapename');
        if~isempty(blockshape)
            props.shape=getBlockShape(blockshape);

            if strcmp(props.shape,'rectangle')
                props.shapeRadius=0;
            end
        end
    end

    configureBlock(operations,b,obj,props);


    x=getAttribute(bounds,'x');
    y=getAttribute(bounds,'y');

    operations.setPosition(b,x,y);

end

function connectBlocksUsing16bView(operations,model,xmlObject)


    blocks=model.getAllEntitiesInMap;
    graphicalIDs=cell(numel(blocks),1);
    sessionIDs=cell(numel(blocks),1);

    for i=1:numel(blocks)
        sessionIDs{i}=blocks(i).getAttribute('sessionID').value;
        if blocks(i).hasAttribute('graphicalId')
            graphicalIDs{i}=blocks(i).getAttribute('graphicalId').value;
            operations.eraseAttribute(blocks(i),'graphicalId');
        else
            graphicalIDs{i}='';
        end
    end

    linesNode=xmlObject.lines;
    lines=linesNode.line;

    for i=1:numel(lines)
        startConn=getAttribute(lines(i),'startconnection');
        endConn=getAttribute(lines(i),'endconnection');

        startSessionId=sessionIDs(ismember(graphicalIDs,startConn));
        endSessionId=sessionIDs(ismember(graphicalIDs,endConn));

        startBlock=blocks(ismember(graphicalIDs,startConn));
        endBlock=blocks(ismember(graphicalIDs,endConn));


        lhsline=getField(lines(i),'lhsline');
        if~isempty(lhsline)
            if strcmp(lhsline,'true')&&~isempty(endBlock)&&any(strcmp(endBlock.type,{'repeatedAssignment','rate'}))



                endSessionId=sessionIDs(ismember(graphicalIDs,startConn));
                startSessionId=sessionIDs(ismember(graphicalIDs,endConn));
                startBlock=blocks(ismember(graphicalIDs,endConn));
                endBlock=blocks(ismember(graphicalIDs,startConn));
            end
        end

        tags=getField(lines(i),'tags');
        tags=strtrim(strsplit(tags,','));


        if~isempty(endSessionId)&&~isempty(startSessionId)
            if ismember('Reactant_Line',tags)&&ismember('Product_Line',tags)
                type='reactantProductLine';
            elseif ismember('Reactant_Line',tags)
                type='reactantLine';
            elseif ismember('Product_Line',tags)
                type='productLine';
            elseif strcmp(lhsline,'true')
                type='lhsLine';
            else
                type='usageLine';
                if~isempty(endBlock)&&any(strcmp(endBlock.type,{'repeatedAssignment','rate'}))
                    operations.setAttributeValue(endBlock,'lines','show');
                elseif~isempty(startBlock)&&any(strcmp(startBlock.type,{'repeatedAssignment','rate'}))
                    operations.setAttributeValue(endBlock,'lines','show');
                end
            end

            startCloneIndex=startBlock.getAttribute('cloneIndex').value;
            endCloneIndex=endBlock.getAttribute('cloneIndex').value;


            createLine(operations,model,startSessionId,endSessionId,startCloneIndex,endCloneIndex,type);
        end
    end

end

function out=getColorString(node)

    if isempty(node(1))
        out='transparent';
        return;
    end

    r=getAttribute(node,'r');
    g=getAttribute(node,'g');
    b=getAttribute(node,'b');

    out=sprintf('rgb(%d, %d, %d)',r,g,b);

end

function out=getTextPosition(textPosition)

    switch textPosition
    case 0
        out='top';
    case 1
        out='left';
    case 2
        out='bottom';
    case 3
        out='right';
    case 4
        out='center';
    case 5
        out='none';
    otherwise
        out='bottom';
    end

end

function out=getBlockShape(shapeName)

    switch shapeName
    case 'shape2'
        out='chevron';
    case 'shape3'
        out='parallelogram';
    case 'shape5'
        out='hexagon';
    case 'shape6'
        out='triangle';
    case 'shape8'
        out='diamond';
    case 'oval'
        out='oval';
    otherwise
        out='rectangle';
    end

end

function out=getFontWeight(value)

    values={'plain','bold','italic','bold italic'};
    out=values{value+1};

end

function block=createBlock(operations,model,root,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,root,obj);

end

function createLine(operations,model,startSessionId,endSessionId,startCloneIndex,endCloneIndex,type)

    SimBiology.web.diagram.linehandler('createLine',operations,model,startSessionId,endSessionId,startCloneIndex,endCloneIndex,type);

end

function configureBlock(operations,b,obj,props)

    SimBiology.web.diagramhandler('configureBlock',operations,b,obj,props);

end

function out=getDefaultProperties(type)

    out=SimBiology.web.diagramhandler('getDefaultProperties',type);

end

function params=getParametersToAdd(rules,events)

    params=SimBiology.web.diagram.utilhandler('getParametersToAdd',rules,events);

end

function types=getSupportedRuleTypes

    types=SimBiology.web.diagramhandler('getSupportedRuleTypes');

end

function reparentAllBlocks(operations,model)

    SimBiology.web.diagram.layouthandler('reparentAllBlocks',operations,model);

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);
end
