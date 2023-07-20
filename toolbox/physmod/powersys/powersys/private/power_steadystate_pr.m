function varargout=power_steadystate_pr(varargin)







    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_steadystate'));
    end


    if nargin<=2

        [GUI_is_already_open,POWERGUI_Handles,handles]=InitializePowerguiTools(nargout,varargin,'steadystate',mfilename);
        if GUI_is_already_open==1
            if nargout==1
                varargout{1}=handles.Data;
            end
            return
        end


        set(handles.figure,'Name',['Powergui Steady-State Voltages and Currents Tool.  model: ',handles.system]);


        set(handles.MeasurementsCheck,'value',1);


        try
            handles=EvaluateTheModel(handles);
        catch ME
            set(handles.listbox,'string',{'There is an error in the model.';'See MATLAB Command Window for more info on this error.'})

            set(handles.UnitsPopup,'Enable','off');
            set(handles.FrequencyPopup,'Enable','off');
            set(handles.Format,'Enable','off');
            set(handles.Ordering,'Enable','off');
            set(handles.NonlinearsCheck,'Enable','off');
            set(handles.SourcesCheck,'Enable','off');
            set(handles.MeasurementsCheck,'Enable','off');
            set(handles.StatesCheck,'Enable','off');


            handles.Ordre=0;


            guidata(handles.figure,handles);

            rethrow(ME)
        end


        handles.Ordre=0;


        guidata(handles.figure,handles);

        if isempty(handles.sps.xss)&&isempty(handles.sps.yss)&&isempty(handles.sps.uss)
        else


            MeasurementsCheck_Callback(handles.figure,[],handles,'yes');
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



    function[Freqx,PeakRMS,DCvalues,syslength]=GetGUIinfoSettings(handles)


        Freqx=get(handles.FrequencyPopup,'Value');
        freqstr=get(handles.FrequencyPopup,'String');
        PeakRMS=sqrt(get(handles.UnitsPopup,'Value'));
        DCvalues=0;
        if strcmp(freqstr(Freqx,1),'0');
            PeakRMS=1;
            DCvalues=1;
        end
        syslength=length(handles.system)+2;



        function varargout=UnitsPopup_Callback(h,eventdata,handles,varargin)%#ok


            if~isempty(handles.block)
                valeur=get(handles.UnitsPopup,'value');
                set_param(handles.block,'RmsSteady',mat2str(valeur));
            end
            UpdateCheckedTexts(h,eventdata,handles,varargin);
            DisplayInListBox(h,eventdata,handles,varargin);



            function varargout=FrequencyPopup_Callback(h,eventdata,handles,varargin)%#ok


                if~isempty(handles.block)
                    i=get(handles.FrequencyPopup,'value');
                    frequency=get(handles.FrequencyPopup,'string');
                    set_param(handles.block,'frequencyindicesteady',frequency(i,:));
                end
                UpdateCheckedTexts(h,eventdata,handles,varargin);
                DisplayInListBox(h,eventdata,handles,varargin);







                function varargout=StatesCheck_Callback(h,eventdata,handles,varargin)%#ok



                    IsNotChecked=~get(handles.StatesCheck,'value');
                    if IsNotChecked

                        DisplayInListBox(h,eventdata,handles,varargin);
                        return
                    end

                    if strcmp(varargin{1},'NoGUI')


                    else
                        handles=guidata(handles.figure);
                    end

                    DisplayStringFormat=getdisplayformat(handles);


                    sps=handles.sps;

                    if isempty(sps)

                        handles.States_text='';
                        handles.Sources_text='';
                        handles.Measurements_text='';
                        handles.Nonlinears_text='';
                        guidata(handles.figure,handles);
                        return
                    end

                    if isempty(sps.xss)

                        handles.States_text='-- No states --';

                    else

                        [Freqx,PeakRMS,DCvalues]=GetGUIinfoSettings(handles);

                        xss=sps.xss(:,Freqx);
                        handles.States_text=str2mat('STATES:',' ');
                        NumberOfIndependentStates=length(sps.IndependentStates);
                        NumberOfDependentStates=length(sps.DependentStates);
                        FormatedIndependentStates=char(sps.IndependentStates);
                        FormatedDependentStates=char(sps.DependentStates);

                        for i=1:NumberOfIndependentStates

                            if sps.IndependentStates{i}(1)=='U';
                                unite='V';
                            else
                                unite='A';
                            end
                            if PeakRMS==1
                                rms='';
                            else
                                rms='rms';
                            end
                            if DCvalues

                                if handles.Ordre
                                    ligne=sprintf([DisplayStringFormat,' %s   --->  ''%s'''],...
                                    abs(xss(i))*cos(angle(xss(i))),unite,FormatedIndependentStates(i,1:end));
                                else
                                    ligne=sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s'],...
                                    num2str(i),FormatedIndependentStates(i,1:end),abs(xss(i))*cos(angle(xss(i))),unite);
                                end
                            else

                                if handles.Ordre
                                    ligne=sprintf([DisplayStringFormat,' %s%s   %8.2f %s  --->  ''%s'''],...
                                    abs(xss(i))/PeakRMS,unite,rms,angle(xss(i))*180/pi,char(176),FormatedIndependentStates(i,1:end));
                                else
                                    ligne=sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s%s %8.2f %s'],...
                                    num2str(i),FormatedIndependentStates(i,1:end),abs(xss(i))/PeakRMS,unite,rms,angle(xss(i))*180/pi,char(176));
                                end
                            end
                            handles.States_text=str2mat(handles.States_text,ligne);

                        end


                        FullList=0;
                        if NumberOfDependentStates>0
                            if~isempty(sps.xssDependentStates)

                                handles.States_text=str2mat(handles.States_text,' ','Dependent STATES:',' ');
                                FullList=1;
                            else
                                handles.States_text=str2mat(handles.States_text,' ','Dependent STATES: (steady state values are not computed)',' ');
                            end
                        end
                        for i=1:NumberOfDependentStates
                            if sps.DependentStates{i}(1)=='U';
                                unite='V';
                                type='Uc';
                            else
                                unite='A';
                                type='Il';
                            end
                            if PeakRMS==1
                                rms='';
                            else
                                rms='rms';
                            end
                            if FullList
                                dxss=sps.xssDependentStates(i,Freqx);
                                if DCvalues
                                    ligne=sprintf(['%3s:  %s  ''%s''  =  ',DisplayStringFormat,' %s'],...
                                    type,FormatedDependentStates(i,1:end),abs(dxss)*cos(angle(dxss)),unite);
                                else
                                    ligne=sprintf(['%3s:  %s  ''%s''  =  ',DisplayStringFormat,' %s%s %8.2f %s'],...
                                    num2str(i),type,FormatedDependentStates(i,1:end),abs(dxss)/PeakRMS,unite,rms,angle(dxss)*180/pi,char(176));
                                end
                                handles.States_text=str2mat(handles.States_text,ligne);
                            else

                                ligne=sprintf('%3s:  ''%s''',num2str(i),FormatedDependentStates(i,1:end));
                                handles.States_text=str2mat(handles.States_text,ligne);
                            end
                        end
                    end


                    if~strcmp(varargin,'NoGUI')
                        guidata(handles.figure,handles);
                    end


                    if strcmp(varargin,'yes')||strcmp(varargin,'NoGUI')
                        DisplayInListBox(h,eventdata,handles,varargin);
                    end



                    function varargout=MeasurementsCheck_Callback(h,eventdata,handles,varargin)%#ok



                        IsNotChecked=~get(handles.MeasurementsCheck,'value');
                        if IsNotChecked

                            DisplayInListBox(h,eventdata,handles,varargin);
                            return
                        end

                        if strcmp(varargin{1},'NoGUI')


                        else
                            handles=guidata(handles.figure);
                        end

                        DisplayStringFormat=getdisplayformat(handles);


                        sps=handles.sps;

                        if isempty(sps)

                            handles.States_text='';
                            handles.Sources_text='';
                            handles.Measurements_text='';
                            handles.Nonlinears_text='';
                            guidata(handles.figure,handles);
                            return
                        end


                        if isempty(sps.MeasurementBlock.indice)&&isempty(sps.mesurexmeter)

                            handles.Measurements_text='-- No measurements --';

                        else

                            [Freqx,PeakRMS,DCvalues]=GetGUIinfoSettings(handles);



                            YssMax=size(sps.yss,1);


                            MultimeterMeasurementIndices=YssMax-sps.nbmodels(sps.basicnonlinearmodels+2)+1:YssMax;

                            AllMeasurements=[sps.MeasurementBlock.indice,MultimeterMeasurementIndices];

                            yss=sps.yss(AllMeasurements,Freqx);
                            ytype=sps.ytype(AllMeasurements);

                            mesures=sps.outstr(AllMeasurements,:);

                            handles.Measurements_text=str2mat('MEASUREMENTS:',' ');

                            for i=1:size(mesures,1)

                                if ytype(i)==0
                                    unit='V';
                                else
                                    unit='A';
                                end
                                if PeakRMS==1
                                    rms='';
                                else
                                    rms='rms';
                                end

                                if DCvalues
                                    if handles.Ordre
                                        ligne=sprintf([DisplayStringFormat,' %s   --->  %s'],abs(yss(i))*cos(angle(yss(i))),unit,mesures(i,:));
                                    else
                                        ligne=sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s'],num2str(i),mesures(i,:),abs(yss(i))*cos(angle(yss(i))),unit);
                                    end
                                else
                                    if handles.Ordre
                                        ligne=[sprintf([DisplayStringFormat,' %s%s   %8.2f%s'],abs(yss(i))/PeakRMS,unit,rms,angle(yss(i))*180/pi),char(176),'   --->  ',mesures(i,:)];
                                    else
                                        ligne=[sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s%s %8.2f'],num2str(i),mesures(i,:),abs(yss(i))/PeakRMS,unit,rms,angle(yss(i))*180/pi),char(176)];
                                    end
                                end

                                handles.Measurements_text=str2mat(handles.Measurements_text,ligne);

                            end

                        end


                        if~strcmp(varargin,'NoGUI')
                            guidata(handles.figure,handles);
                        end


                        if strcmp(varargin,'yes')||strcmp(varargin,'NoGUI')
                            DisplayInListBox(h,eventdata,handles,varargin);
                        end


                        function varargout=SourcesCheck_Callback(h,eventdata,handles,varargin)%#ok



                            IsNotChecked=~get(handles.SourcesCheck,'value');
                            if IsNotChecked

                                DisplayInListBox(h,eventdata,handles,varargin);
                                return
                            end

                            if strcmp(varargin{1},'NoGUI')


                            else
                                handles=guidata(handles.figure);
                            end

                            DisplayStringFormat=getdisplayformat(handles);


                            sps=handles.sps;

                            if isempty(sps)

                                handles.States_text='';
                                handles.Sources_text='';
                                handles.Measurements_text='';
                                handles.Nonlinears_text='';
                                guidata(handles.figure,handles);
                                return
                            end

                            [Freqx,PeakRMS,DCvalues]=GetGUIinfoSettings(handles);

                            if isempty(sps.SourceBlock.indice)
                                handles.Sources_text='-- No sources --';

                            else

                                uss=sps.uss(sps.SourceBlock.indice,Freqx);
                                types=sps.source(sps.SourceBlock.indice,3);

                                sours=[];
                                for i=sps.SourceBlock.indice
                                    sours=str2mat(sours,strrep(deblank(sps.srcstr{i}),char(10),' '));
                                end
                                sours(1,:)=[];


                                handles.Sources_text=str2mat('SOURCES:',' ');
                                for i=1:size(uss,1);
                                    if types(i)==0;
                                        unit='V';
                                    else
                                        unit='A';
                                    end
                                    if PeakRMS==1
                                        rms='';
                                    else
                                        rms='rms';
                                    end
                                    if DCvalues
                                        if handles.Ordre
                                            ligne=sprintf([DisplayStringFormat,' %s   --->  %s'],abs(uss(i))*cos(angle(uss(i))),unit,sours(i,:));
                                        else
                                            ligne=sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s'],num2str(i),sours(i,:),abs(uss(i))*cos(angle(uss(i))),unit);
                                        end
                                    else
                                        if handles.Ordre
                                            ligne=[sprintf([DisplayStringFormat,' %s%s   %8.2f'],abs(uss(i))/PeakRMS,unit,rms,angle(uss(i))*180/pi),char(176),'   --->  ',sours(i,:)];
                                        else
                                            ligne=[sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s%s %8.2f'],num2str(i),sours(i,:),abs(uss(i))/PeakRMS,unit,rms,angle(uss(i))*180/pi),char(176)];
                                        end
                                    end
                                    handles.Sources_text=str2mat(handles.Sources_text,ligne);
                                end
                            end


                            if~strcmp(varargin,'NoGUI')
                                guidata(handles.figure,handles);
                            end


                            if strcmp(varargin,'yes')||strcmp(varargin,'NoGUI')
                                DisplayInListBox(h,eventdata,handles,varargin);
                            end


                            function varargout=NonlinearsCheck_Callback(h,eventdata,handles,varargin)%#ok



                                IsNotChecked=~get(handles.NonlinearsCheck,'value');
                                if IsNotChecked

                                    DisplayInListBox(h,eventdata,handles,varargin);
                                    return
                                end

                                if strcmp(varargin{1},'NoGUI')


                                else
                                    handles=guidata(handles.figure);
                                end

                                DisplayStringFormat=getdisplayformat(handles);


                                sps=handles.sps;

                                if isempty(sps)

                                    handles.States_text='';
                                    handles.Sources_text='';
                                    handles.Measurements_text='';
                                    handles.Nonlinears_text='';
                                    guidata(handles.figure,handles);
                                    return
                                end


                                if isempty(sps.NonlinearBlock.name)

                                    handles.Nonlinears_text='-- No nonlinear elements --';

                                else

                                    [Freqx,PeakRMS,DCvalues]=GetGUIinfoSettings(handles);


                                    yss=sps.yss(sps.NonlinearBlock.Yindice,Freqx);
                                    ytype=sps.ytype(sps.NonlinearBlock.Yindice);
                                    uss=sps.uss(sps.NonlinearBlock.Uindice,Freqx);

                                    if~isempty(yss)

                                        NLmodel=[];
                                        blk=sps.outstr(sps.NonlinearBlock.Yindice,:);
                                        for i=1:size(yss,1)
                                            NLmodel=str2mat(NLmodel,strrep(deblank(blk(i,1:end)),char(10),' '));
                                        end
                                        NLmodel(1,:)=[];

                                        handles.Nonlinears_text=str2mat('NONLINEAR ELEMENTS (system outputs):',' ');
                                        if PeakRMS==1
                                            rms='';
                                        else
                                            rms='rms';
                                        end

                                        for i=1:size(yss,1);

                                            if ytype(i)==0
                                                unit='V';
                                            else
                                                unit='A';
                                            end

                                            if DCvalues
                                                if handles.Ordre
                                                    ligne=sprintf([DisplayStringFormat,' V   --->  %s'],abs(yss(i))*cos(angle(yss(i))),NLmodel(i,:));
                                                else
                                                    ligne=sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,unit],num2str(i),NLmodel(i,:),abs(yss(i))*cos(angle(yss(i))));
                                                end
                                            else
                                                if handles.Ordre
                                                    ligne=sprintf([DisplayStringFormat,' V%s   %8.2f%s   --->  %s'],abs(yss(i))/PeakRMS,rms,angle(yss(i))*180/pi,char(176),NLmodel(i,:));
                                                else
                                                    ligne=[sprintf(['%3s:  ''%s''  =  ',DisplayStringFormat,' %s%s %8.2f'],num2str(i),NLmodel(i,:),abs(yss(i))/PeakRMS,unit,rms,angle(yss(i))*180/pi),char(176)];
                                                end
                                            end
                                            handles.Nonlinears_text=str2mat(handles.Nonlinears_text,ligne);
                                        end


                                        NLmodel=[];
                                        for i=sps.NonlinearBlock.Uindice
                                            NLmodel=str2mat(NLmodel,strrep(deblank(sps.srcstr{i}),char(10),' '));
                                        end
                                        NLmodel(1,:)=[];

                                        handles.Nonlinears_text=str2mat(handles.Nonlinears_text,' ');
                                        handles.Nonlinears_text=str2mat(handles.Nonlinears_text,'NONLINEAR ELEMENTS (system inputs):');
                                        handles.Nonlinears_text=str2mat(handles.Nonlinears_text,' ');
                                        for i=1:size(uss,1);

                                            if NLmodel(i,1)=='U'
                                                unit='V';
                                            else
                                                unit='A';
                                            end

                                            if DCvalues
                                                if handles.Ordre
                                                    ligne=sprintf([DisplayStringFormat,' A   --->  %s'],abs(uss(i))*cos(angle(uss(i))),NLmodel(i,:));
                                                else
                                                    ligne=sprintf(['%3s:  ''%1s''  =  ',DisplayStringFormat,' A'],...
                                                    num2str(i),NLmodel(i,:),abs(uss(i))*cos(angle(uss(i))));
                                                end
                                            else
                                                if handles.Ordre
                                                    ligne=sprintf([DisplayStringFormat,' A%s   %8.2f%s   --->  %s'],abs(uss(i))/PeakRMS,rms,angle(uss(i))*180/pi,char(176),NLmodel(i,:));
                                                else
                                                    ligne=[sprintf(['%3s:  ''%1s''  =  ',DisplayStringFormat,' %s%s %8.2f'],num2str(i),NLmodel(i,:),abs(uss(i))/PeakRMS,unit,rms,angle(uss(i))*180/pi),char(176)];
                                                end
                                            end
                                            handles.Nonlinears_text=str2mat(handles.Nonlinears_text,ligne);
                                        end
                                    end
                                end


                                if~strcmp(varargin,'NoGUI')
                                    guidata(handles.figure,handles);
                                end


                                if strcmp(varargin,'yes')||strcmp(varargin,'NoGUI')
                                    DisplayInListBox(h,eventdata,handles,varargin);
                                end



                                function varargout=UpdatePushButton_Callback(h,eventdata,handles,varargin)%#ok


                                    if VerifyIfAcceleratorMode(handles.system);
                                        return
                                    end

                                    set(handles.figure,'Pointer','watch');
                                    try
                                        handles=EvaluateTheModel(handles);


                                        set(handles.UnitsPopup,'Enable','on');
                                        set(handles.FrequencyPopup,'Enable','on');
                                        set(handles.Format,'Enable','on');
                                        set(handles.Ordering,'Enable','on');
                                        set(handles.NonlinearsCheck,'Enable','on');
                                        set(handles.SourcesCheck,'Enable','on');
                                        set(handles.MeasurementsCheck,'Enable','on');
                                        set(handles.StatesCheck,'Enable','on');


                                        guidata(handles.figure,handles);

                                        set(handles.figure,'Pointer','arrow');

                                        UpdateCheckedTexts(h,eventdata,handles,varargin);
                                        DisplayInListBox(h,eventdata,handles,varargin);

                                    catch ME

                                        set(handles.listbox,'string',{'There is an error in the model.';'See MATLAB Command Window for more info on this error.'});

                                        set(handles.figure,'Pointer','arrow');
                                        set(handles.UnitsPopup,'Enable','off');
                                        set(handles.FrequencyPopup,'Enable','off');
                                        set(handles.Format,'Enable','off');
                                        set(handles.Ordering,'Enable','off');
                                        set(handles.NonlinearsCheck,'Enable','off');
                                        set(handles.SourcesCheck,'Enable','off');
                                        set(handles.MeasurementsCheck,'Enable','off');
                                        set(handles.StatesCheck,'Enable','off');

                                        set(handles.figure,'Pointer','arrow');
                                        rethrow(ME)
                                    end




                                    function DisplayInListBox(h,eventdata,handles,varargin)

                                        if strcmp(varargin{1},'NoGUI')


                                        else
                                            handles=guidata(handles.figure);
                                        end

                                        StatesChecked=get(handles.StatesCheck,'Value');
                                        MeasurementsChecked=get(handles.MeasurementsCheck,'Value');
                                        SourcesChecked=get(handles.SourcesCheck,'Value');
                                        NonlinearsChecked=get(handles.NonlinearsCheck,'Value');

                                        set(handles.listbox,'Value',1);

                                        ListboxText=[];
                                        if StatesChecked&&~isempty(handles.States_text)
                                            ListboxText=str2mat(ListboxText,handles.States_text);
                                            ListboxText=str2mat(ListboxText,' ');
                                        end
                                        if MeasurementsChecked&&~isempty(handles.Measurements_text)
                                            ListboxText=str2mat(ListboxText,handles.Measurements_text);
                                            ListboxText=str2mat(ListboxText,' ');
                                        end
                                        if SourcesChecked&&~isempty(handles.Sources_text)
                                            ListboxText=str2mat(ListboxText,handles.Sources_text);
                                            ListboxText=str2mat(ListboxText,' ');
                                        end
                                        if NonlinearsChecked&&~isempty(handles.Nonlinears_text);
                                            ListboxText=str2mat(ListboxText,handles.Nonlinears_text);
                                        end


                                        if isempty(ListboxText)
                                            set(handles.listbox,'string','','Value',[])
                                        else
                                            set(handles.listbox,'string',ListboxText,'Value',[]);
                                        end



                                        function UpdateCheckedTexts(h,eventdata,handles,varargin)

                                            StatesChecked=get(handles.StatesCheck,'Value');
                                            MeasurementsChecked=get(handles.MeasurementsCheck,'Value');
                                            SourcesChecked=get(handles.SourcesCheck,'Value');
                                            NonlinearsChecked=get(handles.NonlinearsCheck,'Value');
                                            if StatesChecked
                                                power_steadystate('StatesCheck_Callback',h,[],handles,'no');
                                            end
                                            if MeasurementsChecked
                                                power_steadystate('MeasurementsCheck_Callback',h,[],handles,'no');
                                            end
                                            if SourcesChecked
                                                power_steadystate('SourcesCheck_Callback',h,[],handles,'no');
                                            end
                                            if NonlinearsChecked
                                                power_steadystate('NonlinearsCheck_Callback',h,[],handles,'no');
                                            end


                                            function varargout=Pushbutton10_Callback(h,eventdata,handles,varargin)%#ok

                                                POWERGUI_Handles=get_param(handles.block,'UserData');
                                                POWERGUI_Handles.steadystate=[];
                                                set_param(handles.block,'UserData',POWERGUI_Handles);
                                                closereq;



                                                function varargout=Format_Callback(h,eventdata,handles,varargin)%#ok
                                                    UpdateCheckedTexts(h,eventdata,handles,varargin);
                                                    DisplayInListBox(h,eventdata,handles,varargin);

                                                    function varargout=Ordering_Callback(h,eventdata,handles,varargin)%#ok
                                                        if isequal(get(handles.Ordering,'value'),1)
                                                            handles.Ordre=1;
                                                        else
                                                            handles.Ordre=0;
                                                        end
                                                        guidata(handles.figure,handles);
                                                        UpdateCheckedTexts(h,eventdata,handles,varargin);
                                                        DisplayInListBox(h,eventdata,handles,varargin);


                                                        function DisplayStringFormat=getdisplayformat(handles)
                                                            if isequal(get(handles.Format,'value'),1)
                                                                DisplayStringFormat='%12.4e';
                                                            elseif isequal(get(handles.Format,'value'),2)
                                                                DisplayStringFormat='%12.4g';
                                                            elseif isequal(get(handles.Format,'value'),3)
                                                                DisplayStringFormat='%12.2f';
                                                            end

                                                            function status=VerifyIfAcceleratorMode(system)

                                                                SimulationMode=get_param(system,'SimulationMode');
                                                                status=0;
                                                                if strcmp(SimulationMode,'accelerator')
                                                                    status=1;
                                                                    Message=['You cannot update the steady state values when the Accelerator mode is selected. ',...
                                                                    'You can temporarily set the simulation mode to Normal to update values.'];
                                                                    warndlg(Message,'Powergui tools')
                                                                    warning('SpecializedPowerSystems:Powergui:VerifyIfAcceleratorMode',Message)
                                                                end


                                                                function handles=EvaluateTheModel(handles)


                                                                    sps=power_init(handles.system,'getSPSstructure');
                                                                    handles.sps=sps;

                                                                    handles.Data.circuit=handles.system;

                                                                    if isempty(sps)

                                                                        set(handles.listbox,'string','The model have no state-space equations');
                                                                        handles.Data.States=[];
                                                                        handles.Data.xss=[];

                                                                        return
                                                                    else


                                                                        if isempty(sps.xss)&&isempty(sps.yss)&&isempty(sps.uss)

                                                                            set(handles.listbox,'string','The model have no state-space equations');
                                                                            handles.Data.States=[];
                                                                            handles.Data.xss=[];

                                                                            return
                                                                        end

                                                                        handles.Data.Frequencies=sps.freq;


                                                                        handles.Data.States=sps.IndependentStates;
                                                                        handles.Data.Xss=sps.xss;
                                                                        handles.Data.DependentStates=sps.DependentStates;


                                                                        if isempty(sps.measurenames)&&isempty(sps.mesurexmeter)
                                                                            handles.Data.Measurements=[];
                                                                            handles.Data.Yss_Measurements=[];
                                                                        else
                                                                            YssMax=size(sps.yss,1);

                                                                            MultimeterMeasurementIndices=YssMax-sps.nbmodels(sps.basicnonlinearmodels+2)+1:YssMax;
                                                                            AllMeasurements=[sps.MeasurementBlock.indice,MultimeterMeasurementIndices];


                                                                            handles.Data.Measurements=cellstr(sps.outstr(AllMeasurements,:));
                                                                            handles.Data.Yss_Measurements=sps.yss(AllMeasurements,:);
                                                                        end


                                                                        if isempty(sps.uss)
                                                                            handles.Data.Sources=sps.srcstr(sps.SourceBlock.indice);
                                                                            handles.Data.Uss_Sources=[];
                                                                        else
                                                                            handles.Data.Sources=sps.srcstr(sps.SourceBlock.indice);
                                                                            handles.Data.Uss_Sources=sps.uss(sps.SourceBlock.indice,:);
                                                                        end


                                                                        if isempty(sps.NonlinearBlock.name)
                                                                            handles.Data.NonlinearOutputs=[];
                                                                            handles.Data.Yss_NonlinearOutputs=[];
                                                                            handles.Data.NonlinearInputs=[];
                                                                            handles.Data.Uss_NonlinearInputs=[];
                                                                        else
                                                                            handles.Data.NonlinearOutputs=cellstr(sps.outstr(sps.NonlinearBlock.Yindice,:));
                                                                            handles.Data.Yss_NonlinearOutputs=sps.yss(sps.NonlinearBlock.Yindice,:);
                                                                            handles.Data.NonlinearInputs=sps.srcstr(sps.NonlinearBlock.Uindice,:);
                                                                            handles.Data.Uss_NonlinearInputs=sps.uss(sps.NonlinearBlock.Uindice,:);
                                                                        end

                                                                    end


                                                                    Frequencies=mat2str(sps.freq);
                                                                    if~isempty(findstr(Frequencies,'[')),
                                                                        Frequencies=strrep(Frequencies,' ','|');
                                                                        Frequencies=strrep(Frequencies,'[','');
                                                                        Frequencies=strrep(Frequencies,']','');
                                                                    end
                                                                    if~isempty(Frequencies)
                                                                        set(handles.FrequencyPopup,'String',Frequencies);
                                                                    end

                                                                    frequence=eval(get_param(handles.block,'frequencyindicesteady'));
                                                                    IndiceFrequence=find(sps.freq==frequence);

                                                                    if isempty(IndiceFrequence)

                                                                        IndiceFrequence=1;
                                                                        f50=find(sps.freq==50);
                                                                        f60=find(sps.freq==60);
                                                                        if f50
                                                                            IndiceFrequence=f50;
                                                                        end
                                                                        if f60
                                                                            IndiceFrequence=f60;
                                                                        end
                                                                    end
                                                                    set(handles.FrequencyPopup,'Value',IndiceFrequence);

                                                                    RmsSteady=get_param(handles.block,'RmsSteady');
                                                                    if~isempty(RmsSteady)
                                                                        rmix=eval(RmsSteady);
                                                                        set(handles.UnitsPopup,'value',rmix);
                                                                    end