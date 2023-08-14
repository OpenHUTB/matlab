classdef(Hidden)SerializedFigureState<handle







    properties
        SerializedAxesAndCharts;
        SerializedAnnotations;
        SerializedFigureProperties;
        SerializedSubplotLocations;
        SerializedSpanSubplotLocations;
        SerializedSubplotTitle;

        SerializedModeState;
    end

    properties(Constant)
        UNSUPPORTED_FIGURE_PROPS=["MenuBar","ToolBar"];
    end

    methods

        function this=SerializedFigureState()
            this.SerializedModeState=matlab.internal.editor.figure.SerializedModeState;
        end

        function deserialize(this,fig)


            import matlab.internal.editor.*







            warnstate=warning('off');
            cleanupHandle=onCleanup(@()warning(warnstate));



            if(isfield(this.SerializedFigureProperties,'Colormap'))
                fig.Colormap=this.SerializedFigureProperties.Colormap;
                this.SerializedFigureProperties=rmfield(this.SerializedFigureProperties,'Colormap');
            end


            if isfield(this.SerializedFigureProperties,'Alphamap')
                fig.Alphamap=this.SerializedFigureProperties.Alphamap;
                this.SerializedFigureProperties=rmfield(this.SerializedFigureProperties,'Alphamap');
            end


            deserializeArray=WorkspaceUtilities.deserializeArray(this.SerializedAxesAndCharts);

            set(deserializeArray(end:-1:1),'Parent',fig);


            axWithPostDeserializeFcn=findall(deserializeArray,'flat','-function',@(x)isappdata(x,'PostDeserializeFcn'));
            for k=1:length(axWithPostDeserializeFcn)
                postDeserializeFcn=getappdata(axWithPostDeserializeFcn(k),'PostDeserializeFcn');
                feval(postDeserializeFcn,axWithPostDeserializeFcn(k),'load')
            end

            axWithCustomMaxResponsiveFontSize=findall(deserializeArray,'flat','-function',@(x)isappdata(x,'Internal_MaxResponsiveFontSize'));
            for k=1:length(axWithCustomMaxResponsiveFontSize)
                fontSize=getappdata(axWithCustomMaxResponsiveFontSize(k),'Internal_MaxResponsiveFontSize');
                setMaxResponsiveFontSize(axWithCustomMaxResponsiveFontSize(k),fontSize);
            end




            if~isempty(this.SerializedAnnotations)
                deserializeAnnotations=WorkspaceUtilities.deserializeArray(this.SerializedAnnotations);
                annotationPane=matlab.graphics.annotation.internal.getDefaultCamera(fig,'overlay');
                if~isempty(deserializeAnnotations)&&~isempty(annotationPane)
                    set(deserializeAnnotations(end:-1:1),'Parent',annotationPane);
                end
            end


            if~isempty(this.SerializedFigureProperties)
                propNames=setdiff(fieldnames(this.SerializedFigureProperties),this.UNSUPPORTED_FIGURE_PROPS);
                for k=1:length(propNames)
                    if strcmp(propNames{k},'Position')||strcmp(propNames{k},'OuterPosition')
                        if strcmp(propNames{k},'Position')
                            pos=this.SerializedFigureProperties.Position;
                        else
                            pos=this.SerializedFigureProperties.OuterPosition;
                        end



                        if strcmp(get(groot,'Units'),'pixels')
                            screenSize=get(groot,'ScreenSize');
                        else
                            oldRootunits=get(groot,'Units');
                            set(groot,'Units','pixels');
                            screenSize=get(groot,'ScreenSize');
                            set(groot,'Units',oldRootunits);
                        end
                        overflowScaleFactor=max(pos(3:4)./(screenSize(3:4)-2));
                        if overflowScaleFactor>=1
                            pos(3:4)=pos(3:4)/overflowScaleFactor;
                        end
                        fig.(propNames{k})=pos;
                    else
                        if(isequal(propNames{k},'CallbackNotSupportedWarning')&&isprop(fig,'CallbackNotSupportedWarning'))||...
                            ~isequal(propNames{k},'CallbackNotSupportedWarning')
                            fig.(propNames{k})=this.SerializedFigureProperties.(propNames{k});
                        end
                    end
                end
            end



            if matlab.graphics.interaction.internal.isPublishingTest||(isServerSideNeededForAxes(fig)&&isprop(fig,'IsForcedSSR'))
                matlab.internal.editor.figure.FigureUtils.setFigureServerSideRendered(fig);
                if isprop(fig,'IsForcedSSR')


                    fig.IsForcedSSR=true;
                end
            end


            matlab.ui.internal.restoreSubplotLayout...
            (this.SerializedSubplotLocations,this.SerializedSpanSubplotLocations,...
            this.SerializedSubplotTitle,deserializeArray,fig);
        end


        function deserializeFigureLaunch(this,fig)

            deserialize(this,fig);





            if~isempty(matlab.graphics.internal.getFigureJavaFrame(fig))
                serializedUnsupportedProperties=intersect(this.UNSUPPORTED_FIGURE_PROPS,fieldnames(this.SerializedFigureProperties));
                for k=1:length(serializedUnsupportedProperties)
                    fig.(serializedUnsupportedProperties{k})=this.SerializedFigureProperties.(serializedUnsupportedProperties{k});
                end
            end


            axesAndCharts=matlab.ui.internal.getAllCharts(fig);
            hGeobubble=getGeobubble(axesAndCharts);
            for i=1:length(hGeobubble)


                showMapActionsPalette(hGeobubble(i));
            end
        end


        function serialize(this,fig)



















            serializedFigureProperties=struct;
            if~isempty(this.SerializedFigureProperties)
                unsupportedFigureProps=intersect(fieldnames(this.SerializedFigureProperties),this.UNSUPPORTED_FIGURE_PROPS);
                for k=1:length(unsupportedFigureProps)
                    serializedFigureProperties.(unsupportedFigureProps{k})=this.SerializedFigureProperties.(unsupportedFigureProps{k});
                end
            end

            axesAndCharts=matlab.ui.internal.getAllCharts(fig);
            if~isempty(fig.ResizeFcn)||~isempty(fig.SizeChangedFcn)
                notify(fig,'SizeChanged');
