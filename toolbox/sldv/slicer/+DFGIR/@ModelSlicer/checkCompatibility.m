function status=checkCompatibility(obj,varargin)




    if mod(nargin,2)==0
        error('ModelSlicer:Compatibility:InvalidInputArgs',...
        getString(message('Sldv:ModelSlicer:ModelSlicer:InvalidInputArgs')));
    end


    opts=getOptions(varargin{:});

    errMex={};
    allBlkH=getAllBlocks(obj);
    allBlkTypes=get_param(allBlkH,'BlockType');


    checkUnsupportedBlocks();


    if any(strcmpi(opts.CheckType,{'precompile','all'}))
        checkMachineParenetedData();
        checkSFExportedFunction();
    end


    if any(strcmpi(opts.CheckType,{'highlight','all'}))

    end


    if any(strcmpi(opts.CheckType,{'slice','all'}))
        checkModelToLoadStates();
        checkFunctionCallAcrossModelRef();
        checkExportFunctionModel();
        checkForHarness();
        checkForSteppingMode();
    end


    if~isempty(errMex)
        status='incompatible';
    else
        status='compatible';
    end


    if opts.ThrowError&&~isempty(errMex)
        Mex=MException('ModelSlicer:Compatibility:Incompatible',...
        getString(message('Sldv:ModelSlicer:ModelSlicer:CompatTop',obj.model)));
        for idx=1:length(errMex)
            Mex=addCause(Mex,errMex{idx});
        end
        throw(Mex);
    end



    function checkUnsupportedBlocks()


        unsupportedBlockType={};
        if any(strcmpi(opts.CheckType,{'precompile','all'}))
            unsupportedBlockType=[unsupportedBlockType,{'FunctionCaller','ResetPort','StateWriter','StateReader'}];
        end







        for i=1:length(unsupportedBlockType)
            incompatBlkH=allBlkH(strcmp(allBlkTypes,unsupportedBlockType{i}));
            for j=1:length(incompatBlkH)
                errMex{end+1}=MException('ModelSlicer:Compatibility:UnsupportedBlock',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:UnsupportedBlock',...
                getfullname(incompatBlkH(j)))));%#ok<AGROW>
            end
        end
        if any(strcmpi(opts.CheckType,{'precompile','highlight','all'}))
            susysBlkH=allBlkH(strcmp(allBlkTypes,'SubSystem'));
            for i=1:length(susysBlkH)
                if strcmp(get_param(susysBlkH(i),'IsSimulinkFunction'),'on')
                    errMex{end+1}=MException('ModelSlicer:Compatibility:SimulinkFunction',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:SimulinkFunction',...
                    getfullname(susysBlkH(i)))));%#ok<AGROW>
                end
            end
        end

        incompatRootBlockType={'TriggerPort','EnablePort'};
        rootBlkH=find_system(obj.modelH,'FindAll','on','SearchDepth',1,'type','block');
        rootBlkType=get_param(rootBlkH,'BlockType');
        for i=1:length(incompatRootBlockType)
            incompatRootBlkH=rootBlkH(strcmp(rootBlkType,incompatRootBlockType{i}));
            for j=1:length(incompatRootBlkH)
                errMex{end+1}=MException('ModelSlicer:Compatibility:UnsupportedBlock',...
                sprintf('Block type of ''%s'' at root-level is not supported.',...
                getfullname(incompatRootBlkH(j))));%#ok<AGROW>
            end
        end


        ForEachBlkH=allBlkH(strcmp(allBlkTypes,'ForEach'));
        for i=1:length(ForEachBlkH)
            ph=get_param(ForEachBlkH(i),'PortHandles');
            if~isempty(ph.Inport)||~isempty(ph.Outport)
                errMex{end+1}=MException('ModelSlicer:Compatibility:UnsupportedBlock',...
                sprintf('ForEach ''%s'' has inport(s) and this configuration is not supported.',...
                getfullname(ForEachBlkH(i))));%#ok<AGROW>
            end
        end


        obsBlks=Simulink.observer.internal.getObserverRefBlocksInBD(obj.modelH);
        for i=1:numel(obsBlks)
            errMex{end+1}=MException('ModelSlicer:Compatibility:UnsupportedBlock',...
            sprintf('Observer ''%s'' is not supported.',...
            getfullname(obsBlks(i))));%#ok<AGROW>
        end
    end

    function checkModelToLoadStates()


        if strcmp(get_param(obj.modelH,'LoadInitialState'),'on')
            msg=getString(message('Sldv:ModelSlicer:ModelSlicer:LoadInitialStateIsON'));
            errMex{end+1}=MException('ModelSlicer:Compatibility:LoadInitialStateIsON',msg);
        end
    end

    function checkMachineParenetedData()
        mdlName=get_param(obj.modelH,'Name');
        machineId=sf('find','all','machine.name',mdlName);
        if~isempty(machineId)
            objIds=sf('DataOf',machineId);
            if~isempty(objIds)
                errMsgD=getString(message('Sldv:ModelSlicer:gui:MachineParentedData'));
                for i=1:length(objIds)
                    errMsgD=[errMsgD,sprintf('<li> ''%s''  (#%d)</li>',sf('get',objIds(i),'.name'),objIds(i))];%#ok<AGROW>
                end
                errMex{end+1}=MException('ModelSlicer:Compatibility:MachineParentedData',errMsgD);
            end
            objIds=sf('EventsOf',machineId);
            if~isempty(objIds)
                errMsgE=getString(message('Sldv:ModelSlicer:gui:MachineParentedEvent'));
                for i=1:length(objIds)
                    errMsgE=[errMsgE,sprintf('<li> ''%s''  (#%d)</li>',sf('get',objIds(i),'.name'),objIds(i))];%#ok<AGROW>
                end
                errMex{end+1}=MException('ModelSlicer:Compatibility:MachineParentedEvent',errMsgE);
            end
        end
    end

    function checkSFExportedFunction()
        mdlName=get_param(obj.modelH,'Name');
        rt=sfroot;
        machine=rt.find('-isa','Stateflow.Machine','Name',mdlName);
        chart=[];
        if~isempty(machine)
            chart=machine.find('-isa','Stateflow.Chart');
        end
        for i=1:length(chart)
            if chart(i).ExportChartFunctions
                errMsg=getString(message('Sldv:ModelSlicer:gui:SFExportedFunction',chart(i).Path));
                errMex{end+1}=MException('ModelSlicer:Compatibility:SFExportedFunction',errMsg);%#ok<AGROW>
            end
        end
    end

    function checkFunctionCallAcrossModelRef()
        modelBlkH=obj.refMdlToMdlBlk.values;
        for n=1:length(modelBlkH)
            found=false;
            ph=get(modelBlkH{n},'PortHandles');
            for m=1:length(ph.Inport)
                CompiledPortDataType=get(ph.Inport(m),'CompiledPortDataType');
                if strcmp(CompiledPortDataType,'fcn_call')
                    found=true;
                end
            end
            if found
                errMsg=getString(message('Sldv:ModelSlicer:gui:FunctionCallInport',getfullname(modelBlkH{n})));
                errMex{end+1}=MException('ModelSlicer:Compatibility:FunctionCallInport',errMsg);%#ok<AGROW>
            end
        end
    end

    function checkExportFunctionModel()


        mdlName=get_param(obj.modelH,'Name');
        if slprivate('getIsExportFcnModel',mdlName)
            errMsg=getString(message('Sldv:ModelSlicer:gui:ExportFunctionModel',mdlName));
            errMex{end+1}=MException('ModelSlicer:Compatibility:ExportFunctionModel',errMsg);
        end
    end
    function checkForHarness()
        if obj.isHarness
            msg=getString(message('Sldv:ModelSlicer:gui:HarnessSliceIsNotSupported'));
            errMex{end+1}=MException(...
            'ModelSlicer:Compatibility:HarnessSliceIsNotSupported',msg);
        end
    end

    function checkForSteppingMode()
        if obj.inSteppingMode
            msg=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipUnsupStepping'));
            errMex{end+1}=MException(...
            'ModelSlicer:Compatibility:SliceUnsupportedWithStepping',msg);
        end
    end
