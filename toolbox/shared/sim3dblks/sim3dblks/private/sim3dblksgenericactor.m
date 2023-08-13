function[varargout]=sim3dblksgenericactor(varargin)

    varargout{1}={};

    block=varargin{1};
    Context=varargin{2};

    switch Context
    case 'Initialization'
        Initialization(block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'SetInitScript'
        SetInitScript(block);
    case 'SetInputs'
        SetInputs(block);
    case 'SetOutputs'
        SetOutputs(block);
    case 'SetEvents'
        SetEvents(block);
    case 'SelectSourceFile'
        SelectSourceFile(block);
    case 'UpdateOnOperationChange'
        UpdateOnOperationChange(block);
    case 'InputsButton'
        InputsButton(block);
    case 'OutputsButton'
        OutputsButton(block);
    case 'EventsButton'
        EventsButton(block);
    case 'ResetPorts'
        ResetBlockPorts(block);
    end
end

function Initialization(block)
    SetInitScript(block);
    SetInputs(block);
    SetOutputs(block);
    SetEvents(block);
    if~isequal(get_param(bdroot(block),'LibraryType'),'None')
        return;
    end
    autoblkscheckparams(block,{'SampleTime',[1,1],{'st',0};});
    operation=get_param(block,'Operation');
    srcFile=get_param(block,'SourceFile');
    if(strcmp('Create at setup',operation))
        sim3d.utils.SimPool.addActorTag(block);
    end
    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        updateBlockInports(block);
        updateBlockOutports(block);
        actorName=get_param(block,'ActorName');
        parentName=get_param(block,'ParentName');
        if(strcmp('Create at setup',operation)||...
            strcmp('Create at step',operation))
            if(~isempty(srcFile))
                mustBeFile(srcFile);
            end
        end
        if strcmp(parentName,'Scene Origin')
            parentName='SceneOrigin';
        end
        if~(isNameValid(actorName))
            error(message('shared_sim3dblks:sim3dblkActor:InvalidActorName',actorName));
        end
        if~(isNameValid(parentName))
            error(message('shared_sim3dblks:sim3dblkActor:InvalidParentName',parentName));
        end
    end
end

function IconInfo=DrawCommands(block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(block,AliasNames);


    IconInfo.ImageName='sim3d_generic_actor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function SetInitScript(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        initScriptTextArea=maskObj.getParameter('InitScriptText');
        set_param([block,'/Simulation 3D Generic Actor'],'InitScript',initScriptTextArea.Value);
    end
end

function SetInputs(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        inputsTextArea=maskObj.getParameter('InputsText');
        props=getPropertyNames(inputsTextArea.Value);
        if~isempty(props{1})
            for prop=1:length(props)
                [propertyName,~]=getPropertyNamespace(props{prop});
                if~checkPropValidity(propertyName,1)
                    error(message("shared_sim3dblks:sim3dblkActor:InvalidInputProperty",propertyName));
                end
            end
        end
        set_param([block,'/Simulation 3D Generic Actor'],'Inputs',inputsTextArea.Value);
    end
end

function SetOutputs(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        outputsTextArea=maskObj.getParameter('OutputsText');
        props=getPropertyNames(outputsTextArea.Value);
        if~isempty(props{1})
            for prop=1:length(props)
                [propertyName,~]=getPropertyNamespace(props{prop});
                if~checkPropValidity(propertyName,2)
                    error(message("shared_sim3dblks:sim3dblkActor:InvalidOutputProperty",propertyName));
                end
            end
        end
        set_param([block,'/Simulation 3D Generic Actor'],'Outputs',outputsTextArea.Value);
    end
end

function SetEvents(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        eventsTextArea=maskObj.getParameter('EventsText');
        props=getPropertyNames(eventsTextArea.Value);
        if~isempty(props{1})
            for prop=1:length(props)
                [propertyName,~]=getPropertyNamespace(props{prop});
                if~checkPropValidity(propertyName,3)
                    error(message("shared_sim3dblks:sim3dblkActor:InvalidEventsProperty",propertyName));
                end
            end
        end
        set_param([block,'/Simulation 3D Generic Actor'],'Events',eventsTextArea.Value);
    end
end

function SelectSourceFile(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        SrcFile=maskObj.getParameter('SourceFile');
        oldSrc=SrcFile.Value;
        [file,path,~]=uigetfile({'*.m;*.mat;*.stl;*.fbx;*.urdf;*.x3d'},'Select File',pwd);
        if~file==0
            newSrc=[path,file];
        else
            newSrc=oldSrc;
        end
        SrcFile.Value=newSrc;
    end
end

function UpdateOnOperationChange(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        opPrm=maskObj.getParameter('Operation');
        ParentName=maskObj.getParameter('ParentName');
        operation=opPrm.Value;
        SourceFile=maskObj.getParameter('SourceFile');
        SelectSrcButton=maskObj.getDialogControl('SelectSourceFile');
        TransformTab=maskObj.getDialogControl('TransformTab');
        InitScript=maskObj.getParameter('InitScriptText');
        InputsTab=maskObj.getDialogControl('InputsTab');
        OutputsTab=maskObj.getDialogControl('OutputsTab');
        if(strcmp('Create at setup',operation))
            sim3d.utils.SimPool.addActorTag(block);
        else
            sim3d.utils.SimPool.DestroyCallback(block);
        end
        if(strcmp('Reference by name',operation)||...
            strcmp('Reference by instance number',operation))
            SourceFile.Visible='off';
            SourceFile.Enabled='off';
            SelectSrcButton.Visible='off';
            SelectSrcButton.Enabled='off';
            InitScript.Visible='off';
            InitScript.Enabled='off';
            TransformTab.Visible='off';
            TransformTab.Enabled='off';
            ParentName.Visible='off';
            ParentName.Enabled='off';
        else
            SourceFile.Visible='on';
            SourceFile.Enabled='on';
            SelectSrcButton.Visible='on';
            SelectSrcButton.Enabled='on';
            InitScript.Visible='on';
            InitScript.Enabled='on';
            TransformTab.Visible='on';
            TransformTab.Enabled='on';
            ParentName.Visible='on';
            ParentName.Enabled='on';
        end
        if(strcmp('Create at step',operation))
            InputsTab.Visible='off';
            InputsTab.Enabled='off';
            OutputsTab.Visible='off';
            OutputsTab.Enabled='off';
        else
            InputsTab.Visible='on';
            InputsTab.Enabled='on';
            OutputsTab.Visible='on';
            OutputsTab.Enabled='on';
        end
    end
end

function InputsButton(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        actorNamePrm=maskObj.getParameter('ActorName');
        actorName=actorNamePrm.Value;
        InputsText=maskObj.getParameter('InputsText');
        world=sim3d.World.getWorld(string(bdroot));
        if isempty(world)
            world=sim3d.World.buildWorldFromModel(string(bdroot));
        end
        actor=world.Root.findBy('ActorName',actorName,'first');
        operation=get_param(block,'Operation');
        if isempty(actor)&&(strcmp('Reference by name',operation))
            warning(message('shared_sim3dblks:sim3dblkActor:ActorReferenceNotFound',actorName));
            actor=sim3d.Actor('ActorName',actorName);
        end
        if isempty(actor)&&(strcmp('Reference by instance number',operation))
            actor=sim3d.Actor('ActorName','*');
        end
        sim3d.internal.PortDesigner(actor,strtrim(splitlines(InputsText.Value)),'InputsText',gcb);
        world.delete();
    end
end

function OutputsButton(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        actorNamePrm=maskObj.getParameter('ActorName');
        actorName=actorNamePrm.Value;
        OutputsText=maskObj.getParameter('OutputsText');
        world=sim3d.World.getWorld(string(bdroot));
        if isempty(world)
            world=sim3d.World.buildWorldFromModel(string(bdroot));
        end
        actor=world.Root.findBy('ActorName',actorName,'first');
        operation=get_param(block,'Operation');
        if isempty(actor)&&(strcmp('Reference by name',operation))
            warning(message('shared_sim3dblks:sim3dblkActor:ActorReferenceNotFound',actorName));
            actor=sim3d.Actor('ActorName',actorName);
        end
        if isempty(actor)&&(strcmp('Reference by instance number',operation))
            actor=sim3d.Actor('ActorName','*');
        end
        sim3d.internal.PortDesigner(actor,strtrim(splitlines(OutputsText.Value)),'OutputsText',gcb);
        world.delete();
    end
end

function EventsButton(block)

    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        actorNamePrm=maskObj.getParameter('ActorName');
        actorName=actorNamePrm.Value;
        EventsText=maskObj.getParameter('EventsText');
        world=sim3d.World.getWorld(string(bdroot));
        if isempty(world)
            world=sim3d.World.buildWorldFromModel(string(bdroot));
        end
        actor=world.Root.findBy('ActorName',actorName,'first');
        operation=get_param(block,'Operation');
        if isempty(actor)&&(strcmp('Reference by name',operation))
            warning(message('shared_sim3dblks:sim3dblkActor:ActorReferenceNotFound',actorName));
            actor=sim3d.Actor('ActorName',actorName);
        end
        if isempty(actor)&&(strcmp('Reference by instance number',operation))
            actor=sim3d.Actor('ActorName','*');
        end
        sim3d.internal.PortDesigner(actor,strtrim(splitlines(EventsText.Value)),'EventsText',gcb);
        world.delete();
    end
end

function updateBlockInports(block)

    if~bdIsLibrary(bdroot(block))
        needUpdate=false;
        conn=autoblksgetblockconn([block,'/Simulation 3D Generic Actor']);
        connText=strtrim(splitlines(get_param([block,'/Simulation 3D Generic Actor'],'Inputs')));
        if strcmp(get_param(block,'Operation'),'Create at step')
            if isempty(connText{1})
                connText{1}='Instance';
            else
                connText={'Instance'};
            end
        end
        if strcmp(get_param(block,'Operation'),'Reference by instance number')
            if isempty(connText{1})
                connText{1}='Instance';
            else
                connText=[{'Instance'};connText];
            end
        end
        currInports=find_system(block,'LookUnderMasks','on','FollowLinks','on','BlockType','Inport');
        updateIndex=1;
        if isempty(currInports)&&...
            ~isequal(length(conn.Inports),length(currInports))
            needUpdate=true;
        else
            for i=1:length(conn.Inports)
                if i>length(currInports)
                    needUpdate=true;
                    updateIndex=i;
                    break;
                end
                ipName=get_param(currInports(i),'Name');
                if~strcmp([connText{i}],ipName{1})
                    updateIndex=i;
                    needUpdate=true;
                    break;
                end
            end
        end
        if length(conn.Inports)<length(currInports)
            if~needUpdate
                needUpdate=true;
                updateIndex=length(conn.Inports)+1;
            end
        end

        if needUpdate
            for i=updateIndex:length(conn.Inports)
                if~isequal(conn.Inports(i).LineHdl,-1)
                    delete_line(conn.Inports(i).LineHdl);
                end
            end
            for i=updateIndex:length(currInports)
                delete_block(currInports{i});
            end
            delete_line(find_system(block,'LookUnderMasks','on','FollowLinks','on','FindAll','on','Type','line','Connected','off'));
            if~isempty(connText{1})
                for i=updateIndex:length(connText)
                    h=add_block('simulink/Commonly Used Blocks/In1',[block,'/',connText{i}]);
                    hInpHandle=get_param(h,'PortHandles');
                    sysObjInpHandle=get_param([block,'/Simulation 3D Generic Actor'],'PortHandles');
                    if~isempty(sysObjInpHandle.Inport(i))&&~isempty(hInpHandle.Outport(1))
                        add_line(block,hInpHandle.Outport(1),sysObjInpHandle.Inport(i));
                    end
                end
            end
        end
    end
end

function updateBlockOutports(block)

    if~bdIsLibrary(bdroot(block))
        needUpdate=false;
        conn=autoblksgetblockconn([block,'/Simulation 3D Generic Actor']);
        connText=strtrim(splitlines(get_param([block,'/Simulation 3D Generic Actor'],'Outputs')));
        connEvtText=strtrim(splitlines(get_param([block,'/Simulation 3D Generic Actor'],'Events')));
        updateIndex=2;
        if~isempty(connEvtText{1})

            l=length(connText);
            if isempty(connText{1})
                l=0;
            end
            for i=1:length(connEvtText)
                connText{l+i}=connEvtText{i};
            end
        end
        currOutports=find_system(block,'LookUnderMasks','on','FollowLinks','on','BlockType','Outport');
        if isequal(length(currOutports),1)&&...
            ~isequal(length(conn.Outports),length(currOutports))
            needUpdate=true;
        else
            for i=2:length(conn.Outports)
                if i>length(currOutports)
                    needUpdate=true;
                    updateIndex=i;
                    break;
                end
                opName=get_param(currOutports(i),'Name');
                if~strcmp([connText{i-1},'OUT'],opName{1})
                    updateIndex=i;
                    needUpdate=true;
                    break;
                end
            end
        end
        if length(conn.Outports)<length(currOutports)
            if~needUpdate
                needUpdate=true;
                updateIndex=length(conn.Outports)+1;
            end
        end
        if needUpdate
            for i=updateIndex:length(conn.Outports)
                if~isequal(conn.Outports(i).LineHdl,-1)
                    delete_line(conn.Outports(i).LineHdl);
                end
            end
            for i=updateIndex:length(currOutports)
                delete_block(currOutports{i});
            end
            delete_line(find_system(block,'LookUnderMasks','on','FollowLinks','on','FindAll','on','Type','line','Connected','off'));
            if~isempty(connText{1})
                for i=(updateIndex-1):length(connText)
                    h=add_block('simulink/Commonly Used Blocks/Out1',[block,'/',connText{i},'OUT']);
                    hInpHandle=get_param(h,'PortHandles');
                    sysObjInpHandle=get_param([block,'/Simulation 3D Generic Actor'],'PortHandles');
                    if~isempty(sysObjInpHandle.Outport(i+1))&&~isempty(hInpHandle.Inport(1))
                        add_line(block,sysObjInpHandle.Outport(i+1),hInpHandle.Inport(1));
                    end
                end
            end
        end
    end
end

function ResetBlockPorts(block)

    operation=get_param(block,'Operation');
    srcFile=get_param(block,'SourceFile');
    if strcmp(operation,'Create at setup')&&~isequal(srcFile,'')

        blocksToReset={};
        libraryBlock='sim3dlib/Simulation 3D Actor';
        blockList=find_system(string(bdroot(block)),'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','ReferenceBlock',libraryBlock);
        for i=1:length(blockList)


            if isequal(blockList{i},block)
                continue;
            end
            blockOp=get_param(blockList{i},'Operation');
            blockSrc=get_param(blockList{i},'SourceFile');
            if(strcmp(blockOp,'Create at setup'))&&strcmp(srcFile,blockSrc)
                blocksToReset=[blocksToReset,{blockList{i}}];
            end
        end

        if~isempty(blocksToReset)
            blocksToReset=[{block},blocksToReset];

            for i=1:length(blocksToReset)

                set_param(blocksToReset{i},'InputsText','');
                set_param(blocksToReset{i},'OutputsText','');
                set_param(blocksToReset{i},'EventsText','');



                set_param(blocksToReset{i},'Operation','Create at setup');
                warning(message('shared_sim3dblks:sim3dblkActor:ResetPortsAfterBlockRename',blocksToReset{i}));
            end
        end
    end

end

function[propertyName,actorName]=getPropertyNamespace(port)
    namespaceElements=split(port,'.');
    if length(namespaceElements)<2||length(namespaceElements)>2
        error(message("shared_sim3dblks:sim3dblkActor:InvalidPortFormat",port))
    end
    actorName=namespaceElements{1};
    propertyName=namespaceElements{2};
end

function[propertyNames]=getPropertyNames(properties)
    propertyNames=strtrim(splitlines(properties))';
end

function valid=checkPropValidity(prop,listType)
    switch listType
    case 1
        list={'Translation','Rotation','Scale',...
        'Color','Transparency','Shininess','Metallic','Tessellation',...
        'Mass','CenterOfMass','Collisions'};
    case 2
        list={'Translation','Rotation','Scale',...
        'Color','Transparency','Shininess','Metallic','Tessellation',...
        'Mass','CenterOfMass','Collisions'};
    case 3
        list={'OnHit','Activate','BeginOverlap','EndOverlap','IsOverlapped','Control','Menu'};
    end
    valid=ismember({prop},list);
end

function valid=isNameValid(str)
    if(strcmp(str,''))
        valid=true;
        return;
    end
    retval=false(size(str));
    retval(regexp(str,'[a-zA-Z0-9_]'))=true;
    retval(1)=isstrprop(str(1),'alpha');
    valid=all(retval);
end