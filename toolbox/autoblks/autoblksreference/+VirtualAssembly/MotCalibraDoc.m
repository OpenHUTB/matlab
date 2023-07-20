classdef MotCalibraDoc<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties

HAppContainer

Parent

BlockName

BlockParams
    end

    properties(Access=private)

PerformancePanel
DesignPanel
GridLayout_Design
GridLayout1
GridLayout_P
Ptable
ResizedPwrLabel
ResizedPwrEdit
ResizedTqLabel
ResizedTqEdit
ResizedCPSRLabel
ResizedCPSREdit
ResizedDCLinkVLabel
ResizedDCLinkVEdit
Reszbutton
Showfigbutton
ShowTestbutton
        System='MotDynoReferenceApplication';
        Block='MotDynoReferenceApplication/Resize Mapped Motors';
        MotorBlk='MotDynoReferenceApplication/Motor System/Motor & Inverter Plant/Mapped Motor Model/Mapped Motor';

        MotRzDefaultIn=struct(...
        'P_new',210e3,...
        'T_rated_new',450);



        MotRzDefaultOut={...
        'P_rated','Rated Power','W','211000';...
        'T_rated','Rated Torque','Nm','450';};



Power
Torque


    end

    events
MotorResized
    end


    methods

        function obj=MotCalibraDoc(varargin)
            if~isempty(varargin)
                if isscalar(varargin{1})&&isgraphics(varargin{1})

                    varargin=[{'Parent'},varargin];
                end

                set(obj,varargin{:});
            end

            if isempty(obj.Parent)
                obj.Parent=gcf;
            end

            obj.setupDocLyt();
            obj.initMotorBlk();

        end


        function set.Power(obj,value)
            obj.Power=value;
            setPower(obj,value);
        end

        function set.Torque(obj,value)
            obj.Torque=value;
            setTorque(obj,value);
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
            obj.GridLayout_Design.RowHeight={'fit','fit','fit','fit','fit'};

            obj.ResizedPwrLabel=uilabel(obj.GridLayout_Design,...
            'Text','Desired power[W]:',...
            'WordWrap','on');
            obj.ResizedPwrLabel.Layout.Row=1;
            obj.ResizedPwrLabel.Layout.Column=1;
            V=obj.MotRzDefaultIn.P_new;
            Val=round(V*100)/100;
            obj.ResizedPwrEdit=uieditfield(obj.GridLayout_Design,'text',...
            'Value',num2str(Val),...
            'Tag','ResizedPwrEdit');
            obj.ResizedPwrEdit.Layout.Row=1;
            obj.ResizedPwrEdit.Layout.Column=2;
            obj.ResizedPwrEdit.ValueChangedFcn=@(~,event)ResizedPwrChanged(obj,event);

            obj.ResizedTqLabel=uilabel(obj.GridLayout_Design,...
            'Text','Desired torque[Nm]:',...
            'WordWrap','on');
            obj.ResizedTqLabel.Layout.Row=2;
            obj.ResizedTqLabel.Layout.Column=1;
            V=obj.MotRzDefaultIn.T_rated_new;
            Val=round(V*100)/100;
            obj.ResizedTqEdit=uieditfield(obj.GridLayout_Design,'text',...
            'Value',num2str(Val),...
            'Tag','ResizedTqEdit');
            obj.ResizedTqEdit.Layout.Row=2;
            obj.ResizedTqEdit.Layout.Column=2;
            obj.ResizedTqEdit.ValueChangedFcn=@(~,event)ResizedTqChanged(obj,event);

            obj.Reszbutton=uibutton(obj.GridLayout_Design,...
            'Text','Resize Motor');
            obj.Reszbutton.Layout.Row=5;
            obj.Reszbutton.Layout.Column=1;
            obj.Reszbutton.ButtonPushedFcn=@(~,event)ResizeMotor(obj);


            obj.PerformancePanel=uipanel(obj.GridLayout1,'Title','Performance');
            obj.GridLayout_P=uigridlayout(obj.PerformancePanel);
            obj.GridLayout_P.ColumnWidth={'1x'};
            obj.GridLayout_P.RowHeight={'1x','fit','fit'};

            obj.Ptable=uitable(obj.GridLayout_P,...
            'ColumnName',{'Name','Unit','Value'},...
            'Data',obj.MotRzDefaultOut(:,2:4));


            s1=uistyle('FontColor',[0.5,0.5,0.5]);
            addStyle(obj.Ptable,s1,'column',3);

            obj.Showfigbutton=uibutton(obj.GridLayout_P,...
            'Text','Plot Performance');
            obj.Showfigbutton.Layout.Row=2;
            obj.Showfigbutton.Layout.Column=1;
            obj.Showfigbutton.Enable=true;
            obj.Showfigbutton.ButtonPushedFcn=@(~,event)ShowFigures(obj);

            obj.ShowTestbutton=uibutton(obj.GridLayout_P,...
            'Text','Run Performance Test');
            obj.ShowTestbutton.Layout.Row=3;
            obj.ShowTestbutton.Layout.Column=1;
            obj.ShowTestbutton.Enable=true;
            obj.ShowTestbutton.ButtonPushedFcn=@(~,event)ShowTest(obj);

            drawnow();
        end

        function ResizeMotor(obj)
            if obj.checksimstopped
                txt='Motor Resizing...';
                set_param(obj.Block,'P_new',num2str(obj.Power));
                set_param(obj.Block,'T_rated_new',num2str(obj.Torque));

                fig=obj.HAppContainer.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.1;

                try


                    autoicon('autoblksmotorresizeCb',obj.Block,'resize');
                    ok=true;
                catch
                    warndlg('Motor Resize is not successful!');
                    ok=false;
                end

                if ok
                    d.Value=0.5;


                    obj.updatePerfomanceParas();

                    d.Value=0.8;
                    obj.Showfigbutton.Enable=true;

                    w_t=get_param(obj.MotorBlk,'w_t');
                    T_t=get_param(obj.MotorBlk,'T_t');
                    T_eff_bp=get_param(obj.MotorBlk,'T_eff_bp');
                    efficiency_table=get_param(obj.MotorBlk,'efficiency_table');

                    obj.BlockParams={w_t,T_t,T_eff_bp,efficiency_table};

                    save_system(obj.System);

                    if strcmp(obj.BlockName,'Electric Machine (Motor)')
                        obj.HAppContainer.MotRzResult.MotorResizedFlag=true;
                        obj.HAppContainer.MotRzResult.BlockParams=obj.BlockParams;


                    else
                        obj.HAppContainer.GtorRzResult.GtorResizedFlag=true;
                        obj.HAppContainer.GtorRzResult.BlockParams=obj.BlockParams;


                    end

                    d.Value=1;
                    notify(obj,'MotorResized');
                    close(d);
                else
                    d.Value=1;
                    close(d);
                    if strcmp(obj.BlockName,'Electric Machine (Motor)')
                        obj.HAppContainer.MotRzResult.MotorResizedFlag=false;
                        obj.HAppContainer.MotRzResult.BlockParams=obj.BlockParams;


                    else
                        obj.HAppContainer.GtorRzResult.GtorResizedFlag=false;
                        obj.HAppContainer.GtorRzResult.BlockParams=obj.BlockParams;


                    end

                end

            end


        end

        function updatesldd(obj)

            dictionaryObj=Simulink.data.dictionary.open('VirtualVehicleTemplate.sldd');
            dDataSectObj=getSection(dictionaryObj,'Design Data');

            if strcmp(obj.BlockName,'Electric Machine (Motor)')

                dObj=getEntry(dDataSectObj,'PlntEM1Spd');
                setValue(dObj,w_t);
                dObj=getEntry(dDataSectObj,'PlntEM1Trq');
                setValue(dObj,T_t);
                dObj=getEntry(dDataSectObj,'PlntEM1TrqEff');
                setValue(dObj,T_eff_bp);
                dObj=getEntry(dDataSectObj,'PlntEM1EffTbl');
                setValue(dObj,efficiency_table);
            else

                dObj=getEntry(dDataSectObj,'PlntEM2Spd');
                setValue(dObj,w_t);
                dObj=getEntry(dDataSectObj,'PlntEM2Trq');
                setValue(dObj,T_t);
                dObj=getEntry(dDataSectObj,'PlntEM2TrqEff');
                setValue(dObj,T_eff_bp);
                dObj=getEntry(dDataSectObj,'PlntEM2EffTbl');
                setValue(dObj,efficiency_table);
            end

        end

        function ShowFigures(obj)
            autoicon('autoblksmotorresizeCb',obj.Block,'plotCharacteristics');
        end

        function ShowTest(obj)

            txt='Runing performance test...';
            fig=obj.HAppContainer.FeatureBrowserFigure;
            d=uiprogressdlg(fig,'Title','Please Wait',...
            'Message',txt);
            d.Value=.5;
            sim(obj.System);
            try
                autoicon('autoblksmotorresizeCb',[obj.System,'/Resize Mapped Motors'],'plotResults');
                d.Value=1;
                close(d);
            catch
                d.Value=1;
                close(d);
            end
        end

        function ResizedPwrChanged(obj,event)
            try
                val=eval(event.Value);

                if val>0&&val<=1e6
                    obj.Power=val;
                end
            catch
                obj.ResizedPwrEdit.Value=event.PreviousValue;
                obj.Power=str2double(event.PreviousValue);
                warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidResizedMotorPower').getString);
            end

        end

        function ResizedTqChanged(obj,event)
            try
                val=eval(event.Value);

                if val>0&&val<=11e3
                    obj.Torque=val;
                end
            catch
                obj.ResizedTqEdit.Value=event.PreviousValue;
                obj.Torque=str2double(event.PreviousValue);
                warndlg(message('autoblks_reference:autoerrVirtualAssembly:InvalidResizedMotorTorque').getString);
            end
        end

        function updatePerfomanceParas(obj)
            for i=1:size(obj.Ptable.Data,1)
                obj.Ptable.Data{i,3}=get_param(obj.Block,obj.MotRzDefaultOut{i,1});
            end
        end

        function setPower(obj,value)
            value=round(value*100)/100;
            val=num2str(value);
            obj.ResizedPwrEdit.Value=val;
            set_param(obj.Block,'P_new',val);
        end

        function setTorque(obj,value)
            value=round(value*100)/100;
            val=num2str(value);
            obj.ResizedTqEdit.Value=val;
            set_param(obj.Block,'T_rated_new',val);
        end













        function initMotorBlk(obj)
            if obj.checksimstopped&&~isempty(obj.BlockParams)

                Spd=str2num(obj.BlockParams{1});
                Trq=str2num(obj.BlockParams{2});


                set_param(obj.MotorBlk,'w_t',obj.BlockParams{1},...
                'w_eff_bp',obj.BlockParams{1},...
                'T_t',obj.BlockParams{2},...
                'T_eff_bp',obj.BlockParams{3},...
                'efficiency_table',obj.BlockParams{4});



                Pwr=Spd.*Trq;
                obj.Power=max(Pwr);
                obj.Torque=max(Trq);
                value=obj.Power;
                value=round(value*100)/100;
                obj.ResizedPwrEdit.Value=num2str(value);
                value=obj.Torque;
                value=round(value*100)/100;
                obj.ResizedTqEdit.Value=num2str(value);

                set_param(obj.Block,...
                'P_rated',num2str(obj.Power),...
                'T_rated',num2str(obj.Torque),...
                'P_new',num2str(obj.Power),...
                'T_rated_new',num2str(obj.Torque));




                obj.Ptable.Data{1,3}=obj.Power;
                obj.Ptable.Data{2,3}=obj.Torque;

            end
        end



        function simstopped=checksimstopped(obj)

            tf=bdIsLoaded(obj.System);
            if~tf
                txt='Loading Motor Resize Project...';
                fig=obj.HAppContainer.FeatureBrowserFigure;
                d=uiprogressdlg(fig,'Title','Please Wait',...
                'Message',txt);
                d.Value=.5;

                load_system('MotDynoReferenceApplication');
                d.Value=1;
                close(d);
            end

            try
                simstopped=autoblkschecksimstopped(obj.Block);
            catch
                simstopped=false;
            end
        end


    end

end