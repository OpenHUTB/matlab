

function varargout=cbutils(varargin)
    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end

function MaskParamCb(paramName,blkH,cbH)%#ok<*DEFNU>

    cbVal=get_param(blkH,paramName);
    vis=get_param(blkH,'MaskVisibilities');
    ens=get_param(blkH,'MaskEnables');
    pnames=get_param(blkH,'MaskNames');

    idxMap=containers.Map;
    for ii=1:length(pnames)
        idxMap(pnames{ii})=ii;
    end

    [vis,ens]=cbH(blkH,cbVal,vis,ens,idxMap);

    set_param(blkH,...
    'MaskVisibilities',vis,...
    'MaskEnables',ens...
    );

end


function blkPath=GetBlkPath(blkH)
    blkPath=[get(blkH,'Path'),'/',strrep(get(blkH,'Name'),'/','//')];
end

function p=GetDialogParams(blkH,varargin)
...
...
...
...

    if nargin==2
        evalFunc={varargin{1}};%#ok<CCAT1>
    else
        evalFunc={'evalin','base'};
    end

    dpnames=fieldnames(get_param(blkH,'DialogParameters'));
    dpstrvalues=cellfun(@(x)(get_param(blkH,x)),dpnames,'UniformOutput',false);
    dpvalues={};
    for v=dpstrvalues'
        try
            val=feval(evalFunc{:},v{1},blkH);
        catch ME %#ok<NASGU>
            val=v{1};
        end
        dpvalues{end+1}=val;%#ok<AGROW>
    end
    p=cell2struct(dpvalues,dpnames',2);

end


function runningState=SimStatusIsRunning(blkH,sysH)

    currStatus=get_param(sysH,'SimulationStatus');
    if(strcmp(currStatus,'running')||...
        strcmp(currStatus,'terminating')||...
        strcmp(get_param(sysH,'ExtModeConnected'),'on')||...
        strcmp(get_param(bdroot(get(blkH,'Parent')),'Lock'),'on'))
        runningState=true;
    else
        runningState=false;
    end
end
function runningState=SimStatusIsStopped(~,sysH)
    currStatus=get_param(sysH,'SimulationStatus');
    runningState=strcmp(currStatus,'stopped');
end
function tf=IsLibContext(blkH)
    tf=any(strcmp(get(bdroot(blkH),'Name'),{'socmemlib','socmemlib_internal',...
    'soclib','socregisterchanneli2clib',...
    'prociolib','prociodatalib','procinterlib',...
    'proclib_internal'}));
end

function AddBadge(blkH,image,tooltip,actionHandler)
    if nargin<4
        actionHandler=[];
    end

    id=['slSoCBadge',num2str(blkH)];
    panel='BlockOutside';
    try
        badgeObj=diagram.badges.create(id,panel);
    catch ME
        if strcmp(ME.identifier,'diagram_badges:badges:DuplicateKey')
            badgeObj=diagram.badges.get(id,panel);
        else
            throw(ME);
        end
    end
    if~isempty(actionHandler)
        badgeObj.setActionHandler(actionHandler);
    end
    badgeObj.Image=image;
    badgeObj.Tooltip=tooltip;
    badgeObj.DefaultOpacity=0.7;
    badgeObj.SuppressContextMenu=true;
    badgeObj.Text='';

    diagObj=diagram.resolver.resolve(blkH);
    if~badgeObj.isVisible(diagObj)
        setVisible(badgeObj,diagObj,true);
    end
end

function Index=RegisterIndexCb(blkH,MemorySelection)
    Index='';
    if~ishandle(blkH)
        error('(internal socb) block tried to register an block index but did not specify a handle');
    end
    modelH=bdroot(blkH);
    IndexRegistry=l_IndexRegistry(modelH);
    key=blkH;
    MemId=find(strcmpi(MemorySelection,{'PS memory','PL memory'}));
    if~isempty(MemId)
        if~isKey(IndexRegistry{MemId}.Registry,key)
            IndexRegistry{MemId}.Registry(key)=IndexRegistry{MemId}.Index;
            IndexRegistry{MemId}.Index=IndexRegistry{MemId}.Index+1;
            l_IndexRegistry(modelH,IndexRegistry);
        end
        Index=IndexRegistry{MemId}.Registry(key);
    end
end

function UnregisterIndexCb(blkH,MemorySelection)
    if~ishandle(blkH)
        error('(internal socb) block tried to unregister a block index callback but did not specify a handle');
    end
    modelH=bdroot(blkH);
    IndexRegistry=l_IndexRegistry(modelH);
    key=blkH;
    MemId=find(strcmpi(MemorySelection,{'PS memory','PL memory'}));
    if~isempty(MemId)
        if IndexRegistry{MemId}.Registry.isKey(key)


            index2remove=IndexRegistry{MemId}.Registry(key);
            for keys=IndexRegistry{MemId}.Registry.keys
                if IndexRegistry{MemId}.Registry(keys{1})>index2remove
                    IndexRegistry{MemId}.Registry(keys{1})=IndexRegistry{MemId}.Registry(keys{1})-1;
                end
            end
            IndexRegistry{MemId}.Registry.remove(key);
            IndexRegistry{MemId}.Index=IndexRegistry{MemId}.Index-1;
            l_IndexRegistry(modelH,IndexRegistry);
        end
    end
end

function val=l_IndexRegistry(modelH,varargin)
    persistent IndexRegistry;
    if isempty(IndexRegistry)
        IndexRegistry=containers.Map('KeyType','double','ValueType','any');
    end
    if~isKey(IndexRegistry,modelH)
        IndexRegistry(modelH)={struct('Registry',containers.Map('KeyType','double','ValueType','any'),'Index',1);
        struct('Registry',containers.Map('KeyType','double','ValueType','any'),'Index',1)};
    end
    if nargin>1
        IndexRegistry(modelH)=varargin{1};
    end
    val=IndexRegistry(modelH);
end


function RegisterSetupViewerCb(blkH,blkKind)
    if~ishandle(blkH)
        error('(internal socb) block tried to register a setup viewer callback but did not specify a handle');
    end
    mws=get_param(bdroot(blkH),'ModelWorkspace');
    if~isempty(mws)
        key=blkH;
        val=@(storedDL,currDL)(setupViewer(blkH,blkKind,storedDL,currDL));
        if mws.hasVariable('socvcb')
            socvcb=mws.getVariable('socvcb');
        else
            socvcb=containers.Map('KeyType','double','ValueType','any');
        end
        socvcb(key)=val;
        mws.assignin('socvcb',socvcb);
    end
end
function UnregisterSetupViewerCb(blkH)
    if~ishandle(blkH)
        error('(internal socb) block tried to unregister a setup viewer callback but did not specify a handle');
    end
    mws=get_param(bdroot(blkH),'ModelWorkspace');
    if~isempty(mws)
        key=blkH;
        if mws.hasVariable('socvcb')
            socvcb=mws.getVariable('socvcb');
            if socvcb.isKey(key)
                socvcb.remove(key);
                mws.assignin('socvcb',socvcb);
            end
        end
    end
end
function CallAllRegisteredSetupViewerCbs(sysH,storedDL,currDL)
    mws=get_param(sysH,'ModelWorkspace');
    if~isempty(mws)
        if mws.hasVariable('socvcb')
            socvcb=mws.getVariable('socvcb');
            for k=keys(socvcb)
                if isnumeric(k{1})&&ishandle(k{1})
                    if strcmp(get(k{1},'type'),'block')
                        if any(strcmp(get_param(k{1},'ReferenceBlock'),{'socmemlib/Memory Channel',...
                            'socmemlib/Memory Controller',...
                            'socmemlib/Memory Traffic Generator',...
                            'socmemlib/AXI4-Stream to Software',...
                            'socmemlib/Software to AXI4-Stream',...
                            'socmemlib/AXI4 Random Access Memory',...
                            'socmemlib/AXI4 Video Frame Buffer',...
                            'socmemlib_internal/Memory Controller'}))
                            cb=socvcb(k{1});
                            cb(storedDL,currDL);
                            continue;
                        end
                    end
                end
                socvcb.remove(k{1});
            end
            mws.assignin('socvcb',socvcb);
        end
    end
end
function setupViewer(blkH,blkKind,arg1,arg2)
    switch blkKind
    case 'memctrlNumMastersCb'
        numMasters=arg1;
        storedDL=arg2;
        currDL=arg2;
        blkKind='memctrl';
    case 'memctrl'
        storedDL=arg1;
        currDL=arg2;
        blkP=hsb.blkcb2.cbutils('GetDialogParams',blkH);
        numMasters=blkP.NumMasters;
    case{'memch','memctrl_single','stream2sw','sw2stream',...
        'randomAccessMem','videoFrameBuffer','memTrafficGen'}
        storedDL=arg1;
        currDL=arg2;
    otherwise
        error('(socb internal) illegal blkKind');
    end

    blkPath=getfullname(blkH);

    switch blkKind
    case 'memch'
        memchBusBlks=strcat([blkPath,'/'],...
        {
'log/Writer/Bus Selector'
'log/Reader/Bus Selector'
        });
        dlOff={memchBusBlks};
        dlOffFilter={-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memchBusBlks};
            dlOnFilter={[(4:7),9,10,15,16]};
        end

    case 'memctrl'

        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'log/Master01/Bus Selector'
'log/Master02/Bus Selector'
'log/Master03/Bus Selector'
'log/Master04/Bus Selector'
'log/Master05/Bus Selector'
'log/Master06/Bus Selector'
'log/Master07/Bus Selector'
'log/Master08/Bus Selector'
'log/Master09/Bus Selector'
'log/Master10/Bus Selector'
'log/Master11/Bus Selector'
'log/Master12/Bus Selector'
        });

        dlOff={memctrlBusBlks};
        dlOffFilter={-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag=['.',num2str(numMasters)];
            dlOn={memctrlBusBlks(1:numMasters)};
            dlOnFilter={[1,3,6,7]};
        end

    case 'memctrl_single'

        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'log/Master/Bus Selector'
        });

        dlOff={memctrlBusBlks};
        dlOffFilter={-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memctrlBusBlks};
            dlOnFilter={[1,2,3,6,7]};
        end
    case 'stream2sw'
        memchBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Channel/log/Writer/Bus Selector'
