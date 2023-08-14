function createDiagramFromModel(operations,model,syntax,varargin)



    isPK=false;
    if nargin==4
        isPK=varargin{1};
        if~isPK
            isPK=startsWith(model.Notes,'Model constructed with PKModelDesign with compartments:');
        end
    end


    createBlocksUsingModel(operations,model,syntax.root);


    blocks=model.getAllEntitiesInMap;


    connectBlocksUsingModel(operations,model);

    if isPK
        try
            layoutPKModel(model,operations);
        catch
            layoutDiagram(model,syntax,operations,blocks);
        end
    else
        layoutDiagram(model,syntax,operations,blocks);
    end

end

function createBlocksUsingModel(operations,model,root)


    compartments=sbioselect(model,'Type','Compartment','Where','Owner','==',[]);
    for i=1:numel(compartments)
        createCompartmentBlock(root,operations,model,compartments(i));
    end

    rules=sbioselect(model.Rules,'RuleType',getSupportedRuleTypes);
    params=getParametersToAdd(rules,model.Events);

    for i=1:numel(params)
        createBlock(operations,model,root,params(i));
    end

    reactions=model.Reactions;
    for i=1:numel(reactions)
        createBlock(operations,model,root,reactions(i));
    end

    for i=1:numel(rules)
        createBlock(operations,model,root,rules(i));
    end

end

function connectBlocksUsingModel(operations,model)


    reactions=model.Reactions;
    for i=1:numel(reactions)
        createLinesForReaction(operations,model,reactions(i));
    end


    rules=sbioselect(model.Rules,'RuleType',getSupportedRuleTypes);
    for i=1:numel(rules)
        createLinesForRule(operations,model,rules(i));
    end

end

function createCompartmentBlock(root,operations,model,compartment)

    b=createBlock(operations,model,root,compartment);

    if~isempty(compartment.Compartments)
        for i=1:numel(compartment.Compartments)
            createCompartmentBlock(b.subdiagram,operations,model,compartment.Compartments(i));
        end
    end

    if~isempty(b)

        species=compartment.Species;
        for j=1:numel(species)
            createBlock(operations,model,b.subdiagram,species(j));
        end
    end

end

function layoutPKModel(model,operations)

    comps=model.Compartments;
    x=100;
    y=100;
    spaceBetweenCompartments=50;

    for i=1:numel(comps)
        compartmentBlock=model.getEntitiesInMap(comps(i).SessionID);
        compartmentSize=compartmentBlock.getSize;
        operations.setPosition(compartmentBlock,x,y);


        species=comps(i).Species;
        dose=sbioselect(species,'Name',['Dose_',comps(i).Name]);
        drug=sbioselect(species,'Name',['Drug_',comps(i).Name]);
        doseBlock=model.getEntitiesInMap(dose.SessionID);
        drugBlock=model.getEntitiesInMap(drug.SessionID);
        drugSize=drugBlock.getSize;


        operations.setPosition(doseBlock,25,25);
        operations.setPosition(drugBlock,ceil(compartmentSize.width/2-drugSize.width/2),ceil(compartmentSize.height/2-drugSize.height/2));


        reaction=sbioselect(model,'Type','reaction','Reactant',drug);
        for j=1:length(reaction)
            reactionBlock=model.getEntitiesInMap(reaction(j).SessionID);
            reactionSize=reactionBlock.getSize;
            if isempty(reaction(j).Product)

                rx=x+ceil(compartmentSize.width/2-reactionSize.width/2);
                ry=y+compartmentSize.height+50;
                operations.setPosition(reactionBlock,rx,ry);
            else

                rx=x+ceil(compartmentSize.width+spaceBetweenCompartments/2-reactionSize.width/2);
                ry=y+ceil(compartmentSize.height/2-reactionSize.height/2);
                operations.setPosition(reactionBlock,rx,ry);
            end
        end


        reaction=sbioselect(model,'Type','reaction','Product',drug);
        if~isempty(reaction)
            reactionBlock=model.getEntitiesInMap(reaction(1).SessionID);
            reactionSize=reactionBlock.getSize;
            operations.setParent(reactionBlock,compartmentBlock.subdiagram);
            operations.setPosition(reactionBlock,ceil(compartmentSize.width/2-reactionSize.width/2),25);
        end

        x=x+compartmentSize.width+spaceBetweenCompartments;
    end

end

function layoutDiagram(model,syntax,operations,blocks)

    layoutArgs=struct('setCompartmentSize',true,'layoutType','circle');
    layoutDiagramHelper(model,syntax,operations,layoutArgs,blocks);

end

function block=createBlock(operations,model,root,obj)

    block=SimBiology.web.diagramhandler('createBlock',operations,model,root,obj);

end

function createLinesForReaction(operations,model,obj)

    SimBiology.web.diagram.reactionhandler('createLines',operations,model,obj);

end

function createLinesForRule(operations,model,obj)

    SimBiology.web.diagram.rulehandler('createLines',operations,model,obj);

end

function params=getParametersToAdd(rules,events)

    params=SimBiology.web.diagram.utilhandler('getParametersToAdd',rules,events);

end

function types=getSupportedRuleTypes

    types=SimBiology.web.diagramhandler('getSupportedRuleTypes');

end

function layoutDiagramHelper(model,syntax,operations,inputs,blocks)

    SimBiology.web.diagram.layouthandler('layoutDiagramHelper',model,syntax,operations,inputs,blocks);
end
