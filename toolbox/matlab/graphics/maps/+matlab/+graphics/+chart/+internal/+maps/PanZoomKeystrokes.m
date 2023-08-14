classdef PanZoomKeystrokes<matlab.graphics.interaction.uiaxes.InteractionBase








    properties(SetAccess=private)
Chart
StepsPerZoomLevel
KeyPressListener
KeyPressManager
    end


    methods
        function obj=PanZoomKeystrokes(ax,fig)
            obj.Axes=ax;
            ch=ancestor(obj.Axes,'matlab.graphics.chart.GeographicChart');
            if isempty(ch)
                obj.Chart=ax;
            else
                obj.Chart=ch;
            end
            obj.StepsPerZoomLevel=ax.StepsPerZoomLevelKeystrokes;
            obj.Figure=fig;
        end


        function enable(obj)
            fig=obj.Figure;
            if~isempty(fig)&&isvalid(fig)
                obj.KeyPressListener=event.listener(fig,'KeyPress',...
                @(source,eventData)keyPressFcn(obj,source,eventData));


                keys={'equal','add','hyphen','subtract',...
                'leftarrow','rightarrow','uparrow','downarrow'};
                obj.KeyPressManager=...
                matlab.graphics.interaction.internal.FigureKeyPressManager.registerObject(...
                obj.Chart,keys);
            end
        end


        function delete(obj)

            ch=obj.Chart;
            manager=obj.KeyPressManager;
            if isscalar(manager)&&isvalid(manager)
                matlab.graphics.interaction.internal.FigureKeyPressManager.unregisterObject(ch,manager);
            end
        end


        function keyPressFcn(obj,~,eventData)
            if isactiveuimode(obj.Figure,'Standard.EditPlot')
                return
            end
            ch=obj.Chart;
            ax=obj.Axes;
            if chartIsCurentAxes(obj)&&~isempty(ax)&&isvalid(ax)
                latlim=ax.LatitudeLimits;
                lonlim=ax.LongitudeLimits;
                switch eventData.Key
                case{'equal','add'}

                    zoomIn(ch,obj.StepsPerZoomLevel)
                    addToUndoStack(obj,'Zoom',latlim,lonlim)
                case{'hyphen','subtract'}
                    zoomOut(ch,obj.StepsPerZoomLevel)
                    addToUndoStack(obj,'Zoom',latlim,lonlim)
                case 'leftarrow'
                    pan(ch,"west")
                    addToUndoStack(obj,'Pan',latlim,lonlim)
                case 'rightarrow'
                    pan(ch,"east")
                    addToUndoStack(obj,'Pan',latlim,lonlim)
                case 'uparrow'
                    pan(ch,"north")
                    addToUndoStack(obj,'Pan',latlim,lonlim)
                case 'downarrow'
                    pan(ch,"south")
                    addToUndoStack(obj,'Pan',latlim,lonlim)
                end
                matlab.graphics.interaction.generateLiveCode(ax,...
                matlab.internal.editor.figure.ActionID.PANZOOM);
            end
        end


        function tf=chartIsCurentAxes(obj)
            ch=obj.Chart;
            fig=obj.Figure;
            if~isempty(ch)&&~isempty(fig)&&isvalid(ch)&&isvalid(fig)
                tf=any(fig.CurrentAxes==ch);
            else
                tf=false;
            end
        end


        function addToUndoStack(obj,name,latlim,lonlim)
            if isempty(latlim)||isempty(lonlim)
                return
            end


            cmd.Name=name;


            gx=obj.Axes;
            gxProxy=plotedit({'getProxyValueFromHandle',gx});


            fig=obj.Figure;
            cmd.Function=@changeLimits;
            cmd.Varargin={obj,fig,gxProxy,gx.LatitudeLimits,gx.LongitudeLimits};


            cmd.InverseFunction=@changeLimits;
            cmd.InverseVarargin={obj,fig,gxProxy,latlim,lonlim};



            uiundo(fig,'function',cmd)
        end


        function changeLimits(~,fig,gxProxy,latlim,lonlim)
            gx=plotedit({'getHandleFromProxyValue',fig,gxProxy});

            if(~ishghandle(gx))
                return
            end

            gx.LatitudeLimitsRequest=latlim;
            gx.LongitudeLimitsRequest=lonlim;
        end
    end
end


function noOperationCallback(~,~)%#ok<DEFNU>



end
