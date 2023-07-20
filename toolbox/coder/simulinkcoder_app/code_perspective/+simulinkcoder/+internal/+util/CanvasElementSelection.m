classdef CanvasElementSelection<handle






    methods(Static)
        function valSrcPortsHdls=getValidSrcPortHandles(modelH)

            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            bd=get_param(modelH,'object');
            if isa(bd,'Simulink.BlockDiagram')||isa(bd,'Simulink.SubSystem')
                line=find_system(modelH,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.allVariants,...
                'FindAll','on',...
                'Type','line',...
                'Selected','on');
                if isempty(line)



                    line=find(bd,'Type','line','Selected','on','-depth',1);
                end
            else
                valSrcPortsHdls=[];
                return;
            end

            valSrcPortsHdls=zeros(length(line),1);
            for idx=1:length(line)
                if isa(line(idx),'Simulink.Line')
                    onePort=getSourcePort(line(idx));
                    if~isempty(onePort)&&strcmpi(get_param(onePort,'PortType'),'outport')
                        valSrcPortsHdls(idx)=onePort.Handle;
                    end
                else
                    onePort=get_param(line(idx),'SrcPortHandle');
                    if~isequal(-1,onePort)&&strcmpi(get_param(onePort,'PortType'),'outport')
                        valSrcPortsHdls(idx)=onePort;
                    end
                end
            end
            valSrcPortsHdls=valSrcPortsHdls(valSrcPortsHdls~=0);
        end


        function valBlockHdls=getValidBlockHandles(modelH)

            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            bd=get_param(modelH,'object');
            if isa(bd,'Simulink.BlockDiagram')||isa(bd,'Simulink.SubSystem')
                valBlockHdls=find_system(modelH,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.allVariants,...
                'FindAll','on',...
                'Type','block',...
                'Selected','on');
                if isempty(valBlockHdls)



                    valBlockHdls=find(bd,'Type','block','Selected','on','-depth',1);
                end
            else
                valBlockHdls=[];
            end
        end

        function countAdded=addBlockParameter(modelH,blockHandle,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            mmgr=get_param(modelH,'MappingManager');
            if nargin>2
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            paramFields={};
            paramFieldsStruct=get_param(blockHandle,'DialogParameters');
            if~isempty(paramFieldsStruct)
                paramFields=fieldnames(paramFieldsStruct);
            end
            countAdded=0;
            for k=1:numel(paramFields)
                try
                    if strcmp(paramFieldsStruct.(paramFields{k}).Type,'string')
                        newBlockParam=modelMapping.createBlockParameter(blockHandle,paramFields{k});
                        if~isempty(newBlockParam)
                            countAdded=countAdded+1;
                        end
                    end
                catch

                end
            end
        end

        function removeBlockParameter(modelH,blockHandle,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            mmgr=get_param(modelH,'MappingManager');
            if nargin>3
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            if nargin>2

                paramField=varargin{1};
                try
                    modelMapping.removeBlockParameter(blockHandle,paramField);
                catch ME
                    errordlg(regexprep(ME.message,'<.*?>',''));
                    return;
                end
            else

                paramFieldsStruct=get_param(blockHandle,'DialogParameters');
                paramFields=fieldnames(paramFieldsStruct);
                for k=1:numel(paramFields)
                    try
                        if strcmp(paramFieldsStruct.(paramFields{k}).Type,'string')
                            modelMapping.removeBlockParameter(blockHandle,paramFields{k});
                        end
                    catch ME
                        errordlg(regexprep(ME.message,'<.*?>',''));
                        return;
                    end
                end
            end
        end

        function addSelectedSignals(modelH,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            valSrcPortsHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidSrcPortHandles(modelH);

            if isempty(valSrcPortsHdls)
                return;
            end

            mmgr=get_param(modelH,'MappingManager');
            if nargin>2
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            warningList=[];

            for i=1:length(valSrcPortsHdls)

                try
                    modelMapping.addSignal(valSrcPortsHdls(i));
                    set_param(valSrcPortsHdls(i),'PortConfiguredForCode','on');
                catch ME
                    warningList{end+1}=ME;
                    continue;
                end
            end

            if~isempty(warningList)
                myStage=sldiagviewer.createStage('Analysis','ModelName',get_param(modelH,'Name'));
            end

            for i=1:length(warningList)
                sldiagviewer.reportWarning(warningList{i});
            end
        end

        function removeSelectedSignals(modelH,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            valSrcPortsHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidSrcPortHandles(modelH);

            if isempty(valSrcPortsHdls)
                return;
            end

            mmgr=get_param(modelH,'MappingManager');
            if nargin>2
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            for i=1:length(valSrcPortsHdls)

                modelMapping.removeSignal(valSrcPortsHdls(i));
                set_param(valSrcPortsHdls(i),'PortConfiguredForCode','off');
            end
        end

        function[result,selected]=areAnySelectedSignalsNotConfigured(modelH)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            result=false;
            selected=false;

            valSrcPortsHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidSrcPortHandles(modelH);
            if isempty(valSrcPortsHdls)
                return;
            end
            selected=true;

            mmgr=get_param(modelH,'MappingManager');
            modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);

            if isempty(modelMapping)
                return;
            end

            configuredHandles=[modelMapping.Signals(:).PortHandle];
            if isempty(configuredHandles)
                result=true;
                return;
            end

            for i=1:length(valSrcPortsHdls)
                if~any(ismember(configuredHandles,valSrcPortsHdls(i)))

                    result=true;
                    break;
                end
            end
        end

        function result=isInCodePerspective(modelH)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            result=false;
            cp=simulinkcoder.internal.CodePerspective.getInstance;
            if cp.isInPerspective(modelH)
                result=true;
            end
        end

        function result=isValidMappingType(model)
            result=false;
            if ishandle(model)
                model=get_param(model,'Name');
            end

            mmgr=get_param(model,'MappingManager');
            allowedTypes={'CoderDictionary','AutosarTarget','SimulinkCoderCTarget'};
            if isempty(find(strcmp(allowedTypes,mmgr.getCurrentMapping),1))
                return;
            end

            modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            if isempty(modelMapping)
                return;


            end

            result=true;
        end

        function result=isConfiguredForCode(modelH,portHandle)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            result=false;

            mmgr=get_param(modelH,'MappingManager');
            modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);

            if isempty(modelMapping)
                return;
            end

            configuredHandles=[modelMapping.Signals(:).PortHandle];
            if isempty(configuredHandles)

                return;
            end

            if any(ismember(configuredHandles,portHandle))

                result=true;
            end
        end

        function addSignal(modelH,portHandle,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            mmgr=get_param(modelH,'MappingManager');
            if nargin>2
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end


            try
                modelMapping.addSignal(portHandle);
                set_param(portHandle,'PortConfiguredForCode','on');
            catch ME
                errordlg(regexprep(ME.message,'<.*?>',''));
                return;
            end
        end

        function removeSignal(modelH,portHandle,varargin)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end
            mmgr=get_param(modelH,'MappingManager');
            if nargin>2
                modelMapping=mmgr.getActiveMappingFor(varargin{1});
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            modelMapping.removeSignal(portHandle);
            set_param(portHandle,'PortConfiguredForCode','off');
        end

        function syncNamedSignals(modelH,currentMapping)
            if ishandle(modelH)
                modelH=get_param(modelH,'Name');
            end


            A=find_system(modelH,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','type','Port','Name','.*');

            mmgr=get_param(modelH,'MappingManager');
            if nargin>1
                modelMapping=mmgr.getActiveMappingFor(currentMapping);
            else
                modelMapping=mmgr.getActiveMappingFor(mmgr.getCurrentMapping);
            end

            if isempty(modelMapping)
                return;
            end

            warningList=[];
            for i=1:length(A)

                try
                    modelMapping.addSignal(A(i));
                    set_param(A(i),'PortConfiguredForCode','on');
                catch ME
                    warningList{end+1}=ME;
                    continue;
                end
            end

            if~isempty(warningList)
                myStage=sldiagviewer.createStage('Analysis','ModelName',get_param(modelH,'Name'));
            end

            for i=1:length(warningList)
                sldiagviewer.reportWarning(warningList{i});
            end
        end

        function refreshSignalBadges(model)
            if ishandle(model)
                model=get_param(model,'Name');
            end
            mmgr=get_param(model,'MappingManager');
            allowedTypes={'CoderDictionary','AutosarTarget','SimulinkCoderCTarget','HDLTarget'};



            for i=1:length(allowedTypes)
                modelMapping=mmgr.getActiveMappingFor(allowedTypes{i});
                if~isempty(modelMapping)
                    modelMapping.refreshSignalBadges();
                end
            end
        end
    end
end


