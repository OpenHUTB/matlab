classdef FPGADesign<handle



    methods
        function obj=FPGADesign(name,simTgt,esbCompatible,tool,toolVer)
            obj.BoardName=name;
            obj.SupportedTool=tool;
            obj.SupportedToolVersion=toolVer;
            obj.SupportsOnlySimulation=simTgt;
            obj.HasProcessor=bitand(esbCompatible,1)==1;
            obj.HasFPGA=bitand(esbCompatible,2)==2;













            wpm=obj.makeWidgetPropMap();


            dl_none=DAStudio.message('codertarget:ui:FPGADesignMemChDiagLevelNone');
            dl_basic=DAStudio.message('codertarget:ui:FPGADesignMemChDiagLevelBasic');
            MemChDiagValues={dl_none,dl_basic};







            inclPS=obj.HasProcessor;


            obj.DesignParamsPL=[...
            soc.customboard.internal.DesignParameter(...
            'AXIMemorySubsystemClockPL','MemControllersPL',...
            100,1,1e9,'MHz',{},...
            'edit',wpm('AXIMemorySubsystemClockPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'AXIMemorySubsystemDataWidthPL','MemControllersPL',...
            '64',0,0,'bits',{'8','16','32','64','128','256','512','1024'},...
            'combobox',wpm('AXIMemorySubsystemDataWidthPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'RefreshOverheadPL','MemControllersPL',...
            2.3,0,100,'clocks',{},...
            'edit',wpm('RefreshOverheadPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'WriteFirstTransferLatencyPL','MemControllersPL',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('WriteFirstTransferLatencyPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'WriteLastTransferLatencyPL','MemControllersPL',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('WriteLastTransferLatencyPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'ReadFirstTransferLatencyPL','MemControllersPL',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('ReadFirstTransferLatencyPL'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'ReadLastTransferLatencyPL','MemControllersPL',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('ReadLastTransferLatencyPL'),'default','')
            ];

            obj.DesignParamsPS=[...
            soc.customboard.internal.DesignParameter(...
            'AXIMemorySubsystemClockPS','MemControllersPS',...
            100,1,1e9,'MHz',{},...
            'edit',wpm('AXIMemorySubsystemClockPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'AXIMemorySubsystemDataWidthPS','MemControllersPS',...
            '64',0,0,'bits',{'8','16','32','64','128','256','512','1024'},...
            'combobox',wpm('AXIMemorySubsystemDataWidthPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'RefreshOverheadPS','MemControllersPS',...
            2.3,0,100,'clocks',{},...
            'edit',wpm('RefreshOverheadPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'WriteFirstTransferLatencyPS','MemControllersPS',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('WriteFirstTransferLatencyPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'WriteLastTransferLatencyPS','MemControllersPS',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('WriteLastTransferLatencyPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'ReadFirstTransferLatencyPS','MemControllersPS',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('ReadFirstTransferLatencyPS'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'ReadLastTransferLatencyPS','MemControllersPS',...
            5,0,1e3,'clocks',{},...
            'edit',wpm('ReadLastTransferLatencyPS'),'default','')
            ];

            obj.DesignParams=[...




            soc.customboard.internal.DesignParameter(...
            'MemMapButton','TopLevel',...
            '',false,true,'',{},...
            'pushbutton',wpm('MemMapButton'),...
            'soc.memmap.csButtonCallback',''),...
            soc.customboard.internal.DesignParameter(...
            'IncludeJTAGMaster','TopLevel',...
            true,false,true,'',{},...
            'checkbox',wpm('IncludeJTAGMaster'),'',''),...
            soc.customboard.internal.DesignParameter(...
            'IncludeProcessingSystem','TopLevel',...
            inclPS,false,true,'',{},...
            'checkbox',wpm('IncludeProcessingSystem'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'HasPSMemory','TopLevel',...
            false,false,true,'',{},...
            'checkbox',wpm('HasPSMemory'),'',''),...
            soc.customboard.internal.DesignParameter(...
            'HasPLMemory','TopLevel',...
            false,false,true,'',{},...
            'checkbox',wpm('HasPLMemory'),'',''),...
            soc.customboard.internal.DesignParameter(...
            'InterruptLatency','TopLevel',...
            0,0,0,'s',{},...
            'edit',wpm('InterruptLatency'),'default',''),...
            soc.customboard.internal.DesignParameter(...
            'AXILiteClock','TopLevel',...
            50,50,50,'MHz',{},...
            'edit',wpm('AXILiteClock'),'',''),...
            soc.customboard.internal.DesignParameter(...
            'AXIHDLUserLogicClock','TopLevel',...
            100,5,500,'MHz',{},...
            'edit',wpm('AXIHDLUserLogicClock'),'default',''),...
...
            soc.customboard.internal.DesignParameter(...
            'MemChDiagLevel','Debug',...
            dl_none,0,0,'',MemChDiagValues,...
            'combobox',wpm('MemChDiagLevel'),'default','default'),...
            soc.customboard.internal.DesignParameter(...
            'IncludeAXIInterconnectMonitor','Debug',...
            false,false,true,'',{},...
            'checkbox',wpm('IncludeAXIInterconnectMonitor'),'',''),...
            soc.customboard.internal.DesignParameter(...
            'NumberOfTraceEvents','Debug',...
            1024,512,8196,'bursts',{},...
            'edit',{true,'codertarget.fpgadesign.internal.showAPMModeWidget(hObj)'},'default',''),...
            ];
        end

        function defineDesignConstraintsForValConstrainableParams(obj,paramName,paramType,varargin)
            if ismember(paramType,{'PS','PL'})
                dp=obj.findParamsBy('Name',paramName,paramType);
            else
                dp=obj.findParamsBy('Name',paramName);
            end
            for idx=1:2:length(varargin)
                dp.(varargin{idx})=varargin{idx+1};
            end

            switch paramName
            case 'AXIMemorySubsystemClock'
                depDP=obj.findParamsBy('Name','AXIMemoryInterconnectInputClock');
                if~obj.SupportsOnlySimulation
                    depDP.DefaultValue=dp.DefaultValue;
                end
            end
        end

        function defineCommonDesignConstraints(obj,paramName,type,varargin)
            obj.defineDesignConstraintsForValConstrainableParams(...
            paramName,type,varargin{:});
        end



        function defineDesignConstraint(obj,paramName,varargin)












            if obj.isParameterValueConstrainable(paramName)
                obj.defineDesignConstraintsForValConstrainableParams(...
                paramName,'',varargin{:});
            else
                cList=obj.getConstrainableParameterList();
                cListStr=sprintf('\t%s\n',cList{:});
                error('Cannot change constraints for parameter %s.\nConstrainable parameters include:\n%s',...
                paramName,cListStr);
            end
        end

        function attachCustomDesignTclHook(obj,kind,val)

            obj.CustomDesignTclHooks.(kind)=val;
        end

        function attachOSCustomizationCacheFile(obj,val)

            obj.OSCustomizationCacheFile=val;
        end

        function validate(obj)
        end


        function cObj=getValueConstraints(obj,paramName,varargin)
            if nargin==3
                dp=obj.findParamsBy('Name',paramName,varargin{1});
            else
                dp=obj.findParamsBy('Name',paramName);
            end
            if isempty(dp)
                error(['could not find param ',paramName]);
            end
            cObj=dp.getValueConstraints();
        end

        function paramsToReturn=getMemControllerParamType(obj)
            if obj.HasProcessor
                paramsToReturn='PS';
            else
                paramsToReturn='PL';
            end
        end

        function params=findParamsBy(obj,prop,val,varargin)

            if isequal(prop,'Name')&&~ismember(val,obj.MemoryCtrlPLParams)&&~ismember(val,obj.MemoryCtrlPSParams)||...
                isequal(prop,'GroupName')&&~isequal(val,'MemControllersPL')&&~isequal(val,'MemControllersPS')
                params=findobj(obj.DesignParams,prop,val);
                return;
            end

            if nargin==3
                switch val
                case 'MemControllersPS'
                    params=findobj(obj.DesignParamsPS,prop,val);
                case 'MemControllersPL'
                    params=findobj(obj.DesignParamsPL,prop,val);
                end
            else
                switch varargin{1}
                case 'PS'
                    params=findobj(obj.DesignParamsPS,prop,val);
                case 'PL'
                    params=findobj(obj.DesignParamsPL,prop,val);
                end
            end
        end

    end
    methods(Access=private)
        function wpm=makeWidgetPropMap(obj)
            wpm=containers.Map();
            for p=obj.AllParamList'
                en=obj.isParamEnabledByDefault(p{1});
                vis=obj.isParamVisibleByDefault(p{1});
                wpm(p{1})={en,vis};
            end
        end
        function tf=isParamEnabledByDefault(obj,p)


            switch(p)
            case{'HasPSMemory','HasPLMemory'}
                tf=false;
            otherwise
                tf=~(any(strcmp(p,obj.ParamHasFixedValForGenList))&&~obj.SupportsOnlySimulation);
            end
        end
        function tf=isParamVisibleByDefault(obj,p)
            switch p
            case{'InterruptLatency','HasPSMemory','HasPLMemory'}
                tf=false;

            case obj.MemoryCtrlPLParams
                tf='codertarget.fpgadesign.internal.showMemControllersPLWidget(hObj)';
            case obj.MemoryCtrlPSParams
                tf='codertarget.fpgadesign.internal.showMemControllersPSWidget(hObj)';
            otherwise


                tf=~(any(strcmp(p,obj.ParamHasNoEffectForSimList))&&obj.SupportsOnlySimulation);
            end
        end
        function tf=isParameterValueConstrainable(obj,p)
            switch p
            case{'MemMapButton','MemChDiagLevel','InterruptLatency'}
                tf=false;
            otherwise
                isVisible=obj.isParamVisibleByDefault(p);
                isChangeable=obj.isParamEnabledByDefault(p);
                hasFixedGenConstraints=(any(strcmp(p,obj.ParamHasFixedValConstraintsForGenList))&&~obj.SupportsOnlySimulation);
                hasFixedSimConstraints=(any(strcmp(p,obj.ParamHasFixedValConstraintsForSimOnlyList))&&obj.SupportsOnlySimulation);
                tf=isVisible&&isChangeable&&~(hasFixedGenConstraints||hasFixedSimConstraints);
            end
        end
        function cList=getConstrainableParameterList(obj)
            cList={};
            for p=obj.AllParamList'
                if obj.isParameterValueConstrainable(p{1})
                    cList{end+1}=p{1};%#ok<AGROW>
                end
            end
        end
    end
    properties(SetAccess=private)
BoardName
SupportsOnlySimulation
SupportedTool
SupportedToolVersion
HasProcessor
HasFPGA
        DesignParamsPL(1,:)soc.customboard.internal.DesignParameter
        DesignParamsPS(1,:)soc.customboard.internal.DesignParameter
        DesignParams(1,:)soc.customboard.internal.DesignParameter
CustomDesignTclHooks
        OSCustomizationCacheFile='';
    end
    properties(Access=private,Constant=true)
        SupportedToolList={'Xilinx Vivado'};
        SupportedToolVersionList={'2018.2'};

        MemoryCtrlPLParams={
'AXIMemorySubsystemClockPL'
'AXIMemorySubsystemDataWidthPL'
'RefreshOverheadPL'
'WriteFirstTransferLatencyPL'
'WriteLastTransferLatencyPL'
'ReadFirstTransferLatencyPL'
'ReadLastTransferLatencyPL'
        };

        MemoryCtrlPSParams={
'AXIMemorySubsystemClockPS'
'AXIMemorySubsystemDataWidthPS'
'RefreshOverheadPS'
'WriteFirstTransferLatencyPS'
'WriteLastTransferLatencyPS'
'ReadFirstTransferLatencyPS'
'ReadLastTransferLatencyPS'
        };

        AllParamList={
'MemMapButton'
'IncludeJTAGMaster'
'IncludeProcessingSystem'
'HasPSMemory'
'HasPLMemory'
'InterruptLatency'
'AXILiteClock'
'AXIHDLUserLogicClock'
'AXIMemorySubsystemClockPL'
'AXIMemorySubsystemDataWidthPL'
'RefreshOverheadPL'
'WriteFirstTransferLatencyPL'
'WriteLastTransferLatencyPL'
'ReadFirstTransferLatencyPL'
'ReadLastTransferLatencyPL'
'AXIMemorySubsystemClockPS'
'AXIMemorySubsystemDataWidthPS'
'RefreshOverheadPS'
'WriteFirstTransferLatencyPS'
'WriteLastTransferLatencyPS'
'ReadFirstTransferLatencyPS'
'ReadLastTransferLatencyPS'
'AXIMemoryInterconnectInputClock'
'AXIMemoryInterconnectInputDataWidth'
'AXIMemoryInterconnectFIFODepth'
'AXIMemoryInterconnectFIFOAFullDepth'
'MemChDiagLevel'
'IncludeAXIInterconnectMonitor'
'NumberOfTraceEvents'
        };


        ParamHasNoEffectForSimList={
'IncludeJTAGMaster'
'InterruptLatency'
'AXILiteClock'
'AXIHDLUserLogicClock'
'IncludeAXIInterconnectMonitor'
'NumberOfTraceEvents'
        };

        ParamHasFixedValForGenList={

'AXILiteClock'
'AXIMemoryInterconnectInputClock'
        };


        ParamHasFixedValConstraintsForGenList={
'MemMapButton'
'IncludeJTAGMaster'
'InterruptLatency'
'AXILiteClock'
'RefreshOverhead'
'AXIMemoryInterconnectInputClock'
'AXIMemoryInterconnectInputDataWidth'
'AXIMemoryInterconnectFIFODepth'
'AXIMemoryInterconnectFIFOAFullDepth'
'MemChDiagLevel'
'IncludeAXIInterconnectMonitor'
        };


        ParamHasFixedValConstraintsForSimOnlyList={
'RefreshOverheadPL'
'RefreshOverheadPS'
        };
        CustomDesignTclHookList={
'ProcessingSystem'
'MIG'
        };
    end
end
