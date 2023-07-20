classdef VehCalibraDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties
HAppContainer

Parent

EngRzIn

EngRzOut

EngType

Resizedflag
    end

    properties(Access=private)

PerformancePanel
DesignPanel
GridLayout_Design
GridLayout1
GridLayout_P
Ptable
TurbCheck
EgrCheck
TrqSpecCheck
TrqSpdCheck
Thr2Check
DisLabel
DisEdit
CylLabel
CylEdit
ArchiLabel
ArchiOpt
MaxTqLabel
MaxTqEdit
MaxSpdLabel
MaxSpdEdit
showfigbutton
reszbutton
ResizeOpt
        System='SiDynoReferenceApplication';
        Block='SiDynoReferenceApplication/Recalibrate Engine';
        CIBlock='SiDynoReferenceApplication/Recalibrate CI Engine';

        unsized=0

        typechanged=false;
        systemloaded=false;
    end

    properties(Constant)

        EngRzDefaultSIIn=struct(...
        'EngReszSpecType','Displacement',...
        'EngReszMaxPwrDesIn','115.0917',...
        'EngReszNumCylDes','4',...
        'EngReszDispDesIn','1.5',...
        'EngReszArchEngine','Line',...
        'EngReszTurb',true,...
        'EngReszEgr',true,...
        'TrqSpec',false,...
        'TrqSpdSpec',false,...
        'Thr2',false,...
        'EngReszDesMaxTq','228',...
        'EngReszReqMaxTqSpd','2571');

        EngRzDefaultCIIn=struct(...
        'EngReszSpecType','Displacement',...
        'EngReszMaxPwrDesIn','103.7766',...
        'EngReszNumCylDes','4',...
        'EngReszDispDesIn','1.5');



        EngRzDefaultSIOut={...
        'EngReszMaxPwr','Maximum power','kW','115.0917';...
        'EngReszDisp','Engine displacement','L','1.5';...
        'EngReszNumCyl','Number of cylinders','','4';...
        'EngReszIdleSpd','Idle speed','rpm','0';...
        'EngReszMaxTqSpd','Speed of maximum torque','rpm','2571';...
        'EngReszMaxTq','Maximum torque','Nm','228';...
        'EngReszBestFuelPwr','Power for best fuel','kW','41.1';...
        'EngReszBestFuelSpd','Speed for best fuel','rpm','2571';...
        'EngReszBestFuelTq','Torque for best fuel','Nm','152.7';...
        'EngReszBestFuelBSFC','BSFC for best fuel','g/kWh','222.2';...
        'EngReszSpdMaxPwr','Speed for maximum power','rpm','5000';...
        'EngReszTqMaxPwr','Torque for maximum power','Nm','219.8';...
        'EngReszIntkManVol','Intake manifold volume','L','2.86';...
        'EngReszExhManVol','Exhaust manifold volume','L','1.6';...
        'EngReszMaxTurboSpd','Maximum turbo speed','rpm','232000';...
        'EngReszTurboRotInert','Turbo rotor inertia','kg*m^2','0.016';...
        'EngReszInjSlp','Fuel injector slope','mg/ms','6.45';...
        'EngReszThrDiam','Throttle bore diameter','mm','50';...
        'EngReszCompOutVol','Compressor out volumn','L','2.6'};

        EngRzDefaultCIOut={...
        'EngReszMaxPwr','Maximum power','kW','103.7766';...
        'EngReszDisp','Engine displacement','L','1.5';...
        'EngReszNumCyl','Number of cylinders','','4';...
        'EngReszIdleSpd','Idle speed','rpm','500';...
        'EngReszMaxTqSpd','Speed of maximum torque','rpm','2750';...
        'EngReszMaxTq','Maximum torque','Nm','273.6';...
        'EngReszBestFuelPwr','Power for best fuel','kW','66';...
        'EngReszBestFuelSpd','Speed for best fuel','rpm','2750';...
        'EngReszBestFuelTq','Torque for best fuel','Nm','229.3';...
        'EngReszBestFuelBSFC','BSFC for best fuel','g/kWh','196.4';...
        'EngReszSpdMaxPwr','Speed for maximum power','rpm','4000';...
        'EngReszTqMaxPwr','Torque for maximum power','Nm','247.7';...
        'EngReszIntkManVol','Intake manifold volume','L','2.86';...
        'EngReszExhManVol','Exhaust manifold volume','L','0.7';...
        'EngReszMaxTurboSpd','Maximum turbo speed','rpm','237952.67';...
        'EngReszTurboRotInert','Turbo rotor inertia','kg*m^2','0.006';...
        'EngReszInjSlp','Fuel injector slope','mg/ms','6.45',};
    end

    events