'SimVariant/Accurate/Memory Channel/log/Reader/Bus Selector'
        });
        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Controller/log/Master/Bus Selector'
        });
        dlOff={memchBusBlks;memctrlBusBlks};
        dlOffFilter={-1;-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memchBusBlks;memctrlBusBlks};
            dlOnFilter={[(4:7),9,10,15,16];...
            [1,2,3,6,7]};
        end
    case 'sw2stream'
        memchBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Channel/log/Writer/Bus Selector'
'SimVariant/Accurate/Memory Channel/log/Reader/Bus Selector'
        });
        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Controller/log/Master/Bus Selector'
        });
        dlOff={memchBusBlks;memctrlBusBlks};
        dlOffFilter={-1;-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memchBusBlks;memctrlBusBlks};
            dlOnFilter={[(4:7),9,10,15,16];...
            [1,2,3,6,7]};
        end
    case{'randomAccessMem','videoFrameBuffer'}
        memchBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Channel/log/Writer/Bus Selector'
'SimVariant/Accurate/Memory Channel/log/Reader/Bus Selector'
        });
        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'SimVariant/Accurate/Memory Controller Wr/log/Master/Bus Selector'
'SimVariant/Accurate/Memory Controller Rd/log/Master/Bus Selector'
        });
        dlOff={memchBusBlks;memctrlBusBlks};
        dlOffFilter={-1;-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memchBusBlks;memctrlBusBlks};
            dlOnFilter={[(4:7),9,10,15,16];...
            [1,2,3,6,7]};
        end
    case 'memTrafficGen'
        memctrlBusBlks=strcat([blkPath,'/'],...
        {
'MemCtrlGate/local/Memory Controller/log/Master/Bus Selector'
        });
        dlOff={memctrlBusBlks};
        dlOffFilter={-1};
        switch currDL
        case 'No debug'
            currDLTag='';
            dlOn={};
        otherwise
            currDLTag='';
            dlOn={memctrlBusBlks};
            dlOnFilter={[1,2,3,6,7]};
        end
    otherwise
        error('(internal) illegal blkKind');
    end

    if~isempty(dlOff)
        for i=1:numel(dlOff)
            ddvOff=soc.internal.DDLoggerViewer(blkH,dlOff{i},dlOffFilter{i});
            ddvOff.turnOffLogging();
        end
    end

    if~isempty(dlOn)
        for i=1:numel(dlOn)
            ddvOn=soc.internal.DDLoggerViewer(blkH,dlOn{i},dlOnFilter{i});
            ddvOn.turnOnLogging();
        end
    end


    sw=warning('off','Simulink:Commands:SetParamLinkChangeWarn');
    tmp=onCleanup(@()warning(sw));

    set_param(blkH,'DiagnosticLevel',[currDL,currDLTag]);
