classdef ToolTip<handle


































    properties(AbortSet)
        BackgroundColor=[255,255,225]./255
        FontSize=9
        ForegroundColor=[0,0,0]



        Location='pointer'
    end

    properties(SetAccess=private)
Parent
    end

    properties(AbortSet)
        ShowAfter=1
        String='Tool tip string';
        RemainFor=4
    end

    properties(Hidden)



        MouseUpdatePeriod=0.2



        KeepOnTop=false
    end

    properties(Access=private)
hTipText
hTipPanel
pLoc
        pMotion=false
pExtent
hListeners
hShowAfterTimer
hRemainForTimer





        pState=0
    end

    methods
        function obj=ToolTip(parent)

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






            if obj.pState==1




                stop(obj.hShowAfterTimer);
                stop(obj.hRemainForTimer);
                obj.pState=1;

            elseif obj.pState==2




                stop(obj.hRemainForTimer);
                obj.pState=1;

            else
                obj.pState=1;


                obj.hShowAfterTimer.Duration=obj.ShowAfter;
                obj.hRemainForTimer.Duration=obj.RemainFor;
            end




            hideTip(obj);


            if~strcmpi(obj.pLoc,obj.Location)
                updateBannerWidgetPos(obj);
            end

            if nargin>1
                obj.String=str;
                if isempty(str)


                    return
                end
            end
            start(obj.hShowAfterTimer);
        end

        function stop(obj)



            stopAllTimers(obj);
            hideTip(obj);
            obj.pState=0;
        end

        function set.String(obj,val)
            if~iscellstr(val)
                validateattributes(val,{'char','string'},{},...
                'ToolTip','String');
            end
            obj.String=val;
            updateString(obj);
        end

        function set.FontSize(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','>',0},'ToolTip','FontSize');
            obj.FontSize=val;
            updateFontSize(obj);
        end

        function set.Location(obj,val)
            obj.Location=validatestring(val,{'Top','Bottom','Pointer','None'},...
            'ToolTip','Location');


            updateString(obj);

            resize(obj);
        end

        function set.ShowAfter(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','nonnegative'},...
            'ToolTip','ShowAfter');

            if obj.pState>0 %#ok<MCSUP>
                error('ToolTip:ReadOnlyWhileEnabled',...
                'Cannot change timer settings while ToolTip is enabled.');
            end
            obj.ShowAfter=val;
        end

        function set.RemainFor(obj,val)
            validateattributes(val,{'double'},...
            {'real','scalar','nonnegative'},...
            'ToolTip','RemainFor');

            if obj.pState>0 %#ok<MCSUP>
                error('ToolTip:ReadOnlyWhileEnabled',...
                'Cannot change timer settings while ToolTip is enabled.');
            end
            obj.RemainFor=val;
        end

        function set.ForegroundColor(obj,val)
            internal.ColorConversion.validatecolorspec(val,...
            'ToolTip','ForegroundColor');
            obj.ForegroundColor=val;
            updateColor(obj);
        end

        function set.BackgroundColor(obj,val)
            internal.ColorConversion.validatecolorspec(val,...
            'ToolTip','BackgroundColor');
            obj.BackgroundColor=val;
            updateColor(obj);
        end
    end

    methods(Access=private)
        function retObj=init(obj)






            name='internal_ToolTip';
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

        function destroyFigureInstance(obj)

            ax=obj.Parent;
            check_ax_del=isa(ax,'matlab.ui.Figure')&&ishghandle(ax);
            if check_ax_del

                if isappdata(ax,'internal_ToolTip')

                    rmappdata(obj.Parent,'internal_ToolTip');
                end
            end
        end

        function removeFromFigure(obj)


            destroyInstance(obj);
        end

        function destroyInstance(obj)






            deleteListeners(obj);
            deleteWidgets(obj);
            deleteTimers(obj);

            destroyFigureInstance(obj);
        end

        function hideTip(obj)
            if~isempty(obj.hTipPanel)&&ishghandle(obj.hTipPanel)
                obj.hTipPanel.Visible='off';
            end
        end

        function showTip(obj)


            if~isempty(obj.String)...
                &&~isempty(obj.hTipPanel)&&ishghandle(obj.hTipPanel)


                if strcmpi(obj.Location,'pointer')
                    p=obj.Parent;
                    orig=p.Units;
                    p.Units='pixels';
                    xy=p.CurrentPoint(1,1:2);
                    p.Units=orig;

                    ptrRows=size(p.PointerShapeCData,1);
                    wh=getExtent(obj);





                    twoBorders=2;
                    obj.hTipPanel.Position=[...
                    xy(1)+twoBorders...
                    ,xy(2)-wh(2)-ptrRows-3-twoBorders...
                    ,wh(1)+1+twoBorders...
                    ,wh(2)+twoBorders];

                    updatePointerOnScreenPos(obj);

                    if obj.KeepOnTop
                        orderTipAboveOtherChildren(obj);
                    end
                end


                obj.hTipPanel.Visible='on';
            end
        end

        function deleteTimers(obj)

            stopAllTimers(obj);
            delete(obj.hShowAfterTimer);
            delete(obj.hRemainForTimer);
        end

        function stopAllTimers(obj)





            if~isempty(obj.hShowAfterTimer)&&isvalid(obj.hShowAfterTimer)
                stopAndWait(obj.hShowAfterTimer);
            end
            if~isempty(obj.hRemainForTimer)&&isvalid(obj.hRemainForTimer)
                stopAndWait(obj.hRemainForTimer);
            end
        end

        function initTimers(obj)
            obj.hShowAfterTimer=internal.TimeoutTimer(...
            @(~,~)showAfterTimeoutFcn(obj),obj.ShowAfter);
            obj.hRemainForTimer=internal.TimeoutTimer(...
            @(~,~)remainForTimeoutFcn(obj),obj.RemainFor);
        end

        function showAfterTimeoutFcn(obj,doShow)




            if nargin<2||doShow
                showTip(obj);
            end
            obj.pState=2;


            d=obj.RemainFor;
            if~isinf(d)

                t=obj.hRemainForTimer;
                t.Duration=d;
                start(t);
            end
        end

        function remainForTimeoutFcn(obj)




            hideTip(obj);
            obj.pState=1;
        end

        function resetEvent(obj,ev,coalesce)































            obj.Parent.CurrentPoint=ev.Point;

            if obj.pState==1
                if coalesce





                    e=elapsed(obj.hShowAfterTimer);
                    if e>obj.MouseUpdatePeriod


                        if e<obj.ShowAfter

                            start(obj.hShowAfterTimer,-e);
                        else




                            showAfterTimeoutFcn(obj,false);
                        end
                    end
                else



                    start(obj.hShowAfterTimer);
                end

            elseif obj.pState==2



                stop(obj.hRemainForTimer);
                hideTip(obj);
                obj.pState=1;
                start(obj.hShowAfterTimer);
            end
        end

        function deleteWidgets(obj)

            h=obj.hTipPanel;
            if~isempty(h)&&ishghandle(h)
                delete(h);
                obj.hTipPanel=[];
                obj.hTipText=[];
            end
        end

        function initWidgets(obj)

            obj.hTipPanel=uipanel(...
            'Parent',obj.Parent,...
            'Tag','ToolTipPanel',...
            'HandleVisibility','off',...
            'BorderType','line',...
            'Units','pixels',...
            'Position',[1,1,1,1],...
            'BackgroundColor',obj.BackgroundColor,...
            'Visible','off');




            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText=uicontrol(...
                'Parent',obj.hTipPanel,...
                'Tag','ToolTipText',...
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
                'Tag','ToolTipText',...
                'HandleVisibility','off',...
                'BackgroundColor',obj.BackgroundColor,...
                'HorizontalAlignment','left',...
                'FontSize',obj.FontSize,...
                'Position',[1,1,1,1],...
                'Visible','on');
            end

            updateFontSize(obj,false);
            updateString(obj);
        end

        function initListeners(obj)
            lis.FigDestroy=addlistener(obj.Parent,'ObjectBeingDestroyed',@(~,~)removeFromFigure(obj));
            lis.Resize=addlistener(obj.Parent,'SizeChanged',@(~,~)resize(obj));
            lis.MouseMotion=addlistener(obj.Parent,...
            'WindowMouseMotion',@(~,ev)resetEvent(obj,ev,true));
            lis.MousePress=addlistener(obj.Parent,...
            'WindowMousePress',@(~,ev)resetEvent(obj,ev,false));
            lis.MouseRelease=addlistener(obj.Parent,...
            'WindowMouseRelease',@(~,ev)resetEvent(obj,ev,false));
            obj.hListeners=lis;
        end

        function deleteListeners(p)

            try %#ok<TRYNC>


                p.hListeners=internal.polariCommon.deleteListenerStruct(p.hListeners);
            end
        end

        function resize(obj)


            if strcmpi(obj.Location,'pointer')
                updatePointerOnScreenPos(obj);
            else

                obj.pExtent=[];
                obj.hTipText.String=obj.String;

                updateBannerWidgetPos(obj);
                updateWidgetEllipsis(obj);
            end
        end

        function updateColor(obj)
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                obj.hTipText.ForegroundColor=obj.ForegroundColor;

            end
            obj.hTipText.BackgroundColor=obj.BackgroundColor;
            obj.hTipPanel.BackgroundColor=obj.BackgroundColor;
        end

        function ext=setExtent(obj)









            ht=obj.hTipText;

            if~matlab.ui.internal.isUIFigure(obj.Parent)
                s=ht.String;
            else
                s=ht.Text;
            end
            if iscellstr(s)

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
                        e_i=getTextSize(obj,ht);
                        e_i(end)=e_i(end)+6;
                    end
                    dx=max(dx,e_i(3));
                    if ismac
                        dy=dy+e_i(4)-3;
                    else



                        dy=dy+e_i(4)-5;
                    end
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
                        ext=[10,10]-[0,3];
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
                            e_i=getTextSize(self,ht);
                        end
                        dx=max(dx,e_i(3));
                        if ismac
                            dy=dy+e_i(4)-3;
                        else
                            dy=dy+e_i(4)-5;
                        end
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

        function orderTipAboveOtherChildren(obj)


            p=obj.Parent;


            shh='showhiddenhandles';
            shh_o=get(0,shh);
            set(0,shh,'on')
            ch=p.Children;
            set(0,shh,shh_o);


            me=obj.hTipPanel;
            sel=ch==me;
            idx=find(sel);
            assert(~isempty(idx));


            ch(idx)=[];
            p.Children=[me;ch];
        end

        function updateFontSize(obj,updateExtent)

            h=obj.hTipText;
            h.FontSize=obj.FontSize;
            if nargin<2||updateExtent





                updateString(obj);



                resize(obj);
            end
        end

        function updateString(obj)




            is_ptr=strcmpi(obj.Location,'pointer');
            one_line=~is_ptr;


            str=obj.String;
            if iscellstr(str)
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
            h=obj.hTipText;
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                h.String=str;
            else
                h.Text=str;
            end


            ext=setExtent(obj);

            if is_ptr



                h.Position(3:4)=ext+1;



                obj.hTipPanel.Position(3:4)=ext+3;

                updatePointerOnScreenPos(obj);
            else

                updateWidgetEllipsis(obj);
            end
        end

        function updateBannerWidgetPos(obj)


            ext=getExtent(obj);
            h=ext(2);


            p=obj.Parent;
            orig=p.Units;
            p.Units='pixels';
            ppos=p.Position;
            p.Units=orig;



            obj.pLoc=obj.Location;
            switch lower(obj.Location)
            case 'top'
                obj.hTipPanel.Position=[1,ppos(4)-(h+2)+1,ppos(3),h+2];
                obj.hTipText.Position=[1,1,ppos(3)-2,h];
            case 'bottom'
                obj.hTipPanel.Position=[1,1,ppos(3),h+2];
                obj.hTipText.Position=[1,1,ppos(3)-2,h];
            end
        end

        function updatePointerOnScreenPos(obj)






            p=obj.Parent;
            orig=p.Units;
            p.Units='pixels';
            ppos=p.Position;
            p.Units=orig;



            h=obj.hTipPanel;
            hpos=h.Position;
            [ptr_dy,ptr_dx]=size(get(p,'PointerShapeCData'));
            fixup=false;
            if hpos(2)<=0

                h.Position(2)=max(1,hpos(2)+ptr_dy);
                h.Position(1)=hpos(1)+ptr_dx;
                fixup=true;
            end


            hpos=h.Position;
            h_right=hpos(1)+hpos(3);
            hpast_right=h_right-ppos(3);
            if hpast_right>0

                if fixup
                    h.Position(1)=hpos(1)-ptr_dx-2-hpos(3);
                else
                    h.Position(1)=hpos(1)-hpast_right;
                end
            end
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

        function position=getTextSize(self,uiobj)
            persistent axval;
            persistent txtObjval;
            if isempty(axval)||isempty(txtObjval)
                axval=uiaxes('Parent',[],'Units','pixels','Visible','off','Internal',true);
                txtObjval=text(axval,1,1,'','Units','pixels','FontUnits','pixels','Internal',true);
            end

            p=uiobj.Parent;
            axval.Parent=p;
            if~matlab.ui.internal.isUIFigure(obj.Parent)
                txtObjval.String=uiobj.String;
            else
                txtObjval.String=uiobj.Text;
            end

            props=["FontName","FontSize","FontAngle","FontWeight"];
            for propi=1:length(props)
                txtObjval.(props(propi))=uiobj.(props(propi));
            end

            position=txtObjval.Extent;
            axval.Parent=[];

        end
    end
end
