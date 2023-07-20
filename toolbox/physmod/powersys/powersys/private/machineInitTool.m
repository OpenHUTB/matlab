function varargout=machineInitTool(varargin)















    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_loadflow'));
    end


    if nargin<=2


        CMDLINE=0;
        COMPUTECMDLINE=0;

        if nargout==0&&nargin==2

            if isstruct(varargin{2})
                CMDLINE=1;
                COMPUTECMDLINE=1;
            end
        end

        if nargout==1&&nargin>0

            CMDLINE=1;
            if nargin==2
                COMPUTECMDLINE=1;
            end
        end

        [GUI_is_already_open,~,handles]=InitializePowerguiTools(CMDLINE,varargin,'loadflow','MachineInitGUIxxx');

        if GUI_is_already_open&&CMDLINE==0





            if nargout==1
                varargout{1}=handles.LoadFlowParameters;
            end
            return
        end


        if COMPUTECMDLINE

            if strcmp(varargin{2},'default')
                LoadFlowSolution=ExecuteButton_Callback(handles.figure,[],handles,[]);
            else



                LoadFlowSolution=ExecuteButton_Callback(handles.figure,varargin{2},handles,[]);
            end

        else




            set(handles.figure,'Name',['Powergui Machine Initialization Tool.  model: ',handles.system]);
            set(handles.figure,'Pointer','watch');

            try

                [sps,handles]=UpdateButton_Callback(handles.figure,[],handles,[]);
                handles.LoadFlowParameters=sps.LoadFlowParameters;
                guidata(handles.figure,handles);

            catch ME

                set(handles.figure,'Pointer','arrow');
                set(handles.listboxResults,'string',{'There is an error in your model that forced';'the tool to stop prematurely.'});

                msg=ME.message;
                Erreur.msg=msg;
                Erreur.identifier='SpecializedPowerSystems:MachineLoadFlow:ErrorInTheModel';
                psberror(Erreur.msg,Erreur.identifier,'no-uiwait');

                set(handles.editParameter4,'visible','off');
                set(handles.UpdateButton,'visible','off');
                set(handles.BusTypePopup,'visible','off');
                set(handles.editParameter3,'visible','off');
                set(handles.editParameter2,'visible','off');
                set(handles.editParameter1,'visible','off');
                set(handles.FrequencyPopup,'visible','off');
                set(handles.StartFromPreviousCheck,'visible','off');
                set(handles.ExecuteButton,'visible','off');
                set(handles.textParameter3,'visible','off');
                set(handles.textParameter4,'visible','off');
                set(handles.textParameter2,'visible','off');
                set(handles.textParameter1,'visible','off');
                set(handles.textBusType,'visible','off');
                set(handles.listboxMachines,'visible','off');
                set(handles.text18,'visible','off');
                set(handles.text10,'visible','off');
                set(handles.text6,'visible','off');
                set(handles.text7,'visible','off');

                return

            end

        end

        set(handles.figure,'Pointer','arrow');

        if nargout==1
            if COMPUTECMDLINE
                varargout{1}=LoadFlowSolution;
            else
                varargout{1}=handles.LoadFlowParameters;
            end
        end


    elseif ischar(varargin{1})

        try
            [varargout{1:nargout}]=feval(varargin{:});
        catch ME
            rethrow(ME);
        end
    end


    function varargout=UpdateButton_Callback(h,eventdata,handles,varargin)%#ok



        if VerifyIfAcceleratorMode(handles.system,'update circuit and measurements')
            if nargout==1
                varargout{1}=[];
            end
            if nargout==2
                sps.LoadFlowParameters=[];
                varargout{1}=sps;
                varargout{2}=handles;
            end
            return
        end

        set(handles.figure,'Pointer','watch');


        sps=power_analyze(handles.system,'detailed');

        NbMachines=length(sps.LoadFlowParameters);

        if NbMachines==0
            set(handles.figure,'Pointer','arrow');
            texte={'There are no machine blocks';'in the model.'};
            set(handles.listboxResults,'String',texte);
            set(handles.listboxMachines,'String','');
            set(handles.BusTypePopup,'enable','off');
            set(handles.editParameter1,'enable','off');
            set(handles.editParameter2,'enable','off');
            set(handles.editParameter3,'enable','off');
            set(handles.editParameter4,'enable','off');
            set(handles.ExecuteButton,'enable','off');
            set(handles.FrequencyPopup,'enable','off');
            set(handles.StartFromPreviousCheck,'enable','off');
            if nargout==1
                varargout{1}=sps;
            elseif nargout==2
                varargout{1}=sps;
                varargout{2}=handles;
            end
            return
        else
            set(handles.ExecuteButton,'enable','on');
            set(handles.FrequencyPopup,'enable','on');
            set(handles.StartFromPreviousCheck,'enable','on');
        end


        texte=mat2str(sps.freq);
        if~isempty(findstr(texte,'['))%#ok<FSTR>
            texte=strrep(texte,' ','|');
            texte=strrep(texte,'[','');
            texte=strrep(texte,']','');
        end
        set(handles.FrequencyPopup,'String',texte);



        IndiceFrequence=find(sps.freq==sps.PowerguiInfo.LoadFlowFrequency);
        if isempty(IndiceFrequence)

            IndiceFrequence=1;
            sps.PowerguiInfo.LoadFlowFrequency=sps.freq(IndiceFrequence);
        end
        set(handles.FrequencyPopup,'Value',IndiceFrequence);


        texte=' ';
        for i=1:NbMachines
            texte=str2mat(texte,sprintf('%s',strrep(sps.LoadFlowParameters(i).name,newline,' ')));
        end
        texte(1,:)=[];
        set(handles.listboxMachines,'string',texte,'Value',1);

        handles.LoadFlowParameters=sps.LoadFlowParameters;
        guidata(handles.figure,handles);


        listboxMachines_Callback(h,[],handles,varargin);

        if nargout==1
            varargout{1}=sps;
        else
            LoadFlowSolution=DisplayLoadFlowsolution(handles,sps,'UpdateButton');
            if nargout==2
                varargout{1}=sps;
                handles.Data=LoadFlowSolution;
                varargout{2}=handles;
            end
        end

        set(handles.figure,'Pointer','arrow');


        function varargout=listboxMachines_Callback(h,eventdata,handles,varargin)%#ok



            MachineNo=get(handles.listboxMachines,'Value');
            set(handles.listboxResults,'Value',[]);

            if isempty(handles.LoadFlowParameters)
                set(handles.ExecuteButton,'Enable','off');
                return
            end

            set(handles.ExecuteButton,'Enable','on');

            switch handles.LoadFlowParameters(MachineNo).type

            case 'Asynchronous Machine'

                set(handles.BusTypePopup,'Visible','off');
                set(handles.textBusType,'String','Bus type : Asynchronous machine');
                set(handles.textParameter1,'string','Mechanical power (Watts):','enable','on');
                set(handles.textParameter2,'Enable','off');
                set(handles.textParameter3,'Enable','off');
                set(handles.textParameter4,'Enable','off');
                set(handles.editParameter1,'Enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.MechanicalPower));
                set(handles.editParameter2,'Enable','off','string','X');
                set(handles.editParameter3,'Enable','off','string','X');
                set(handles.editParameter4,'Enable','off','string','X');

            case 'Three Phase Dynamic Load'

                set(handles.BusTypePopup,'value',2,'Visible','off');
                set(handles.textBusType,'String','Bus type : P & Q load');

                BusTypePopup_Callback(h,eventdata,handles,varargin);

            otherwise

                set(handles.textBusType,'String','Bus type :');
                switch handles.LoadFlowParameters(MachineNo).set.BusType
                case 'P & V generator'
                    set(handles.BusTypePopup,'value',1,'Visible','on');
                case 'P & Q generator'
                    set(handles.BusTypePopup,'value',2,'Visible','on');
                case 'Swing bus'
                    set(handles.BusTypePopup,'value',3,'Visible','on');
                end
                BusTypePopup_Callback(h,eventdata,handles,varargin);

            end


            function varargout=BusTypePopup_Callback(h,eventdata,handles,varargin)%#ok



                MachineNo=get(handles.listboxMachines,'Value');

                switch get(handles.BusTypePopup,'Value')

                case 1

                    handles.LoadFlowParameters(MachineNo).set.BusType='P & V generator';
                    NewBusTypeSetting=1;

                    set(handles.textParameter1,'String','Terminal voltage UAB (Vrms):','enable','on');
                    set(handles.textParameter2,'String','Active power (Watts):','enable','on');
                    set(handles.textParameter3,'enable','off');
                    set(handles.textParameter4,'enable','off');
                    set(handles.editParameter1,'Enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.TerminalVoltage));
                    set(handles.editParameter2,'Enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.ActivePower));
                    set(handles.editParameter3,'Enable','off','string','X');
                    set(handles.editParameter4,'Enable','off','string','X');

                case 2

                    handles.LoadFlowParameters(MachineNo).set.BusType='P & Q generator';
                    NewBusTypeSetting=4;

                    set(handles.textParameter1,'String','Terminal voltage UAB (Vrms):','enable','off');
                    set(handles.textParameter2,'String','Active power (Watts):','enable','on');
                    set(handles.textParameter3,'enable','off');
                    set(handles.textParameter4,'enable','on');
                    set(handles.editParameter1,'Enable','off','string','X');
                    set(handles.editParameter2,'Enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.ActivePower));
                    set(handles.editParameter3,'Enable','off','string','X');
                    set(handles.editParameter4,'Enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.ReactivePower));

                case 3

                    handles.LoadFlowParameters(MachineNo).set.BusType='Swing bus';
                    NewBusTypeSetting=2;

                    set(handles.textParameter1,'String','Terminal voltage UAB (Vrms):','enable','on');
                    set(handles.textParameter2,'String','Active power guess (Watts) :','enable','on');
                    set(handles.textParameter3,'string','Phase of UAN voltage (deg) :','enable','on');
                    set(handles.textParameter4,'enable','off');
                    set(handles.editParameter1,'enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.TerminalVoltage));
                    set(handles.editParameter2,'enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.ActivePower));
                    set(handles.editParameter3,'enable','on','string',sprintf('%g',handles.LoadFlowParameters(MachineNo).set.PhaseUan));
                    set(handles.editParameter4,'Enable','off','string','X');

                end


                Block=[handles.system,'/',handles.LoadFlowParameters(MachineNo).name];
                CurrentSetting=eval(get_param(Block,'LoadFlowParameters'));
                CurrentSetting(1)=NewBusTypeSetting;
                set_param(Block,'LoadFlowParameters',mat2str(CurrentSetting));


                guidata(handles.figure,handles);


                function varargout=editParameter1_Callback(h,eventdata,handles,varargin)%#ok


                    try
                        valeur=eval(get(handles.editParameter1,'String'));
                    catch ME %#ok mlint
                        msg=['Error evaluating parameter ''',get(handles.textParameter1,'String'),''' : Undefined function or variable ''',get(handles.editParameter1,'String'),''''];
                        Erreur.msg=msg;
                        Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';
                        psberror(Erreur.msg,Erreur.identifier);
                    end

                    MachineNo=get(handles.listboxMachines,'Value');
                    switch handles.LoadFlowParameters(MachineNo).type
                    case 'Asynchronous Machine'
                        handles.LoadFlowParameters(MachineNo).set.MechanicalPower=valeur;
                        ddx=1;
                    otherwise
                        handles.LoadFlowParameters(MachineNo).set.TerminalVoltage=valeur;
                        ddx=3;
                    end


                    Block=[handles.system,'/',handles.LoadFlowParameters(MachineNo).name];
                    CurrentSetting=eval(get_param(Block,'LoadFlowParameters'));
                    CurrentSetting(ddx)=valeur;
                    set_param(Block,'LoadFlowParameters',mat2str(CurrentSetting));


                    guidata(handles.figure,handles);


                    function varargout=editParameter2_Callback(h,eventdata,handles,varargin)%#ok


                        try
                            valeur=eval(get(handles.editParameter2,'String'));
                        catch ME %#ok mlint
                            msg=['Error evaluating parameter ''',get(handles.textParameter2,'String'),''' : Undefined function or variable ''',get(handles.editParameter1,'String'),''''];
                            Erreur.msg=msg;
                            Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';
                            psberror(Erreur.msg,Erreur.identifier);
                        end

                        MachineNo=get(handles.listboxMachines,'Value');
                        handles.LoadFlowParameters(MachineNo).set.ActivePower=valeur;


                        Block=[handles.system,'/',handles.LoadFlowParameters(MachineNo).name];
                        CurrentSetting=eval(get_param(Block,'LoadFlowParameters'));
                        CurrentSetting(2)=valeur;
                        set_param(Block,'LoadFlowParameters',mat2str(CurrentSetting));


                        guidata(handles.figure,handles);


                        function varargout=editParameter3_Callback(h,eventdata,handles,varargin)%#ok


                            try
                                valeur=eval(get(handles.editParameter3,'String'));
                            catch ME %#ok mlint
                                msg=['Error evaluating parameter ''',get(handles.textParameter3,'String'),''' : Undefined function or variable ''',get(handles.editParameter1,'String'),''''];
                                Erreur.msg=msg;
                                Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';
                                psberror(Erreur.msg,Erreur.identifier);
                            end

                            MachineNo=get(handles.listboxMachines,'Value');
                            handles.LoadFlowParameters(MachineNo).set.PhaseUan=valeur;


                            MachineBlock=[handles.system,'/',handles.LoadFlowParameters(MachineNo).name];
                            CurrentSetting=eval(get_param(MachineBlock,'LoadFlowParameters'));
                            CurrentSetting(4)=valeur;
                            set_param(MachineBlock,'LoadFlowParameters',mat2str(CurrentSetting));


                            guidata(handles.figure,handles);


                            function varargout=editParameter4_Callback(h,eventdata,handles,varargin)%#ok


                                try
                                    valeur=eval(get(handles.editParameter4,'String'));
                                catch ME %#ok mlint
                                    msg=['Error evaluating parameter ''',get(handles.textParameter4,'String'),''' : Undefined function or variable ''',get(handles.editParameter1,'String'),''''];
                                    Erreur.msg=msg;
                                    Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';
                                    psberror(Erreur.msg,Erreur.identifier);
                                end

                                MachineNo=get(handles.listboxMachines,'Value');
                                handles.LoadFlowParameters(MachineNo).set.ReactivePower=valeur;


                                MachineBlock=[handles.system,'/',handles.LoadFlowParameters(MachineNo).name];
                                CurrentSetting=eval(get_param(MachineBlock,'LoadFlowParameters'));
                                CurrentSetting(5)=valeur;
                                set_param(MachineBlock,'LoadFlowParameters',mat2str(CurrentSetting));


                                guidata(handles.figure,handles);


                                function varargout=ExecuteButton_Callback(h,LoadFlowParameters,handles,varargin)



                                    if nargout==1
                                        varargout{1}=[];
                                    end

                                    if VerifyIfAcceleratorMode(handles.system,'update load flow')
                                        return
                                    end


                                    sps=UpdateButton_Callback(h,[],handles,[]);

                                    if~isempty(LoadFlowParameters)



                                        ComputeCMDLN=1;

                                        sps.LoadFlowParameters=LoadFlowParameters;
                                        handles.LoadFlowParameters=LoadFlowParameters;

                                        LoadflowFrequency=LoadFlowParameters(1).LoadFlowFrequency;
                                        if strcmp('Auto',LoadFlowParameters(1).InitialConditions)
                                            UseInitialConditions=0;
                                        else
                                            UseInitialConditions=1;
                                        end
                                        if isfield(LoadFlowParameters,'DisplayWarnings')==0
                                            LoadFlowParameters(1).DisplayWarnings='on';
                                        end
                                        DisplayWarnings=strcmp('on',LoadFlowParameters(1).DisplayWarnings);

                                    else



                                        if isempty(sps.LoadFlowParameters)
                                            return
                                        end
                                        ComputeCMDLN=0;

                                        handles.LoadFlowParameters=sps.LoadFlowParameters;


                                        IndiceFrequence=get(handles.FrequencyPopup,'Value');
                                        LoadflowFrequency=sps.freq(IndiceFrequence);
                                        UseInitialConditions=get(handles.StartFromPreviousCheck,'Value')-1;
                                        DisplayWarnings=1;

                                    end

                                    set(handles.figure,'Pointer','watch');



                                    if~any([sps.machines.bustype]==2)




                                        msg='You  must specify one machine bus type as Swing Bus, or have at least one AC voltage or current source block with frequency equal to the Machine Initialization frequency.';
                                        Erreur.msg=msg;
                                        Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';

                                        VoltageSources=sps.source(:,7)==22;
                                        CurrentSources=sps.source(:,7)==23;

                                        existVoltageSources=any(VoltageSources);
                                        existCurrentSources=any(CurrentSources);

                                        if~existVoltageSources&&~existCurrentSources
                                            psberror(Erreur.msg,Erreur.identifier);
                                            set(handles.figure,'Pointer','arrow');
                                            return
                                        end

                                        if existVoltageSources||existCurrentSources


                                            Frequencies=sps.source([VoltageSources,CurrentSources],6);

                                            if~any(Frequencies==LoadflowFrequency)
                                                psberror(Erreur.msg,Erreur.identifier);
                                                set(handles.figure,'Pointer','arrow');
                                                return
                                            end

                                        end

                                    end


                                    for i=1:length(handles.LoadFlowParameters)
                                        switch handles.LoadFlowParameters(i).type
                                        case{'Simplified Synchronous Machine','Synchronous Machine'}
                                            valeur=handles.LoadFlowParameters(i).set.TerminalVoltage;
                                            if isempty(valeur)
                                                valeur=0;
                                            end
                                            if valeur==0
                                                msg=['The terminal voltage parameter of: ',handles.LoadFlowParameters(i).name,' machine must be different from zero'];
                                                Erreur.msg=msg;
                                                Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:ParameterError';
                                                psberror(Erreur.msg,Erreur.identifier);
                                                set(handles.figure,'Pointer','arrow');
                                                set(h.CloseButton,'Enable','on');
                                                return
                                            end
                                        end
                                    end


                                    sps=powerflow(sps,UseInitialConditions,LoadflowFrequency,handles.figure,DisplayWarnings);

                                    if sps.machines(1).status==0
                                        msg=sprintf('Unable to find machine initial conditions for the parameters you specified in the Machine Initialization tool.\n\nNote that the Load Flow tool of powergui block can also be used to initialize the machine blocks of your model. This tool provides an improved and robust solution with faster convergence than the Machine Initialization tool.');
                                        Erreur.msg=msg;
                                        Erreur.identifier='SpecializedPowerSystems:LoadFlowTool:NoSolution';

                                        if ComputeCMDLN
                                            disp(msg);
                                        else
                                            psberror(Erreur.msg,Erreur.identifier,'NoUIwait');
                                        end
                                    end













                                    LoadFlowSolution=DisplayLoadFlowsolution(handles,sps,'ExecuteButton');


                                    handles.Data=LoadFlowSolution;
                                    guidata(handles.figure,handles);

                                    set(handles.figure,'Pointer','arrow');

                                    if nargout==1
                                        varargout{1}=LoadFlowSolution;
                                    end


                                    function LoadFlowSolution=DisplayLoadFlowsolution(handles,sps,statux)


                                        LoadFlowSolution=[];
                                        ReportMode=strcmp(statux,'Report');

                                        CmdLineMode=strcmp(statux,'CmdLine');

                                        if isempty(sps)
                                            sps=get_param([handles.system,'/powergui/EquivalentModel1'],'UserData');
                                        end

                                        if length(sps.LoadFlowParameters)==0 %#ok<ISMT>

                                            if ReportMode
                                                return
                                            end
                                            if CmdLineMode
                                                LoadFlowSolution='There are no machine blocks supported by the Machine Initialization tool in the model.';
                                                return
                                            end
                                            set(handles.listboxResults,'String',{'There are no machine blocks supported';'by the Machine Initializations tool in the model.'});
                                            if isfield(handles,'BusTypePopup')


                                                set(handles.BusTypePopup,'enable','off');
                                                set(handles.editParameter1,'enable','off');
                                                set(handles.editParameter2,'enable','off');
                                                set(handles.editParameter3,'enable','off');
                                            end

                                            return

                                        end


                                        fi=find(sps.freq==sps.PowerguiInfo.LoadFlowFrequency);
                                        if~CmdLineMode&&~ReportMode
                                            set(handles.FrequencyPopup,'Value',fi(1));
                                        end
                                        if~ReportMode&&~CmdLineMode
                                            FrequencyPopup_Callback(0,[],handles,[]);
                                        end


                                        texte='';


                                        SwingBusTest=length(sps.LoadFlowParameters)==1&~any(sps.source(:,7)==22)&~any(sps.source(:,7)==24);

                                        LoadFlowSolution(1).status=sps.machines.status;
                                        for i=1:length(sps.LoadFlowParameters)

                                            switch sps.LoadFlowParameters(i).type
                                            case 'Asynchronous Machine'
                                                bustype='Asynchronous Machine';
                                            case 'Three Phase Dynamic Load'
                                                bustype='P & Q load';
                                            otherwise
                                                bustype=sps.LoadFlowParameters(i).set.BusType;
                                            end

                                            if SwingBusTest

                                                bustype='Swing generator';
                                                sps.machines(i).bustype=2;
                                            end


                                            output_indice=sps.machines(i).output;
                                            input_indice=sps.machines(i).input;

                                            UAB=abs(sps.yss(output_indice,fi))/sqrt(2);
                                            UABp=angle(sps.yss(output_indice,fi))*180/pi;
                                            UBC=abs(sps.yss(output_indice+1,fi))/sqrt(2);
                                            UBCp=angle(sps.yss(output_indice+1,fi))*180/pi;

                                            if sps.machines(i).terminals==4
                                                U3=abs(sps.yss(output_indice+2,fi))/sqrt(2);
                                                U3p=angle(sps.yss(output_indice+2,fi))*180/pi;
                                            else
                                                U3=abs(sps.yss(output_indice+1,fi)+sps.yss(output_indice,fi))/sqrt(2);
                                                U3p=angle(-sps.yss(output_indice+1,fi)-sps.yss(output_indice,fi))*180/pi;
                                            end

                                            UANp=unwrap((UABp-30)*pi/180)*180/pi;

                                            IA=abs(sps.uss(input_indice,fi))/sqrt(2);
                                            IAp=angle(sps.uss(input_indice,fi))*180/pi;
                                            IB=abs(sps.uss(input_indice+1,fi))/sqrt(2);
                                            IBp=angle(sps.uss(input_indice+1,fi))*180/pi;

                                            if sps.machines(i).terminals==4
                                                I3=abs(sps.uss(input_indice+2,fi))/sqrt(2);
                                                I3p=angle(sps.uss(input_indice+2,fi))*180/pi;
                                            else
                                                I3=abs(sps.uss(input_indice+1,fi)+sps.uss(input_indice,fi))/sqrt(2);
                                                I3p=angle(-sps.uss(input_indice+1,fi)-sps.uss(input_indice,fi))*180/pi;
                                            end


                                            if strcmp(statux,'UpdateButton')||strcmp(statux,'Report')

                                                UIangle=(UANp-IAp)*pi/180;

                                                Rs=sps.machines(i).Pmec;
                                                RPM=sps.machines(i).torque;
                                                P=3*(UAB/sqrt(3))*IA*cos(UIangle);
                                                Q=3*(UAB/sqrt(3))*IA*sin(UIangle);
                                                S=sps.machines(i).slip;
                                                if sps.machines(i).bustype==3
                                                    Pmec=sps.machines(i).Pmec;
                                                    T=(30/pi)*Pmec/((1-S*0.999)*RPM);
                                                else
                                                    Pmec=P+3*(Rs*(IA)^2);
                                                    T=(30/pi)*Pmec/RPM;
                                                end
                                            else

                                                P=sps.machines(i).P;
                                                Q=sps.machines(i).Q;
                                                Pmec=sps.machines(i).Pmec;
                                                T=sps.machines(i).torque;
                                                S=sps.machines(i).slip;
                                            end

                                            EVf=sps.machines(i).Ef;
                                            NominalParameters=sps.machines(i).nominal;

                                            Pbase=NominalParameters{2};
                                            MachineFrequency=NominalParameters{5};
                                            Pn=mat2str(Pbase);
                                            PmecPU=Pmec/Pbase;
                                            pairsofpoles=NominalParameters{4};


                                            Tbase=Pbase/(2*pi*MachineFrequency/pairsofpoles);
                                            TPU=T/Tbase;
                                            unit1='VA';

                                            TensionBase=NominalParameters{3};
                                            CourantBase=Pbase/NominalParameters{3};

                                            if Pbase>1e3
                                                Pn=mat2str(Pbase/1e3);
                                                unit1='kVA';
                                            end

                                            if Pbase>1e6
                                                Pn=mat2str(Pbase/1e6);
                                                unit1='MVA';
                                            end

                                            vn=mat2str(NominalParameters{3});
                                            unit2='V rms';
                                            if TensionBase>1e4
                                                vn=mat2str(TensionBase/1e3);
                                                unit2='kV rms';
                                            end

                                            if TensionBase>1e9
                                                vn=mat2str(TensionBase/1e6);
                                                unit2='MV rms';
                                            end

                                            texte=str2mat(texte,sprintf('Machine:    %s',strrep(sps.machines(i).name,newline,' ')));%#ok<*DSTRMT>

                                            if sps.machines(i).type==35
                                                texte=str2mat(texte,sprintf('Nominal:    %s',[vn,' ',unit2]));
                                            else
                                                texte=str2mat(texte,sprintf('Nominal:    %s',[Pn,' ',unit1,'   ',vn,' ',unit2]));
                                            end

                                            texte=str2mat(texte,sprintf('Bus Type:   %s',bustype));

                                            if sps.machines(i).terminals==3
                                                texte=str2mat(texte,sprintf('Uan phase:  %3.2f%s',UANp,char(176)));
                                            end

                                            LoadFlowSolution(i).Machine=sps.machines(i).name;%#ok<*AGROW>
                                            LoadFlowSolution(i).Nominal=[NominalParameters{2},NominalParameters{3}];
                                            LoadFlowSolution(i).BusType=bustype;
                                            LoadFlowSolution(i).UanPhase=UANp;

                                            if sps.machines(i).terminals==3
                                                texte=str2mat(texte,sprintf('Uab:        %0.5g Vrms [%0.4g pu] %3.2f%1s',UAB,UAB/TensionBase,UABp,char(176)));
                                                texte=str2mat(texte,sprintf('Ubc:        %0.5g Vrms [%0.4g pu] %3.2f%1s',UBC,UBC/TensionBase,UBCp,char(176)));
                                                texte=str2mat(texte,sprintf('Uca:        %0.5g Vrms [%0.4g pu] %3.2f%1s',U3,U3/TensionBase,U3p,char(176)));

                                                LoadFlowSolution(i).Uab=[UAB,UAB/TensionBase,UABp];
                                                LoadFlowSolution(i).Ubc=[UBC,UBC/TensionBase,UBCp];
                                                LoadFlowSolution(i).Uca=[U3,U3/TensionBase,U3p];

                                            else
                                                texte=str2mat(texte,sprintf('Uan:        %0.5g Vrms [%0.4g pu] %3.2f%1s',UAB,UAB*sqrt(3)/TensionBase,UABp,char(176)));
                                                texte=str2mat(texte,sprintf('Ubn:        %0.5g Vrms [%0.4g pu] %3.2f%1s',UBC,UBC*sqrt(3)/TensionBase,UBCp,char(176)));
                                                texte=str2mat(texte,sprintf('Ucn:        %0.5g Vrms [%0.4g pu] %3.2f%1s',U3,U3*sqrt(3)/TensionBase,U3p,char(176)));

                                                LoadFlowSolution(i).Uan=[UAB,UAB*sqrt(3)/TensionBase,UABp];
                                                LoadFlowSolution(i).Ubn=[UBC,UBC*sqrt(3)/TensionBase,UBCp];
                                                LoadFlowSolution(i).Ucn=[U3,U3*sqrt(3)/TensionBase,U3p];

                                            end

                                            switch sps.LoadFlowParameters(i).type
                                            case 'Three Phase Dynamic Load'
                                                texte=str2mat(texte,sprintf('Ia:         %0.5g Arms  %3.2f%1s',IA,IAp,char(176)));
                                                texte=str2mat(texte,sprintf('Ib:         %0.5g Arms  %3.2f%1s',IB,IBp,char(176)));
                                                texte=str2mat(texte,sprintf('Ic:         %0.5g Arms  %3.2f%1s',I3,I3p,char(176)));
                                                LoadFlowSolution(i).Ia=[IA,IAp];
                                                LoadFlowSolution(i).Ib=[IB,IBp];
                                                LoadFlowSolution(i).Ic=[I3,I3p];
                                                texte=str2mat(texte,sprintf('P:          %0.5g W   ',P));
                                                texte=str2mat(texte,sprintf('Q:          %0.5g Vars ',Q));
                                                LoadFlowSolution(i).P=P;
                                                LoadFlowSolution(i).Q=Q;
                                            otherwise
                                                texte=str2mat(texte,sprintf('Ia:         %0.5g Arms [%0.4g pu] %3.2f%1s',IA,IA*sqrt(3)/CourantBase,IAp,char(176)));
                                                texte=str2mat(texte,sprintf('Ib:         %0.5g Arms [%0.4g pu] %3.2f%1s',IB,IB*sqrt(3)/CourantBase,IBp,char(176)));
                                                texte=str2mat(texte,sprintf('Ic:         %0.5g Arms [%0.4g pu] %3.2f%1s',I3,I3*sqrt(3)/CourantBase,I3p,char(176)));
                                                LoadFlowSolution(i).Ia=[IA,IA*sqrt(3)/CourantBase,IAp];
                                                LoadFlowSolution(i).Ib=[IB,IB*sqrt(3)/CourantBase,IBp];
                                                LoadFlowSolution(i).Ic=[I3,I3*sqrt(3)/CourantBase,I3p];
                                                texte=str2mat(texte,sprintf('P:          %0.5g W   [%0.4g pu]',P,P/Pbase));
                                                texte=str2mat(texte,sprintf('Q:          %0.5g Vars   [%0.4g pu]',Q,Q/Pbase));
                                                LoadFlowSolution(i).P=[P,P/Pbase];
                                                LoadFlowSolution(i).Q=[Q,Q/Pbase];
                                                texte=str2mat(texte,sprintf('Pmec:       %0.5g W   [%0.4g pu]',Pmec,PmecPU));
                                                texte=str2mat(texte,sprintf('Torque:     %0.5g N.m   [%0.4g pu]',T,TPU));
                                                LoadFlowSolution(i).Pmec=[Pmec,PmecPU];
                                                LoadFlowSolution(i).Torque=[T,TPU];
                                            end

                                            switch sps.LoadFlowParameters(i).type

                                            case 'Asynchronous Machine'

                                                texte=str2mat(texte,sprintf('slip:       %0.4g ',S));
                                                LoadFlowSolution(i).Slip=S;

                                            otherwise

                                                if NominalParameters{1}==1

                                                    switch sps.LoadFlowParameters(i).type

                                                    case 'Synchronous Machine'

                                                        set_param(sps.circuit,'SimulationCommand','update');
                                                        SM=getSPSmaskvalues([handles.system,'/',sps.machines(i).name],{'SM'});
                                                        Vfd=SM.vfn;
                                                        EVfSI=EVf;
                                                        EVfpu=EVfSI/Vfd;
                                                        texte=str2mat(texte,sprintf('Vf:         %0.5g V   [%0.5g pu]',EVfSI,EVfpu));
                                                        LoadFlowSolution(i).Vf=[EVfSI,EVfpu];

                                                    otherwise
                                                        EVfSI=EVf*NominalParameters{3};
                                                        texte=str2mat(texte,sprintf('E:          %0.5g Vrms   [%0.5g pu]',EVfSI,EVf));
                                                        LoadFlowSolution(i).E=[EVfSI,EVf];

                                                    end

                                                else

                                                    switch sps.LoadFlowParameters(i).type
                                                    case 'Synchronous Machine'
                                                        texte=str2mat(texte,sprintf('Vf:         %0.5g pu',EVf));
                                                        LoadFlowSolution(i).Vf=EVf;
                                                    case 'Simplified Synchronous Machine'
                                                        texte=str2mat(texte,sprintf('E:          %0.5g pu',EVf));
                                                        LoadFlowSolution(i).E=EVf;
                                                    end
                                                end
                                            end
                                            texte=str2mat(texte,' ');

                                        end
                                        if~isempty(texte)
                                            texte(1,:)=[];
                                        end
                                        if~CmdLineMode
                                            set(handles.listboxResults,'String',texte);



                                        end


                                        function varargout=pushbutton1_Callback(h,eventdata,handles,varargin)%#ok

                                            GUIHandles=get_param(handles.block,'UserData');
                                            GUIHandles.loadflow=[];
                                            set_param(handles.block,'UserData',GUIHandles);
                                            closereq;

                                            function varargout=FrequencyPopup_Callback(h,eventdata,handles,varargin)%#ok

                                                i=get(handles.FrequencyPopup,'value');
                                                FrequencyList=get(handles.FrequencyPopup,'string');
                                                LoadFlowFrequency=FrequencyList(i,:);
                                                set_param(handles.block,'frequencyindice',LoadFlowFrequency);

                                                function status=VerifyIfAcceleratorMode(system,Tool)

                                                    SimulationMode=get_param(system,'SimulationMode');
                                                    status=0;
                                                    if strcmp(SimulationMode,'accelerator')
                                                        status=1;
                                                        msg=['You cannot ',Tool,' when the Accelerator mode is selected. ',...
                                                        'You can temporarily set the simulation mode to Normal to use this option. '];
                                                        warndlg(msg,'Powergui tools')
                                                        warning('SpecializedPowerSystems:Powergui:VerifyIfAcceleratorMode',msg)
                                                    end
