function blockInfos=loadBlockInfos(modelObjs,diagramFiles,ignoreDiagram)






























    lineInfoTemplate=struct("QuantityEndpoint",[],...
    "Color",[],...
    "Width",[]);
    blockInfoTemplate=struct("UUID",[],...
    "Visible",[],...
    "Pin",[],...
    "Shape",[],...
    "Rotate",[],...
    "FontName",[],...
    "FontSize",[],...
    "FontWeight",[],...
    "TextLocation",[],...
    "FaceColor",[],...
    "EdgeColor",[],...
    "Position",[],...
    "Connections",[],...
    "Lines",lineInfoTemplate([]));

    blockInfos={blockInfoTemplate([]),blockInfoTemplate([])};

    if ignoreDiagram

        return;
    end

    cleanupDiagramSyntax=[];

    for i=1:2

        if~hasDiagramSyntax(modelObjs(i))&&~ismissing(diagramFiles(i))

            info.viewFile=char(diagramFiles(i));
            info.model=modelObjs(i);
            SimBiology.web.diagram.inithandler('initDiagramSyntax',info);
            cleanupDiagramSyntax=[cleanupDiagramSyntax,onCleanup(...
            @()deleteDiagramSyntaxFromModel(modelObjs(i)))];
        end

        if hasDiagramSyntax(modelObjs(i))

            blocks=getAllEntitiesInMap(modelObjs(i));
            if isempty(blocks)
                continue;
            end
            sessionIDs=arrayfun(@(block)getAttribute(block,'sessionID').value,blocks,'UniformOutput',false);
            annotationBlockIdx=[sessionIDs{:}]<0;
            blocks(annotationBlockIdx)=[];
            sessionIDs(annotationBlockIdx)=[];%#ok<*AGROW> 





            modelComponents=findobj(modelObjs(i),"-isa","SimBiology.ModelComponent");
            [~,modelComponentIdx]=ismember(unique([sessionIDs{:}],"stable"),[modelComponents.SessionID]);
            modelComponents=modelComponents(modelComponentIdx);


            [~,uuidIdx]=ismember([sessionIDs{:}],[modelComponents.SessionID]);

            positions=getPositions(modelObjs(i),blocks,sessionIDs);
            numBlockInfos=size(positions,1);
            blockInfos{i}=repmat(blockInfoTemplate,numBlockInfos,1);
            for blockIdx=1:numBlockInfos
                blockInfos{i}(blockIdx).UUID=modelComponents(uuidIdx(blockIdx)).UUID;
                blockInfos{i}(blockIdx).Position=createValueStruct(positions{blockIdx},'%d');
            end





            blockAttributes={'Visible','Pin','Shape','Rotate','FontName',...
            'FontSize','FontWeight','TextLocation'};
            attributeValues=simbio.diagram.getBlock(modelComponents,blockAttributes);
            for blockIdx=1:numBlockInfos
                for attrIdx=1:numel(blockAttributes)
                    blockInfos{i}(blockIdx).(blockAttributes{attrIdx})=...
                    createValueStruct(attributeValues{blockIdx,attrIdx},'%4.3f');
                end
            end


            attributeNames={'FaceColor','EdgeColor','TextColor','Connections'};
            colorAndConnectionInfos=simbio.diagram.getBlock(modelComponents,attributeNames);
            for blockIdx=1:numBlockInfos
                for attrIdx=1:numel(attributeNames)
                    blockInfos{i}(blockIdx).(attributeNames{attrIdx})=...
                    createValueStruct(colorAndConnectionInfos{blockIdx,attrIdx},'%4.3f');
                end
            end


            expressionsThatSupportLines=modelComponents(ismember({modelComponents.Type},{'reaction','rule'}));
            [~,expressionIndices]=ismember([expressionsThatSupportLines.SessionID],[sessionIDs{:}]);
            for j=1:numel(expressionsThatSupportLines)
                expressionObj=expressionsThatSupportLines(j);
                expressionIdx=expressionIndices(j);
                lines=simbio.diagram.getLine(expressionObj);
                if numel(lines)==1&&numel(fieldnames(lines))==0



                    continue;
                end
                for lineIdx=1:numel(lines)



                    if isa(lines(lineIdx).Connections(1),"SimBiology.QuantityComponent")
                        quantityEndPoint=lines(lineIdx).Connections(1);
                    else
                        quantityEndPoint=lines(lineIdx).Connections(2);
                    end
                    blockInfos{i}(expressionIdx).Lines=[blockInfos{i}(expressionIdx).Lines;...
                    struct("QuantityEndpoint",quantityEndPoint,...
                    "Color",createValueStruct(lines(lineIdx).Color,'%4.3f'),...
                    "Width",createValueStruct(lines(lineIdx).Width,'%4.3f'))];
                end
            end


            blockInfos{i}=standardize(blockInfos{i},[sessionIDs{:}]);

        end

    end

end


