classdef SystemParametersSection<handle




    properties
Parent
Parameters
Panel
Layout
        Width=0
        Height=0
    end

    properties(Dependent)
InputFrequency
AvailableInputPower
SignalBandwidth
    end

    properties
Title
InputFrequencyLabel
InputFrequencyEdit
InputFrequencyUnits
AvailableInputPowerLabel
AvailableInputPowerEdit
AvailableInputPowerUnits
SignalBandwidthLabel
SignalBandwidthEdit
SignalBandwidthUnits
SettingsDialog
OKBtn
CancelButton
Note
OldValue
InputFrequencyListener
InputFrequencyUnitsListener
AvailableInputPowerListener
SignalBandwidthListener
SignalBandwidthUnitsListener
    end

    properties(Constant)

        Width1=143-31*ispc-41*ismac
        Width2=75
        Width3=53-4*ispc+17*ismac
    end

    methods


        function self=SystemParametersSection(parent)


            self.Parent=parent;
            createUIControls(self)
            addListeners(self)
        end
    end

    methods


        function freq=get.InputFrequency(self)
            fac=1e3^(self.InputFrequencyUnits.SelectedIndex-1);
            freq=fac*str2double(self.InputFrequencyEdit.Value);
        end

        function set.InputFrequency(self,freq)
            [y,e,u]=engunits(freq);
            i=strcmp(u,{'','k','M','G','T'});
            if any(i)
                self.InputFrequencyEdit.Value=num2str(y);
                self.InputFrequencyUnits.SelectedIndex=find(i);
            elseif e<...
1e-12
                self.InputFrequencyEdit.Value=num2str(freq*1e-12);
                self.InputFrequencyUnits.SelectedIndex=5;
            else
                self.InputFrequencyEdit.Value=num2str(freq);
                self.InputFrequencyUnits.SelectedIndex=1;
            end
        end

        function bw=get.SignalBandwidth(self)
            fac=1e3^(self.SignalBandwidthUnits.SelectedIndex-1);
            bw=fac*str2double(self.SignalBandwidthEdit.Value);
        end

        function set.SignalBandwidth(self,bw)
            [y,e,u]=engunits(bw);
            i=strcmp(u,{'','k','M','G','T'});
            if any(i)
                self.SignalBandwidthEdit.Value=num2str(y);
                self.SignalBandwidthUnits.SelectedIndex=find(i);
            elseif e<...
