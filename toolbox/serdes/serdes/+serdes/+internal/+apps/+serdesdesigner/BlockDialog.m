classdef BlockDialog<handle




    properties
Parent
Panel
Layout
        Width=0
        Height=0
Listeners

Title
DefaultName
HeaderDescription
        ParameterNames=[];
        ParameterValues=[];
        ParameterTooltips=[];
        ParameterNamesInGUI=[];
        TogglePairs_SeDiff=[];
        SerdesElement=[];
        NonSerdesElement=[];
    end

    properties(Dependent)
Name
    end

    properties(Access=private)

NameLabel
NameEdit
WarningLabel
WarningLabel2
        WarningLabelText=[];
        WarningLabelText2=[];
        ConfigSelectEdit=[];
        ConfigSelectList=[];

ParameterLabels
ParameterEdits

amiParameters
simParameters
        isMismatchedAcDcPeakingGainEtc=false;
        isMismatchedTapWeightsMinTapMaxTap=false;

        sParameterFitHistory=[];
        CTLEFitHistory=[];
    end

    methods

        function obj=BlockDialog(parent,dialogPanel,headerDescription)
            if nargin==0
                parent=uifigure;
            end
            obj.Parent=parent;
            obj.Panel=dialogPanel;
            obj.HeaderDescription=headerDescription;

            isSerdesElement=true;
            if strcmpi(headerDescription,getString(message('serdes:serdesdesigner:AgcHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.agc;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:FfeHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.ffe;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:VgaHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.vga;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:SatAmpHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.satAmp;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:SatAmpDisabledBlockText'));
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:DfeCdrHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.dfeCdr;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:MustBeSameLengthVectorsOrScalarsText'));
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:CdrHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.cdr;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:CdrDisabledBlockText'));
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:CtleHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.ctle;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:MustBeSameLengthVectorsOrScalarsText'));
                obj.WarningLabelText2=getString(message('serdes:serdesdesigner:MustBeLessThanOrEqualTo40dB'));
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:TransparentHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.transparent;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:AnalogOutHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.rcTx;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText1'));
                obj.WarningLabelText2=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText2'));
                isSerdesElement=false;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:AnalogInHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.rcRx;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText1'));
                obj.WarningLabelText2=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText2'));
                isSerdesElement=false;
            elseif strcmpi(headerDescription,getString(message('serdes:serdesdesigner:ChannelHdrDesc')))
                block=serdes.internal.apps.serdesdesigner.channel;
                obj.WarningLabelText=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText1'));
                obj.WarningLabelText2=getString(message('serdes:serdesdesigner:AnalogModelInputsUsageText2'));
                isSerdesElement=false;
            else
                block=[];
                isSerdesElement=false;
            end
            if~isempty(block)

                obj.DefaultName=block.DefaultName;


                obj.ParameterNames=fieldnames(block);
                if~isempty(obj.ParameterNames)
                    obj.TogglePairs_SeDiff=obj.get_ToggleParamPairs_SE_Diff(block);
                    for i=1:numel(obj.ParameterNames)
                        obj.ParameterValues{i}=block.(obj.ParameterNames{i});
                        obj.ParameterTooltips{i}=obj.get_ToolTip(block,obj.ParameterNames{i});


                        obj.ParameterNamesInGUI{i}=obj.get_NameInGUI(block,obj.ParameterNames{i});
                        if isempty(obj.ParameterNamesInGUI{i})
                            obj.ParameterNamesInGUI{i}=obj.ParameterNames{i};
                        end
                    end
                    if~isSerdesElement

                        obj.NonSerdesElement=block;
                    else

                        obj.SerdesElement=block;


                        obj.updateAmiAndSimParameterLists();


                        if~isempty(obj.amiParameters)
                            for i=1:numel(obj.amiParameters)
                                for j=1:numel(obj.ParameterNames)
                                    if isprop(obj.amiParameters{i},'CurrentValueDisplay')&&...
                                        (isprop(obj.amiParameters{i},'Name')&&strcmpi(obj.amiParameters{i}.Name,obj.ParameterNames{j})||...
                                        isprop(obj.amiParameters{i},'NodeName')&&strcmpi(obj.amiParameters{i}.NodeName,obj.ParameterNames{j}))
                                        obj.ParameterValues{j}=obj.amiParameters{i}.CurrentValueDisplay;
                                        break;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            obj.createUIControls();
            obj.layoutUIControls();
            obj.addListeners();
        end

        function deleteDialog(obj)

            obj.removeListeners();
            obj.deleteUIControls();
            delete(obj);
        end


        function updateAmiAndSimParameterLists(obj)
            if~isempty(obj.SerdesElement)
                try
                    [obj.amiParameters,obj.simParameters]=obj.SerdesElement.getAMIParameters();
                catch
                    try
                        obj.simParameters=[];
                        obj.amiParameters=obj.SerdesElement.getAMIParameters();
                    catch
                        obj.simParameters=[];
                        obj.amiParameters=[];
                    end
                end
            end
        end


        function isVisible=isVisibleConfigSelectCTLE(obj)
            isVisible=true;
            if~isempty(obj.SerdesElement)&&isa(obj.SerdesElement,'serdes.CTLE')
                [label_Mode,edit_Mode]=obj.getParameterLabelAndEdit('Mode');
                [label_Config,edit_Config]=obj.getParameterLabelAndEdit('ConfigSelect');
                if~isempty(label_Mode)&&~isempty(edit_Mode)&&~isempty(label_Config)&&~isempty(edit_Config)
                    isVisible=~strcmpi(edit_Mode.Value,'Adapt');
                end
            end
        end


        function setAcDcPeakingGainLabelsEtc(obj)

            [label_PKFreq,edit_PKFreq]=obj.getParameterLabelAndEdit('PeakingFrequency');
            [label_DCGain,edit_DCGain]=obj.getParameterLabelAndEdit('DCGain');
            [label_ACGain,edit_ACGain]=obj.getParameterLabelAndEdit('ACGain');
            [label_PKGain,edit_PKGain]=obj.getParameterLabelAndEdit('PeakingGain');


            allLabels={label_PKFreq,label_DCGain,label_ACGain,label_PKGain};
            for i=1:numel(allLabels)
                if all(abs(allLabels{i}.FontColor-[1,0,0])<0.000001)
                    allLabels{i}.FontColor='k';
                    allLabels{i}.FontWeight='normal';
                end
            end


            allEdits={edit_PKFreq,edit_DCGain,edit_ACGain,edit_PKGain};
            for i=1:numel(allEdits)
                text=obj.getParamNameOfUIControl(allEdits{i});
                allEdits{i}.Tooltip=obj.getParameterToolTip(text);
            end


            visibleEdits={};
            visibleValues={};
            visibleLabels={};
            visibleLabelsCount=0;
            if strcmpi(label_PKFreq.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_PKFreq;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.PeakingFrequency;
                visibleEdits{visibleLabelsCount}=edit_PKFreq;
            end
            if strcmpi(label_DCGain.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_DCGain;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.DCGain;
                visibleEdits{visibleLabelsCount}=edit_DCGain;
            end
            if strcmpi(label_ACGain.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_ACGain;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.ACGain;
                visibleEdits{visibleLabelsCount}=edit_ACGain;
            end
            if strcmpi(label_PKGain.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_PKGain;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.PeakingGain;
                visibleEdits{visibleLabelsCount}=edit_PKGain;
            end


            if obj.areScalarsOrVectorsOfSameLength(visibleValues,visibleLabels,visibleEdits)
                obj.isMismatchedAcDcPeakingGainEtc=false;
                obj.WarningLabel.Visible='off';
            else
                obj.isMismatchedAcDcPeakingGainEtc=true;
                obj.WarningLabel.Visible='on';
            end


            obj.WarningLabel2.Visible='off';
            if~obj.isMismatchedAcDcPeakingGainEtc&&...
                strcmpi(label_DCGain.Visible,'on')&&strcmpi(label_ACGain.Visible,'on')
                if any(abs(obj.SerdesElement.DCGain-obj.SerdesElement.ACGain)>40)
                    obj.WarningLabel2.Visible='on';
                    obj.isMismatchedAcDcPeakingGainEtc=true;
                    label_DCGain.ForegroundColor='r';
                    label_ACGain.ForegroundColor='r';
                    label_DCGain.FontWeight='bold';
                    label_ACGain.FontWeight='bold';
                    edit_DCGain.TooltipString=getString(message('serdes:serdessystem:PeakingGainImpliedMustBeLessThan40dB'));
                    edit_ACGain.TooltipString=getString(message('serdes:serdessystem:PeakingGainImpliedMustBeLessThan40dB'));
                end
            end
        end


        function updateConfigSelectWidget(obj)
            if~isempty(obj.ConfigSelectEdit)&&isprop(obj.SerdesElement,'ConfigSelect')

                wasChanged=obj.Parent.View.SerdesDesignerTool.Model.IsChanged;


                configSelectValue=obj.SerdesElement.ConfigSelect;
                obj.SerdesElement.ConfigSelect=0;


                obj.updateAmiAndSimParameterLists();
                configSelect=obj.getAmiParameter('ConfigSelect');

                if numel(configSelect.DisplayValues)~=numel(obj.ConfigSelectList)||...
                    ~all(strcmpi(configSelect.DisplayValues,obj.ConfigSelectList))...

                    values={};
                    for k=1:numel(configSelect.DisplayValues)
                        values{k}=configSelect.DisplayValues{k};%#ok<AGROW> Convert/store string as char.
                    end
                    obj.ConfigSelectEdit.Items=values;
                    obj.ConfigSelectList=configSelect.DisplayValues;

                    if configSelectValue<numel(configSelect.DisplayValues)-1

                        obj.ConfigSelectEdit.Value=num2str(configSelectValue);
                        obj.SerdesElement.ConfigSelect=configSelectValue;
                    else

                        obj.ConfigSelectEdit.Value=num2str(numel(configSelect.DisplayValues)-1);
                        obj.SerdesElement.ConfigSelect=numel(configSelect.DisplayValues)-1;
                    end
                else

                    obj.ConfigSelectEdit.Value=num2str(configSelectValue);
                    obj.SerdesElement.ConfigSelect=configSelectValue;
                end

                obj.Parent.View.SerdesDesignerTool.Model.IsChanged=wasChanged;
            end
        end


        function setTapWeightsMinTapMaxTapLabelsEtc(obj)

            [label_TapWeights,edit_TapWeights]=obj.getParameterLabelAndEdit('TapWeights');
            [label_MinimumTap,edit_MinimumTap]=obj.getParameterLabelAndEdit('MinimumTap');
            [label_MaximumTap,edit_MaximumTap]=obj.getParameterLabelAndEdit('MaximumTap');


            allLabels={label_TapWeights,label_MinimumTap,label_MaximumTap};
            for i=1:numel(allLabels)
                if all(abs(allLabels{i}.FontColor-[1,0,0])<0.000001)
                    allLabels{i}.FontColor='k';
                    allLabels{i}.FontWeight='normal';
                end
            end


            allEdits={edit_TapWeights,edit_MinimumTap,edit_MaximumTap};
            for i=1:numel(allEdits)
                text=obj.getParamNameOfUIControl(allEdits{i});
                allEdits{i}.Tooltip=obj.getParameterToolTip(text);
            end


            visibleEdits={};
            visibleValues={};
            visibleLabels={};
            visibleLabelsCount=0;
            if strcmpi(label_TapWeights.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_TapWeights;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.TapWeights;
                visibleEdits{visibleLabelsCount}=edit_TapWeights;
            end
            if strcmpi(label_MinimumTap.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_MinimumTap;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.MinimumTap;
                visibleEdits{visibleLabelsCount}=edit_MinimumTap;
            end
            if strcmpi(label_MaximumTap.Visible,'on')
                visibleLabelsCount=visibleLabelsCount+1;
                visibleLabels{visibleLabelsCount}=label_MaximumTap;
                visibleValues{visibleLabelsCount}=obj.SerdesElement.MaximumTap;
                visibleEdits{visibleLabelsCount}=edit_MaximumTap;
            end


            if obj.areScalarsOrVectorsOfSameLength(visibleValues,visibleLabels,visibleEdits)
                obj.isMismatchedTapWeightsMinTapMaxTap=false;
                obj.WarningLabel.Visible='off';
            else
                obj.isMismatchedTapWeightsMinTapMaxTap=true;
                obj.WarningLabel.Visible='on';
            end
        end


        function[label,edit]=getParameterLabelAndEdit(obj,name)
            if~isempty(name)&&~isempty(obj.ParameterNames)&&~isempty(obj.ParameterLabels)&&~isempty(obj.ParameterEdits)
                for i=1:numel(obj.ParameterNames)
                    if strcmpi(obj.ParameterNames{i},name)
                        label=obj.ParameterLabels{i};
                        edit=obj.ParameterEdits{i};
                        return;
                    end
                end
            end
            label=[];
            edit=[];
        end


        function tooltip=getParameterToolTip(obj,name)
            if~isempty(name)&&~isempty(obj.ParameterNames)&&~isempty(obj.ParameterTooltips)
                for i=1:numel(obj.ParameterNames)
                    if strcmpi(obj.ParameterNames{i},name)
                        tooltip=obj.ParameterTooltips{i};
                        if isempty(tooltip)
                            break;
                        end
                        return;
                    end
                end
            end
            tooltip='';
        end


        function amiParameter=getAmiParameter(obj,name)
            if~isempty(name)&&~isempty(obj.amiParameters)
                for i=1:numel(obj.amiParameters)
                    mstest=isa(obj.amiParameters{i},'serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter');


                    if mstest&&strcmpi(name,obj.amiParameters{i}.NodeName)
                        amiParameter=obj.amiParameters{i};
                        return;
                    end
                end
            end
            amiParameter=[];
        end


        function simParameter=getSimParameter(obj,name)
            if~isempty(name)&&~isempty(obj.simParameters)
                obj.updateAmiAndSimParameterLists();
                for i=1:numel(obj.simParameters)
                    if strcmpi(name,obj.simParameters(i).Name)
                        simParameter=obj.simParameters(i);
                        return;
                    end
                end
            end
            simParameter=[];
        end


        function values=getParameterValues(obj)
            if~isempty(obj.ParameterEdits)
                for i=1:numel(obj.ParameterEdits)
                    if~isempty(obj.SerdesElement)
                        obj.ParameterValues{i}=...
                        serdes.internal.apps.serdesdesigner.BlockDialog.getValueInStoredUnits(obj.SerdesElement,obj.ParameterNamesInGUI{i},obj.ParameterEdits{i});
                    else
                        obj.ParameterValues{i}=...
                        serdes.internal.apps.serdesdesigner.BlockDialog.getValueInStoredUnits(obj.NonSerdesElement,obj.ParameterNamesInGUI{i},obj.ParameterEdits{i});
                    end
                end
            end
            values=obj.ParameterValues;
        end


        function setParameterValues(obj,values)
            if~isempty(values)
                if~isempty(obj.SerdesElement)&&isa(obj.SerdesElement,'serdes.CTLE')
                    obj.updateConfigSelectWidget();
                    if length(values)==length(obj.ParameterEdits)-1

                        index_myGPZ=find(strcmpi(obj.ParameterNames,'myGPZ'));
                        index_GPZ=find(strcmpi(obj.ParameterNames,'GPZ'));
                        if index_myGPZ>=1&&index_GPZ>=1
                            for i=length(values):-1:index_myGPZ
                                values{i+1}=values{i};
                            end
                            values{index_myGPZ}=values{index_GPZ};
                            obj.SerdesElement.ParameterValues=values;
                            obj.SerdesElement.ParameterNames=obj.ParameterNames;
                        end
                    end
                end
                obj.ParameterValues=values;
                containsACGain=false;
                containsDCGain=false;
                containsPeakingGain=false;
                containsPeakingFrequency=false;
                containsTapWeights=false;
                containsMinimumTap=false;
                containsMaximumTap=false;
                for i=1:numel(values)
                    if strcmpi(obj.ParameterEdits{i}.Type,'uicheckbox')
                        obj.ParameterEdits{i}.Value=values{i};
                    elseif strcmpi(obj.ParameterEdits{i}.Type,'uidropdown')
                        obj.ParameterEdits{i}.Value=values{i};
                        if strcmpi(obj.ParameterNames{i},'Specification')
                            obj.layoutUIControls;
                        elseif strcmpi(obj.ParameterNames{i},'Mode')&&isa(obj.SerdesElement,'serdes.CTLE')
                            obj.layoutUIControls;
                        elseif strcmpi(obj.ParameterNames{i},'ChannelModel')
                            obj.layoutUIControls;
                        end
                    elseif strcmp(obj.ParameterEdits{i}.Type,'uibutton')

                    elseif isa(obj.SerdesElement,'serdes.internal.apps.serdesdesigner.ctle')&&i==find(strcmpi(obj.ParameterNames,'GPZ'))

                        index=find(strcmpi(obj.ParameterNames,'myGPZ'));
                        if index>=1&&obj.SerdesElement.isWorkspaceVariable(values{index})
                            obj.ParameterEdits{i}.Value=values{index};
                        else
                            obj.ParameterEdits{i}.Value=...
                            serdes.internal.apps.serdesdesigner.BlockDialog.mat2strConditional(obj.SerdesElement,obj.ParameterNamesInGUI{i},values{i});
                        end
                    elseif~ischar(values{i})&&~isstring(values{i})
                        if~isempty(obj.SerdesElement)
                            obj.ParameterEdits{i}.Value=...
                            serdes.internal.apps.serdesdesigner.BlockDialog.mat2strConditional(obj.SerdesElement,obj.ParameterNamesInGUI{i},values{i});
                        else
                            obj.ParameterEdits{i}.Value=...
                            serdes.internal.apps.serdesdesigner.BlockDialog.mat2strConditional(obj.NonSerdesElement,obj.ParameterNamesInGUI{i},values{i});
                            if isa(obj.NonSerdesElement,'serdes.internal.apps.serdesdesigner.rcRx')||...
                                isa(obj.NonSerdesElement,'serdes.internal.apps.serdesdesigner.rcTx')
                                channel=obj.Parent.View.SerdesDesignerTool.Model.SerdesDesign.getChannel;
                                if~isempty(channel)&&strcmpi(channel.ChannelModel,'Impulse response')
                                    obj.setWarningLabelsVisibility('on');
                                else
                                    obj.setWarningLabelsVisibility('off');
                                end
                            end
                        end
                    else
                        obj.ParameterEdits{i}.Value=values{i};
                    end
                    if strcmpi(obj.ParameterNames{i},'ACGain')
                        containsACGain=true;
                    elseif strcmpi(obj.ParameterNames{i},'DCGain')
                        containsDCGain=true;
                    elseif strcmpi(obj.ParameterNames{i},'PeakingGain')
                        containsPeakingGain=true;
                    elseif strcmpi(obj.ParameterNames{i},'PeakingFrequency')
                        containsPeakingFrequency=true;
                    elseif strcmpi(obj.ParameterNames{i},'TapWeights')
                        containsTapWeights=true;
                    elseif strcmpi(obj.ParameterNames{i},'MinimumTap')
                        containsMinimumTap=true;
                    elseif strcmpi(obj.ParameterNames{i},'MaximumTap')
                        containsMaximumTap=true;
                    end
                end
                if containsACGain||containsDCGain||containsPeakingGain||containsPeakingFrequency
                    obj.setAcDcPeakingGainLabelsEtc();
                end
                if containsTapWeights&&containsMinimumTap&&containsMaximumTap
                    obj.setTapWeightsMinTapMaxTapLabelsEtc();
                end
            end
        end


        function element=getSerdesElement(obj)
            element=obj.SerdesElement;
        end


        function setSerdesElement(obj,element)
            obj.SerdesElement=element;
        end


        function element=getNonSerdesElement(obj)
            element=obj.NonSerdesElement;
        end


        function setNonSerdesElement(obj,element)
            obj.NonSerdesElement=element;
        end
    end

    methods

        function str=get.Name(obj)
            str=obj.NameEdit.Value;
        end
        function set.Name(obj,str)
            obj.NameEdit.Value=str;
            obj.setTitle(str);
        end


        function setListenersEnable(obj,val)
            if val
                obj.addListeners();
            else
                obj.removeListeners();
            end
        end


        function updateLayout(obj)
            obj.layoutUIControls;
        end

        function InputFromSParameterFitter(obj,serdesDesignerHandle,SChannelObj)%#ok<INUSL> 




            assignin('base','sParameterFit',SChannelObj);
            assignin('base','sParameterFitImpulse',SChannelObj.ImpulseResponse);


            obj.sParameterFitHistory=SChannelObj;


            sampleIntervalTag=[obj.DefaultName,':ImpulseSampleInterval'];
            impulseResponseTag=[obj.DefaultName,':ImpulseResponse'];

            ndx1=find(strcmpi({obj.Layout.Children.Tag},sampleIntervalTag),1,'first');
            ndx2=find(strcmpi({obj.Layout.Children.Tag},impulseResponseTag),1,'first');


            obj.Layout.Children(ndx1).Value=sprintf('%.15g',SChannelObj.SampleInterval);






            c=obj.Parent.View.Canvas;
            c.selectElement(c.ChannelIndex);

            impulseEditField=obj.Layout.Children(ndx2);
            impulseEditField.Value="sParameterFitImpulse";

            e.Source=impulseEditField;
            obj.parameterChanged(e);
        end

        function InputFromCTLEFitter(obj,CTLEFitObj)






            if isempty(CTLEFitObj.pSDGPZName)
                bws=evalin('base','whos');
                gpzVarName=serdes.utilities.apps.ctlefitter.CTLEFitter.findCandidateNames(...
                {bws.name},'gpz');
                CTLEFitObj.pSDGPZName=gpzVarName;
            else
                gpzVarName=CTLEFitObj.pSDGPZName;
            end

            assignin('base',gpzVarName,CTLEFitObj.GPZ);


            targetBlockName=CTLEFitObj.pBlockName;
            if~isvalid(obj.Parent.View)

                body=message('serdes:serdesdesigner:CTLEFitterError1');
                h=errordlg(getString(body),'CTLE Fitter Error','modal');
                uiwait(h);
                return
            end
            c=obj.Parent.View.Canvas;
            SDAppKeyNames=cellfun(@getfield,c.Elements,repmat({'Name'},1,length(c.Elements)),'UniformOutput',false);
            blockNdx=find(strcmp(SDAppKeyNames,targetBlockName));
            if isempty(blockNdx)


                body=message('serdes:serdesdesigner:CTLEFitterError2',targetBlockName);
                h=errordlg(getString(body),'CTLE Fitter Error','modal');
                uiwait(h);
                return
            end
            c.selectElement(blockNdx);


            panelTags={obj.Panel.Children.Children.Tag};
            ndx2=find(~cellfun(@isempty,regexp(panelTags,'(?<=:)Specification$')));
            obj.Panel.Children.Children(ndx2).Value='GPZ Matrix';

            e.Source=obj.Panel.Children.Children(ndx2);
            obj.parameterChanged(e);


            ndx1=find(~cellfun(@isempty,regexp(panelTags,'(?<=:)GPZ$')));
            currentstr=obj.Panel.Children.Children(ndx1).Value;
            if strcmp(currentstr(end),' ')
                obj.Panel.Children.Children(ndx1).Value=gpzVarName;
            else
                obj.Panel.Children.Children(ndx1).Value=sprintf('%s ',gpzVarName);
            end


            ndx3=find(~cellfun(@isempty,regexp(panelTags,'(?<=:)FilterMethod$')));
            obj.Panel.Children.Children(ndx3).Value='Cascaded';


            if isempty(obj.CTLEFitHistory)
                obj.CTLEFitHistory={targetBlockName,copy(CTLEFitObj)};
            else
                historyKeyNames=obj.CTLEFitHistory(:,1);
                ndx=strcmp(historyKeyNames,targetBlockName);
                if any(ndx)
                    obj.CTLEFitHistory(ndx,:)={targetBlockName,copy(CTLEFitObj)};
                else
                    obj.CTLEFitHistory(length(historyKeyNames)+1,:)={targetBlockName,copy(CTLEFitObj)};
                end
            end

        end
    end

    methods(Access=private)

        function createUIControls(obj)
            obj.Layout=uigridlayout(obj.Panel,'RowHeight',{'fit'},'ColumnWidth',{'fit'},'Scrollable','on');

            obj.Title=uilabel(obj.Layout,...
            'Text',strcat(' (',obj.HeaderDescription,')'),...
            'Tag',strcat(obj.DefaultName,':','TitleText'),...
            'FontWeight','bold',...
            'FontColor',[.94,.94,.94],...
            'BackgroundColor',[.1,.1,.8],...
            'HorizontalAlignment','left');
            obj.Title.Layout.Row=1;
            obj.Title.Layout.Column=[1,2];

            obj.NameLabel=uilabel(obj.Layout,...
            'Text','Name:',...
            'Tag',strcat(obj.DefaultName,':','NameText'),...
            'HorizontalAlignment','right');
            obj.NameLabel.Layout.Row=2;
            obj.NameLabel.Layout.Column=1;

            obj.NameEdit=uieditfield(obj.Layout,...
            'Value','',...
            'Tag',strcat(obj.DefaultName,':','Name'),...
            'HorizontalAlignment','left');
            obj.NameEdit.Layout.Row=2;
            obj.NameEdit.Layout.Column=2;

            rowCount=2;
            if~isempty(obj.ParameterNames)
                amiColor='k';
                for i=1:numel(obj.ParameterNames)
                    rowCount=rowCount+1;

                    tag=obj.ParameterNames{i};
                    name=obj.ParameterNamesInGUI{i};
                    value=obj.ParameterValues{i};
                    amiParameter=obj.getAmiParameter(tag);
                    if~isempty(obj.SerdesElement)
                        stringSet=obj.getStringSet(obj.SerdesElement,tag);
                    else
                        stringSet=obj.getStringSet(obj.NonSerdesElement,tag);
                    end
                    obj.ParameterLabels{i}=uilabel(obj.Layout,...
                    'Tag',strcat(obj.DefaultName,':',tag,'Text'),...
                    'Text',name,...
                    'HorizontalAlignment','right');
                    obj.ParameterLabels{i}.Layout.Row=rowCount;
                    obj.ParameterLabels{i}.Layout.Column=1;





                    if~isempty(amiParameter)&&~isempty(amiParameter.Format)



                        if isempty(obj.ParameterTooltips{i})
                            obj.ParameterTooltips{i}=amiParameter.Description;
                        end
                        obj.ParameterLabels{i}.FontColor=amiColor;
                        if strcmpi(amiParameter.Format.Name,"List")
                            values={};
                            for j=1:numel(amiParameter.DisplayValues)
                                values{j}=amiParameter.DisplayValues{j};%#ok<AGROW> % Convert/store string as char.
                            end
                            value=amiParameter.CurrentValueDisplay;
                            obj.ParameterEdits{i}=uidropdown(obj.Layout,...
                            'Items',values,...
                            'Value',value,...
                            'Tag',strcat(obj.DefaultName,':',tag),...
                            'FontColor',amiColor);
                        elseif isprop(amiParameter,'CurrentValueDisplay')
                            obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                            'Value',value,...
                            'Tag',strcat(obj.DefaultName,':',tag),...
                            'FontColor',amiColor,...
                            'HorizontalAlignment','left');
                        else
                            switch lower(amiParameter.Type.Name)
                            case "boolean"
                                obj.ParameterEdits{i}=uicheckbox(obj.Layout,...
                                'Value',value,...
                                'Text','',...
                                'Tag',strcat(obj.DefaultName,':',tag),...
                                'FontColor',amiColor,...
                                'HorizontalAlignment','left');
                            case "integer"
                                obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                                'Value',int2str(value),...
                                'Tag',strcat(obj.DefaultName,':',tag),...
                                'FontColor',amiColor,...
                                'HorizontalAlignment','left');
                            case "float"
                                obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                                'Value',num2str(value),...
                                'Tag',strcat(obj.DefaultName,':',tag),...
                                'FontColor',amiColor,...
                                'HorizontalAlignment','left');
                            case "tap"
                                obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                                'Value','',...
                                'Tag',strcat(obj.DefaultName,':',tag),...
                                'FontColor',amiColor,...
                                'HorizontalAlignment','left');
                            otherwise
                                obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                                'Value',value,...
                                'Tag',strcat(obj.DefaultName,':',tag),...
                                'FontColor',amiColor,...
                                'HorizontalAlignment','left');
                            end
                        end
                    elseif~isempty(stringSet)

                        if~isempty(obj.SerdesElement)
                            values=stringSet.getAllowedValues();
                        else
                            values=stringSet;
                        end
                        obj.ParameterEdits{i}=uidropdown(obj.Layout,...
                        'Items',values,...
                        'Value',value,...
                        'Tag',strcat(obj.DefaultName,':',tag));
                    elseif islogical(value)
                        obj.ParameterEdits{i}=uicheckbox(obj.Layout,...
                        'Value',value,...
                        'Text','',...
                        'Tag',strcat(obj.DefaultName,':',tag));
                    elseif isinteger(value)
                        obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                        'Value',int2str(value),...
                        'Tag',strcat(obj.DefaultName,':',tag),...
                        'HorizontalAlignment','left');
                    elseif endsWith(tag,'Button','Ignorecase',true)

                        obj.ParameterLabels{i}.Text='';
                        if strcmp('SparameterButton',tag)
                            obj.ParameterEdits{i}=uibutton(obj.Layout,...
                            'Text',name,...
                            'Tag',strcat(obj.DefaultName,':',tag),...
                            'UserData',value);
                        else

                            obj.ParameterEdits{i}=uibutton(obj.Layout,...
                            'Text',name,...
                            'Tag',strcat(obj.DefaultName,':',tag),...
                            'UserData',value);
                        end
                    elseif isnumeric(value)
                        obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                        'text',...
                        'Value',mat2str(value),...
                        'Tag',strcat(obj.DefaultName,':',tag),...
                        'HorizontalAlignment','left');
                    elseif isempty(value)
                        obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                        'Value','',...
                        'Tag',strcat(obj.DefaultName,':',tag),...
                        'HorizontalAlignment','left');
                    else
                        obj.ParameterEdits{i}=uieditfield(obj.Layout,...
                        'Value',value,...
                        'Tag',strcat(obj.DefaultName,':',tag),...
                        'HorizontalAlignment','left');
                    end
                    if~isempty(obj.ParameterTooltips)&&~isempty(obj.ParameterTooltips{i})
                        set(obj.ParameterEdits{i},'Tooltip',obj.ParameterTooltips{i});
                        set(obj.ParameterLabels{i},'Tooltip',obj.ParameterTooltips{i});
                    end
                    if strcmpi(tag,'ConfigSelect')
                        obj.ConfigSelectEdit=obj.ParameterEdits{i};
                        obj.ConfigSelectList=amiParameter.DisplayValues;
                    end
                    obj.ParameterEdits{i}.Layout.Row=rowCount;
                    obj.ParameterEdits{i}.Layout.Column=2;
                end
            end
            if~isempty(obj.WarningLabelText)
                obj.WarningLabel=uilabel(obj.Layout,...
                'Text',obj.WarningLabelText,...
                'FontWeight','bold',...
                'FontColor','r',...
                'Tag',strcat(obj.DefaultName,':','WarningLabel'),...
                'HorizontalAlignment','left');
                rowCount=rowCount+1;
                obj.WarningLabel.Layout.Row=rowCount;
                obj.WarningLabel.Layout.Column=[1,2];
            end
            if~isempty(obj.WarningLabelText2)
                obj.WarningLabel2=uilabel(obj.Layout,...
                'Text',obj.WarningLabelText2,...
                'FontWeight','bold',...
                'FontColor','r',...
                'Tag',strcat(obj.DefaultName,':','WarningLabel2'),...
                'HorizontalAlignment','left');
                rowCount=rowCount+1;
                obj.WarningLabel2.Layout.Row=rowCount;
                obj.WarningLabel2.Layout.Column=[1,2];
            end
            if~isempty(obj.NonSerdesElement)
                obj.setWarningLabelsVisibility('off');
            end
            for row=2:rowCount
                obj.Layout.RowHeight{row}='fit';
            end
        end
        function deleteUIControls(obj)
            if~isempty(obj.NameEdit)&&isvalid(obj.NameEdit)
                delete(obj.NameEdit);
            end
            if~isempty(obj.NameLabel)&&isvalid(obj.NameLabel)
                delete(obj.NameLabel);
            end
            if~isempty(obj.ParameterEdits)
                for i=numel(obj.ParameterEdits):-1:1
                    if~isempty(obj.ParameterEdits{i})&&isvalid(obj.ParameterEdits{i})
                        delete(obj.ParameterEdits{i});
                    end
                end
            end
            if~isempty(obj.ParameterLabels)
                for i=numel(obj.ParameterLabels):-1:1
                    if~isempty(obj.ParameterLabels{i})&&isvalid(obj.ParameterLabels{i})
                        delete(obj.ParameterLabels{i});
                    end
                end
            end
        end


        function layoutUIControls(obj)

            row=1;
            obj.Title.Layout.Row=row;
            obj.Title.Layout.Column=[1,2];


            includeInvisibleWarnings=true;
            switch obj.HeaderDescription
            case getString(message('serdes:serdesdesigner:AnalogOutHdrDesc'))
                set(obj.NameLabel,'visible',false);
                set(obj.NameEdit,'visible',false);
            case getString(message('serdes:serdesdesigner:AnalogInHdrDesc'))
                set(obj.NameLabel,'visible',false);
                set(obj.NameEdit,'visible',false);
            case getString(message('serdes:serdesdesigner:ChannelHdrDesc'))
                set(obj.NameLabel,'visible',false);
                set(obj.NameEdit,'visible',false);
                includeInvisibleWarnings=false;
            otherwise
                row=row+1;
                obj.NameLabel.Layout.Row=row;
                obj.NameLabel.Layout.Column=1;

                obj.NameEdit.Layout.Row=row;
                obj.NameEdit.Layout.Column=2;
            end


            if~isempty(obj.ParameterLabels)
                isDifferential=strcmpi(obj.Parent.View.Toolstrip.SignalingDropdown.Value,'Differential');
                for i=1:numel(obj.ParameterLabels)
                    if strcmpi(obj.ParameterLabels{i}.Text,'BlockName')||...