function blockInfo=standardize(blockInfo,allSessionIDs)








    duplicateBlockSessionIDs=getNonUniqueValues(allSessionIDs);



    nonSharedAttributes=["Position","Connections","Pin","Visible"];

    deleteIdx=cell(numel(duplicateBlockSessionIDs),1);
    for i=1:numel(duplicateBlockSessionIDs)
        duplicateIdx=find(allSessionIDs==duplicateBlockSessionIDs(i));
        blockRowIdx=duplicateIdx(1);
        deleteIdx{i}=duplicateIdx(2:end);
        for clonedBlockRowIdx=duplicateIdx(2:end)
            for attrIdx=1:numel(nonSharedAttributes)

                blockInfo(blockRowIdx).(nonSharedAttributes(attrIdx))=[...
                blockInfo(blockRowIdx).(nonSharedAttributes(attrIdx));
                blockInfo(clonedBlockRowIdx).(nonSharedAttributes(attrIdx))];
            end
        end
    end
    blockInfo([deleteIdx{:}])=[];

end

function valueStruct=createValueStruct(value,format)
    valueStruct=struct("Value",value,"String","");
    if isnumeric(value)
        valueStruct.String=numericToChar(value,format);
    elseif islogical(value)
        valueStruct.String=char(string(value));
    elseif ischar(value)
        valueStruct.String=value;
    else
        assert(isa(value,"SimBiology.ModelComponent"));
    end
end

function charValue=numericToChar(value,format)


    charValue=compose(format,value);
    charValue=strjoin(charValue,'  ');
    if~isscalar(value)
        charValue=['[',charValue,']'];
    end
end

function blockPositions=getPositions(modelObj,blocks,sessionIDs)

    compartmentPositions=containers.Map('KeyType','double','ValueType','any');
    tfCompartment=false(size(sessionIDs));
    topLevelCompartments=findobj(modelObj,"Type","compartment","-depth",1);
    [tfCompartment,compartmentPositions]=getCompartmentPositions(topLevelCompartments,...
    [0,0],blocks,sessionIDs,compartmentPositions,tfCompartment);


    [tfSpecies,speciesPositions]=addSpeciesPositions(modelObj,blocks,sessionIDs,compartmentPositions);
    speciesCount=0;
    blockPositions=cell(numel(blocks),1);
    for i=1:numel(sessionIDs)
        if tfSpecies(i)
            speciesCount=speciesCount+1;
            blockPositions{i}=speciesPositions{speciesCount};
        elseif tfCompartment(i)
            blockPositions{i}=compartmentPositions(sessionIDs{i});
        else

            positionObj=SimBiology.web.diagram.placementhandler('getBlockAbsolutePosition',modelObj,blocks(i));
            sizeObj=blocks(i).getSize();
            blockPositions{i}=[positionObj.x,positionObj.y,sizeObj.width,sizeObj.height];
        end
        blockPositions{i}=round(blockPositions{i});
    end
end

function[tfSpecies,speciesPositions]=addSpeciesPositions(modelObj,blocks,sessionIDs,compartmentPositions)




    species=modelObj.Species;
    [tfSpecies,idxSpecies]=ismember([sessionIDs{:}],[species.SessionID]);
    idxSpecies=idxSpecies(tfSpecies);
    idxSpeciesBlock=find(tfSpecies);
    speciesPositions=cell(numel(idxSpecies),1);
    for i=1:numel(idxSpecies)
        parentPosition=compartmentPositions(species(idxSpecies(i)).Parent.SessionID);
        positionObj=blocks(idxSpeciesBlock(i)).getPosition();
        position=parentPosition([1,2])+[positionObj.x,positionObj.y];
        sizeObj=blocks(idxSpeciesBlock(i)).getSize();
        speciesPositions{i}=[position,sizeObj.width,sizeObj.height];
    end
end

function[tfCompartment,positions]=getCompartmentPositions(compartments,parentPosition,blocks,sessionIDs,positions,tfCompartment)




    [~,idxCompartment]=ismember([compartments.SessionID],[sessionIDs{:}]);
    tfCompartment(idxCompartment)=true;
    for i=1:numel(compartments)
        positionObj=blocks(idxCompartment(i)).getPosition();
        position=parentPosition([1,2])+[positionObj.x,positionObj.y];
        sizeObj=blocks(idxCompartment(i)).getSize();
        positions(sessionIDs{idxCompartment(i)})=[position,sizeObj.width,sizeObj.height];
        [tfCompartment,positions]=getCompartmentPositions(compartments(i).Compartment,position,blocks,sessionIDs,positions,tfCompartment);
    end
end

function deleteDiagramSyntaxFromModel(model)

    if model.hasDiagramSyntax()
        model.deleteDiagramSyntax();
    end
end

function nonUniqueValues=getNonUniqueValues(values)



    [count,edges]=histcounts(values,BinMethod="integers",...
    Normalization="count");
    edgeIdx=(1:numel(count))';
    binnedValues=mean(edges([edgeIdx,edgeIdx+1]),2);
    nonUniqueValues=binnedValues(count>1);
end
