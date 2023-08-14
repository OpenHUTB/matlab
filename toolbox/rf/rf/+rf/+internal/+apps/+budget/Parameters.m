classdef Parameters<handle





    properties
View
Layout
SystemDialog
        ElementDialog=[]
        AmplifierDialog=[]
        ModulatorDialog=[]
        NportDialog=[]
        RFelementDialog=[]
        FilterDialog=[]
        TxlineDialog=[]
        seriesRLCDialog=[]
        shuntRLCDialog=[]
        AttenuatorDialog=[]
        AntennaDialog=[]
        LCLadderDialog=[]
        PhaseshiftDialog=[]
SelectedStage
        AntennaDialogRx=[]
        MixerIMTDialog=[]
        AntennaDialogTxRx=[]
        PowerAmplifierDialog=[]
    end

    properties(Dependent)
ElementType
    end

    events
SystemParameterChanged
ElementParameterChanged
IconUpdate
DisableCanvas
NameChanged
    end

    methods

        function self=Parameters(view)



            if nargin==0
                view=figure;
            end
            self.View=view;
            self.SystemDialog=self.View.Toolstrip.SystemParameters;
            self.SystemDialog.Parameters=self;
            if self.View.UseAppContainer
                self.Layout=uigridlayout(...
                'Parent',self.View.ParametersFig.Figure,...
                'Scrollable','on',...
                'Tag','parametersLayout',...
                'RowSpacing',3,...
                'ColumnSpacing',0);
            else
                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.View.ParametersFig,...
                'VerticalGap',8,...
                'HorizontalGap',6,...
                'VerticalWeights',[0,1],...
                'HorizontalWeights',1);
            end
        end

        function set.ElementType(self,str)
            str1=class(str);
            switch str1
            case 'char'
                if~isempty(self.ElementDialog)
                    if self.View.UseAppContainer
                        self.ElementDialog.Layout.Visible='off';
                    else
                        self.ElementDialog.Panel.Visible='off';
                        remove(self.Layout,2,1)
                    end
                    self.ElementDialog=[];
                end
                return
            case 'amplifier'
                if isempty(self.AmplifierDialog)
                    self.AmplifierDialog=...
                    rf.internal.apps.budget.AmplifierDialog(self);
                end
                self.ElementDialog=self.AmplifierDialog;
            case 'modulator'
                if isempty(self.ModulatorDialog)
                    self.ModulatorDialog=...
                    rf.internal.apps.budget.ModulatorDialog(self);
                end
                self.ElementDialog=self.ModulatorDialog;
            case 'nport'
                if isempty(self.NportDialog)
                    self.NportDialog=...
                    rf.internal.apps.budget.NportDialog(self);
                end
                self.ElementDialog=self.NportDialog;
            case 'rfelement'
                if isempty(self.RFelementDialog)
                    self.RFelementDialog=...
                    rf.internal.apps.budget.RFelementDialog(self);
                end
                self.ElementDialog=self.RFelementDialog;
            case 'rffilter'
                if isempty(self.FilterDialog)
                    self.FilterDialog=...
                    rf.internal.apps.budget.FilterDialog(self);
                end
                self.ElementDialog=self.FilterDialog;
            case 'txlineMicrostrip'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'microstrip');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Microstrip')
                else
                    self.TxlineDialog.TypePopup.Value=1;
                end
            case 'txlineCoaxial'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'coaxial');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Coaxial')
                else
                    self.TxlineDialog.TypePopup.Value=2;
                end
            case 'txlineCPW'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'cpw');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('CPW')
                else
                    self.TxlineDialog.TypePopup.Value=3;
                end
            case 'txlineTwoWire'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'twowire');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Two Wire')
                else
                    self.TxlineDialog.TypePopup.Value=4;
                end
            case 'txlineParallelPlate'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'parallelplate');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Parallel Plate')
                else
                    self.TxlineDialog.TypePopup.Value=5;
                end
            case 'txlineRLCGLine'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'rlcgline');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('RLCG Line')
                else
                    self.TxlineDialog.TypePopup.Value=6;
                end
            case 'txlineEquationBased'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'equationbased');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Equation Based')
                else
                    self.TxlineDialog.TypePopup.Value=7;
                end
            case 'txlineDelayLossless'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'delaylossless');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Delay Lossless')
                else
                    self.TxlineDialog.TypePopup.Value=8;
                end
            case 'txlineDelayLossy'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'delaylossy');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.TxlineDialog.TypePopup.Value='Delay Lossy';
                    self.setValue('Delay Lossy')
                else
                    self.TxlineDialog.TypePopup.Value=9;
                end
            case 'seriesRLC'
                if isempty(self.seriesRLCDialog)
                    self.seriesRLCDialog=...
                    rf.internal.apps.budget.seriesRLCDialog(self);
                end
                self.ElementDialog=self.seriesRLCDialog;
            case 'shuntRLC'
                if isempty(self.shuntRLCDialog)
                    self.shuntRLCDialog=...
                    rf.internal.apps.budget.shuntRLCDialog(self);
                end
                self.ElementDialog=self.shuntRLCDialog;
            case 'attenuator'
                if isempty(self.AttenuatorDialog)
                    self.AttenuatorDialog=...
                    rf.internal.apps.budget.AttenuatorDialog(self);
                end
                self.ElementDialog=self.AttenuatorDialog;
            case 'rfantenna'
                if strcmpi(str.Type,'Receiver')
                    if isempty(self.AntennaDialogRx)
                        self.AntennaDialogRx=...
                        rf.internal.apps.budget.AntennaDialogRx(self);
                    end
                    self.ElementDialog=self.AntennaDialogRx;
                elseif strcmpi(str.Type,'TransmitReceive')
                    if isempty(self.AntennaDialogTxRx)
                        self.AntennaDialogTxRx=...
                        rf.internal.apps.budget.AntennaDialogTxRx(self);
                    end
                    self.ElementDialog=self.AntennaDialogTxRx;
                else
                    if isempty(self.AntennaDialog)
                        self.AntennaDialog=...
                        rf.internal.apps.budget.AntennaDialog(self);
                    end
                    self.ElementDialog=self.AntennaDialog;
                end
            case 'lcladder'
                if isempty(self.LCLadderDialog)
                    self.LCLadderDialog=...
                    rf.internal.apps.budget.LCLadderDialog(self);
                end
                self.ElementDialog=self.LCLadderDialog;

            case 'phaseshift'
                if isempty(self.PhaseshiftDialog)
                    self.PhaseshiftDialog=...
                    rf.internal.apps.budget.PhaseshiftDialog(self);
                end
                self.ElementDialog=self.PhaseshiftDialog;
            case 'mixerIMT'
                if isempty(self.MixerIMTDialog)
                    self.MixerIMTDialog=...
                    rf.internal.apps.budget.MixerIMTDialog(self);
                end
                self.ElementDialog=self.MixerIMTDialog;
            case 'txlineStripline'
                if isempty(self.TxlineDialog)
                    self.TxlineDialog=...
                    rf.internal.apps.budget.TxlineDialog(self,'Stripline');
                end
                self.ElementDialog=self.TxlineDialog;
                if self.View.UseAppContainer
                    self.setValue('Stripline')
                else
                    self.TxlineDialog.TypePopup.Value=10;
                end
            case 'powerAmplifier'
                if isempty(self.PowerAmplifierDialog)
                    self.PowerAmplifierDialog=...
                    rf.internal.apps.budget.PowerAmplifierDialog(self);
                end
                self.ElementDialog=self.PowerAmplifierDialog;
            end
            if self.View.UseAppContainer
                updateStageNumber(self);
                self.ElementDialog.Panel.Parent=self.Layout;
                self.ElementDialog.Panel.Layout.Row=2;
                self.ElementDialog.Panel.Layout.Column=1;
                self.ElementDialog.Layout.Visible='on';
            else
                add(...
                self.Layout,self.ElementDialog.Panel,...
                2,1,...
                'MinimumWidth',self.ElementDialog.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',self.ElementDialog.Height,...
                'Anchor','North')
                self.ElementDialog.Panel.Visible='on';
            end
        end
        function setValue(self,Value)
            self.TxlineDialog.TypePopup.Value=Value;
            e.EventName='ValueChanged';
            e.Source=self.TxlineDialog.TypePopup;
            e.Source.Tag='TypeDropdown';
            self.TxlineDialog.TypePopup.ValueChangedFcn(self,e);
        end

        function str=get.ElementType(self)
            if isempty(self.ElementDialog)
                str='';
            else
                str=self.ElementDialog.Title.String;
            end
        end

        function UpdatedIMTProperty(self,budget)
            imtM=arrayfun(@(x)isa(x,'mixerIMT'),budget.Elements);
            num=1:numel(budget.Elements);
            idx=num(imtM~=0);

            if isa(self.ElementDialog,'rf.internal.apps.budget.MixerIMTDialog')
                self.ElementDialog.NominalOutputPower=budget.Elements(idx).NominalOutputPower;
            end
        end

        function HBClicked(self)

            enableActions(self.View,false)
            pause(0.1);
            setStatusBarMsg(self.View,...
            'Computing budget using Harmonic Balance Solver... ');
            errorFlag=0;
            if(self.SystemDialog.InputFrequency<self.SystemDialog.SignalBandwidth)...
                &&(self.SystemDialog.InputFrequency>0)
                h=errordlg(...
                ['Solver "Harmonic Balance" requires that the Input Frequency and all the stage output frequencies should be zero or greater than the Signal Bandwidth'],...
                'Error','modal');
                uiwait(h);
                setStatusBarMsg(self.View,'');
                errorFlag=1;
            end
            if~errorFlag
                self.notify('SystemParameterChanged',...
                rf.internal.apps.budget.SystemParameterChangedEventData('Solver','h'));
                enableIP2(self.View.Toolstrip,true);
            end
            enableActions(self.View,true)
        end

        function AutoUpdateToggled(self)


            enableIP2(self.View.Toolstrip,false);
            pause(0.1);
            if self.View.Toolstrip.AutoUpdateCheckbox.Value
                enableActions(self.View,false)
                setStatusBarMsg(self.View,'Computing Harmonic Balance');
                self.notify('SystemParameterChanged',...
                rf.internal.apps.budget.SystemParameterChangedEventData('AutoUpdate',1));
            else
                enableActions(self.View,false)
                self.notify('SystemParameterChanged',...
                rf.internal.apps.budget.SystemParameterChangedEventData('AutoUpdate',0));
            end
            enableActions(self.View,true)
            setStatusBarMsg(self.View,'Completed');
        end

        function updateStageNumber(self)



            p=properties(self.ElementDialog);

            cellfun(@(x)setNumber(self.ElementDialog.(x),self.SelectedStage),p,'UniformOutput',false);


            function setNumber(item,number)
                compClasses={...
                'matlab.ui.control.Label',...
                'matlab.ui.control.EditField',...
                'matlab.ui.control.Image',...
                'matlab.ui.control.DropDown',...
                'matlab.ui.container.Panel',...
                'matlab.ui.control.UIControl',...
                'matlab.ui.control.CheckBox'};
                if any(strcmp(class(item),compClasses))
                    if~isempty(item.UserData)
                        if isa(item.UserData,'struct')
                            if isfield(item.UserData,'Stage')
                                item.UserData.Stage=number;
                            end
                        end
                    end
                end
            end
        end
    end


    methods(Static)

        function addTitle(layout,uic,row,col,h,hspacing,vspacing,UseAppContainer)










            if UseAppContainer
                uic.Parent=layout;
                uic.Layout.Row=row;
                uic.Layout.Column=col;
            else
                add(layout,uic,row,col,...
                'LeftInset',-hspacing,...
                'RightInset',-hspacing,...
                'TopInset',-vspacing,...
                'MinimumHeight',h,...
                'MaximumHeight',h,...
                'Fill','Horizontal')
            end
        end

        function addText(layout,uic,row,col,w,h,UseAppContainer)










            if UseAppContainer
                layout.ColumnWidth(1)={120};
                uic.Parent=layout;
                uic.Layout.Row=row;
                if col==3
                    col=col+2;
                end
                if strcmpi(uic.Tag,'ApplyButton')||strcmpi(uic.Tag,'IconImage')
                    col=col+1;
                end
                if strcmpi(uic.Tag,'FrequencyUnitsDropdown')
                    layout.ColumnWidth(5)={60};
                end
                if numel(col)>1
                    col(end)=col(end)+3;
                end
                uic.Layout.Column=col;
            else
                textInset=5;
                add(layout,uic,row,col,...
                'MinimumWidth',w,...
                'MinimumHeight',h-textInset,...
                'TopInset',textInset)
            end
        end

        function addEdit(layout,uic,row,col,w,h,UseAppContainer)










            if UseAppContainer
                uic.Parent=layout;
                uic.Layout.Row=row;
                col=[col,col+2];
                uic.Layout.Column=col;
            else
                add(layout,uic,row,col,...
                'MinimumWidth',w,...
                'Fill','Horizontal',...
                'MinimumHeight',h)
            end
        end

        function addPopup(layout,uic,row,col,w,h,UseAppContainer)










            if UseAppContainer
                layout.ColumnWidth(5)={'1.5x'};
                uic.Parent=layout;
                uic.Layout.Row=row;
                if col==3
                    col=col+2;
                elseif col==2
                    col=[col,col+2];
                end
                uic.Layout.Column=col;
            else
                popupInset=0;
                add(layout,uic,row,col,...
                'MinimumWidth',w,...
                'Fill','Horizontal',...
                'MinimumHeight',h-popupInset,...
                'TopInset',popupInset)
            end
        end

        function addButton(layout,uic,row,col,w,h,UseAppContainer)










            if UseAppContainer
                uic.Parent=layout;
                uic.Layout.Row=row;
                if strcmpi(uic.Tag,'FileNameButton')
                    col=col+2;
                end
                if strcmpi(uic.Tag,'ApplyButton')
                    col=col+1;
                end
                if strcmpi(uic.Tag,'AntButton')
                    col=[2,4];
                    uic.HorizontalAlignment='center';
                end
                uic.Layout.Column=col;
            else
                popupInset=-2;
                add(layout,uic,row,col,...
                'MinimumWidth',w,...
                'MinimumHeight',h-popupInset,...
                'TopInset',popupInset)
            end
        end
    end

    methods
        function systemParameterInvalid(self,data)



            enableActions(self.View,true);
            if strcmpi(data.Name,'Solver')
                return;
            end
            self.SystemDialog.(data.Name)=data.Value;
        end

        function elementParameterInvalid(self,data)



            self.ElementDialog.(data.Name)=data.Value;
            enableActions(self.View,true);
        end
    end
end





