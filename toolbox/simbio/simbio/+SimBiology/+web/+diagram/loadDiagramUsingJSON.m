function loadDiagramUsingJSON(operations,model,syntax,inputs)




    diagramJSON=fileread(inputs.viewFile);
    syntax.loadFromJSON(diagramJSON);




    blocks=getBlocksWalkDiagram(syntax);



    hasLineActiveAttribute=doesLineHaveActiveAttribute(blocks);
    updateAttributesToLatest(operations,blocks,hasLineActiveAttribute);
    updateLineAttributes(operations,blocks);


    allObj=findobj(model);
    modelComps=allObj(arrayfun(@(o)isa(o,'SimBiology.ModelComponent'),allObj));


    blocks=linkSessionIDs(operations,blocks,modelComps);



    for i=1:numel(blocks)
        sessionID=blocks(i).getAttribute('sessionID').value;
        model.addEntitiesToMap(sessionID,blocks(i));
    end



    SimBiology.web.diagramhandler('searchCleared',struct('modelSessionID',model.SessionID));


    if~hasLineActiveAttribute
        configureInactiveLineProperty(operations,model);
    end


    setAllCompartmentVisible(operations,model);

end

function blocks=linkSessionIDs(operations,blocks,modelComps)

    uuids={modelComps.UUID};

    indicesToDestroy=[];
    for i=1:numel(blocks)
        try
            uuid=blocks(i).getAttribute('uuid').value;
            sessionID=blocks(i).getAttribute('sessionID').value;%#ok<NASGU> 
            idx=strcmp(uuids,uuid);
            if any(idx)
                modelComp=modelComps(idx);
                operations.setAttributeValue(blocks(i),'sessionID',modelComp.SessionID);
                operations.setAttributeValue(blocks(i),'parentSessionID',modelComp.Parent.SessionID);



                lines=blocks(i).connections;
                for j=1:numel(lines)
                    if strcmp(lines(j).getAttribute('sourceUUID').value,uuid)
                        operations.setAttributeValue(lines(j),'sourceSessionID',modelComp.SessionID);

                    elseif strcmp(lines(j).getAttribute('destinationUUID').value,uuid)
                        operations.setAttributeValue(lines(j),'destinationSessionID',modelComp.SessionID);
                    end
                end
            end
        catch
            indicesToDestroy(end+1)=i;%#ok<AGROW> 
        end
    end

    if~isempty(indicesToDestroy)
        for i=1:numel(indicesToDestroy)
            operations.destroy(blocks(indicesToDestroy(i)),true);
        end
        blocks(indicesToDestroy)=[];
    end

    if~isempty(blocks)
        annotationBlocks=blocks(strcmp({blocks.type},'annotation'));
        idx=-1;
        for i=1:numel(annotationBlocks)
            operations.setAttributeValue(annotationBlocks(i),'sessionID',idx);
            idx=idx-1;
        end
    end



end

function updateAttributesToLatest(operations,blocks,hasLineActiveAttribute)

    if isempty(blocks)
        return
    end

    hasLinesAttribute=blocks(1).hasAttribute('lines');
    if~hasLinesAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'lines','hide');
        end
    end

    hasEventAttribute=blocks(1).hasAttribute('event');
    if~hasEventAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'event','false');
        end
    end

    hasImageDataAttribute=blocks(1).hasAttribute('imageData');
    if~hasImageDataAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'imageData','');
        end
    end

    if~hasLineActiveAttribute
        for i=1:numel(blocks)
            lines=blocks(i).connections;
            for j=1:numel(lines)
                operations.setAttributeValue(lines(j),'active','false');
            end
        end
    end

    hasPlotAttribute=blocks(1).hasAttribute('plot');
    if~hasPlotAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'plot','false');
        end
    end

    hasAttribute=blocks(1).hasAttribute('dosedDisabled');
    if~hasAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'dosedDisabled','false');
        end
    end

    hasAttribute=blocks(1).hasAttribute('variant');
    if~hasAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'variant','false');
            operations.setAttributeValue(blocks(i),'variantDisabled','false');
        end
    end

    hasAttribute=blocks(1).hasAttribute('hasDuplicateName');
    if~hasAttribute
        for i=1:numel(blocks)
            operations.setAttributeValue(blocks(i),'hasDuplicateName','false');
        end
    end

end

function updateLineAttributes(operations,blocks)

    needsUpdate=~doesLineHaveColorAttribute(blocks);
    if needsUpdate
        props=SimBiology.web.diagram.linehandler('getDefaultProperties');

        for i=1:numel(blocks)
            lines=blocks(i).connections;
            for j=1:numel(lines)
                operations.setAttributeValue(lines(j),'linecolor',props.linecolor);
                operations.setAttributeValue(lines(j),'linewidth',props.linewidth);
            end
        end
    end

end

function out=doesLineHaveColorAttribute(blocks)


    out=true;
    for i=1:numel(blocks)
        lines=blocks(i).connections;
        for j=1:numel(lines)
            out=lines(j).hasAttribute('linecolor');
            return;
        end
    end

end

function out=doesLineHaveActiveAttribute(blocks)


    out=true;
    for i=1:numel(blocks)
        lines=blocks(i).connections;
        for j=1:numel(lines)
            out=lines(j).hasAttribute('active');
            return;
        end
    end

end

function configureInactiveLineProperty(operations,model)


    objs=sbioselect(model,'Active',false);
    for i=1:length(objs)
        blocks=model.getEntitiesInMap(objs(i).SessionID);
        if~isempty(blocks)


            operations.setAttributeValue(blocks(1).connections,'active','true');
        end
    end

end

function setAllCompartmentVisible(operations,model)


    objs=sbioselect(model,'Type','compartment');
    for i=1:length(objs)
        blocks=model.getEntitiesInMap(objs(i).SessionID);
        if~isempty(blocks)
            operations.setAttributeValue(blocks(1),'visible','true');
        end
    end

end

function out=getBlocksWalkDiagram(syntax)

    out=SimBiology.web.diagram.utilhandler('getBlocksWalkDiagram',syntax);
end