end

function logVar=GetSignalLoggingVariable(blkH)
    slen=get_param(bdroot(blkH),'SignalLogging');
    slna=get_param(bdroot(blkH),'SignalLoggingName');
    rwen=get_param(bdroot(blkH),'ReturnWorkspaceOutputs');

    if strcmp(slen,'off')
        error(message('soc:msgs:ModelLoggingDisabled'));
    else
        try
            if strcmp(rwen,'off')
                logVarName=slna;
            else
                rwna=get_param(bdroot(blkH),'ReturnWorkspaceOutputsName');
                logVarName=[rwna,'.',slna];
            end
            logVar=evalin('base',logVarName);
            assert(isa(logVar,'Simulink.SimulationData.Dataset'),'Log variable is not a Simulink.SimulationData.Dataset object.');
        catch ME
            error(message('soc:msgs:NoSignalLogging',logVarName,ME.message));
        end
    end
end

function CreateBusInBase(name,description,sigs)

    bus=Simulink.Bus;
    bus.Description=description;

    for ii=1:4:numel(sigs)-1
        be=Simulink.BusElement;
        be.Name=sigs{ii};
        be.DataType=sigs{ii+1};
        be.Dimensions=sigs{ii+2};
        be.Description=sigs{ii+3};
        bus.Elements(end+1)=be;
    end

    assignin('base',name,bus);

end



