function varargout=power_PMSynchronousMachineParamsGUI(varargin)






    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@power_PMSynchronousMachineParamsGUI_OpeningFcn,...
    'gui_OutputFcn',@power_PMSynchronousMachineParamsGUI_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end


    function power_PMSynchronousMachineParamsGUI_OpeningFcn(hObject,eventdata,handles,varargin)


        handles.output=hObject;

        set(handles.figure1,'Name','power_PMSynchronousMachineParams')


        guidata(hObject,handles);


        specifiedConstant_Callback(handles.specifiedConstant,eventdata,handles)
        rotorType_Callback(handles.rotorType,eventdata,handles)

        function varargout=power_PMSynchronousMachineParamsGUI_OutputFcn(hObject,eventdata,handles)%#ok

            varargout{1}=handles.output;




            function backEMF_Callback(hObject,eventdata,handles)%#ok


                EnableButton(handles)

                contents=cellstr(get(hObject,'String'));
                backEMF=contents{get(hObject,'Value')};
                switch backEMF
                case 'Sinusoidal'
                    set(handles.rotorType,'Enable','on');
                    set(handles.rotorType_Text,'Enable','on');
                    rotorType_Callback(handles.rotorType,eventdata,handles);
                case 'Trapezoidal'
                    set(handles.rotorType,'Value',1);
                    rotorType_Callback(handles.rotorType,eventdata,handles);
                    set(handles.Inductance_Mask,'String','Stator phase inductance Ls(H):');
                    set(handles.rotorType,'Enable','off');
                    set(handles.rotorType_Text,'Enable','off');
                end

                function rotorType_Callback(hObject,eventdata,handles)%#ok


                    EnableButton(handles)

                    contents=cellstr(get(hObject,'String'));
                    rotorType=contents{get(hObject,'Value')};

                    switch rotorType

                    case 'Round'

                        set(handles.Inductance_Mask,'String','Armature inductance (H):');

                        set(handles.L,'enable','on');
                        set(handles.Inductance_text,'enable','on');
                        set(handles.Inductance_Symbol,'enable','on');
                        set(handles.Inductance_Units,'enable','on');

                        set(handles.Ld_in,'enable','off');
                        set(handles.Daxis_Text,'enable','off');
                        set(handles.Daxis_Symbol,'enable','off');
                        set(handles.Daxis_Units,'enable','off');

                        set(handles.Lq_in,'enable','off');
                        set(handles.Qaxis_Text,'enable','off');
                        set(handles.Qaxis_Symbol,'enable','off');
                        set(handles.Qaxis_Units,'enable','off');

                    case 'Salient-pole'

                        set(handles.Inductance_Mask,'String','Inductances [ Ld(H) Lq(H) ]:');

                        set(handles.L,'enable','off');
                        set(handles.Inductance_text,'enable','off');
                        set(handles.Inductance_Symbol,'enable','off');
                        set(handles.Inductance_Units,'enable','off');

                        set(handles.Ld_in,'enable','on');
                        set(handles.Daxis_Text,'enable','on');
                        set(handles.Daxis_Symbol,'enable','on');
                        set(handles.Daxis_Units,'enable','on');

                        set(handles.Lq_in,'enable','on');
                        set(handles.Qaxis_Text,'enable','on');
                        set(handles.Qaxis_Symbol,'enable','on');
                        set(handles.Qaxis_Units,'enable','on');

                    end

                    function R_Callback(~,~,handles)%#ok

                        EnableButton(handles)

                        function L_Callback(~,~,handles)%#ok

                            EnableButton(handles)

                            function Ld_in_Callback(hObject,eventdata,handles)%#ok

                                EnableButton(handles)

                                function Lq_in_Callback(hObject,eventdata,handles)%#ok

                                    EnableButton(handles)

                                    function specifiedConstant_Callback(hObject,eventdata,handles)%#ok


                                        EnableButton(handles)

                                        switch get(handles.specifiedConstant,'value')

                                        case 1

                                            set(handles.ke,'enable','on');
                                            set(handles.keUnitsNum,'enable','on');
                                            set(handles.keUnitsDenom,'enable','on');
                                            set(handles.ke_Text,'enable','on');
                                            set(handles.ke_slash,'enable','on');
                                            set(handles.ke_Symbol,'enable','on');

                                            set(handles.kt,'enable','off');
                                            set(handles.ktUnitsNum,'enable','off');
                                            set(handles.ktUnitsDenom,'enable','off');
                                            set(handles.kt_Text,'enable','off');
                                            set(handles.kt_slash,'enable','off');
                                            set(handles.kt_Symbol,'enable','off');

                                            set(handles.ktUnitsNum,'value',1);
                                            set(handles.ktUnitsDenom,'value',1);



                                        case 2

                                            set(handles.ke,'enable','off');
                                            set(handles.keUnitsNum,'enable','off');
                                            set(handles.keUnitsDenom,'enable','off');
                                            set(handles.ke_Text,'enable','off');
                                            set(handles.ke_slash,'enable','off');
                                            set(handles.ke_Symbol,'enable','off');

                                            set(handles.keUnitsNum,'value',1);
                                            set(handles.keUnitsDenom,'value',1);



                                            set(handles.kt,'enable','on');
                                            set(handles.ktUnitsNum,'enable','on');
                                            set(handles.ktUnitsDenom,'enable','on');
                                            set(handles.kt_Text,'enable','on');
                                            set(handles.kt_slash,'enable','on');
                                            set(handles.kt_Symbol,'enable','on');

                                        end

                                        function ke_Callback(~,~,handles)%#ok

                                            EnableButton(handles)

                                            function kt_Callback(~,~,handles)%#ok

                                                EnableButton(handles)

                                                function J_Callback(~,~,handles)%#ok

                                                    EnableButton(handles)

                                                    function F_Callback(~,~,handles)%#ok

                                                        EnableButton(handles)

                                                        function polePairs_Callback(~,~,handles)%#ok

                                                            EnableButton(handles)

                                                            function computeButton_Callback(hObject,eventdata,handles)%#ok


                                                                [specs,Err]=EvaluateSpecs(handles);

                                                                if any(Err)
                                                                    return
                                                                end

                                                                params=power_PMSynchronousMachineParams(specs,'GUI');

                                                                if isempty(params)
                                                                    return
                                                                end

                                                                set(handles.Rs,'string',mat2str(params.Rs,6));

                                                                contents=cellstr(get(handles.rotorType,'String'));

                                                                switch contents{get(handles.rotorType,'Value')}
                                                                case 'Round'
                                                                    set(handles.Inductance_Value,'string',num2str(params.Ls));
                                                                case 'Salient-pole'
                                                                    set(handles.Inductance_Value,'string',mat2str([params.Ld,params.Lq],6));
                                                                end

                                                                set(handles.lambdaOut,'string',mat2str(params.lambda,6));
                                                                set(handles.keOut,'string',mat2str(params.ke,6));
                                                                set(handles.ktOut,'string',mat2str(params.kt,6));
                                                                set(handles.mechanicalOut,'string',mat2str([params.J,params.F,params.p],6));

                                                                set(handles.Download,'Enable','on');

                                                                set(handles.computeButton,'Enable','off');




                                                                function Download_Callback(~,~,handles)%#ok

                                                                    block=gcb;
                                                                    if isempty(block)
                                                                        return
                                                                    end
                                                                    switch get_param(block,'MaskType')

                                                                    case 'Permanent Magnet Synchronous Machine'



                                                                        close_system(block);

                                                                        switch get_param(block,'NbPhases')
                                                                        case '5'
                                                                            H=questdlg('The number of phases of selected block is currently set to 5. Do you want power_PMynchronousMachineParams to change it to 3?',...
                                                                            'Apply to selected block question','Yes','No','Yes');
                                                                            switch H
                                                                            case 'No'
                                                                                return
                                                                            end
                                                                        end



                                                                        set_param(block,'NbPhases','3')
                                                                        set_param(block,'PresetModel','no')


                                                                        contents=cellstr(get(handles.backEMF,'String'));
                                                                        backEMF=contents{get(handles.backEMF,'Value')};
                                                                        set_param(block,'FluxDistribution',backEMF);

                                                                        contents=cellstr(get(handles.rotorType,'String'));
                                                                        rotorType=contents{get(handles.rotorType,'Value')};

                                                                        switch backEMF
                                                                        case 'Sinusoidal'

                                                                            set_param(block,'RotorType',rotorType);
                                                                        end

                                                                        set_param(block,'Resistance',get(handles.Rs,'string'));

                                                                        L=get(handles.Inductance_Value,'string');
                                                                        switch rotorType
                                                                        case 'Round'
                                                                            switch backEMF
                                                                            case 'Sinusoidal'
                                                                                set_param(block,'La',L);
                                                                            case 'Trapezoidal'
                                                                                set_param(block,'Inductance',L);
                                                                            end
                                                                        case 'Salient-pole'
                                                                            set_param(block,'dqInductances',L);
                                                                        end

                                                                        set_param(block,'Mechanical',get(handles.mechanicalOut,'string'));
                                                                        set_param(block,'MachineConstant',0);
                                                                        set_param(block,'Flux',get(handles.lambdaOut,'string'));

                                                                    end

                                                                    function Help_Callback(hObject,eventdata,handles)%#ok

                                                                        helpview(psbhelp('power_PMSynchronousMachineParams'));

                                                                        function Close_Callback(~,~,handles)%#ok

                                                                            close(handles.figure1)




                                                                            function CleanDataSheet(handles)%#ok
































                                                                                function CleanParameters(handles)%#ok










                                                                                    function EnableButton(handles)
                                                                                        set(handles.computeButton,'Enable','on');

                                                                                        function[specs,Err]=EvaluateSpecs(handles)

                                                                                            Err=[];

                                                                                            contents=cellstr(get(handles.rotorType,'String'));
                                                                                            specs.rotorType=contents{get(handles.rotorType,'Value')};

                                                                                            switch specs.rotorType
                                                                                            case 'Round'
                                                                                                [specs.Lab,Err(end+1)]=getvalue(get(handles.L,'string'),'Inductance');
                                                                                            case 'Salient-pole'
                                                                                                [specs.Ld,Err(end+1)]=getvalue(get(handles.Ld_in,'string'),'D-axis inductance');
                                                                                                [specs.Lq,Err(end+1)]=getvalue(get(handles.Lq_in,'string'),'Q-axis inductance');
                                                                                            end

                                                                                            [specs.R,Err(end+1)]=getvalue(get(handles.R,'string'),'Resistance');
                                                                                            [specs.J,Err(end+1)]=getvalue(get(handles.J,'string'),'Inertia');
                                                                                            [specs.F,Err(end+1)]=getvalue(get(handles.F,'string'),'Viscous friction');
                                                                                            [specs.p,Err(end+1)]=getvalue(get(handles.polePairs,'string'),'Pole pairs');

                                                                                            contents=cellstr(get(handles.specifiedConstant,'String'));
                                                                                            specs.suppliedConstant=contents{get(handles.specifiedConstant,'Value')};

                                                                                            contents=cellstr(get(handles.backEMF,'String'));
                                                                                            specs.backEMF=contents{get(handles.backEMF,'Value')};

                                                                                            switch specs.suppliedConstant
                                                                                            case 'Voltage constant'
                                                                                                [specs.k,Err(end+1)]=getvalue(get(handles.ke,'string'),'Voltage constant');

                                                                                                unit1=get(handles.keUnitsNum,'string');
                                                                                                specs.kUnitsNum=unit1{get(handles.keUnitsNum,'value'),1};
                                                                                                unit2=get(handles.keUnitsDenom,'string');
                                                                                                specs.kUnitsDenom=unit2{get(handles.keUnitsDenom,'value'),1};

                                                                                            case 'Torque constant'
                                                                                                [specs.k,Err(end+1)]=getvalue(get(handles.kt,'string'),'Torque constant');

                                                                                                unit1=get(handles.ktUnitsNum,'string');
                                                                                                specs.kUnitsNum=unit1{get(handles.ktUnitsNum,'value'),1};
                                                                                                unit2=get(handles.ktUnitsDenom,'string');
                                                                                                specs.kUnitsDenom=unit2{get(handles.ktUnitsDenom,'value'),1};
                                                                                            end

                                                                                            unit5=get(handles.J_units,'string');
                                                                                            specs.inertiaUnits=unit5{get(handles.J_units,'value'),1};

                                                                                            unit6=get(handles.F_units,'string');
                                                                                            specs.frictionUnits=unit6{get(handles.F_units,'value'),1};


                                                                                            function[Out,Err]=getvalue(In,Info)

                                                                                                Out=[];
                                                                                                Err=false;
                                                                                                try
                                                                                                    Out=evalin('base',In);
                                                                                                catch ME
                                                                                                    Err=true;

                                                                                                    Errmes=ME.message;
                                                                                                    ShowText=[Errmes(1:end-1),char(10),' in ''',Info,''' parameter entry.'];
                                                                                                    errordlg(ShowText,'Error in power_PMSynchronousMachineParams');
                                                                                                    return
                                                                                                end



                                                                                                function ktUnitsDenom_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                    ManageColor(hObject)
                                                                                                    function specifiedConstant_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                        ManageColor(hObject)
                                                                                                        function armatureInductance_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                            ManageColor(hObject)
                                                                                                            function keUnitsDenom_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                ManageColor(hObject)
                                                                                                                function F_units_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                    ManageColor(hObject)
                                                                                                                    function F_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                        ManageColor(hObject)
                                                                                                                        function ktUnitsNum_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                            ManageColor(hObject)
                                                                                                                            function J_units_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                ManageColor(hObject)
                                                                                                                                function keUnitsNum_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                    ManageColor(hObject)
                                                                                                                                    function mechanicalOut_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                        ManageColor(hObject)
                                                                                                                                        function kt_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                            ManageColor(hObject)
                                                                                                                                            function J_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                ManageColor(hObject)
                                                                                                                                                function polePairs_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                    ManageColor(hObject)
                                                                                                                                                    function backEMF_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                        ManageColor(hObject)
                                                                                                                                                        function rotorType_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                            ManageColor(hObject)
                                                                                                                                                            function Ld_in_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                                ManageColor(hObject)
                                                                                                                                                                function Lq_in_CreateFcn(hObject,eventdata,handles)%#ok
                                                                                                                                                                    ManageColor(hObject)

                                                                                                                                                                    function ManageColor(hObject)
                                                                                                                                                                        if ispc&&isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
                                                                                                                                                                            set(hObject,'BackgroundColor','white');
                                                                                                                                                                        end