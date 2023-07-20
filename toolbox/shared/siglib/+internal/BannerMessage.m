classdef BannerMessage<handle








    properties(AbortSet)
        BackgroundColor=[253,231,65]./255
        FontSize=10
        ForegroundColor=[82,31,22]./255
        HighlightColor='k'
        Location='bottom'
Parent
        RemainFor=5
        String='Message';
    end

    properties(Access=private)
hTipText
hTipPanel
hTipClose
pExtent
pLoc
hListeners
hRemainForTimer




        pState=0
    end

    methods
        function obj=BannerMessage(parent)

            if nargin<1
                parent=gcf;
            end
            obj.Parent=parent;
            obj=init(obj);
        end

        function release(obj)

















            stop(obj);
        end

        function delete(obj)


            destroyInstance(obj);
        end

        function start(obj,str)






            stop(obj.hRemainForTimer);


            obj.hRemainForTimer.Duration=obj.RemainFor;


            if~strcmpi(obj.pLoc,obj.Location)
                updateBannerWidgetPos(obj);
            end

            if nargin>1
                obj.String=str;
            else
                str=obj.String;
            end
            if isempty(str)

                obj.pState=0;
                hideTip(obj);
            else
                obj.pState=1;
                showTip(obj);
                start(obj.hRemainForTimer);
            end
        end

        function stop(obj)


            stopAllTimers(obj);
            hideTip(obj);
            obj.pState=0;
        end

        function set.String(obj,val)
            if~iscellstr(val)&&~isstring(val)
                validateattributes(val,{'char','string'},{},...
                'BannerMessage','String');
            end
            obj.String=val;
            updateString(obj);
        end

        function set.FontSize(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','>',0},'BannerMessage','FontSize');
            obj.FontSize=val;
            updateFontSize(obj);
        end

        function set.Location(obj,val)
            obj.Location=validatestring(val,{'Top','Bottom'},...
            'BannerMessage','Location');
        end

        function set.RemainFor(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','nonnegative'},...
            'BannerMessage','RemainFor');
            obj.RemainFor=val;
        end

        function set.ForegroundColor(obj,val)
            if ischar(val)
                validateattributes(val,{'char'},{'row'},...
                'BannerMessage','ForegroundColor');
            else
                validateattributes(val,{'numeric'},...
                {'real','size',[1,3]},...
                'BannerMessage','ForegroundColor');
            end
            obj.ForegroundColor=val;
            updateColor(obj);
        end

        function set.HighlightColor(obj,val)
            if ischar(val)
                validateattributes(val,{'char'},{'row'},...
                'BannerMessage','HighlightColor');
            else
                validateattributes(val,{'numeric'},...
                {'real','size',[1,3]},...
                'BannerMessage','HighlightColor');
            end
            obj.HighlightColor=val;
            updateColor(obj);
        end

        function set.BackgroundColor(obj,val)
            if ischar(val)
                validateattributes(val,{'char'},{'row'},...
                'BannerMessage','BackgroundColor');
            else
                validateattributes(val,{'numeric'},...
                {'real','size',[1,3]},...
                'BannerMessage','BackgroundColor');
            end
            obj.BackgroundColor=val;
            updateColor(obj);
        end
    end

    methods(Access=private)
        function retObj=init(obj)






            name='internal_BannerMessage';
            p=obj.Parent;
            retObj=getappdata(p,name);
            if isempty(retObj)||~isvalid(retObj)
                setappdata(p,name,obj);

                initWidgets(obj);
                initTimers(obj);
                initListeners(obj);

                obj.pState=0;
                resize(obj);
                retObj=obj;
            end
        end

        function removeFromFigure(obj)


            destroyInstance(obj);
        end

        function destroyInstance(obj)






            deleteListeners(obj);
            deleteWidgets(obj);
            deleteTimers(obj);
        end

        function hideTip(obj)
            if~isempty(obj.hTipPanel)&&ishghandle(obj.hTipPanel)
                obj.hTipPanel.Visible='off';
            end
        end

        function showTip(obj)
            if~isempty(obj.String)...
                &&~isempty(obj.hTipPanel)&&ishghandle(obj.hTipPanel)
                obj.hTipPanel.Visible='on';
            end
        end

        function deleteTimers(obj)

            stopAllTimers(obj);
            delete(obj.hRemainForTimer);
        end

        function stopAllTimers(obj)





            if~isempty(obj.hRemainForTimer)&&isvalid(obj.hRemainForTimer)
                stopAndWait(obj.hRemainForTimer);
            end
        end

        function initTimers(obj)
            obj.hRemainForTimer=internal.TimeoutTimer(...
            @(~,~)remainForTimeoutFcn(obj),obj.RemainFor);
        end

        function remainForTimeoutFcn(obj)




            hideTip(obj);
            obj.pState=0;
        end

        function deleteWidgets(obj)

            h=obj.hTipPanel;
            if~isempty(h)&&ishghandle(h)
                delete(h);
                obj.hTipPanel=[];
                obj.hTipText=[];
                obj.hTipClose=[];
            end
        end

        function initWidgets(obj)
            try
                s=settings;
                if s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue
                    obj.hTipPanel=uipanel(...
                    'Parent',obj.Parent,...
                    'HandleVisibility','off',...
                    'Units','pixels',...
                    'Position',[1,1,1,1],...
                    'BackgroundColor',obj.BackgroundColor,...
                    'Visible','off');
                    obj.hTipPanel.AutoResizeChildren='off';
                else
                    obj.hTipPanel=uipanel(...
                    'Parent',obj.Parent,...
                    'HandleVisibility','off',...
                    'BorderType','line',...
                    'Units','pixels',...
                    'Position',[1,1,1,1],...
                    'BackgroundColor',obj.BackgroundColor,...
                    'HighlightColor',obj.HighlightColor,...
                    'Visible','off');
                end
            catch
                obj.hTipPanel=uipanel(...
                'Parent',obj.Parent,...
                'HandleVisibility','off',...
                'BorderType','line',...
                'Units','pixels',...
                'Position',[1,1,1,1],...
                'BackgroundColor',obj.BackgroundColor,...
                'Visible','off');
            end



            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText=uicontrol(...
                'Parent',obj.hTipPanel,...
                'HandleVisibility','off',...
                'Style','text',...
                'BackgroundColor',obj.BackgroundColor,...
                'ForegroundColor',obj.ForegroundColor,...
                'HorizontalAlignment','left',...
                'FontSize',obj.FontSize,...
                'Units','pixels',...
                'Position',[1,1,1,1],...
                'Visible','on');
            else
                obj.hTipText=uilabel(...
                'Parent',obj.hTipPanel,...
                'HandleVisibility','off',...
                'BackgroundColor',obj.BackgroundColor,...
                'HorizontalAlignment','left',...
                'FontSize',obj.FontSize,...
                'Position',[1,1,1,1],...
                'Visible','on');
            end

            ico=load('internal/BannerMessageIcons');
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipClose=uicontrol(...
                'Parent',obj.hTipPanel,...
                'HandleVisibility','off',...
                'Style','checkbox',...
                'Callback',@(~,~)userCloseBanner(obj),...
                'BackgroundColor',obj.BackgroundColor,...
                'CData',ico.x16x16,...
                'Units','pixels',...
                'Position',[1,1,1,1],...
                'TooltipString','Close',...
                'String','');
            else
                obj.hTipClose=uiimage(...
                'Parent',obj.hTipPanel,...
                'HandleVisibility','off',...
                'ImageClickedFcn',@(~,~)userCloseBanner(obj),...
                'BackgroundColor',obj.BackgroundColor,...
                'ImageSource',ico.x16x16,...
                'Position',[1,1,1,1],...
                'Tooltip','Close');
            end

            updateFontSize(obj,false);
            updateString(obj);
        end

        function userCloseBanner(obj)
            stop(obj);
        end

        function initListeners(obj)
            lis.FigDestroy=addlistener(obj.Parent,'ObjectBeingDestroyed',@(~,~)removeFromFigure(obj));
            lis.Resize=addlistener(obj.Parent,'SizeChanged',@(~,~)resize(obj));
            obj.hListeners=lis;
        end

        function deleteListeners(p)

            try %#ok<TRYNC>


                p.hListeners=internal.polariCommon.deleteListenerStruct(p.hListeners);
            end
        end

        function resize(obj)

            obj.pExtent=[];
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText.String=obj.String;
            else
                obj.hTipText.Text=obj.String;
            end

            updateBannerWidgetPos(obj);
            updateWidgetEllipsis(obj);
        end

        function updateColor(obj)
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText.ForegroundColor=obj.ForegroundColor;

            end
            obj.hTipText.BackgroundColor=obj.BackgroundColor;
            obj.hTipPanel.BackgroundColor=obj.BackgroundColor;
            try
                s=settings;
                if s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue
                else
                    obj.hTipPanel.HighlightColor=obj.HighlightColor;
                end
            catch

            end
        end

        function ext=setExtent(obj)









            ht=obj.hTipText;
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                s=ht.String;
            else
                s=ht.Text;
            end
            if iscellstr(s)||isstring(s)

                dx=0;
                dy=0;
                Nlines=numel(s);
                for i=1:Nlines
                    if~matlab.ui.internal.isUIFigure(obj.Parent)
                        ht.String=s{i};
                    else
                        ht.Text=s{i};
                    end
                    if~matlab.ui.internal.isUIFigure(obj.Parent)
                        e_i=ht.Extent;
                    else
                        e_i=[10,10,10,20];
                    end
                    dx=max(dx,e_i(3));



                    dy=dy+e_i(4)-6;
                end
                ext=[dx,dy];
                if~matlab.ui.internal.isUIFigure(obj.Parent)
                    ht.String=s;
                else
                    ht.Text=s;
                end
            else
                Nlines=size(s,1);
                if Nlines==1

                    if~matlab.ui.internal.isUIFigure(obj.Parent)
                        ext=ht.Extent(3:4)-[0,3];
                    else
                        ext=[10,20]-[0,3];
                    end
                else

                    dx=0;
                    dy=0;
                    for i=1:Nlines
                        if~matlab.ui.internal.isUIFigure(obj.Parent)
                            ht.String=strtrim(s(i,:));
                        else
                            ht.Text=strtrim(s(i,:));
                        end
                        if~matlab.ui.internal.isUIFigure(obj.Parent)
                            e_i=ht.Extent;
                        else
                            e_i=[10,10,10,20];
                        end
                        dx=max(dx,e_i(3));
                        dy=dy+e_i(4)-6;
                    end
                    ext=[dx,dy];
                    if~matlab.ui.internal.isUIFigure(obj.Parent)
                        ht.String=s;
                    else
                        ht.Text=s;
                    end
                end
            end
            obj.pExtent=ext;
        end

        function ext=getExtent(obj)

            ext=obj.pExtent;
            if isempty(ext)
                ext=setExtent(obj);
            end
        end

        function updateFontSize(obj,updateExtent)

            h=obj.hTipText;
            h.FontSize=obj.FontSize;
            if nargin<2||updateExtent
                setExtent(obj);
                resize(obj);
            end
        end

        function updateString(obj)


            one_line=true;


            str=obj.String;
            if iscellstr(str)||isstring(str)
                if one_line



                    Nlines=numel(str);
                    str=[str(:)';repmat({' '},1,Nlines)];
                    str=cat(2,str{:});
                    str=str(1:end-1);
                end
            elseif~isvector(str)
                if one_line
                    str=[str,repmat(' ',size(str,1),1)];
                    str=str';
                    str=str(:)';
                    str=str(1:end-1);
                end
            end
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText.String=str;
            else
                obj.hTipText.Text=str;
            end


            setExtent(obj);
            resize(obj);

            updateWidgetEllipsis(obj);
        end

        function updateBannerWidgetPos(obj)





            ext=getExtent(obj);
            hText=ext(2);


            p=obj.Parent;
            orig=p.Units;
            p.Units='pixels';
            fpos=p.Position;
            p.Units=orig;





            obj.pLoc=obj.Location;








            hPanel=hText+2;
            switch lower(obj.Location)
            case 'top'
                ppos=[1,fpos(4)+1-hPanel,fpos(3),hPanel];
            case 'bottom'
                ppos=[1,1,fpos(3),hPanel];
            end
            try
                s=settings;
                if s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue

                else
                    obj.hTipPanel.Position=ppos;
                end
            catch
                obj.hTipPanel.Position=ppos;
            end


            try
                s=settings;
                if s.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue
                    hText=20;
                end
            catch
            end
            obj.hTipText.Position=[1,1,fpos(3)-2,hText];


            hc=obj.hTipClose;
            gap=5;
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                [cdata_h,cdata_w,~]=size(hc.CData);
            else
                [cdata_h,cdata_w,~]=size(hc.ImageSource);
            end
            cpos=[fpos(3)-1-cdata_w-gap,1+floor((hPanel-cdata_h)/2),cdata_w,cdata_h];
            hc.Position=cpos;
        end

        function updateWidgetEllipsis(obj)





            h=obj.hTipText;



            ext=getExtent(obj);
            dx_text=ext(1);
            dx_widget=h.Position(3);
            if dx_text>=dx_widget
                str=h.String;
                Ns=numel(str);
                if Ns>6


                    str=[str(1:end-3),'...'];
                    while numel(str)>5

                        str(end-5:end-3)='';
                        h.String=str;
                        ext=setExtent(obj);
                        if ext(1)<dx_widget
                            return
                        end
                    end
                end


                h.String='';
            end
        end
    end
end
