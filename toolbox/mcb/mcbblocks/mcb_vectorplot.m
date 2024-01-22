classdef mcb_vectorplot<matlab.System

    properties(Access=protected)
        axLim=1;
        history=100;
        updateFreq=1000;
    end

    properties(Nontunable)

        OpenFigAtSimStart(1,1)logical=true;
        RotatingReferenceFrame(1,1)logical=true;
        InputSignals=message('mcb:blocks:ABCInput').getString(matlab.internal.i18n.locale("en"));
        ReferenceFrame=message('mcb:blocks:rotatingFrame').getString(matlab.internal.i18n.locale("en"));

        axisAlign='D-axis';

        thetaUnits='Radians';

        angleUnits='Radians';
        debugEnable=0;
    end


    properties(Constant,Hidden)
        InputSignalsSet=matlab.system.StringSet({message('mcb:blocks:ABCInput').getString(matlab.internal.i18n.locale("en")),...
        message('mcb:blocks:DQInput').getString(matlab.internal.i18n.locale("en")),...
        message('mcb:blocks:PolarInput').getString(matlab.internal.i18n.locale("en"))});
        ReferenceFrameSet=matlab.system.StringSet({message('mcb:blocks:stationaryFrame').getString(matlab.internal.i18n.locale("en")),...
        message('mcb:blocks:rotatingFrame').getString(matlab.internal.i18n.locale("en"))});
        axisAlignSet=matlab.system.StringSet({'D-axis','Q-axis'});
        thetaUnitsSet=matlab.system.StringSet({'Per-unit','Radians','Degrees'});
        angleUnitsSet=matlab.system.StringSet({'Per-unit','Radians','Degrees'});
    end


    properties(Constant,Access=protected)
        stationaryFrame=message('mcb:blocks:stationaryFrame').getString(matlab.internal.i18n.locale("en"));
        rotatingFrame=message('mcb:blocks:rotatingFrame').getString(matlab.internal.i18n.locale("en"));
        abcinput=message('mcb:blocks:ABCInput').getString(matlab.internal.i18n.locale("en"));
        dqinput=message('mcb:blocks:DQInput').getString(matlab.internal.i18n.locale("en"));
        polarinput=message('mcb:blocks:PolarInput').getString(matlab.internal.i18n.locale("en"));
    end


    properties(Access=private)
        Fig;
        AxObj;
        dplot;
        dCirplot;
        darrowplot;

        l;
        cir;
        hhh;

        FigureTag='';
        arrow;
        color_line;
        DialogFig;
        DialogTag;
        prvSimValue;
        lastVal=0;

        f;
        flag;
        update;
        lgd;

        axesButton;
        clearButton;
        autoCheckBox;
        blkHandle;
        numVectors=0;
    end


    methods
        function obj=mcb_vectorplot(varargin)
            obj.color_line={'red';'blue';'green';'yellow';'magenta';'cyan'};
        end
    end


    methods(Access=protected)

        function setupImpl(obj)
            if coder.target('MATLAB')
                obj.flag=0;
                obj.f=0;
                obj.update=1;
                obj.lastVal=0;
                obj.blkHandle=get_param(gcb,'Handle');
                [obj.FigureTag,obj.DialogTag]=obj.getUniqueTag(obj.blkHandle);
                [obj.Fig,obj.DialogFig]=obj.setupFigure(obj.FigureTag,obj.DialogTag,obj.blkHandle);
                obj.Fig.UserData=obj.blkHandle;
                name=get_param(obj.blkHandle,'Name');
                set(obj.Fig,'name',name);
                set(obj.DialogFig,'name',strcat('Preferences: ',name));
                obj.Fig.Visible='off';
                obj.FigureParam(obj.blkHandle);

                xx=[0,1,.9,1,.9].';
                yy=[0,0,.08,0,-.08].';
                obj.arrow=xx+yy.*sqrt(-1);

                if obj.OpenFigAtSimStart
                    obj.Fig.Visible='on';
                end

                icons=[];
                if isempty(icons)
                    icons=load('plot_icons.mat');
                end
                c=findall(obj.Fig,'Type','uitoolbar');
                b=findall(c,'Type','uipushtool');
                b(4).ClickedCallback=@obj.showDialog;
                d=findall(c,'Type','uitoggletool');
                if obj.f==0
                    b(3).CData=icons.pause;
                    b(3).Tooltip=message('mcb:blocks:PauseSim').getString(matlab.internal.i18n.locale("en"));
                    b(2).Enable='on';
                else
                    b(3).CData=icons.run;
                    b(3).Tooltip=message('mcb:blocks:RunSim').getString(matlab.internal.i18n.locale("en"));
                    b(2).Enable='on';
                end
                b(1).ClickedCallback=@obj.clearHistory_callback;
                d(2).ClickedCallback=@obj.insertLegend;
                d(1).ClickedCallback=@obj.autoScale_callback;
                if(~isempty(obj.prvSimValue))
                    d(1).State=obj.prvSimValue.autoScale;
                    obj.autoCheckBox.Value=obj.prvSimValue.autoScale;
                    if(d(1).State)
                        obj.axesButton.Enable='off';
                    else
                        obj.axesButton.Enable='on';
                    end
                else
                    d(1).State=1;
                    obj.autoCheckBox.Value=1;
                end
            end
        end


        function releaseImpl(obj)

            if coder.target('MATLAB')
                icons=[];
                if isempty(icons)
                    icons=load('plot_icons.mat');
                end
                temp=struct('limit',obj.axLim,'history',obj.history,...
                'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                'autoScale',obj.autoCheckBox.Value,...
                'strg',{obj.lgd.String});
                set_param(obj.blkHandle,'UserData',temp);
                set_param(obj.blkHandle,'UserDataPersistent','on');
                c=findall(obj.Fig,'Type','uitoolbar');
                b=findall(c,'Type','uipushtool');
                b(3).CData=icons.run;
                b(2).Enable='off';
            end
        end


        function FigureParam(obj,blkh)
            delete(findall(obj.Fig,'Type','Line'));
            delete(findall(obj.Fig,'Type','Text'));
            obj.prvSimValue=get_param(blkh,'UserData');
            if(~isempty(obj.prvSimValue))
                obj.axLim=obj.prvSimValue.limit;
                obj.history=obj.prvSimValue.history;
            end
            obj.CreateDialogBox(obj.DialogFig);

            obj.AxObj=axes('Parent',obj.Fig,'Units','normalized',...
            'Position',[0.1,0.15,0.8,0.8]);
            axis(obj.AxObj,[-obj.axLim,obj.axLim,-obj.axLim,obj.axLim],'square');
            obj.AxObj.Toolbar=axtoolbar(obj.AxObj,{'zoomin','zoomout','restoreview'});
            obj.AxObj.NextPlot='add';

            obj.setaxes();
            disableDefaultInteractivity(obj.AxObj);
        end


        function insertLegend(obj,hObject,~)
            if hObject.State
                obj.lgd.Visible='on';
                obj.lgd.Location='bestoutside';
            else
                obj.lgd.Visible='off';
            end
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if(strcmp(prop,'ReferenceFrame'))
                flag=~strcmp(obj.InputSignals,obj.abcinput);
            end
            if(strcmp(prop,'axisAlign'))
                flag=((~strcmp(obj.InputSignals,obj.abcinput))||(strcmp(obj.ReferenceFrame,obj.stationaryFrame)));
            end
            if(strcmp(prop,'thetaUnits'))
                flag=((~strcmp(obj.InputSignals,obj.abcinput))||(strcmp(obj.ReferenceFrame,obj.stationaryFrame)));
            end
            if(strcmp(prop,'angleUnits'))
                flag=~strcmp(obj.InputSignals,obj.polarinput);
            end
            if(strcmp(prop,'debugEnable'))
                flag=true;
            end
        end


        function showDialog(obj,~,~)
            obj.DialogFig.Visible='on';
            figure(obj.DialogFig);
        end


        function icon=getIconImpl(~)
            icon="Vector plot";
        end


        function CreateDialogBox(obj,hFig)
            bgc=get(hFig,'color');
            ctxt={'parent',hFig,...
            'backgr',bgc,...
            'style','text',...
            'horiz','left'};
            cedt={'parent',hFig,...
            'backgr','w',...
            'style','edit',...
            'horiz','left'};
            dy=18;
            dye=21;
            tip=message('mcb:blocks:Historytip').getString(matlab.internal.i18n.locale("en"));
            uicontrol(ctxt{:},...
            'string',message('mcb:blocks:DisplayTraces').getString(matlab.internal.i18n.locale("en")),...
            'tooltip',tip,...
            'pos',[10,90,130,dy]);
            uicontrol(cedt{:},'string',num2str(obj.history),...
            'callback',@obj.updateHistory,...
            'pos',[10+130+3,90,100,dye]);

            tip=message('mcb:blocks:ScalingMsg').getString(matlab.internal.i18n.locale("en"));
            obj.autoCheckBox=uicontrol('parent',hFig,'backgr',bgc,...
            'style','checkbox','string','Auto-Scale',...
            'tooltip',tip,'pos',[10,90-25,110,dy],...
            'callback',@obj.autoScale_callback,...
            'value',1);
            tip=message('mcb:blocks:AxesMsg').getString(matlab.internal.i18n.locale("en"));
            uicontrol(ctxt{:},...
            'string',message('mcb:blocks:AxesLimit').getString(matlab.internal.i18n.locale("en")),...
            'tooltip',tip,...
            'pos',[10,90-50,80,dy]);
            obj.axesButton=uicontrol(cedt{:},...
            'callback',@obj.updateaxes,...
            'tooltip',tip,...
            'string',num2str(obj.axLim),...
            'pos',[10+130+3,90-50,70,dye],...
            'Enable','off');
        end


        function setaxes(obj)

            axColor=obj.AxObj.Color;
            if strcmp(axColor,'none')

                parent=obj.AxObj.Parent;

                if isprop(parent,'BackgroundColor')

                    axColor=parent.BackgroundColor;
                else

                    axColor=parent.Color;
                end

                if strcmp(axColor,'none')

                    axColor=[0,0,0];
                end
            end

            gridColor=obj.AxObj.GridColor;
            gridAlpha=obj.AxObj.GridAlpha;
            if strcmp(gridColor,'none')

                tc=gridColor;
            else
                tc=gridColor.*gridAlpha+axColor.*(1-gridAlpha);
            end
            ls=obj.AxObj.GridLineStyle;
            v=[get(obj.AxObj,'XLim'),get(obj.AxObj,'YLim')];
            v=cast(v,'double');
            ticks=sum(get(obj.AxObj,'YTick')>=0);
            ticks=cast(ticks,'double');
            hold(obj.AxObj,'on')
            box(obj.AxObj,'off');
            grid(obj.AxObj,'off');
            obj.AxObj.Visible='off';
            rticks=max(ticks-1,2);
            if rticks>5
                if rem(rticks,2)==0
                    rticks=rticks/2;
                elseif rem(rticks,3)==0
                    rticks=rticks/3;
                end
            end

            rmin=0;
            rmax=v(4);

            th=0:pi/50:2*pi;
            xunit=cos(th);
            yunit=sin(th);

            inds=1:(length(th)-1)/4:length(th);
            xunit(inds(2:2:4))=zeros(2,1);

            c82=cos(82*pi/180);
            s82=sin(82*pi/180);
            rinc=(rmax-rmin)/rticks;
            k=1;
            for i=(rmin+rinc):rinc:rmax
                obj.hhh(k)=line(xunit*i,yunit*i,'LineStyle',ls,'Color',tc,'LineWidth',1,...
                'Parent',obj.AxObj);
                text((i+rinc/20)*c82,(i+rinc/20)*s82,...
                ['  ',num2str(i)],'VerticalAlignment','bottom',...
                'Parent',obj.AxObj);
                k=k+1;
            end
            k=k-1;
            set(obj.hhh(k),'LineStyle','-');

            th=(1:6)*2*pi/12;
            cst=cos(th);
            snt=sin(th);
            cs=[-cst;cst];
            sn=[-snt;snt];
            obj.l=line(rmax*cs,rmax*sn,'LineStyle',ls,'Color',tc,'LineWidth',1,...
            'Parent',obj.AxObj);

            rt=1.1*rmax;
            for i=1:length(th)
                text(rt*cst(i),rt*snt(i),int2str(i*30),...
                'HorizontalAlignment','center',...
                'Parent',obj.AxObj);
                if i==length(th)
                    loc=int2str(0);
                else
                    loc=int2str(180+i*30);
                end
                text(-rt*cst(i),-rt*snt(i),loc,'HorizontalAlignment','center',...
                'Parent',obj.AxObj);
            end

        end


        function clearHistory_callback(obj,~,~)
            for i=1:obj.numVectors
                obj.dplot(i).XData=[NaN,NaN];
                obj.dplot(i).YData=[NaN,NaN];
                obj.dCirplot(i).XData=[NaN,NaN];
                obj.dCirplot(i).YData=[NaN,NaN];
            end
            obj.f=1;
            obj.flag=0;
        end

        function[alpha,beta]=clarkeTransform(~,a,b,c)
            result=(2/3)*[1,-0.5,-0.5;0,sqrt(3)/2,-sqrt(3)/2]*[a;b;c];
            alpha=result(1);
            beta=result(2);
        end

        function[d,q]=parkTransform(~,alpha,beta,theta)
            result=[cos(theta),sin(theta);-sin(theta),cos(theta)]*[alpha;beta];
            d=result(1);
            q=result(2);
        end

        function[d,q]=altParkTransform(~,alpha,beta,theta)
            result=[sin(theta),-cos(theta);cos(theta),sin(theta)]*[alpha;beta];
            d=result(1);
            q=result(2);
        end


        function stepImpl(obj,varargin)

            if coder.target('MATLAB')
                if(isequal(obj.InputSignals,obj.polarinput))
                    r=varargin{1};
                    angle=varargin{2};
                    obj.numVectors=length(varargin{1});
                    r=cast(r,'double');
                    angle=cast(angle,'double');
                    if(isequal(obj.angleUnits,'Per-unit'))
                        theta=angle*2*pi;
                    elseif(isequal(obj.thetaUnits,'Degrees'))
                        theta=angle*pi/180;
                    else
                        theta=angle;
                    end
                    Idc=r.*cos(theta);
                    Ids=r.*sin(theta);
                else
                    RotatingReference=isequal(obj.ReferenceFrame,obj.rotatingFrame);
                    obj.numVectors=2;
                    if(isequal(obj.InputSignals,obj.abcinput))
                        Vabc=varargin{1};
                        Iabc=varargin{2};
                        if RotatingReference
                            thetain=varargin{3};
                            thetain=cast(thetain,'double');
                            if(isequal(obj.thetaUnits,'Per-unit'))
                                theta=thetain*2*pi;
                            elseif(isequal(obj.thetaUnits,'Degrees'))
                                theta=thetain*pi/180;
                            else
                                theta=thetain;
                            end
                        end
                        Vabc=cast(Vabc,'double');
                        Iabc=cast(Iabc,'double');
                        [dv,qv]=clarkeTransform(obj,Vabc(1),Vabc(2),Vabc(3));
                        [di,qi]=clarkeTransform(obj,Iabc(1),Iabc(2),Iabc(3));

                        if RotatingReference
                            if isequal(obj.axisAlign,'D-axis')
                                [dv,qv]=parkTransform(obj,dv,qv,theta);
                                [di,qi]=parkTransform(obj,di,qi,theta);
                            else
                                [dv,qv]=altParkTransform(obj,dv,qv,theta);
                                [di,qi]=altParkTransform(obj,di,qi,theta);
                            end
                        end
                        Idc(1)=dv;
                        Ids(1)=qv;
                        Idc(2)=di;
                        Ids(2)=qi;
                    else
                        Vdq=varargin{1};
                        Idq=varargin{2};

                        cast(Vdq(1),'double');
                        cast(Vdq(2),'double');
                        cast(Idq(1),'double');
                        cast(Idq(2),'double');
                        Idc(1)=Vdq(1);
                        Ids(1)=Vdq(2);
                        Idc(2)=Idq(1);
                        Ids(2)=Idq(2);
                    end
                end

                p=sqrt(Idc.^2+Ids.^2);
                x=abs(max(p));
                if(x>=2*obj.lastVal)
                    obj.update=obj.updateFreq;
                end
                obj.lastVal=x;
                if((obj.autoCheckBox.Value==1)&&(obj.update==obj.updateFreq))
                    p=sqrt(Idc.^2+Ids.^2);
                    lim=abs(max(p))+0.1;
                    delete(obj.cir);
                    delete(obj.hhh(isgraphics(obj.hhh)));
                    delete(obj.l);
                    delete(findall(obj.AxObj,'Type','text'));
                    set(obj.AxObj,'XLim',[-lim,lim]);
                    set(obj.AxObj,'YLim',[-lim,lim]);
                    obj.setaxes();
                    uistack(obj.dCirplot,'top');
                    uistack(obj.dplot,'top');
                    uistack(obj.darrowplot,'top');
                    obj.update=1;
                elseif((obj.autoCheckBox.Value==1)&&(obj.update<obj.updateFreq))
                    obj.update=obj.update+1;
                end

                if(obj.f==0)
                    obj.dplot=gobjects(obj.numVectors,1);
                    obj.dCirplot=gobjects(obj.numVectors,1);
                    obj.darrowplot=gobjects(obj.numVectors,1);
                    h=gobjects(obj.numVectors,1);
                    for i=1:obj.numVectors
                        obj.dplot(i)=line(obj.AxObj,[0,Idc(i)],[0,Ids(i)],'Color',obj.color_line{i},'LineStyle','-','LineWidth',2);
                        obj.dCirplot(i)=line(obj.AxObj,[Idc(i)],[Ids(i)],'Color',obj.color_line{i},'LineStyle','--','LineWidth',2);
                        zd=(Idc(i)+Ids(i).*sqrt(-1)).';
                        ad=obj.arrow*zd;
                        obj.darrowplot(i)=line(obj.AxObj,real(ad),imag(ad),'Color',obj.color_line{i},'LineStyle','-','LineWidth',2);
                        h(i)=plot(obj.AxObj,[NaN,NaN],'Color',obj.color_line{i},'LineWidth',2);
                    end
                    set(obj.Fig,'defaultLegendAutoUpdate','off');
                    c=findall(obj.Fig,'Type','uitoolbar');
                    d=findall(c,'Type','uitoggletool');
                    if(isempty(obj.prvSimValue))
                        if(isequal(obj.InputSignals,obj.polarinput))
                            obj.lgd=legend(h);
                        else
                            obj.lgd=legend(h,{'Voltage','Current'});
                        end
                        obj.lgd.Visible='off';
                        obj.lgd.HandleVisibility='callback';
                    else
                        prvlength=length(obj.prvSimValue.lgdHandle.String);
                        if((prvlength==0)&&(~isempty(obj.prvSimValue.strg))...
                            &&(isequal(obj.InputSignals,obj.prvSimValue.inputType))...
                            &&(obj.numVectors==length(obj.prvSimValue.strg)))
                            obj.lgd=legend(h,obj.prvSimValue.strg);
                            if(d(2).State)
                                obj.lgd.Visible='on';
                                obj.lgd.Location='bestoutside';
                            else
                                obj.lgd.Visible='off';
                            end
                        elseif((obj.numVectors~=prvlength)...
                            ||(~isequal(obj.InputSignals,obj.prvSimValue.inputType)))
                            delete(obj.prvSimValue.lgdHandle);
                            delete(obj.lgd);
                            if(isequal(obj.InputSignals,obj.polarinput))
                                obj.lgd=legend(h);
                            else
                                obj.lgd=legend(h,{'Voltage','Current'});
                            end
                            if(d(2).State)
                                obj.lgd.Visible='on';
                                obj.lgd.Location='bestoutside';
                            else
                                obj.lgd.Visible='off';
                            end
                            obj.lgd.HandleVisibility='callback';
                        else
                            obj.lgd=obj.prvSimValue.lgdHandle;

                            obj.lgd.Location='bestoutside';
                        end
                    end
                    obj.f=obj.f+1;
                else
                    if(obj.history~=inf)
                        if((obj.f<obj.history)&&(obj.flag~=1))
                            for i=1:obj.numVectors
                                obj.dplot(i).XData=[0,Idc(i)];
                                obj.dplot(i).YData=[0,Ids(i)];
                                obj.dCirplot(i).XData=[obj.dCirplot(i).XData,Idc(i)];
                                obj.dCirplot(i).YData=[obj.dCirplot(i).YData,Ids(i)];
                                zd=(Idc(i)+Ids(i).*sqrt(-1)).';
                                ad=obj.arrow*zd;
                                obj.darrowplot(i).XData=real(ad);
                                obj.darrowplot(i).YData=imag(ad);
                            end
                            drawnow limitrate;
                            obj.f=obj.f+1;
                            if(obj.f==obj.history)

                                obj.flag=1;


                                obj.f=1;
                            end
                        else
                            for i=1:obj.numVectors
                                obj.dplot(i).XData=[0,Idc(i)];
                                obj.dplot(i).YData=[0,Ids(i)];
                                obj.dCirplot(i).XData=[obj.dCirplot(i).XData(2:end),Idc(i)];
                                obj.dCirplot(i).YData=[obj.dCirplot(i).YData(2:end),Ids(i)];
                                zd=(Idc(i)+Ids(i).*sqrt(-1)).';
                                ad=obj.arrow*zd;
                                obj.darrowplot(i).XData=real(ad);
                                obj.darrowplot(i).YData=imag(ad);
                            end
                            drawnow limitrate;
                            obj.f=obj.f+1;
                            if(obj.f==obj.history)
                                obj.f=1;
                            end
                        end
                    else


                        for i=1:obj.numVectors
                            obj.dplot(i).XData=[0,Idc(i)];
                            obj.dplot(i).YData=[0,Ids(i)];
                            obj.dCirplot(i).XData=[obj.dCirplot(i).XData,Idc(i)];
                            obj.dCirplot(i).YData=[obj.dCirplot(i).YData,Ids(i)];
                            zd=(Idc(i)+Ids(i).*sqrt(-1)).';
                            ad=obj.arrow*zd;
                            obj.darrowplot(i).XData=real(ad);
                            obj.darrowplot(i).YData=imag(ad);
                        end
                        obj.f=1;
                        drawnow limitrate;
                    end
                end
                if obj.debugEnable
                    for i=1:obj.numVectors
                        S(i).xComp=obj.dCirplot(i).XData';
                        S(i).yComp=obj.dCirplot(i).YData';
                        fig=obj.Fig;
                    end
                    try
                        assignin('base','test',S);
                        assignin('base','testFig',fig);
                    catch %#ok<CTCH>
                    end
                end
            end
        end


        function updateHistory(obj,hObject,~)
            edtText=get(hObject,'String');
            if(~strcmp(edtText,'inf'))
                input=str2double(edtText);
                if((isnan(input))||(input<=0))
                    errordlg(message('mcb:blocks:PositiveInput').getString(matlab.internal.i18n.locale("en")),...
                    'Invalid Input','modal')
                    return
                else
                    obj.history=input;
                    if(~isempty(obj.lgd))
                        temp=struct('limit',obj.axLim,'history',obj.history,...
                        'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                        'autoScale',obj.autoCheckBox.Value,...
                        'strg',{obj.lgd.String});
                    else
                        temp=struct('limit',obj.axLim,'history',obj.history,...
                        'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                        'autoScale',obj.autoCheckBox.Value);
                    end
                    set_param(obj.Fig.UserData,'UserData',temp);
                end
            else
                obj.history=inf;
            end
            for i=1:obj.numVectors
                obj.dplot(i).XData=[NaN,NaN];
                obj.dplot(i).YData=[NaN,NaN];
                obj.dCirplot(i).XData=[NaN,NaN];
                obj.dCirplot(i).YData=[NaN,NaN];
            end
            obj.f=1;
            obj.flag=0;
        end


        function updateaxes(obj,hObject,~)
            edtText=get(hObject,'String');
            if(~strcmp(edtText,'inf'))
                input=str2double(edtText);
                if((isnan(input))||(input<=0))
                    errordlg(message('mcb:blocks:PositiveInput').getString(matlab.internal.i18n.locale("en")),...
                    'Invalid Input','modal')
                    return
                else
                    obj.axLim=input;
                    if(~isempty(obj.lgd))
                        temp=struct('limit',obj.axLim,'history',obj.history,...
                        'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                        'autoScale',obj.autoCheckBox.Value,...
                        'strg',{obj.lgd.String});
                    else
                        temp=struct('limit',obj.axLim,'history',obj.history,...
                        'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                        'autoScale',obj.autoCheckBox.Value);
                    end
                    set_param(obj.Fig.UserData,'UserData',temp);
                    delete(obj.cir);
                    for k=1:numel(obj.hhh)
                        if isgraphics(obj.hhh(k))
                            delete(obj.hhh(k));
                        end
                    end
                    delete(obj.l);
                    delete(findall(obj.AxObj,'Type','text'));
                    set(obj.AxObj,'XLim',[-input,input]);
                    set(obj.AxObj,'YLim',[-input,input]);
                    obj.setaxes();
                    uistack(obj.dCirplot,'top');
                    uistack(obj.dplot,'top');
                    uistack(obj.darrowplot,'top');
                end
            end
        end

        function[name]=getInputNamesImpl(obj)

            abcInputs=isequal(obj.InputSignals,obj.abcinput);
            dqInputs=isequal(obj.InputSignals,obj.dqinput);
            magangleInputs=isequal(obj.InputSignals,obj.polarinput);
            if abcInputs
                name=["Vabc","Iabc","Theta"];
            elseif dqInputs
                name=["Vdq","Idq"];
            elseif magangleInputs
                name=["Magnitude","Angle"];
            end
        end


        function validateInputsImpl(obj,varargin)

            if coder.target('MATLAB')
                if isequal(obj.InputSignals,obj.dqinput)
                    validateattributes(varargin{1},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector','nrows',2},...
                    'validateInputsImpl','Vdq');
                    validateattributes(varargin{2},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector','nrows',2},...
                    'validateInputsImpl','Idq');
                end
                if isequal(obj.InputSignals,obj.abcinput)
                    validateattributes(varargin{1},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector','nrows',3},...
                    'validateInputsImpl','Vabc');
                    validateattributes(varargin{2},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector','nrows',3},...
                    'validateInputsImpl','Iabc');
                    if isequal(obj.ReferenceFrame,obj.rotatingFrame)
                        validateattributes(varargin{3},{'double','single'},...
                        {'nonempty','nonnan','finite','real','scalar'},...
                        'validateInputsImpl','Theta');
                    end
                end
                if isequal(obj.InputSignals,obj.polarinput)
                    validateattributes(varargin{1},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector'},...
                    'validateInputsImpl','Magnitude');
                    validateattributes(varargin{2},{'double','single'},...
                    {'nonempty','nonnan','finite','real','vector'},...
                    'validateInputsImpl','Angle');
                    s1=size(varargin{1});
                    s2=size(varargin{1});
                    if(s1(1)~=s2(1))
                        error(message('mcb:blocks:DimensionError').getString(matlab.internal.i18n.locale("en")));
                    end
                    if((s1(1)>6)||(s2(1)>6))
                        error(message('mcb:blocks:MaxInputError').getString(matlab.internal.i18n.locale("en")));
                    end
                end
            end
        end


        function num=getNumInputsImpl(obj)

            num=2;
            abcInputs=isequal(obj.InputSignals,obj.abcinput);
            RotatingReference=isequal(obj.ReferenceFrame,obj.rotatingFrame);
            if(abcInputs&&RotatingReference)
                num=3;
            end
        end


        function autoScale_callback(obj,hObject,~)
            if(isequal(hObject.Type,'uitoggletool'))
                x=hObject.State;
            elseif(isequal(hObject.Type,'uicontrol'))
                x=hObject.Value;
            end
            b=findall(obj.Fig,'Type','uitoolbar');
            d=findall(b,'Type','uitoggletool');
            if(x)
                obj.axesButton.Enable='off';
                obj.autoCheckBox.Value=1;
                d(1).State='on';

            else
                obj.axesButton.Enable='on';
                obj.autoCheckBox.Value=0;
                d(1).State='off';
            end
            if(~isempty(obj.lgd))
                temp=struct('limit',obj.axLim,'history',obj.history,...
                'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                'autoScale',obj.autoCheckBox.Value,...
                'strg',{obj.lgd.String});
            else
                temp=struct('limit',obj.axLim,'history',obj.history,...
                'lgdHandle',obj.lgd,'inputType',obj.InputSignals,...
                'autoScale',obj.autoCheckBox.Value);
            end
            set_param(obj.Fig.UserData,'UserData',temp);
        end


        function[figureHandle,dialogHandle]=setupFigure(obj,tag,dtag,blkh)

            figureHandle=findall(groot,'Type','Figure','Tag',tag);
            dialogHandle=findall(groot,'Type','Figure','Tag',dtag);
            name=get_param(blkh,'Name');
            if isempty(dialogHandle)
                dialogHandle=DisplayParameters(name);
            end
            if isempty(figureHandle)
                screenLoc=get(0,'ScreenSize');
                if screenLoc(1)<0
                    left=-screenLoc(1)+100;
                else
                    left=100;
                end

                if screenLoc(2)<0
                    bottom=-screenLoc(2)+100;
                else
                    bottom=100;
                end
                figureHandle=figure('Color','w','Units','pixel',...
                'Position',[left,bottom,559,444],...
                'CloseRequestFcn',@hidePlotFigure,...
                'name',name);

                datacursormode off;
                figureHandle.HandleVisibility='off';
                figureHandle.IntegerHandle='off';
                set(figureHandle,'MenuBar','none');

                figureHandle.ToolBar='figure';
                hb=findall(figureHandle,'Type','uitoolbar');
                delete(findall(hb,'ToolTipString','New Figure'));
                delete(findall(hb,'ToolTipString','Print Figure'));
                delete(findall(hb,'ToolTipString','Insert Colorbar'));
                delete(findall(hb,'ToolTipString','Open File'));
                delete(findall(hb,'ToolTipString','Link/Unlink Plot'));
                delete(findall(hb,'ToolTipString','Edit Plot'));
                delete(findall(hb,'ToolTipString','Open Property Inspector'));
                delete(findall(hb,'ToolTipString','Insert Legend'));
                figureHandle.Tag=tag;
                obj.Fig=figureHandle;
                obj.DialogFig=dialogHandle;
                if strcmp(obj.DialogFig.Visible,'off')
                    scope_pos=getpixelposition(obj.Fig);
                    scope_origin=scope_pos(1:2);
                    scope_delta=scope_pos(3:4);
                    scope_midpoint=scope_origin+scope_delta/2;
                    dialog_delta=[300,120];
                    dialog_origin=scope_midpoint-dialog_delta/2;
                    pos=[dialog_origin,dialog_delta];
                    set(obj.DialogFig,'pos',pos);
                end
                obj.FigureParam(blkh);
                mcb_vectorplot.setToolBar(obj);
                figureHandle=obj.Fig;
                dialogHandle=obj.DialogFig;
            end


            function hidePlotFigure(src,~)
                src.Visible='off';
                dialogHandle.Visible='off';

            end


            function hideDialogFigure(src,~)
                src.Visible='off';
            end


            function dialogHandle=DisplayParameters(name)
                fontsize=get(0,'FactoryUicontrolFontSize');
                fontname=get(0,'FactoryUicontrolFontName');

                dialogHandle=figure(...
                'DefaultUicontrolHorizontalAlign','left',...
                'DefaultUicontrolFontname',fontname,...
                'DefaultUicontrolFontsize',fontsize,...
                'DefaultUicontrolUnits','pixels',...
                'HandleVisibility','callback',...
                'Colormap',[],...
                'resize','off',...
                'Name',strcat('Preferences: ',name),...
                'Tag',dtag,...
                'menubar','none',...
                'CloseRequestFcn',@hideDialogFigure,...
                'nextplot','add',...
                'IntegerHandle','off',...
                'Visible','off');
            end
        end
    end


    methods(Access=protected,Static)
        function[EraserIm,SaveIm,BinocIm]=LOCALCreateImages

            Cfig=ones(16,16);
            Cfig(:,1)=0;
            Cfig(1,:)=0;
            Cfig(end,:)=0;
            Cfig(:,end)=0;
            Cfig=repmat(Cfig,[1,1,3]);

            Efig=Cfig;

            Efig(13,3:8,1:3)=0;
            Efig(10,3:8,1:3)=0;
            Efig(10:13,3,1:3)=0;
            Efig(10:13,8,1:3)=0;
            Efig(4,9:14,1:3)=0;
            Efig(4:7,14,1:3)=0;
            for i1=1:5
                Efig(10-i1,3+i1,1:3)=0;
                Efig(10-i1,8+i1,1:3)=0;
                Efig(13-i1,8+i1,1:3)=0;
            end

            Ecolor=ones(2,4,3);
            Ecolor(:,:,2)=0.5;
            Efig(11:12,4:7,1:3)=Ecolor;

            Ecolor1=ones(1,4,3);
            Ecolor1(:,:,2)=0.5;
            Ecolor2=ones(2,1,3);
            Ecolor2(:,:,2)=0.5;
            for i1=1:5
                Efig(10-i1,(4:7)+i1,1:3)=Ecolor1;
                Efig((11:12)-i1,8+i1,1:3)=Ecolor2;
            end

            Pfig=Cfig;

            for i1=1:5
                Pfig(3+i1,4+i1,1:3)=0;
                Pfig(14-i1,4+i1,1:3)=0;
                Pfig(3+i1,8+i1,1:3)=0;
                Pfig(14-i1,8+i1,1:3)=0;
            end

            Bfig(:,:,1)=[...
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,0,0,0,0,0,0,0,0,0,0,NaN,NaN,NaN;
            NaN,NaN,NaN,0,1,0,0,0,0,0,1,0,0,NaN,NaN,NaN;
            NaN,NaN,0,0,0,0,0,0,0,0,0,0,0,0,NaN,NaN;
            NaN,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,NaN;
            0,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,0;
            0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0;
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0];
            Bfig(:,:,2)=[...
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,0,0,0,0,0,0,0,0,0,0,NaN,NaN,NaN;
            NaN,NaN,NaN,0,1,0,0,0,0,0,1,0,0,NaN,NaN,NaN;
            NaN,NaN,0,0,0,0,0,0,0,0,0,0,0,0,NaN,NaN;
            NaN,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,NaN;
            0,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,0;
            0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0;
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0];
            Bfig(:,:,3)=[...
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,0,0,0,0,0,0,0,0,0,0,NaN,NaN,NaN;
            NaN,NaN,NaN,0,1,0,0,0,0,0,1,0,0,NaN,NaN,NaN;
            NaN,NaN,0,0,0,0,0,0,0,0,0,0,0,0,NaN,NaN;
            NaN,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,NaN;
            0,0,0,1,0,0,0,NaN,0,0,0,1,0,0,0,0;
            0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0;
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,1,0,0,0,NaN,NaN,NaN,NaN,0,0,1,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0;
            0,0,0,0,0,0,NaN,NaN,NaN,NaN,0,0,0,0,0,0];

            EraserIm=Efig;
            SaveIm=Pfig;
            BinocIm=Bfig;
        end


        function header=getHeaderImpl()
            header=matlab.system.display.Header('Title','Vector Plot',...
            'Text',message('mcb:blocks:VectorPlotDescription').getString(matlab.internal.i18n.locale("en")),...
            'ShowSourceLink',false);
        end


        function controlSim(hand)
            blk=get_param(gcb,'Handle');
            sys=bdroot(blk);
            status=get_param(sys,'SimulationStatus');
            c=findall(hand,'Type','uitoolbar');
            b=findall(c,'Type','uipushtool');
            icons=[];
            if isempty(icons)
                icons=load('plot_icons.mat');
            end

            switch status
            case 'stopped'
                set_param(sys,'SimulationCommand','start');
            case 'running'
                set_param(sys,'SimulationCommand','pause');
                b(3).CData=icons.run;
                b(3).Tooltip=message('mcb:blocks:RunSim').getString(matlab.internal.i18n.locale("en"));

            case 'paused'
                set_param(sys,'SimulationCommand','continue');
                b(3).CData=icons.pause;
                b(3).Tooltip=message('mcb:blocks:PauseSim').getString(matlab.internal.i18n.locale("en"));
            end
        end


        function stopSim(fhandle)
            blk=get_param(gcb,'Handle');
            sys=bdroot(blk);
            status=get_param(sys,'SimulationStatus');
            c=findall(fhandle,'Type','uitoolbar');
            b=findall(c,'Type','uipushtool');
            icons=[];
            if isempty(icons)
                icons=load('plot_icons.mat');
            end
            switch status
            case 'running'
                set_param(sys,'SimulationCommand','stop');
                b(3).CData=icons.run;
                b(3).Tooltip=message('mcb:blocks:RunSim').getString(matlab.internal.i18n.locale("en"));
                b(2).Enable='off';
            case 'paused'
                set_param(sys,'SimulationCommand','stop');
                b(3).CData=icons.run;
                b(3).Tooltip=message('mcb:blocks:RunSim').getString(matlab.internal.i18n.locale("en"));
                b(2).Enable='off';
            end
        end


        function setToolBar(obj)
            hb=findall(obj.Fig,'Type','uitoolbar');
            icons=[];
            if(isempty(icons))
                icons=load('plot_icons.mat');
            end
            [EraserIm,~,BinocIm]=mcb_vectorplot.LOCALCreateImages();
            if(~isempty(hb))
                uipushtool('parent',hb,...
                'tooltip','Preferences',...
                'CData',icons.s,...
                'ClickedCallback',@obj.showDialog);
                uipushtool('parent',hb,...
                'tooltip',message('mcb:blocks:RunSim').getString(matlab.internal.i18n.locale("en")),...
                'CData',icons.run,...
                'ClickedCallback',@(src,event)mcb_vectorplot.controlSim(obj.Fig));
                uipushtool('parent',hb,...
                'tooltip',message('mcb:blocks:StopSim').getString(matlab.internal.i18n.locale("en")),...
                'CData',icons.stop,...
                'Enable','off',...
                'ClickedCallback',@(src,event)mcb_vectorplot.stopSim(obj.Fig));
                uipushtool('parent',hb,'Tooltip',message('mcb:blocks:Clear').getString(matlab.internal.i18n.locale("en")),...
                'CData',EraserIm);
                uitoggletool('parent',hb,'Tooltip',message('mcb:blocks:Legend').getString(matlab.internal.i18n.locale("en")),...
                'CData',icons.legend);
                uitoggletool('parent',hb,'Tooltip',message('mcb:blocks:AutoScale').getString(matlab.internal.i18n.locale("en")),...
                'CData',BinocIm,'State','on');
            end
        end


        function group=getPropertyGroupsImpl(~)

            ReferenceFrameProp=matlab.system.display.internal.Property(...
            'ReferenceFrame','Description',message('mcb:blocks:RefFrameString').getString(matlab.internal.i18n.locale("en")));
            InputSignalsProp=matlab.system.display.internal.Property(...
            'InputSignals','Description',message('mcb:blocks:InputTypeString').getString(matlab.internal.i18n.locale("en")));
            axisAlignProp=matlab.system.display.internal.Property(...
            'axisAlign','Description',message('mcb:blocks:AxisAlignString').getString(matlab.internal.i18n.locale("en")));
            openFigAtSimStartProp=matlab.system.display.internal.Property(...
            'OpenFigAtSimStart','Description',message('mcb:blocks:OpenFigureString').getString(matlab.internal.i18n.locale("en")));
            thetaUnitsProp=matlab.system.display.internal.Property(...
            'thetaUnits','Description',message('mcb:blocks:ThetaString').getString(matlab.internal.i18n.locale("en")));
            angleUnitsProp=matlab.system.display.internal.Property(...
            'angleUnits','Description',message('mcb:blocks:AngleString').getString(matlab.internal.i18n.locale("en")));
            group=matlab.system.display.Section('Title','Parameters','PropertyList',...
            {InputSignalsProp,ReferenceFrameProp,axisAlignProp,thetaUnitsProp,...
            angleUnitsProp,openFigAtSimStartProp,'debugEnable'});
            group.Actions=matlab.system.display.Action(@(actionData,obj)mcb_vectorplot.showFigure(obj,actionData),'Label','Show plot');
            matlab.system.display.internal.setCallbacks(group.Actions,'SystemDeletedFcn',@(actionData)mcb_vectorplot.onSystemDeleted(actionData));
        end

        function[tag,dtag]=getUniqueTag(blockHandle)
            tag=strcat('Simulink_mcb_vectorplot',Simulink.ID.getSID(blockHandle));
            dtag=strcat('Dialog',Simulink.ID.getSID(blockHandle));
        end


        function onSystemDeleted(actionData)
            blockHandle=get_param(actionData.SystemHandle,'Handle');
            [tag,dtag]=mcb_vectorplot.getUniqueTag(blockHandle);
            animationFigure=findall(groot,'Type','Figure','Tag',tag);
            dialogFigure=findall(groot,'Type','Figure','Tag',dtag);
            if((~isempty(animationFigure))&&(ishandle(animationFigure)))
                delete(animationFigure);
            end
            if((~isempty(dialogFigure))&&(ishandle(dialogFigure)))
                delete(dialogFigure);
            end

        end


        function showFigure(obj,actionData)
            if((isempty(actionData.UserData))||(~isvalid(actionData.UserData)))
                blockHandle=get_param(actionData.SystemHandle,'Handle');
                [tag,dtag]=mcb_vectorplot.getUniqueTag(blockHandle);
                actionData.UserData=obj.setupFigure(tag,dtag,blockHandle);
            end
            actionData.UserData.Visible='on';
            figure(actionData.UserData);
        end


        function simMode=getSimulateUsingImpl

            simMode="Interpreted execution";
        end


        function flag=showSimulateUsingImpl

            flag=false;
        end
    end
end

