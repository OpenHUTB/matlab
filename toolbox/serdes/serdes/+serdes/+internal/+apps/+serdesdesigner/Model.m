classdef Model<handle

    properties(Hidden)
Name
SerdesDesign
        IsChanged=false;
SerdesDesignerTool
    end


    properties(Constant,Access=private)
        DefaultName=getString(message('serdes:serdesdesigner:DefaultSerdesDesignName'));
    end


    properties(Access=private)
        MatFilePath=''
    end


    properties
View
        IsAutoUpdate=true;
    end


    methods

        function obj=Model(varargin)
            if nargin==1
                initialModel(varargin{1})
            else
                defaultModel(obj)
            end
        end
    end


    methods(Hidden)
        function setMainTitle(obj,designName)
            if~isempty(obj.View)
                mainTitle=strcat({getString(message('serdes:serdesdesigner:SerdesDesignerText'))},{' - '},{designName});
                if obj.IsChanged
                    mainTitle=strcat(mainTitle,{getString(message('serdes:serdesdesigner:DirtySerdesDesignFlag'))});
                end
                obj.View.Toolstrip.appContainer.Title=mainTitle{1};
            end
        end


        function defaultSerdesDesign(obj)
            obj.SerdesDesign=serdesquicksimulation([]);
            obj.SerdesDesign.AutoUpdate=false;
            obj.SerdesDesign.View=obj.View;
        end


        function defaultModel(obj)
            obj.Name=obj.DefaultName;
            defaultSerdesDesign(obj);
            obj.IsChanged=false;
            obj.setMainTitle(obj.Name);
        end


        function success=loadModel(obj,matfilepath)
            try
                [~,obj.Name,~]=fileparts(matfilepath);
                obj.setMainTitle(obj.Name);
                temp=load(matfilepath,'-mat');
                if obj.isValidSerdesDesignFile(temp)
                    serdesDesign=temp.serdesDesign;
                    obj.SerdesDesign=serdesDesign;
                    obj.SerdesDesign.View=obj.View;
                    obj.SerdesDesign.AutoUpdate=false;
                    obj.SerdesDesign.restoreWorkspaceVariables();
                    obj.View.Canvas.setInputOutputLinesVisible();
                    obj.View.Parameters.JitterDialog.jitter=obj.SerdesDesign.Jitter;
                    obj.View.Parameters.JitterDialog.refreshDisplayedValues();
                    obj.MatFilePath=matfilepath;
                    success=true;
                else
                    msg=message('serdes:serdesdesigner:BadSerdesDesignFile',matfilepath);
                    error(msg)
                end
            catch err
                ttl=message('serdes:serdesdesigner:LoadFailed');
                h=errordlg(err.message,getString(ttl),'modal');
                uiwait(h)
                defaultModel(obj)
                success=false;
            end
        end


        function success=initialModel(obj,arg)
            obj.Name=obj.DefaultName;
            obj.setMainTitle(obj.Name);
            if ischar(arg)

                [~,~,ext]=fileparts(arg);
                if isempty(ext)
                    filename=[arg,'.mat'];
                else
                    filename=arg;
                end
                success=obj.loadModel(filename);
            else
                if isa(arg,'serdesdesigner')
                    obj.SerdesDesign=clone(arg);
                else
                    if isnumeric(arg)
                        name=num2str(arg);
                    elseif isstring(arg)
                        name=arg;
                    elseif isobject(arg)
                        name=class(arg);
                    else
                        name='?';
                    end
                    title=message('serdes:serdesdesigner:LoadFailed');
                    msg=message('serdes:serdesdesigner:BadSerdesDesignFile',name);
                    h=errordlg(getString(msg),getString(title),'modal');
                    uiwait(h);
                    success=false;
                    return;
                end
                obj.SerdesDesign.AutoUpdate=false;
                success=true;
            end
        end
    end


    methods(Hidden)
        function isCanceled=processSerdesDesignSaving(obj)

            isCanceled=false;

            yes=getString(message('serdes:serdesdesigner:UnsavedPromptYes'));
            no=getString(message('serdes:serdesdesigner:UnsavedPromptNo'));
            cancel=getString(message('serdes:serdesdesigner:UnsavedPromptCancel'));

            if~isempty(obj.SerdesDesign.Elements)&&obj.IsChanged
                selection=questdlg(...
                getString(message('serdes:serdesdesigner:UnsavedPromptQuestion')),...
                getString(message('serdes:serdesdesigner:UnsavedPromptTitle')),yes,no,cancel,yes);
                if isempty(selection)
                    selection=cancel;
                end
            else
                selection=no;
            end

            switch selection
            case yes
                isCanceled=saveAction(obj);
            case no

            case cancel
                isCanceled=true;
            end
        end


        function newPopupActions(obj,tag)
            isCanceled=obj.processSerdesDesignSaving();
            if isCanceled
                return;
            end
            defaultModel(obj)
            obj.View.Toolstrip.SymbolTimeEdit.Value='100';
            obj.View.Toolstrip.SamplesPerSymbolDropdown.Value='16';
            obj.View.Toolstrip.BERtargetEdit.Value='1e-6';
            obj.View.Toolstrip.ModulationDropdown.Value='NRZ';
            obj.View.Toolstrip.SignalingDropdown.Value='Differential';
            obj.View.Parameters.JitterDialog.jitter=serdes.internal.apps.serdesdesigner.jitter;
            obj.View.Parameters.JitterDialog.refreshDisplayedValues();
            obj.SerdesDesign.Jitter=obj.View.Parameters.JitterDialog.jitter;
            tx=serdes.internal.apps.serdesdesigner.rcTx();
            ch=serdes.internal.apps.serdesdesigner.channel();
            rx=serdes.internal.apps.serdesdesigner.rcRx();
            try
                switch tag
                case 'Blank canvas'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyNewBlankCanvas')));
                    obj.SerdesDesign.Elements=[{tx},{ch},{rx}];

                end
                obj.IsChanged=false;
                obj.setMainTitle(obj.Name);
                obj.MatFilePath='';
                obj.notify('NewModel',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,obj.SerdesDesign))
                obj.View.Canvas.setInputOutputLinesVisible();
                obj.View.PlotsDoc_Blank.Visible=true;
                if~isempty(obj.View.PlotsFig_All_NonBlank)&&numel(obj.View.PlotsFig_All_NonBlank)>0
                    for i=1:numel(obj.View.PlotsDoc_All_NonBlank)
                        obj.View.PlotsDoc_All_NonBlank(i).Visible=false;
                        clf(obj.View.PlotsFig_All_NonBlank(i));
                    end
                end
                if~obj.IsAutoUpdate
                    obj.View.Toolstrip.toggleAutoUpdateButton();
                    obj.IsAutoUpdate=true;
                    obj.SerdesDesignerTool.Controller.AutoUpdateString='Update';
                end
                obj.View.Toolstrip.AutoUpdateBtn.Enabled=false;
                obj.View.Toolstrip.AutoUpdateCheckbox.Enabled=false;
                obj.View.Toolstrip.AutoUpdateCheckbox.Value=true;
                obj.View.Toolstrip.AutoUpdateRadioBtn.Enabled=false;
                obj.View.Toolstrip.AutoUpdateRadioBtn.Value=true;
                obj.View.Toolstrip.ManualUpdateRadioBtn.Enabled=false;
                obj.View.Toolstrip.ManualUpdateRadioBtn.Value=false;
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end


        function openAction(obj)
            isCanceled=obj.processSerdesDesignSaving();
            if isCanceled
                return;
            end

            serdesDesignFiles='SerDes System File';
            allFiles='All Files';
            selectFileTitle='Select File';

            [matfile,pathname]=uigetfile(...
            {'*.mat',[serdesDesignFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,obj.MatFilePath);

            wasCanceled=isequal(matfile,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end

            if~obj.loadModel([pathname,matfile])

                obj.newPopupActions('Blank canvas');
                return;
            end
            try
                obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyOpen')));
                obj.notify('NewModel',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,obj.SerdesDesign))

                if obj.IsAutoUpdate
                    serdesplot(obj.SerdesDesign,{'Update',obj.View});
                else
                    serdesplot(obj.SerdesDesign,{'DirtyState',obj.View});
                end
                obj.IsChanged=false;
                obj.setMainTitle(obj.Name);
                drawnow;
                obj.View.CanvasFig.Visible='off';
                obj.View.CanvasFig.Visible='on';

                obj.View.Toolstrip.AutoUpdateCheckbox.Value=obj.SerdesDesign.AutoAnalyze;
                obj.IsAutoUpdate=obj.SerdesDesign.AutoAnalyze;

                if obj.SerdesDesign.PlotVisible_PulseRes
                    serdesplot(obj.SerdesDesign,{'Pulse Response',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_StatEye
                    serdesplot(obj.SerdesDesign,{'STAT Eye',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_PrbsWaveform
                    serdesplot(obj.SerdesDesign,{'PRBS Waveform',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_Contours
                    serdesplot(obj.SerdesDesign,{'Contours',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_Bathtub
                    serdesplot(obj.SerdesDesign,{'Bathtub',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_COM
                    serdesplot(obj.SerdesDesign,{'COM',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_Report
                    serdesplot(obj.SerdesDesign,{'Report',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_BER
                    serdesplot(obj.SerdesDesign,{'BER',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_ImpulseRes
                    serdesplot(obj.SerdesDesign,{'Impulse Response',obj.View});
                end
                if obj.SerdesDesign.PlotVisible_CTLE
                    serdesplot(obj.SerdesDesign,{'CTLE Transfer Function',obj.View});
                end
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end


        function matfilepath=getMatFilePath(obj)

            if isempty(obj.MatFilePath)
                [matfile,pathname]=...
                uiputfile('*.mat','Save SERDES System as',...
                [obj.DefaultName,'.mat']);
            else
                [matfile,pathname]=...
                uiputfile('*.mat','Save SERDES System as',obj.MatFilePath);
            end
            isCanceled=isequal(matfile,0)||isequal(pathname,0);
            if isCanceled
                matfilepath=0;
            else
                matfilepath=[pathname,matfile];
            end
        end


        function canceled=saveAction(obj,matfilepath)
            canceled=false;
            if nargin<2

                if isempty(obj.MatFilePath)
                    matfilepath=getMatFilePath(obj);
                    if isequal(matfilepath,0)
                        canceled=true;
                        return;
                    end
                else
                    matfilepath=obj.MatFilePath;
                end
            end
            if~obj.SerdesDesign.refreshValuesFromWorkspaceVariables()
                canceled=true;
                return;
            end
            try
                obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusySave')));
                try
                    serdesDesign=clone(obj.SerdesDesign);
                    serdesDesign.VersionWhenSaved=version('-release');
                    serdesDesign.Jitter=obj.View.Parameters.JitterDialog.jitter;
                    serdesDesign.AutoUpdate=true;
                    save(matfilepath,'serdesDesign')
                    obj.IsChanged=false;
                    obj.setMainTitle(obj.Name);


                    obj.MatFilePath=matfilepath;
                    [~,name]=fileparts(obj.MatFilePath);
                    obj.setMainTitle(name);
                catch err
                    ttl=message('serdes:serdesdesigner:SaveFailed');
                    h=errordlg(err.message,getString(ttl),'modal');
                    uiwait(h)
                    canceled=true;
                    return;
                end
                obj.notify('NewName',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(name,obj.SerdesDesign));
                if~strcmp(obj.Name,name)
                    obj.Name=name;
                end
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end


        function savePopupActions(obj,tag)
            switch tag
            case 'Save'
                saveAction(obj);
            case 'Save as'
                matfilepath=getMatFilePath(obj);
                if isequal(matfilepath,0)
                    return;
                end
                obj.saveAction(matfilepath);
            end
        end


        function exportAction(obj)
            if~obj.SerdesDesign.refreshValuesFromWorkspaceVariables()
                return;
            end
            serdesSystem=clone(obj.SerdesDesign);
            serdesSystem.AutoUpdate=true;
            assignin('base','serdesSystem',serdesSystem)
            disp('Exported SERDES System to workspace variable <a href="matlab:disp(serdesSystem)">serdesSystem</a>.')
        end


        function exportSimulinkAction(obj)
            if~obj.SerdesDesign.refreshValuesFromWorkspaceVariables()
                return;
            end
            design=clone(obj.SerdesDesign);
            design.AutoUpdate=false;
            [sdsys,~,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR]=design.computeQuickSimulation();
            if~isempty(mismatchedValuesBlocksCTLE)||~isempty(mismatchedValuesBlocksDFECDR)
                serdes.internal.apps.serdesdesigner.Model.showMismatchedValuesDialog(mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR);
                return;
            end

            elements=design.Elements;
            channelIndex=0;
            workspaceVariablesToSet=struct('position',{},'blockName',{},'parameterName',{},'parameterValue',{});
            for i=1:numel(elements)
                if isa(elements{i},'serdes.internal.apps.serdesdesigner.channel')
                    channelIndex=i;
                    if elements{i}.isWorkspaceVariable(elements{i}.ImpulseResponse)
                        block.position='Channel';
                        block.blockName='Channel';
                        block.parameterName='ImpulseResponse';
                        block.parameterValue=elements{i}.ImpulseResponse;
                        workspaceVariablesToSet(end+1)=block;%#ok<AGROW> 
                    end
                elseif isa(elements{i},'serdes.internal.apps.serdesdesigner.ctle')
                    if elements{i}.isWorkspaceVariable(elements{i}.myGPZ)
                        if channelIndex==0
                            block.position='Tx';
                        else
                            block.position='Rx';
                        end
                        block.blockName=elements{i}.Name;
                        block.parameterName='GPZ';
                        block.parameterValue=elements{i}.myGPZ;
                        workspaceVariablesToSet(end+1)=block;%#ok<AGROW> 
                    end
                end
            end
            exporter=serdes.internal.apps.serdesdesigner.TestbenchExport(sdsys);
            exporter.workspaceVariablesToSet=workspaceVariablesToSet;
            exporter.exportSimulink(false);
        end


        function exportAMIModelAction(obj)

            if~obj.SerdesDesign.refreshValuesFromWorkspaceVariables()
                return;
            end
            design=clone(obj.SerdesDesign);
            design.AutoUpdate=false;

            [sdsys,~,mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR]=design.computeQuickSimulation();
            if~isempty(mismatchedValuesBlocksCTLE)||~isempty(mismatchedValuesBlocksDFECDR)
                serdes.internal.apps.serdesdesigner.Model.showMismatchedValuesDialog(mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR);
                return;
            end
            exporter=serdes.internal.apps.serdesdesigner.TestbenchExport(sdsys);
            position=obj.View.Toolstrip.appContainer.WindowBounds;
            exporter.exportSimulink(true,position);
        end


        function exportPopupActions(obj,tag)

            if~obj.SerdesDesign.refreshValuesFromWorkspaceVariables()
                return;
            end
            try
                switch tag
                case 'SerDes Toolbox (Simulink)'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusySerDesSystemToSimulink')));
                    exportSimulinkAction(obj);

                case 'Generate MATLAB script'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusySerDesSystemToMATLABscript')));
                    exportScript(obj.SerdesDesign);
                case 'Make IBIS-AMI'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusySerDesSystemToAMIModel')));
                    exportAMIModelAction(obj);


                end
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end

        function jitterAction(obj,tag)
            obj.View.Canvas.unselectAllElements();
            obj.View.Parameters.ElementType='';
            obj.View.Parameters.ElementType=getString(message('serdes:serdesdesigner:JitterParametersTitle'));
            drawnow;
        end
    end

    methods(Hidden)
        function systemParameterChanged(obj,data)
            b=obj.SerdesDesign;
            try
                b.(data.Name)=data.Value;

                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                obj.notify('ParameterChanged',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,b))

                if obj.IsAutoUpdate
                    serdesplot(b,{'Update',obj.View});
                end
            catch me
                h=errordlg(me.message,'Error Dialog','modal');
                uiwait(h)
                obj.notify('SystemParameterInvalid',...
                serdes.internal.apps.serdesdesigner.ParameterInvalidEventData(data.Name,b.(data.Name)))
            end
        end

        function typedData=getTypedData(obj,destination,sourceData)
            if isnumeric(destination)&&ischar(sourceData)
                typedData=str2num(sourceData);%#ok<ST2NM>
            elseif ischar(destination)&&isnumeric(sourceData)
                typedData=num2str(sourceData);
            else
                typedData=sourceData;
            end
        end
        function elementParameterChanged(obj,data)
            if isempty(obj)||isempty(data)||isempty(data.Index)
                return;
            end

            b=obj.SerdesDesign;
            updatePlots=true;
            if data.Index>0

                try

                    b.Elements{data.Index}.(data.Name)=obj.getTypedData(b.Elements{data.Index}.(data.Name),data.Value);
                catch me

                    foundInParametersList=false;
                    parameterNames=b.Elements{data.Index}.ParameterNames;
                    if~isempty(parameterNames)
                        for j=1:numel(parameterNames)
                            if strcmp(parameterNames{j},data.Name)
                                b.Elements{data.Index}.ParameterValues{j}=obj.getTypedData(b.Elements{data.Index}.ParameterValues{j},data.Value);
                                foundInParametersList=true;
                                break;
                            end
                        end
                    end
                    if~foundInParametersList
                        h=errordlg(me.message,'Error Dialog','modal');
                        uiwait(h)
                        obj.notify('ElementParameterInvalid',...
                        serdes.internal.apps.serdesdesigner.ParameterInvalidEventData(data.Name,b.Elements{data.Index}.(data.Name)))
                        return;
                    end
                end
            else



                if strcmpi(data.Name,'radioButtonIsModeClocked')
                    b.Jitter.isModeClocked=data.Value;
                    b.Jitter.isModeIdeal=~data.Value;
                elseif strcmpi(data.Name,'radioButtonIsModeIdeal')
                    b.Jitter.isModeIdeal=data.Value;
                    b.Jitter.isModeClocked=~data.Value;


                elseif strcmpi(data.Name,'checkboxTxDCD')
                    b.Jitter.isTxDCD=data.Value;
                elseif strcmpi(data.Name,'checkboxTxRj')
                    b.Jitter.isTxRj=data.Value;
                elseif strcmpi(data.Name,'checkboxTxDj')
                    b.Jitter.isTxDj=data.Value;
                elseif strcmpi(data.Name,'checkboxTxSj')
                    b.Jitter.isTxSj=data.Value;
                elseif strcmpi(data.Name,'checkboxTxSjFrequency')
                    b.Jitter.isTxSjFrequency=data.Value;
                elseif strcmpi(data.Name,'editTxDCD')
                    b.Jitter.TxDCD=data.Value;
                    updatePlots=b.Jitter.isTxDCD;
                elseif strcmpi(data.Name,'editTxRj')
                    b.Jitter.TxRj=data.Value;
                    updatePlots=b.Jitter.isTxRj;
                elseif strcmpi(data.Name,'editTxDj')
                    b.Jitter.TxDj=data.Value;
                    updatePlots=b.Jitter.isTxDj;
                elseif strcmpi(data.Name,'editTxSj')
                    b.Jitter.TxSj=data.Value;
                    updatePlots=b.Jitter.isTxSj;
                elseif strcmpi(data.Name,'editTxSjFrequency')
                    b.Jitter.TxSjFrequency=data.Value;
                    updatePlots=b.Jitter.isTxSjFrequency;
                elseif strcmpi(data.Name,'popupmenuTxDCD')
                    b.Jitter.unitsTxDCD=data.Value;
                    updatePlots=b.Jitter.isTxDCD;
                elseif strcmpi(data.Name,'popupmenuTxRj')
                    b.Jitter.unitsTxRj=data.Value;
                    updatePlots=b.Jitter.isTxRj;
                elseif strcmpi(data.Name,'popupmenuTxDj')
                    b.Jitter.unitsTxDj=data.Value;
                    updatePlots=b.Jitter.isTxDj;
                elseif strcmpi(data.Name,'popupmenuTxSj')
                    b.Jitter.unitsTxSj=data.Value;
                    updatePlots=b.Jitter.isTxSj;


                elseif strcmpi(data.Name,'checkboxRxDCD')
                    b.Jitter.isRxDCD=data.Value;
                elseif strcmpi(data.Name,'checkboxRxRj')
                    b.Jitter.isRxRj=data.Value;
                elseif strcmpi(data.Name,'checkboxRxDj')
                    b.Jitter.isRxDj=data.Value;
                elseif strcmpi(data.Name,'checkboxRxSj')
                    b.Jitter.isRxSj=data.Value;
                elseif strcmpi(data.Name,'editRxDCD')
                    b.Jitter.RxDCD=data.Value;
                    updatePlots=b.Jitter.isRxDCD;
                elseif strcmpi(data.Name,'editRxRj')
                    b.Jitter.RxRj=data.Value;
                    updatePlots=b.Jitter.isRxRj;
                elseif strcmpi(data.Name,'editRxDj')
                    b.Jitter.RxDj=data.Value;
                    updatePlots=b.Jitter.isRxDj;
                elseif strcmpi(data.Name,'editRxSj')
                    b.Jitter.RxSj=data.Value;
                    updatePlots=b.Jitter.isRxSj;
                elseif strcmpi(data.Name,'popupmenuRxDCD')
                    b.Jitter.unitsRxDCD=data.Value;
                    updatePlots=b.Jitter.isRxDCD;
                elseif strcmpi(data.Name,'popupmenuRxRj')
                    b.Jitter.unitsRxRj=data.Value;
                    updatePlots=b.Jitter.isRxRj;
                elseif strcmpi(data.Name,'popupmenuRxDj')
                    b.Jitter.unitsRxDj=data.Value;
                    updatePlots=b.Jitter.isRxDj;
                elseif strcmpi(data.Name,'popupmenuRxSj')
                    b.Jitter.unitsRxSj=data.Value;
                    updatePlots=b.Jitter.isRxSj;


                elseif strcmpi(data.Name,'checkboxRxClockRecoveryMean')
                    b.Jitter.isRxClockRecoveryMean=data.Value;
                elseif strcmpi(data.Name,'checkboxRxClockRecoveryRj')
                    b.Jitter.isRxClockRecoveryRj=data.Value;
                elseif strcmpi(data.Name,'checkboxRxClockRecoveryDj')
                    b.Jitter.isRxClockRecoveryDj=data.Value;
                elseif strcmpi(data.Name,'checkboxRxClockRecoverySj')
                    b.Jitter.isRxClockRecoverySj=data.Value;
                elseif strcmpi(data.Name,'checkboxRxClockRecoveryDCD')
                    b.Jitter.isRxClockRecoveryDCD=data.Value;
                elseif strcmpi(data.Name,'editRxClockRecoveryMean')
                    b.Jitter.RxClockRecoveryMean=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryMean;
                elseif strcmpi(data.Name,'editRxClockRecoveryRj')
                    b.Jitter.RxClockRecoveryRj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryRj;
                elseif strcmpi(data.Name,'editRxClockRecoveryDj')
                    b.Jitter.RxClockRecoveryDj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryDj;
                elseif strcmpi(data.Name,'editRxClockRecoverySj')
                    b.Jitter.RxClockRecoverySj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoverySj;
                elseif strcmpi(data.Name,'editRxClockRecoveryDCD')
                    b.Jitter.RxClockRecoveryDCD=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryDCD;
                elseif strcmpi(data.Name,'popupmenuRxClockRecoveryMean')
                    b.Jitter.unitsRxClockRecoveryMean=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryMean;
                elseif strcmpi(data.Name,'popupmenuRxClockRecoveryRj')
                    b.Jitter.unitsRxClockRecoveryRj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryRj;
                elseif strcmpi(data.Name,'popupmenuRxClockRecoveryDj')
                    b.Jitter.unitsRxClockRecoveryDj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryDj;
                elseif strcmpi(data.Name,'popupmenuRxClockRecoverySj')
                    b.Jitter.unitsRxClockRecoverySj=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoverySj;
                elseif strcmpi(data.Name,'popupmenuRxClockRecoveryDCD')
                    b.Jitter.unitsRxClockRecoveryDCD=data.Value;
                    updatePlots=b.Jitter.isRxClockRecoveryDCD;


                elseif strcmpi(data.Name,'checkboxRxReceiverSensitivity')
                    b.Jitter.isRxReceiverSensitivity=data.Value;
                elseif strcmpi(data.Name,'checkboxRxNoise')
                    b.Jitter.isRxNoise=data.Value;
                elseif strcmpi(data.Name,'checkboxRxGaussianNoise')
                    b.Jitter.isRxGaussianNoise=data.Value;
                elseif strcmpi(data.Name,'checkboxRxUniformNoise')
                    b.Jitter.isRxUniformNoise=data.Value;
                elseif strcmpi(data.Name,'editRxReceiverSensitivity')
                    b.Jitter.RxReceiverSensitivity=data.Value;
                    updatePlots=b.Jitter.isRxReceiverSensitivity;
                elseif strcmpi(data.Name,'editRxNoise')
                    b.Jitter.RxNoise=data.Value;
                    updatePlots=b.Jitter.isRxNoise;
                elseif strcmpi(data.Name,'editRxGaussianNoise')
                    b.Jitter.RxGaussianNoise=data.Value;
                    updatePlots=b.Jitter.isRxGaussianNoise;
                elseif strcmpi(data.Name,'editRxUniformNoise')
                    b.Jitter.RxUniformNoise=data.Value;
                    updatePlots=b.Jitter.isRxUniformNoise;
                else
                    return;
                end
            end
            obj.IsChanged=true;
            obj.setMainTitle(obj.Name);
            if length(obj.View.Canvas.Elements)>=length(obj.SerdesDesign.Elements)
                obj.notify('ParameterChanged',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,b))
            end

            if updatePlots
                if obj.IsAutoUpdate
                    serdesplot(b,{'Update',obj.View});
                else
                    serdesplot(b,{'DirtyState',obj.View});
                end
            end

            obj.setMainTitle(obj.Name);
        end

        function insertionRequested(obj,data)
            if isempty(data)||isnan(data.Index)||data.Index<1
                return;
            end
            index=data.Index;
            try
                switch data.Type
                case 'AGC'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertAgc')));
                    elem=serdes.internal.apps.serdesdesigner.agc;
                case 'FFE'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertFfe')));
                    elem=serdes.internal.apps.serdesdesigner.ffe;
                case 'VGA'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertVga')));
                    elem=serdes.internal.apps.serdesdesigner.vga;
                case 'SAT_AMP'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertSatAmp')));
                    elem=serdes.internal.apps.serdesdesigner.satAmp;
                case 'DFE_CDR'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertDfeCdr')));
                    elem=serdes.internal.apps.serdesdesigner.dfeCdr;
                case 'CDR'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertCdr')));
                    elem=serdes.internal.apps.serdesdesigner.cdr;
                case 'CTLE'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertCtle')));
                    elem=serdes.internal.apps.serdesdesigner.ctle;
                    elem.setIsLastEdited(obj.SerdesDesign.Elements);
                case 'Transparent'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertTransparent')));
                    elem=serdes.internal.apps.serdesdesigner.transparent;
                case 'Channel'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertChannel')));
                    elem=serdes.internal.apps.serdesdesigner.channel;
                case 'RcTx'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertAnalogOut')));
                    elem=serdes.internal.apps.serdesdesigner.rcTx;
                case 'RcRx'
                    obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyInsertAnalogIn')));
                    elem=serdes.internal.apps.serdesdesigner.rcRx;
                end








                if isempty(obj.SerdesDesign.Elements)||numel(obj.SerdesDesign.Elements)==0

                    obj.SerdesDesign.Elements(1)={elem};
                else
                    temp=[];
                    if index>1

                        for i=1:index-1
                            temp{i}=obj.SerdesDesign.Elements{i};%#ok<AGROW>
                        end
                    end
                    temp{index}=elem;
                    if index<numel(obj.SerdesDesign.Elements)+1

                        for i=index:numel(obj.SerdesDesign.Elements)
                            temp{i+1}=obj.SerdesDesign.Elements{i};
                        end
                    end
                    obj.SerdesDesign.Elements=temp;
                end
                elem.Listener.Enabled=false;

                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                obj.notify('ElementInserted',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,obj.SerdesDesign,index))

                if obj.IsAutoUpdate
                    serdesplot(obj.SerdesDesign,{'Update',obj.View});
                else
                    serdesplot(obj.SerdesDesign,{'DirtyState',obj.View});
                end
                obj.setMainTitle(obj.Name);
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end

        function deletionRequested(obj,data)
            if isempty(data)||isnan(data.Index)||data.Index<1
                return;
            end
            index=data.Index;
            element=obj.SerdesDesign.Elements{index};
            if isa(element,'serdes.internal.apps.serdesdesigner.agc')
                blockType='AGC';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.ffe')
                blockType='FFE';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.vga')
                blockType='VGA';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.satAmp')
                blockType='Saturating Amplifier';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.dfeCdr')
                blockType='DFECDR';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.cdr')
                blockType='CDR';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.ctle')
                blockType='CTLE';
            elseif isa(element,'serdes.internal.apps.serdesdesigner.transparent')
                blockType='Pass Through';
            else
                blockType=[];
            end
            try
                obj.SerdesDesignerTool.setStatus(getString(message('serdes:serdesdesigner:BusyDeleteElement',blockType,element.Name)));
                if isa(obj.SerdesDesign.Elements{index},'serdes.CTLE')
                    obj.SerdesDesign.Elements{index}.setIsLastEdited(obj.SerdesDesign.Elements);
                end
                obj.SerdesDesign.Elements{index}.delete;





                if isempty(obj.SerdesDesign.Elements)||numel(obj.SerdesDesign.Elements)==1

                    obj.SerdesDesign.Elements=[];
                else
                    temp=[];
                    if index>1

                        for i=1:index-1
                            temp{i}=obj.SerdesDesign.Elements{i};%#ok<AGROW>
                        end
                    end
                    if index<numel(obj.SerdesDesign.Elements)

                        for i=index+1:numel(obj.SerdesDesign.Elements)
                            temp{i-1}=obj.SerdesDesign.Elements{i};%#ok<AGROW>
                        end
                    end
                    obj.SerdesDesign.Elements=temp;
                end

                obj.IsChanged=true;
                obj.setMainTitle(obj.Name);
                obj.notify('ElementDeleted',...
                serdes.internal.apps.serdesdesigner.ModelChangedEventData(obj.Name,obj.SerdesDesign,index))

                if obj.IsAutoUpdate
                    serdesplot(obj.SerdesDesign,{'Update',obj.View});
                else
                    serdesplot(obj.SerdesDesign,{'DirtyState',obj.View});
                end
                obj.setMainTitle(obj.Name);
            catch ex
                obj.SerdesDesignerTool.setStatus('');
                rethrow(ex);
            end
            obj.SerdesDesignerTool.setStatus('');
        end

        function elementSelected(obj,data)
            index=data.Index;
            elem=obj.SerdesDesign.Elements{index};
            obj.notify('SelectedElement',...
            serdes.internal.apps.serdesdesigner.ElementSelectedEventData(index,elem))
        end
    end

    events(Hidden)
NewModel
NewName
ParameterChanged
SystemParameterInvalid
ElementParameterInvalid
ElementInserted
ElementDeleted
SelectedElement
    end

    methods(Static)
        function isValid=isValidSerdesDesignFile(serdesDesignStruct)

            isValid=isfield(serdesDesignStruct,'serdesDesign')&&...
            (isa(serdesDesignStruct.serdesDesign,'serdesquicksimulation')||...
            isa(serdesDesignStruct.serdesDesign,'serdes.internal.apps.serdesdesigner.serdesquicksimulation'));
        end

        function showMismatchedValuesDialog(mismatchedValuesBlocksCTLE,mismatchedValuesBlocksDFECDR)
            if~isempty(mismatchedValuesBlocksCTLE)>0&&~isempty(mismatchedValuesBlocksDFECDR)
                title=getString(message('serdes:serdesdesigner:BadDataTitle','CTLE, DFECDR'));
            elseif~isempty(mismatchedValuesBlocksCTLE)
                title=getString(message('serdes:serdesdesigner:BadDataTitle','CTLE'));
            elseif~isempty(mismatchedValuesBlocksDFECDR)
                title=getString(message('serdes:serdesdesigner:BadDataTitle','DFECDR'));
            else
                return;
            end
            body='';
            if~isempty(mismatchedValuesBlocksCTLE)
                ctleBlocks=serdes.internal.apps.serdesdesigner.Model.getStringOfBlockNames(mismatchedValuesBlocksCTLE);
                if~contains(ctleBlocks,', ')
                    body=getString(message('serdes:serdesdesigner:AcDcPeakingGainEtcViolation0',ctleBlocks));
                else
                    body=getString(message('serdes:serdesdesigner:AcDcPeakingGainEtcViolation1',ctleBlocks));
                end
            end
            if~isempty(mismatchedValuesBlocksDFECDR)
                dfecdrBlocks=serdes.internal.apps.serdesdesigner.Model.getStringOfBlockNames(mismatchedValuesBlocksDFECDR);
                if~contains(dfecdrBlocks,', ')
                    temp=getString(message('serdes:serdesdesigner:TapWeightsMinMaxTapViolation0',dfecdrBlocks));
                else
                    temp=getString(message('serdes:serdesdesigner:TapWeightsMinMaxTapViolation1',dfecdrBlocks));
                end
                if isempty(body)
                    body=temp;
                else
                    body=[body,{' '},temp];
                end
            end
            h=errordlg(body,title,'modal');
            uiwait(h);
        end

        function blockNamesString=getStringOfBlockNames(blocks)
            blockNamesString='';
            if~isempty(blocks)&&numel(blocks)>0
                for i=1:numel(blocks)
                    if isprop(blocks{i},'BlockName')
                        if i==1

                            blockNamesString=blocks{i}.BlockName;
                        else

                            blockNamesString=[blockNamesString,', ',blocks{i}.BlockName];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end
