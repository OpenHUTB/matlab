classdef LayoutManager<handle

    properties
plotH
figW
figH
pixF
bH
margX
margY
    end

    methods
        function this=LayoutManager()
            this.figW=770;
            this.figH=710;
            this.plotH=70;

            pf=get(0,'ScreenPixelsPerInch')/96;
            if isunix
                pf=1;
            end
            this.pixF=pf;
            this.bH=20*pf;
            this.margX=10*pf;
            this.margY=5*pf;
        end

        function hFig=createFigure(this,title)
            hFig=figure(...
            'Name',title,...
            'Color','default',...
            'MenuBar','none',...
            'WindowStyle','normal',...
            'IntegerHandle','off',...
            'NumberTitle','off',...
            'DockControls','off'...
            );
            set(hFig,'Position',this.getFigPosition(hFig));
        end

        function pp=addPlotPanel(this,fig,title)
            pp=uipanel(fig,...
            'Title',title,...
            'TitlePosition','centertop',...
            'Units','Pixels',...
            'FontWeight','bold'...
            );
            set(pp,'Position',this.getPlotPanelPosition(pp));
            set(pp,'Units','normalized');
        end

        function ax=addAxes(~,parent,xLabel,yLabel)
            ax=axes(parent,...
            'Box','on',...
            'Tag','perfplotaxis'...
            );
            xlabel(ax,xLabel);
            ylabel(ax,yLabel);
            ax.Toolbar.Visible='on';
        end

        function cp=addControlsPanel(this,parent)
            cp=uipanel(parent,...
            'Title',message('soc:ui:PlotControlsPanelLbl').getString(),...
            'TitlePosition','centertop',...
            'Units','Pixels',...
            'FontWeight','bold'...
            );
            set(cp,'Position',this.getCtrlsPanelPosition(cp));
            set(cp,'Units','normalized');
        end

        function ip=addInfoPanel(this,parent)
            ip=uipanel(parent,...
            'Title',message('soc:ui:PlotInfoPanelLbl').getString(),...
            'TitlePosition','centertop',...
            'Units','Pixels',...
            'FontWeight','bold'...
            );
            set(ip,'Position',this.getInfoPanelPosition(ip));
            set(ip,'Units','normalized');
            set(ip,'SizeChangedFcn',@this.infoTextSizeChangedCb);
        end

        function ic=addInfoTextControl(this,parent,text)
            ic=uicontrol(parent,...
            'Style','text',...
            'String',text,...
            'HorizontalAlignment','left'...
            );
            set(ic,'Position',this.getInfoTextCtrlPosition(ic));
            set(ic,'Units','normalized');
            fs=get(ic,'FontSize');
            if~ispc
                set(ic,'FontSize',fs-1);
            end
        end

        function latP=addLatenciesPanel(this,parent)
            latP=uipanel('Parent',parent,...
            'Units','Pixels',...
            'Title',message('soc:ui:PlotLatenciesLbl').getString(),...
            'BorderType','none'...
            );
            set(latP,'Position',this.getLatenciesPanelPosition(latP));
            set(latP,'Units','normalized');
        end

        function lc=addLatencyControls(this,parent,kind)
            switch kind
            case 'Controller'
                lcid(1)={'soc:ui:PlotBurstReqToStartLatency'};
                lcid(2)={'soc:ui:PlotBurstExecutionLatency'};
                lcid(3)={'soc:ui:PlotBurstLastToCompleteLatency'};
            case 'Channel'
                lcid(1)={'soc:ui:PlotBufferWriteLatency'};
                lcid(2)={'soc:ui:PlotBufferReadLatency'};
                lcid(3)={'soc:ui:PlotBufferExecLatency'};
            otherwise
                error('(socb internal) unknown latency control kind');
            end

            lc(1)=uicontrol(parent,...
            'Style','checkbox',...
            'String',message(lcid{1}).getString(),...
            'Units','Pixels',...
            'HorizontalAlignment','center',...
            'Tag','lc1'...
            );

            lc(2)=uicontrol(parent,...
            'Style','checkbox',...
            'String',message(lcid{2}).getString(),...
            'Units','Pixels',...
            'HorizontalAlignment','center',...
            'Tag','lc2'...
            );

            lc(3)=uicontrol(parent,...
            'Style','checkbox',...
            'String',message(lcid{3}).getString(),...
            'Units','Pixels',...
            'HorizontalAlignment','center',...
            'Tag','lc3'...
            );
            lPos=this.getLatencyCtrlsPosition(parent,lc);
            for i=1:numel(lc)
                set(lc(i),'Position',lPos{i});
                set(lc(i),'Units','normalized');
            end
        end

        function avgP=addAvgWindowPanel(this,parent)
            avgP=uipanel('Parent',parent,...
            'Units','Pixels',...
            'Title','',...
            'BorderType','none'...
            );
            set(avgP,'Position',this.getAvgWPanelPosition(avgP));
            set(avgP,'Units','normalized');
            set(avgP,'SizeChangedFcn',@this.avgWSizeChangedCb);
        end

        function avgW=addAvgWindowControls(~,parent,label,defaultVal)
            uicontrol(parent,...
            'Style','text',...
            'String',label,...
            'HorizontalAlignment','left',...
            'Tooltip',sprintf('%s',message('soc:ui:SamplingIntTooltip').getString())...
            );
            avgW=uicontrol(parent,...
            'Style','edit',...
            'String','auto',...
            'HorizontalAlignment','left',...
            'Tooltip',sprintf('%s',message('soc:ui:SamplingIntTooltip').getString())...
            );
        end

        function sP=addSamplingIntPanel(this,parent)
            sP=uipanel('Parent',parent,...
            'Units','Pixels',...
            'BorderType','none'...
            );
            set(sP,'Position',this.getSamplingIntPanelPosition(parent.Children(2)));
            set(sP,'Units','normalized');
            set(sP,'SizeChangedFcn',@this.avgWSizeChangedCb);
        end

        function mastP=addMastersPanel(this,parent,size)
            if isequal(size,'short')
                title=message('soc:ui:PlotMastersToPlotLbl','').getString();
            else
                title=message('soc:ui:PlotMastersToPlotLbl','s').getString();
            end
            mastP=uipanel('Parent',parent,...
            'Units','Pixels',...
            'Title',title,...
            'BorderType','none'...
            );
            set(mastP,'Position',this.getMastersPanelPosition(mastP,size));
            set(mastP,'Units','normalized');
        end

        function mc=addMastersControls(this,parent,numMasters,type)
            if isequal(type,'dropdownlist')

                mc{1}=message('soc:ui:PlotMasterChkboxLabel','1').getString();
                for i=2:numMasters
                    mc{end+1}=message('soc:ui:PlotMasterChkboxLabel',num2str(i)).getString();%#ok<AGROW>
                end
                mc=uicontrol(parent,...
                'Style','popupmenu',...
                'String',mc,...
                'Units','Pixels',...
                'HorizontalAlignment','center',...
                'Tag','masterDropdown'...
                );
                set(mc,'Position',this.getMastersListPosition(mc));
                set(mc,'Units','normalized');
            elseif isequal(type,'checkboxlist')
                for i=1:numMasters
                    mc(i)=uicontrol(parent,...
                    'Style','checkbox',...
                    'String',['Master ',num2str(i)],...
                    'HorizontalAlignment','center',...
                    'Tag',['master',num2str(i)]...
                    );%#ok<AGROW>
                end
                lPos=this.getMastersCtrlsPosition(parent,mc);
                for i=1:numel(mc)
                    set(mc(i),'Position',lPos{i});
                    set(mc(i),'Units','normalized');
                end
            end
        end

        function helpB=addHelpBtn(this,parent)

            helpB=uicontrol(parent,...
            'Style','pushbutton',...
            'String',message('soc:ui:HelpBtnTxt').getString(),...
            'HorizontalAlignment','center',...
            'Units','Pixels',...
            'Tag','plotbutton'...
            );
            set(helpB,'Position',this.getPlotBtnPosition(parent,helpB));
            set(helpB,'Units','normalized');
        end

        function plotB=addPlotBtn(this,parent)

            plotB=uicontrol(parent,...
            'Style','pushbutton',...
            'String',message('soc:ui:PlotBtnTxt').getString(),...
            'HorizontalAlignment','center',...
            'Units','Pixels',...
            'Tag','plotbutton'...
            );
            set(plotB,'Position',this.getPlotBtnPosition(parent,plotB));
            set(plotB,'Units','normalized');
            set(plotB,'Enable','off');
        end
    end

    methods(Access=private)
        function figPos=getFigPosition(this,fig)
            oldUnits=get(fig,'Units');
            set(fig,'Units','pixels');


            figPos=get(0,'DefaultFigurePosition');
            figPos(3:4)=[this.figW,this.figH]*this.pixF;



            rootScreenSize=get(0,'ScreenSize');
            if(figPos(1)<1)||(figPos(1)+figPos(3)>rootScreenSize(3))
                figPos(1)=30;
            end


            if(figPos(2)<1)||(figPos(2)+figPos(4)>rootScreenSize(4)-40*this.pixF)
                figPos(2)=figPos(2)-((figPos(2)+figPos(4)+100)-rootScreenSize(4))-40*this.pixF;
            end
            set(fig,'Units',oldUnits);
        end

        function pPos=getPlotPanelPosition(this,panel)
            oldUnits=get(panel,'Units');
            set(panel,'Units','Pixels');


            pX=10;
            pY=panel.Position(4)*(1-this.plotH/100)-pX;
            pW=panel.Position(3)-(2*pX);
            pH=panel.Position(4)*(this.plotH/100)+2*this.margY;
            pPos=[pX,pY,pW,pH]*this.pixF;

            set(panel,'Units',oldUnits);
        end

        function hPos=getCtrlsPanelPosition(this,panel)
            oldUnits=get(panel,'Units');
            set(panel,'Units','Pixels');

            pX=panel.Position(3)*0.5-0.5*this.margX;
            pY=this.margY;
            pW=panel.Position(3)*0.50-0.5*this.margX;
            pH=panel.Position(4)*(1-this.plotH/100)-3*pY;
            hPos=[pX,pY,pW,pH]*this.pixF;

            set(panel,'Units',oldUnits);
        end

        function cPos=getInfoPanelPosition(this,panel)
            oldUnits=get(panel,'Units');
            set(panel,'Units','Pixels');


            pX=this.margX;
            pY=this.margY;
            pW=panel.Position(3)*0.50-(2*this.margX);
            pH=panel.Position(4)*(1-this.plotH/100)-3*pY;
            cPos=[pX,pY,pW,pH]*this.pixF;

            set(panel,'Units',oldUnits);
        end

        function hPos=getInfoTextCtrlPosition(this,control)
            oldUnits=get(control,'Units');
            set(control,'Units','pixels');
            oldPUnits=get(control.Parent,'Units');
            set(control.Parent,'Units','Pixels');
            pPos=get(control.Parent,'Position');

            w=this.getControlExtent(control);


            hPos(1)=this.margX;
            hPos(2)=this.margY;
            hPos(3)=w;
            hPos(4)=pPos(4)-4*this.margY;

            set(control,'Units',oldUnits);
            set(control.Parent,'Units',oldPUnits);
        end

        function w=getControlExtent(this,c)

            uiExtent=get(c,'Extent');
            w=uiExtent(3)+4+20*this.pixF;
        end

        function lPos=getLatenciesPanelPosition(this,control)
            parent=control.Parent;
            oldPUnits=get(parent,'Units');
            set(parent,'Units','Pixels');
            pPos=get(parent,'Position');

            lPos(1)=this.margX;
            lPos(3)=pPos(3)-2*this.margX;
            latH=85;
            if numel(parent.Children)==1
                lPos(2)=pPos(4)-latH-3*this.margY;
            else
                lChild=parent.Children(2);
                oldLUnits=get(lChild,'Units');
                set(lChild,'Units','Pixels');
                lChildPos=get(lChild,'Position');
                lPos(2)=lChildPos(2)-latH;
                set(lChild,'Units',oldLUnits);
            end
            lPos(4)=latH;
            set(control.Parent,'Units',oldPUnits);
        end

        function lPos=getLatencyCtrlsPosition(this,parent,controls)
            oldPUnits=get(parent,'Units');
            set(parent,'Units','Pixels');
            pPos=parent.Position;

            for i=1:numel(controls)
                oldCUnits=get(controls(i),'Units');
                set(controls(i),'Units','Pixels');

                w=this.getControlExtent(controls(i));


                lX=2*this.margX;
                if i==1
                    lY=pPos(4)-6*this.margY;
                else
                    lY=lPos{i-1}(2)-4*this.margY;
                end

                lPos{i}=[lX,lY,w,this.bH];%#ok<AGROW>

                set(controls(i),'Units',oldCUnits);
            end
            set(parent,'Units',oldPUnits);
        end

        function aPos=getAvgWPanelPosition(this,control)

            oldCUnits=get(control,'Units');
            set(control,'Units','Pixels');
            oldPUnits=get(control.Parent,'Units');
            set(control.Parent,'Units','Pixels');
            pPos=get(control.Parent,'Position');

            lChild=control.Parent.Children(2);
            oldLUnits=get(lChild,'Units');
            set(lChild,'Units','Pixels');
            lChildPos=get(lChild,'Position');

            aPos(1)=this.margX;
            aPos(3)=pPos(3)-this.margX;

            ht=8*this.margY;
            aPos(2)=lChildPos(2)-0.75*ht;
            aPos(4)=ht;
            set(lChild,'Units',oldLUnits);
            set(control,'Units',oldCUnits);
            set(control.Parent,'Units',oldPUnits);
        end

        function cPos=getAvgWCtrlsPosition(this,parent)
            oldUnits=get(parent,'Units');
            set(parent,'Units','Pixels');

            if numel(parent.Children)==2
                cs={parent.Children.Style};

                lc=parent.Children(find(ismember(cs,'text')));%#ok<FNDSB>
                pPos=get(parent,'Position');
                fs=get(lc,'FontSize');
                lcX=2;
                lcY=max(0,pPos(4)-3*this.margY-fs*this.pixF);
                lcW=max(0,this.getControlExtent(lc));
                lcH=max(0,2*this.margY+fs*this.pixF);
                cPos{1}=[lcX,lcY,lcW,lcH];


                ecY=max(0,lcY+3);
                ecW=max(0,pPos(3)-lcW);
                ecX=max(0,lcW-2*this.margY);
                cPos{2}=[ecX,ecY,ecW,lcH];
            end
            set(parent,'Units',oldUnits);
        end

        function sPos=getSamplingIntPanelPosition(this,mastP)
            oldPUnits=get(mastP,'Units');
            set(mastP,'Units','Pixels');
            pPos=get(mastP,'Position');


            if numel(mastP.Children)-1>=4
                lChild=mastP.Children(end-3);
            else
                lChild=mastP.Children(1);
            end
            oldUnits=get(lChild,'Units');
            set(lChild,'Units','Pixels');
            lPos=get(lChild,'Position');

            sPos(1)=this.margX;
            sPos(2)=lPos(2)-10*this.margY;
            sPos(3)=pPos(3)-this.margX;
            sPos(4)=9*this.margY;

            set(lChild,'Units',oldUnits);
            set(mastP,'Units',oldPUnits);
        end

        function mPos=getMastersPanelPosition(this,control,size)
            oldPUnits=get(control.Parent,'Units');
            set(control.Parent,'Units','Pixels');
            pPos=get(control.Parent,'Position');

            mPos(1)=this.margX;
            mPos(3)=pPos(3)-2*this.margX;
            if isequal(size,'short')
                mPos(2)=pPos(4)*0.75-2*this.margY;
                mPos(4)=2*this.bH+2*this.margY;
            else
                mPos(2)=pPos(2);
                mPos(4)=pPos(4)-this.margY;
            end

            set(control.Parent,'Units',oldPUnits);
        end

        function mPos=getMastersListPosition(this,control)
            oldPUnits=get(control.Parent,'Units');
            set(control.Parent,'Units','Pixels');
            pPos=get(control.Parent,'Position');

            oldCUnits=get(control.Parent,'Units');
            set(control.Parent,'Units','Pixels');

            w=this.getControlExtent(control);

            cX=pPos(1)+this.margX;
            mPos=[cX,3*this.margY,w,this.bH];

            set(control,'Units',oldCUnits);
            set(control.Parent,'Units',oldPUnits);
        end

        function mPos=getMastersCtrlsPosition(this,parent,controls)
            oldPUnits=get(parent,'Units');
            set(parent,'Units','pixels');
            pPos=parent.Position;

            for i=1:numel(controls)
                oldCUnits=get(controls(i),'Units');
                set(controls(i),'Units','pixels');

                w=this.getControlExtent(controls(i));



                if mod(i,4)==1
                    mY=(pPos(4)-pPos(2))*0.80;
                    mX=pPos(1)+2*i*this.margX;
                else
                    mX=mPos{i-1}(1);
                    mY=mPos{i-1}(2)-4*this.margY;
                end

                mPos{i}=[mX,mY,mX+w,this.bH];%#ok<AGROW>

                set(controls(i),'Units',oldCUnits);
            end
            set(parent,'Units',oldPUnits);
        end

        function bPos=getPlotBtnPosition(this,parent,btn)
            oldUnits=get(parent,'Units');
            set(parent,'Units','Pixels');
            pPos=get(parent,'Position');

            w=this.getControlExtent(btn);

            bX=pPos(3)-w-this.margX;
            bPos=[bX,this.margY-2,w,this.bH];
            set(parent,'Units',oldUnits);
        end

        function avgWSizeChangedCb(this,avgP,~)
            if numel(avgP.Children)==2
                aPos=this.getAvgWCtrlsPosition(avgP);
                set(avgP.Children(2),'Position',aPos{1});
                set(avgP.Children(1),'Position',aPos{2});
            end
        end

        function infoTextSizeChangedCb(~,ip,~)
            if numel(ip.Children)==1&&~isempty(ip.Children(1).String)
                tChild=ip.Children(1);
            elseif numel(ip.Children)==2&&~isempty(ip.Children(1).String)
                tChild=ip.Children(2);
            end
            if~isempty(tChild)
                oldPUnits=get(ip,'Units');
                oldCUnits=get(tChild,'Units');
                set(ip,'Units','Characters');
                pPos=get(ip,'Position');
                cW=floor(pPos(3)-2);

                formatStr=regexprep(strjoin(strtrim(tChild.String)),'\.\s+','.\n\n');
                outtxt=textwrap(tChild,{formatStr},cW);
                set(tChild,'Units','Characters');
                newPos=get(tChild,'Position');
                newPos(3)=cW;
                set(tChild,'String',outtxt,'Position',newPos);

                set(ip,'Units',oldPUnits);
                set(tChild,'Units',oldCUnits);
            end
        end
    end
end