drawnow
            else
                if anyCameraPropManual(axesAndCharts)||anyLegendOrColorbar(axesAndCharts)...
                    ||any(isa(axesAndCharts,'matlab.graphics.layout.Layout'))


                    drawnow update
                end
            end

            if strcmp(fig.PositionMode,'manual')

                serializedFigureProperties.Position=fig.Position;
                if strcmp(fig.UnitsMode,'manual')&&~strcmp(fig.Units,'pixels')
                    serializedFigureProperties.Position=hgconvertunits(fig,...
                    serializedFigureProperties.Position,fig.Units,'pixels',groot);
                end
            elseif strcmp(fig.OuterPositionMode,'manual')

                serializedFigureProperties.OuterPosition=fig.OuterPosition;
                if strcmp(fig.UnitsMode,'manual')&&~strcmp(fig.Units,'pixels')
                    serializedFigureProperties.OuterPosition=hgconvertunits(fig,...
                    serializedFigureProperties.OuterPosition,fig.Units,'pixels',groot);
                end
            end

            import matlab.internal.editor.*





            hGeobubble=getGeobubble(axesAndCharts);
            for i=1:length(hGeobubble)


                hideMapActionsPalette(hGeobubble(i));
            end
            this.SerializedAxesAndCharts=WorkspaceUtilities.serializeArray(axesAndCharts);


            annotationPane=findall(fig,'-depth',1,'type','annotationpane');
            if~isempty(annotationPane)
                annotations=findall(annotationPane,'-depth',1,'-isa','matlab.graphics.shape.internal.ScribeObject');
                if~isempty(annotations)
                    this.SerializedAnnotations=WorkspaceUtilities.serializeArray(annotations);
                end
            end


            if strcmp(fig.ColormapMode,'manual')
                serializedFigureProperties.Colormap=fig.Colormap;
            end


            if strcmp(fig.AlphamapMode,'manual')
                serializedFigureProperties.Alphamap=fig.Alphamap;
            end

            if strcmp(fig.ColorMode,'manual')&&~isequal(fig.Color,get(0,'DefaultFigureColor'))
                serializedFigureProperties.Color=fig.Color;
            end


            if strcmp(fig.ToolBarMode,'manual')
                serializedFigureProperties.ToolBar=fig.ToolBar;
            end


            if strcmp(fig.MenuBarMode,'manual')
                serializedFigureProperties.MenuBar=fig.MenuBar;
            end


            if strcmp(fig.NumberTitleMode,'manual')
                serializedFigureProperties.NumberTitle=fig.NumberTitle;
            end


            if~isempty(fig.Name)
                serializedFigureProperties.Name=fig.Name;
            end


            if~isempty(fig.UserData)
                serializedFigureProperties.UserData=fig.UserData;
            end





            [this.SerializedSubplotLocations,this.SerializedSpanSubplotLocations,this.SerializedSubplotTitle]...
            =matlab.ui.internal.saveSubplotLayout(fig,axesAndCharts);


            this.SerializedModeState.serialize(fig);

            mode=this.SerializedModeState.getCurrentMode(fig);
            if isprop(fig,'LiveEditorRunTimeFigure')&&fig.LiveEditorRunTimeFigure&&~isempty(mode)
                activateuimode(fig,'');
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                figureCallbacksSupportedArray={'WindowButtonUpFcn','WindowButtonDownFcn','WindowButtonMotionFcn',...
                'ResizeFcn','CreateFcn','DeleteFcn','SizeChangedFcn','ButtonDownFcn','CloseRequestFcn'};
                figureCallbacksNotSupportedArray={'WindowScrollWheelFcn','WindowKeyPressFcn','WindowKeyReleaseFcn','KeyPressFcn','KeyReleaseFcn'};

                for idx=1:numel(figureCallbacksSupportedArray)
                    if~isempty(fig.(figureCallbacksSupportedArray{idx}))&&((isequal(figureCallbacksSupportedArray{idx},'CloseRequestFcn')&&...
                        ~isequal(fig.(figureCallbacksSupportedArray{idx}),'closereq'))||~isequal(figureCallbacksSupportedArray{idx},'CloseRequestFcn'))
                        if~checkIfCallbackWarningRequired(fig,figureCallbacksSupportedArray{idx})
                            serializedFigureProperties.(figureCallbacksSupportedArray{idx})=fig.(figureCallbacksSupportedArray{idx});
                        else
                            serializedFigureProperties.CallbackNotSupportedWarning=true;
                        end
                    end
                end



                if(isfield(serializedFigureProperties,'CallbackNotSupportedWarning')&&~serializedFigureProperties.CallbackNotSupportedWarning)||...
                    ~isfield(serializedFigureProperties,'CallbackNotSupportedWarning')
                    for index=1:numel(figureCallbacksNotSupportedArray)
                        if~isempty(fig.(figureCallbacksNotSupportedArray{index}))


                            serializedFigureProperties.CallbackNotSupportedWarning=true;

                            break;
                        end
                    end
                end
            end
            this.SerializedFigureProperties=serializedFigureProperties;
            if isprop(fig,'LiveEditorRunTimeFigure')&&fig.LiveEditorRunTimeFigure&&~isempty(mode)
                activateuimode(fig,mode);
            end
        end
    end
