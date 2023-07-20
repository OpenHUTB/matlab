classdef Model<handle








    properties(Hidden)
Name
Budget
IsChanged
        HB=0;
    end

    properties(Constant,Access=private)
        DefaultInputFrequency=2.1e9
        DefaultAvailableInputPower=-30
        DefaultSignalBandwidth=100e6
        DefaultName='Cascade'
    end

    properties(Access=private)

        MatFilePath='';
    end

    events(Hidden)
NewModel
NewName
ParameterChanged
BandwidthResolutionChanged
SystemParameterInvalid
ElementParameterInvalid
ElementInserted
ElementDeleted
SelectedElement
    end

    methods

        function self=Model(varargin)











            if nargin==1
                initialModel(varargin{1})
            else
                defaultModel(self)
            end
        end
    end

    methods(Hidden)

        function defaultBudget(self)

            self.Budget=rfbudget([],...
            self.DefaultInputFrequency,...
            self.DefaultAvailableInputPower,...
            self.DefaultSignalBandwidth);
            self.Budget.AutoUpdate=false;
        end

        function defaultModel(self)


            self.Name=self.DefaultName;
            defaultBudget(self);
            self.IsChanged=false;
        end

        function forceComputeBudget(self)

            budget=self.Budget;
            changed=false;
            if isempty(budget.InputFrequency)
                budget.InputFrequency=self.DefaultInputFrequency;
                changed=true;
                warning(message('rf:rfbudget:EmptyInputFrequency'))
            elseif~isscalar(budget.InputFrequency)
                budget.InputFrequency=budget.InputFrequency(1);
            end
            if isempty(budget.AvailableInputPower)
                budget.AvailableInputPower=self.DefaultAvailableInputPower;
                changed=true;
                warning(message('rf:rfbudget:EmptyAvailableInputPower'))
            end
            if isempty(budget.SignalBandwidth)
                budget.SignalBandwidth=self.DefaultSignalBandwidth;
                changed=true;
                warning(message('rf:rfbudget:EmptySignalBandwidth'))
            end
            computeBudget(budget)
            self.IsChanged=changed;
        end

        function loadModel(self,matfilepath)

            try
                [~,self.Name,~]=fileparts(matfilepath);

                temp=load(matfilepath,'-mat');

                [isValid,temp]=self.isValidBudgetFile(temp);
                if isValid
                    budget=temp.rfb;
                    if isa(budget,'rf.internal.apps.budget.rfbudget')
                        budget=autoforward(budget);
                    end
                    warning('off','rf:shared:InputPower')
                    self.Budget=clone(budget);
                    warning('on','rf:shared:InputPower')
                    if~(strcmpi(self.Budget.Solver,'HarmonicBalance')&&self.Budget.AutoUpdate)
                        self.Budget.Solver='Friis';
                        self.Budget.AutoUpdate=false;
                        forceComputeBudget(self);
                        self.HB=0;
                    else
                        self.HB=1;
                    end


                    self.MatFilePath=matfilepath;
                else
                    msg=message('rf:rfbudget:BadBudgetFile',matfilepath);
                    error(msg)
                end
            catch err
                ttl=message('rf:rfbudget:LoadFailed');
                h=errordlg(err.message,getString(ttl),'modal');
                uiwait(h)
                defaultModel(self)
            end
        end

        function initialModel(self,arg)



            self.Name=self.DefaultName;
            if ischar(arg)

                [~,~,ext]=fileparts(arg);
                if isempty(ext)
                    filename=[arg,'.mat'];
                else
                    filename=arg;
                end


                loadModel(self,filename);
            else
                if isa(arg,'rfbudget')


                    warning('off','rf:shared:InputPower')
                    self.Budget=clone(arg);
                    warning('on','rf:shared:InputPower')
                elseif isa(arg,'rf.internal.apps.budget.rfbudget')
                    self.Budget=autoforward(arg);
                end
                self.Budget.AutoUpdate=false;
                forceComputeBudget(self)
            end
        end
    end

    methods(Hidden)

        function isCanceled=processBudgetSaving(self,varargin)


            isCanceled=false;
            yes='Yes';
            no='No';
            cancel='Cancel';
            if~isempty(varargin)
                fig=varargin{1};
            else
                fig=[];
            end
            if~isempty(self.Budget.Elements)&&self.IsChanged
                if~isempty(fig)
                    selection=uiconfirm(fig,...
                    'Save current RF Budget Analysis?',...
                    'Save Budget','Options',{yes,no,cancel},...
                    'DefaultOption',1);
                else
                    selection=questdlg(...
                    'Save current RF Budget Analysis?',...
                    'Save Budget',yes,no,cancel,yes);
                end
                if isempty(selection)
                    selection=cancel;
                end
            else
                selection=no;
            end

            switch selection
            case yes
                saveAction(self)
            case no

            case cancel
                isCanceled=true;
            end
        end

        function newPopupActions(self,str,varargin)


            if~isempty(varargin)
                isCanceled=self.processBudgetSaving(varargin{1});
            else
                isCanceled=self.processBudgetSaving();
            end
            if isCanceled
                return;
            end
            defaultModel(self)
            switch str
            case 'Blank canvas'

            case 'Receiver'
                s1=nport('allpass.s2p','RFFilter');
                a1=amplifier('Name','RFAmplifier');
                m=modulator('Name','Demodulator',...
                'LO',2e9,...
                'ConverterType','Down');
                s2=nport('allpass.s2p','IFFilter');
                a2=amplifier('Name','IFAmplifier');
                self.Budget.Elements=[s1,a1,m,s2,a2];
                self.Budget.AvailableInputPower=-70;
                self.Budget.SignalBandwidth=50e6;
                computeBudget(self.Budget)
            case 'Transmitter'
                a1=amplifier('Name','IFAmplifier');
                m=modulator('Name','Modulator',...
                'LO',2e9,...
                'ConverterType','Up');
                s2=nport('allpass.s2p','BandpassFilter');
                a2=amplifier('Name','PowerAmplifier');
                self.Budget.Elements=[a1,m,s2,a2];
                self.Budget.InputFrequency=10e6;
                self.Budget.SignalBandwidth=10e3;
                computeBudget(self.Budget)
            end
            self.IsChanged=false;
            self.MatFilePath='';
            self.notify('NewModel',...
            rf.internal.apps.budget.ModelChangedEventData(self.Name,self.Budget))
            self.HB=0;
        end

        function openAction(self,varargin)


            if~isempty(varargin)
                isCanceled=self.processBudgetSaving(varargin{1});
            else
                isCanceled=self.processBudgetSaving();
            end
            if isCanceled
                return;
            end
            budgetFiles='RF Budget Analysis File';
            allFiles='All Files';
            selectFileTitle='Select File';
            [matfile,pathname]=uigetfile(...
            {'*.mat',[budgetFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,self.MatFilePath);
            wasCanceled=isequal(matfile,0)||...
            isequal(pathname,0);
            if wasCanceled
                return;
            end
            loadModel(self,[pathname,matfile]);
            self.notify('NewModel',...
            rf.internal.apps.budget.ModelChangedEventData(self.Name,self.Budget))
        end

        function matfilepath=getMatFilePath(self)


            if isempty(self.MatFilePath)
                [matfile,pathname]=...
                uiputfile('*.mat','Save budget as',...
                [self.DefaultName,'.mat']);
            else
                [matfile,pathname]=...
                uiputfile('*.mat','Save budget as',self.MatFilePath);
            end
            isCanceled=isequal(matfile,0)||...
            isequal(pathname,0);
            if isCanceled
                matfilepath=0;
            else
                matfilepath=[pathname,matfile];
            end
        end

        function saveAction(self,matfilepath)

            if nargin<2

                if isempty(self.MatFilePath)
                    matfilepath=getMatFilePath(self);
                    if isequal(matfilepath,0)
                        return;
                    end
                else
                    matfilepath=self.MatFilePath;
                end
            end
            try
                warning('off','rf:shared:InputPower')
                rfb=clone(self.Budget);
                warning('on','rf:shared:InputPower')
                rfb.AutoUpdate=true;
                save(matfilepath,'rfb')
                self.IsChanged=false;

                self.MatFilePath=matfilepath;
                [~,name]=fileparts(self.MatFilePath);
                if~strcmp(self.Name,name)
                    self.notify('NewName',...
                    rf.internal.apps.budget.ModelChangedEventData(name,self.Budget))
                end
            catch err
                ttl=message('rf:rfbudget:SaveFailed');
                h=errordlg(err.message,getString(ttl),'modal');
                uiwait(h)
            end
        end

        function savePopupActions(self,str)

            switch str
            case 'Save'
                saveAction(self)
            case 'Save As...'
                matfilepath=getMatFilePath(self);
                if isequal(matfilepath,0)
                    return;
                end
                saveAction(self,matfilepath);
            end
        end

        function exportAction(self)


            warning('off','rf:shared:InputPower')
            rfb=clone(self.Budget);
            warning('on','rf:shared:InputPower')

            wsName='rfb';

            accessVariable='RF Budget';
            labels={['Save ',accessVariable,' Object as:']};

            vars={wsName};

            values={rfb};

            export2wsdlg(labels,vars,values);
        end

        function exportPopupActions(self,str)


            switch str
            case 'MATLAB Workspace'
                exportAction(self)
            case 'MATLAB Script'
                warning('off','rf:shared:InputPower')
                rfb=clone(self.Budget);
                warning('on','rf:shared:InputPower')
                exportScript(rfb);
            case 'RF System'
                exportRFSystem(self.Budget);
            case 'RF Blockset'
                wb=waitbar(0,'Please wait, starting Simulink...');
                waitbar(0.5)
                try
                    exportRFBlockset(self.Budget);
                catch err
                    h=errordlg(err.message,'Error Dialog','modal');
                    uiwait(h)
                    close(wb)
                    return
                end
                close(wb)
            case 'Measurement Testbench'
                wb=waitbar(0,'Please wait, starting Simulink...');
                waitbar(0.5)
                try
                    exportTestbench(self.Budget);
                catch err
                    h=errordlg(err.message,'Error Dialog','modal');
                    uiwait(h)
                    close(wb)
                    return
                end
                close(wb)
            end
        end
    end

    methods(Hidden)

        function systemParameterChanged(self,data)




            b=self.Budget;
            if strcmpi(data.Name,'BandwidthResolution')
                self.notify('BandwidthResolutionChanged',...
                rf.internal.apps.budget.BandwidthResolutionChangedEventData(data.Name,b));
                return;
            end
            if~strcmpi(data.Name,'Solver')
                if~self.Budget.AutoUpdate
                    b.Solver='Friis';
                end
            end
            solverIsHB=strcmpi(self.Budget.Solver,'HarmonicBalance');
            if strcmpi(data.Name,'AutoUpdate')
                if data.Value
                    self.Budget.AutoUpdate=true;
                    data.Name='Solver';
                    data.Value='HarmonicBalance';
                    self.HB=1;
                    solverIsHB=1;
                else
                    self.Budget.AutoUpdate=false;
                    data.Name='Solver';
                    data.Value='Friis';
                    self.HB=0;
                    solverIsHB=0;
                    return
                end
            end
            try
                ant=arrayfun(@(x)isa(x,'rfantenna'),self.Budget.Elements);
                num=1:numel(ant);
                idx=num(ant~=0);
                if any(ant)&&strcmpi(data.Name,'InputFrequency')
                    varType=[];
                    if~isempty(self.Budget.Elements(idx).AntennaDesign)
                        varType='AntennaDesign';
                    else
                        if iscell(self.Budget.Elements(idx).AntennaObject)
                            if~isempty(self.Budget.Elements(idx).AntennaObject)&&...
                                (isa(self.Budget.Elements(idx).AntennaObject{1},'em.Antenna')||...
                                isa(self.Budget.Elements(idx).AntennaObject{2},'em.Antenna'))
                                varType='AntennaObject';
                            end
                        elseif~isempty(self.Budget.Elements(idx).AntennaObject)&&...
                            isa(self.Budget.Elements(idx).AntennaObject,'em.Antenna')
                            varType='AntennaObject';
                        end
                    end
                    if~isempty(varType)
                        if strcmpi(self.Budget.Elements(idx).Type,'TransmitReceive')
                            if~isempty(self.Budget.Elements(idx).(varType){1})
                                self.Budget.Elements(idx).Z(1)=impedance(...
                                self.Budget.Elements(idx).(varType){1},data.Value);
                                self.Budget.Elements(idx).Gain(1)=pattern(...
                                self.Budget.Elements(idx).(varType){1},data.Value,...
                                self.Budget.Elements(idx).DirectionAngles(1),...
                                self.Budget.Elements(idx).DirectionAngles(2));
                            end
                            if~isempty(self.Budget.Elements(idx).(varType){2})
                                self.Budget.Elements(idx).Z(2)=impedance(...
                                self.Budget.Elements(idx).(varType){2},data.Value);
                                self.Budget.Elements(idx).Gain(2)=pattern(...
                                self.Budget.Elements(idx).(varType){2},data.Value,...
                                self.Budget.Elements(idx).DirectionAngles(3),...
                                self.Budget.Elements(idx).DirectionAngles(4));
                            end
                        else
                            self.Budget.Elements(idx).Z=impedance(...
                            self.Budget.Elements(idx).(varType),data.Value);
                            self.Budget.Elements(idx).Gain=pattern(...
                            self.Budget.Elements(idx).(varType),data.Value,...
                            self.Budget.Elements(idx).DirectionAngles(1),...
                            self.Budget.Elements(idx).DirectionAngles(2));
                        end

                    end
                end
                b.(data.Name)=data.Value;
                if~solverIsHB&&self.HB&&~strcmpi(self.Budget.Solver,'HarmonicBalance')
                    self.Budget.Solver='HarmonicBalance';
                    self.Budget.AutoUpdate=true;
                end
                if~self.Budget.AutoUpdate
                    computeBudget(b);
                end
                if isempty(b.Friis.OutputPower)
                    computeBudget(b);
                end
                self.IsChanged=true;
                self.notify('ParameterChanged',...
                rf.internal.apps.budget.ModelChangedEventData(data.Name,b))
            catch me
                h=errordlg(me.message,'Error Dialog','modal');
                uiwait(h)
                self.notify('SystemParameterInvalid',...
                rf.internal.apps.budget.ParameterInvalidEventData(data.Name,b.(data.Name)))
            end
        end

        function elementParameterChanged(self,data)




            b=self.Budget;
            try
                if~strcmpi(data.Name,'Name')
                    solverIsHB=strcmpi(self.Budget.Solver,'HarmonicBalance');
                    warning('off','rf:shared:InputPower')
                    b.Elements(data.Index)=data.Value;
                    warning('on','rf:shared:InputPower')
                    if~solverIsHB&&self.HB&&~strcmpi(self.Budget.Solver,'HarmonicBalance')
                        self.Budget.Solver='HarmonicBalance';
                        self.Budget.AutoUpdate=true;
                    end
                    if~self.Budget.AutoUpdate
                        self.Budget.Solver='Friis';
                        computeBudget(b)
                    end

                    self.IsChanged=true;

                    self.notify('ParameterChanged',...
                    rf.internal.apps.budget.ModelChangedEventData(self.Name,b))
                else
                    b.Elements(data.Index).(data.Name)=data.Value;

                    self.notify('ParameterChanged',...
                    rf.internal.apps.budget.ModelChangedEventData(data.Name,b,data.Index))
                end
            catch me
                h=errordlg(me.message,'Error Dialog','modal');
                uiwait(h)
                self.notify('ElementParameterInvalid',...
                rf.internal.apps.budget.ParameterInvalidEventData(data.Name,...
                b.Elements(data.Index).(data.Name)))
            end
        end

        function insertionRequested(self,data)


            index=data.Index;
            switch data.Type
            case 'amplifier'
                elem=amplifier;
            case 'modulator'
                BW=self.Budget.SignalBandwidth;
                LO=10*BW;
                elem=modulator(...
                'Name','Modulator',...
                'ConverterType','Up',...
                'LO',LO);
            case 'demodulator'
                BW=self.Budget.SignalBandwidth;
                if index==1
                    RF=self.Budget.InputFrequency;
                else
                    RF=self.Budget.OutputFrequency(index-1);
                end
                LO=10*BW;
                if RF>0&&RF-LO<=BW
                    LO=RF;
                end
                elem=modulator(...
                'Name','Demodulator',...
                'ConverterType','Down',...
                'LO',LO);
            case 'nport'
                elem=nport('allpass.s2p');
            case 'rfelement'
                elem=rfelement;
            case 'filter'
                elem=rffilter;
            case 'txline'
                elem=txlineMicrostrip('Name','TransmissionLine');
            case 'seriesRLC'
                elem=seriesRLC;
            case 'shuntRLC'
                elem=shuntRLC;
            case 'Attenuator'
                elem=attenuator;
            case 'RFantenna'
                elem=rfantenna;
            case 'lcladder'
                elem=lcladder('lowpasstee',[1.3324e-5,1.3324e-5],1.1327e-9);
            case 'Phaseshift'
                elem=phaseshift;
            case 'Receiver'
                elem=rfantenna('Type','Receiver');
            case 'MixerIMT'
                elem=mixerIMT;
            case 'TxRxAntenna'
                elem=rfantenna('Type','TransmitReceive');
            case 'PowerAmplifier'
                elem=powerAmplifier;


            end
            solverIsHB=strcmpi(self.Budget.Solver,'HarmonicBalance');
            if strcmpi(class(elem),'rfantenna')&&...
                ~isempty(self.Budget.Elements)



                try





                    warning('off','rf:shared:InputPower')
                    self.Budget.Elements=...
                    [self.Budget.Elements(1:index-1),...
elem...
                    ,self.Budget.Elements(index:end)];
                    warning('on','rf:shared:InputPower')

                catch me
                    h=errordlg(me.message,'Error Dialog','modal');

                    uiwait(h);
                    return;
                end
            else
                warning('off','rf:shared:InputPower')
                self.Budget.Elements=...
                [self.Budget.Elements(1:index-1),...
elem...
                ,self.Budget.Elements(index:end)];
                warning('on','rf:shared:InputPower')
            end
            elem.Listener.Enabled=false;
            if~solverIsHB&&self.HB&&~strcmpi(self.Budget.Solver,'HarmonicBalance')
                self.Budget.Solver='HarmonicBalance';
                self.Budget.AutoUpdate=true;
            end
            if~self.Budget.AutoUpdate
                self.Budget.Solver='Friis';
                computeBudget(self.Budget);
            end
            self.IsChanged=true;
            self.notify('ElementInserted',...
            rf.internal.apps.budget.ModelChangedEventData(...
            self.Name,self.Budget,index))
        end

        function deletionRequested(self,data)



            index=data.Index;
            solverIsHB=strcmpi(self.Budget.Solver,'HarmonicBalance');

            self.Budget.Elements(index).delete
            warning('off','rf:shared:InputPower')
            self.Budget.Elements(index)=[];
            warning('on','rf:shared:InputPower')

            if~solverIsHB&&self.HB&&~strcmpi(self.Budget.Solver,...
                'HarmonicBalance')
                self.Budget.Solver='HarmonicBalance';
                self.Budget.AutoUpdate=true;
            end

            if~self.Budget.AutoUpdate
                self.Budget.Solver='Friis';
                computeBudget(self.Budget);
            end

            self.IsChanged=true;

            self.notify('ElementDeleted',...
            rf.internal.apps.budget.ModelChangedEventData(...
            self.Name,self.Budget,index))
        end

        function elementSelected(self,data)



            index=data.Index;
            elem=self.Budget.Elements(index);
            self.notify('SelectedElement',...
            rf.internal.apps.budget.ElementSelectedEventData(index,elem))
        end
    end

    methods(Static)

        function[isValid,newBudgetStruct]=isValidBudgetFile(budgetStruct)

            if numel(budgetStruct)==1
                f=fields(budgetStruct);
                fName=f{1};
                isValid=(isa(budgetStruct.(fName),'rfbudget')||...
                isa(budgetStruct.(fName),'rf.internal.apps.budget.rfbudget'));
                newBudgetStruct.rfb=budgetStruct.(fName);



            else
                isValid=false;
            end
        end
    end
end







