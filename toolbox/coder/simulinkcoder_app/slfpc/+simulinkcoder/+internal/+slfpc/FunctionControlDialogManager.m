




classdef FunctionControlDialogManager<handle
    methods(Static=true)
        function out=getData()
            mlock;
            persistent uiRegistry;
            if isempty(uiRegistry)
                uiRegistry=containers.Map('KeyType','double','ValueType','any');
            end
            out=uiRegistry;
        end
        function modelRegistry=getModelEntry(modelH)
            uiRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getData;
            if~uiRegistry.isKey(modelH)
                modelRegistry=containers.Map('KeyType','char','ValueType','any');
                uiRegistry(modelH)=modelRegistry;%#ok<NASGU>
            else
                modelRegistry=uiRegistry(modelH);
            end
        end
        function openDialogForSubsystem(modelH,blockH)



            modelRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getModelEntry(modelH);

            fcnName='Subsystem';
            if modelRegistry.isKey(fcnName)
                ui=modelRegistry(fcnName);
            else
                ui=simulinkcoder.internal.slfpc.SubsystemFunctionControlUI(modelH,blockH);
                modelRegistry(fcnName)=ui;%#ok<NASGU>
            end
            modelObject=get_param(modelH,'object');
            if~modelObject.hasCallback('PreClose','SimulinkFunctionControl_PreClose')
                Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulinkFunctionControl_PreClose',...
                @()simulinkcoder.internal.slfpc.FunctionControlDialogManager.removeDialogs(modelH));
            end
            ui.show;
        end

        function openDialog(modelH,blockH)
            if ischar(modelH)||isstring(modelH)
                modelH=get_param(modelH,'Handle');
            end
            if ischar(blockH)||isstring(blockH)
                blockH=get_param(blockH,'Handle');
            end

            if codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(blockH)
                return;
            end
            modelRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getModelEntry(modelH);
            [~,~,fcnName]=coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(blockH);
            if modelRegistry.isKey(fcnName)
                ui=modelRegistry(fcnName);
            else
                ui=simulinkcoder.internal.slfpc.FunctionControlUI(modelH,blockH);
                modelRegistry(fcnName)=ui;%#ok<NASGU>
            end
            modelObject=get_param(modelH,'object');
            if~modelObject.hasCallback('PreClose','SimulinkFunctionControl_PreClose')
                Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulinkFunctionControl_PreClose',...
                @()simulinkcoder.internal.slfpc.FunctionControlDialogManager.removeDialogs(modelH));
            end
            ui.show;
        end


        function openEntryFcnDialog(modelH,mapping,functionCategory,debug)
            if nargin<4
                debug=false;
            end

            if ischar(modelH)
                load_system(strtok(modelH,'/'));
                modelH=get_param(modelH,'handle');
            end
            if strcmp(get_param(modelH,'type'),'block')
                RTW.configSubsystemBuild(modelH);
                return;
            end

            hasMapping=true;
            if nargin==1



                modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
                hasMapping=~isempty(modelMapping)&&~isempty(modelMapping.OutputFunctionMappings);
                if hasMapping
                    mapping=modelMapping.OutputFunctionMappings(1);
                else

                    mapping='';
                    functionType='Step';
                    functionId='';
                    validId='';
                end
            end

            if hasMapping
                [functionType,functionId]=Simulink.CodeMapping.getFunctionId(...
                mapping,functionCategory);

                validId=Simulink.CodeMapping.getValidIdentifierForDialogId(mapping,functionType,functionId);
            end

            fcnIdString=sprintf('$%s_%s$',functionType,validId);

            modelRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getModelEntry(modelH);
            if modelRegistry.isKey(fcnIdString)
                ui=modelRegistry(fcnIdString);
            else
                ui=simulinkcoder.internal.slfpc.EntryFunctionControlUI(modelH,mapping,functionType,functionId,debug);

                if isempty(ui.ID)

                    return;
                end
                modelRegistry(fcnIdString)=ui;%#ok<NASGU>
            end
            modelObject=get_param(modelH,'object');
            if~modelObject.hasCallback('PreClose','SimulinkFunctionControl_PreClose')
                Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulinkFunctionControl_PreClose',...
                @()simulinkcoder.internal.slfpc.FunctionControlDialogManager.removeDialogs(modelH));
            end
            ui.show;
        end
        function removeDialogs(modelH)
            modelRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getModelEntry(modelH);
            keys=modelRegistry.keys;
            for i=1:length(keys)
                ui=modelRegistry(keys{i});
                delete(ui);
            end
            if isempty(modelRegistry)
                uiRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getData;
                if uiRegistry.isKey(modelH)
                    uiRegistry.remove(modelH);
                end
            end
            Simulink.removeBlockDiagramCallback(modelH,'PreClose','SimulinkFunctionControl_PreClose');
        end
        function removeDialog(modelH,fcnName)
            modelRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getModelEntry(modelH);
            if modelRegistry.isKey(fcnName)
                modelRegistry.remove(fcnName);
            end
            if isempty(modelRegistry)
                uiRegistry=simulinkcoder.internal.slfpc.FunctionControlDialogManager.getData;
                uiRegistry.remove(modelH);
            end
        end
    end
end