end

function warningRequired=checkIfCallbackWarningRequired(fig,figureCallbackProperty)







    warningRequired=false;

    if~isempty(fig.(figureCallbackProperty))
        if isa(fig.(figureCallbackProperty),'function_handle')
            getCallbackMetadata=functions(fig.(figureCallbackProperty));
            if checkCallbackMetadataWorkspaceObject(getCallbackMetadata)&&...
                checkCallbackIsDefinedWithinLiveEditor(getCallbackMetadata)


                objStruct=structfun(@(obj)obj,getCallbackMetadata.workspace{1},'UniformOutput',false);
                fieldnameStruct=fieldnames(objStruct);
                for idx=1:numel(fieldnameStruct)
                    if checkIfObjectBelongsToRuntimeFigure(objStruct.(fieldnameStruct{idx}))
                        warningRequired=true;
                        break;
                    end
                end
            end
        elseif isa(fig.(figureCallbackProperty),'cell')
            objArray=cellfun(@(obj)obj,fig.(figureCallbackProperty),'UniformOutput',false);

            if isa(objArray{1},'function_handle')
                getCallbackMetadata=functions(objArray{1});
                if~isempty(getCallbackMetadata)&&checkCallbackIsDefinedWithinLiveEditor(getCallbackMetadata)
                    for idx=2:numel(objArray)
                        if checkIfObjectBelongsToRuntimeFigure(objArray{idx})
                            warningRequired=true;
                            break;
                        end
                    end
                end
            end
        end
    end
