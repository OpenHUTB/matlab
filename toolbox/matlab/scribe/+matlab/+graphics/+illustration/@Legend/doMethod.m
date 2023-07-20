function varargout=doMethod(hObj,fcn,varargin)




    args=[{fcn,hObj},varargin];
    if nargout==0
        feval(args{:});
    else
        [varargout{1:nargout}]=feval(args{:});
    end



    function printcallback(hObj,cbname)



        pci=getappdata(hObj,'PrintCallbackInfo');

        if strcmp(cbname,'PrePrintCallback')
            if ismember(pci.DriverClass,{'EP','PS'})
                hObj.PrintAlphaSupported=false;
            end
        else
            hObj.PrintAlphaSupported=true;
        end



        function val=postdeserialize(h)

            val.strings=h.String';
            val.loc=h.Location;
            fig=ancestor(h,'figure');
            val.position=hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
            'points',fig);
            val.leg=h;
            if~isappdata(double(fig),'BusyPasting')
                val.ax=getappdata(double(h),'PeerAxes');
                val.plotchildren=getappdata(double(h),'PlotChildren');
            else
                axProxy=getappdata(double(h),'PeerAxesProxy');
                val.ax=plotedit({'getHandleFromProxyValue',fig,axProxy});
                childProxy=getappdata(double(h),'PlotChildrenProxy');
                val.plotchildren=plotedit({'getHandleFromProxyValue',fig,childProxy});
            end

            val.viewprops={'Orientation','TextColor','EdgeColor',...
            'Interpreter','Box','Visible','Color'};
            val.viewvals=get(h,val.viewprops);
            val.Units=get(h,'Units');




            if~isempty(val.ax)&&ishandle(val.ax)
                setappdata(double(val.ax),'LegendPeerHandle',double(h));
            end



            function bmotion(fig,evdata,buttonMotionData)

                if matlab.ui.internal.isUIFigure(fig)

                    return
                end

                h=buttonMotionData.Legend;
                pt=hgconvertunits(fig,[0,0,evdata.Point],get(fig,'Units'),...
                'points',fig);
                pt=pt(3:4);





                startpt=buttonMotionData.StartPoint;
                if~getappdata(h,'AllowDrag')
                    if(any(abs(startpt-pt)>5))||...
                        (etime(clock,buttonMotionData.StartClock)>.5)
                        setappdata(h,'AllowDrag',true);
                    else
                        return;
                    end
                end


                if~isequal(pt,startpt)

                    posPts=buttonMotionData.OrigPosInPoints+(pt-startpt);
                    newpos=hgconvertunits(fig,[posPts,1,1],'points',...
                    get(h,'Units'),ancestor(h.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));

                    if~isempty(h.Parent)&&isa(h.Parent,'matlab.graphics.layout.Layout')
                        newpos=h.Parent.computeRelativePosition(newpos,h.Units);
                    end


                    h.Position(1:2)=newpos(1:2);



                    buttonDownData=getappdata(h,'ButtonDownData');
                    buttonDownData.DragOccurred=true;
                    setappdata(h,'ButtonDownData',buttonDownData);
                end


                function bmotioncb(hSrc,evdata,buttonDownData)
                    if~ishandle(buttonDownData.Legend),return,end
                    bmotion(hSrc,evdata,buttonDownData);



                    function clear_buttondown_state(h)

                        buttonDownData=getappdata(h,'ButtonDownData');

                        fig=ancestor(h,'figure');
                        if(length(buttonDownData.oldwinfuns)~=2)
                            buttonDownData.oldwinfuns={'',''};
                        end
                        set(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},buttonDownData.oldwinfuns);

                        rmappdata(h,'ButtonDownData');

                        if isappdata(h,'LegendDestroyedListener')
                            rmappdata(h,'LegendDestroyedListener');
                        end

                        if isappdata(h,'AllowDrag')
                            rmappdata(h,'AllowDrag');
                        end











                        function handled=ploteditbup(hLeg,evd)

                            handled=false;
                            fig=ancestor(hLeg,'figure');
                            if strcmp(get(fig,'SelectionType'),'open')
                                hPrim=evd.HitPrimitive;
                                if isa(hPrim,'matlab.graphics.primitive.world.Text')
                                    hText=ancestor(hPrim,'Text');

                                    if~isempty(hText)&&isvalid(hText)
                                        handled=true;
                                        start_textitem_edit(hLeg,hText);
                                    end
                                end
                            end



                            function windowMouseRelease(fig,~,leg)






                                buttonDownData=getappdata(leg,'ButtonDownData');

                                clear_buttondown_state(leg);

                                if buttonDownData.clickedOverItems&&~buttonDownData.rightClickWithUIContextMenu



                                    if~buttonDownData.DragOccurred&&matlab.ui.internal.isUIFigure(fig)

                                        if~isempty(leg.Parent)&&isa(leg.Parent,'matlab.graphics.layout.Layout')
                                            currentPosInPts=hgconvertunits(fig,leg.getAbsoluteCanvasPosition(),get(leg,'Units'),...
                                            'points',ancestor(leg.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
                                        else
                                            currentPosInPts=hgconvertunits(fig,get(leg,'Position_I'),get(leg,'Units'),...
                                            'points',ancestor(leg.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
                                        end
                                        if~isequal(buttonDownData.OrigPosInPoints,currentPosInPts(1:2))
                                            buttonDownData.DragOccurred=true;
                                        end
                                    end

                                    if~buttonDownData.DragOccurred

                                        ed=buttonDownData.ItemHitEventData;



                                        if~isappdata(fig,'scribeActive')
                                            errorlisteners=createWindowMouseErrorListeners(fig);%#ok<NASGU>
                                        end
                                        notify(leg,'ItemHit',ed)
                                        if~isempty(leg.ItemHitFcn)
                                            try


                                                hgfeval(leg.ItemHitFcn,leg,ed);
                                            catch ex

                                                warnState=warning('off','backtrace');
                                                warning(message('MATLAB:legend:ErrorWhileEvaluating',ex.message,'ItemHitFcn'));
                                                warning(warnState);
                                            end
                                        end
                                    end
                                end

                                function l=createWindowMouseErrorListeners(f)
                                    errorproperties={...
                                    'WindowButtonDownFcn',...
                                    'WindowButtonMotionFcn',...
                                    'WindowButtonUpFcn',...
                                    'WindowScrollWheelFcn',...
                                    'WindowKeyPressFcn',...
                                    'WindowKeyReleaseFcn'};

                                    for i=1:numel(errorproperties)
                                        prop=findprop(f,errorproperties{i});
                                        l(i)=event.proplistener(f,prop,'PreSet',@(o,e)properror(errorproperties{i}));%#ok<AGROW>
                                    end

                                    function properror(fcnname)
                                        warning(message('MATLAB:legend:FigureCallbacksInItemHitFcn',fcnname));




                                        function bdown(h,figCurrentPoint,winfuns,origPosInPts)

                                            fig=ancestor(h,'figure');
                                            if isappdata(fig,'scribeActive')
                                                return;
                                            end


                                            setappdata(h,'AllowDrag',false);

                                            buttonMotionData.OrigPosInPoints=origPosInPts(1:2);
                                            buttonMotionData.Legend=h;
                                            buttonMotionData.StartPoint=figCurrentPoint;
                                            buttonMotionData.StartClock=clock;
                                            buttonMotionData.oldwinfuns=winfuns;
                                            set(fig,'WindowButtonMotionFcn',{@bmotioncb,buttonMotionData});


                                            function bdowncb(leg,evdata)



                                                if isappdata(leg,'ButtonDownData')
                                                    clear_buttondown_state(leg);
                                                    return
                                                end

                                                fig=ancestor(leg,'figure');
                                                if~isa(leg.Parent,'matlab.graphics.chart.Chart')&&...
                                                    isempty(ancestor(leg.Parent,'matlab.graphics.chartcontainer.ChartContainer'))
                                                    set(fig,'CurrentAxes',leg.Axes);
                                                end


                                                pt=hgconvertunits(fig,[0,0,get(fig,'CurrentPoint')],get(fig,'Units'),'points',fig);
                                                figCurrentPoint=pt(3:4);


                                                if~isempty(leg.Parent)&&isa(leg.Parent,'matlab.graphics.layout.Layout')
                                                    origPosInPts=hgconvertunits(fig,leg.getAbsoluteCanvasPosition(),get(leg,'Units'),...
                                                    'points',ancestor(leg.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
                                                else
                                                    origPosInPts=hgconvertunits(fig,get(leg,'Position_I'),get(leg,'Units'),...
                                                    'points',ancestor(leg.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
                                                end


                                                rightClickWithUICM=strcmp(fig.SelectionType,'alt')&&...
                                                ~isempty(leg.UIContextMenu)&&...
                                                isvalid(leg.UIContextMenu);

                                                [clickedOverItems,ed]=determineItemHitEventData(leg,fig,figCurrentPoint);

                                                buttonDownData.oldwinfuns=get(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
                                                buttonDownData.clickedOverItems=clickedOverItems;
                                                buttonDownData.rightClickWithUIContextMenu=rightClickWithUICM;
                                                buttonDownData.ItemHitEventData=ed;


                                                buttonDownData.DragOccurred=false;
                                                buttonDownData.OrigPosInPoints=origPosInPts(1:2);


                                                buttonDownData.WindowMouseReleaseListener=event.listener(fig,'WindowMouseRelease',@(h,e)windowMouseRelease(h,e,leg));

                                                buttonDownData.LegendDestroyedListener=event.listener(leg,'ObjectBeingDestroyed',@(~,~)clear_buttondown_state(leg));


                                                setappdata(leg,'ButtonDownData',buttonDownData);

                                                seltype=get(fig,'SelectionType');
                                                if strcmp(seltype,'normal')
                                                    bdown(leg,figCurrentPoint,buttonDownData.oldwinfuns,origPosInPts);
                                                elseif strcmp(seltype,'open')

                                                    hText=get_and_validate_composite_text(evdata);
                                                    if~isempty(hText)

                                                        if strcmp(leg.version,'on')


                                                            start_textitem_edit(leg,hText);


                                                        elseif isequal(leg.Title.TextComp,hText)
                                                            start_title_edit(leg);
                                                        end
                                                    end
                                                end



                                                function hT=get_and_validate_composite_text(ed)
                                                    hT=[];
                                                    hPrim=ed.Primitive;
                                                    if isa(hPrim,'matlab.graphics.primitive.world.Text')
                                                        hText=ancestor(hPrim,'Text');
                                                        if~isempty(hText)&&isvalid(hText)
                                                            hT=hText;
                                                        end
                                                    end




                                                    function start_title_edit(leg)






                                                        t=leg.Title;




                                                        t.Editing='on';



                                                        function[clickedOverItems,ed]=determineItemHitEventData(leg,fig,figCurrentPoint)

                                                            clickedOverItems=false;
                                                            ed=matlab.graphics.eventdata.ItemHitEventData;




                                                            if~isempty(leg.Parent)&&isa(leg.Parent,'matlab.graphics.layout.Layout')
                                                                parentCanvas=ancestor(leg,'matlab.ui.internal.mixin.CanvasHostMixin');
                                                                legPosInParentCanvas=leg.getAbsoluteCanvasPosition();




                                                                parentCanvasPixelPos=getpixelposition(parentCanvas,true);
                                                                legPosPixelsWRTFigure=hgconvertunits(fig,legPosInParentCanvas,leg.Units,'pixels',parentCanvas);
                                                                if~isequal(parentCanvas,fig)
                                                                    legPosPixelsWRTFigure(1:2)=legPosPixelsWRTFigure(1:2)+parentCanvasPixelPos(1:2);
                                                                end
                                                            else
                                                                legPosPixelsWRTFigure=getpixelposition(leg,true);
                                                            end

                                                            legPosPointsWRTFigure=hgconvertunits(fig,legPosPixelsWRTFigure,'pixels','points',fig);
                                                            legCurrentPoint=figCurrentPoint-legPosPointsWRTFigure(1:2);
                                                            legCurrentPointNorm=legCurrentPoint./legPosPointsWRTFigure(3:4);

                                                            entries=leg.getEntries;


                                                            if isempty(entries)
                                                                return
                                                            end

                                                            li=[entries.LayoutInfo];



                                                            for i=1:length(li)
                                                                if(legCurrentPointNorm(1)>li(i).LeftEdge&&...
                                                                    legCurrentPointNorm(1)<li(i).RightEdge&&...
                                                                    legCurrentPointNorm(2)>li(i).BottomEdge&&...
                                                                    legCurrentPointNorm(2)<li(i).TopEdge)

                                                                    clickedOverItems=true;
                                                                    ed.SelectionType=fig.SelectionType;
                                                                    ed.Item=entries(i);
                                                                    ed.Peer=ed.Item.Object;
                                                                    if legCurrentPointNorm(1)<li(i).IconToLabelEdge
                                                                        ed.Region='icon';
                                                                    else
                                                                        ed.Region='label';
                                                                    end


                                                                    break
                                                                end
                                                            end








                                                            function obj=getTextComponentFromItemHit(~,ed)
                                                                obj=matlab.graphics.primitive.Text.empty;
                                                                if isa(ed,'matlab.graphics.eventdata.ItemHitEventData')&&strcmpi(ed.Region,'label')
                                                                    obj=ed.Item.Label.TextComp;
                                                                end



                                                                function start_textitem_edit(hLeg,hText)

                                                                    hText.Editing='on';




                                                                    hListener=addlistener(hText,findprop(hText,'String'),'PostSet',@(~,~)noop());
                                                                    hListener.Callback=@(es,ed)end_textitem_edit(hLeg,ed.AffectedObject,hListener);



                                                                    function end_textitem_edit(hLeg,hText,hListener)


                                                                        if isvalid(hLeg)&&isvalid(hText)



                                                                            entry=findEntry(hLeg,hText);
                                                                            if~isempty(entry)
                                                                                plotChild=entry.Object;
                                                                                str=get(hText,'String');



                                                                                if iscell(str)&&numel(str)==1
                                                                                    str=str{1};
                                                                                end



                                                                                if size(str,1)>1
                                                                                    cstr=cellstr(str);
                                                                                    s=repmat('%s\n',1,length(cstr));
                                                                                    s(end-1:end)=[];
                                                                                    str=sprintf(s,cstr{:});
                                                                                end

                                                                                set(plotChild,'DisplayName',str);
                                                                            end
                                                                        end





                                                                        matlab.graphics.interaction.generateLiveCode(hLeg.Axes,matlab.internal.editor.figure.ActionID.LEGEND_EDITED);
                                                                        delete(hListener);



                                                                        function update_userdata(h)

                                                                            ud.PlotHandle=h.Axes;
                                                                            ud.legendpos=getnpos(h);
                                                                            ud.LegendPosition=h.Position_I;
                                                                            ud.LabelHandles=[h.ItemText,h.ItemTokens]';
                                                                            ud.handles=h.PlotChildren;
                                                                            ud.lstrings=h.String';
                                                                            ud.LegendHandle=h;
                                                                            set(h,'UserData',ud);



                                                                            parent=get(h,'Parent');
                                                                            fig=ancestor(h,'figure');
                                                                            pos=h.Position_I;
                                                                            siz=hgconvertunits(fig,pos,get(h,'Units'),'points',parent);
                                                                            setappdata(h,'LegendOldSize',siz(3:4));



                                                                            function npos=getnpos(h)

                                                                                switch h.Location
                                                                                case 'Best'
                                                                                    npos=0;
                                                                                case 'NorthWest'
                                                                                    npos=2;
                                                                                case 'NorthEast'
                                                                                    npos=1;
                                                                                case 'NorthEastOutside'
                                                                                    npos=-1;
                                                                                case 'SouthWest'
                                                                                    npos=3;
                                                                                case 'SouthEast'
                                                                                    npos=4;
                                                                                otherwise
                                                                                    fig=ancestor(h,'figure');
                                                                                    npos=hgconvertunits(fig,h.Position_I,get(h,'Units'),...
                                                                                    'points',get(h,'Parent'));
                                                                                end




                                                                                function strsize=getTitleStringSize(h,updateState)



                                                                                    t=h.Title_I;
                                                                                    str=t.String;



                                                                                    if isempty(str)&&strcmp(t.TextComp.Editing_I,'on')
                                                                                        str=' ';
                                                                                    end

                                                                                    hFont=matlab.graphics.general.Font;
                                                                                    hFont.Name=t.FontName_I;
                                                                                    hFont.Size=t.FontSize_I;
                                                                                    hFont.Angle=t.FontAngle_I;
                                                                                    hFont.Weight=t.FontWeight_I;
                                                                                    smoothing='on';


                                                                                    try
                                                                                        strsize=updateState.getStringBounds(str,hFont,t.Interpreter_I,smoothing);
                                                                                    catch err
                                                                                        if strcmp(err.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                                                                                            strsize=updateState.getStringBounds(str,hFont,'none',smoothing);
                                                                                        end
                                                                                    end




                                                                                    function strsizes=getStringSizes(h,updateState)

                                                                                        strs=getNamesForLayout(h);
                                                                                        strsizes=ones(length(strs),2);
                                                                                        hFont=matlab.graphics.general.Font;
                                                                                        hFont.Name=h.FontName_I;
                                                                                        hFont.Size=h.FontSize_I;
                                                                                        hFont.Angle=h.FontAngle_I;
                                                                                        hFont.Weight=h.FontWeight_I;
                                                                                        smoothing='on';


                                                                                        if isempty(strs)
                                                                                            strs="data1";
                                                                                        end
                                                                                        for k=1:length(strs)
                                                                                            str=strs{k};
                                                                                            if isempty(str)
                                                                                                str='Onj';
                                                                                            end


                                                                                            try
                                                                                                strsizes(k,:)=updateState.getStringBounds(str,hFont,h.Interpreter,smoothing);
                                                                                            catch err
                                                                                                if strcmp(err.identifier,'MATLAB:hg:textutils:StringSyntaxError')
                                                                                                    strsizes(k,:)=updateState.getStringBounds(str,hFont,'none',smoothing);
                                                                                                elseif strcmp(err.identifier,'MATLAB:handle_graphics:Text:LargeStringLengthException')



                                                                                                    strsizes(k,:)=updateState.getStringBounds('data1',hFont,'none',smoothing);
                                                                                                end
                                                                                            end



                                                                                        end


                                                                                        function pixelsPerPoint=getpixelsperpoint(h)





                                                                                            pixelsPerPoint=get(groot,'ScreenPixelsPerInch')/72;




                                                                                            if isfield(h.PrintSettingsCache,'ScaleFactor')
                                                                                                pixelsPerPoint=pixelsPerPoint.*h.PrintSettingsCache.ScaleFactor;
                                                                                            end


                                                                                            function out=getsizeinfo(h,updateState)





                                                                                                if strcmp(h.version,'on')
                                                                                                    out=getsizeinfoCompatible(h,updateState);
                                                                                                    return;
                                                                                                end






                                                                                                pixelsPerPoint=getpixelsperpoint(h);
                                                                                                out.topspace=2/pixelsPerPoint;
                                                                                                out.rowspace=.5/pixelsPerPoint;
                                                                                                out.botspace=2/pixelsPerPoint;
                                                                                                out.leftspace=4/pixelsPerPoint;
                                                                                                out.colspace=8/pixelsPerPoint;
                                                                                                out.rightspace=4/pixelsPerPoint;
                                                                                                out.tokentotextspace=3/pixelsPerPoint;
                                                                                                out.strsizes=getStringSizes(h,updateState);
                                                                                                out.tokenwidth=h.ItemTokenSize(1);


                                                                                                maxIconToLabelRatio=.75;
                                                                                                out.tokenheight=min(h.ItemTokenSize(2),maxIconToLabelRatio*min(out.strsizes(:,2)));


                                                                                                suppTitle=supportsTitle(h);
                                                                                                if suppTitle
                                                                                                    out.titlebotspace=2/pixelsPerPoint;
                                                                                                    out.titletopspace=2/pixelsPerPoint;
                                                                                                    out.titlestrsize=getTitleStringSize(h,updateState);
                                                                                                else
                                                                                                    out.titlebotspace=0;
                                                                                                    out.titletopspace=0;
                                                                                                    out.titlestrsize=[0,0];
                                                                                                end

                                                                                                out.titlesectionwidth=max(out.titlestrsize(1),0);
                                                                                                out.titlesectionheight=suppTitle*(out.titletopspace+out.titlestrsize(2)+out.titlebotspace);




                                                                                                numItems=size(out.strsizes,1);

                                                                                                switch h.Orientation
                                                                                                case 'vertical'
                                                                                                    if strcmp(h.NumColumnsMode,'auto')
                                                                                                        h.NumRowsInternal=numItems;
                                                                                                        h.NumColumns_I=1;
                                                                                                        h.NumColumnsInternal=1;







                                                                                                    else


                                                                                                        h.NumColumnsInternal=h.NumColumns_I;
                                                                                                        h.NumRowsInternal=ceil(numItems/h.NumColumns_I);
                                                                                                        diff=h.NumRowsInternal*h.NumColumns_I-numItems;
                                                                                                        if diff>=h.NumRowsInternal
                                                                                                            h.NumColumnsInternal=h.NumColumns_I-floor(diff/h.NumRowsInternal);
                                                                                                            h.NumRowsInternal=ceil(numItems/h.NumColumnsInternal);
                                                                                                        end
                                                                                                    end

                                                                                                case 'horizontal'
                                                                                                    if strcmp(h.NumColumnsMode,'auto')
                                                                                                        h.NumRowsInternal=1;
                                                                                                        h.NumColumns_I=numItems;
                                                                                                        h.NumColumnsInternal=numItems;







                                                                                                    else


                                                                                                        h.NumColumnsInternal=min(h.NumColumns_I,numItems);
                                                                                                        h.NumRowsInternal=ceil(numItems/h.NumColumnsInternal);
                                                                                                    end
                                                                                                end

                                                                                                numColumns=h.NumColumnsInternal;
                                                                                                numRows=h.NumRowsInternal;



                                                                                                if strcmp(h.Orientation,'vertical')
                                                                                                    for ind=1:numItems
                                                                                                        col=ceil(ind/numRows);
                                                                                                        row=1+mod(ind-1,numRows);
                                                                                                        out.strsizegrid(row,col,1:2)=out.strsizes(ind,:);
                                                                                                        out.itemsizegrid(row,col,1)=out.tokenwidth+out.tokentotextspace+out.strsizes(ind,1);
                                                                                                        out.itemsizegrid(row,col,2)=out.strsizes(ind,2);
                                                                                                    end
                                                                                                else
                                                                                                    for ind=1:numItems
                                                                                                        col=1+mod(ind-1,numColumns);
                                                                                                        row=ceil(ind/numColumns);
                                                                                                        out.strsizegrid(row,col,1:2)=out.strsizes(ind,:);
                                                                                                        out.itemsizegrid(row,col,1)=out.tokenwidth+out.tokentotextspace+out.strsizes(ind,1);
                                                                                                        out.itemsizegrid(row,col,2)=out.strsizes(ind,2);
                                                                                                    end
                                                                                                end

                                                                                                out.columnwidths=max(out.itemsizegrid(:,:,1),[],1);
                                                                                                out.rowheights=max(out.itemsizegrid(:,:,2),[],2);






                                                                                                out.itemsectionwidth=max(numColumns-1,0)*out.colspace+...
                                                                                                sum(out.columnwidths);

                                                                                                out.itemsectionheight=out.topspace+...
                                                                                                sum(out.rowheights)+...
                                                                                                max([numRows-1,0])*out.rowspace+...
                                                                                                out.botspace;



                                                                                                out.itempadding=max(0,.5*(out.titlesectionwidth-out.itemsectionwidth));


                                                                                                out.totalwidth=out.leftspace+2*out.itempadding+out.itemsectionwidth+out.rightspace;
                                                                                                out.totalheight=out.itemsectionheight+out.titlesectionheight;



                                                                                                function[totalSize,itemsSize,sizeInfoStruct]=getsize(h,updateState)





                                                                                                    persistent lastTotalSize;
                                                                                                    persistent lastItemsSize;
                                                                                                    persistent lastSizeInfoStruct;
                                                                                                    if isempty(lastTotalSize)
                                                                                                        lastTotalSize=[0,0];
                                                                                                        lastItemsSize=[0,0];
                                                                                                        lastSizeInfoStruct=[];
                                                                                                    end
                                                                                                    if nargin==1
                                                                                                        totalSize=lastTotalSize;
                                                                                                        itemsSize=lastItemsSize;
                                                                                                        sizeInfoStruct=lastSizeInfoStruct;
                                                                                                        return
                                                                                                    end

                                                                                                    s=doMethod(h,'getsizeinfo',updateState);
                                                                                                    sizeInfoStruct=s;
                                                                                                    totalSize=[s.totalwidth,s.totalheight];
                                                                                                    itemsSize=[s.itemsectionwidth,s.itemsectionheight];


                                                                                                    lastTotalSize=totalSize;
                                                                                                    lastItemsSize=itemsSize;
                                                                                                    lastSizeInfoStruct=sizeInfoStruct;



                                                                                                    function tf=hasTitle(leg)


                                                                                                        t=leg.Title_I;
                                                                                                        tf=~isempty(t)&&isvalid(t)&&(~isempty(t.String)||strcmp(t.TextComp.Editing_I,'on'));


                                                                                                        function tf=supportsTitle(leg)


                                                                                                            tf=strcmp(leg.version,'off')&&hasTitle(leg);



                                                                                                            function legPointsPos=get_best_location(h,minSizePoints)


                                                                                                                peerAxes=h.Axes;

                                                                                                                axPixelPos=hgconvertunits(ancestor(peerAxes,'figure'),...
                                                                                                                peerAxes.InnerPosition_I,peerAxes.Units,'pixels',...
                                                                                                                ancestor(peerAxes.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));

                                                                                                                legPixelPos=hgconvertunits(ancestor(h,'figure'),[0,0,minSizePoints],...
                                                                                                                'points','pixels',ancestor(h.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));
                                                                                                                H=axPixelPos(4);
                                                                                                                W=axPixelPos(3);
                                                                                                                buffH=0.03*H;
                                                                                                                buffW=0.03*W;
                                                                                                                Hgt=legPixelPos(4);
                                                                                                                Wdt=legPixelPos(3);
                                                                                                                Thgt=H/max(1,floor(H/(Hgt+buffH)));
                                                                                                                Twdt=W/max(1,floor(W/(Wdt+buffW)));



                                                                                                                tallLegend=false;
                                                                                                                if H-Thgt<eps
                                                                                                                    Thgt=Hgt+buffH;
                                                                                                                    tallLegend=true;
                                                                                                                end
                                                                                                                longLegend=false;
                                                                                                                if W-Twdt<eps
                                                                                                                    Twdt=Wdt+buffW;
                                                                                                                    longLegend=true;
                                                                                                                end

                                                                                                                dh=(Thgt-Hgt)/2;
                                                                                                                dw=(Twdt-Wdt)/2;


                                                                                                                allAxes=peerAxes;
                                                                                                                if isappdata(peerAxes,'graphicsPlotyyPeer')
                                                                                                                    allAxes(2)=getappdata(peerAxes,'graphicsPlotyyPeer');
                                                                                                                end
                                                                                                                primitives=matlab.graphics.chart.internal.findallVisibleDataObjectPrimitives(allAxes);

                                                                                                                Xdata=[];
                                                                                                                Ydata=[];
                                                                                                                for i=1:length(primitives)


                                                                                                                    theAxes=ancestor(primitives(i),'matlab.graphics.axis.AbstractAxes','node');
                                                                                                                    if isa(primitives(i),'matlab.graphics.primitive.Text')

                                                                                                                    else
                                                                                                                        if~isempty(primitives(i).VertexData)
                                                                                                                            viewerCoords=matlab.graphics.chart.internal.convertVertexCoordsToViewerCoords(primitives(i),primitives(i).VertexData);
                                                                                                                            Xdata=[Xdata,viewerCoords(1,:)];
                                                                                                                            Ydata=[Ydata,viewerCoords(2,:)];
                                                                                                                        end
                                                                                                                    end
                                                                                                                end




                                                                                                                xp=unique(axPixelPos(1)+[(0:Twdt:W-Twdt),(W-Twdt:-Twdt:0)]);



                                                                                                                if longLegend
                                                                                                                    xp(end+1)=(W/2-(Wdt+buffW)/2)+axPixelPos(1);
                                                                                                                end

                                                                                                                yp=unique(axPixelPos(2)+[(H-Thgt:-Thgt:0),(0:Thgt:H-Thgt)]);


                                                                                                                if tallLegend
                                                                                                                    yp(end+1)=(H/2-(Hgt+buffH)/2)+axPixelPos(2);
                                                                                                                end

                                                                                                                wtol=Twdt/100;
                                                                                                                htol=Thgt/100;
                                                                                                                pop=zeros(length(yp),length(xp));
                                                                                                                for j=1:length(yp)
                                                                                                                    for i=1:length(xp)
                                                                                                                        pop(j,i)=sum(sum((Xdata>xp(i)-wtol)&(Xdata<xp(i)+Twdt+wtol)&...
                                                                                                                        (Ydata>yp(j)-htol)&(Ydata<yp(j)+Thgt+htol)));
                                                                                                                    end
                                                                                                                end

                                                                                                                if all(pop(:)==0),pop(1)=1;end




                                                                                                                while any(pop(:)==0)
                                                                                                                    newpop=filter2(ones(3),pop);


                                                                                                                    if all(newpop(:)~=0)
                                                                                                                        break;
                                                                                                                    end
                                                                                                                    pop=newpop;
                                                                                                                end

                                                                                                                [j,i]=find(pop==min(pop(:)));
                                                                                                                legPixelPos(1:2)=[xp(i(end))+dw,yp(j(end))+dh];

                                                                                                                legPointsPos=hgconvertunits(ancestor(h,'figure'),legPixelPos,...
                                                                                                                'pixels','points',ancestor(peerAxes.Parent,'matlab.ui.internal.mixin.CanvasHostMixin','node'));


                                                                                                                function[edgecolor,facecolor]=patchcolors(leg,h)%#ok

                                                                                                                    cdat=get(h,'Cdata');
                                                                                                                    facecolor=get(h,'FaceColor');
                                                                                                                    if any(strcmp(facecolor,{'interp','texturemap'}))
                                                                                                                        if~all(cdat==cdat(1))
                                                                                                                            warning(message('MATLAB:legend:UnsupportedFaceColor',facecolor))
                                                                                                                        end
                                                                                                                        facecolor='flat';
                                                                                                                    end
                                                                                                                    if strcmp(facecolor,'flat')
                                                                                                                        if size(cdat,3)==1
                                                                                                                            if~any(isfinite(cdat))
                                                                                                                                facecolor='none';
                                                                                                                            end
                                                                                                                        else
                                                                                                                            facecolor=reshape(cdat(1,1,:),1,3);
                                                                                                                        end
                                                                                                                    end

                                                                                                                    edgecolor=get(h,'EdgeColor');
                                                                                                                    if strcmp(edgecolor,'interp')
                                                                                                                        if~all(cdat==cdat(1))
                                                                                                                            warning(message('MATLAB:legend:UnsupportedEdgeColor'))
                                                                                                                        end
                                                                                                                        edgecolor='flat';
                                                                                                                    end
                                                                                                                    if strcmp(edgecolor,'flat')
                                                                                                                        if size(cdat,3)==1
                                                                                                                            if~any(isfinite(cdat))
                                                                                                                                edgecolor='none';
                                                                                                                            end
                                                                                                                        else
                                                                                                                            edgecolor=reshape(cdat(1,1,:),1,3);
                                                                                                                        end
                                                                                                                    end


                                                                                                                    function[facevertcdata,facevertadata]=patchvdata(leg,h)%#ok

                                                                                                                        cdat=get(h,'CData');
                                                                                                                        if isempty(cdat)


                                                                                                                            facecolor=1;
                                                                                                                        elseif size(cdat,3)==1


                                                                                                                            facecolor=cdat(:);
                                                                                                                            facecolor=mean(facecolor(~isnan(facecolor)));
                                                                                                                        elseif size(cdat,3)==3
                                                                                                                            facecolor=reshape(cdat(1,1,:),1,3);
                                                                                                                        else
                                                                                                                            facecolor=1;
                                                                                                                        end

                                                                                                                        xdat=get(h,'XData');

                                                                                                                        if length(xdat)==1
                                                                                                                            facevertcdata=facecolor;
                                                                                                                        else
                                                                                                                            facevertcdata=[facecolor;facecolor;facecolor;facecolor];
                                                                                                                        end

                                                                                                                        try
                                                                                                                            facealpha=get(h,'FaceVertexAlphaData');
                                                                                                                        catch ex %#ok<NASGU>
                                                                                                                            try
                                                                                                                                facealpha=get(h,'AlphaData');
                                                                                                                            catch ex2 %#ok<NASGU>
                                                                                                                                facealpha=1;
                                                                                                                            end
                                                                                                                        end

                                                                                                                        if length(facealpha)<1
                                                                                                                            facealpha=1;
                                                                                                                        else
                                                                                                                            facealpha=facealpha(1);
                                                                                                                        end

                                                                                                                        if length(xdat)==1
                                                                                                                            facevertadata=facealpha;
                                                                                                                        else
                                                                                                                            facevertadata=[facealpha;facealpha;facealpha;facealpha];
                                                                                                                        end






                                                                                                                        function createDefaultContextMenu(h,fig)

                                                                                                                            assert(isempty(h.UIContextMenu),'legend should have no initial UIContextMenu')
                                                                                                                            if(nargin<2)
                                                                                                                                assert(isempty(ancestor(h,'figure')),'legend should have no ancestor figure');
                                                                                                                                fig=matlab.ui.Figure.empty;
                                                                                                                            end

                                                                                                                            uic=uicontextmenu('Parent',fig,...
                                                                                                                            'HandleVisibility','off',...
                                                                                                                            'Serializable','off',...
                                                                                                                            'Tag','defaultlegendcontextmenu');

                                                                                                                            addlistener(h,'ObjectBeingDestroyed',@(h,e)delete(uic));
                                                                                                                            setappdata(uic,'CallbackObject',h);


                                                                                                                            uic.Callback={@defaultContextMenuCB,h};




                                                                                                                            lis(1)=event.proplistener(h,findprop(h,'UIContextMenu'),'PreGet',@(src,ed)defaultContextMenuCB(uic,ed,h));
                                                                                                                            lis(2)=event.proplistener(h,findprop(h,'ContextMenu'),'PreGet',@(src,ed)defaultContextMenuCB(uic,ed,h));
                                                                                                                            setappdata(uic,'PreGetListener',lis);

                                                                                                                            h.UIContextMenu=uic;


                                                                                                                            function defaultContextMenuCB(uic,~,leg)


                                                                                                                                if strcmp(leg.version,'on')
                                                                                                                                    return
                                                                                                                                end

                                                                                                                                h=leg;






                                                                                                                                uicBelongsToLegend=~isempty(h.UIContextMenu)&&h.UIContextMenu==uic;
                                                                                                                                updatingLegend=isappdata(h,'inUpdate')&&getappdata(h,'inUpdate');
                                                                                                                                if~uicBelongsToLegend||updatingLegend

                                                                                                                                    return
                                                                                                                                end


                                                                                                                                alreadyHasSubmenus=~isempty(uic.NodeChildren);
                                                                                                                                if~alreadyHasSubmenus




                                                                                                                                    hMenu=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'GeneralAction',getString(message('MATLAB:uistring:scribemenu:Delete')),'','',{@delete_cb,h});
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:delete');


                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'GeneralAction',getString(message('MATLAB:uistring:scribemenu:EditTitle')),'','',@(~,~)start_title_edit(h));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:edittitle');
                                                                                                                                    set(hMenu(end),'Separator','on');

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:color');

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'Color',getString(message('MATLAB:uistring:scribemenu:EdgeColorDotDotDot')),'EdgeColor',getString(message('MATLAB:uistring:scribemenu:EdgeColor')));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:edgecolor');

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:linewidth');
                                                                                                                                    hChil=findall(hMenu(end));
                                                                                                                                    hChil=hChil(2:end);
                                                                                                                                    widthTags={'scribe:legend:linewidth:12.0';'scribe:legend:linewidth:11.0';...
                                                                                                                                    'scribe:legend:linewidth:10.0';'scribe:legend:linewidth:9.0';...
                                                                                                                                    'scribe:legend:linewidth:8.0';'scribe:legend:linewidth:7.0';...
                                                                                                                                    'scribe:legend:linewidth:6.0';'scribe:legend:linewidth:5.0';...
                                                                                                                                    'scribe:legend:linewidth:4.0';'scribe:legend:linewidth:3.0';...
                                                                                                                                    'scribe:legend:linewidth:2.0';'scribe:legend:linewidth:1.0';...
                                                                                                                                    'scribe:legend:linewidth:0.5'};
                                                                                                                                    set(hChil,{'Tag'},widthTags);

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'Font',getString(message('MATLAB:uistring:scribemenu:FontDotDotDot')),'',getString(message('MATLAB:uistring:scribemenu:Font')));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:font');

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'TextInterpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')),'Interpreter',getString(message('MATLAB:uistring:scribemenu:Interpreter')));
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:interpreter');
                                                                                                                                    hChil=findall(hMenu(end));
                                                                                                                                    hChil=flipud(hChil(2:end));
                                                                                                                                    intTags={'scribe:legend:interpreter:latex';'scribe:legend:interpreter:tex';...
                                                                                                                                    'scribe:legend:interpreter:none'};
                                                                                                                                    set(hChil,{'Tag'},intTags);


                                                                                                                                    locationEnums={...
                                                                                                                                    'Northeast';...
                                                                                                                                    'Northwest';...
                                                                                                                                    'Southeast';...
                                                                                                                                    'Southwest';...
                                                                                                                                    'EastOutside';...
                                                                                                                                    'NortheastOutside';...
                                                                                                                                    'Best';...
                                                                                                                                    };
                                                                                                                                    locationTags=strcat('scribe:legend:location:',lower(locationEnums));
                                                                                                                                    locationMessageKeys=strcat('MATLAB:uistring:scribemenu:',locationEnums);
                                                                                                                                    locationStrings=cellfun(@(x)getString(message(x)),locationMessageKeys,'UniformOutput',false);

                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,...
                                                                                                                                    'EnumEntry',getString(message('MATLAB:uistring:scribemenu:Location')),...
                                                                                                                                    'Location',getString(message('MATLAB:uistring:scribemenu:Location')),...
                                                                                                                                    locationStrings,locationEnums);
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:location');
                                                                                                                                    hChil=findall(hMenu(end));
                                                                                                                                    hChil=flipud(hChil(2:end));
                                                                                                                                    set(hChil,{'Tag'},locationTags);


                                                                                                                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'EnumEntry',getString(message('MATLAB:uistring:scribemenu:Orientation')),'Orientation',getString(message('MATLAB:uistring:scribemenu:Orientation')),...
                                                                                                                                    {getString(message('MATLAB:uistring:scribemenu:Vertical')),getString(message('MATLAB:uistring:scribemenu:Horizontal'))},{'vertical','horizontal'});
                                                                                                                                    set(hMenu(end),'Tag','scribe:legend:orientation');hChil=findall(hMenu(end));
                                                                                                                                    hChil=flipud(hChil(2:end));
                                                                                                                                    ortags={'scribe:legend:orientation:vertical';'scribe:legend:orientation:horizontal'};
                                                                                                                                    set(hChil,{'Tag'},ortags);
                                                                                                                                    set(findall(hMenu),'Visible','on');


                                                                                                                                    hMenu(end+1)=uimenu(uic,'Label',getString(message('MATLAB:uistring:scribemenu:NumColumns')),...
                                                                                                                                    'Tag','scribe:legend:numcolumns',...
                                                                                                                                    'Callback',@(h,e)numColsCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label',getString(message('MATLAB:uistring:scribemenu:Auto')),'Tag','scribe:legend:numcolumns:auto','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','1','Tag','scribe:legend:numcolumns:1','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','2','Tag','scribe:legend:numcolumns:2','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','3','Tag','scribe:legend:numcolumns:3','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','4','Tag','scribe:legend:numcolumns:4','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','5','Tag','scribe:legend:numcolumns:5','Callback',@(h,e)numColsChoiceCB(e,leg));
                                                                                                                                    uimenu(hMenu(end),'Label','6','Tag','scribe:legend:numcolumns:6','Callback',@(h,e)numColsChoiceCB(e,leg));


                                                                                                                                    if(~isdeployed&&~ismcc)
                                                                                                                                        hMenu=uimenu(uic,'HandleVisibility','off','Separator','on',...
                                                                                                                                        'Label',getString(message('MATLAB:uistring:scribemenu:OpenPropertyInspector')),'Callback',{@localOpenPropertyEditor,h});
                                                                                                                                        set(hMenu,'Tag','scribe:legend:propedit');
                                                                                                                                    end


                                                                                                                                    fig=uic.Parent;
                                                                                                                                    if~isdeployed&&~ismcc&&isscalar(fig)&&isgraphics(fig,'figure')&&~isWebFigureType(fig,'UIFigure')
                                                                                                                                        hMenu=uimenu(uic,'HandleVisibility','off','Separator','on',...
                                                                                                                                        'Label',getString(message('MATLAB:uistring:scribemenu:ShowCode')),'Callback',{@localGenerateMCode,h});
                                                                                                                                        set(hMenu,'Tag','scribe:legend:mcode');
                                                                                                                                    end


                                                                                                                                    set(uic.NodeChildren,'HandleVisibility','off');
                                                                                                                                end


                                                                                                                                numItems=numel(getEntries(leg));
                                                                                                                                numColsMenu=findall(leg.UIContextMenu,'Tag','scribe:legend:numcolumns');
                                                                                                                                if numItems>1
                                                                                                                                    numColsMenu.Enable='on';
                                                                                                                                else
                                                                                                                                    numColsMenu.Enable='off';
                                                                                                                                end


                                                                                                                                function numColsCB(e,leg)



                                                                                                                                    numItems=numel(getEntries(leg));
                                                                                                                                    submenus=e.Source.NodeChildren;
                                                                                                                                    m=flipud(submenus);
                                                                                                                                    m=m(2:end);
                                                                                                                                    set(m,'Visible','off');
                                                                                                                                    set(m(1:min(numItems,6)),'Visible','on');


                                                                                                                                    set(submenus,'Checked','off');
                                                                                                                                    if strcmp(leg.NumColumnsMode,'auto')
                                                                                                                                        set(findobj(submenus,'Tag','scribe:legend:numcolumns:auto'),'Checked','on');
                                                                                                                                    else
                                                                                                                                        nc=leg.NumColumns;
                                                                                                                                        val_menus=findall(e.Source.NodeChildren,'-not','Tag','scribe:legend:numcolumns:auto');
                                                                                                                                        tags_mat=cell2mat(get(val_menus,'Tag'));
                                                                                                                                        vals=str2num(tags_mat(:,end));%#ok<ST2NM>
                                                                                                                                        ind=find(nc==vals);
                                                                                                                                        if~isempty(ind)
                                                                                                                                            val_menus(ind).Checked='on';
                                                                                                                                        end
                                                                                                                                    end


                                                                                                                                    function numColsChoiceCB(e,leg)

                                                                                                                                        set(e.Source.Parent.Children,'Checked','off');

                                                                                                                                        tag=e.Source.Tag;
                                                                                                                                        if strcmp(tag,'scribe:legend:numcolumns:auto')
                                                                                                                                            leg.NumColumnsMode='auto';
                                                                                                                                        else

                                                                                                                                            leg.NumColumns=str2double(e.Source.Text);
                                                                                                                                        end


                                                                                                                                        function localOpenPropertyEditor(obj,evd,hLeg)%#ok<INUSL>
                                                                                                                                            matlab.graphics.internal.propertyinspector.propertyinspector('show',hLeg);



                                                                                                                                            function localGenerateMCode(obj,evd,hLeg)%#ok<INUSL>

                                                                                                                                                makemcode(hLeg,'Output','-editor')


                                                                                                                                                function tokObj=localGetTokenItem(h_in)


                                                                                                                                                    if~strcmpi(get(h_in,'Type'),'hggroup')&&~strcmpi(get(h_in,'Type'),'hgtransform')
                                                                                                                                                        tokObj=h_in;
                                                                                                                                                        return
                                                                                                                                                    end


                                                                                                                                                    if isprop(h_in,'LegendLegendInfo')
                                                                                                                                                        tokObj=h_in;
                                                                                                                                                        return
                                                                                                                                                    end



                                                                                                                                                    hChil=get(h_in,'Children');

                                                                                                                                                    legKids=arrayfun(@(x)(matlab.graphics.illustration.internal.islegendable(x)),hChil);
                                                                                                                                                    hChil(~legKids)=[];
                                                                                                                                                    hChil=matlab.graphics.illustration.internal.expandLegendChildren(hChil);
                                                                                                                                                    if isempty(hChil)
                                                                                                                                                        tokObj=h_in;
                                                                                                                                                        return
                                                                                                                                                    end


                                                                                                                                                    tokObj=localGetTokenItem(hChil(1));


                                                                                                                                                    function createEntries(hObj,~)%#ok<*DEFNU>

                                                                                                                                                        children=hObj.PlotChildren_I;
                                                                                                                                                        children=children(isvalid(children));

                                                                                                                                                        for k=1:length(children)
                                                                                                                                                            item=children(k);


                                                                                                                                                            entry=matlab.graphics.illustration.legend.LegendEntry(hObj,item,k);


                                                                                                                                                            ic=matlab.graphics.illustration.legend.LegendIcon;






                                                                                                                                                            useLegendInfo=false;
                                                                                                                                                            obj=entry.Object;
                                                                                                                                                            if ismember(obj.Type,{'hggroup','hgtransform'})
                                                                                                                                                                if isappdata(obj,'LegendLegendInfo')
                                                                                                                                                                    li=getappdata(obj,'LegendLegendInfo');

                                                                                                                                                                    if isa(li,'matlab.graphics.illustration.legend.LegendInfo')
                                                                                                                                                                        useLegendInfo=true;
                                                                                                                                                                    else
                                                                                                                                                                        if isappdata(obj,'LegendLegendInfoStruct')
                                                                                                                                                                            lis=getappdata(obj,'LegendLegendInfoStruct');
                                                                                                                                                                            if~isempty(lis)


                                                                                                                                                                                setappdata(obj,'LegendLegendInfo',legendinfo(obj,lis{:}));
                                                                                                                                                                                useLegendInfo=true;
                                                                                                                                                                            end
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            end

                                                                                                                                                            if useLegendInfo

                                                                                                                                                                li=getappdata(entry.Object,'LegendLegendInfo');
                                                                                                                                                                ic.addGraphic(build_legendinfo_token(li));
                                                                                                                                                            else





                                                                                                                                                                m=metaclass(item);
                                                                                                                                                                method=findobj(m.MethodList,'Name','getLegendGraphic');
                                                                                                                                                                numArgs=numel(method.InputNames);

                                                                                                                                                                if numArgs==1
                                                                                                                                                                    ic.addGraphic(item.getLegendGraphic);
                                                                                                                                                                elseif numArgs==2
                                                                                                                                                                    ic.addGraphic(item.getLegendGraphic(hObj.FontSize_I));
                                                                                                                                                                end

                                                                                                                                                            end


                                                                                                                                                            entry.addIcon(ic);


                                                                                                                                                            addEntry(hObj,entry);


                                                                                                                                                            entry.Object.markLegendEntryClean();
                                                                                                                                                        end


                                                                                                                                                        function syncEntries(hObj)

                                                                                                                                                            entries=flipud(hObj.EntryContainer.Children);



                                                                                                                                                            changedFontSize=[entries.FontSize]~=hObj.FontSize_I;



                                                                                                                                                            dirtyEntries=entries([entries.Dirty]|changedFontSize);


                                                                                                                                                            for i=1:numel(dirtyEntries)
                                                                                                                                                                de=dirtyEntries(i);


                                                                                                                                                                if isvalid(de.Object)


                                                                                                                                                                    if isprop(de,'PeerVisible')
                                                                                                                                                                        de.PeerVisible=de.Object.Visible;
                                                                                                                                                                    end






                                                                                                                                                                    useLegendInfo=false;
                                                                                                                                                                    if ismember(de.Object.Type,{'hggroup','hgtransform'})
                                                                                                                                                                        if isappdata(de.Object,'LegendLegendInfo')
                                                                                                                                                                            li=getappdata(de.Object,'LegendLegendInfo');
                                                                                                                                                                            if isa(li,'matlab.graphics.illustration.legend.LegendInfo')
                                                                                                                                                                                useLegendInfo=true;
                                                                                                                                                                            end
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                    if useLegendInfo

                                                                                                                                                                        li=getappdata(de.Object,'LegendLegendInfo');
                                                                                                                                                                        de.Icon.addGraphic(build_legendinfo_token(li));
                                                                                                                                                                    else


                                                                                                                                                                        item=de.Object;
                                                                                                                                                                        m=metaclass(item);
                                                                                                                                                                        method=findobj(m.MethodList,'Name','getLegendGraphic');
                                                                                                                                                                        numArgs=numel(method.InputNames);
                                                                                                                                                                        if numArgs==1
                                                                                                                                                                            de.Icon.addGraphic(de.Object.getLegendGraphic);
                                                                                                                                                                        elseif numArgs==2
                                                                                                                                                                            de.Icon.addGraphic(de.Object.getLegendGraphic(hObj.FontSize_I));
                                                                                                                                                                        end
                                                                                                                                                                    end


                                                                                                                                                                    de.Dirty=false;
                                                                                                                                                                    de.Object.markLegendEntryClean();
                                                                                                                                                                end
                                                                                                                                                            end



                                                                                                                                                            function pushLegendPropsToLabels(h)

                                                                                                                                                                entries=getEntries(h);

                                                                                                                                                                for i=1:length(entries)
                                                                                                                                                                    e=entries(i);
                                                                                                                                                                    e.Color=h.TextColor_I;
                                                                                                                                                                    e.FontAngle=h.FontAngle_I;
                                                                                                                                                                    e.FontWeight=h.FontWeight_I;
                                                                                                                                                                    e.FontName=h.FontName_I;
                                                                                                                                                                    e.FontSize=h.FontSize_I;
                                                                                                                                                                    e.Interpreter=h.Interpreter_I;
                                                                                                                                                                end

                                                                                                                                                                function[tokenx,textx,xinc,totalWidth]=calculateXLocations(h,s,totalMinWidth,numEntries)












                                                                                                                                                                    positionpadding=0;
                                                                                                                                                                    totalWidth=totalMinWidth;
                                                                                                                                                                    if strcmp(h.Location,'none')

                                                                                                                                                                        vp=h.Camera.Viewport;
                                                                                                                                                                        vp.Units='points';
                                                                                                                                                                        pos_points=vp.Position;

                                                                                                                                                                        pos_width=pos_points(3);
                                                                                                                                                                        if pos_width>totalMinWidth
                                                                                                                                                                            totalWidth=pos_width;
                                                                                                                                                                            if strcmp(h.Orientation,'vertical')
                                                                                                                                                                                positionpadding=(pos_width-totalMinWidth)/2;
                                                                                                                                                                            else
                                                                                                                                                                                origcolspace=s.colspace;
                                                                                                                                                                                origleftspace=s.leftspace;
                                                                                                                                                                                totalspace=((numEntries-1)*origcolspace+2*origleftspace);
                                                                                                                                                                                s.colspace=s.colspace+(pos_width-totalMinWidth)*(origcolspace/totalspace);
                                                                                                                                                                                s.leftspace=s.leftspace+(pos_width-totalMinWidth)*(origleftspace/totalspace);
                                                                                                                                                                            end
                                                                                                                                                                        end
                                                                                                                                                                    end



                                                                                                                                                                    tokenx=[positionpadding+s.leftspace+s.itempadding,positionpadding+s.leftspace+s.itempadding+s.tokenwidth]/totalWidth;
                                                                                                                                                                    textx=(positionpadding+s.leftspace+s.itempadding+s.tokenwidth+s.tokentotextspace)/totalWidth;

                                                                                                                                                                    xinc=(s.tokenwidth+s.tokentotextspace+s.colspace)/totalWidth;


                                                                                                                                                                    function[ypos,tokeny,yinc]=calculateYLocations(h,s,itemsHeight,totalHeight)

                                                                                                                                                                        ypos=(itemsHeight-s.topspace-s.rowheights(1)/2)/totalHeight;


                                                                                                                                                                        tokeny=ypos+([-.5*s.tokenheight,.5*s.tokenheight]/totalHeight);


                                                                                                                                                                        tmp=(s.rowspace+s.rowheights)/totalHeight;
                                                                                                                                                                        yinc=(tmp(1:end-1)+tmp(2:end))/2;


                                                                                                                                                                        function layoutEntries(h,updateState)






                                                                                                                                                                            [minSize,sizeWithoutTitle,s]=doMethod(h,'getsize',updateState);

                                                                                                                                                                            entries=getEntries(h);
                                                                                                                                                                            numItems=length(entries);
                                                                                                                                                                            numColumns=h.NumColumnsInternal;
                                                                                                                                                                            numRows=h.NumRowsInternal;

                                                                                                                                                                            totalMinWidth=minSize(1);
                                                                                                                                                                            totalHeight=minSize(2);
                                                                                                                                                                            itemsHeight=sizeWithoutTitle(2);


                                                                                                                                                                            if supportsTitle(h)

                                                                                                                                                                                titlex=.5;
                                                                                                                                                                                titley=(totalHeight-s.titletopspace-s.titlestrsize(2)/2)/totalHeight;
                                                                                                                                                                                h.Title_I.Position=[titlex,titley,0];


                                                                                                                                                                                titlesepy=itemsHeight/totalHeight;
                                                                                                                                                                                h.TitleSeparator.VertexData=single([0,1;titlesepy,titlesepy;0,0]);
                                                                                                                                                                            else
                                                                                                                                                                                h.TitleSeparator.VertexData=single([]);
                                                                                                                                                                            end

                                                                                                                                                                            [tokenx,textx,~,totalWidth]=calculateXLocations(h,s,totalMinWidth,numItems);
                                                                                                                                                                            [ypos,tokeny,yinc]=calculateYLocations(h,s,itemsHeight,totalHeight);

                                                                                                                                                                            for k=1:numItems
                                                                                                                                                                                if strcmp(h.Orientation,'vertical')
                                                                                                                                                                                    col=ceil(k/numRows);
                                                                                                                                                                                    row=1+mod(k-1,numRows);
                                                                                                                                                                                else
                                                                                                                                                                                    col=1+mod(k-1,numColumns);
                                                                                                                                                                                    row=ceil(k/numColumns);
                                                                                                                                                                                end


                                                                                                                                                                                entries(k).Label.Position=[textx,ypos,0];





                                                                                                                                                                                tokenxdiff=diff(tokenx);
                                                                                                                                                                                if tokenxdiff<=0
                                                                                                                                                                                    tokenxdiff=.1;
                                                                                                                                                                                end
                                                                                                                                                                                tokenydiff=diff(tokeny);
                                                                                                                                                                                if tokenydiff<=0
                                                                                                                                                                                    tokenydiff=.1;
                                                                                                                                                                                end


                                                                                                                                                                                assert(tokeny(1)+tokenydiff<=1,'the legend icon should not draw outside the legend');


                                                                                                                                                                                m=makehgtform('translate',[tokenx(1),tokeny(1),0],'scale',[tokenxdiff,tokenydiff,1]);
                                                                                                                                                                                entries(k).Icon.Transform.Matrix=m;


                                                                                                                                                                                li=matlab.graphics.illustration.legend.ItemLayoutInfo;

                                                                                                                                                                                inFirstColumn=(col==1);
                                                                                                                                                                                inLastColumn=(col==numColumns);
                                                                                                                                                                                inFirstRow=(row==1);
                                                                                                                                                                                inLastRow=(row==numRows);
                                                                                                                                                                                maxStrWidthInColumn=max(s.strsizegrid(:,col,1))/totalWidth;
                                                                                                                                                                                maxStrHeightInRow=s.rowheights(row)/totalHeight;
                                                                                                                                                                                bottomSpace=s.botspace;

                                                                                                                                                                                if inFirstColumn
                                                                                                                                                                                    leftOfIconMargin=s.leftspace/totalWidth;
                                                                                                                                                                                else
                                                                                                                                                                                    leftOfIconMargin=(s.colspace/2)/totalWidth;
                                                                                                                                                                                end

                                                                                                                                                                                if inLastColumn
                                                                                                                                                                                    rightOfLabelMargin=s.rightspace/totalWidth;
                                                                                                                                                                                else
                                                                                                                                                                                    rightOfLabelMargin=(s.colspace/2)/totalWidth;
                                                                                                                                                                                end

                                                                                                                                                                                if inFirstRow
                                                                                                                                                                                    topMargin=s.topspace/totalHeight;
                                                                                                                                                                                else
                                                                                                                                                                                    topMargin=(s.rowspace/2)/totalHeight;
                                                                                                                                                                                end

                                                                                                                                                                                if inLastRow
                                                                                                                                                                                    bottomMargin=bottomSpace/totalHeight;
                                                                                                                                                                                else
                                                                                                                                                                                    bottomMargin=(s.rowspace/2)/totalHeight;
                                                                                                                                                                                end

                                                                                                                                                                                li.LeftEdge=tokenx(1)-leftOfIconMargin;
                                                                                                                                                                                li.RightEdge=textx+maxStrWidthInColumn+rightOfLabelMargin;
                                                                                                                                                                                li.IconToLabelEdge=(tokenx(2)+textx)/2;
                                                                                                                                                                                li.TopEdge=ypos+maxStrHeightInRow/2+topMargin;
                                                                                                                                                                                li.BottomEdge=ypos-maxStrHeightInRow/2-bottomMargin;
                                                                                                                                                                                entries(k).LayoutInfo=li;

                                                                                                                                                                                if k<numItems
                                                                                                                                                                                    if strcmp(h.Orientation,'vertical')
                                                                                                                                                                                        incrementRowPointers=(mod(row,numRows)~=0);
                                                                                                                                                                                        if incrementRowPointers

                                                                                                                                                                                            ypos=ypos-yinc(row);
                                                                                                                                                                                            tokeny=tokeny-yinc(row);
                                                                                                                                                                                        elseif col<numColumns

                                                                                                                                                                                            tokenx=tokenx+(s.columnwidths(col)+s.colspace)/totalWidth;
                                                                                                                                                                                            textx=textx+(s.columnwidths(col)+s.colspace)/totalWidth;


                                                                                                                                                                                            [ypos,tokeny]=calculateYLocations(h,s,itemsHeight,totalHeight);
                                                                                                                                                                                        end
                                                                                                                                                                                    else
                                                                                                                                                                                        incrementColPointers=(mod(col,numColumns)~=0);
                                                                                                                                                                                        if incrementColPointers

                                                                                                                                                                                            tokenx=tokenx+(s.columnwidths(col)+s.colspace)/totalWidth;
                                                                                                                                                                                            textx=textx+(s.columnwidths(col)+s.colspace)/totalWidth;
                                                                                                                                                                                        elseif row<numRows

                                                                                                                                                                                            ypos=ypos-yinc(row);
                                                                                                                                                                                            tokeny=tokeny-yinc(row);


                                                                                                                                                                                            [tokenx,textx]=calculateXLocations(h,s,totalMinWidth,numItems);
                                                                                                                                                                                        end
                                                                                                                                                                                    end
                                                                                                                                                                                end
                                                                                                                                                                            end


                                                                                                                                                                            function graphic=build_legendinfo_token(li)


                                                                                                                                                                                graphic=matlab.graphics.primitive.Group('HitTest','off',...
                                                                                                                                                                                'SelectionHighlight','off',...
                                                                                                                                                                                'Interruptible','off');


                                                                                                                                                                                gcomp=li.GlyphChildren;
                                                                                                                                                                                for k=1:length(gcomp)
                                                                                                                                                                                    build_legendinfo_component(graphic,gcomp(k));
                                                                                                                                                                                end
                                                                                                                                                                                if~isprop(graphic,'LegendInfo')
                                                                                                                                                                                    prop=addprop(graphic,'LegendInfo');
                                                                                                                                                                                    prop.Transient=true;
                                                                                                                                                                                    prop.Hidden=true;
                                                                                                                                                                                end
                                                                                                                                                                                set(graphic,'LegendInfo',li);


                                                                                                                                                                                function lich=build_legendinfo_component(p,lic)



                                                                                                                                                                                    convertConstructorName(lic);


                                                                                                                                                                                    if isempty(lic.PVPairs)
                                                                                                                                                                                        lich=feval(lic.ConstructorName,'Parent',p);
                                                                                                                                                                                    else
                                                                                                                                                                                        lich=feval(lic.ConstructorName,'Parent',p,lic.PVPairs{:});
                                                                                                                                                                                    end
                                                                                                                                                                                    set(lich,'HitTest','off');

                                                                                                                                                                                    if~isempty(lic.GlyphChildren)

                                                                                                                                                                                        gcomp=lic.GlyphChildren;

                                                                                                                                                                                        for k=1:length(gcomp)
                                                                                                                                                                                            build_legendinfo_component(lich,gcomp(k));
                                                                                                                                                                                        end
                                                                                                                                                                                    end


                                                                                                                                                                                    function adjust_data(lich,tx,ty)

                                                                                                                                                                                        if isprop(lich,'XData')&&isprop(lich,'YData')
                                                                                                                                                                                            x=get(lich,'XData');
                                                                                                                                                                                            y=get(lich,'YData');
                                                                                                                                                                                            x=tx(1)+diff(tx).*x;
                                                                                                                                                                                            y=ty(1)+diff(ty).*y;
                                                                                                                                                                                            set(lich,'XData',x,'YData',y);
                                                                                                                                                                                        end


                                                                                                                                                                                        if isprop(lich,'Position')
                                                                                                                                                                                            pos=get(lich,'Position');
                                                                                                                                                                                            pos(1)=tx(1)+diff(tx).*pos(1);
                                                                                                                                                                                            pos(2)=ty(1)+diff(ty).*pos(2);
                                                                                                                                                                                            set(lich,'Position',pos);
                                                                                                                                                                                        end


                                                                                                                                                                                        function convertConstructorName(lic)

                                                                                                                                                                                            switch lic.ConstructorName
                                                                                                                                                                                            case 'hg.line'
                                                                                                                                                                                                lic.ConstructorName='matlab.graphics.primitive.Line';
                                                                                                                                                                                            case 'hg.patch'
                                                                                                                                                                                                lic.ConstructorName='matlab.graphics.primitive.Patch';
                                                                                                                                                                                            case 'hg.surface'
                                                                                                                                                                                                lic.ConstructorName='matlab.graphics.primitive.Surface';
                                                                                                                                                                                            case 'hg.hggroup'
                                                                                                                                                                                                lic.ConstructorName='matlab.graphics.primitive.Group';
                                                                                                                                                                                            case 'hg.text'
                                                                                                                                                                                                lic.ConstructorName='matlab.graphics.primitive.Text';
                                                                                                                                                                                            end


                                                                                                                                                                                            function out=getfunhan(h,str,varargin)

                                                                                                                                                                                                if strcmp(str,'-noobj')
                                                                                                                                                                                                    str=varargin{1};
                                                                                                                                                                                                    if nargin==3
                                                                                                                                                                                                        out=str2func(str);
                                                                                                                                                                                                    else
                                                                                                                                                                                                        out={str2func(str),varargin{2:end}};
                                                                                                                                                                                                    end
                                                                                                                                                                                                else
                                                                                                                                                                                                    out=[{str2func(str),h},varargin];
                                                                                                                                                                                                end


                                                                                                                                                                                                function delete_cb(hProp,eventData,leg)%#ok



                                                                                                                                                                                                    hFig=ancestor(leg,'figure');
                                                                                                                                                                                                    hAx=leg.Axes;
                                                                                                                                                                                                    if isactiveuimode(hFig,'Standard.EditPlot')
                                                                                                                                                                                                        scribeccp(hFig,'delete');
                                                                                                                                                                                                    else
                                                                                                                                                                                                        delete(leg);
                                                                                                                                                                                                    end
                                                                                                                                                                                                    matlab.graphics.interaction.generateLiveCode(hAx,matlab.internal.editor.figure.ActionID.LEGEND_REMOVED);


                                                                                                                                                                                                    function clearEntries(leg)
                                                                                                                                                                                                        delete(leg.EntryContainer.Children);
                                                                                                                                                                                                        leg.MarkDirty('all');


                                                                                                                                                                                                        function update_contextmenu_cb(varargin)



                                                                                                                                                                                                            function setButtonDownFcn(hObj)

                                                                                                                                                                                                                hObj.ButtonDownFcn_I=@bdowncb;



                                                                                                                                                                                                                function doMarkDirty(hObj,varargin)
                                                                                                                                                                                                                    hObj.MarkDirty(varargin{:});







                                                                                                                                                                                                                    function createEntriesCompatible(hObj,~)

                                                                                                                                                                                                                        children=hObj.PlotChildren_I;

                                                                                                                                                                                                                        ax=hObj.Axes;
                                                                                                                                                                                                                        hObj.CLim=ax.CLim_I;

                                                                                                                                                                                                                        texthandle=matlab.graphics.GraphicsPlaceholder.empty;
                                                                                                                                                                                                                        tokenhandle=matlab.graphics.GraphicsPlaceholder.empty;

                                                                                                                                                                                                                        for k=1:length(children)
                                                                                                                                                                                                                            item=children(k);


                                                                                                                                                                                                                            entry=matlab.graphics.illustration.legend.LegendEntry(hObj,item,k);


                                                                                                                                                                                                                            label=matlab.graphics.illustration.legend.Text(entry.Object.DisplayName_I);
                                                                                                                                                                                                                            texthandle(end+1)=label.TextComp;%#ok<AGROW>
                                                                                                                                                                                                                            entry.addLabel(label);


                                                                                                                                                                                                                            ic=matlab.graphics.illustration.legend.LegendIcon;

                                                                                                                                                                                                                            item=localGetTokenItem(item);
                                                                                                                                                                                                                            type=get(item,'type');

                                                                                                                                                                                                                            if any(strcmpi(type,{'line','patch','surface'}))
                                                                                                                                                                                                                                switch type

                                                                                                                                                                                                                                case 'line'

                                                                                                                                                                                                                                    linehandle=matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Color_I',get(item,'Color_I'),...
                                                                                                                                                                                                                                    'LineWidth_I',get(item,'LineWidth'),...
                                                                                                                                                                                                                                    'LineStyle_I',get(item,'LineStyle_I'),...
                                                                                                                                                                                                                                    'Marker_I','none',...
                                                                                                                                                                                                                                    'Tag',item.DisplayName_I(:).',...
                                                                                                                                                                                                                                    'SelectionHighlight','off',...
                                                                                                                                                                                                                                    'HitTest','off',...
                                                                                                                                                                                                                                    'Interruptible','off');
                                                                                                                                                                                                                                    tokenhandle(end+1)=linehandle;
                                                                                                                                                                                                                                    setappdata(item,'legend_linetokenhandle',tokenhandle(end));




                                                                                                                                                                                                                                    markerhandle=matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Color_I',get(item,'Color_I'),...
                                                                                                                                                                                                                                    'LineWidth_I',get(item,'LineWidth'),...
                                                                                                                                                                                                                                    'LineStyle_I','none',...
                                                                                                                                                                                                                                    'Marker_I',get(item,'Marker_I'),...
                                                                                                                                                                                                                                    'MarkerSize_I',get(item,'MarkerSize'),...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',get(item,'MarkerEdgeColor'),...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',get(item,'MarkerFaceColor'),...
                                                                                                                                                                                                                                    'Tag',item.DisplayName_I(:).',...
                                                                                                                                                                                                                                    'HitTest','off',...
                                                                                                                                                                                                                                    'SelectionHighlight','off',...
                                                                                                                                                                                                                                    'Interruptible','off');
                                                                                                                                                                                                                                    tokenhandle(end+1)=markerhandle;
                                                                                                                                                                                                                                    setappdata(item,'legend_linemarkertokenhandle',tokenhandle(end));
                                                                                                                                                                                                                                    ic.addGraphic([linehandle,markerhandle]);


                                                                                                                                                                                                                                case{'patch','surface'}
                                                                                                                                                                                                                                    [edgecolor,facecolor]=patchcolors(hObj,item);
                                                                                                                                                                                                                                    [facevertcdata,facevertadata]=patchvdata(hObj,item);

                                                                                                                                                                                                                                    patchhandle=matlab.graphics.primitive.Patch(...
                                                                                                                                                                                                                                    'FaceColor_I',facecolor,...
                                                                                                                                                                                                                                    'EdgeColor_I',edgecolor,...
                                                                                                                                                                                                                                    'LineWidth_I',get(item,'LineWidth'),...
                                                                                                                                                                                                                                    'LineStyle_I',get(item,'LineStyle_I'),...
                                                                                                                                                                                                                                    'Marker_I',get(item,'Marker'),...
                                                                                                                                                                                                                                    'MarkerSize_I',hObj.FontSize_I,...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',get(item,'MarkerEdgeColor'),...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',get(item,'MarkerFaceColor'),...
                                                                                                                                                                                                                                    'FaceVertexCData_I',facevertcdata,...
                                                                                                                                                                                                                                    'FaceVertexAlphaData_I',facevertadata,...
                                                                                                                                                                                                                                    'Tag',item.DisplayName_I(:).',...
                                                                                                                                                                                                                                    'SelectionHighlight','off',...
                                                                                                                                                                                                                                    'HitTest','off',...
                                                                                                                                                                                                                                    'Interruptible','off');
                                                                                                                                                                                                                                    tokenhandle(end+1)=patchhandle;
                                                                                                                                                                                                                                    ic.addGraphic(patchhandle);
                                                                                                                                                                                                                                    setappdata(item,'legend_patchtokenhandle',tokenhandle(end));
                                                                                                                                                                                                                                end

                                                                                                                                                                                                                            else

                                                                                                                                                                                                                                iconObj=matlab.graphics.primitive.Group('Tag',item.DisplayName_I(:).',...
                                                                                                                                                                                                                                'hittest','off',...
                                                                                                                                                                                                                                'Selected','off',...
                                                                                                                                                                                                                                'SelectionHighlight','off');

                                                                                                                                                                                                                                switch type
                                                                                                                                                                                                                                case{'scatter'}
                                                                                                                                                                                                                                    cdata=item.CData_I;
                                                                                                                                                                                                                                    if isequal(size(cdata),[1,3])

                                                                                                                                                                                                                                        mfacecolor=cdata;
                                                                                                                                                                                                                                        if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                            switch item.MarkerFaceColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                mfacecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        medgecolor=cdata;
                                                                                                                                                                                                                                        if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                            switch item.MarkerEdgeColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                medgecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                medgecolor=mfacecolor;
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        cdata=[];
                                                                                                                                                                                                                                    elseif isequal(size(cdata(:)),size(item.XData(:)))

                                                                                                                                                                                                                                        mfacecolor='flat';
                                                                                                                                                                                                                                        if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                            switch item.MarkerFaceColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                mfacecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        medgecolor='flat';
                                                                                                                                                                                                                                        if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                            switch item.MarkerEdgeColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                medgecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                medgecolor=mfacecolor;
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        if~isempty(cdata)
                                                                                                                                                                                                                                            cdata=mean(cdata);
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    else

                                                                                                                                                                                                                                        c=cdata(ceil(size(cdata,1)/2),:);
                                                                                                                                                                                                                                        mfacecolor=c;
                                                                                                                                                                                                                                        if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                            switch item.MarkerFaceColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                mfacecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        medgecolor=c;
                                                                                                                                                                                                                                        if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                            switch item.MarkerEdgeColor
                                                                                                                                                                                                                                            case 'none'
                                                                                                                                                                                                                                                medgecolor='none';
                                                                                                                                                                                                                                            case 'auto'
                                                                                                                                                                                                                                                medgecolor=mfacecolor;
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        cdata=[];
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    if~ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                        medgecolor=item.MarkerEdgeColor;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    if~ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                        mfacecolor=item.MarkerFaceColor;
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    matlab.graphics.primitive.Patch('Parent',iconObj,...
                                                                                                                                                                                                                                    'Marker_I',item.Marker_I,...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',medgecolor,...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',mfacecolor,...
                                                                                                                                                                                                                                    'EdgeColor_I','none',...
                                                                                                                                                                                                                                    'FaceColor_I','none',...
                                                                                                                                                                                                                                    'MarkerSize_I',6,...
                                                                                                                                                                                                                                    'CData_I',cdata,...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    setappdata(double(item),'LegendLegendType','patch');
                                                                                                                                                                                                                                case{'stair','errorbar'}



                                                                                                                                                                                                                                    lis=matlab.graphics.primitive.Group('hittest','off',...
                                                                                                                                                                                                                                    'Selected','off');

                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'Marker_I','none',...
                                                                                                                                                                                                                                    'HitTest','off');

                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineStyle_I','none',...
                                                                                                                                                                                                                                    'Marker_I',item.Marker_I,...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',item.MarkerEdgeColor,...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',item.MarkerFaceColor,...
                                                                                                                                                                                                                                    'MarkerSize_I',item.MarkerSize,...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    lis.Parent=iconObj;
                                                                                                                                                                                                                                    setappdata(double(item),'LegendLegendType','line');

                                                                                                                                                                                                                                case{'area','bar'}
                                                                                                                                                                                                                                    facecdata=getCDataFromColorData(item.Face);
                                                                                                                                                                                                                                    edgecdata=getCDataFromColorData(item.Edge);
                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    matlab.graphics.primitive.Patch(...
                                                                                                                                                                                                                                    'Parent',iconObj,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'EdgeColor_I',edgecdata,...
                                                                                                                                                                                                                                    'FaceColor_I',facecdata,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'HitTest','off');

                                                                                                                                                                                                                                    setappdata(item,'legend_patchtokenhandle',tokenhandle(end));

                                                                                                                                                                                                                                case 'stem'

                                                                                                                                                                                                                                    c=item.MarkerFaceColor;
                                                                                                                                                                                                                                    if strcmp(c,'auto')
                                                                                                                                                                                                                                        edge=get(item,'MarkerEdgeColor');
                                                                                                                                                                                                                                        if strcmp(edge,'auto')
                                                                                                                                                                                                                                            edge=get(get(item,'MarkerHandle'),'color');
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        mfacecolor=edge;
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        mfacecolor=c;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    lis=matlab.graphics.primitive.Group('Parent',iconObj,...
                                                                                                                                                                                                                                    'hittest','off',...
                                                                                                                                                                                                                                    'Selected','off');
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'Marker_I','none',...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'Marker_I',item.Marker_I,...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',item.MarkerEdgeColor,...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',mfacecolor,...
                                                                                                                                                                                                                                    'MarkerSize_I',item.MarkerSize,...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    setappdata(double(item),'LegendLegendType','line');
                                                                                                                                                                                                                                case{'quiver'}
                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    lis=matlab.graphics.primitive.Group('Parent',iconObj,...
                                                                                                                                                                                                                                    'hittest','off',...
                                                                                                                                                                                                                                    'Selected','off');
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'Marker_I','none',...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                    'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                    'Marker_I','none',...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    matlab.graphics.primitive.Line(...
                                                                                                                                                                                                                                    'Parent',lis,...
                                                                                                                                                                                                                                    'Color_I',item.Color,...
                                                                                                                                                                                                                                    'LineStyle_I','none',...
                                                                                                                                                                                                                                    'Marker_I',item.Marker_I,...
                                                                                                                                                                                                                                    'MarkerEdgeColor_I',item.MarkerEdgeColor,...
                                                                                                                                                                                                                                    'MarkerFaceColor_I',item.MarkerFaceColor,...
                                                                                                                                                                                                                                    'MarkerSize_I',item.MarkerSize,...
                                                                                                                                                                                                                                    'HitTest','off');
                                                                                                                                                                                                                                    lis.Parent=iconObj;
                                                                                                                                                                                                                                    setappdata(double(item),'LegendLegendType','line');
                                                                                                                                                                                                                                case{'contour'}
                                                                                                                                                                                                                                    tokenhandle(end+1)=iconObj;
                                                                                                                                                                                                                                    lis=matlab.graphics.primitive.Group('Parent',iconObj,...
                                                                                                                                                                                                                                    'hittest','off',...
                                                                                                                                                                                                                                    'Selected','off');

                                                                                                                                                                                                                                    llist=item.LevelList;
                                                                                                                                                                                                                                    if length(llist)>3
                                                                                                                                                                                                                                        pllist=[llist(1),llist(round(length(llist)/2)),llist(length(llist))];
                                                                                                                                                                                                                                        if pllist(1)==pllist(2)||pllist(2)==pllist(3)
                                                                                                                                                                                                                                            pllist=[pllist(1),pllist(3)];
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        pllist=llist;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    if isequal(item.Fill,'on')
                                                                                                                                                                                                                                        fcolor='flat';
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        fcolor='none';
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    if isnumeric(item.LineColor)
                                                                                                                                                                                                                                        edgecolor=item.LineColor;
                                                                                                                                                                                                                                    else
                                                                                                                                                                                                                                        edgecolor='flat';
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    for i=1:length(pllist)
                                                                                                                                                                                                                                        if length(pllist)==1
                                                                                                                                                                                                                                            xd=[0,1];
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            w=(length(pllist)-i+1)/length(pllist);
                                                                                                                                                                                                                                            h=w;
                                                                                                                                                                                                                                            [xd,~]=makeEllipseData(.5,.5,w,h);
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        matlab.graphics.primitive.Patch(...
                                                                                                                                                                                                                                        'Parent',lis,...
                                                                                                                                                                                                                                        'LineWidth_I',item.LineWidth,...
                                                                                                                                                                                                                                        'LineStyle_I',item.LineStyle_I,...
                                                                                                                                                                                                                                        'EdgeColor_I',edgecolor,...
                                                                                                                                                                                                                                        'FaceColor_I',fcolor,...
                                                                                                                                                                                                                                        'CData_I',repmat(pllist(i),length(xd),1),...
                                                                                                                                                                                                                                        'HitTest','off');
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    lis.Parent=iconObj;
                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                ic.addGraphic(iconObj);
                                                                                                                                                                                                                            end


                                                                                                                                                                                                                            entry.addIcon(ic);


                                                                                                                                                                                                                            addEntry(hObj,entry);


                                                                                                                                                                                                                            entry.Object.markLegendEntryClean();
                                                                                                                                                                                                                        end

                                                                                                                                                                                                                        if(hObj.version)
                                                                                                                                                                                                                            hObj.ItemTokens=tokenhandle(:);
                                                                                                                                                                                                                            hObj.ItemText=texthandle(:);
                                                                                                                                                                                                                        end


                                                                                                                                                                                                                        function out=getsizeinfoCompatible(h,updateState)










                                                                                                                                                                                                                            pixelsPerPoint=getpixelsperpoint(h);
                                                                                                                                                                                                                            out.topspace=2/pixelsPerPoint;
                                                                                                                                                                                                                            out.rowspace=.5/pixelsPerPoint;
                                                                                                                                                                                                                            out.botspace=2/pixelsPerPoint;
                                                                                                                                                                                                                            out.leftspace=4/pixelsPerPoint;
                                                                                                                                                                                                                            out.colspace=5/pixelsPerPoint;
                                                                                                                                                                                                                            out.rightspace=4/pixelsPerPoint;
                                                                                                                                                                                                                            out.tokentotextspace=3/pixelsPerPoint;
                                                                                                                                                                                                                            out.tokenwidth=h.ItemTokenSize(1);
                                                                                                                                                                                                                            out.tokenheight=h.ItemTokenSize(2);
                                                                                                                                                                                                                            out.strsizes=getStringSizes(h,updateState);

                                                                                                                                                                                                                            suppTitle=supportsTitle(h);


                                                                                                                                                                                                                            if suppTitle
                                                                                                                                                                                                                                out.titlebotspace=2/pixelsPerPoint;
                                                                                                                                                                                                                                out.titletopspace=2/pixelsPerPoint;
                                                                                                                                                                                                                                out.titlestrsize=getTitleStringSize(h,updateState);
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                out.titlebotspace=0;
                                                                                                                                                                                                                                out.titletopspace=0;
                                                                                                                                                                                                                                out.titlestrsize=[0,0];
                                                                                                                                                                                                                            end






                                                                                                                                                                                                                            out.titlesectionwidth=max(out.titlestrsize(1),0);
                                                                                                                                                                                                                            out.titlesectionheight=suppTitle*(out.titletopspace+out.titlestrsize(2)+out.titlebotspace);
                                                                                                                                                                                                                            numItems=size(out.strsizes,1);
                                                                                                                                                                                                                            if strcmpi(h.Orientation,'vertical')
                                                                                                                                                                                                                                out.itemsectionwidth=out.tokenwidth+out.tokentotextspace+max([out.strsizes(:,1);0]);
                                                                                                                                                                                                                                out.itemsectionheight=out.topspace+...
                                                                                                                                                                                                                                sum(out.strsizes(:,2))+...
                                                                                                                                                                                                                                max([numItems-1,0])*out.rowspace+...
                                                                                                                                                                                                                                out.botspace;
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                out.itemsectionwidth=numItems*out.tokenwidth+...
                                                                                                                                                                                                                                numItems*out.tokentotextspace+...
                                                                                                                                                                                                                                max(numItems-1,0)*out.colspace+...
                                                                                                                                                                                                                                sum(out.strsizes(:,1));
                                                                                                                                                                                                                                out.itemsectionheight=out.topspace+...
                                                                                                                                                                                                                                max([out.strsizes(:,2);0])+...
                                                                                                                                                                                                                                out.rowspace+...
                                                                                                                                                                                                                                out.botspace;
                                                                                                                                                                                                                            end



                                                                                                                                                                                                                            out.itempadding=max(0,.5*(out.titlesectionwidth-out.itemsectionwidth));


                                                                                                                                                                                                                            out.totalwidth=out.leftspace+2*out.itempadding+out.itemsectionwidth+out.rightspace;
                                                                                                                                                                                                                            out.totalheight=out.itemsectionheight+out.titlesectionheight;




                                                                                                                                                                                                                            function layoutEntriesCompatible(hObj,updateState)

                                                                                                                                                                                                                                entries=getEntries(hObj);


                                                                                                                                                                                                                                [lpos,~,s]=getsize(hObj,updateState);


                                                                                                                                                                                                                                tokenx=[s.leftspace,s.leftspace+s.tokenwidth]/lpos(1);
                                                                                                                                                                                                                                textx=(s.leftspace+s.tokenwidth+s.tokentotextspace)/lpos(1);

                                                                                                                                                                                                                                ypos=1-((s.topspace+(s.strsizes(1,2)/2))/lpos(2));

                                                                                                                                                                                                                                tokeny=([s.strsizes(1,2)/-2.5+s.rowspace/2,s.strsizes(1,2)/2.5-s.rowspace/2]/lpos(2))+ypos;

                                                                                                                                                                                                                                yinc=(s.rowspace+s.strsizes(:,2))/lpos(2);

                                                                                                                                                                                                                                xinc=(s.tokenwidth+s.tokentotextspace+s.colspace)/lpos(1);

                                                                                                                                                                                                                                icons=hObj.ItemTokens;

                                                                                                                                                                                                                                tindex=1;
                                                                                                                                                                                                                                for k=1:length(entries)
                                                                                                                                                                                                                                    entry=entries(k);
                                                                                                                                                                                                                                    item=entry.Object;


                                                                                                                                                                                                                                    set(entry,...
                                                                                                                                                                                                                                    'Color',hObj.TextColor,...
                                                                                                                                                                                                                                    'Interpreter',hObj.Interpreter,...
                                                                                                                                                                                                                                    'FontSize',hObj.FontSize_I,...
                                                                                                                                                                                                                                    'FontAngle',hObj.FontAngle_I,...
                                                                                                                                                                                                                                    'FontWeight',hObj.FontWeight_I,...
                                                                                                                                                                                                                                    'FontName',hObj.FontName_I);
                                                                                                                                                                                                                                    set(entry.Label,'Position',[textx,ypos,0]);


                                                                                                                                                                                                                                    item=localGetTokenItem(item);

                                                                                                                                                                                                                                    type=get(item,'type');
                                                                                                                                                                                                                                    switch type

                                                                                                                                                                                                                                    case{'line'}

                                                                                                                                                                                                                                        set(icons(tindex),...
                                                                                                                                                                                                                                        'XData',tokenx,...
                                                                                                                                                                                                                                        'YData',[ypos,ypos]);

                                                                                                                                                                                                                                        tindex=tindex+1;



                                                                                                                                                                                                                                        set(icons(tindex),...
                                                                                                                                                                                                                                        'XData',(tokenx(1)+tokenx(2))/2,...
                                                                                                                                                                                                                                        'YData',ypos);
                                                                                                                                                                                                                                        tindex=tindex+1;

                                                                                                                                                                                                                                    case{'patch','surface'}
                                                                                                                                                                                                                                        pyd=get(item,'xdata');
                                                                                                                                                                                                                                        if length(pyd)==1
                                                                                                                                                                                                                                            pxdata=sum(tokenx)/length(tokenx);
                                                                                                                                                                                                                                            pydata=ypos;
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            pxdata=[tokenx(1),tokenx(1),tokenx(2),tokenx(2)];
                                                                                                                                                                                                                                            pydata=[tokeny(1),tokeny(2),tokeny(2),tokeny(1)];
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        set(icons(tindex),...
                                                                                                                                                                                                                                        'XData',pxdata,...
                                                                                                                                                                                                                                        'YData',pydata);
                                                                                                                                                                                                                                        tindex=tindex+1;

                                                                                                                                                                                                                                    case{'area','bar'}
                                                                                                                                                                                                                                        patchh=icons(tindex).Children;
                                                                                                                                                                                                                                        set(patchh,...
                                                                                                                                                                                                                                        'XData',[0,0,1,1,0],...
                                                                                                                                                                                                                                        'YData',[0,1,1,0,0]);
                                                                                                                                                                                                                                        adjust_data(patchh,tokenx,tokeny);
                                                                                                                                                                                                                                        tindex=tindex+1;
                                                                                                                                                                                                                                    case{'stem'}
                                                                                                                                                                                                                                        lines=icons(tindex).Children.Children;

                                                                                                                                                                                                                                        set(lines(2),...
                                                                                                                                                                                                                                        'XData',[0,0.7],...
                                                                                                                                                                                                                                        'YData',[0.5,0.5]);
                                                                                                                                                                                                                                        adjust_data(lines(2),tokenx,tokeny);




                                                                                                                                                                                                                                        set(lines(1),...
                                                                                                                                                                                                                                        'XData',0.7,...
                                                                                                                                                                                                                                        'YData',0.5);
                                                                                                                                                                                                                                        adjust_data(lines(1),tokenx,tokeny);
                                                                                                                                                                                                                                        tindex=tindex+1;

                                                                                                                                                                                                                                    case{'stair','errorbar'}
                                                                                                                                                                                                                                        lines=icons(tindex).Children.Children;

                                                                                                                                                                                                                                        set(lines(2),...
                                                                                                                                                                                                                                        'Marker','none',...
                                                                                                                                                                                                                                        'XData',[0,1],...
                                                                                                                                                                                                                                        'YData',[0.5,0.5]);
                                                                                                                                                                                                                                        adjust_data(lines(2),tokenx,tokeny);




                                                                                                                                                                                                                                        set(lines(1),...
                                                                                                                                                                                                                                        'LineStyle','none',...
                                                                                                                                                                                                                                        'XData',0.5,...
                                                                                                                                                                                                                                        'YData',0.5);
                                                                                                                                                                                                                                        adjust_data(lines(1),tokenx,tokeny);
                                                                                                                                                                                                                                        tindex=tindex+1;

                                                                                                                                                                                                                                    case{'quiver'}
                                                                                                                                                                                                                                        lines=icons(tindex).Children.Children;
                                                                                                                                                                                                                                        set(lines(3),...
                                                                                                                                                                                                                                        'XData',[0,1],...
                                                                                                                                                                                                                                        'YData',[.5,.5]);
                                                                                                                                                                                                                                        adjust_data(lines(3),tokenx,tokeny);
                                                                                                                                                                                                                                        set(lines(2),...
                                                                                                                                                                                                                                        'XData',[.7,1,.7],...
                                                                                                                                                                                                                                        'YData',[.7,.5,.3]);
                                                                                                                                                                                                                                        adjust_data(lines(2),tokenx,tokeny);
                                                                                                                                                                                                                                        set(lines(1),...
                                                                                                                                                                                                                                        'XData',0,...
                                                                                                                                                                                                                                        'YData',.5);
                                                                                                                                                                                                                                        adjust_data(lines(1),tokenx,tokeny);
                                                                                                                                                                                                                                        tindex=tindex+1;
                                                                                                                                                                                                                                    case{'scatter'}
                                                                                                                                                                                                                                        scatter_icons=icons(tindex).Children;
                                                                                                                                                                                                                                        set(scatter_icons,...
                                                                                                                                                                                                                                        'XData',.5,...
                                                                                                                                                                                                                                        'YData',.5);
                                                                                                                                                                                                                                        adjust_data(scatter_icons,tokenx,tokeny);
                                                                                                                                                                                                                                        tindex=tindex+1;
                                                                                                                                                                                                                                    case{'contour'}
                                                                                                                                                                                                                                        contour_icons=icons(tindex).Children.Children;

                                                                                                                                                                                                                                        llist=item.LevelList;
                                                                                                                                                                                                                                        if length(llist)>3
                                                                                                                                                                                                                                            pllist=[llist(1),llist(round(length(llist)/2)),llist(length(llist))];
                                                                                                                                                                                                                                            if pllist(1)==pllist(2)||pllist(2)==pllist(3)
                                                                                                                                                                                                                                                pllist=[pllist(1),pllist(3)];
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            pllist=llist;
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        for i=1:length(pllist)
                                                                                                                                                                                                                                            if length(pllist)==1
                                                                                                                                                                                                                                                xd=[0,1];
                                                                                                                                                                                                                                                yd=[0.5,0.5];
                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                width=i/length(pllist);
                                                                                                                                                                                                                                                height=width;
                                                                                                                                                                                                                                                [xd,yd]=makeEllipseData(.5,.5,width,height);
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            set(contour_icons(i),'XData',xd,...
                                                                                                                                                                                                                                            'YData',yd);
                                                                                                                                                                                                                                            adjust_data(contour_icons(i),tokenx,tokeny);
                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                        tindex=tindex+1;
                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                    if k<size(s.strsizes,1)
                                                                                                                                                                                                                                        if strcmpi(hObj.Orientation,'vertical')
                                                                                                                                                                                                                                            ypos=ypos-(yinc(k)+yinc(k+1))/2;
                                                                                                                                                                                                                                            tokeny=tokeny-(yinc(k)+yinc(k+1))/2;
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            tokenx=tokenx+xinc+s.strsizes(k,1)/lpos(1);
                                                                                                                                                                                                                                            textx=textx+xinc+s.strsizes(k,1)/lpos(1);
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                function[x,y]=makeEllipseData(cx,cy,w,h)

                                                                                                                                                                                                                                    theta=linspace(0,2*pi,24);
                                                                                                                                                                                                                                    x=w/2*cos(theta)+cx;
                                                                                                                                                                                                                                    y=h/2*sin(theta)+cy;

                                                                                                                                                                                                                                    function cdata=getCDataFromColorData(obj)
                                                                                                                                                                                                                                        if obj.ColorData(4)~=0
                                                                                                                                                                                                                                            cdata=obj.ColorData(1:3);
                                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                            cdata='none';
                                                                                                                                                                                                                                        end

                                                                                                                                                                                                                                        function g=getGraphic(icon)
                                                                                                                                                                                                                                            g=icon.Transform.Children;


                                                                                                                                                                                                                                            function syncEntriesCompatible(hObj)


                                                                                                                                                                                                                                                entries=flipud(hObj.EntryContainer.Children);
                                                                                                                                                                                                                                                dirtyEntries=entries([entries.Dirty]);

                                                                                                                                                                                                                                                if~isempty(dirtyEntries)
                                                                                                                                                                                                                                                    for i=1:numel(dirtyEntries)
                                                                                                                                                                                                                                                        de=dirtyEntries(i);


                                                                                                                                                                                                                                                        if isvalid(de.Object)


                                                                                                                                                                                                                                                            de.Label.String=de.Object.DisplayName_I;




                                                                                                                                                                                                                                                            ax=hObj.Axes;
                                                                                                                                                                                                                                                            item=de.Object;
                                                                                                                                                                                                                                                            icon=getGraphic(de.Icon);

                                                                                                                                                                                                                                                            type=get(item,'type');
                                                                                                                                                                                                                                                            switch type

                                                                                                                                                                                                                                                            case{'line'}

                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(2),'Color',get(item,'Color_I'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(2),'LineWidth',get(item,'LineWidth'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(2),'LineStyle',get(item,'LineStyle_I'));
                                                                                                                                                                                                                                                                set(icon(2),'Tag',item.DisplayName_I(:).');




                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'Color',get(item,'Color_I'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'LineWidth',get(item,'LineWidth'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'Marker',get(item,'Marker_I'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'MarkerSize',get(item,'MarkerSize'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'MarkerEdgeColor',get(item,'MarkerEdgeColor'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon(1),'MarkerFaceColor',get(item,'MarkerFaceColor'));
                                                                                                                                                                                                                                                                set(icon(1),'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                            case{'patch','surface'}

                                                                                                                                                                                                                                                                [edgecolor,facecolor]=patchcolors(hObj,item);
                                                                                                                                                                                                                                                                [facevertcdata,facevertadata]=patchvdata(hObj,item);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'FaceColor',facecolor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'EdgeColor',edgecolor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'LineWidth',get(item,'LineWidth'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'LineStyle',get(item,'LineStyle'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'Marker',get(item,'Marker'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'MarkerSize',hObj.FontSize_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'MarkerEdgeColor',get(item,'MarkerEdgeColor'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'MarkerFaceColor',get(item,'MarkerFaceColor'));
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'FaceVertexCData',facevertcdata);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(icon,'FaceVertexAlphaData',facevertadata);

                                                                                                                                                                                                                                                                set(icon,'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                            case{'area','bar'}
                                                                                                                                                                                                                                                                facecdata=getCDataFromColorData(item.Face);
                                                                                                                                                                                                                                                                edgecdata=getCDataFromColorData(item.Edge);

                                                                                                                                                                                                                                                                patchh=icon.Children;
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(patchh,'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(patchh,'EdgeColor',edgecdata);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(patchh,'FaceColor',facecdata);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(patchh,'LineStyle',item.LineStyle_I);
                                                                                                                                                                                                                                                                set(patchh,'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                            case{'stem'}
                                                                                                                                                                                                                                                                lines=icon.Children.Children;

                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'LineStyle',item.LineStyle_I);
                                                                                                                                                                                                                                                                set(lines(2),'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                                c=item.MarkerFaceColor;
                                                                                                                                                                                                                                                                if strcmp(c,'auto')
                                                                                                                                                                                                                                                                    edge=get(item,'MarkerEdgeColor');
                                                                                                                                                                                                                                                                    if strcmp(edge,'auto')
                                                                                                                                                                                                                                                                        edge=get(get(item,'MarkerHandle'),'color');
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    mfacecolor=edge;
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    mfacecolor=c;
                                                                                                                                                                                                                                                                end




                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineStyle',item.LineStyle_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'Marker',item.Marker_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'MarkerEdgeColor',item.MarkerEdgeColor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'MarkerFaceColor',mfacecolor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'MarkerSize',item.MarkerSize);
                                                                                                                                                                                                                                                                set(lines(1),'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                            case{'stair','errorbar'}
                                                                                                                                                                                                                                                                lines=icon.Children.Children;

                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineStyle',item.LineStyle_I);
                                                                                                                                                                                                                                                                set(lines(1),'Tag',item.DisplayName_I(:).');




                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'Marker',item.Marker_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'MarkerEdgeColor',item.MarkerEdgeColor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'MarkerFaceColor',item.MarkerFaceColor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'MarkerSize',item.MarkerSize);
                                                                                                                                                                                                                                                                set(lines(2),'Tag',item.DisplayName_I(:).');

                                                                                                                                                                                                                                                            case{'quiver'}
                                                                                                                                                                                                                                                                lines=icon.Children.Children;
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(1),'LineStyle',item.LineStyle_I);

                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'LineWidth',item.LineWidth);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(2),'LineStyle',item.LineStyle_I);

                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(3),'Color',item.Color);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(3),'Marker',item.Marker_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(3),'MarkerEdgeColor',item.MarkerEdgeColor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(3),'MarkerFaceColor',item.MarkerFaceColor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(lines(3),'MarkerSize',item.MarkerSize);

                                                                                                                                                                                                                                                            case{'scatter'}
                                                                                                                                                                                                                                                                s=icon.Children;
                                                                                                                                                                                                                                                                cdata=item.CData_I;
                                                                                                                                                                                                                                                                if isequal(size(cdata),[1,3])

                                                                                                                                                                                                                                                                    mfacecolor=cdata;
                                                                                                                                                                                                                                                                    if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                                                        switch item.MarkerFaceColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            mfacecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    medgecolor=cdata;
                                                                                                                                                                                                                                                                    if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                                                        switch item.MarkerEdgeColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            medgecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            medgecolor=mfacecolor;
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    cdata=[];
                                                                                                                                                                                                                                                                elseif isequal(size(cdata(:)),size(item.XData(:)))

                                                                                                                                                                                                                                                                    mfacecolor='flat';
                                                                                                                                                                                                                                                                    if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                                                        switch item.MarkerFaceColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            mfacecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    medgecolor='flat';
                                                                                                                                                                                                                                                                    if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                                                        switch item.MarkerEdgeColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            medgecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            medgecolor=mfacecolor;
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if~isempty(cdata)
                                                                                                                                                                                                                                                                        cdata=mean(cdata);
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                else

                                                                                                                                                                                                                                                                    c=cdata(ceil(size(cdata,1)/2),:);
                                                                                                                                                                                                                                                                    mfacecolor=c;
                                                                                                                                                                                                                                                                    if ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                                                        switch item.MarkerFaceColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            mfacecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            mfacecolor=get(ax,'color');
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    medgecolor=c;
                                                                                                                                                                                                                                                                    if ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                                                        switch item.MarkerEdgeColor
                                                                                                                                                                                                                                                                        case 'none'
                                                                                                                                                                                                                                                                            medgecolor='none';
                                                                                                                                                                                                                                                                        case 'auto'
                                                                                                                                                                                                                                                                            medgecolor=mfacecolor;
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    cdata=[];
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if~ischar(item.MarkerEdgeColor)
                                                                                                                                                                                                                                                                    medgecolor=item.MarkerEdgeColor;
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                if~ischar(item.MarkerFaceColor)
                                                                                                                                                                                                                                                                    mfacecolor=item.MarkerFaceColor;
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'Marker',item.Marker_I);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'MarkerEdgeColor',medgecolor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'MarkerFaceColor',mfacecolor);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'EdgeColor','none');
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'FaceColor','none');
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'MarkerSize',6);
                                                                                                                                                                                                                                                                setIconIfPropertyModeManual(s,'CData',cdata);
                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                        de.Dirty=false;
                                                                                                                                                                                                                                                        de.Object.markLegendEntryClean();

                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                function setIconIfPropertyModeManual(icon,iconProperty,objectPropertyValue)
                                                                                                                                                                                                                                                    if strcmp(get(icon,[iconProperty,'Mode']),'auto')
                                                                                                                                                                                                                                                        set(icon,[iconProperty,'_I'],objectPropertyValue);
                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                    function initializePositionCacheCompatible(hObj)



                                                                                                                                                                                                                                                        if hObj.InitPositionCache
                                                                                                                                                                                                                                                            pc.PositionCacheNormalized=[0,0,0,0];
                                                                                                                                                                                                                                                            pc.PositionCachePoints=[0,0,0,0];
                                                                                                                                                                                                                                                            pc.ParentPositionCachePoints=[0,0,0,0];
                                                                                                                                                                                                                                                            pc.PeerPositionCachePoints=[0,0,0,0];
                                                                                                                                                                                                                                                            pc.PeerPositionCacheNorm=[0,0,0,0];
                                                                                                                                                                                                                                                            pc.PinToPeerCacheNorm=[0,0];
                                                                                                                                                                                                                                                            pc.OrientationCache=hObj.Orientation_I;
                                                                                                                                                                                                                                                            hObj.PositionCache=pc;

                                                                                                                                                                                                                                                            hObj.InitPositionCache=false;
                                                                                                                                                                                                                                                        end


                                                                                                                                                                                                                                                        function doUpdateCompatible(hObj,updateState)

                                                                                                                                                                                                                                                            if isempty(hObj.Axes)
                                                                                                                                                                                                                                                                return
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                peerAxes=hObj.Axes;
                                                                                                                                                                                                                                                            end



                                                                                                                                                                                                                                                            hObj.UIContextMenu=[];

                                                                                                                                                                                                                                                            initializePositionCacheCompatible(hObj);





                                                                                                                                                                                                                                                            if ismember(hObj.Location,{'best','bestoutside','none'})
                                                                                                                                                                                                                                                                matlab.graphics.illustration.internal.updateFontProperties(hObj,peerAxes);
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            if strcmp(hObj.LineWidthMode,'auto')
                                                                                                                                                                                                                                                                hObj.LineWidth_I=peerAxes.LineWidth;
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            if~isempty(hObj.PlotChildren_I)&&all(isvalid(hObj.PlotChildren_I))
                                                                                                                                                                                                                                                                if isempty(hObj.EntryContainer.Children)

                                                                                                                                                                                                                                                                    createEntriesCompatible(hObj,updateState);


                                                                                                                                                                                                                                                                    layoutEntriesCompatible(hObj,updateState);
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    syncEntriesCompatible(hObj);
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                            end

                                                                                                                                                                                                                                                            if isvalid(hObj.SelectionHandle)
                                                                                                                                                                                                                                                                if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                                                                                                                                                                                                                                                                    hObj.SelectionHandle.Visible='on';
                                                                                                                                                                                                                                                                else
                                                                                                                                                                                                                                                                    hObj.SelectionHandle.Visible='off';
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                            end



                                                                                                                                                                                                                                                            fig=ancestor(hObj,'Figure');
                                                                                                                                                                                                                                                            parent=hObj.Parent;
                                                                                                                                                                                                                                                            peerAxes=hObj.Axes;
                                                                                                                                                                                                                                                            pc=hObj.PositionCache;
                                                                                                                                                                                                                                                            posToCacheNorm=hgconvertunits(fig,hObj.Position_I,hObj.Units,'normalized',parent);
                                                                                                                                                                                                                                                            posToCachePoints=hgconvertunits(fig,hObj.Position_I,hObj.Units,'points',parent);
                                                                                                                                                                                                                                                            updateCache=false;

                                                                                                                                                                                                                                                            switch hObj.Location
                                                                                                                                                                                                                                                            case 'best'
                                                                                                                                                                                                                                                                currPosPoints=hgconvertunits(fig,hObj.Position_I,hObj.Units,'points',parent);
                                                                                                                                                                                                                                                                currSizePoints=currPosPoints(3:4);
                                                                                                                                                                                                                                                                minSizePoints=doMethod(hObj,'getsize',updateState);




                                                                                                                                                                                                                                                                sizeDiffPoints=abs(currSizePoints-minSizePoints);
                                                                                                                                                                                                                                                                recalculateBest=false;
                                                                                                                                                                                                                                                                currPeerPosPoints=hgconvertunits(fig,peerAxes.InnerPosition_I,peerAxes.Units,'points',peerAxes.Parent);

                                                                                                                                                                                                                                                                if any(sizeDiffPoints>1)
                                                                                                                                                                                                                                                                    recalculateBest=true;
                                                                                                                                                                                                                                                                elseif any(sizeDiffPoints>0)

                                                                                                                                                                                                                                                                    currSizePoints=minSizePoints;
                                                                                                                                                                                                                                                                    newPosPoints=[currPosPoints(1:2),currSizePoints];
                                                                                                                                                                                                                                                                    hObj.setLayoutPosition(hgconvertunits(fig,newPosPoints,'points',hObj.Units,parent));

                                                                                                                                                                                                                                                                    posToCacheNorm=hgconvertunits(fig,newPosPoints,'points','normalized',parent);
                                                                                                                                                                                                                                                                    posToCachePoints=newPosPoints;
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                userSetLocation=strcmp(hObj.LocationMode,'manual');


                                                                                                                                                                                                                                                                cachedPeerPosPoints=pc.PeerPositionCachePoints;
                                                                                                                                                                                                                                                                peerPosPointsChanged=~isequal(currPeerPosPoints,cachedPeerPosPoints);
                                                                                                                                                                                                                                                                cachedPeerPosNorm=pc.PeerPositionCacheNorm;
                                                                                                                                                                                                                                                                currPeerPosNorm=hgconvertunits(fig,peerAxes.InnerPosition_I,peerAxes.Units,'normalized',peerAxes.Parent);
                                                                                                                                                                                                                                                                peerPosNormChanged=~isequal(currPeerPosNorm,cachedPeerPosNorm);
                                                                                                                                                                                                                                                                orientationChanged=~strcmp(pc.OrientationCache,hObj.Orientation_I);

                                                                                                                                                                                                                                                                if userSetLocation||recalculateBest

                                                                                                                                                                                                                                                                    newPosPoints=doMethod(hObj,'get_best_location',minSizePoints);
                                                                                                                                                                                                                                                                    hObj.setLayoutPosition(hgconvertunits(fig,newPosPoints,'points',hObj.Units,parent));
                                                                                                                                                                                                                                                                    hObj.LocationMode='auto';



                                                                                                                                                                                                                                                                    currPosPoints=newPosPoints;
                                                                                                                                                                                                                                                                    currCenterPoints=[currPosPoints(1)+currPosPoints(3)/2,currPosPoints(2)+currPosPoints(4)/2];
                                                                                                                                                                                                                                                                    currPeerOrigPoints=currPeerPosPoints(1:2);
                                                                                                                                                                                                                                                                    newPinNorm=(currCenterPoints-currPeerOrigPoints)./currPeerPosPoints(3:4);
                                                                                                                                                                                                                                                                    pc.PinToPeerCacheNorm=newPinNorm;

                                                                                                                                                                                                                                                                    posToCacheNorm=hgconvertunits(fig,newPosPoints,'points','normalized',parent);
                                                                                                                                                                                                                                                                    posToCachePoints=newPosPoints;
                                                                                                                                                                                                                                                                elseif peerPosPointsChanged||peerPosNormChanged||orientationChanged







                                                                                                                                                                                                                                                                    currPeerOrigPoints=currPeerPosPoints(1:2);
                                                                                                                                                                                                                                                                    currPeerSizePoints=currPeerPosPoints(3:4);
                                                                                                                                                                                                                                                                    newOffsetFromPeerPoints=currPeerSizePoints.*pc.PinToPeerCacheNorm;
                                                                                                                                                                                                                                                                    newCenterPoints=currPeerOrigPoints+newOffsetFromPeerPoints;
                                                                                                                                                                                                                                                                    newPosPoints=[newCenterPoints-currSizePoints./2,currSizePoints];
                                                                                                                                                                                                                                                                    newPos=hgconvertunits(fig,newPosPoints,'points',hObj.Units,parent);
                                                                                                                                                                                                                                                                    hObj.setLayoutPosition(newPos);

                                                                                                                                                                                                                                                                    posToCacheNorm=hgconvertunits(fig,newPosPoints,'points','normalized',parent);
                                                                                                                                                                                                                                                                    posToCachePoints=newPosPoints;
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                updateCache=true;

                                                                                                                                                                                                                                                            case 'none'





                                                                                                                                                                                                                                                                if~isempty(hObj.SPosition)
                                                                                                                                                                                                                                                                    setLayoutPosition(hObj,hObj.SPosition);
                                                                                                                                                                                                                                                                    hObj.SPosition=[];
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                cachedParPosPoints=pc.ParentPositionCachePoints;
                                                                                                                                                                                                                                                                currParPosPoints=hgconvertunits(fig,parent.Position_I,parent.Units,'points',parent.Parent);
                                                                                                                                                                                                                                                                parentResize=~isequal(currParPosPoints,cachedParPosPoints);
                                                                                                                                                                                                                                                                hasNormUnits=strcmp(hObj.Units,'normalized');
                                                                                                                                                                                                                                                                posNormUnchanged=isequal(hObj.Position_I,pc.PositionCacheNormalized);
                                                                                                                                                                                                                                                                if parentResize&&hasNormUnits&&posNormUnchanged

                                                                                                                                                                                                                                                                    currPosPoints=hgconvertunits(fig,hObj.Position_I,'normalized','points',parent);
                                                                                                                                                                                                                                                                    currSizePoints=currPosPoints(3:4);
                                                                                                                                                                                                                                                                    cachedPosPoints=pc.PositionCachePoints;
                                                                                                                                                                                                                                                                    cachedSizePoints=cachedPosPoints(3:4);
                                                                                                                                                                                                                                                                    if~isequal(currSizePoints,cachedSizePoints)

                                                                                                                                                                                                                                                                        centerPoints=currPosPoints(1:2)+currPosPoints(3:4)/2;
                                                                                                                                                                                                                                                                        newPosPoints=[(centerPoints-cachedSizePoints/2),cachedSizePoints];
                                                                                                                                                                                                                                                                        newPosNorm=hgconvertunits(fig,newPosPoints,'points','normalized',parent);
                                                                                                                                                                                                                                                                        hObj.setLayoutPosition(newPosNorm);

                                                                                                                                                                                                                                                                        posToCacheNorm=newPosNorm;
                                                                                                                                                                                                                                                                        posToCachePoints=newPosPoints;
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                currPosPoints=hgconvertunits(fig,hObj.Position_I,hObj.Units,'points',parent);
                                                                                                                                                                                                                                                                currSizePoints=currPosPoints(3:4);
                                                                                                                                                                                                                                                                minSizePoints=doMethod(hObj,'getsize',updateState);

                                                                                                                                                                                                                                                                newPosPoints=currPosPoints;

                                                                                                                                                                                                                                                                if any(minSizePoints-currSizePoints>.1)
                                                                                                                                                                                                                                                                    centerPoints=currPosPoints(1:2)+currPosPoints(3:4)/2;
                                                                                                                                                                                                                                                                    if currSizePoints(1)+.1<minSizePoints(1)
                                                                                                                                                                                                                                                                        newPosPoints(1)=centerPoints(1)-minSizePoints(1)/2;
                                                                                                                                                                                                                                                                        newPosPoints(3)=minSizePoints(1);
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if currSizePoints(2)+.1<minSizePoints(2)
                                                                                                                                                                                                                                                                        newPosPoints(2)=centerPoints(2)-minSizePoints(2)/2;
                                                                                                                                                                                                                                                                        newPosPoints(4)=minSizePoints(2);
                                                                                                                                                                                                                                                                    end

                                                                                                                                                                                                                                                                    newPos=hgconvertunits(fig,newPosPoints,'points',hObj.Units,parent);
                                                                                                                                                                                                                                                                    hObj.setLayoutPosition(newPos);

                                                                                                                                                                                                                                                                    posToCacheNorm=hgconvertunits(fig,newPosPoints,'points','normalized',parent);
                                                                                                                                                                                                                                                                    posToCachePoints=newPosPoints;
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                updateCache=true;

                                                                                                                                                                                                                                                            otherwise




                                                                                                                                                                                                                                                                hObj.SPosition=[];
                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                            if updateCache
                                                                                                                                                                                                                                                                pc.PositionCacheNormalized=posToCacheNorm;
                                                                                                                                                                                                                                                                pc.PositionCachePoints=posToCachePoints;
                                                                                                                                                                                                                                                                pc.ParentPositionCachePoints=hgconvertunits(fig,parent.Position_I,parent.Units,'points',parent.Parent);
                                                                                                                                                                                                                                                                pc.PeerPositionCachePoints=hgconvertunits(fig,peerAxes.InnerPosition_I,peerAxes.Units,'points',peerAxes.Parent);
                                                                                                                                                                                                                                                                pc.PeerPositionCacheNorm=hgconvertunits(fig,peerAxes.InnerPosition_I,peerAxes.Units,'normalized',peerAxes.Parent);
                                                                                                                                                                                                                                                                pc.OrientationCache=hObj.Orientation_I;
                                                                                                                                                                                                                                                                hObj.PositionCache=pc;
                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                            if~isempty(fig)&&~isempty(hObj.UIContextMenu)
                                                                                                                                                                                                                                                                hObj.UIContextMenu.Parent=fig;
                                                                                                                                                                                                                                                            end


                                                                                                                                                                                                                                                            matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);


                                                                                                                                                                                                                                                            function doUpdateStandalone(hObj,updateState)
















                                                                                                                                                                                                                                                                updateTitleProperties(hObj);


                                                                                                                                                                                                                                                                if~isempty(hObj.PlotChildren_I)&&any(isvalid(hObj.PlotChildren_I))

                                                                                                                                                                                                                                                                    if isempty(hObj.EntryContainer.Children)
                                                                                                                                                                                                                                                                        doMethod(hObj,'createEntries',updateState);
                                                                                                                                                                                                                                                                    else


                                                                                                                                                                                                                                                                        doMethod(hObj,'syncEntries')
                                                                                                                                                                                                                                                                    end


                                                                                                                                                                                                                                                                    doMethod(hObj,'pushLegendPropsToLabels');
                                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                                doMethod(hObj,'layoutEntries',updateState);


                                                                                                                                                                                                                                                                parts=findall(hObj);
                                                                                                                                                                                                                                                                set(hObj,'HandleVisibility','off');
                                                                                                                                                                                                                                                                set(hObj,'Internal',true);
                                                                                                                                                                                                                                                                set(parts,'HandleVisibility','off');
                                                                                                                                                                                                                                                                set(parts,'Internal',true);
                                                                                                                                                                                                                                                                set(parts,'PickableParts','none');


                                                                                                                                                                                                                                                                delete(hObj.UIContextMenu);
                                                                                                                                                                                                                                                                hObj.ButtonDownFcn='';


                                                                                                                                                                                                                                                                matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);



