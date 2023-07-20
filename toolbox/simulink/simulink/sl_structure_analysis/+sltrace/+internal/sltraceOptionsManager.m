classdef sltraceOptionsManager<handle














































    properties(SetAccess=private)
TraceDirection
TraceModel

OriginBlock
OriginBlockPath
OriginBlockHandle
OriginBlockPorts
OriginPortHandle

PortIndex
IsPortIndexFromUser
IsTracingFromPort

TraceSegmentHandle

InterceptorHandle

LastActiveEditor

EnableTraceToAll
EnableBlockPath

BusElement
BusPath
SelectedBusLabel
ValidBusElementPortIndex
    end

    properties(Access=private)











        ReverseTraceBlockList;

        ConnectionlessBlockList;












ValidPortList
    end

    methods


        function obj=sltraceOptionsManager(varargin)
            import sltrace.utils.*

            oldState=warning('off','backtrace');
            x=onCleanup(@()warning(oldState.state,'backtrace'));

            obj.TraceSegmentHandle=0;
            obj.PortIndex=0;
            obj.IsPortIndexFromUser=0;
            obj.OriginBlockPorts=0;
            obj.OriginBlockHandle=0;
            obj.OriginPortHandle=0;
            obj.InterceptorHandle=0;
            obj.BusElement="";
            obj.BusPath="";
            obj.SelectedBusLabel="";
            obj.ValidBusElementPortIndex=0;
            obj.TraceDirection='source';
            obj.IsTracingFromPort=0;


            obj.EnableTraceToAll='off';
            obj.EnableBlockPath='off';

            obj.ReverseTraceBlockList={'From','Goto',...
            'EntityMulticast','Queue'};
            obj.ConnectionlessBlockList={'SubSystem'};

            obj.ValidPortList={'inport','outport','enable',...
            'trigger','state','ifaction',...
            'reset','event'};
            traceType=varargin{1};
            switch traceType
            case 'block'
                obj.OriginBlock=varargin{2};
                obj.OriginBlockPath=getBlockPathFromBlock(obj.OriginBlock);
                option=lower(convertStringsToChars(varargin{3}));
                if isempty(option)
                    ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidTraceDirection',option);
                    throw(ME);
                end
                switch option
                case 'src'
                    direction='source';
                case 'dst'
                    direction='destination';
                otherwise
                    direction=option;
                end
                obj.TraceDirection=direction;
                obj.TraceModel=getBaseGraph(obj.OriginBlock);
                obj.OriginBlockPorts=get_param(obj.OriginBlock,'Ports');
                obj.OriginBlockHandle=getBlockHandle(obj.OriginBlock);

                obj.verifyParameters(varargin{4:end});
            case 'Simulink.BlockPath'
                blockPath=varargin{2};
                obj.OriginBlockPath=blockPath;
                obj.OriginBlock=blockPath.getBlock(blockPath.getLength);
                option=lower(convertStringsToChars(varargin{3}));
                if isempty(option)
                    ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidTraceDirection',option);
                    throw(ME);
                end
                switch option
                case 'src'
                    direction='source';
                case 'dst'
                    direction='destination';
                otherwise
                    direction=option;
                end
                obj.TraceDirection=direction;
                obj.TraceModel=getBaseGraph(obj.OriginBlock);
                obj.OriginBlockPorts=get_param(obj.OriginBlock,'Ports');
                obj.OriginBlockHandle=getBlockHandle(obj.OriginBlock);

                obj.verifyParameters(varargin{4:end});
            case 'port'
                obj.OriginPortHandle=varargin{2};
                obj.OriginBlock=get_param(obj.OriginPortHandle,'Parent');
                obj.OriginBlockPath=Simulink.BlockPath(obj.OriginBlock);
                options=varargin(3:end);

                if~isempty(options)
                    option=lower(convertStringsToChars(varargin{3}));
                    if ismember(option,{'source','src','destination','dst'})
                        ME=createMException('Simulink:HiliteTool:IgnoreDirection',option);
                        warning(ME.message);
                        options=varargin(4:end);
                    end
                end

                portType=lower(get_param(obj.OriginPortHandle,'PortType'));
                if~obj.isPortValid(portType)


                    if strcmp(portType,'connection')
                        ME=createMException('Simulink:HiliteTool:NotSupportSimscape');
                        throw(ME);
                    end


                    ME=createMException('Simulink:HiliteTool:UnsupportedTracePort',portType);
                    throw(ME);
                end

                if ismember(portType,{'outport','state'})
                    obj.TraceDirection='destination';
                end

                obj.OriginBlockPath=getBlockPathFromBlock(obj.OriginBlock);
                obj.TraceSegmentHandle=get_param(obj.OriginPortHandle,'line');
                obj.TraceModel=getBaseGraph(obj.OriginBlock);
                obj.OriginBlockPorts=get_param(obj.OriginBlock,'Ports');
                obj.OriginBlockHandle=getBlockHandle(obj.OriginBlock);
                obj.IsTracingFromPort=1;
                obj.verifyParameters(options{:});
            otherwise
                ME=createMException('Simulink:HiliteTool:TraceTypeNotSupport',traceType);
                throw(ME);
            end

            obj.verifyActiveEditor();
        end



        function delete(~)

        end
    end


    methods(Access=private,Hidden=true)


        function verifyParameters(obj,varargin)



            switch obj.TraceDirection
            case 'source'
                obj.verifyTraceToSourceParams(varargin{:});
            case 'destination'
                obj.verifyTraceToDestinationParams(varargin{:});
            otherwise
                ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidTraceDirection',obj.TraceDirection);
                throw(ME);
            end
        end



        function verifyTraceToSourceParams(obj,varargin)
            import sltrace.utils.*

            oldState=warning('off','backtrace');
            x=onCleanup(@()warning(oldState.state,'backtrace'));

            blockType=get_param(obj.OriginBlock,'BlockType');
            if strcmp(blockType,'SimscapeBlock')
                ME=createMException('Simulink:HiliteTool:NotSupportSimscape');
                throw(ME);
            end






            if obj.TraceSegmentHandle==0

                obj.TraceSegmentHandle=getInputSegmentHandle(obj.OriginBlock);
            end




            if isempty(obj.TraceSegmentHandle)
                if ismember(blockType,obj.ReverseTraceBlockList)
                    obj.TraceSegmentHandle=getOutputSegmentHandle(obj.OriginBlock);
                end
                if isempty(obj.TraceSegmentHandle)
                    ME=createMException('Simulink:HiliteTool:InvalidTracePort','source','input port',obj.OriginBlock);
                    throw(ME);
                end
            end


            if~isempty(varargin)
                options=cellfun(@convertStringsToChars,varargin,'UniformOutput',false);
                options=obj.lowerOptions(options);
                for i=1:2:length(options)
                    obj.validateNameValueOptions(options,i);
                    switch options{i}
                    case 'traceall'
                        obj.EnableTraceToAll=options{i+1};

                        if~obj.isOnOff(obj.EnableTraceToAll)
                            ME=createMException('Simulink:HiliteTool:OptionCanOnlyBeOnOff',obj.EnableTraceToAll);
                            throw(ME);
                        end






                        if~ismember(obj.TraceDirection,{'source interceptor',...
                            'source element'})...
                            &&strcmp(obj.EnableTraceToAll,'on')
                            obj.TraceDirection='all source';
                        end

                    case{'blockpath','bp'}
                        obj.EnableBlockPath=options{i+1};

                        if~obj.isOnOff(obj.EnableBlockPath)
                            ME=createMException('Simulink:HiliteTool:OptionCanOnlyBeOnOff',obj.EnableBlockPath);
                            throw(ME);
                        end

                    case 'port'
                        if obj.IsTracingFromPort
                            ME=createMException('Simulink:HiliteTool:IgnorePortIndex',options{i+1});
                            warning(ME.message);
                            continue;
                        end

                        obj.PortIndex=options{i+1};

                        if ischar(obj.PortIndex)
                            obj.PortIndex=str2double(obj.PortIndex);
                        end




                        numInports=length(getAllInportHandles(get_param(obj.OriginBlock,'PortHandles')));



                        if obj.PortIndex<0||obj.PortIndex>numInports||isnan(obj.PortIndex)
                            ME=createMException('Simulink:HiliteTool:InvalidInportIndex',...
                            options{i+1},obj.OriginBlock);
                            throw(ME);
                        end
                        obj.IsPortIndexFromUser=1;
                    case 'element'
                        obj.BusElement=varargin{i+1};


                        if obj.IsTracingFromPort
                            ports=obj.OriginPortHandle;
                        else
                            blkPortHandle=get_param(obj.OriginBlock,'PortHandles');
                            ports=blkPortHandle.Inport;
                        end
                        numPorts=length(ports);
                        validPorts=zeros(1,numPorts);
                        for j=1:numPorts
                            port=ports(j);
                            busSignal=get_param(port,'SignalHierarchy');
                            obj.SelectedBusLabel=busSignal.SignalName;
                            [isValidBusElement,busPath]=obj.validateBusElement(busSignal,obj.BusElement);
                            if(isValidBusElement)
                                validPorts(j)=1;
                                obj.BusPath=busPath;
                            end
                        end
                        if~any(validPorts)
                            ME=createMException('Simulink:HiliteTool:InvalidBusElement',obj.BusElement);
                            throw(ME);
                        end
                        obj.ValidBusElementPortIndex=find(validPorts==1);
                        obj.TraceDirection='source element';
                    case{'interrupter','stop'}


                        interceptor=varargin{i+1};

                        obj.InterceptorHandle=getBlockHandle(interceptor);


                        if length(get_param(obj.InterceptorHandle,'PortHandles').Outport)<1
                            ME=createMException('Simulink:HiliteTool:InvalidInterceptorToSrc');
                            throw(ME);
                        end

                        obj.TraceDirection='source interceptor';

                    otherwise
                        ME=createMException('Simulink:HiliteTool:NotAnOption',option);
                        throw(ME);
                    end
                end
            end

            obj.PortIndex=obj.PortIndex;

            obj.verifyCommonParams();
        end



        function verifyTraceToDestinationParams(obj,varargin)
            import sltrace.utils.*

            oldState=warning('off','backtrace');
            x=onCleanup(@()warning(oldState.state,'backtrace'));

            blockType=get_param(obj.OriginBlock,'BlockType');
            if strcmp(blockType,'SimscapeBlock')
                ME=createMException('Simulink:HiliteTool:NotSupportSimscape');
                throw(ME);
            end

            if obj.TraceSegmentHandle==0
                obj.TraceSegmentHandle=getOutputSegmentHandle(obj.OriginBlock);
            end


            if isempty(obj.TraceSegmentHandle)
                if ismember(blockType,obj.ReverseTraceBlockList)
                    obj.TraceSegmentHandle=getInputSegmentHandle(obj.OriginBlock);
                end

                if isempty(obj.TraceSegmentHandle)
                    ME=createMException('Simulink:HiliteTool:InvalidTracePort','destination','output port',obj.OriginBlock);
                    throw(ME);
                end
            end


            if~isempty(varargin)
                options=cellfun(@convertStringsToChars,varargin,'UniformOutput',false);
                options=obj.lowerOptions(options);
                for i=1:2:length(options)
                    obj.validateNameValueOptions(options,i);
                    switch options{i}
                    case 'traceall'
                        obj.EnableTraceToAll=options{i+1};

                        if~obj.isOnOff(obj.EnableTraceToAll)
                            ME=createMException('Simulink:HiliteTool:OptionCanOnlyBeOnOff',obj.EnableTraceToAll);
                            throw(ME);
                        end





                        if~ismember(obj.TraceDirection,{'destination interceptor','destination element'})...
                            &&strcmp(obj.EnableTraceToAll,'on')
                            obj.TraceDirection='all destination';
                        end

                    case{'blockpath','bp'}
                        obj.EnableBlockPath=options{i+1};

                        if~obj.isOnOff(obj.EnableBlockPath)
                            ME=createMException('Simulink:HiliteTool:OptionCanOnlyBeOnOff',obj.EnableBlockPath);
                            throw(ME);
                        end

                    case 'port'
                        if obj.IsTracingFromPort
                            ME=createMException('Simulink:HiliteTool:IgnorePortIndex',options{i+1});
                            warning(ME.message);
                            continue;
                        end

                        obj.PortIndex=options{i+1};

                        if ischar(obj.PortIndex)
                            obj.PortIndex=str2double(obj.PortIndex);
                        end
                        numOutports=obj.OriginBlockPorts(2);

                        if obj.PortIndex<0||obj.PortIndex>numOutports||isnan(obj.PortIndex)
                            ME=createMException('Simulink:HiliteTool:InvalidOutportIndex',...
                            obj.PortIndex,obj.OriginBlock);
                            throw(ME);
                        end
                        obj.IsPortIndexFromUser=1;

                    case 'element'
                        obj.BusElement=varargin{i+1};


                        if obj.IsTracingFromPort
                            ports=obj.OriginPortHandle;
                        else
                            blkPortHandle=get_param(obj.OriginBlock,'PortHandles');
                            ports=blkPortHandle.Outport;
                        end
                        numPorts=length(ports);
                        validPorts=zeros(1,numPorts);
                        for j=1:numPorts
                            port=ports(j);
                            busSignal=get_param(port,'SignalHierarchy');
                            obj.SelectedBusLabel=busSignal.SignalName;
                            [isValidBusElement,busPath]=obj.validateBusElement(busSignal,obj.BusElement);
                            if(isValidBusElement)
                                validPorts(j)=1;
                                obj.BusPath=busPath;
                            end
                        end
                        if~any(validPorts)
                            ME=createMException('Simulink:HiliteTool:InvalidBusElement',obj.BusElement);
                            throw(ME);
                        end
                        obj.ValidBusElementPortIndex=find(validPorts==1);
                        obj.TraceDirection='destination element';
                    case{'interrupter','stop'}


                        interceptor=varargin{i+1};

                        obj.InterceptorHandle=getBlockHandle(interceptor);


                        if length(get_param(obj.InterceptorHandle,'PortHandles').Inport)<1
                            ME=createMException('Simulink:HiliteTool:InvalidInterceptorToDst');
                            throw(ME);
                        end

                        obj.TraceDirection='destination interceptor';

                    otherwise
                        ME=createMException('Simulink:HiliteTool:NotAnOption',option);
                        throw(ME);
                    end
                end
            end

            obj.PortIndex=obj.PortIndex;

            obj.verifyCommonParams();
        end



        function verifyCommonParams(obj)
            import sltrace.utils.*






            if obj.ValidBusElementPortIndex~=0

                if obj.IsPortIndexFromUser


                    if~ismember(obj.PortIndex,obj.ValidBusElementPortIndex)
                        ME=createMException('Simulink:HiliteTool:InvalidBusElementWithPortIndex',obj.BusElement,obj.PortIndex);
                        throw(ME);
                    end
                    obj.TraceSegmentHandle=obj.TraceSegmentHandle(obj.PortIndex);
                else


                    obj.TraceSegmentHandle=obj.TraceSegmentHandle(obj.ValidBusElementPortIndex);
                end
            else
                if obj.IsPortIndexFromUser
                    obj.TraceSegmentHandle=obj.TraceSegmentHandle(obj.PortIndex);
                end
            end


            if any(obj.TraceSegmentHandle<0)
                if ismember(get_param(obj.OriginBlock,'BlockType'),obj.ConnectionlessBlockList)
                    assert(unique(obj.TraceSegmentHandle)==-1);
                    obj.TraceSegmentHandle=obj.traceUnconnectedBlock();
                else
                    ME=createMException('Simulink:HiliteTool:UnconnectedTracingPort',obj.TraceDirection,obj.PortIndex,obj.OriginBlock);
                    throw(ME);
                end
            end


            if obj.InterceptorHandle~=0
                assert(obj.InterceptorHandle~=obj.OriginBlockHandle,...
                message('Simulink:HiliteTool:InvalidInterceptorToOriginBlock',...
                getfullname(obj.InterceptorHandle),getfullname(obj.OriginBlockHandle')));
            end
        end
    end


    methods(Access=private,Hidden=true)


        function segmentHandle=traceUnconnectedBlock(obj)
            switch obj.TraceDirection
            case{'source','all source','source interceptor','source element'}
                blockCell=find_system(obj.OriginBlock,'SearchDepth',1,'BlockType','Inport');
                segmentHandle=zeros(1,length(blockCell));
                for i=1:length(blockCell)
                    if obj.PortIndex>0
                        if get_param(blockCell{i},'Port')==num2str(obj.PortIndex)
                            segmentHandle=sltrace.utils.getOutputSegmentHandle(blockCell{i});
                            break;
                        end
                    else
                        segmentHandle(i)=sltrace.utils.getOutputSegmentHandle(blockCell{i});
                    end
                end
            case{'destination','all destination','destination interceptor','destination element'}
                blockCell=find_system(obj.OriginBlock,'SearchDepth',1,'BlockType','Outport');
                segmentHandle=zeros(1,length(blockCell));
                for i=1:length(blockCell)
                    if obj.PortIndex>0
                        if get_param(blockCell{i},'Port')==num2str(obj.PortIndex)
                            segmentHandle=sltrace.utils.getInputSegmentHandle(blockCell{i});
                            break;
                        end
                    else
                        segmentHandle(i)=sltrace.utils.getInputSegmentHandle(blockCell{i});
                    end
                end
            otherwise
                ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidTraceDirection',direction);
                throw(ME);
            end
            obj.openShadeSubsystem(blockCell{i});
            segmentHandle=segmentHandle(segmentHandle~=0);
        end


        function verifyActiveEditor(obj)
            blockPath=obj.OriginBlockPath(1);
            bdParent=blockPath.getParent();

            if ischar(bdParent)
                open_system(bdParent,'force','tab');
                startBDHandle=get_param(bdParent,'Handle');
                editor=SLM3I.SLDomain.getLastActiveEditorFor(startBDHandle);
            else
                bdParent.open('opentype','NEW_TAB','force','on');
                startBDHandle=get_param(get_param(obj.OriginBlock,'Parent'),'handle');
                editor=SLM3I.SLDomain.getLastActiveEditorFor(startBDHandle);
            end
            obj.LastActiveEditor=editor;
        end






        function[isValidBusElement,busPath]=validateBusElement(obj,busSignal,busElement)
            isValidBusElement=false;
            busPath="";

            if strcmp(busSignal.SignalName,busElement)
                isValidBusElement=true;
                busPath=busSignal.SignalName;
                return;
            end

            if~isempty(busSignal.Children)

                for i=1:length(busSignal.Children)
                    [isValidBusElement,busPath]=obj.validateBusElement(busSignal.Children(i),busElement);
                    if isValidBusElement
                        if~strcmp(busSignal.SignalName,obj.SelectedBusLabel)
                            busPath=append(busSignal.SignalName,'/',busPath);
                        end
                        return;
                    end
                end
            end
        end




        function openShadeSubsystem(obj,block)
            blockParent=get_param(block,'Parent');
            bpHandle=get_param(blockParent,'Handle');
            if bpHandle~=get_param(obj.TraceModel,'Handle')
                open_system(blockParent,'force','tab');
            end
        end










        function options=lowerOptions(~,options)
            specialOptions={'port','interrupter','stop'};
            for i=1:length(options)
                try
                    options{i}=lower(options{i});
                catch
                    if ismember(options{i-1},specialOptions)
                        continue;
                    end
                end
            end
        end

        function flag=isOnOff(~,str)
            if strcmpi(str,'on')||strcmpi(str,'off')
                flag=true;
            else
                flag=false;
            end
        end


        function valid=isPortValid(obj,portType)
            valid=ismember(portType,obj.ValidPortList);
        end


        function validateNameValueOptions(~,options,index)
            try
                paramName=options{index};
                paramValue=options{index+1};
            catch
                ME=sltrace.utils.createMException(...
                'Simulink:HiliteTool:InvalidParaValPair');
                throw(ME);
            end

            if isempty(paramName)
                ME=sltrace.utils.createMException(...
                'Simulink:HiliteTool:NotAnOption',paramName);
                throw(ME);
            elseif isempty(paramValue)
                ME=sltrace.utils.createMException(...
                'Simulink:HiliteTool:NotAnOption',paramValue);
                throw(ME);
            end
        end
    end

end