end

function ret=checkCallbackMetadataWorkspaceObject(getCallbackMetadata)


    ret=~isempty(getCallbackMetadata)&&isfield(getCallbackMetadata,'workspace')&&~isempty(getCallbackMetadata.workspace)&&...
    iscell(getCallbackMetadata.workspace)&&isstruct(getCallbackMetadata.workspace{1})&&~isempty(fieldnames(getCallbackMetadata.workspace{1}));
end

function ret=checkIfObjectBelongsToRuntimeFigure(callbackWorkspaceObject)






    import matlab.internal.editor.figure.*

    ret=false;




    if isa(callbackWorkspaceObject,'matlab.graphics.Graphics')
        if~isa(callbackWorkspaceObject,'matlab.ui.Figure')
            getFigParent=ancestor(callbackWorkspaceObject,'matlab.ui.Figure');
            if~isempty(getFigParent)&&isprop(getFigParent(1),'Tag')&&FigureUtils.isEditorEmbeddedFigure(getFigParent(1))
                ret=true;
            end
        elseif isa(callbackWorkspaceObject,'matlab.ui.Figure')&&FigureUtils.isEditorEmbeddedFigure(callbackWorkspaceObject)
            ret=true;
        end
    end
end

function ret=checkCallbackIsDefinedWithinLiveEditor(getCallbackMetadata)






    ret=false;
    if isfield(getCallbackMetadata,'file')
        if~isempty(getCallbackMetadata.file)
            [~,name,~]=fileparts(getCallbackMetadata.file);
            if contains(name,'LiveEditorEvaluationHelper')
                ret=true;
            end
        end
    end
end

function hGeobubble=getGeobubble(axesAndCharts)

    hGeobubble=findobj(axesAndCharts,'flat','Type','geobubble');
end

function ret=isServerSideNeededForAxes(hFig)

    ret=~isempty(findobj(hFig,'-isa','matlab.graphics.chart.GeographicBubbleChart','-or',...
    '-isa','matlab.graphics.axis.GeographicAxes'));
end

function ret=anyCameraPropManual(hAxes)

    ret=~isempty(findobj(hAxes,'flat',...
    'CameraPositionMode','manual','-or',...
    'CameraTargetMode','manual','-or',...
    'CameraViewAngleMode','manual','-or',...
    'CameraUpVectorMode','manual'));
end


function ret=anyLegendOrColorbar(hAxes)



    hParents=ancestor(hAxes,'matlab.graphics.shape.internal.AxesLayoutManager','node');
    if~iscell(hParents)
        hParents={hParents};
    end
    ret=any(~cellfun('isempty',hParents));
end