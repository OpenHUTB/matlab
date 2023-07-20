

classdef ToolstripSubscriber<handle


    properties
        subscriptionMap;
actionSubscriptionMap
        currentFigureMap;
    end
    properties(Constant)


        ATOMIC_ACTIONS=["cleargrid","clearlegend","clearcolorbar"];


        SPRING_LOADED_ACTIONS=["title","xlabel","ylabel","line","arrow","textarrow","doublearrow"];
    end

    methods(Static)
        function h=getInstance
            import matlab.internal.editor.figure.*
mlock
            persistent sInstance;
            if isempty(sInstance)||~isvalid(sInstance)
                sInstance=ToolstripSubscriber;
            end
            h=sInstance;
        end
    end

    methods
        function this=ToolstripSubscriber

            this.currentFigureMap=containers.Map;
            this.actionSubscriptionMap=containers.Map;
            this.subscriptionMap=containers.Map;
        end

        function subscribe(this,editorId)
            import matlab.internal.editor.figure.*




            if~this.subscriptionMap.isKey(editorId)
                this.subscriptionMap(editorId)=message.subscribe(['/toolstrip/toolstriptabevent/',editorId],...
                @(msgData)this.callback(editorId,msgData),'enableDebugger',false);
            end




            if~this.actionSubscriptionMap.isKey(editorId)
                this.actionSubscriptionMap(editorId)=message.subscribe(['/toolstrip/toolstripactionevent/',editorId],...
                @(msgData)ToolstripSubscriber.actionCallback(editorId,msgData),'enableDebugger',false);
            end
        end

        function unsubscribe(this,editorId)
            if this.subscriptionMap.isKey(editorId)
                message.unsubscribe(this.subscriptionMap(editorId));
                remove(this.subscriptionMap,editorId);
            end
            if this.actionSubscriptionMap.isKey(editorId)
                message.unsubscribe(this.actionSubscriptionMap(editorId));
                remove(this.actionSubscriptionMap,editorId);
            end
        end

        function callback(this,editorId,msgData)


            this.currentFigureMap(editorId)=msgData;
        end

        function figProxy=getFigureProxy(this,editorId)


            import matlab.internal.editor.*
            figureProps=this.currentFigureMap(editorId);
            if isfield(figureProps,'focusedFigureProperties')
                figProxy=FigureProxy.lookupFigureProxy(figureProps.focusedFigureProperties.lineNumbers(end)+1,...
                editorId,figureProps.focusedFigureProperties.figureId);
            end
        end
    end

    methods(Static)
        function actionCallback(editorId,msgData)


            import matlab.internal.editor.figure.ToolstripSubscriber;
            import matlab.internal.editor.ModeManager;




            graphicsType=regexprep(msgData.actionId,'.*\.','');
            selectedState=isfield(msgData,"Selected")&&msgData.Selected;
            unselectedState=isfield(msgData,"Selected")&&~msgData.Selected;




            javaScriptAction=@()(message.publish(['/toolstrip/toolstripactionevent/',editorId],...
            struct('id',msgData.actionId)));



            toolstripSubscriber=matlab.internal.editor.figure.ToolstripSubscriber.getInstance;
            fp=toolstripSubscriber.getFigureProxy(editorId);
            if isempty(fp.DeserializedFigure)||~isvalid(fp.DeserializedFigure)
                fp.deserializeFigure;
            end
            ax=findobj(fp.DeserializedFigure,'-isa','matlab.graphics.axis.AbstractAxes','-depth',1,'Visible','on');


            atomicAction=any(strcmp(graphicsType,ToolstripSubscriber.ATOMIC_ACTIONS));
            springLoadedAction=any(strcmp(graphicsType,ToolstripSubscriber.SPRING_LOADED_ACTIONS));
            compositeAction=~atomicAction&&~springLoadedAction;



            if(compositeAction&&length(ax)<=1)||atomicAction
                if unselectedState
                    return
                end
                if strcmp('title',graphicsType)
                    if isempty(ax.Title_IS)
                        fp.actionInteractionCallback(graphicsType,'');
                    else
                        fp.actionInteractionCallback(graphicsType,x.Title_IS.String);
                    end
                else
                    fp.actionInteractionCallback(graphicsType);
                end

                message.publish(['/toolstrip/toolstripactionevent/',editorId],...
                struct('id',"",'operator',"not"));
            elseif springLoadedAction||compositeAction
                springLoadedModeNames=ModeManager.getSpringLoadedModeNames;
                I=find(strcmpi(springLoadedModeNames,sprintf('placed%sMode',graphicsType)));
                if~isempty(I)





                    if selectedState
                        message.publish(['/toolstrip/toolstripactionevent/',editorId],...
                        struct('id',msgData.actionId,'operator',"not"));
                    end

                    if unselectedState
                        fp.clearSpringLoadedModeFromJavaScript(msgData.actionId);
                    else
                        fp.activateSpringLoadedModeFromJavaScript(javaScriptAction,...
                        {fp.FigureId},editorId,{fp.Line-1},springLoadedModeNames(I(1)),msgData.actionId);
                    end
                end
            end
        end
    end
end