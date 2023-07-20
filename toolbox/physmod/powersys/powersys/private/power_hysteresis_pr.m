function varargout=power_hysteresis_pr(varargin)










    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_hysteresis'));
    end


    if nargout==1


        if nargin==0
            load hysteresis.mat
            MATFILE='hysteresis.mat';
        else
            load(varargin{1});
            MATFILE=varargin{1};
        end

        varargout{1}.Segments=2^HT.npuis;%#ok mlint HT is loaded from MAT file
        varargout{1}.Fr=HT.Fr;
        varargout{1}.Fs=HT.Fs;
        varargout{1}.Is=HT.Is;
        varargout{1}.Ic=HT.Ic;
        varargout{1}.dFdI=HT.Pc;
        varargout{1}.Isat=HT.Ij_sat;
        varargout{1}.Fsat=HT.Fj_sat;
        if ischar(HT.Nominals)
            varargout{1}.Nominal=eval(HT.Nominals);
        end

        if HT.UnitsPopup==1
            varargout{1}.Units='pu';
        else
            varargout{1}.Units='SI';
        end

        varargout{1}.Tolerances=HT.Tolerances;
        varargout{1}.MATfile=MATFILE;

        return

    end



    if nargin<=2

        if nargin==1

            CMDLine=1;
        else
            CMDLine=0;
        end

        if nargin==2
            STY=varargin;
        else
            STY={[],[]};
        end

        [GUI_is_already_open,POWERGUI_Handles,handles]=InitializePowerguiTools(nargout,STY,'hysteresis',mfilename);

        if GUI_is_already_open
            return
        end



        figToolBar=findall(0,'Tag','FigureToolBar','Parent',POWERGUI_Handles.hysteresis);
        if~isempty(figToolBar)
            plotEditTool=findall(0,'Tag','Standard.EditPlot','Parent',figToolBar);
            plotEditTool.Enable='off';plotEditTool.Visible='off';
            figToolBar.Visible='off';
        end

        if CMDLine

            HPARAM=varargin{1};


            HT.Is=HPARAM.Is;
            HT.Fs=HPARAM.Fs;
            HT.Ij_sat=HPARAM.Isat;
            HT.Fj_sat=HPARAM.Fsat;
            HT.Ic=HPARAM.Ic;
            HT.Fr=HPARAM.Fr;
            HT.Pc=HPARAM.dFdI;
            if strcmp('pu',HPARAM.Units)
                HT.UnitsPopup=1;
            else
                HT.UnitsPopup=2;
            end
            switch HPARAM.Segments
            case 32
                HT.npuis=5;
            case 64
                HT.npuis=6;
            case 128
                HT.npuis=7;
            case 256
                HT.npuis=8;
            case 512
                HT.npuis=9;
            end
            HT.Nominals=HPARAM.Nominal;
            HT.Tolerances=HPARAM.Tolerances;

            HT=DisplayPushButton_Callback(handles.figure,[],handles,HT);
            save(fullfile(pwd,HPARAM.MATfile),'HT');
        else

            LoadPushButton_Callback(handles.figure,CMDLine,handles,'hysteresis.mat');
        end

    elseif ischar(varargin{1})
        try
            [varargout{1:nargout}]=feval(varargin{:});
        catch ME
            rethrow(ME);
        end
    end

    function LoadPushButton_Callback(h,eventdata,handles,varargin)


        if isempty(varargin)
            [FileName,PathName]=uigetfile('*.mat','Load hysteresis data');
            if ischar(FileName)

                load(fullfile(PathName,FileName));
            else
                return
            end
            set(handles.LoadPushButton,'UserData',FileName);
        else
            FileName=varargin{1};
            eval(['load ',FileName]);
            set(handles.LoadPushButton,'UserData',FileName);
            PathName=fullfile(matlabroot,'toolbox','physmod','powersys','powerdemo');
        end

        set(handles.figure,'Name',['Powergui Hysteresis Design Tool. model: ',fullfile(PathName,FileName)]);


        if exist('HT','var')
            if~isstruct(HT)
                message='The selected MAT file does not contain valid hysteresis data';
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:HysteresisTool:InvalidMatFile';
                psberror(Erreur.message,Erreur.identifier);
                return
            end
        else
            message='The selected MAT file does not contain valid hysteresis data';
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:HysteresisTool:InvalidMatFile';
            psberror(Erreur.message,Erreur.identifier);
            return
        end


        set(handles.IsStarEdit,'String',mat2str(HT.Is,5));
        set(handles.FsStarEdit,'String',mat2str(HT.Fs,5));








        set(handles.CurrentSatEdit,'String',mat2str(HT.Ij_sat,5));
        set(handles.FluxSatEdit,'String',mat2str(HT.Fj_sat,5));

        set(handles.IcxEdit,'String',mat2str(HT.Ic,5));
        set(handles.FrplusEdit,'String',mat2str(HT.Fr,5));
        set(handles.DfdlEdit,'String',mat2str(HT.Pc,5));
        set(handles.SegmentsPopup,'Value',(HT.npuis-4));
        set(handles.UnitsPopup,'value',HT.UnitsPopup);
        if ischar(HT.Nominals)
            set(handles.NominalParametersEdit,'String',HT.Nominals);
        else
            set(handles.NominalParametersEdit,'String',mat2str(HT.Nominals));
        end
        set(handles.TolerancesEdit,'String',mat2str(HT.Tolerances,5));

        set(handles.UnitsPopup,'UserData',HT.UnitsPopup);
        set(handles.DisplayPushButton,'UserData',HT);

        UnitsPopup_Callback(h,eventdata,handles,varargin);


        DisplayPushButton_Callback(h,eventdata,handles,HT);


        function varargout=SavePushButton_Callback(h,eventdata,handles,varargin)%#ok


            CurrentFileName=get(handles.LoadPushButton,'userdata');
            if isempty(CurrentFileName)
                [FileName,PathName]=uiputfile('MyHysteresis.mat','Save Hysteresis data');
            else
                [FileName,PathName]=uiputfile(CurrentFileName,'Save Hysteresis data');
            end

            if ischar(FileName)
                HT=get(handles.DisplayPushButton,'UserData');
                save(fullfile(PathName,FileName),'HT');
                set(handles.figure,'Name',['power_hysteresis - Model: ',[PathName,FileName]]);
                set(handles.LoadPushButton,'userdata',[PathName,FileName]);
            end


            function varargout=DisplayPushButton_Callback(h,eventdata,handles,varargin)%#ok


                if isempty(varargin)
                    HT=get(handles.DisplayPushButton,'UserData');
                else
                    HT=varargin{1};
                end
                if ischar(HT.Nominals)
                    Nominals=eval(HT.Nominals);
                else
                    Nominals=HT.Nominals;
                end
                P=Nominals(1);
                V=Nominals(2);
                f=Nominals(3);

                HT.Fpu=(V/(2*pi*f))*sqrt(2);
                HT.Ipu=(P/V)*sqrt(2);
                HT.LastRc=0;


                if(HT.Ij_sat(1)~=HT.Is||HT.Fj_sat(1)~=HT.Fs)
                    return
                end




                a0=HT.Fs/pi*2;
                c0=tan(HT.Fr/a0);
                b0=c0/HT.Ic;
                e0=-a0/2*(atan(b0*HT.Is+c0)+atan(-b0*HT.Is+c0));%#ok
                alpha0=0;%#ok


                options=simset('SrcWorkspace','current');
                t=sim('solve_para',[],options);
                j=length(t);
                HT.a=a(j);
                HT.b=b(j);
                HT.c=c(j);
                HT.e=e(j);
                HT.alpha=alfa(j);

                sgn=1;
                lim=(2^HT.npuis)/2;%#ok


                HT.Jmax=(2^HT.npuis)+1;



                delIj=(2*HT.Is)/(HT.Jmax-1);


                HT.Ij=[];
                HT.Fj=[];

                for J=1:HT.Jmax

                    HT.Ij(J)=-HT.Is+((J-1)*delIj);
                    HT.Fj(J)=(-sgn*(HT.a*atan((HT.b*(-sgn)*HT.Ij(J))+HT.c)-(sgn*HT.alpha*HT.Ij(J))+HT.e));
                    derj(J)=(HT.a*HT.b/(1+(HT.b*(-sgn)*HT.Ij(J)+HT.c)^2))+HT.alpha;%#ok

                    Fjd(J)=(sgn*(HT.a*atan((HT.b*(sgn)*HT.Ij(J))+HT.c)-(-sgn*HT.alpha*HT.Ij(J))+HT.e));%#ok
                end




                JmaxM1=HT.Jmax-1;


                HT.Mj=[];
                HT.Bj=[];

                for J=1:JmaxM1
                    HT.Mj(J)=(HT.Fj(J+1)-HT.Fj(J))/delIj;
                    HT.Bj(J)=HT.Fj(J)-(HT.Mj(J)*HT.Ij(J));
                end


                HT.Mj(HT.Jmax)=HT.Mj(HT.Jmax-1);
                HT.Bj(HT.Jmax)=HT.Bj(HT.Jmax-1);

                HT.X_i=HT.Ij';
                HT.Y_a=HT.Fj';
                HT.Y_d=Fjd';









                N=length(HT.Fj_sat);

                plot(HT.X_i,HT.Y_a,HT.X_i,HT.Y_d,'b',HT.Is,HT.Fs,'*r',0,HT.Fr,'+r',HT.Ic,0,'xr',...
                HT.Ij_sat(1:N),HT.Fj_sat(1:N),'b',-HT.Ij_sat(1:N),-HT.Fj_sat(1:N),'b',...
                'Parent',handles.axes);

                set(get(handles.axes,'parent'),'HandleVisibility','on')
                FileName=get(handles.LoadPushButton,'UserData');
                mot=['Hysteresis curve of file:',FileName];
                set(handles.HysteresisPanel,'Title',mot);

                if HT.UnitsPopup==1
                    xlabel('Current (pu)','Parent',handles.axes);
                    ylabel('Flux (pu)','Parent',handles.axes);
                else
                    xlabel('Current (A)','Parent',handles.axes);
                    ylabel('Flux (V.s)','Parent',handles.axes);
                end

                set(get(handles.axes,'parent'),'HandleVisibility','callback');
                grid(handles.axes);

                set(handles.DisplayPushButton,'UserData',HT);

                guidata(h,handles);

                AutoZoomCheck_Callback(h,[],handles,varargin);

                if nargout==1
                    varargout{1}=HT;
                end



                function varargout=HelpPushButton_Callback(h,eventdata,handles,varargin)%#ok


                    helpview(psbhelp('power_hysteresis'));


                    function varargout=UnitsPopup_Callback(h,eventdata,handles,varargin)%#ok

                        valeur=get(handles.UnitsPopup,'value');

                        if valeur==1
                            set(handles.text5,'String','Remnant flux Fr (pu):');
                            set(handles.text4,'String','Saturation flux Fs (pu):');
                            set(handles.text3,'String','Saturation current Is (pu):');
                            set(handles.text22,'String','Coercive current Ic (pu):');
                            set(handles.text10,'String','Saturation region currents (pu):');
                            set(handles.text11,'String','Saturation region fluxes (pu):');
                        else
                            set(handles.text5,'String','Remnant flux Fr (V.s):');
                            set(handles.text4,'String','Saturation flux Fs (V.s):');
                            set(handles.text3,'String','Saturation current Is (A):');
                            set(handles.text22,'String','Coercive current Ic (A):');
                            set(handles.text10,'String','Saturation region currents (A):');
                            set(handles.text11,'String','Saturation region fluxes (V.s):');
                        end
                        UnitsPopup=get(handles.UnitsPopup,'UserData');
                        if UnitsPopup~=valeur

                            ConvertPushButton_Callback(h,eventdata,handles,varargin);
                            set(handles.UnitsPopup,'UserData',valeur);
                        end


                        function varargout=SegmentsPopup_Callback(h,eventdata,handles,varargin)%#ok

                            HT=get(handles.DisplayPushButton,'UserData');
                            SettingNSEG=get(handles.SegmentsPopup,'value');
                            HT.npuis=SettingNSEG+4;
                            set(handles.DisplayPushButton,'UserData',HT);


                            function varargout=FrplusEdit_Callback(h,eventdata,handles,varargin)%#ok

                                HT=get(handles.DisplayPushButton,'UserData');
                                HT.Fr=eval(get(handles.FrplusEdit,'String'));
                                set(handles.DisplayPushButton,'UserData',HT);


                                function varargout=FsStarEdit_Callback(h,eventdata,handles,varargin)%#ok

                                    HT=get(handles.DisplayPushButton,'UserData');
                                    HT.Fs=eval(get(handles.FsStarEdit,'String'));
                                    HT.Fj_sat(1)=HT.Fs;
                                    if length(HT.Fj_sat)==1
                                        Mot=['[ ',mat2str(HT.Fj_sat,5),', ',mat2str(2*HT.Fj_sat,5),' ]'];
                                        set(handles.FluxSatEdit,'String',Mot);
                                    else
                                        set(handles.FluxSatEdit,'String',mat2str(HT.Fj_sat(1:end),5));
                                    end
                                    set(handles.DisplayPushButton,'UserData',HT);


                                    function varargout=IsStarEdit_Callback(h,eventdata,handles,varargin)%#ok

                                        HT=get(handles.DisplayPushButton,'UserData');
                                        HT.Is=eval(get(handles.IsStarEdit,'String'));
                                        HT.Ij_sat(1)=HT.Is;
                                        if length(HT.Ij_sat)==1
                                            Mot=['[ ',mat2str(HT.Ij_sat,5),', ',mat2str(2*HT.Ij_sat,5),' ]'];
                                            set(handles.CurrentSatEdit,'String',Mot);
                                        else
                                            set(handles.CurrentSatEdit,'String',mat2str(HT.Ij_sat,5));
                                        end
                                        set(handles.DisplayPushButton,'UserData',HT);


                                        function varargout=IcxEdit_Callback(h,eventdata,handles,varargin)%#ok

                                            HT=get(handles.DisplayPushButton,'UserData');
                                            HT.Ic=eval(get(handles.IcxEdit,'String'));
                                            set(handles.DisplayPushButton,'UserData',HT);


                                            function varargout=DfdlEdit_Callback(h,eventdata,handles,varargin)%#ok

                                                HT=get(handles.DisplayPushButton,'UserData');
                                                HT.Pc=eval(get(handles.DfdlEdit,'String'));
                                                set(handles.DisplayPushButton,'UserData',HT);


                                                function varargout=CurrentSatEdit_Callback(h,eventdata,handles,varargin)%#ok

                                                    HT=get(handles.DisplayPushButton,'UserData');


                                                    HT.Ij_sat=eval(get(handles.CurrentSatEdit,'String'));






                                                    HT.Is=HT.Ij_sat(1);
                                                    set(handles.IsStarEdit,'String',mat2str(HT.Is,5));
                                                    set(handles.DisplayPushButton,'UserData',HT);


                                                    function varargout=FluxSatEdit_Callback(h,eventdata,handles,varargin)%#ok

                                                        HT=get(handles.DisplayPushButton,'UserData');

                                                        HT.Fj_sat=eval(get(handles.FluxSatEdit,'String'));






                                                        HT.Fs=HT.Fj_sat(1);
                                                        set(handles.FsStarEdit,'String',mat2str(HT.Fs,5));
                                                        set(handles.DisplayPushButton,'UserData',HT);


                                                        function varargout=NominalParametersEdit_Callback(h,eventdata,handles,varargin)%#ok

                                                            HT=get(handles.DisplayPushButton,'UserData');
                                                            HT.Nominals=get(handles.NominalParametersEdit,'String');
                                                            set(handles.DisplayPushButton,'UserData',HT);

                                                            function varargout=TolerancesEdit_Callback(h,eventdata,handles,varargin)%#ok

                                                                HT=get(handles.DisplayPushButton,'UserData');
                                                                HT.Tolerances=eval(get(handles.TolerancesEdit,'String'));
                                                                set(handles.DisplayPushButton,'UserData',HT);

                                                                function varargout=ConvertPushButton_Callback(h,eventdata,handles,varargin)%#ok

                                                                    HT=get(handles.DisplayPushButton,'UserData');
                                                                    WantSIUnits=(get(handles.UnitsPopup,'Value')==2);

                                                                    Nominals=eval(HT.Nominals);
                                                                    P=Nominals(1);
                                                                    V=Nominals(2);
                                                                    f=Nominals(3);
                                                                    BaseFlux=(V/(2*pi*f))*sqrt(2);
                                                                    BaseCurrent=(P/V)*sqrt(2);

                                                                    if WantSIUnits

                                                                        HT.Fr=HT.Fr*BaseFlux;
                                                                        HT.Fs=HT.Fs*BaseFlux;
                                                                        HT.Is=HT.Is*BaseCurrent;
                                                                        HT.Ic=HT.Ic*BaseCurrent;
                                                                        HT.Pc=HT.Pc*(BaseFlux/BaseCurrent);
                                                                        HT.Ij_sat=HT.Ij_sat*BaseCurrent;
                                                                        HT.Fj_sat=HT.Fj_sat*BaseFlux;
                                                                        HT.UnitsPopup=2;

                                                                    else

                                                                        HT.Fr=HT.Fr/BaseFlux;
                                                                        HT.Fs=HT.Fs/BaseFlux;
                                                                        HT.Is=HT.Is/BaseCurrent;
                                                                        HT.Ic=HT.Ic/BaseCurrent;
                                                                        HT.Pc=HT.Pc*(BaseCurrent/BaseFlux);
                                                                        HT.Ij_sat=HT.Ij_sat/BaseCurrent;
                                                                        HT.Fj_sat=HT.Fj_sat/BaseFlux;
                                                                        HT.UnitsPopup=1;

                                                                    end

                                                                    set(handles.DisplayPushButton,'UserData',HT);

                                                                    set(handles.IsStarEdit,'String',mat2str(HT.Is,5));
                                                                    set(handles.FsStarEdit,'String',mat2str(HT.Fs,5));
                                                                    set(handles.IcxEdit,'String',mat2str(HT.Ic,5));
                                                                    set(handles.FrplusEdit,'String',mat2str(HT.Fr,5));
                                                                    set(handles.DfdlEdit,'String',mat2str(HT.Pc,5));

                                                                    set(handles.CurrentSatEdit,'String',mat2str(HT.Ij_sat,5));
                                                                    set(handles.FluxSatEdit,'String',mat2str(HT.Fj_sat,5));


                                                                    set(handles.DfEdit,'String',mat2str(HT.Fs/100,5));

                                                                    FsStarEdit_Callback(h,eventdata,handles,varargin);
                                                                    IsStarEdit_Callback(h,eventdata,handles,varargin);
                                                                    DisplayPushButton_Callback(h,eventdata,handles,HT);


                                                                    function varargout=pushbutton3_Callback(h,eventdata,handles,varargin)%#ok
                                                                        close(handles.figure);






                                                                        function varargout=ExtraCheck_Callback(h,eventdata,handles,varargin)%#ok

                                                                            set(handles.SimulationCheck,'Value',0);
                                                                            set(handles.TolerancesCheck,'Value',0);

                                                                            Checked=get(handles.ExtraCheck,'Value');
                                                                            statut='off';
                                                                            statut2='on';%#ok
                                                                            AxesPosition=[0.1089,0.1548,0.525,0.7286];%#ok
                                                                            if Checked
                                                                                statut='on';
                                                                                statut2='off';%#ok
                                                                                AxesPosition=[0.1089,0.4548,0.525,0.4643];%#ok
                                                                            end


                                                                            set(handles.ConvertPushButton,'Visible',statut);
                                                                            set(handles.NominalParametersText,'Visible',statut);
                                                                            set(handles.NominalParametersEdit,'Visible',statut);


                                                                            set(handles.StartText,'Visible','off');
                                                                            set(handles.StartFluxEdit,'Visible','off');
                                                                            set(handles.StopText,'Visible','off');
                                                                            set(handles.StopFluxEdit,'Visible','off');
                                                                            set(handles.DfText,'Visible','off');
                                                                            set(handles.DfEdit,'Visible','off');
                                                                            set(handles.GoPushButton,'Visible','off');
                                                                            set(handles.ResetPushButton,'Visible','off');
                                                                            set(handles.TolerancesText,'Visible','off');
                                                                            set(handles.TolerancesEdit,'Visible','off');
                                                                            set(handles.InitialSlope,'visible','on');



                                                                            function varargout=GoPushButton_Callback(h,eventdata,handles,varargin)%#ok





                                                                                HT=get(handles.DisplayPushButton,'UserData');

                                                                                HT.npuis=get(handles.SegmentsPopup,'Value')+4;


                                                                                fluxinit=eval(get(handles.StartFluxEdit,'String'));
                                                                                fluxgoal=eval(get(handles.StopFluxEdit,'String'),'NaN');
                                                                                if isnan(fluxgoal)
                                                                                    Message='You must specify a valid flux stop value in order to use the animation tool correctly';
                                                                                    GUI=warndlg(Message,'Hysteresis tool','modal');
                                                                                    set(GUI,'tag','Specialized Power Systems Hysteresis Tool');
                                                                                    warning('SpecializedPowerSystems:Powergui:InvalidParameter',Message)
                                                                                    return
                                                                                end
                                                                                if HT.UnitsPopup==1
                                                                                    Funits='p.u';
                                                                                else
                                                                                    Funits='V.s';
                                                                                end
                                                                                if fluxgoal>HT.Fs
                                                                                    Message=['The value of Stop parameter in Flux animation tool must be lower than the value of Saturation flux Fs parameter. Please specify a value between -',mat2str(HT.Fs),' and ',mat2str(HT.Fs),' ',Funits,'.'];
                                                                                    GUI=warndlg(Message,'Hysteresis tool','modal');
                                                                                    set(GUI,'tag','Specialized Power Systems Hysteresis Tool');
                                                                                    warning('SpecializedPowerSystems:HysteresisTool:InvalidParameter',Message)
                                                                                    return
                                                                                end
                                                                                if fluxgoal<-HT.Fs
                                                                                    Message=['The absolute value of Stop parameter in Flux animation tool must be lower than the value of Saturation flux Fs parameter. Please specify a value between -',mat2str(HT.Fs),' and ',mat2str(HT.Fs),' ',Funits,'.'];
                                                                                    GUI=warndlg(Message,'Hysteresis tool','modal');
                                                                                    set(GUI,'tag','Specialized Power Systems Hysteresis Tool');
                                                                                    warning('SpecializedPowerSystems:HysteresisTool:InvalidParameter',Message)
                                                                                    return
                                                                                end
                                                                                initialslope=1;

                                                                                if initialslope==1
                                                                                    pente=1;
                                                                                else
                                                                                    pente=-1;
                                                                                end
                                                                                if HT.LastRc==0
                                                                                    AnimateHysteresis(0,0,0,0,fluxinit,HT,1,-1,[],pente);
                                                                                end

                                                                                Delta_F=eval(get(handles.DfEdit,'String'))*sign(fluxgoal-fluxinit);
                                                                                if Delta_F==0

                                                                                    return
                                                                                end

                                                                                flux=fluxinit:Delta_F:fluxgoal;

                                                                                HT.Tolerances=eval(get(handles.TolerancesEdit,'String'),'[0.1,10]');

                                                                                if length(flux)>500
                                                                                    Message='The specified delta F parameter is too small, the number of generated point has been limited to 500 points';
                                                                                    warndlg(Message,'Hysteresis');
                                                                                    warning('SpecializedPowerSystems:Powergui:InvalidParameter',Message)
                                                                                    Delta_F=abs(fluxinit-fluxgoal)/500;
                                                                                    flux=fluxinit:Delta_F:fluxgoal;
                                                                                end

                                                                                for n=1:length(flux)

                                                                                    sys=AnimateHysteresis(0,0,flux(n),2,[],HT,1,-1,[HT.Fs*HT.Tolerances(1)/100,HT.Ic*HT.Tolerances(2)/100],[]);%#ok

                                                                                    sys=AnimateHysteresis(0,0,flux(n),3,[],HT,1,-1,[HT.Fs*HT.Tolerances(1)/100,HT.Ic*HT.Tolerances(2)/100],[]);
                                                                                    current(n)=sys(1);%#ok

                                                                                end

                                                                                HT.LastRc=current(n);
                                                                                set(handles.StartFluxEdit,'String',mat2str(fluxgoal),'Enable','off');
                                                                                set(handles.StopFluxEdit,'String','?');

                                                                                set(handles.figure,'HandleVisibility','on');
                                                                                set(handles.axes,'NextPlot','add')
                                                                                comet(current,flux);
                                                                                plot(current,flux,'r');
                                                                                set(handles.axes,'NextPlot','replace')
                                                                                set(handles.figure,'HandleVisibility','callback');

                                                                                zoom(handles.axes,'on');


                                                                                set(handles.DisplayPushButton,'UserData',HT);



                                                                                function varargout=ResetPushButton_Callback(h,eventdata,handles,varargin)%#ok


                                                                                    set(handles.StartFluxEdit,'String','0.0','Enable','on');
                                                                                    set(handles.StopFluxEdit,'String','?');

                                                                                    HT=get(handles.DisplayPushButton,'UserData');
                                                                                    HT.LastRc=0.0;
                                                                                    set(handles.DisplayPushButton,'UserData',HT);

                                                                                    DisplayPushButton_Callback(h,eventdata,handles,HT);


                                                                                    function varargout=SimulationCheck_Callback(h,eventdata,handles,varargin)%#ok

                                                                                        if strcmp('on',get(handles.Animation,'Checked'))

                                                                                            set(handles.Animation,'Checked','off')
                                                                                            statut='off';
                                                                                        else

                                                                                            set(handles.Animation,'Checked','on')
                                                                                            set(handles.Tolerances,'Checked','off')
                                                                                            set(handles.TolerancesText,'enable','off');
                                                                                            set(handles.TolerancesEdit,'enable','off');
                                                                                            statut='on';
                                                                                        end

                                                                                        HT=get(handles.DisplayPushButton,'UserData');

                                                                                        set(handles.StartText,'enable',statut);
                                                                                        set(handles.StartFluxEdit,'enable',statut);
                                                                                        set(handles.StopText,'enable',statut);
                                                                                        set(handles.StopFluxEdit,'enable',statut);
                                                                                        set(handles.DfText,'enable',statut);
                                                                                        set(handles.DfEdit,'enable',statut,'String',mat2str(HT.Fs/100,5));
                                                                                        set(handles.GoPushButton,'enable',statut);
                                                                                        set(handles.ResetPushButton,'enable',statut);


                                                                                        function varargout=TolerancesCheck_Callback(h,eventdata,handles,varargin)%#ok

                                                                                            if strcmp('on',get(handles.Tolerances,'Checked'))

                                                                                                set(handles.Tolerances,'Checked','off');
                                                                                                set(handles.TolerancesText,'Enable','off');
                                                                                                set(handles.TolerancesEdit,'Enable','off');
                                                                                            else

                                                                                                set(handles.Tolerances,'Checked','on');
                                                                                                set(handles.TolerancesText,'Enable','on');
                                                                                                set(handles.TolerancesEdit,'Enable','on');


                                                                                                set(handles.Animation,'Checked','off');
                                                                                                set(handles.StartText,'enable','off');
                                                                                                set(handles.StartFluxEdit,'enable','off');
                                                                                                set(handles.StopText,'enable','off');
                                                                                                set(handles.StopFluxEdit,'enable','off');
                                                                                                set(handles.DfText,'enable','off');
                                                                                                set(handles.DfEdit,'enable','off');
                                                                                                set(handles.GoPushButton,'enable','off');
                                                                                                set(handles.ResetPushButton,'enable','off');
                                                                                            end


                                                                                            function varargout=EMTPsave_Callback(h,eventdata,handles,varargin);%#ok

                                                                                                [FileName,PathName]=uiputfile('MyHysteresis.dat','Save EMTP Hysteresis data');

                                                                                                if ischar(FileName)
                                                                                                    HT=get(handles.DisplayPushButton,'UserData');


                                                                                                    fid_1=fopen([PathName,FileName],'w');
                                                                                                    if fid==-1
                                                                                                        return
                                                                                                    end


                                                                                                    PUunits=get(handles.UnitsPopup,'value');
                                                                                                    if PUunits==2
                                                                                                        Ipu=1;
                                                                                                        Fpu=1;
                                                                                                    else
                                                                                                        Ipu=HT.Ipu;
                                                                                                        Fpu=HT.Fpu;
                                                                                                    end

                                                                                                    temps=clock;
                                                                                                    hr=num2str(temps(4));
                                                                                                    min=num2str(temps(5));
                                                                                                    sec=num2str(fix(temps(6)));
                                                                                                    Time=[date,' (',hr,':',min,':',sec,')'];

                                                                                                    fprintf(fid_1,[...
                                                                                                    'C FILE: %s \n',...
                                                                                                    'C DATE: %s \n',...
                                                                                                    'C DESCRIPTION: Created by the power_hysteresis utility. \n',...
                                                                                                    'C 1 pu = %f A, %f V.s \n',...
                                                                                                    'C ---CUR (A)---><--FLUX (V.S)-->\n'],...
                                                                                                    [PathName,FileName],Time,HT.Ipu,HT.Fpu);


                                                                                                    r=length(HT.Fj);
                                                                                                    for n=2:r
                                                                                                        fprintf(fid_1,'%16.6e%16.6e\n',HT.Ij(n)*Ipu,HT.Fj(n)*Fpu);
                                                                                                    end



                                                                                                    last_cur=HT.Ij_sat(2);
                                                                                                    last_flu=HT.Fj_sat(2);
                                                                                                    fprintf(fid_1,'%16.6e%16.6e\n            9999',last_cur*Ipu,last_flu*Fpu);

                                                                                                    fclose(fid_1);
                                                                                                end


                                                                                                function varargout=AutoZoomCheck_Callback(h,eventdata,handles,varargin);%#ok

                                                                                                    HT=get(handles.DisplayPushButton,'UserData');
                                                                                                    AutoZoom=get(handles.AutoZoomCheck,'Value');
                                                                                                    if AutoZoom
                                                                                                        Delta_Is=HT.Is/10;
                                                                                                        Delta_Fs=HT.Fs/10;
                                                                                                        set(handles.axes,'Xlim',[-HT.Is-Delta_Is,HT.Is+Delta_Is]);
                                                                                                        set(handles.axes,'Ylim',[-HT.Fs-Delta_Fs,HT.Fs+Delta_Fs]);
                                                                                                    else
                                                                                                        Lim_F=HT.Fj_sat(end);
                                                                                                        Lim_I=HT.Ij_sat(end);
                                                                                                        set(handles.axes,'Xlim',[-Lim_I,Lim_I]);
                                                                                                        set(handles.axes,'Ylim',[-Lim_F,Lim_F]);
                                                                                                    end
                                                                                                    zoom(handles.axes,'on');