1e-12
                self.SignalBandwidthEdit.Value=num2str(bw*1e-12);
                self.SignalBandwidthUnits.SelectedIndex=5;
            else
                self.SignalBandwidthEdit.Value=num2str(bw);
                self.SignalBandwidthUnits.SelectedIndex=1;
            end
        end

        function pwr=get.AvailableInputPower(self)
            pwr=str2double(self.AvailableInputPowerEdit.Value);
        end

        function set.AvailableInputPower(self,pwr)
            self.AvailableInputPowerEdit.Value=num2str(pwr);
        end

        function parameterChanged(self,e)


            self.Parameters.View.enableActions(false);
            try
                name=e.Source.Tag;
            catch
                name=e.AffectedObject.Tag;
            end
            switch name
            case 'InputFrequencyUnits'
                name='InputFrequency';
            case 'SignalBandwidthUnits'
                name='SignalBandwidth';
            case 'PlotBandwidthUnits'
                name='BandwidthResolution';
            case 'PlotBandwidth'
                name='BandwidthResolution';
            case 'PlotResolution'
                name='BandwidthResolution';
            end
            if strcmpi(name,'BandwidthResolution')
                b=rfbudget;
                try
                    BW=self.Parameters.View.Toolstrip.PlotBandwidth;
                    Res=self.Parameters.View.Toolstrip.PlotResolution;
                    validateattributes(Res,{'numeric'},...
                    {'nonempty','scalar','nonnan','finite','integer','positive','>',1}...
                    ,...
                    'Resolution');
                    validateattributes(BW,{'numeric'},...
                    {'nonempty','scalar','real','nonnan','finite','positive'}...
                    ,...
                    'Bandwidth');
                    b.SignalBandwidth=BW;
                    InFreq=self.InputFrequency;
                    value=(InFreq-BW/2):BW/Res:(InFreq+BW/2);
                    b.InputFrequency=value;

                    self.Parameters.notify('SystemParameterChanged',...
                    rf.internal.apps.budget.SystemParameterChangedEventData(name,value))
                catch me
                    if strcmpi(e.Source.Tag,'PlotBandwidth')
                        self.Parameters.View.Toolstrip.PlotBandwidthEdit.Value=e.EventData.OldValue;
                    elseif strcmpi(e.Source.Tag,'PlotResolution')
                        self.Parameters.View.Toolstrip.PlotResolutionEdit.Value=e.EventData.OldValue;
                    end
                    h=errordlg(me.message,'Error Dialog','modal');
                    uiwait(h)
                end
            else
                value=self.(name);
                self.Parameters.notify('SystemParameterChanged',...
                rf.internal.apps.budget.SystemParameterChangedEventData(name,value))
                enableIP2(self.Parent,false);
            end
            self.Parameters.View.enableActions(true);
        end
    end

    methods(Access=private)


        function createUIControls(self)


            userData=struct(...
            'Dialog','systemParameters',...
            'Stage',1);
            import matlab.ui.internal.toolstrip.*

            section=self.Parent.AnalysisTab.addSection('System Parameters');
            section.Tag='SystemParameters';
            if self.Parent.UseAppContainer
                labelColumn=addColumn(section,...
                'Width',65,...
                'HorizontalAlignment','right');
            else
                labelColumn=addColumn(section,...
                'HorizontalAlignment','right');
            end
            self.InputFrequencyLabel=Label('Input Frequency');
            self.InputFrequencyLabel.Description='Input frequency to the budget';
            labelColumn.add(...
            self.InputFrequencyLabel);
            labelColumn.Tag='SystemparameterslabelColumnTag';
            self.AvailableInputPowerLabel=Label('Available Input Power');
            self.AvailableInputPowerLabel.Description='Input power to the budget';
            labelColumn.add(...
            self.AvailableInputPowerLabel);
            self.SignalBandwidthLabel=Label('Signal Bandwidth');
            self.SignalBandwidthLabel.Description='Input signal bandwidth to the budget';
            labelColumn.add(...
            self.SignalBandwidthLabel);
            editColumn=addColumn(section,...
            'Width',rf.internal.apps.budget.SystemParametersSection.Width2);
            editColumn.Tag='SystemparameterseditColumnTag';
            self.InputFrequencyEdit=EditField('');
            self.InputFrequencyEdit.Tag='InputFrequency';
            self.InputFrequencyEdit.Description='Input frequency to the budget';
            editColumn.add(...
            self.InputFrequencyEdit);
            self.AvailableInputPowerEdit=EditField('');
            self.AvailableInputPowerEdit.Tag='AvailableInputPower';
            self.AvailableInputPowerEdit.Description='Input power to the budget';
            editColumn.add(...
            self.AvailableInputPowerEdit);
            self.SignalBandwidthEdit=EditField('');
            self.SignalBandwidthEdit.Tag='SignalBandwidth';
            self.SignalBandwidthEdit.Description='Input signal bandwidth to the budget';
            editColumn.add(...
            self.SignalBandwidthEdit);

            UnitsVal=[{'Hz'};{'kHz'};{'MHz'};{'GHz'};{'THz'}];
            if self.Parent.UseAppContainer
                unitsColumn=addColumn(section,...
                'Width',65);
            else
                unitsColumn=addColumn(section);
            end
            unitsColumn.Tag='SystemparametersunitsColumnTag';
            self.InputFrequencyUnits=DropDown();
            self.InputFrequencyUnits.replaceAllItems(UnitsVal);
            self.InputFrequencyUnits.Tag='InputFrequencyUnits';
            unitsColumn.add(...
            self.InputFrequencyUnits);
            self.AvailableInputPowerUnits=Label('dBm');
            self.AvailableInputPowerUnits.Tag='AvailableInputPowerUnits';
            unitsColumn.add(...
            self.AvailableInputPowerUnits);
            self.SignalBandwidthUnits=DropDown();
            self.SignalBandwidthUnits.replaceAllItems(UnitsVal);
            self.SignalBandwidthUnits.Tag='SignalBandwidthUnits';
            unitsColumn.add(...
            self.SignalBandwidthUnits);
        end


        function addListeners(self)


            self.InputFrequencyListener=...
            addlistener(self.InputFrequencyEdit,'ValueChanged',...
            @(h,e)parameterChanged(self,e));
            self.InputFrequencyUnitsListener=...
            addlistener(self.InputFrequencyUnits,'ValueChanged',...
            @(h,e)parameterChanged(self,e));
            self.AvailableInputPowerListener=...
            addlistener(self.AvailableInputPowerEdit,'ValueChanged',...
            @(h,e)parameterChanged(self,e));
            self.SignalBandwidthListener=...
            addlistener(self.SignalBandwidthEdit,'ValueChanged',...
            @(h,e)parameterChanged(self,e));
            self.SignalBandwidthUnitsListener=...
            addlistener(self.SignalBandwidthUnits,'ValueChanged',...
            @(h,e)parameterChanged(self,e));
        end
    end

    methods

        function enableUIControls(self,val)




            val=logical(val);
            self.InputFrequencyEdit.Enabled=val;
            self.InputFrequencyUnits.Enabled=val;
            self.AvailableInputPowerEdit.Enabled=val;
            self.SignalBandwidthEdit.Enabled=val;
            self.SignalBandwidthUnits.Enabled=val;
        end
    end
end



