classdef ColorbarDragInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase

    properties
InitialColormap
InitialCMapName
ColorEditorApp
CurrentFigure
    end

    properties(Constant)
        CUSTOM_COLORMAP=getString(message('MATLAB:datamanager:colormapeditor:CustomColormap'))
    end

    methods
        function this=ColorbarDragInteraction(hColorbar,app)
            this.Type='colormapshift';
            this.Object=hColorbar;
            this.ColorEditorApp=app;
            this.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function startdata=dragstart(this,eventData)
            this.CurrentFigure=ancestor(this.Object,'figure');
            this.InitialColormap=colormap(this.Object.Axes);
            this.InitialCMapName=this.ColorEditorApp.getCurrentColorMapName();
            startdata=hgconvertunits(this.CurrentFigure,[eventData.x,eventData.y,0,0],this.CurrentFigure.Units,'normalized',this.CurrentFigure);
        end

        function dragprogress(this,eventData,startData)

            this.shiftColormap(eventData,startData);
        end

        function dragend(this,~,~)

            this.ColorEditorApp.addUndoRedoUpdateColormap(this.InitialCMapName,this.InitialColormap,this.CUSTOM_COLORMAP,this.ColorEditorApp.getColormap());
        end
    end

    methods(Access=private)


        function shiftColormap(this,eventData,startData)
            hColorbar=this.Object;
            fig=ancestor(hColorbar,'figure');
            map0=this.InitialColormap;
            mapsiz=length(map0);
            pt=hgconvertunits(fig,[eventData.x,eventData.y,0,0],fig.Units,'normalized',fig);
            cbpos=hgconvertunits(fig,hColorbar.Position,fig.Units,'normalized',fig);
            cbloc=lower(hColorbar.Location);
            switch cbloc
            case{'east','west','eastoutside','westoutside'}
                mapindstart=ceil(mapsiz*(startData(2)-cbpos(2))/cbpos(4));
                mapindsmove=ceil(mapsiz*(pt(2)-startData(2))/cbpos(4));
            case 'manual'
                if cbpos(3)>cbpos(4)
                    mapindstart=ceil(mapsiz*(startData(1)-cbpos(1))/cbpos(3));
                    mapindsmove=ceil(mapsiz*(pt(1)-startData(1))/cbpos(3));

                else
                    mapindstart=ceil(mapsiz*(startData(2)-cbpos(2))/cbpos(4));
                    mapindsmove=ceil(mapsiz*(pt(2)-startData(2))/cbpos(4));
                end

            otherwise
                mapindstart=ceil(mapsiz*(startData(1)-cbpos(1))/cbpos(3));
                mapindsmove=ceil(mapsiz*(pt(1)-startData(1))/cbpos(3));
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
            this.ColorEditorApp.updateUIOnDrag(this.CUSTOM_COLORMAP,newmap);
        end
    end
end