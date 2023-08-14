function varargout=doMethod(hObj,fcn,varargin)




    args={fcn,hObj,varargin{:}};%#ok<CCAT>
    if nargout==0
        feval(args{:});
    else
        [varargout{1:nargout}]=feval(args{:});
    end



    function handled=bup(h,~)

        handled=true;


        b=hggetbehavior(h,'Plotedit');
        b.ButtonUpFcn=[];
        b.MouseMotionFcn=[];



        function handled=bdown(h)%#ok<DEFNU>

            handled=false;
            fig=ancestor(h,'figure');
            if strcmpi(h.Editing,'on')


                hMode=plotedit(fig,'getmode');
                hPlotSelect=hMode.ModeStateData.PlotSelectMode;
                if strcmpi(hPlotSelect.ModeStateData.NonScribeMoveMode,'none');

                    b=hggetbehavior(double(h),'Plotedit');
                    b.ButtonUpFcn=@bup;
                    b.MouseMotionFcn=@move_colormap;

                    h.ColormapMoveInitialMap=colormap(h.Axes);
                    handled=true;
                end
            end
            if get(fig,'CurrentAxes')==h
                set(fig,'CurrentAxes',h.Axes);
            end


            function res=localPointOnBorder(obj,point)



                res=false;


                hAncestor=handle(get(obj,'Parent'));
                hFig=ancestor(obj,'Figure');
                if~isa(hAncestor,'matlab.ui.Figure')&&~isa(hAncestor,'matlab.ui.container.Panel')
                    hAncestor=hFig;
                end

                point=hgconvertunits(hFig,[point,0,0],'Normalized','Pixels',hFig);

                objPos=hgconvertunits(hFig,obj.Position_I,get(obj,'Units'),'Pixels',hAncestor);
                if~isa(hAncestor,'matlab.ui.Figure')
                    ancPos=hgconvertunits(hFig,get(hAncestor,'Position'),get(hAncestor,'Units'),'Pixels',hFig);
                else
                    ancPos=[0,0,0,0];
                end
                objPos(1:2)=objPos(1:2)+ancPos(1:2);


                XL=objPos(1);
                XR=objPos(1)+objPos(3);
                YU=objPos(2)+objPos(4);
                YL=objPos(2);


                px=point(1);
                py=point(2);

                a2=4;


                if(any(abs([XL,XR]-px)<=a2)&&YL<=py&&py<=YU)||...
                    (any(abs([YL,YU]-py)<=a2)&&XL<=px&&px<=XR)
                    res=true;
                end





                function over=mouseover(h,evd)%#ok<DEFNU>




                    over=0;
                    fig=ancestor(h,'figure');
                    point=evd.Point;


                    cbpos=hgconvertunits(fig,h.Position_I,h.Units,fig.Units,fig);
                    inrect=point(1)>cbpos(1)&&point(1)<cbpos(1)+cbpos(3)&&...
                    point(2)>cbpos(2)&&point(2)<cbpos(2)+cbpos(4);

                    if true
                        if strcmpi(h.Editing,'on')

                            if inrect>0&&~localPointOnBorder(h,point)
                                orient=h.Orientation;
                                switch orient(1:3);
                                case 'ver'
                                    over='heditbar';
                                case 'hor'
                                    over='veditbar';
                                otherwise

                                end
                                hMode=plotedit(fig,'getmode');
                                hPlotSelect=hMode.ModeStateData.PlotSelectMode;
                                hPlotSelect.ModeStateData.NonScribeMoveMode='none';
                            end
                        end
                    end



                    function handled=move_colormap(h,evd)

                        handled=true;
                        fig=ancestor(h,'figure');
                        map0=h.ColormapMoveInitialMap;
                        mapsiz=size(map0,1);
                        pt0=h.NClickPoint;
                        pt=hgconvertunits(fig,[evd.Point,0,0],fig.Units,'normalized',fig);
                        cbpos=h.Position;
                        cbloc=lower(h.Location);
                        switch cbloc
                        case{'east','west','eastoutside','westoutside'}
                            mapindstart=ceil(mapsiz*(pt0(2)-cbpos(2))/cbpos(4));
                            mapindsmove=ceil(mapsiz*(pt(2)-pt0(2))/cbpos(4));
                        case 'manual'
                            if cbpos(3)>cbpos(4)
                                mapindstart=ceil(mapsiz*(pt0(1)-cbpos(1))/cbpos(3));
                                mapindsmove=ceil(mapsiz*(pt(1)-pt0(1))/cbpos(3));

                            else
                                mapindstart=ceil(mapsiz*(pt0(2)-cbpos(2))/cbpos(4));
                                mapindsmove=ceil(mapsiz*(pt(2)-pt0(2))/cbpos(4));
                            end

                        otherwise
                            mapindstart=ceil(mapsiz*(pt0(1)-cbpos(1))/cbpos(3));
                            mapindsmove=ceil(mapsiz*(pt(1)-pt0(1))/cbpos(3));
                        end


                        newmap=map0;

                        if mapindsmove>0
                            stretchind=mapindstart+mapindsmove;
                            stretchind=min(stretchind,mapsiz);
                            mapindstart=max(1,mapindstart);
                            stretchfx=stretchind/mapindstart;
                            ixinc=1/stretchfx;
                            ix=1;
                            for k=1:stretchind
                                ia=max(1,min(mapsiz,floor(ix)));
                                if ia<mapsiz
                                    ib=ia+1;
                                    ifrx=ix-ia;
                                    newmap(k,:)=map0(ia,:)+ifrx*(map0(ib,:)-map0(ia,:));
                                else
                                    newmap(k,:)=map0(ia,:);
                                end
                                ix=ix+ixinc;
                            end

                            squeezefx=max(1,(mapsiz-stretchind))/(mapsiz-mapindstart);
                            ixinc=1/squeezefx;
                            ix=mapindstart;
                            for k=stretchind:mapsiz
                                ia=max(1,min(mapsiz,floor(ix)));
                                if ia<mapsiz
                                    ib=ia+1;
                                    ifrx=ix-ia;
                                    newmap(k,:)=map0(ia,:)+ifrx*(map0(ib,:)-map0(ia,:));
                                else
                                    newmap(k,:)=map0(ia,:);
                                end
                                ix=ix+ixinc;
                            end
                        else
                            stretchind=mapindstart+mapindsmove;
                            stretchind=max(stretchind,1);
                            mapindstart=max(1,mapindstart);
                            stretchfx=stretchind/mapindstart;
                            ixinc=1/stretchfx;
                            ix=1;
                            for k=1:stretchind
                                ia=max(1,min(mapsiz,floor(ix)));
                                if ia<mapsiz
                                    ib=ia+1;
                                    ifrx=ix-ia;
                                    newmap(k,:)=map0(ia,:)+ifrx*(map0(ib,:)-map0(ia,:));
                                else
                                    newmap(k,:)=map0(ia,:);
                                end
                                ix=ix+ixinc;
                            end
                            squeezefx=(mapsiz-stretchind)/(mapsiz-mapindstart);
                            ixinc=1/squeezefx;
                            ix=mapindstart;
                            for k=stretchind:mapsiz
                                ia=max(1,min(mapsiz,floor(ix)));
                                if ia<mapsiz
                                    ib=ia+1;
                                    ifrx=ix-ia;
                                    newmap(k,:)=map0(ia,:)+ifrx*(map0(ib,:)-map0(ia,:));
                                else
                                    newmap(k,:)=map0(ia,:);
                                end
                                ix=ix+ixinc;
                            end
                        end


                        colormap(h.Axes,newmap);








                        function repairContextMenu(h,cm,fig)%#ok<DEFNU>



                            if~isempty(cm)
                                eo=findall(cm,'Tag','scribe:colorbar:location:eastoutside');
                                if~isempty(eo)



                                    delete(cm);

                                    createDefaultContextMenu(h,fig);
                                end
                            end








                            function createDefaultContextMenu(h,varargin)

                                if~isempty(varargin)

                                    fig=varargin{1};
                                else

                                    fig=matlab.ui.Figure.empty;
                                end

                                uic=uicontextmenu('Parent',fig,...
                                'HandleVisibility','off',...
                                'Serializable','off',...
                                'Tag','defaultContextMenu');

                                addlistener(h,'ObjectBeingDestroyed',@(h,e)delete(uic));
                                setappdata(uic,'CallbackObject',h);


                                uic.Callback={@defaultContextMenuCB,h};




                                lis(1)=event.proplistener(h,findprop(h,'UIContextMenu'),'PreGet',@(src,ed)defaultContextMenuCB(uic,ed,h));
                                lis(2)=event.proplistener(h,findprop(h,'ContextMenu'),'PreGet',@(src,ed)defaultContextMenuCB(uic,ed,h));
                                setappdata(uic,'PreGetListener',lis);

                                h.UIContextMenu=uic;








                                function defaultContextMenuCB(uic,~,h)





                                    uicBelongsToColorbar=~isempty(h.UIContextMenu)&&h.UIContextMenu==uic;
                                    alreadyHasSubmenus=~isempty(hgGetTrueChildren(uic));
                                    updatingColorbar=isappdata(h,'inUpdate')&&getappdata(h,'inUpdate');

                                    if alreadyHasSubmenus
                                        update_contextmenu(h,'on');
                                    end

                                    if~uicBelongsToColorbar||alreadyHasSubmenus||updatingColorbar
                                        return
                                    end


                                    hMenu=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,'GeneralAction',getString(message('MATLAB:uistring:scribemenu:Delete')),'','',{@delete_self_cb,h});
                                    set(hMenu,'Tag','scribe:colorbar:delete');


                                    locationEnums={...
                                    'EastOutside';...
                                    'WestOutside';...
                                    'NorthOutside';...
                                    'SouthOutside';...
                                    'East';...
                                    'West';...
                                    };
                                    locationTags=strcat('scribe:colorbar:location:',lower(locationEnums));
                                    locationMessageKeys=strcat('MATLAB:uistring:scribemenu:',locationEnums);
                                    locationStrings=cellfun(@(x)getString(message(x)),locationMessageKeys,'UniformOutput',false);

                                    hMenu(end+1)=matlab.graphics.annotation.internal.createScribeUIMenuEntry(uic,uic,...
                                    'EnumEntry',getString(message('MATLAB:uistring:scribemenu:Location')),...
                                    'Location',getString(message('MATLAB:uistring:scribemenu:Location')),...
                                    locationStrings,locationEnums);
                                    set(hMenu(end),'Tag','scribe:colorbar:location');
                                    set(hMenu(end),'Separator','on');

                                    set(hMenu,'Parent',uic);
                                    set(findall(hMenu),'Visible','on');
                                    hChil=findall(hMenu(end));
                                    hChil=flipud(hChil(2:end));
                                    set(hChil,{'Tag'},locationTags);


                                    maplabels=cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:',x])),{'Cool','Gray','Hot','HSV','Jet','Turbo','ParulaDefault'},'UniformOutput',false);
                                    mapfunctions={'cool','gray','hot','hsv','jet','turbo','parula'};
                                    maptags=cellfun(@(x)(['scribe:colorbar:colormap:',x]),mapfunctions,'UniformOutput',false);
                                    stdmaps=uimenu(uic,'HandleVisibility','off','Label',getString(message('MATLAB:uistring:scribemenu:StandardColormaps')),...
                                    'Separator','on','Tag','scribe:colorbar:colormap');
                                    for k=1:length(maplabels)
                                        uimenu(stdmaps,'HandleVisibility','off','Label',maplabels{k},...
                                        'Callback',{@set_standard_colormap_cb,h,mapfunctions{k}},...
                                        'Tag',maptags{k});
                                    end

                                    hMenu=uimenu(uic,'HandleVisibility','off','Label',getString(message('MATLAB:uistring:scribemenu:InteractiveColormapShift')),...
                                    'Separator','off','Callback',{@toggle_editmode_cb,h});
                                    set(hMenu,'Tag','scribe:colorbar:interactivecolormapshift');


                                    hMenu=uimenu(uic,'HandleVisibility','off','Label',getString(message('MATLAB:uistring:scribemenu:OpenColormapEditor')),...
                                    'Separator','off','Callback',@edit_colormap_cb);
                                    set(hMenu,'Tag','scribe:colorbar:editcolormap');

                                    if strcmpi(get(uic.Parent,'HandleVisibility'),'off')
                                        set(hMenu,'Enable','off');
                                    end

                                    hMenu=uimenu(uic,'HandleVisibility','off','Separator','on',...
                                    'Label',getString(message('MATLAB:uistring:scribemenu:OpenPropertyInspector')),'Callback',{@localOpenPropertyEditor,h});
                                    set(hMenu,'Tag','scribe:colorbar:propedit');



                                    fig=uic.Parent;
                                    if isscalar(fig)&&isgraphics(fig,'figure')&&~isWebFigureType(fig,'UIFigure')
                                        hMenu=uimenu(uic,'HandleVisibility','off','Separator','on',...
                                        'Label',getString(message('MATLAB:uistring:scribemenu:ShowCode')),'Callback',{@localGenerateMCode,h});
                                        set(hMenu,'Tag','scribe:colorbar:mcode');
                                    end

                                    function toggle_editmode_cb(hSrc,evdata,h)%#ok<INUSL>

                                        toggle_editmode(h);


                                        function toggle_editmode(h)

                                            cbarax=h;
                                            fig=ancestor(h,'figure');
                                            uic=get(cbarax,'UIContextMenu');
                                            if~isempty(uic)
                                                emodemenu=findall(uic,'type','UIMenu','Tag','scribe:colorbar:interactivecolormapshift');
                                                if~isempty(emodemenu)
                                                    state=get(emodemenu,'checked');
                                                    if strcmpi(state,'off')
                                                        set(emodemenu,'checked','on');
                                                        plotedit(fig,'on');
                                                        h.Editing='on';
                                                        set(cbarax,'linewidth',1);
                                                        selectobject(h,'replace');
                                                    else
                                                        set(emodemenu,'checked','off');
                                                        h.Editing='off';
                                                        plotedit(fig,'off');
                                                        set(cbarax,'linewidth',.5);
                                                    end
                                                end
                                            end

                                            function edit_colormap_cb(es,~)



                                                obj=ancestor(es,'figure');
                                                ctxMenu=es.Parent;
                                                colrBar=getappdata(ctxMenu,'CallbackObject');
                                                colrBarAx=colrBar.Axes;
                                                if ishghandle(colrBarAx)
                                                    obj=colrBarAx;
                                                end

                                                colormapeditor(obj);

                                                function set_standard_colormap_cb(hSrc,evdata,h,name)%#ok<INUSL>

                                                    set_standard_colormap(h,name);

                                                    function set_standard_colormap(h,name)

                                                        fig=ancestor(h,'figure');
                                                        map=get(fig,'Colormap');
                                                        mapsiz=size(map);
                                                        map=feval(name,mapsiz(1));
                                                        h.BaseColormap=map;

                                                        colormap(h.Axes,map);

                                                        function localOpenPropertyEditor(obj,evd,hLeg)%#ok<INUSL>

                                                            matlab.graphics.internal.propertyinspector.propertyinspector('show',hLeg);


                                                            function localGenerateMCode(obj,evd,hLeg)%#ok<INUSL>

                                                                makemcode(hLeg,'Output','-editor')

                                                                function update_contextmenu_cb(~,~,varargin)

                                                                    update_contextmenu(varargin{:})

                                                                    function update_contextmenu(h,~)

                                                                        mapnames={'cool','gray','hot','hsv','jet','turbo','parula'};
                                                                        uic=get(h,'UIContextMenu');
                                                                        if~isempty(uic)

                                                                            m=findall(uic,'Type','uimenu','Tag','scribe:colorbar:colormap');
                                                                            if~isempty(m)
                                                                                mitems=allchild(m);
                                                                                if~isempty(mitems)
                                                                                    set(mitems,'Checked','off');

                                                                                    if~isempty(h.Axes)




                                                                                        cmap=colormap(h.Axes);
                                                                                        maplength=length(cmap);
                                                                                        k=1;found=false;
                                                                                        while k<=length(mapnames)&&~found


                                                                                            tmap=feval(mapnames{k},maplength);
                                                                                            if isequal(cmap,tmap)

                                                                                                found=true;
                                                                                                mitem=findall(m,'Tag',['scribe:colorbar:colormap:',mapnames{k}]);
                                                                                                set(mitem,'Checked','on');
                                                                                            end
                                                                                            k=k+1;
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end



                                                                            hMenu=findall(uic,'Type','uimenu','Tag','scribe:colorbar:editcolormap');
                                                                            if~hMenu.Enable&&strcmpi(get(uic.Parent,'HandleVisibility'),'on')
                                                                                set(hMenu,'Enable','on');
                                                                            end
                                                                        end


                                                                        function delete_self_cb(~,~,h)


                                                                            hFig=ancestor(h,'figure');
                                                                            hAx=h.Axes;
                                                                            if isactiveuimode(hFig,'Standard.EditPlot')
                                                                                scribeccp(hFig,'delete');
                                                                            else
                                                                                delete(h);
                                                                            end
                                                                            matlab.graphics.interaction.generateLiveCode(hAx,matlab.internal.editor.figure.ActionID.COLORBAR_REMOVED);


                                                                            function localChangeLocationCallback(src,ed,h,hFig,value)



                                                                                if isactiveuimode(hFig,'Standard.EditPlot')
                                                                                    currLoc=get(h,'Location');
                                                                                    if~strcmpi(currLoc,value)
                                                                                        proxyVal=plotedit({'getProxyValueFromHandle',h});
                                                                                        currPos=[];
                                                                                        currOr=[];
                                                                                        if strcmpi(currLoc,'manual')
                                                                                            currPos=get(h,'Position');
                                                                                            currOr=get(h,'Orientation');
                                                                                        end
                                                                                        cmd.Name='Change Location';
                                                                                        cmd.Function=@localChangeLocation;
                                                                                        cmd.Varargin={proxyVal,hFig,value,[],[],[],[]};
                                                                                        cmd.InverseFunction=@localChangeLocation;
                                                                                        cmd.InverseVarargin={proxyVal,hFig,currLoc,currPos,currOr};
                                                                                        uiundo(hFig,'function',cmd);
                                                                                    end
                                                                                end

                                                                                set(h,'Location',value);

                                                                                function localChangeLocation(proxyVal,hFig,locVal,posVal,orientation,xAxisLoc,yAxisLoc)

                                                                                    h=plotedit({'getHandleFromProxyValue',hFig,proxyVal});
                                                                                    set(h,'Location',locVal);

                                                                                    if strcmpi(locVal,'manual')
                                                                                        set(h,'Position',posVal);
                                                                                        set(h,'Orientation',orientation);
                                                                                    end
