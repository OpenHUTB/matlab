function out=inithandler(action,varargin)











    out=[];

    switch(action)
    case 'initDiagramSyntax'
        out=initDiagramSyntax(varargin{1});
    case 'initDiagramEditor'
        out=initDiagramEditor(varargin{:});
    case 'doesDiagramSyntaxNeedToBeInitialized'
        out=doesDiagramSyntaxNeedToBeInitialized(varargin{:});
    end

end

function out=initDiagramEditor(inputs)


    editor=inputs.model.getDiagramEditor;
    editor.commandProcessor.maxDepth=10000;


    out=struct('modelSessionID',inputs.model.SessionID,'diagramInfo','');
    out.diagramInfo=struct('diagramUUID',editor.uuid,'message','');

end

function out=initDiagramSyntax(inputs)


    assert(isfield(inputs,'model')&&strcmp(inputs.model.Type,'sbiomodel'),'Input to initDiagramSyntax must contain a sbiomodel object');

    out=struct('diagramUUID','','message','');

    try
        if~inputs.model.hasDiagramSyntax
            SimBiology.internal.initDiagram(inputs.model);
        end

        syntax=inputs.model.getDiagramSyntax;
        syntax.modifyPrototypes(@(operations,prototypeOperations,diagram)createDiagramPaletteOperations(operations,prototypeOperations,diagram));
        syntax.modify(@(operations)initDiagramOperations(operations,syntax,inputs));
    catch
        out=recreateDiagramAfterError(inputs);
    end

end

function out=recreateDiagramAfterError(inputs)

    out=struct('diagramUUID','','message','');

    try
        inputs.model.deleteDiagramSyntax;
        SimBiology.internal.initDiagram(inputs.model);
        inputs.viewFile='';

        syntax=inputs.model.getDiagramSyntax;
        syntax.modifyPrototypes(@(operations,prototypeOperations,diagram)createDiagramPaletteOperations(operations,prototypeOperations,diagram));
        syntax.modify(@(operations)initDiagramOperations(operations,syntax,inputs));
    catch ex
        out=struct('diagramUUID','','message',SimBiology.web.internal.errortranslator(ex));
    end

end

function createDiagramPaletteOperations(operations,prototypeOperations,diagram)


    customBlockLibrary=[];
    prefFileName=SimBiology.web.desktophandler('getModelBuilderPreferenceFileName');
    if exist(prefFileName,'file')
        preferences=load(prefFileName);
        preferences=preferences.preferences;
        preferences=preferences.preferences;

        if isfield(preferences,'customBlockLibrary')
            customBlockLibrary=preferences.customBlockLibrary;
        end
    end


    createPalette(operations,prototypeOperations,customBlockLibrary,diagram);

end

