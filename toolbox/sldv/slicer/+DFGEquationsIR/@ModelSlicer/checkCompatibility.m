function status=checkCompatibility(obj,varargin)




    if mod(nargin,2)==0
        error('ModelSlicer:Compatibility:InvalidInputArgs',...
        getString(message('Sldv:ModelSlicer:ModelSlicer:InvalidInputArgs')));
    end


    opts=getOptions(varargin{:});
    errMex={};


    if any(strcmpi(opts.CheckType,{'precompile'}))
        checkUnsupportedBlocks();
        checkMachineParentedData();
    end


    if any(strcmpi(opts.CheckType,{'slice'}))
        checkModelToLoadStates();
        checkForObservers();
        checkForArchModel();
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







        allMdls=find_mdlrefs(obj.model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);


        for mdl=allMdls'
            if~bdIsLoaded(mdl)
                load_system(mdl);
            end

            slFcnBlks=Simulink.findBlocksOfType(mdl,'SubSystem','IsSimulinkFunction','on');

            if~isempty(slFcnBlks)
                for i=1:length(slFcnBlks)
                    errMex{end+1}=MException('ModelSlicer:Compatibility:SimulinkFunction',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:SimulinkFunction',...
                    getfullname(slFcnBlks(i)))));%#ok<AGROW>
                end
            end
        end
    end

    function checkModelToLoadStates()


        if strcmp(get_param(obj.modelH,'LoadInitialState'),'on')
            msg=getString(message('Sldv:ModelSlicer:ModelSlicer:LoadInitialStateIsON'));
            errMex{end+1}=MException('ModelSlicer:Compatibility:LoadInitialStateIsON',msg);
        end
    end

    function checkMachineParentedData()
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

    function checkForObservers()
        obsBlks=Simulink.observer.internal.getObserverRefBlocksInBD(obj.modelH);
        if~isempty(obsBlks)
            msg=getString(message(...
            'Sldv:ModelSlicer:ModelSlicer:UnsupportedObserverContentSliceGeneration',...
            getfullname(obj.modelH)));
            errMex{end+1}=MException(...
            'ModelSlicer:Compatibility:UnsupportedObserverContentSliceGeneration',...
            msg);
        end
    end

    function checkForArchModel()
        if Simulink.internal.isArchitectureModel(obj.modelH)
            msg=getString(message(...
            'Sldv:ModelSlicer:ModelSlicer:UnsupportedArchModelSliceGeneration',...
            getfullname(obj.modelH)));
            errMex{end+1}=MException(...
            'ModelSlicer:Compatibility:UnsupportedArchModelSliceGeneration',...
            msg);
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
            if any(strcmpi(varargin{i+1},{'precompile','postcompile','highlight','slice','slice_post_analysis'}))
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


