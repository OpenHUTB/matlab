classdef InterfacePortHandlePairsContainer<handle







    properties(SetAccess=private)
        BlockPath char
        SID char
        InputPairs(:,2)double
        OutputPairs(:,2)double
        InputIsBus logical=logical.empty
        OutputIsBus logical=logical.empty
        InputIsFcnCall logical=logical.empty
        OutputIsFcnCall logical=logical.empty
        InputIsBoolean logical=logical.empty
        OutputIsBoolean logical=logical.empty
        InputIsString logical=logical.empty
        OutputIsString logical=logical.empty
        InputDrivenByDTC logical=logical.empty
        OutputDrivesDTC logical=logical.empty
        NumInputs(1,1)double=0
        NumOutputs(1,1)double=0
        NumInputConnections(1,1)double=0
        NumOutputConnections(1,1)double=0
        EnablePair(:,2)double
        TriggerPair(:,2)double
        StatePair(:,2)double
        IfactionPair(:,2)double
        ResetPair(:,2)double
        Diagnostics=MException.empty()
    end

    methods
        function this=InterfacePortHandlePairsContainer(blockPath,inputPortHandlePairs,outputPortHandlePairs)
            this.BlockPath=blockPath;
            this.SID=Simulink.ID.getSID(this.BlockPath);
            portHandles=get_param(blockPath,'PortHandles');

            [this.EnablePair,inputPortHandlePairs]=this.extractExecutionControlPortPair(inputPortHandlePairs,portHandles.Enable);
            [this.TriggerPair,inputPortHandlePairs]=this.extractExecutionControlPortPair(inputPortHandlePairs,portHandles.Trigger);
            [this.IfactionPair,inputPortHandlePairs]=this.extractExecutionControlPortPair(inputPortHandlePairs,portHandles.Ifaction);
            [this.ResetPair,inputPortHandlePairs]=this.extractExecutionControlPortPair(inputPortHandlePairs,portHandles.Reset);

            [this.StatePair,outputPortHandlePairs]=this.extractExecutionControlPortPair(outputPortHandlePairs,portHandles.State);

            this.InputPairs=inputPortHandlePairs;
            this.OutputPairs=outputPortHandlePairs;

            this.NumInputs=numel(portHandles.Inport);
            this.NumInputConnections=size(this.InputPairs,1);
            this.NumOutputs=numel(portHandles.Outport);
            this.NumOutputConnections=size(this.OutputPairs,1);

            if~isempty(this.InputPairs)
                inPortObjects=arrayfun(@(x)get_param(x,'Object'),this.InputPairs(:,1),'UniformOutput',false);
                [this.InputIsBus,this.InputIsFcnCall,this.InputIsBoolean,this.InputIsString,diagnostics]=this.getSignalHierarchy(inPortObjects);
                addDiagnostic(this,diagnostics);
                drivingParent=arrayfun(@(x)get_param(x,'Parent'),this.InputPairs(:,1),'UniformOutput',false);
                this.InputDrivenByDTC=cellfun(@(x)isa(get_param(x,'Object'),'Simulink.DataTypeConversion'),drivingParent);
            end


            if~isempty(this.OutputPairs)
                outPortObjects=arrayfun(@(x)get_param(x,'Object'),this.OutputPairs(:,1),'UniformOutput',false);
                [this.OutputIsBus,this.OutputIsFcnCall,this.OutputIsBoolean,this.OutputIsString,diagnostics]=this.getSignalHierarchy(outPortObjects);
                addDiagnostic(this,diagnostics);
                drivenParent=arrayfun(@(x)get_param(x,'Parent'),this.OutputPairs(:,2),'UniformOutput',false);
                this.OutputDrivesDTC=cellfun(@(x)isa(get_param(x,'Object'),'Simulink.DataTypeConversion'),drivenParent);
            end
        end

        function parents=getInputParents(this)
            parents=reshape(get(this.InputPairs(:),'Parent'),size(this.InputPairs));
        end

        function parents=getOutputParents(this)
            parents=reshape(get(this.OutputPairs(:),'Parent'),size(this.OutputPairs));
        end

        function addDiagnostic(this,diagnostics)
            if isempty(this.Diagnostics)&&~isempty(diagnostics)
                this.Diagnostics=MException(message('SimulinkFixedPoint:autoscaling:issueWhenConstructingInterfacePortPairs'));
            end
            for k=1:numel(diagnostics)
                this.Diagnostics=this.Diagnostics.addCause(diagnostics{k});
            end
        end
    end

    methods(Static)
        function[extractedPair,otherInputPairs]=extractExecutionControlPortPair(inputPortHandlePairs,executionControlPortHandle)



            otherInputPairs=inputPortHandlePairs;
            extractedPair=[];
            if~(isempty(inputPortHandlePairs)||isempty(executionControlPortHandle))
                extractedPairLocation=any((otherInputPairs==executionControlPortHandle),2);
                extractedPair=otherInputPairs(extractedPairLocation,:);
                otherInputPairs(extractedPairLocation,:)=[];
            end
        end

        function[isBusFlags,isFcnCall,isBoolean,isStringType,diagnostics]=getSignalHierarchy(portObjects)
            warningStruct=warning('off','all');



            isBusFlags=false(1,numel(portObjects));
            isFcnCall=false(1,numel(portObjects));
            isBoolean=false(1,numel(portObjects));
            isStringType=false(1,numel(portObjects));

            diagnostics={};
            for k=1:numel(portObjects)
                portObject=portObjects{k};
                try
                    isBusFlags(k)=~isempty(portObject.SignalHierarchy.BusObject)||~isempty(portObject.SignalHierarchy.Children);


                    isFcnCall(k)=strcmp(portObject.CompiledPortDataType,'fcn_call');


                    isBoolean(k)=strcmp(portObject.CompiledPortDataType,'boolean');

                    isStringType(k)=~isempty(Simulink.internal.getStringDTExprFromDTName(portObject.CompiledPortDataType));
                catch
                    diagnostics=[diagnostics;{MException(message('SimulinkFixedPoint:autoscaling:signalHierarchyIssue',num2str(portObject.Handle)))}];%#ok<AGROW>
                end
            end
            warning(warningStruct);
        end
    end
end