EngineResized

    end


    methods

        function obj=VehCalibraDoc(varargin)

            if~isempty(varargin)
                if isscalar(varargin{1})&&isgraphics(varargin{1})

                    varargin=[{'Parent'},varargin];
                end

                set(obj,varargin{:});
            end

            if isempty(obj.Parent)
                obj.Parent=gcf;
            end

            if isempty(obj.EngType)
                obj.EngType=0;
                obj.Block='SiDynoReferenceApplication/Recalibrate Engine';
            end

            if isempty(obj.EngRzIn)
                obj.EngRzIn=obj.EngRzDefaultSIIn;
            end

            if isempty(obj.EngRzOut)
                if(obj.EngType==0)
                    obj.EngRzOut=obj.EngRzDefaultSIOut;
                else
                    obj.EngRzOut=obj.EngRzDefaultCIOut;
                end
            end

            if isempty(obj.Resizedflag)
                obj.Resizedflag=false;
            end

            obj.setupDocLyt();
            obj.changeDesignPanel();

        end

        function set.EngType(obj,value)
            obj.EngType=value;
            obj.changeDesignPanel();
            obj.AdaptResizeLyt();
        end

        function EngTypeChanged(obj,type)
            obj.typechanged=true;
            obj.EngType=type;
        end

    end


    methods(Access=private)

        function setupDocLyt(obj)

            obj.GridLayout1=uigridlayout(obj.Parent,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{'1x','1x'},...
            'Padding',[0,0,0,0],...
            'columnSpacing',10,...
            'BackgroundColor',[1,1,1]);


            obj.DesignPanel=uipanel(obj.GridLayout1,'Title','Design');
            obj.GridLayout_Design=uigridlayout(obj.DesignPanel);
            obj.GridLayout_Design.ColumnWidth={'0.6x','0.4x'};
            obj.GridLayout_Design.RowHeight={'fit','fit','fit','fit',...
            'fit','fit','fit','fit','fit','fit','fit','fit'};


            ResizeLabel=uilabel(obj.GridLayout_Design,...
            'Text','Resize Option:',...
            'Tag','ResizeLabel');
            ResizeLabel.Layout.Row=1;
            ResizeLabel.Layout.Column=1;
            obj.ResizeOpt=uidropdown(obj.GridLayout_Design,...
            'Items',{'Displacement','Power'},...
            'Value',obj.EngRzIn.EngReszSpecType,...
            'Tag','ResizeOpt');
            obj.ResizeOpt.ValueChangedFcn=@(~,event)obj.ResizeOptValueChanged(event);
            obj.ResizeOpt.Layout.Row=1;
            obj.ResizeOpt.Layout.Column=2;


            text='Desired displacement,EngReszDispDesIn[L]:';
            val=str2double(obj.EngRzIn.EngReszDispDesIn);

            obj.DisLabel=uilabel(obj.GridLayout_Design,...
            'Text',text,...
            'WordWrap','on',...
            'Tag','DisLabel');
            obj.DisLabel.Layout.Row=2;
            obj.DisLabel.Layout.Column=1;

            obj.DisEdit=uieditfield(obj.GridLayout_Design,'numeric',...
            'Value',val,...
            'ValueDisplayFormat','%.2f',...
            'Tag','DisEdit');
            obj.DisEdit.Layout.Row=2;
            obj.DisEdit.Layout.Column=2;
            obj.DisEdit.ValueChangedFcn=@(~,event)DisplacementChanged(obj,event);


            obj.CylLabel=uilabel(obj.GridLayout_Design,...
            'Text','Desired number of cylinders,EngReszNumCylDes:',...
            'WordWrap','on',...
            'Tag','CylLabel');
            obj.CylLabel.Layout.Row=3;
            obj.CylLabel.Layout.Column=1;
            obj.CylEdit=uieditfield(obj.GridLayout_Design,'numeric',...
            'ValueDisplayFormat','%.2f',...
            'Limits',[1,20],...
            'Value',str2double(obj.EngRzIn.EngReszNumCylDes),...
            'Tag','CylEdit');
            obj.CylEdit.ValueChangedFcn=@(~,event)NCylChanged(obj,event);
            obj.CylEdit.Layout.Row=3;
            obj.CylEdit.Layout.Column=2;


            obj.ArchiLabel=uilabel(obj.GridLayout_Design,...
            'Text','Architecture:',...
            'Tag','ArchiLabel');
            obj.ArchiLabel.Layout.Row=4;
            obj.ArchiLabel.Layout.Column=1;
            obj.ArchiOpt=uidropdown(obj.GridLayout_Design,...
            'Items',{'Line','V'},...
            'Value','Line',...
            'Tag','ArchiOpt');
            obj.ArchiOpt.Layout.Row=4;
            obj.ArchiOpt.Layout.Column=2;
            obj.ArchiOpt.ValueChangedFcn=@(~,event)obj.ArchiOptValueChanged(event);
            obj.ArchiOpt.Value=obj.EngRzIn.EngReszArchEngine;


            obj.TurbCheck=uicheckbox(obj.GridLayout_Design,...
            'Text','Turbocharger',...
            'Tag','Check1');
            obj.TurbCheck.Layout.Row=5;
            obj.TurbCheck.Layout.Column=1;
            obj.TurbCheck.Value=obj.EngRzIn.EngReszTurb;
            obj.TurbCheck.ValueChangedFcn=@(~,event)TurbCheckChanged(obj,event);


            obj.EgrCheck=uicheckbox(obj.GridLayout_Design,...
            'Text','EGR',...
            'Tag','Check2');
            obj.EgrCheck.Layout.Row=6;
            obj.EgrCheck.Layout.Column=1;
            obj.EgrCheck.Value=obj.EngRzIn.EngReszEgr;
            obj.EgrCheck.ValueChangedFcn=@(~,event)EgrCheckChanged(obj,event);


            obj.TrqSpecCheck=uicheckbox(obj.GridLayout_Design,...
            'Text','Specify Maximum Torque',...
            'WordWrap','on',...
            'Tag','Check3');
            obj.TrqSpecCheck.Value=obj.EngRzIn.TrqSpec;
            obj.TrqSpecCheck.Layout.Row=8;
            obj.TrqSpecCheck.Layout.Column=1;
            obj.TrqSpecCheck.ValueChangedFcn=@(~,event)TrqSpecCheckChanged(obj,event);


            obj.TrqSpdCheck=uicheckbox(obj.GridLayout_Design,...
            'Text','Specify Speed at Maximum Torque',...
            'WordWrap','on',...
            'Tag','Check4');
            obj.TrqSpdCheck.Value=obj.EngRzIn.TrqSpdSpec;
            obj.TrqSpdCheck.Layout.Row=10;
            obj.TrqSpdCheck.Layout.Column=1;
            obj.TrqSpdCheck.ValueChangedFcn=@(~,event)TrqSpdCheckChanged(obj,event);


            obj.Thr2Check=uicheckbox(obj.GridLayout_Design,...
            'Text','Twin Intake',...
            'Tag','Check5');
            obj.Thr2Check.Value=obj.EngRzIn.Thr2;
            obj.Thr2Check.Layout.Row=7;
            obj.Thr2Check.Layout.Column=1;
            obj.Thr2Check.Enable=false;
            obj.Thr2Check.ValueChangedFcn=@(~,event)Thr2CheckChanged(obj,event);

            obj.MaxTqLabel=uilabel(obj.GridLayout_Design,...
            'Text','EngReszDesMaxTq [Nm]:',...
            'Enable',false,...
            'WordWrap','on',...
            'Tag','MaxTqLabel');
            obj.MaxTqLabel.Layout.Row=9;
            obj.MaxTqLabel.Layout.Column=1;





            if obj.TrqSpecCheck.Value
                MaxTqEditEnable=true;
            else
                MaxTqEditEnable=false;
            end

            obj.MaxTqEdit=uieditfield(obj.GridLayout_Design,'numeric',...
            'ValueDisplayFormat','%.2f',...
            'Value',str2double(obj.EngRzIn.EngReszDesMaxTq),...
            'Enable',MaxTqEditEnable,...
            'Tag','MaxTqEdit');
            obj.MaxTqEdit.ValueChangedFcn=@(~,event)MaxTqChanged(obj,event);
            obj.MaxTqEdit.Layout.Row=9;
            obj.MaxTqEdit.Layout.Column=2;


            obj.MaxSpdLabel=uilabel(obj.GridLayout_Design,...
            'Text','EngReszDesMaxTqSpd [Nm]:',...
            'Enable',false,...
            'WordWrap','on',...
            'Tag','MaxSpdLabel');
            obj.MaxSpdLabel.Layout.Row=11;
            obj.MaxSpdLabel.Layout.Column=1;
            obj.MaxSpdEdit=uieditfield(obj.GridLayout_Design,'numeric',...
            'ValueDisplayFormat','%.2f',...
            'Value',str2double(obj.EngRzIn.EngReszReqMaxTqSpd),...
            'Enable',false,...
            'Tag','MaxSpdEdit');
            obj.MaxSpdEdit.ValueChangedFcn=@(~,event)MaxSpdChanged(obj,event);
            obj.MaxSpdEdit.Layout.Row=11;
            obj.MaxSpdEdit.Layout.Column=2;
            if obj.TrqSpdCheck.Value
                obj.MaxSpdEdit.Enable=true;
            end

            obj.reszbutton=uibutton(obj.GridLayout_Design,...
            'Text','Resize Engine',...
            'Tag','reszbutton');
            obj.reszbutton.Layout.Row=12;
            obj.reszbutton.Layout.Column=1;
            obj.reszbutton.ButtonPushedFcn=@(~,event)ResizeEngine(obj);


            obj.PerformancePanel=uipanel(obj.GridLayout1,'Title','Performance');
            obj.GridLayout_P=uigridlayout(obj.PerformancePanel);
            obj.GridLayout_P.ColumnWidth={'1x'};
            obj.GridLayout_P.RowHeight={'1x','fit'};

            if(obj.EngType==0)
                Out=obj.EngRzDefaultSIOut(:,2:4);
            else
                Out=obj.EngRzDefaultCIOut(:,2:4);
            end

            obj.Ptable=uitable(obj.GridLayout_P,...
            'ColumnName',{'Name','Unit','Value'},...
            'Data',Out,...
            'Tag','Ptable');

            s=uistyle('FontColor',[0.5,0.5,0.5]);
            addStyle(obj.Ptable,s,'column',3);

            obj.showfigbutton=uibutton(obj.GridLayout_P,...
            'Text','Plot Performance',...
            'Tag','showfigbutton');
            obj.showfigbutton.Layout.Row=2;
            obj.showfigbutton.Layout.Column=1;
            obj.showfigbutton.Enable=false;
            obj.showfigbutton.ButtonPushedFcn=@(~,event)ShowFigures(obj);

            AdaptResizeLyt(obj);

            drawnow();
        end


        function ResizeEngine(obj)
            if obj.checksimstopped

                txt='Engine Resizing...';

                fig=obj.HAppContainer.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.1;

                obj.showfigbutton.Enable=false;

                if(obj.EngType==0)
                    try
                        reszok=autoblkssiengresize(obj.Block,'resizenomsk');
                    catch
                        reszok=false;
                    end
                    obj.unsized=1;
                else
                    try
                        reszok=autoblksciengresize(obj.Block,'resizenomsk');
                    catch
                        reszok=false;
                    end
                    obj.unsized=2;
                end

                if reszok

                    d.Value=.5;

                    obj.updatePtable();

                    if(obj.EngType==0)
                        obj.EngRzOut=[obj.EngRzDefaultSIOut(:,1),obj.Ptable.Data];
                    else
                        obj.EngRzOut=[obj.EngRzDefaultCIOut(:,1),obj.Ptable.Data];
                    end

                    obj.Resizedflag=true;

                    obj.showfigbutton.Enable=true;
                    d.Value=.8;

                    save_system(obj.System,'SaveDirtyReferencedModels','on');

                    obj.HAppContainer.EngRzResult.EngRzIn=obj.EngRzIn;
                    obj.HAppContainer.EngRzResult.EngRzOut=obj.EngRzOut;
                    obj.HAppContainer.EngRzResult.EngineResizedFlag=obj.Resizedflag;

                    notify(obj,'EngineResized');
                    d.Value=1;
                    close(d);
                else
                    obj.Resizedflag=false;
                    obj.HAppContainer.EngRzResult.EngRzIn=[];
                    obj.HAppContainer.EngRzResult.EngRzOut=[];
                    obj.HAppContainer.EngRzResult.EngineResizedFlag=false;
                    d.Value=1;
                    close(d);
                end
            end

        end

        function updatePtable(obj)

            if(obj.EngType==1)
                in=obj.EngRzDefaultCIOut;
            else
                in=obj.EngRzDefaultSIOut;
            end

            for i=1:length(in)
                dataname=in{i,1};
                entryval=get_param(obj.Block,dataname);
                in{i,4}=entryval;
            end
            obj.EngRzOut=in;
            obj.Ptable.Data=obj.EngRzOut(:,2:4);


        end

        function ShowFigures(obj)

            if checksimstopped(obj)

                sysname=obj.System;
                resultsblkname=[sysname,'/Performance Monitor'];
                if(obj.EngType==0)
                    setsimout(obj,'SteadyWsVarName','SteadyDynoSimOut');
                    setsimout(obj,'DynWsVarName','DynamicDynoSimOut');
                else
                    setsimout(obj,'SteadyWsVarName','CISteadyDynoSimOut');
                    setsimout(obj,'DynWsVarName','CIDynamicDynoSimOut');
                end

                DynoResultsBlock(resultsblkname,...
                'PlotDynamicButtonCallback');
                DynoResultsBlock(resultsblkname,...
                'PlotSteadyButtonCallback');

                if(obj.EngType==0)
                    RecalibrateSIController(resultsblkname,...
                    'ApplyPlots');
                else
                    RecalibrateCIController(resultsblkname,...
                    'ApplyPlots');
                end

            end
        end

        function ResizeOptValueChanged(obj,event)

            if checksimstopped(obj)
                obj.changeDesignPanel();
                AdaptResizeLyt(obj);

                set_param(obj.Block,'EngReszSpecType',event.Value);
                obj.EngRzIn.EngReszSpecType=event.Value;

                updateOpt(obj,event.Value);

            end
        end

        function updateOpt(obj,in)

            if strcmp(in,'Power')
                val=get_param(obj.Block,'EngReszMaxPwrDesIn');


                obj.EngRzIn.EngReszMaxPwrDesIn=val;

            else
                val=get_param(obj.Block,'EngReszDispDesIn');


                obj.DisEdit.Value=str2double(val);
                obj.EngRzIn.EngReszDispDesIn=val;

            end

            val=get_param(obj.Block,'EngReszNumCylDes');
            obj.CylEdit.Limits=[1,20];
            obj.CylEdit.Value=str2double(val);
            obj.EngRzIn.EngReszNumCylDes=val;

        end

        function AdaptResizeLyt(obj)
            if~isempty(obj.ResizeOpt)
                if(obj.EngType==0)
                    if strcmp(obj.ResizeOpt.Value,'Power')
                        obj.DisLabel.Text='Desired maximum power, EngReszMaxPwrDesIn [kW]:';
                        obj.DisEdit.Value=str2double(obj.EngRzIn.EngReszMaxPwrDesIn);
                        obj.TrqSpecCheck.Enable=false;
                        obj.TrqSpdCheck.Enable=false;
                        obj.MaxTqLabel.Enable=false;
                        obj.MaxTqEdit.Enable=false;
                        obj.MaxSpdLabel.Enable=false;
                        obj.MaxSpdEdit.Enable=false;
                    else
                        obj.DisLabel.Text='Desired displacement, EngReszDispDesIn [L]:';
                        obj.DisEdit.Value=str2double(obj.EngRzIn.EngReszDispDesIn);
                        obj.TrqSpecCheck.Enable=true;
                        obj.TrqSpdCheck.Enable=true;
                        if obj.TrqSpecCheck.Value
                            obj.MaxTqLabel.Enable=true;
                            obj.MaxTqEdit.Enable=true;
                        else
                            obj.MaxTqLabel.Enable=false;
                            obj.MaxTqEdit.Enable=false;
                        end

                        if obj.TrqSpdCheck.Value
                            obj.MaxSpdLabel.Enable=true;
                            obj.MaxSpdEdit.Enable=true;
                        else
                            obj.MaxSpdLabel.Enable=false;
                            obj.MaxSpdEdit.Enable=false;
                        end
                    end
                else
                    if strcmp(obj.ResizeOpt.Value,'Power')
                        obj.DisLabel.Text='Desired maximum power, EngReszMaxPwrDesIn [kW]:';
                        obj.DisEdit.Value=str2double(obj.EngRzIn.EngReszMaxPwrDesIn);
                    else
                        obj.DisLabel.Text='Desired displacement, EngReszDispDesIn [L]:';
                        obj.DisEdit.Value=str2double(obj.EngRzIn.EngReszDispDesIn);

                    end

                end
            end
        end

        function ArchiOptValueChanged(obj,event)

            if checksimstopped(obj)

                if strcmp(event.Value,'V')
                    obj.Thr2Check.Enable=true;
                else
                    obj.Thr2Check.Enable=false;
                end

                set_param(obj.Block,'EngReszArchEngine',event.Value);
                obj.EngRzIn.EngReszArchEngine=event.Value;
            end
        end

        function DisplacementChanged(obj,event)


            if checksimstopped(obj)

                val=num2str(event.Value);

                if strcmp(obj.ResizeOpt.Value,'Displacement')
                    set_param(obj.Block,'EngReszDispDesIn',val);
                    obj.EngRzIn.EngReszDispDesIn=val;




                else
                    set_param(obj.Block,'EngReszMaxPwrDesIn',val);
                    obj.EngRzIn.EngReszMaxPwrDesIn=val;
                end
                obj.AdaptResizeLyt();

            end
        end

        function NCylChanged(obj,event)


            if checksimstopped(obj)
                set_param(obj.Block,'EngReszNumCylDes',num2str(event.Value));
                obj.EngRzIn.EngReszNumCylDes=num2str(event.Value);
            end
        end

        function TurbCheckChanged(obj,event)

            if checksimstopped(obj)

                if(event.Value)
                    val='on';
                else
                    val='off';
                end

                set_param(obj.Block,'EngReszTurb',val);
                obj.EngRzIn.EngReszTurb=num2str(event.Value);
            end
        end

        function EgrCheckChanged(obj,event)

            if checksimstopped(obj)

                if(event.Value)
                    val='on';
                else
                    val='off';
                end

                set_param(obj.Block,'EngReszEgr',val);
                obj.EngRzIn.EngReszEgr=num2str(event.Value);
            end
        end

        function TrqSpecCheckChanged(obj,event)

            if checksimstopped(obj)

                if(event.Value)
                    obj.MaxTqLabel.Enable=true;
                    obj.MaxTqEdit.Enable=true;
                    val='on';
                else
                    obj.MaxTqLabel.Enable=false;
                    obj.MaxTqEdit.Enable=false;
                    val='off';
                end

                set_param(obj.Block,'TrqSpec',val);
                obj.EngRzIn.TrqSpec=num2str(event.Value);
            end
        end


        function TrqSpdCheckChanged(obj,event)

            if checksimstopped(obj)

                if(event.Value)
                    obj.MaxSpdLabel.Enable=true;
                    obj.MaxSpdEdit.Enable=true;
                    val='on';
                else
                    obj.MaxSpdLabel.Enable=false;
                    obj.MaxSpdEdit.Enable=false;
                    val='off';
                end

                set_param(obj.Block,'TrqSpdSpec',val);
                obj.EngRzIn.TrqSpdSpec=event.Value;
            end
        end

        function Thr2CheckChanged(obj,event)

            if checksimstopped(obj)

                if(event.Value)
                    val='on';
                else
                    val='off';
                end

                set_param(obj.Block,'Thr2',val);
                obj.EngRzIn.Thr2=event.Value;
            end
        end

        function MaxTqChanged(obj,event)

            if checksimstopped(obj)
                val=num2str(event.Value);
                set_param(obj.Block,'EngReszDesMaxTq',val);
                obj.EngRzIn.EngReszDesMaxTq=val;
            end
        end

        function MaxSpdChanged(obj,event)

            if checksimstopped(obj)
                val=num2str(event.Value);
                set_param(obj.Block,'EngReszReqMaxTqSpd',val);
                obj.EngRzIn.EngReszReqMaxTqSpd=val;
            end
        end

        function changeDesignPanel(obj)
            if checksimstopped(obj)

                if(obj.EngType==0)

                    obj.Block='SiDynoReferenceApplication/Recalibrate Engine';

                    if~isempty(obj.TurbCheck)

                        obj.TurbCheck.Visible='on';
                        obj.EgrCheck.Visible='on';
                        obj.TrqSpecCheck.Visible='on';
                        obj.TrqSpdCheck.Visible='on';
                        obj.Thr2Check.Visible='on';

                        obj.ArchiLabel.Visible='on';
                        obj.ArchiOpt.Visible='on';
                        obj.MaxTqLabel.Visible='on';
                        obj.MaxTqEdit.Visible='on';
                        obj.MaxSpdLabel.Visible='on';
                        obj.MaxSpdEdit.Visible='on';
                        drawnow();
                    end

                    if~isempty(obj.EgrCheck)
                        obj.EgrCheck.Parent=obj.GridLayout_Design;
                    end

                    if~isempty(obj.ArchiLabel)
                        obj.ArchiLabel.Parent=obj.GridLayout_Design;
                    end


                    if~isempty(obj.ResizeOpt)&&strcmp(obj.ResizeOpt.Value,'Displacement')
                        obj.TrqSpecCheck.Parent=obj.GridLayout_Design;
                        obj.TrqSpdCheck.Parent=obj.GridLayout_Design;

                        obj.MaxTqLabel.Parent=obj.GridLayout_Design;
                        obj.MaxTqEdit.Parent=obj.GridLayout_Design;

                        obj.MaxSpdLabel.Parent=obj.GridLayout_Design;
                        obj.MaxSpdEdit.Parent=obj.GridLayout_Design;
                        drawnow();
                    end

                    if~isempty(obj.ArchiOpt)
                        obj.ArchiOpt.Parent=obj.GridLayout_Design;
                        obj.ArchiOpt.Enable=true;
                        if strcmp(obj.ArchiOpt.Value,'V')
                            obj.Thr2Check.Parent=obj.GridLayout_Design;
                            obj.Thr2Check.Enable=true;
                        end
                        drawnow();
                    end

                else

                    obj.Block='SiDynoReferenceApplication/Recalibrate CI Engine';

                    obj.TurbCheck.Visible='off';
                    obj.EgrCheck.Visible='off';
                    obj.TrqSpecCheck.Visible='off';
                    obj.TrqSpdCheck.Visible='off';
                    obj.Thr2Check.Visible='off';

                    obj.ArchiLabel.Visible='off';
                    obj.ArchiOpt.Visible='off';
                    obj.MaxTqLabel.Visible='off';
                    obj.MaxTqEdit.Visible='off';
                    obj.MaxSpdLabel.Visible='off';
                    obj.MaxSpdEdit.Visible='off';
                    drawnow();

                end


                if~isempty(obj.ResizeOpt)
                    in=obj.ResizeOpt.Value;
                    obj.updateOpt(in);
                end

                if~isempty(obj.Ptable)
                    if~obj.Resizedflag
                        obj.Ptable.Data=obj.EngRzOut(:,2:4);
                    else
                        obj.updatePtable();
                    end
                end
            end
        end


        function simstopped=checksimstopped(obj)


            tf=bdIsLoaded(obj.System);
            if~tf
                txt='Loading Engine Resize Project...';
                fig=obj.HAppContainer.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.5;
                load_system('SiDynoReferenceApplication');
                d.Value=1;
                close(d);
            end

            try
                simstopped=autoblkschecksimstopped(obj.Block);
            catch
                simstopped=false;
            end
        end

        function setsimout(obj,mskparmname,mskparm)
            sysname=obj.System;
            resultsblkname=[sysname,'/Performance Monitor'];
            simoutname=get_param(resultsblkname,mskparmname);
            if~strcmp(simoutname,mskparm)
                set_param(resultsblkname,mskparmname,mskparm);
                save_system(sysname,'SaveDirtyReferencedModels',true);
            end
        end

    end

end