function initDiagramOperations(operations,syntax,inputs)


    model=inputs.model;
    viewFile=inputs.viewFile;


    isPK=false;
    if isfield(inputs,'isPK')
        isPK=inputs.isPK;
    end



    convertedPath=strrep(viewFile,'\','/');
    [~,~,ext]=fileparts(convertedPath);

    switch ext
    case '.json'

        SimBiology.web.diagram.loadDiagramUsingJSON(operations,model,syntax,inputs);
    case '.view'

        loadDiagramOldVersion(operations,model,syntax,inputs);
    otherwise
        SimBiology.web.diagram.createDiagramFromModel(operations,model,syntax,isPK);
    end


    configureBlockIndicators(operations,model);

end

function loadDiagramOldVersion(operations,model,syntax,inputs)

    switch inputs.projectVersion
    case{'4.1','4.2','4.3','4.3.1','5','5.1','5.2','5.3','5.4'}

        SimBiology.web.diagram.loadDiagramOldVersion16aOrOlder(operations,model,syntax,inputs)
    case{'5.5','5.6','5.7','5.8','5.8.1','5.8.2'}

        SimBiology.web.diagram.loadDiagramOldVersion16bOrNewer(operations,syntax,model,inputs);
    case{1,1.1}

        SimBiology.web.diagram.loadDiagramOldVersion16bOrNewer(operations,syntax,model,inputs);
    end

end

function configureBlockIndicators(operations,model)


    d=getdose(model);
    activeTargets=[];
    inactiveTargets=[];

    for i=1:length(d)
        target=resolvetarget(d(i),d(i).Parent);
        if~isempty(target)
            if d(i).Active
                activeTargets(end+1)=target.SessionID;%#ok<AGROW>
            else
                inactiveTargets(end+1)=target.SessionID;%#ok<AGROW>
            end
        end
    end

    activeTargets=unique(activeTargets);
    inactiveTargets=unique(inactiveTargets);
    inactiveTargets=setdiff(inactiveTargets,activeTargets);


    v=getvariant(model);
    activeVariantStates=[];
    inactiveVariantStates=[];

    for i=1:numel(v)
        states=privateresolve(v(i),model);
        active=v(i).Active;
        for j=1:numel(states)
            if isvalid(states(j))
                if active
                    activeVariantStates(end+1)=states(j).SessionID;%#ok<AGROW>
                else
                    inactiveVariantStates(end+1)=states(j).SessionID;%#ok<AGROW>
                end
            end
        end
    end

    activeVariantStates=unique(activeVariantStates);
    inactiveVariantStates=unique(inactiveVariantStates);
    inactiveVariantStates=setdiff(inactiveVariantStates,activeVariantStates);


    initialAssignmentLHS=SimBiology.web.modelhandler('getInitialAssignmentLHS',model);
    repeatAssignmentLHS=SimBiology.web.modelhandler('getRepeatAssignmentLHS',model);


    eventLHS=SimBiology.web.modelhandler('getEventLHS',model);


    inactive=sbioselect(model,'Type',{'rule','reaction'},'Active',false);

    for i=1:length(activeTargets)
        b=model.getEntitiesInMap(activeTargets(i));
        if~isempty(b)
            operations.setAttributeValue(b,'dosed','true');
        end
    end

    for i=1:length(inactiveTargets)
        b=model.getEntitiesInMap(inactiveTargets(i));
        if~isempty(b)
            operations.setAttributeValue(b,'dosedDisabled','true');
        end
    end

    componentsWithDuplicateNames=findobj(model,'HasDuplicateName',true);
    for id=[componentsWithDuplicateNames.SessionID]
        b=model.getEntitiesInMap(id);
        if~isempty(b)
            operations.setAttributeValue(b,'hasDuplicateName','true');
        end
    end

    for i=1:length(activeVariantStates)
        b=model.getEntitiesInMap(activeVariantStates(i));
        if~isempty(b)
            operations.setAttributeValue(b,'variant','true');
        end
    end

    for i=1:length(inactiveVariantStates)
        b=model.getEntitiesInMap(inactiveVariantStates(i));
        if~isempty(b)
            operations.setAttributeValue(b,'variantDisabled','true');
        end
    end

    for i=1:length(eventLHS)
        b=model.getEntitiesInMap(eventLHS(i));
        if~isempty(b)
            operations.setAttributeValue(b,'event','true');
        end
    end

    for i=1:length(initialAssignmentLHS)
        b=model.getEntitiesInMap(initialAssignmentLHS(i));
        if~isempty(b)
            operations.setAttributeValue(b,'initialAssignment','true');
        end
    end

    for i=1:length(repeatAssignmentLHS)
        b=model.getEntitiesInMap(repeatAssignmentLHS(i));
        if~isempty(b)
            operations.setAttributeValue(b,'repeatAssignment','true');
        end
    end

    for i=1:length(inactive)
        b=model.getEntitiesInMap(inactive(i).SessionID);
        if~isempty(b)
            operations.setAttributeValue(b,'active','true');
        end
    end

end

function out=doesDiagramSyntaxNeedToBeInitialized(input)

    if strcmp(input.appType,'ModelingApp')

        out=true;
    else


        mb=SimBiology.web.desktophandler('getModelBuilder');
        out=~isempty(mb.webWindow);
    end

end

function createPalette(operations,prototypeOperations,customBlockLibrary,diagram)

    SimBiology.web.diagram.palettehandler('createPalette',operations,prototypeOperations,customBlockLibrary,diagram);

end
