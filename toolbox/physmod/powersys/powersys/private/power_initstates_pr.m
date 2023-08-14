function varargout=power_initstates_pr(varargin)







    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_initstates'));
    end


    if nargin<=2

        [GUI_is_already_open,POWERGUI_Handles,handles]=InitializePowerguiTools(nargout,varargin,'initstates',mfilename);
        if GUI_is_already_open==1
            if nargout==1
                varargout{1}=handles.Data;
            end
            return
        end


        set(handles.figure,'Name',['Powergui Initial States Setting Tool.  model: ',handles.system]);



        x0status=get_param(handles.block,'x0status');
        switch x0status
        case 'blocks'
            set(handles.SteadyStateCheck,'Value',0);
            set(handles.ResetButton,'Value',0);
        case 'steady'
            set(handles.SteadyStateCheck,'Value',1);
        case 'zero'
            set(handles.ResetButton,'Value',1);
        end

        handles=EvaluateTheModel(handles,POWERGUI_Handles);
        guidata(handles.figure,handles);


        if~isempty(handles.Data)
            DisplayInitialStates(handles.figure,[],handles,[]);
        end

        if nargout==1
            varargout{1}=handles.Data;
        end

    elseif ischar(varargin{1})

        try
            [varargout{1:nargout}]=feval(varargin{:});
        catch ME
            rethrow(ME);
        end

    end







    function varargout=listbox_Callback(h,eventdata,handles,varargin)%#ok


        Valeur=max(1,get(handles.listbox,'Value'));
        TableStates=get(handles.listbox,'UserData');
        if~isempty(TableStates);
            if Valeur>length(TableStates)

                set(handles.StateValueEdit','string',' ','enable','off');
                return
            end
            Valeur=TableStates(Valeur);
        end
        if isnan(Valeur)
            set(handles.StateValueEdit','string',' ','enable','off');
            return
        end

        DisplayStringFormat=getdisplayformat(handles);

        if~isempty(handles.Data.x0)
            NumberOfStates=size(handles.Data.x0,1);
            if Valeur<=NumberOfStates
                Valeur=sprintf(DisplayStringFormat,handles.Data.x0(Valeur(1)));
                if isfield(handles,'StateValueEdit')

                    ForceToSteadyState=get(handles.SteadyStateCheck,'Value')==1;
                    ForceToZero=get(handles.ResetButton,'Value')==1;
                    if ForceToSteadyState||ForceToZero
                        Enab='off';
                    else
                        Enab='on';
                    end

                    set(handles.StateValueEdit','string',Valeur,'enable',Enab);

                end
            else

                set(handles.StateValueEdit','string',' ','enable','off');
            end
        end






        function varargout=Sort_Callback(h,eventdata,handles,varargin)%#ok


            val=get(handles.SortMenu,'Value');

            DisplayStringFormat=getdisplayformat(handles);

            texte=[];
            Capatexte=[];
            Indtexte=[];

            TableStates=[];
            TableCapa=[NaN;NaN];
            TableInd=[NaN;NaN];

            if isempty(handles.Data.States)&&isempty(handles.Data.DependentStates)
                texte='There is no state variables for this model';
                set(handles.listbox,'string',texte,'UserData',[]);

            else

                NumberOfIndependentStates=length(handles.Data.States);
                NumberOfDependentStates=length(handles.Data.DependentStates);
                FormatedIndependentStates=char(handles.Data.States);
                FormatedDependentStates=char(handles.Data.DependentStates);

                if isequal(val,1)



                    guidata(h,handles);

                    for i=1:NumberOfIndependentStates
                        StateVariableName=FormatedIndependentStates(i,:);
                        if StateVariableName(1)=='U'||StateVariableName(1)=='V'
                            unite=' V';
                            type='Uc';
                        else
                            unite=' A';
                            type='Il';
                        end
                        ligne=sprintf(['%2s   ''%s'' %s  =  ',DisplayStringFormat,'%s'],...
                        num2str(i),type,StateVariableName(4:end),handles.Data.x0(i,1),unite);

                        texte=str2mat(texte,ligne);
                    end
                    texte=texte(2:size(texte,1),:);


                    FullList=0;
                    if NumberOfDependentStates>0
                        if~isempty(handles.Data.x0DependentStates)

                            texte=str2mat(texte,' ','DEPENDENT STATES:',' ');
                            FullList=1;
                        else
                            texte=str2mat(texte,' ','DEPENDENT STATES: (initial values are not computed)',' ');
                        end
                    end

                    for i=1:NumberOfDependentStates
                        StateVariableName=FormatedDependentStates(i,:);
                        if StateVariableName(1)=='U'||StateVariableName(1)=='V'
                            unite=' V';
                            type='Uc';
                        else
                            unite=' A';
                            type='Il';
                        end
                        if FullList
                            ligne=sprintf(['     ''%s'' %s  =  ',DisplayStringFormat,'%s'],...
                            type,StateVariableName(4:end),handles.Data.x0DependentStates(i,1),unite);
                        else
                            ligne=sprintf('     ''%s'' %s',...
                            StateVariableName,type);
                        end
                        texte=str2mat(texte,ligne);
                    end

                    set(handles.listbox,'string',texte,'UserData',[]);

                else



                    guidata(h,handles);

                    for i=1:NumberOfIndependentStates

                        StateVariableName=FormatedIndependentStates(i,:);
                        if StateVariableName(1)=='U'||StateVariableName(1)=='V'
                            ligne=sprintf(['%2s   %s  =  ',DisplayStringFormat,' V'],...
                            num2str(i),StateVariableName(4:end),handles.Data.x0(i,1));
                            Capatexte=str2mat(Capatexte,ligne);
                            TableCapa(end+1)=i;%#ok
                        else
                            ligne=sprintf(['%2s   %s  =  ',DisplayStringFormat,' A'],...
                            num2str(i),StateVariableName(4:end),handles.Data.x0(i,1));
                            Indtexte=str2mat(Indtexte,ligne);
                            TableInd(end+1)=i;%#ok
                        end
                    end

                    if~isempty(Capatexte)
                        texte=str2mat('CAPACITOR VOLTAGES:',Capatexte,' ');
                        TableStates=TableCapa;
                    end
                    if~isempty(Indtexte)
                        texte=strvcat(texte,'INDUCTOR CURRENTS:',Indtexte);%#ok
                        if~isempty(TableStates),
                            TableStates=[TableStates;NaN;TableInd];
                        else
                            TableStates=[TableStates;TableInd];
                        end
                    end


                    FullList=0;
                    if NumberOfDependentStates>0
                        if~isempty(handles.Data.x0DependentStates)

                            texte=str2mat(texte,' ','DEPENDENT STATES:',' ');
                            FullList=1;
                        else
                            texte=str2mat(texte,' ','DEPENDENT STATES: (initial values are not computed)',' ');
                        end
                    end

                    for i=1:NumberOfDependentStates
                        StateVariableName=FormatedDependentStates(i,:);
                        if StateVariableName(1)=='U'||StateVariableName(1)=='V'
                            unite=' V';
                            type='Uc';
                        else
                            unite=' A';
                            type='Il';
                        end
                        if FullList
                            ligne=sprintf(['(%s) %s  =  ',DisplayStringFormat,'%s'],...
                            type,StateVariableName(4:end),handles.Data.x0DependentStates(i,1),unite);
                        else
                            ligne=sprintf('(%s) %s',type,StateVariableName);
                        end
                        texte=str2mat(texte,ligne);
                    end

                    set(handles.listbox,'string',texte,'UserData',TableStates);

                end
            end


            if get(handles.listbox,'Value')>size(texte,1)
                set(handles.listbox,'Value',size(texte,1));
            end

            listbox_Callback(h,eventdata,handles,varargin);





            function varargout=Format_Callback(h,eventdata,handles,varargin)%#ok

                DisplayInitialStates(h,eventdata,handles,varargin);






                function varargout=StateValueEdit_Callback(h,eventdata,handles,varargin)%#ok

                    set(handles.ResetButton,'Value',0);
                    set(handles.SteadyStateCheck,'Value',0);

                    NewValue=evalin('base',get(handles.StateValueEdit,'String'),'0');
                    Position=get(handles.listbox,'Value');
                    TableStates=get(handles.listbox,'UserData');
                    if~isempty(TableStates);
                        Position=TableStates(Position);
                    end
                    if isnan(Position)

                        return
                    end
                    if isempty(handles.Data.x0)
                        return
                    end


                    handles.Data.x0_blocks(Position)=NewValue;


                    for i=1:length(Position)
                        StateName=handles.Data.States{Position(i)};
                        StateNumber=strmatch(StateName,handles.BlockInitialState.state,'exact');
                        if~isempty(StateNumber)



                            handles.BlockInitialState.value{StateNumber}=NewValue;
                            handles.BlockInitialState.NeedUpdate{StateNumber}=1;
                        else



                            StateNumber=strmatch(handles.Data.States{Position(i)},handles.PowerguiInitialState.state,'exact');
                            if~isempty(StateNumber)

                                handles.PowerguiInitialState.value{StateNumber}=NewValue;


                            else


                                handles.PowerguiInitialState.value{end+1}=NewValue;
                                handles.PowerguiInitialState.state{end+1}=StateName;


                            end
                        end
                    end

                    handles.Data.x0=handles.Data.x0_blocks;
                    handles.Data.UseInitialStatesFrom='blocks';
                    guidata(h,handles)
                    set(handles.ApplyButton,'enable','on');


                    DisplayInitialStates(h,eventdata,handles,varargin);













                    function varargout=SteadyStateCheck_Callback(h,eventdata,handles,varargin)%#ok




                        set(handles.ResetButton,'Value',0);

                        if VerifyIfAcceleratorMode(handles.system,'force initial states to steady state');
                            return
                        end
                        set(handles.ApplyButton,'enable','on');

                        if get(handles.SteadyStateCheck,'Value')==1
                            handles.Data.x0=handles.Data.x0_steady;
                            handles.Data.UseInitialStatesFrom='steady';
                            set(handles.StateValueEdit,'enable','off');
                            set(handles.text7,'enable','off');
                        else
                            handles.Data.x0=handles.Data.x0_blocks;
                            handles.Data.UseInitialStatesFrom='blocks';
                            set(handles.StateValueEdit,'enable','on');
                            set(handles.text7,'enable','on');
                        end

                        guidata(h,handles)

                        DisplayInitialStates(h,eventdata,handles,varargin);

                        listbox_Callback(h,[],handles,[]);





                        function varargout=ResetButton_Callback(h,eventdata,handles,varargin)%#ok




                            set(handles.SteadyStateCheck,'Value',0);

                            if VerifyIfAcceleratorMode(handles.system,'force initial states to zero');
                                return
                            end
                            set(handles.ApplyButton,'enable','on');

                            if get(handles.ResetButton,'Value')==1
                                handles.Data.x0=(handles.Data.x0).*0;
                                handles.Data.UseInitialStatesFrom='zero';
                                set(handles.StateValueEdit,'enable','off');
                                set(handles.text7,'enable','off');
                            else
                                handles.Data.x0=handles.Data.x0_blocks;
                                handles.Data.UseInitialStatesFrom='blocks';
                                set(handles.StateValueEdit,'enable','on');
                                set(handles.text7,'enable','on');
                            end

                            guidata(h,handles)

                            DisplayInitialStates(h,eventdata,handles,varargin);

                            listbox_Callback(h,[],handles,[]);







                            function varargout=LoadInitialStates_Callback(h,eventdata,handles,varargin)%#ok

                                [FileName,PathName]=uigetfile({'*.mat'},'Load initial values of states');

                                if ischar(FileName)

                                    x0=[];
                                    try
                                        load([PathName,filesep,FileName]);
                                    catch ME
                                        message='Unrecognized file type. Failed to load initial states';
                                        Erreur.message=message;
                                        Erreur.identifier='SpecializedPowerSystems:Powergui:InitialStatesToolError';
                                        psberror(Erreur.message,Erreur.identifier);
                                        return
                                    end
                                    set(handles.ApplyButton,'enable','on');

                                    x0CurrentSize=length(handles.Data.x0);

                                    if length(x0)~=x0CurrentSize
                                        message=['The number of initial states in ',FileName,' doesn''t match the number of states variables'];
                                        Erreur.message=message;
                                        Erreur.identifier='SpecializedPowerSystems:Powergui:InitialStatesToolError';
                                        psberror(Erreur.message,Erreur.identifier);
                                        return

                                    end

                                    handles.Data.x0=x0;
                                    switch checkboxstatus
                                    case 1
                                        set(handles.SteadyStateCheck,'Value',1);
                                        set(handles.ResetButton,'Value',0);
                                        handles.Data.UseInitialStatesFrom='steady';
                                    case 2
                                        set(handles.SteadyStateCheck,'Value',0);
                                        set(handles.ResetButton,'Value',1);
                                        handles.Data.UseInitialStatesFrom='zero';
                                    case 3
                                        set(handles.SteadyStateCheck,'Value',0);
                                        set(handles.ResetButton,'Value',0);
                                        handles.Data.UseInitialStatesFrom='blocks';
                                    end
                                    if exist('PowerguiInitialState','var')
                                        handles.PowerguiInitialState=PowerguiInitialState;
                                        PowerguiUserData=get_param(handles.block,'userdata');
                                        PowerguiUserData.BlockInitialState=handles.PowerguiInitialState;
                                        set_param(handles.block,'userdata',PowerguiUserData);
                                    end
                                    guidata(h,handles);

                                    DisplayInitialStates(h,eventdata,handles,varargin);

                                end






                                function varargout=UpdateButton_Callback(h,eventdata,handles,varargin)%#ok


                                    if VerifyIfAcceleratorMode(handles.system,'reload states from diagram');
                                        return
                                    end
                                    set(handles.ApplyButton,'enable','on');
                                    set(handles.listbox,'Value',1);
                                    POWERGUI_Handles=get_param(handles.block,'UserData');
                                    set(handles.figure,'Pointer','watch');
                                    handles=EvaluateTheModel(handles,POWERGUI_Handles);
                                    set(handles.figure,'Pointer','arrow');
                                    guidata(h,handles);


                                    DisplayInitialStates(h,eventdata,handles,varargin);

                                    listbox_Callback(h,[],handles,varargin);






                                    function varargout=OK_Callback(h,eventdata,handles,varargin)%#ok

                                        if~VerifyIfAcceleratorMode(handles.system,'NODISPLAY');
                                            ApplyButton_Callback(h,eventdata,handles,varargin);
                                        end

                                        CancelButton_Callback(h,eventdata,handles,varargin)





                                        function varargout=CancelButton_Callback(h,eventdata,handles,varargin)%#ok

                                            POWERGUI_Handles=get_param(handles.block,'UserData');
                                            POWERGUI_Handles.initstates=[];
                                            set_param(handles.block,'UserData',POWERGUI_Handles);
closereq




                                            function varargout=HelpButton_Callback(h,eventdata,handles,varargin)%#ok
                                                helpview('sps',' PowerInitstatesAnchor');





                                                function varargout=ApplyButton_Callback(h,eventdata,handles,varargin)%#ok

                                                    if VerifyIfAcceleratorMode(handles.system,'apply changes to initial states');
                                                        return
                                                    end

                                                    if~isempty(handles.Data)

                                                        switch handles.Data.UseInitialStatesFrom
                                                        case 'blocks'
                                                            for i=1:length(handles.BlockInitialState.NeedUpdate)
                                                                if handles.BlockInitialState.NeedUpdate{i}==1

                                                                    switch handles.BlockInitialState.type{i}
                                                                    case 'Initial voltage'
                                                                        set_param(handles.BlockInitialState.block{i},'Setx0','on','InitialVoltage',mat2str(handles.BlockInitialState.value{i}));
                                                                    case 'Initial current'
                                                                        set_param(handles.BlockInitialState.block{i},'SetiL0','on','InitialCurrent',mat2str(handles.BlockInitialState.value{i}));
                                                                    end
                                                                end
                                                            end
                                                        end


                                                        set_param(handles.block,'x0status',handles.Data.UseInitialStatesFrom);




                                                        PowerguiUserData=get_param(handles.block,'userdata');
                                                        PowerguiUserData.BlockInitialState=handles.PowerguiInitialState;
                                                        set_param(handles.block,'userdata',PowerguiUserData);

                                                    end
                                                    set(handles.ApplyButton,'enable','off');





                                                    function varargout=SaveInitialStates_Callback(h,eventdata,handles,varargin)%#ok

                                                        [FileName,PathName]=uiputfile({handles.system,'.mat'},'Save initial values of states');

                                                        if ischar(FileName)

                                                            x0=handles.Data.x0;%#ok
                                                            PowerguiInitialState=handles.PowerguiInitialState;%#ok
                                                            if get(handles.SteadyStateCheck,'Value')==1;
                                                                checkboxstatus=1;%#ok
                                                            elseif get(handles.ResetButton,'Value')==1;
                                                                checkboxstatus=2;%#ok
                                                            else
                                                                checkboxstatus=3;%#ok
                                                            end
                                                            try
                                                                save(fullfile(PathName,FileName),'x0','checkboxstatus','PowerguiInitialState');
                                                            catch ME %#ok       
                                                                Erreur.message='Failed to save initial states';
                                                                Erreur.identifier='SpecializedPowerSystems:Powergui:InitialStatesToolError';
                                                                psberror(Erreur.message,Erreur.identifier);
                                                                uiwait(h);
                                                            end
                                                        end








                                                        function DisplayInitialStates(h,eventdata,handles,varargin)

                                                            Sort_Callback(h,eventdata,handles,varargin);

                                                            function DisplayStringFormat=getdisplayformat(handles)
                                                                val=get(handles.Format,'Value');
                                                                if isequal(val,1)
                                                                    DisplayStringFormat='%12.4e';
                                                                elseif isequal(val,2)
                                                                    DisplayStringFormat='%12.4g';
                                                                elseif isequal(val,3)
                                                                    DisplayStringFormat='%12.2f';
                                                                end

                                                                function status=VerifyIfAcceleratorMode(system,Tool)
                                                                    SimulationMode=get_param(system,'SimulationMode');
                                                                    status=0;
                                                                    if strcmp(SimulationMode,'accelerator')
                                                                        status=1;
                                                                        if~strcmp(Tool,'NODISPLAY')
                                                                            Message=['You cannot ',Tool,' when the Accelerator mode is selected. ',...
                                                                            'You can temporarily set the simulation mode to Normal to use this option. '];
                                                                            warndlg(Message,'Powergui tools')
                                                                            warning('SpecializedPowerSystems:Powergui:VerifyIfAcceleratorMode',Message)
                                                                        end
                                                                    end


                                                                    function handles=EvaluateTheModel(handles,POWERGUI_Handles)


                                                                        PowerguiInfo=getPowerguiInfo(handles.system,[]);
                                                                        if PowerguiInfo.NumberOfInstances>1
                                                                            if~isequal(PowerguiInfo.BlockName,PowerguiInfo.PowerguiBlocks{1})
                                                                                warningMsg=sprintf(['Multiple Powergui blocks associated with independent electrical networks found.\n',...
                                                                                'Due to a modeling constraint with the ''Initial State'' tool, only settings of the following Powergui block are applied to the model: %s.'],PowerguiInfo.BlockName);
                                                                                warndlg(warningMsg,'Powergui tools');
                                                                                warning('SpecializedPowerSystems:Powergui:InitStatesMultiplePowergui',warningMsg);%#ok<*SPWRN>
                                                                                set(handles.listbox,'string',warningMsg)
                                                                                set(handles.Format,'Enable','off')
                                                                                set(handles.SortMenu,'Enable','off')
                                                                                set(handles.FromFile,'Enable','off')
                                                                                set(handles.StateValueEdit,'Enable','off')
                                                                                set(handles.pushbutton1,'Enable','off')
                                                                                set(handles.pushbutton3,'Enable','off')
                                                                                set(handles.SteadyStateCheck,'Enable','off')
                                                                                set(handles.ResetButton,'Enable','off')
                                                                                return
                                                                            end
                                                                        end

                                                                        sps=power_init(handles.system,'getSPSstructure');

                                                                        if isempty(sps)
                                                                            return
                                                                        end


                                                                        handles.Data.circuit=handles.system;
                                                                        handles.Data.States=sps.IndependentStates;
                                                                        handles.Data.x0=sps.x0;
                                                                        handles.Data.x0_steady=sps.x0perm;
                                                                        handles.Data.x0_blocks=sps.x0_blocks;

                                                                        handles.Data.DependentStates=sps.DependentStates;
                                                                        handles.Data.x0DependentStates=sps.x0DependentStates;

                                                                        handles.Data.UseInitialStatesFrom=get_param(handles.block,'x0status');





                                                                        handles.BlockInitialState=sps.BlockInitialState;

                                                                        if~isempty(handles.BlockInitialState.state)
                                                                            handles.BlockInitialState.NeedUpdate{length(handles.BlockInitialState.state)}=[];
                                                                        else
                                                                            handles.BlockInitialState.NeedUpdate=[];
                                                                        end


                                                                        PowerguiUserData=get_param(handles.block,'userdata');
                                                                        if isfield(PowerguiUserData,'BlockInitialState');

                                                                            handles.PowerguiInitialState=POWERGUI_Handles.BlockInitialState;
                                                                        else

                                                                            handles.PowerguiInitialState.state={};
                                                                            handles.PowerguiInitialState.value={};
                                                                        end