end

function opts=getOptions(varargin)



    opts.CheckType='all';
    opts.ThrowError=true;
    opts.UImode=false;
    opts.InactiveBlockHandle=[];

    if nargin<2
        return;
    end
    for i=1:2:nargin
        nonSupportedValue=false;
        switch varargin{i}
        case 'CheckType'
            if any(strcmpi(varargin{i+1},{'precompile','postcompile','highlight','slice','slice_post_analysis','all'}))
                opts.CheckType=varargin{i+1};
            else
                nonSupportedValue=true;
            end
        case 'ThrowError'
            if islogical(varargin{i+1})
                opts.ThrowError=varargin{i+1};
            else
                nonSupportedValue=true;
            end
        end
        if nonSupportedValue
            error(getString(message('Sldv:ModelSlicer:ModelSlicer:InvalidOpt',...
            varargin{i},varargin{i+1})));
        end
    end
end
function blkH=getAllBlocks(obj)

    blkH=[];
    lumOpt=Transform.AtomicGroup.msLookUnderMasks(obj.options);
    fllOpt=Transform.AtomicGroup.msFollowLinks(obj.options);






    allMdls=find_mdlrefs(obj.model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    for i=1:length(allMdls)
        if~bdIsLoaded(allMdls{i})
            load_system(allMdls{i});
        end


        blkH=[blkH;find_system(allMdls{i},'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks',lumOpt,'FollowLinks',fllOpt,...
        'type','block')];%#ok<AGROW>
    end
end


