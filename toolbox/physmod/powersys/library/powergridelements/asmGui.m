function varargout=asmGui(varargin)





















    if nargin==1
        GUIN=varargin{1};
        varargin={};
    elseif nargin==4
        a=varargin{4};
        GUIN=get(a.figure1,'Name');
    end


    gui_Singleton=1;
    gui_State=struct('gui_Name',GUIN,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@asmGui_OpeningFcn,...
    'gui_OutputFcn',@asmGui_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin>1&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end


    function asmGui_OpeningFcn(hObject,~,handles,varargin)

        handles.output=hObject;

        set(handles.figure1,'Name','power_AsynchronousMachineParams')

        guidata(hObject,handles);


        function varargout=asmGui_OutputFcn(~,~,handles)

            varargout{1}=handles.output;


            function New_Callback(~,~,handles)%#ok

                CleanParameters(handles)
                CleanDataSheet(handles)


                function Open_Callback(~,~,handles)%#ok


                    X=which('powergui');
                    SPSroot=X(1:end-10);
                    DefaultFileName=[SPSroot,'AsynchronousMachinePresets'];
                    [FileName,PathName]=uigetfile('*.mat','Get preset motor data from MAT file',DefaultFileName);

                    if ischar(FileName)


                        CleanParameters(handles)
                        CleanDataSheet(handles)
                        load(fullfile(PathName,FileName))

                        if exist('specs','var')

                            if~isempty(specs)


                                set(handles.PresetMotor,'string',FileName);

                                set(handles.Vn,'string',specs.Vn);
                                set(handles.fn,'string',specs.fn);
                                set(handles.Tn,'string',specs.Tn);
                                set(handles.In,'string',specs.In);
                                set(handles.Ns,'string',specs.Ns);
                                set(handles.Nn,'string',specs.Nn);
                                set(handles.IstIn,'string',specs.Ist_In);
                                set(handles.TstTn,'string',specs.Tst_Tn);
                                set(handles.TbrTn,'string',specs.Tbr_Tn);
                                set(handles.pf,'string',specs.pf);

                                set(handles.Download,'Userdata',specs);

                            else

                                set(handles.computeButton,'Enable','off');
                            end

                        end

                        computeButton_Callback([],[],handles);

                    end


                    function SavePresetBank_Callback(~,~,handles)%#ok


                        [FileName,Pathname]=uiputfile('.mat','Save the motor data');


                        if ischar(FileName)
                            specs=EvaluateSpecs(handles);%#ok
                            params=get(handles.computeButton,'Userdata');
                            outspecs=get(handles.NominalParameters,'Userdata');
                            if~isempty(outspecs)
                                specs.Pn=outspecs.Pn;
                            end
                            if isempty(params)||isempty(outspecs)
                                save(fullfile(Pathname,FileName),'specs');
                            else
                                save(fullfile(Pathname,FileName),'specs','params','outspecs')
                            end
                        end


                        function DrawGraph_Callback(hObject,~,~)%#ok

                            switch get(hObject,'Checked')
                            case 'on'
                                set(hObject,'Checked','off');
                            case 'off'
                                set(hObject,'Checked','on');
                            end


                            function DisplayResults_Callback(hObject,~,~)%#ok

                                switch get(hObject,'Checked')
                                case 'on'
                                    set(hObject,'Checked','off');
                                case 'off'
                                    set(hObject,'Checked','on');
                                end


                                function AskMe_Callback(hObject,~,~)%#ok

                                    switch get(hObject,'Checked')
                                    case 'on'
                                        set(hObject,'Checked','off');
                                    case 'off'
                                        set(hObject,'Checked','on');
                                    end




                                    function Vn_Callback(~,~,handles)%#ok

                                        EnableButton(handles)


                                        function fn_Callback(~,~,handles)%#ok

                                            EnableButton(handles)


                                            function In_Callback(~,~,handles)%#ok

                                                EnableButton(handles)


                                                function Tn_Callback(~,~,handles)%#ok

                                                    EnableButton(handles)


                                                    function Ns_Callback(~,~,handles)%#ok

                                                        EnableButton(handles)


                                                        function Nn_Callback(~,~,handles)%#ok

                                                            EnableButton(handles)


                                                            function IstIn_Callback(~,~,handles)%#ok

                                                                EnableButton(handles)


                                                                function TstTn_Callback(~,~,handles)%#ok

                                                                    EnableButton(handles)


                                                                    function TbrTn_Callback(~,~,handles)%#ok

                                                                        EnableButton(handles)


                                                                        function pf_Callback(~,~,handles)%#ok

                                                                            EnableButton(handles)


                                                                            function computeButton_Callback(hObject,eventdata,handles)%#ok



                                                                                switch get(handles.DisplayResults,'Checked')
                                                                                case 'on'
                                                                                    options.DisplayDetails=1;
                                                                                case 'off'
                                                                                    options.DisplayDetails=0;
                                                                                end


                                                                                switch get(handles.DrawGraph,'Checked')
                                                                                case 'on'
                                                                                    options.DrawGraphs=1;
                                                                                case 'off'
                                                                                    options.DrawGraphs=0;
                                                                                end

                                                                                options.units='SI';

                                                                                set(handles.computeButton,'Enable','off');
                                                                                pause(0.1);

                                                                                specs=EvaluateSpecs(handles);


                                                                                try
                                                                                    [params,outspecs,errors]=power_AsynchronousMachineParams_pr(specs,options);%#ok

                                                                                    set(handles.NominalParameters,'string',mat2str([outspecs.Pn,specs.Vn,specs.fn],4));
                                                                                    set(handles.Stator,'string',mat2str([params.Rs,params.Lls],4));
                                                                                    set(handles.Cage1,'string',mat2str([params.Rr1,params.Llr1],4));
                                                                                    set(handles.Cage2,'string',mat2str([params.Rr2,params.Llr2],4));
                                                                                    set(handles.Mutual,'string',mat2str(params.Lm,4));
                                                                                    set(handles.PolePairs,'string',mat2str(outspecs.p,4));
                                                                                    set(handles.computeButton,'Userdata',params);

                                                                                    specs.Pn=outspecs.Pn;
                                                                                    set(handles.Download,'Userdata',specs);
                                                                                    set(handles.NominalParameters,'Userdata',outspecs);

                                                                                    set(handles.Download,'Enable','on');

                                                                                catch ME %#ok

                                                                                    set(handles.computeButton,'Enable','on');
                                                                                    set(handles.Download,'Enable','off');
                                                                                    CleanParameters(handles);
                                                                                    errordlg('The power_AsynchronousMachineParams function failed to compute block parameters for the given data sheet specifications.','Error in power_AsynchronousMachineParams')

                                                                                end


                                                                                function Download_Callback(~,~,handles)%#ok

                                                                                    block=gcb;
                                                                                    if isempty(block)
                                                                                        return
                                                                                    end
                                                                                    switch get_param(block,'MaskType')
                                                                                    case 'Asynchronous Machine'

                                                                                        switch get(handles.AskMe,'Checked')
                                                                                        case 'on'

                                                                                            CurrentCageType=get_param(block,'Rotortype');
                                                                                            switch CurrentCageType
                                                                                            case{'Wound','Squirrel-cage'}
                                                                                                H=questdlg(['The rotor type of selected block is currently set to ''',...
                                                                                                CurrentCageType,...
                                                                                                '''. Do you want power_AsynchronousMachineParams to change this to Double squirrel-cage?'],...
                                                                                                'Apply to selected block question','Yes','No','Yes');
                                                                                                switch H
                                                                                                case 'No'
                                                                                                    return
                                                                                                end
                                                                                            end

                                                                                            switch get_param(block,'PresetModel');
                                                                                            case 'No'
                                                                                            otherwise
                                                                                                H=questdlg(['The selected block is currently using a preset model. ',...
                                                                                                'Do you want power_AsynchronousMachineParams to overwrite this preset model with new block parameters?'],...
                                                                                                'Apply to selected block question','Yes','No','Yes');
                                                                                                switch H
                                                                                                case 'No'
                                                                                                    return
                                                                                                end

                                                                                            end
                                                                                        end

                                                                                        set_param(block,'PresetModel','no');
                                                                                        set_param(block,'Rotortype','Double squirrel-cage');
                                                                                        set_param(block,'NominalParameters',get(handles.NominalParameters,'string'));

                                                                                        Units=get_param(block,'Units');

                                                                                        switch Units

                                                                                        case 'SI'

                                                                                            set_param(block,'Stator',get(handles.Stator,'string'));




                                                                                            set_param(block,'Cage1',get(handles.Cage1,'string'));

                                                                                            set_param(block,'Cage1',get(handles.Cage1,'string'));

                                                                                            set_param(block,'Cage2',get(handles.Cage2,'string'));
                                                                                            set_param(block,'Lm',get(handles.Mutual,'string'));

                                                                                        case 'pu'


                                                                                            params=get(handles.computeButton,'Userdata');
                                                                                            spec=get(handles.Download,'Userdata');
                                                                                            Zb=spec.Vn^2/spec.Pn;
                                                                                            Lb=Zb/(2*pi*spec.fn);
                                                                                            params.Rs=params.Rs/Zb;
                                                                                            params.Rr1=params.Rr1/Zb;
                                                                                            params.Rr2=params.Rr2/Zb;
                                                                                            params.Lls=params.Lls/Lb;
                                                                                            params.Llr1=params.Llr1/Lb;
                                                                                            params.Llr2=params.Llr2/Lb;
                                                                                            params.Lm=params.Lm/Lb;

                                                                                            set_param(block,'Stator',mat2str([params.Rs,params.Lls],4));



                                                                                            set_param(block,'Cage1',mat2str([params.Rr1,params.Llr1],4));

                                                                                            set_param(block,'Cage1',mat2str([params.Rr1,params.Llr1],4));

                                                                                            set_param(block,'Cage2',mat2str([params.Rr2,params.Llr2],4));
                                                                                            set_param(block,'Lm',mat2str(params.Lm,4));
                                                                                        end

                                                                                        switch get_param(gcb,'MechanicalLoad')
                                                                                        case 'Speed w'
                                                                                            set_param(block,'Polepairs',get(handles.PolePairs,'string'));
                                                                                        otherwise

                                                                                            Mechanical=get_param(gcb,'Mechanical');
                                                                                            M=evalin('base',Mechanical);
                                                                                            old_p=M(3);
                                                                                            new_p=eval(get(handles.PolePairs,'string'));

                                                                                            if new_p~=old_p

                                                                                                M(3)=new_p;
                                                                                                NewM=mat2str(M);

                                                                                                switch get(handles.AskMe,'Checked')
                                                                                                case 'on'

                                                                                                    if strcmp(Mechanical,NewM)==0

                                                                                                        H=questdlg(['The Inertia, friction factor,pole pair parameter of selected block is currently set to ''',...
                                                                                                        Mechanical,...
                                                                                                        '''. Do you want power_AsynchronousMachineParams to change this to ',NewM,'?'],...
                                                                                                        'Apply to selected block question','Yes','No','Yes');
                                                                                                        switch H
                                                                                                        case 'No'
                                                                                                            return
                                                                                                        end

                                                                                                    end
                                                                                                end

                                                                                                if strcmp(Mechanical,NewM)==0
                                                                                                    set_param(block,'Mechanical',NewM);
                                                                                                end
                                                                                            end
                                                                                        end

                                                                                    end

                                                                                    function saveSpecToStructureButton_Callback(~,~,handles)%#ok<DEFNU>


                                                                                        spec=struct('Vn',eval(handles.Vn.String),...
                                                                                        'fn',eval(handles.fn.String),...
                                                                                        'In',eval(handles.In.String),...
                                                                                        'Tn',eval(handles.Tn.String),...
                                                                                        'Ns',eval(handles.Ns.String),...
                                                                                        'Nn',eval(handles.Nn.String),...
                                                                                        'Ist_In',eval(handles.IstIn.String),...
                                                                                        'Tst_Tn',eval(handles.TstTn.String),...
                                                                                        'Tbr_Tn',eval(handles.TbrTn.String),...
                                                                                        'pf',eval(handles.pf.String));
                                                                                        assignin('base','spec',spec);evalin('base','spec');


                                                                                        function Closebutton_Callback(hObject,eventdata,handles)%#ok

                                                                                            close(handles.figure1)


                                                                                            function HelpButton_Callback(hObject,eventdata,handles)%#ok

                                                                                                helpview(psbhelp('power_AsynchronousMachineParams'));




                                                                                                function CleanDataSheet(handles)

                                                                                                    set(handles.PresetMotor,'string','');
                                                                                                    set(handles.Vn,'string','0');
                                                                                                    set(handles.fn,'string','0');
                                                                                                    set(handles.Tn,'string','0');
                                                                                                    set(handles.In,'string','0');
                                                                                                    set(handles.Ns,'string','0');
                                                                                                    set(handles.Nn,'string','0');
                                                                                                    set(handles.IstIn,'string','0');
                                                                                                    set(handles.TstTn,'string','0');
                                                                                                    set(handles.TbrTn,'string','0');
                                                                                                    set(handles.pf,'string','0');
                                                                                                    set(handles.Download,'Userdata',[])

                                                                                                    set(handles.computeButton,'Enable','off');


                                                                                                    function CleanParameters(handles)

                                                                                                        set(handles.NominalParameters,'string','');
                                                                                                        set(handles.Stator,'string','');
                                                                                                        set(handles.Cage1,'string','');
                                                                                                        set(handles.Cage2,'string','');
                                                                                                        set(handles.Mutual,'string','')
                                                                                                        set(handles.PolePairs,'string','')
                                                                                                        set(handles.Download,'Enable','off');
                                                                                                        set(handles.computeButton,'Userdata',[]);
                                                                                                        set(handles.NominalParameters,'Userdata',[]);


                                                                                                        function EnableButton(handles)

                                                                                                            set(handles.computeButton,'Enable','on');
                                                                                                            PresetMotor=get(handles.PresetMotor,'string');
                                                                                                            if~isempty(PresetMotor)
                                                                                                                if strcmp(PresetMotor(end),'*')==0
                                                                                                                    PresetMotor(end+1)='*';
                                                                                                                    set(handles.PresetMotor,'string',PresetMotor);
                                                                                                                end
                                                                                                            end




                                                                                                            set(handles.computeButton,'Userdata',[]);
                                                                                                            set(handles.NominalParameters,'Userdata',[]);


                                                                                                            function specs=EvaluateSpecs(handles)

                                                                                                                specs.comment='';
                                                                                                                specs.Pn=[];
                                                                                                                specs.Vn=eval(get(handles.Vn,'string'));
                                                                                                                specs.fn=eval(get(handles.fn,'string'));
                                                                                                                specs.Tn=eval(get(handles.Tn,'string'));
                                                                                                                specs.In=eval(get(handles.In,'string'));
                                                                                                                specs.Ns=eval(get(handles.Ns,'string'));
                                                                                                                specs.Nn=eval(get(handles.Nn,'string'));
                                                                                                                specs.Ist_In=eval(get(handles.IstIn,'string'));
                                                                                                                specs.Tst_Tn=eval(get(handles.TstTn,'string'));
                                                                                                                specs.Tbr_Tn=eval(get(handles.TbrTn,'string'));
                                                                                                                specs.pf=eval(get(handles.pf,'string'));