...
                        strcmpi(obj.ParameterLabels{i}.Text,serdes.CTLE.ConfigSelect_NameInGUI)&&~obj.isVisibleConfigSelectCTLE()||...
...
                        strcmpi(obj.ParameterLabels{i}.Text,'myGPZ')||...
...
                        obj.isHiddenParameter(obj.ParameterEdits{i})||...
...
                        obj.isNoDisplayInSerDesDesignerApp(obj.SerdesElement,obj.ParameterNames{i})||...
...
                        ~isempty(obj.SerdesElement)&&isInactiveProperty(obj.SerdesElement,obj.ParameterNames{i})||...
...
                        ~isempty(obj.SerdesElement)&&~obj.hasSetAccess(obj.SerdesElement,obj.ParameterNames{i})||...
...
                        ~isempty(obj.simParameters)&&obj.isSimulationParameter(obj.ParameterNames{i},obj.simParameters)||...
...
                        ~isempty(obj.TogglePairs_SeDiff)&&obj.isHiddenSeDiffParam(obj.ParameterNames{i},obj.TogglePairs_SeDiff,isDifferential)


                        obj.ParameterLabels{i}.Visible='off';
                        obj.ParameterEdits{i}.Visible='off';
                        continue;
                    end


                    obj.ParameterLabels{i}.Visible='on';
                    obj.ParameterEdits{i}.Visible='on';
                    row=row+1;
                    obj.ParameterLabels{i}.Layout.Row=row;
                    obj.ParameterLabels{i}.Layout.Column=1;

                    obj.ParameterEdits{i}.Layout.Row=row;
                    obj.ParameterEdits{i}.Layout.Column=2;
                end
            end
            if~isempty(obj.SerdesElement)&&isa(obj.SerdesElement,'serdes.CTLE')
                obj.setAcDcPeakingGainLabelsEtc();
                obj.updateConfigSelectWidget();
            end
            if~isempty(obj.WarningLabel)&&(obj.WarningLabel.Visible||includeInvisibleWarnings)

                row=row+1;
                obj.WarningLabel.Layout.Row=row;
                obj.WarningLabel.Layout.Column=[1,2];
            end
            if~isempty(obj.WarningLabel2)&&(obj.WarningLabel2.Visible||includeInvisibleWarnings)

                row=row+1;
                obj.WarningLabel2.Layout.Row=row;
                obj.WarningLabel2.Layout.Column=[1,2];
            end
            for i=1:row
                obj.Layout.RowHeight{i}='fit';
            end
            for i=row+1:length(obj.Layout.RowHeight)
                obj.Layout.RowHeight{i}=0;
            end
            obj.Parent.setElementDialog();
        end
        function isHidden=isHiddenParameter(obj,parameterEdit)

            if~isempty(parameterEdit)&&isprop(parameterEdit,'Tag')
                name=obj.getParamNameOfUIControl(parameterEdit);
                if strcmpi(name,'ImpulseResponse')||...
                    strcmpi(name,'ImpulseSampleInterval')||...
                    strcmpi(name,'SparameterButton')
                    for i=1:length(obj.ParameterEdits)
                        name=obj.getParamNameOfUIControl(obj.ParameterEdits{i});
                        if strcmpi(name,'ChannelModel')
                            isHidden=strcmpi(obj.ParameterEdits{i}.Value,'Loss model');

                            if strcmpi(obj.getParamNameOfUIControl(parameterEdit),'SparameterButton')




                                return
                            end

                            obj.setWarningLabelsVisibility(isHidden);
                            return;
                        end
                    end
                elseif strcmpi(name,'ChannelLoss_dB')||...
                    strcmpi(name,'DifferentialImpedance')||...
                    strcmpi(name,'Impedance')||...
                    strcmpi(name,'TargetFrequency')||...
                    strcmpi(name,'XTalkEnabled')
                    for i=1:length(obj.ParameterEdits)
                        name=obj.getParamNameOfUIControl(obj.ParameterEdits{i});
                        if strcmpi(name,'ChannelModel')
                            isHidden=strcmpi(obj.ParameterEdits{i}.Value,'Impulse response');
                            obj.setWarningLabelsVisibility(isHidden);
                            return;
                        end
                    end
                elseif strcmpi(name,'XTalkSpecification')
                    for i=1:length(obj.ParameterEdits)
                        name=obj.getParamNameOfUIControl(obj.ParameterEdits{i});
                        if strcmpi(name,'ChannelModel')
                            isLossModel=strcmpi(obj.ParameterEdits{i}.Value,'Loss model');
                        elseif strcmpi(name,'XTalkEnabled')
                            isEnabled=obj.ParameterEdits{i}.Value;
                        end
                    end
                    isHidden=~isLossModel||~isEnabled;
                    return;
                elseif strcmpi(name,'FE_XTalkICN')||...
                    strcmpi(name,'NE_XTalkICN')
                    for i=1:length(obj.ParameterEdits)
                        name=obj.getParamNameOfUIControl(obj.ParameterEdits{i});
                        if strcmpi(name,'ChannelModel')
                            isLossModel=strcmpi(obj.ParameterEdits{i}.Value,'Loss model');
                        elseif strcmpi(name,'XTalkEnabled')
                            isEnabled=obj.ParameterEdits{i}.Value;
                        elseif strcmpi(name,'XTalkSpecification')
                            isCustom=strcmpi(obj.ParameterEdits{i}.Value,'Custom');
                        end
                    end
                    isHidden=~isLossModel||~isEnabled||~isCustom;
                    return;
                end
            end
            isHidden=false;
        end
        function setWarningLabelsVisibility(obj,isVisible)




            if~isempty(obj.WarningLabel)
                obj.WarningLabel.Visible=isVisible;
            end
            if~isempty(obj.WarningLabel2)
                obj.WarningLabel2.Visible=isVisible;
            end
        end


        function parameterChanged(obj,e)

            i=obj.Parent.View.Canvas.SelectIdx;
            name=obj.getParamNameOfUIControl(e.Source);
            if strcmpi(name,'Name')&&~obj.isUniqueName(obj.Parent.View.Canvas.Elements,i,obj.(name))

                title=message('serdes:serdesdesigner:DuplicateBlockNameTitle');
                body=message('serdes:serdesdesigner:DuplicateBlockNameMessage',obj.(name));
                h=errordlg(getString(body),getString(title),'modal');
                uiwait(h);
                obj.NameEdit.Value=obj.Parent.View.Canvas.Elements{i}.Name;
                return;
            end
            amiParameter=[];
            try

                value=obj.(name);
                if strcmp(name,'Name')
                    setTitle(obj,value);
                    if isprop(obj.SerdesElement,'BlockName')

                        set(obj.SerdesElement,'BlockName',obj.getStringValue(value));
                    end
                    if~isempty(obj.ParameterNames)
                        for j=1:numel(obj.ParameterNames)
                            if strcmp(obj.ParameterNames{j},'BlockName')

                                obj.ParameterEdits{j}.Value=obj.getStringValue(value);
                                break;
                            end
                        end
                    end
                end
            catch ME
                if~isempty(obj.ParameterNames)

                    obj.updateAmiAndSimParameterLists();
                    for j=1:numel(obj.ParameterNames)
                        if strcmp(obj.ParameterNames{j},name)
                            displayedName=obj.ParameterNamesInGUI{j};
                            if strcmpi(e.Source.Type,'uicheckbox')
                                value=e.Source.Value;
                            elseif strcmpi(e.Source.Type,'uidropdown')
                                value=e.Source.Value;
                            else
                                value=strtrim(e.Source.Value);
                            end
                            displayedValue=value;
                            try
                                if~isempty(obj.SerdesElement)
                                    value=...
                                    serdes.internal.apps.serdesdesigner.BlockDialog.getValueInStoredUnits(obj.SerdesElement,obj.ParameterNamesInGUI{j},value);
                                else
                                    value=...
                                    serdes.internal.apps.serdesdesigner.BlockDialog.getValueInStoredUnits(obj.NonSerdesElement,obj.ParameterNamesInGUI{j},value);
                                end
                            catch

                            end
                            amiParameter=obj.getAmiParameter(name);
                            if~isempty(amiParameter)&&strcmpi(amiParameter.Format.Name,"List")
                                amiParameter.CurrentValueDisplay=value;
                                actualValue=amiParameter.CurrentValue;
                                value=actualValue;
                            end
                            if~isempty(amiParameter)&&~isempty(amiParameter.Format)&&~amiParameter.validateValue(value)

                                title=message('serdes:serdesdesigner:BadEntryTitle');
                                str=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(value);
                                if strcmpi(amiParameter.Type.Name,"Boolean")&&~islogical(value)
                                    body=message('serdes:serdesdesigner:NonBinaryEntryMessage',str,displayedName);
                                elseif strcmpi(amiParameter.Type.Name,"Integer")&&...
                                    ~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isInteger(displayedName,str)
                                    body=[];
                                elseif strcmpi(amiParameter.Type.Name,"Float")&&...
                                    ~serdes.internal.serdesquicksimulation.SERDESQuickSimulation.isNumber(displayedName,str)
                                    body=[];
                                elseif strcmpi(amiParameter.Format.Name,"Range")
                                    body=message('serdes:serdesdesigner:OutOfRangeEntryMessage',str,displayedName,...
                                    amiParameter.Format.Min,amiParameter.Format.Max);
                                elseif strcmpi(amiParameter.Format.Name,"List")
                                    body=message('serdes:serdesdesigner:UnsupportedEntryMessage',str,displayedName);
                                else
                                    body=message('serdes:serdesdesigner:NonNumericEntryMessage',str,displayedName);
                                end
                                if~isempty(body)
                                    h=errordlg(getString(body),getString(title),'modal');
                                    uiwait(h);
                                end
                                obj.setParameterValues(obj.SerdesElement.ParameterValues);
                                return;
                            end
                            if~isempty(obj.SerdesElement)
                                element=obj.SerdesElement;
                            else
                                element=obj.NonSerdesElement;
                            end
                            if~isempty(amiParameter)&&strcmpi(amiParameter.Format.Name,"List")
                                value=amiParameter.CurrentValueDisplay;
                                typedValue=char(value);
                            elseif~isempty(obj.NonSerdesElement)&&obj.NonSerdesElement.isWorkspaceVariable(value)||...
                                ~isempty(obj.SerdesElement)&&obj.SerdesElement.isWorkspaceVariable(value)

                                typedValue=obj.getTypedValue(value,'text');
                            elseif~isempty(obj.NonSerdesElement)&&...
                                ~isempty(obj.NonSerdesElement.getWorkspaceVariableValue(name))

                                typedValue=obj.getTypedValue(value,obj.NonSerdesElement.getWorkspaceVariableValue(name));
                            else

                                typedValue=obj.getTypedValue(value,element.(name));
                            end
                            if~strcmpi(typedValue,string(message('serdes:serdesdesigner:DataTypeConversionError')))

                                body=[];
                                if any(isnan(typedValue(:)))&&(isa(value,'char')||isa(value,'string'))
                                    body=message('serdes:serdesdesigner:NonNumericEntryMessage',value,displayedName);
                                elseif~strcmpi(name,'GPZ')&&~isreal(typedValue)
                                    body=message('serdes:serdesdesigner:NonRealEntryMessage',value,displayedName);
                                elseif isa(element,'serdes.VGA')&&strcmpi(name,'Gain')&&typedValue==0
                                    body=message('serdes:serdesdesigner:ZeroNumericEntryMessage',value,displayedName);
                                elseif isa(element,'serdes.FFE')
                                    if strcmpi(name,'TapWeights')
                                        if~any(typedValue)
                                            body=message('serdes:serdesdesigner:AllZeroEntryMessage',value,displayedName);
                                        elseif~element.Normalize&&any(typedValue>2)
                                            body=message('serdes:serdesdesigner:SettingTapWeightsGreaterThan2WhenNotNormalizedMessage');
                                        end
                                    elseif strcmpi(name,'Normalize')
                                        if~typedValue&&any(element.TapWeights>2)
                                            body=message('serdes:serdesdesigner:UncheckingNormalizeWhenTapWeightsGreaterThan2Message');
                                        end
                                    end
                                elseif isa(element,'serdes.CTLE')
                                    if strcmpi(name,'Mode')
                                        obj.layoutUIControls();
                                    elseif strcmpi(name,'PeakingFrequency')
                                        sys=obj.Parent.View.SerdesDesignerTool.Model.SerdesDesign;
                                        lowerLimit=1/sys.SymbolTime/2/10000;
                                        upperLimit=sys.SamplesPerSymbol/sys.SymbolTime;
                                        if min(typedValue)<=lowerLimit||max(typedValue)>=upperLimit
                                            body=message('serdes:serdesdesigner:OutOfRangeEntryMessage2',displayedValue,displayedName,...
                                            serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(lowerLimit/1e9),...
                                            serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(upperLimit/1e9));
                                        end
                                    elseif strcmpi(name,'DCGain')&&strcmpi(element.Specification,'DC Gain and AC Gain')
                                        if~obj.isMismatchedAcDcPeakingGainEtc&&~isempty(typedValue)&&...
                                            (length(typedValue)==1||length(element.ACGain)==1||length(typedValue)==length(element.ACGain))&&...
                                            any(abs(element.ACGain-typedValue)>40)
                                            body=message('serdes:serdessystem:PeakingGainImpliedMustBeLessThan40dB');
                                        end
                                    elseif strcmpi(name,'ACGain')&&strcmpi(element.Specification,'DC Gain and AC Gain')
                                        if~obj.isMismatchedAcDcPeakingGainEtc&&~isempty(typedValue)&&...
                                            (length(typedValue)==1||length(element.DCGain)==1||length(typedValue)==length(element.DCGain))&&...
                                            any(abs(typedValue-element.DCGain)>40)
                                            body=message('serdes:serdessystem:PeakingGainImpliedMustBeLessThan40dB');
                                        end
                                    elseif strcmpi(name,'PeakingGain')&&(strcmpi(element.Specification,'DC Gain and Peaking Gain')||...
                                        strcmpi(element.Specification,'AC Gain and Peaking Gain'))
                                        if~isempty(typedValue)&&any(typedValue>40)
                                            body=message('serdes:serdessystem:PeakingGainMustBeLessThan40dB');
                                        end
                                    end
                                elseif isa(element,'serdes.internal.apps.serdesdesigner.channel')&&strcmpi(name,'TargetFrequency')
                                    sys=obj.Parent.View.SerdesDesignerTool.Model.SerdesDesign;
                                    upperLimit=sys.SamplesPerSymbol/sys.SymbolTime;
                                    if max(typedValue)>=upperLimit
                                        body=message('serdes:serdesdesigner:TooLargeEntryMessage',displayedValue,displayedName,...
                                        serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(upperLimit/1e9));
                                    end
                                elseif isa(element,'serdes.internal.apps.serdesdesigner.channel')&&strcmpi(name,'ImpulseSampleInterval')
                                    sys=obj.Parent.View.SerdesDesignerTool.Model.SerdesDesign;
                                    impulseResponse=obj.NonSerdesElement.ImpulseResponse;
                                    if obj.NonSerdesElement.isWorkspaceVariable(impulseResponse)
                                        impulseResponse=obj.NonSerdesElement.getWorkspaceVariableValue('ImpulseResponse');
                                    end
                                    if length(impulseResponse)*typedValue/(sys.SymbolTime/sys.SamplesPerSymbol)/sys.SamplesPerSymbol>=1e6
                                        maxValue=1e6/length(impulseResponse)*(sys.SymbolTime/sys.SamplesPerSymbol)*sys.SamplesPerSymbol;
                                        body=message('serdes:serdesdesigner:TooLargeEntryMessage',displayedValue,displayedName,...
                                        ['~ ',serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(maxValue)]);
                                    end
                                end
                                if~isempty(body)
                                    body=getString(body);
                                else
                                    try

                                        if isempty(amiParameter)||~strcmpi(amiParameter.Format.Name,"List")||...
                                            strcmpi(name,'ConfigSelect')&&isnumeric(typedValue)
                                            if isa(element,'serdes.CTLE')&&strcmpi(name,'GPZ')

                                                k=find(contains(obj.ParameterNames,'myGPZ'));
                                                if k>=1

                                                    element.myGPZ=typedValue;
                                                    element.ParameterValues{k}=typedValue;
                                                    obj.ParameterValues{k}=typedValue;
                                                    if obj.SerdesElement.isWorkspaceVariable(typedValue)

                                                        typedValue=obj.SerdesElement.getWorkspaceVariableValue('myGPZ');
                                                    end
                                                end
                                            else
                                                element.(name)=typedValue;
                                            end
                                        elseif strcmpi(name,'ConfigSelect')
                                            element.(name)=str2double(typedValue);
                                        end
                                        element.ParameterValues{j}=typedValue;
                                        obj.ParameterValues{j}=typedValue;
                                    catch exception
                                        body=exception.message;
                                    end
                                end
                                if~isempty(body)
                                    title=message('serdes:serdesdesigner:BadEntryTitle');
                                    h=errordlg(body,getString(title),'modal');
                                    uiwait(h);
                                    obj.setParameterValues(element.ParameterValues);
                                    return;
                                end
                            end
                            break;
                        end
                    end
                end
            end
            if strcmpi(name,'Specification')||strcmpi(name,'ChannelModel')||strcmpi(name,'XTalkEnabled')||strcmpi(name,'XTalkSpecification')
                obj.layoutUIControls;
            end
            if strcmpi(name,'ACGain')||strcmpi(name,'DCGain')||strcmpi(name,'PeakingGain')||strcmpi(name,'PeakingFrequency')
                obj.setAcDcPeakingGainLabelsEtc();
            end
            if strcmpi(name,'ACGain')||strcmpi(name,'DCGain')||strcmpi(name,'PeakingGain')||strcmpi(name,'PeakingFrequency')||...
                strcmpi(name,'Specification')||strcmpi(name,'GPZ')
                obj.updateConfigSelectWidget();
            end
            if~isempty(obj.SerdesElement)&&isa(obj.SerdesElement,'serdes.DFECDR')&&(strcmpi(name,'TapWeights')||strcmpi(name,'MinimumTap')||strcmpi(name,'MaximumTap'))
                obj.setTapWeightsMinTapMaxTapLabelsEtc();
            end
            if obj.isMismatchedAcDcPeakingGainEtc||obj.isMismatchedTapWeightsMinTapMaxTap
                return;
            end
            if~isempty(obj.SerdesElement)&&isa(obj.SerdesElement,'serdes.CTLE')
                obj.SerdesElement.setIsLastEdited(obj.Parent.View.SerdesDesignerTool.Model.SerdesDesign.Elements);
            end
            if~isempty(amiParameter)&&strcmpi(amiParameter.Format.Name,"List")
                obj.Parent.notify('ElementParameterChanged',...
                serdes.internal.apps.serdesdesigner.ElementParameterChangedEventData(i,name,actualValue));
            else
                obj.Parent.notify('ElementParameterChanged',...
                serdes.internal.apps.serdesdesigner.ElementParameterChangedEventData(i,name,value));
            end
            drawnow;
            obj.Parent.View.ParametersFig.Visible='off';
            obj.Parent.View.ParametersFig.Visible='on';
        end
        function isUnique=isUniqueName(obj,elements,index,requestedName)%#ok<INUSL>

            isUnique=true;
            if~isempty(elements)&&index>0&&index<=numel(elements)
                for i=1:numel(elements)
                    if i~=index
                        if strcmpi(requestedName,elements{i}.Name)
                            isUnique=false;
                            return;
                        end
                    end
                end
            end
        end
        function setTitle(obj,name)

            switch lower(obj.HeaderDescription)
            case 'analogout'
                obj.Title.Text=obj.HeaderDescription;
            case 'analogin'
                obj.Title.Text=obj.HeaderDescription;
            case 'channel'
                obj.Title.Text=obj.HeaderDescription;
            otherwise
                obj.Title.Text=strcat(name,'   (',obj.HeaderDescription,')');
            end
        end


        function addListeners(obj)
            obj.NameEdit.ValueChangedFcn=@(h,e)parameterChanged(obj,e);
            if~isempty(obj.ParameterEdits)
                for i=1:numel(obj.ParameterEdits)
                    if strcmpi(obj.ParameterEdits{i}.Type,'uicheckbox')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uidropdown')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uieditfield')
                        obj.ParameterEdits{i}.ValueChangedFcn=@(h,e)parameterChanged(obj,e);
                    elseif strcmpi(obj.ParameterEdits{i}.Type,'uibutton')
                        value=obj.ParameterEdits{i}.UserData;
                        if endsWith(obj.ParameterEdits{i}.Tag,':SparameterButton')
                            obj.ParameterEdits{i}.ButtonPushedFcn=@(h,e)sParameterFitterWrapper(obj,e,value);
                        else

                            obj.ParameterEdits{i}.ButtonPushedFcn=@(h,e)ButtonAppWrapper(obj,e,value);
                        end
                    end
                end
            end
        end
        function removeListeners(obj)
            obj.NameEdit.ValueChangedFcn='';
            if~isempty(obj.ParameterEdits)
                for i=1:numel(obj.ParameterEdits)
                    if strcmpi(obj.ParameterEdits{i}.Type,'uicheckbox')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uidropdown')||...
                        strcmpi(obj.ParameterEdits{i}.Type,'uieditfield')
                        obj.ParameterEdits{i}.ValueChangedFcn='';
                    elseif strcmpi(obj.ParameterEdits{i}.Type,'uibutton')
                        obj.ParameterEdits{i}.ButtonPushedFcn='';
                    end
                end
            end
        end

        function sParameterFitterWrapper(obj,varargin)



            fh=str2func(varargin{2});


            txRIndex=find(strcmp(obj.Parent.RcTxDialog.ParameterNames,'R'));
            txCIndex=find(strcmp(obj.Parent.RcTxDialog.ParameterNames,'C'));
            txVIndex=find(strcmp(obj.Parent.RcTxDialog.ParameterNames,'Voltage'));
            txRTIndex=find(strcmp(obj.Parent.RcTxDialog.ParameterNames,'RiseTime'));
            rxRIndex=find(strcmp(obj.Parent.RcRxDialog.ParameterNames,'R'));
            rxCIndex=find(strcmp(obj.Parent.RcRxDialog.ParameterNames,'C'));

            txRValue=obj.Parent.RcTxDialog.ParameterValues{txRIndex(1)};
            txCValue=obj.Parent.RcTxDialog.ParameterValues{txCIndex(1)};
            txVValue=obj.Parent.RcTxDialog.ParameterValues{txVIndex(1)};
            txRTValue=obj.Parent.RcTxDialog.ParameterValues{txRTIndex(1)};
            rxRValue=obj.Parent.RcRxDialog.ParameterValues{rxRIndex(1)};
            rxCValue=obj.Parent.RcRxDialog.ParameterValues{rxCIndex(1)};




            SystemDt=1e-12*str2double(obj.Parent.View.Toolstrip.SymbolTimeEdit.Value)...
            /str2double(obj.Parent.View.Toolstrip.SamplesPerSymbolDropdown.Value);

            DialogDtIndex=find(strcmpi(obj.Parent.ChannelDialog.ParameterNames,'ImpulseSampleInterval'),1,'first');
            DialogDt=obj.Parent.ChannelDialog.ParameterValues{DialogDtIndex(1)};
            sampleIntervalValue=min(SystemDt,DialogDt);



            try
                if~isempty(obj.sParameterFitHistory)




                    sobjInput=SParameterChannel(...
                    'FileName',obj.sParameterFitHistory.FileName,...
                    'PortOrder',obj.sParameterFitHistory.PortOrderUsed,...
                    'MaxNumberOfPoles',obj.sParameterFitHistory.MaxNumberOfPoles,...
                    'ErrorTolerance',obj.sParameterFitHistory.ErrorTolerance,...
                    'StopTime',obj.sParameterFitHistory.StopTime,...
                    'TxRTFactor',obj.sParameterFitHistory.TxRTFactor,...
                    'AutoDetectPortOrder',obj.sParameterFitHistory.AutoDetectPortOrder,...
...
                    'SampleInterval',sampleIntervalValue,...
                    'Signaling',obj.Parent.View.Toolstrip.SignalingDropdown.Value,...
                    'TxR',txRValue,...
                    'TxC',txCValue,...
                    'TxAmplitude',txVValue,...
                    'TxRiseTime',txRTValue,...
                    'RxR',rxRValue,...
                    'RxC',rxCValue);
                else

                    sobjInput=SParameterChannel(...
                    'SampleInterval',sampleIntervalValue,...
                    'Signaling',obj.Parent.View.Toolstrip.SignalingDropdown.Value,...
                    'TxR',txRValue,...
                    'TxC',txCValue,...
                    'TxAmplitude',txVValue,...
                    'TxRiseTime',txRTValue,...
                    'RxR',rxRValue,...
                    'RxC',rxCValue);
                end
            catch ME

                title=message('MATLAB:license:SERVICES_LMGR_ERROR_CHECKOUT_FAILED');
                body=message('MATLAB:license:SERVICES_LMGR_ERROR_LM_NOFEATURE','RF Toolbox');
                h=errordlg(getString(body),getString(title),'modal');
                uiwait(h);
                return
            end


            fh(sobjInput,obj);

        end

        function ButtonAppWrapper(obj,varargin)



            fh=str2func(varargin{2});


            SymbolTime=str2double(obj.Parent.View.Toolstrip.SymbolTimeEdit.Value);

            try
                if~isempty(obj.CTLEFitHistory)&&...
                    any(strcmp(obj.CTLEFitHistory(:,1),obj.Name))


                    ndx=find(strcmp(obj.CTLEFitHistory(:,1),obj.Name),1,'first');
                    localCTLEFit=obj.CTLEFitHistory{ndx,2};
                    localCTLEFit.pSymbolTime=SymbolTime;
                    localCTLEFit.pBlockName=obj.Name;
                else

                    localCTLEFit=ctlefit;
                    localCTLEFit.pSymbolTime=SymbolTime;
                    localCTLEFit.pBlockName=obj.Name;
                end
            catch ME

                title=message('MATLAB:license:SERVICES_LMGR_ERROR_CHECKOUT_FAILED');
                body=message('MATLAB:license:SERVICES_LMGR_ERROR_LM_NOFEATURE','RF Toolbox');
                h=errordlg(getString(body),getString(title),'modal');
                uiwait(h);
                return
            end


            fh(localCTLEFit,obj);
        end
    end

    methods(Static)

        function areCompatible=areScalarsOrVectorsOfSameLength(values,labels,edits)
            areCompatible=true;
            if~isempty(values)&&numel(values)>1
                params={};
                paramsCount=0;
                for i=1:numel(values)-1
                    for j=(i+1):numel(values)
                        if isvector(values{i})&&isvector(values{j})&&length(values{i})==length(values{j})||...
                            isvector(values{i})&&isscalar(values{j})||...
                            isscalar(values{i})&&isvector(values{j})||...
                            isscalar(values{i})&&isscalar(values{j})
                            continue;
                        else

                            areCompatible=false;
                            if~isempty(labels)&&numel(labels)==numel(values)
                                for k=i:(j-i):j
                                    if all(abs(labels{k}.FontColor-[0,0,0])<0.000001)
                                        labels{k}.FontColor='r';
                                        labels{k}.FontWeight='bold';
                                        paramsCount=paramsCount+1;
                                        params{paramsCount}=serdes.internal.apps.serdesdesigner.BlockDialog.getParamNameOfUIControl(edits{k});%#ok<AGROW> % Get parameter name from uicontrol widget.
                                    end
                                end
                            end
                        end
                    end
                end
                switch paramsCount
                case 0
                    return;
                case 2
                    tooltip=getString(message('serdes:serdesdesigner:AcDcPeakingGainEtcViolation2',params{1},params{2}));
                case 3
                    tooltip=getString(message('serdes:serdesdesigner:AcDcPeakingGainEtcViolation3',params{1},params{2},params{3}));
                otherwise
                    tooltip=getString(message('serdes:serdesdesigner:AcDcPeakingGainEtcViolation'));
                end
                for i=1:numel(labels)
                    if all(abs(labels{i}.FontColor-[1,0,0])<0.000001)
                        edits{i}.Tooltip=tooltip;
                    end
                end
            end
        end


        function name=getParamNameOfUIControl(parameterEdit)
            if~isempty(parameterEdit)&&isprop(parameterEdit,'Tag')
                name=parameterEdit.Tag;
                if~isempty(name)&&contains(name,':')
                    name=extractAfter(name,':');
                end
            else
                name='';
            end
        end


        function value=getParameterValue(rawValue)
            if isempty(rawValue)||ischar(rawValue)||isstring(rawValue)||numel(rawValue)<=1
                value=rawValue;
            else
                try
                    value=mat2str(rawValue);
                catch
                    value='?';
                end
            end
        end


        function value=getTypedValue(sourceValue,destination)
            try

                if islogical(destination)
                    value=serdes.internal.apps.serdesdesigner.BlockDialog.getLogicalValue(sourceValue);
                elseif isinteger(destination)
                    value=serdes.internal.apps.serdesdesigner.BlockDialog.getIntegerValue(sourceValue);
                elseif isnumeric(destination)
                    value=serdes.internal.apps.serdesdesigner.BlockDialog.getNumericValue(sourceValue);
                else
                    value=serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(sourceValue);
                end
            catch
                value=string(message('serdes:serdesdesigner:DataTypeConversionError'));
            end
        end


        function bool=getLogicalValue(value)
            if isempty(value)
                bool=[];
            elseif islogical(value)
                if numel(value)==1
                    bool=value;
                else
                    bool=false;
                end
            elseif isnumeric(value)
                if numel(value)~=1||isnan(value)||(value~=0&&value~=1)
                    bool=false;
                else
                    bool=logical(value);
                end
            elseif strcmpi(value,'true')
                bool=true;
            elseif numel(str2double(value))~=1||strcmpi(value,'false')||isnan(str2double(value))
                bool=false;
            else
                bool=logical(str2double(value));
                if numel(bool)~=1
                    bool=false;
                end
            end
        end


        function int=getIntegerValue(value)
            if isempty(value)
                int=[];
            elseif islogical(value)
                if numel(value)==1
                    int=uint8(value);
                else
                    int=uint8(0);
                end
            elseif isinteger(value)
                if numel(value)==1
                    int=value;
                else
                    int=uint8(0);
                end
            elseif isnumeric(value)&&numel(value)==1
                int=uint8(value);
            elseif strcmpi(value,'true')
                int=uint8(1);
            else
                int=uint8(floor(str2double(value)));
                if numel(int)~=1
                    int=uint8(0);
                end
            end
        end


        function num=getNumericValue(value)
            if isempty(value)
                num=[];
            elseif islogical(value)
                num=double(value);
            elseif isinteger(value)
                num=double(value);
            elseif isnumeric(value)
                num=value;
            elseif ischar(value)||isstring(value)
                try
                    if isstring(value)
                        str=value.lower;
                    else
                        str=convertCharsToStrings(value);
                        str=str.lower;
                    end
                    if str.contains('true')||str.contains('false')
                        num=double(str2num(value));%#ok<ST2NM> 
                    else
                        num=str2num(value);%#ok<ST2NM> % Null/empty if non-numeric.
                    end
                    if isempty(num)
                        num=NaN;
                    end
                catch
                    num=NaN;
                end
            else
                num=NaN;
            end
        end


        function str=getStringValue(value)
            if isempty(value)
                str=value;
            elseif ismatrix(value)&&(islogical(value)||isnumeric(value))
                try
                    str=mat2str(value);
                catch
                    str='?';
                end
            elseif islogical(value)
                str=num2str(value);
            elseif isinteger(value)
                str=num2str(value);
            elseif isnumeric(value)
                str=num2str(value);
            elseif ischar(value)
                str=value;
            elseif isstring(value)&&numel(value)==1
                str=value;
            else
                try
                    str=mat2str(rawValue);
                catch
                    str='?';
                end
            end
        end


        function paramPairs=get_ToggleParamPairs_SE_Diff(element)
            if~isempty(element)
                propNameCandidate='ToggleParamPairs_SE_Diff';
                if isprop(element,propNameCandidate)
                    paramPairs=element.(propNameCandidate);
                    return;
                end
            end
            paramPairs=[];
        end


        function nameInGUI=get_NameInGUI(element,parameterName)
            if~isempty(element)&&~isempty(parameterName)
                propNameCandidate=[parameterName,'_NameInGUI'];
                if isprop(element,propNameCandidate)
                    nameInGUI=element.(propNameCandidate);
                    return;
                end
            end
            nameInGUI=[];
        end


        function toolTip=get_ToolTip(element,parameterName)
            if~isempty(element)&&~isempty(parameterName)
                propNameCandidate=[parameterName,'_ToolTip'];
                if isprop(element,propNameCandidate)
                    toolTip=element.(propNameCandidate);
                    return;
                end
            end
            toolTip=[];
        end


        function stringSet=getStringSet(element,parameterName)
            if~isempty(element)&&~isempty(parameterName)
                propNameCandidate=[parameterName,'Set'];
                if isprop(element,propNameCandidate)
                    if isa(element.(propNameCandidate),'matlab.system.StringSet')
                        stringSet=get(element,propNameCandidate);
                    elseif isa(element.(propNameCandidate),'matlab.system.SourceSet')

                        stringSet=[];
                    else
                        stringSet=element.(propNameCandidate);
                    end
                    return;
                end
            end
            stringSet=[];
        end


        function isNoDisplayInApp=isNoDisplayInSerDesDesignerApp(element,parameterName)
            if~isempty(element)&&~isempty(parameterName)
                propNameCandidate=[parameterName,'Attributes'];
                if isprop(element,propNameCandidate)
                    attributes=get(element,propNameCandidate);
                    if~isempty(attributes)
                        for i=1:numel(attributes)
                            if strcmpi(attributes{i},'NoDisplayInSerDesDesignerApp')
                                isNoDisplayInApp=true;
                                return;
                            end
                        end
                    end
                end
            end
            isNoDisplayInApp=false;
        end


        function canBeSet=hasSetAccess(element,parameterName)
            if~isempty(element)&&~isempty(parameterName)
                mp=findprop(element,parameterName);
                if~isempty(mp)&&...
                    strcmpi(mp.SetAccess,'public')&&...
                    ~mp.DiscreteState&&...
                    ~mp.ContinuousState&&...
                    ~isInactiveProperty(element,parameterName)
                    canBeSet=true;
                    return;
                end
            end
            canBeSet=false;
        end


        function isSimParam=isSimulationParameter(parameterName,simParameters)
            if~isempty(parameterName)&&~isempty(simParameters)
                for i=1:numel(simParameters)
                    if strcmpi(parameterName,simParameters(i).NodeName)
                        isSimParam=true;
                        return;
                    end
                end
            end
            isSimParam=false;
        end


        function isHidden=isHiddenSeDiffParam(parameterName,toggleParamterPairs,isDifferential)
            if~isempty(parameterName)&&~isempty(toggleParamterPairs)
                for i=1:2:numel(toggleParamterPairs)
                    if strcmpi(parameterName,toggleParamterPairs{i})&&isDifferential||...
                        strcmpi(parameterName,toggleParamterPairs{i+1})&&~isDifferential
                        isHidden=true;
                        return;
                    end
                end
            end
            isHidden=false;
        end


        function isConverted=isConvertedFrequency(element,parmName)
            isConverted=isa(element,'serdes.CTLE')&&...
            strcmpi(parmName,getString(message('serdes:serdesdesigner:CTLEPeakingFrequency_NameInGUI')))||...
            isa(element,'serdes.internal.apps.serdesdesigner.channel')&&...
            strcmpi(parmName,getString(message('serdes:serdesdesigner:TargetFrequency_NameInGUI')));
        end


        function isConverted=isConvertedCapacitance(element,parmName)
            isConverted=(isa(element,'serdes.internal.apps.serdesdesigner.rcRx')||...
            isa(element,'serdes.internal.apps.serdesdesigner.rcTx'))&&...
            strcmpi(parmName,getString(message('serdes:serdesdesigner:C_NameInGUI')));
        end


        function isConverted=isConvertedTime(element,parmName)
            isConverted=isa(element,'serdes.internal.apps.serdesdesigner.rcTx')&&...
            strcmpi(parmName,getString(message('serdes:serdesdesigner:RiseTime_NameInGUI')));
        end


        function strNum=getEngineeringNotationString(number)
            if isempty(number)
                strNum=NaN;
            elseif numel(number)==1
                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(number);
            else
                strNum='[';
                for i=1:numel(number)
                    if i>1
                        strNum=strcat(strNum,{' '});
                    end
                    strNum=strcat(strNum,...
                    serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationStringScalar(number(i)));
                end
                strNum=strcat(strNum,']');
                if iscell(strNum)
                    strNum=strNum{1};
                end
            end
        end
        function strNum=getEngineeringNotationStringScalar(number)
            if~isreal(number)
                strNum=num2str(number);
                return;
            end
            if number==0||isnan(number)||isinf(number)
                exponent=0;
            else
                exponent=floor(log10(abs(number)));
            end
            if exponent<3&&exponent>=-3
                exponent=0;
            else
                while(mod(exponent,3))
                    exponent=exponent-1;
                end
            end
            fraction=number/(10^exponent);
            if(exponent==0)
                strNum=sprintf('%8.5G',fraction);
            else
                strNum=sprintf('%8.5Ge%+.2d',fraction,exponent);
            end
            strNum=strtrim(strNum);
        end


        function strNum=num2strConditional(element,parmName,paramValue)
            if serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedFrequency(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(paramValue*1e-9);
            elseif serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedCapacitance(element,parmName)||...
                serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedTime(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(paramValue*1e12);
            else

                strNum=num2str(paramValue);
            end
        end


        function strNum=mat2strConditional(element,parmName,paramValue)
            if serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedFrequency(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(paramValue*1e-9);
            elseif serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedCapacitance(element,parmName)||...
                serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedTime(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(paramValue*1e12);
            else

                strNum=mat2str(paramValue);
            end
        end


        function strNum=getValueInStoredUnits(element,parmName,paramValue)
            if isempty(paramValue)||isempty(strtrim(paramValue))
                strNum='';
            elseif serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedFrequency(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(str2num(paramValue)*1e9);%#ok<ST2NM> 
            elseif serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedCapacitance(element,parmName)||...
                serdes.internal.apps.serdesdesigner.BlockDialog.isConvertedTime(element,parmName)

                strNum=serdes.internal.apps.serdesdesigner.BlockDialog.getEngineeringNotationString(str2num(paramValue)*1e-12);%#ok<ST2NM> 
            else

                strNum=paramValue;
            end
        end
    end
end





