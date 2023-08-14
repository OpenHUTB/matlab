classdef(CaseInsensitiveProperties=true)DataCursorManager<handle&JavaVisible&hgsetget&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer





    properties(Access=public,SetObservable,GetObservable,Dependent)


        SnapToDataVertex matlab.internal.datatype.matlab.graphics.datatype.on_off



        DisplayStyle{matlab.internal.validation.mustBeASCIICharRowVector(DisplayStyle,'DisplayStyle')}=char.empty


        DefaultExportVarName{matlab.internal.validation.mustBeASCIICharRowVector(DefaultExportVarName,'DefaultExportVarName')}=char.empty


        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
    end

    properties(Access=public,SetObservable,GetObservable,Transient)






UpdateFcn
    end

    properties(Access=public,SetObservable,GetObservable,Transient)

        Enable matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end



    properties(Access=public,Hidden,Transient)

        UIContextMenu=[];


        DisplayStyleListener=[];
    end


    properties(Access=public,Hidden,Dependent)

        CurrentCursor matlab.graphics.shape.internal.PointDataCursor;
    end

    properties(GetAccess=public,SetAccess=private,Transient)



        Figure;
    end


    properties(Access=private,Dependent)

        PointDataCursors matlab.graphics.shape.internal.PointDataCursor;
    end


    properties(Access=private,Transient)

        CurrentCursorStorage matlab.graphics.shape.internal.PointDataCursor=matlab.graphics.shape.internal.PointDataCursor.empty;



        PanelHandle matlab.graphics.shape.internal.FigurePanel=matlab.graphics.shape.internal.FigurePanel.empty;


        ModeHandle=[];


        ModeListener=[];




        IsActivationChanging=false;



        FigureListener=event.listener.empty;
    end


    methods
        function hObj=DataCursorManager(hMode,varargin)

            hObj.ModeHandle=hMode;


            hObj.initializeFigureState();

            noContextMenu=nargin>1&&strcmpi(varargin{1},'-nocontextmenu');


            if~isempty(hMode)&&~noContextMenu




                hObj.initContextMenu();
            end



            hTips=findAllTips(hObj.Figure);
            if~isempty(hTips)



                currentTip=hTips(strcmpi({hTips.CurrentTip},'on'));
                if~isempty(currentTip)
                    hObj.CurrentCursor=currentTip(1).Cursor;
                else
                    hObj.CurrentCursor=hTips(end).Cursor;
                end
            end
        end

        function delete(hObj)


            uic=hObj.UIContextMenu;
            if~isempty(uic)...
                &&ishghandle(uic)...
                &&strcmp(uic.Tag,'DataCursorModeContextMenu')
                delete(hObj.UIContextMenu);
            end


            delete(hObj.FigureListener);
        end

        function set.ModeHandle(hObj,newValue)


            hObj.ModeHandle=newValue;
            if~isempty(newValue)&&isvalid(newValue)
                hObj.ModeListener=event.listener(newValue,'ObjectBeingDestroyed',@(obj,evd)(delete(hObj)));
                hObj.Figure=newValue.FigureHandle;
            else
                hObj.ModeListener=[];
                hObj.Figure=[];
            end
        end

        function val=get.PointDataCursors(hObj)
            tips=findAllTips(hObj.Figure);
            val=[tips.Cursor];
        end

        function set.Enable(hObj,newValue)

            if~strcmpi(newValue,hObj.Enable)



                hObj.Enable=newValue;

                if~hObj.IsActivationChanging


                    hMode=hObj.ModeHandle;
                    if isvalid(hMode)&&~strcmpi(newValue,hMode.Enable)



                        if strcmpi(newValue,'on')
                            activateuimode(hObj.Figure,hMode.Name);
                        else
                            activateuimode(hObj.Figure,'');
                        end
                    end
                end
            end
        end

        function retVal=get.DefaultExportVarName(hObj)

            retVal=hObj.getState('DefaultExportVarName','');
        end

        function set.DefaultExportVarName(hObj,newValue)
            newValue=matlab.internal.validation.makeCharRowVector(newValue);

            hObj.setState('DefaultExportVarName',newValue);
        end

        function retVal=get.UpdateFcn(hObj)

            retVal=hObj.getState('UpdateFcn','');
        end

        function set.UpdateFcn(hObj,newValue)

            hObj.setState('UpdateFcn',newValue);


            hObj.updateDataCursors();
        end

        function retVal=get.Interpreter(hObj)

            retVal=hObj.getState('Interpreter','');
        end

        function set.Interpreter(hObj,newValue)

            hObj.setState('Interpreter',newValue);


            hObj.updateInterpreterForDataCursors;
        end

        function retVal=get.DisplayStyle(hObj)

            retVal=hObj.getState('DisplayStyle','datatip');
        end

        function set.DisplayStyle(hObj,newValue)
            newValue=matlab.internal.validation.makeCharRowVector(newValue);


            newValue=lower(newValue);
            if~strcmp(newValue,hObj.DisplayStyle)
                if strcmp(newValue,'window')
                    hCursor=hObj.CurrentCursor;



                    if~isempty(hCursor)||strcmp(hObj.Enable,'on')

                        hObj.Enable='on';





                        if matlab.ui.internal.isUIFigure(hObj.Figure)
                            enableLegacyExplorationModes(hObj.Figure);
                        end


                        hObj.initializePanel;



                        if~isempty(hCursor)
                            tips=findAllTips(hObj.Figure);
                            currentTip=hObj.getTipFromCursor(hCursor);


                            delete(setdiff(tips,currentTip));


                            currentTip.TipHandle=matlab.graphics.shape.internal.PanelTip();
                        end
                    end
                else

                    hFigPanel=matlab.graphics.shape.internal.DataCursorManager.getFigurePanel(hObj.Figure);
                    hFigPanel.Visible='off';



                    tips=findAllTips(hObj.Figure);
                    for n=1:length(tips)
                        tips(n).TipHandle=matlab.graphics.shape.internal.GraphicsTip();
                    end
                end


                hObj.setState('DisplayStyle',newValue);
            end
        end

        function set.CurrentCursor(hObj,newValue)

            if isempty(newValue)
                doUpdates=~isempty(hObj.CurrentCursorStorage);
            else
                doUpdates=isempty(hObj.CurrentCursorStorage)...
                ||hObj.CurrentCursorStorage~=newValue;
            end


            if doUpdates


                hOldTip=hObj.getTipFromCursor(hObj.CurrentCursorStorage);
                if~isempty(hOldTip)&&isvalid(hOldTip)
                    hOldTip.CurrentTip='off';
                end


                hNewTip=hObj.getTipFromCursor(newValue);
                if~isempty(hNewTip)&&isvalid(hNewTip)
                    hNewTip.CurrentTip='on';

                    if isempty(hObj.FigureListener)
                        hObj.FigureListener=event.listener(hObj.Figure,...
                        'WindowMousePress',@(obj,evd)hObj.removeDataTipSelection(obj,evd));
                    end
                end
            end


            hObj.CurrentCursorStorage=newValue;
        end

        function value=get.CurrentCursor(hObj)

            value=hObj.CurrentCursorStorage;

            if~isempty(value)&&isvalid(value)

                tip=hObj.getTipFromCursor(value);
                if isempty(tip)
                    value=matlab.graphics.shape.internal.PointDataCursor.empty;
                end
            end

            if isempty(value)||~isvalid(value)
                value=matlab.graphics.shape.internal.PointDataCursor.empty;


                hTips=findAllTips(hObj.Figure);
                if~isempty(hTips)
                    value=hTips(end).Cursor;
                    hObj.CurrentCursorStorage=value;
                end
            end
        end

        function retVal=get.UIContextMenu(hObj)
            if ishghandle(hObj.UIContextMenu)
                retVal=hObj.UIContextMenu;
            elseif~isempty(hObj.ModeHandle)&&isvalid(hObj.ModeHandle)

                retVal=hObj.ModeHandle.UIContextMenu;
                hObj.UIContextMenu=retVal;
            else
                retVal=[];
            end
        end

        function set.UIContextMenu(hObj,newValue)
            hObj.UIContextMenu=newValue;
            if~isempty(hObj.ModeHandle)&&isvalid(hObj.ModeHandle)
                hObj.ModeHandle.UIContextMenu=newValue;
            end
        end

        function retVal=get.SnapToDataVertex(hObj)

            retVal=hObj.getState('SnapToDataVertex','on');
        end

        function set.SnapToDataVertex(hObj,newValue)


            hObj.setState('SnapToDataVertex',newValue);

            hCursors=hObj.PointDataCursors;
            for i=1:numel(hCursors)
                hObj.updateInterpolateValue(hCursors(i));
            end
        end
    end



    methods(Access=public)
        function removeDataCursor(hObj,hCursor)


            if~isvalid(hObj)||~any(hObj.PointDataCursors==hCursor)
                return
            end



            delete(hCursor);
        end

        function removeAllDataCursors(hObj,hContainer)


            if nargin>1
                hTips=findAllTips(hContainer);
            else
                hTips=findAllTips(hObj.Figure);
            end
            delete(hTips);
            delete(hObj.FigureListener);

            hObj.CurrentCursorStorage=matlab.graphics.shape.internal.PointDataCursor.empty;
        end

        function info=getCursorInfo(hObj)

            info=[];
            infoIndex=1;

            hCursors=hObj.PointDataCursors;
            for i=1:numel(hCursors)
                hThisCursor=hCursors(i);
                currentTip=hObj.getTipFromCursor(hThisCursor);

                if~isempty(currentTip)&&isvalid(currentTip)&&strcmp(currentTip.PinnedView,'on')
                    hTarget=hThisCursor.DataSource;
                    info(infoIndex).Target=hTarget.getAnnotationTarget();%#ok<AGROW>
                    info(infoIndex).Position=getLocation(hThisCursor.getReportedPosition(),hTarget.getAnnotationTarget());%#ok<AGROW>



                    if ishghandle(hTarget,'line')||isa(hTarget,'matlab.graphics.chart.interaction.dataannotatable.LineAdaptor')
                        info(infoIndex).DataIndex=hThisCursor.DataIndex;%#ok<AGROW>
                    end
                    infoIndex=infoIndex+1;
                end
            end
        end

        function hTip=createDatatip(hObj,hTarget,figPoint)


            hTarget=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hTarget);

            if nargin<3


                figPoint=get(hObj.Figure,'CurrentPoint');
                figPoint=hgconvertunits(hObj.Figure,[figPoint,0,0],get(hObj.Figure,'Units'),'pixels',hObj.Figure);
                figPoint=figPoint(1:2);
            end

            if strcmp(hObj.DisplayStyle,'datatip')
                hCursor=createCursor(hObj,hTarget,figPoint);
                hTip=createTip(hObj,hCursor);
            else

                hCursor=hObj.CurrentCursorStorage;
                hTip=hObj.getTipFromCursor(hCursor);
                if isempty(hCursor)||~isvalid(hCursor)||isempty(hTip)
                    hCursor=createCursor(hObj,hTarget,figPoint);
                    hTip=createTip(hObj,hCursor);
                    hTip.TipHandle=matlab.graphics.shape.internal.PanelTip();
                else

                    hCursor.DataSource=hTarget;
                    hObj.updateInterpolateValue(hCursor);

                    hCursor.moveTo(figPoint);
                end
            end
        end

        function addDataCursor(hObj,hTip)
            if isvalid(hTip)
                hObj.CurrentCursor=hTip.Cursor;
            end
        end

        function updateDataCursors(hObj)
            hTips=findAllTips(hObj.Figure);
            for i=1:numel(hTips)
                hDS=hTips(i).Cursor.DataSource.getAnnotationTarget();



                if isprop(hDS,'DataTipTemplate')&&isvalid(hDS.DataTipTemplate)&&...
                    strcmpi(hDS.DataTipTemplate.DataTipRowsMode,'auto')
                    hTips(i).UpdateFcn=hObj.UpdateFcn;
                end
            end
        end

        function updateInterpreterForDataCursors(hObj)
            interpreter=hObj.Interpreter;
            if~isempty(interpreter)
                hTips=findAllTips(hObj.Figure);
                for i=1:numel(hTips)



                    hDS=hTips(i).Cursor.DataSource.getAnnotationTarget();
                    if isprop(hDS,'DataTipTemplate')&&isvalid(hDS.DataTipTemplate)&&...
                        strcmpi(hDS.DataTipTemplate.InterpreterMode,'auto')
                        hTips(i).Interpreter=interpreter;
                    end
                end
            end
        end
    end


    methods(Access=public,Hidden=true)

        function hMenu=createOrGetContextMenu(hObj)
            if isempty(hObj.UIContextMenu)
                hObj.initContextMenu();
            end
            hMenu=hObj.UIContextMenu;
        end


        function datatip=getCurrentDataTip(hObj)


            datatip=hObj.getTipFromCursor(hObj.CurrentCursorStorage);

        end

        function startMode(hObj)
            hObj.IsActivationChanging=true;


            hTip=hObj.getTipFromCursor(hObj.CurrentCursor);
            set(hTip,'CurrentTip','on');

            if strcmp(hObj.DisplayStyle,'window')
                hObj.initializePanel;
            end

            if isempty(hObj.UIContextMenu)


                hObj.initContextMenu();
            end

            hObj.Enable='on';

            hObj.IsActivationChanging=false;
        end

        function endMode(hObj)
            hObj.IsActivationChanging=true;

            if(strcmpi(hObj.DisplayStyle,'window'))

                hObj.removeAllDataCursors();
            else

                hTip=hObj.getTipFromCursor(hObj.CurrentCursor);
                set(hTip,'CurrentTip','off');
            end


            if~isempty(hObj.PanelHandle)&&isvalid(hObj.PanelHandle)
                delete(hObj.PanelHandle);
            end

            hObj.Enable='off';

            hObj.IsActivationChanging=false;
        end

        function hTip=getTipFromCursor(hObj,hCursor)
            hTip=matlab.graphics.shape.internal.PointDataTip.empty;
            if~isempty(hCursor)&&isvalid(hCursor)
                tips=findAllTips(hObj.Figure);
                if~isempty(tips)
                    hTip=tips([tips.Cursor]==hCursor);
                end
            end
        end

        function info=hasInfo(hObj)
            info=~isempty(findAllTips(hObj.Figure));
        end

        function initContextMenu(hObj)

            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)&&~hObj.ModeHandle.LiveEditorFigure


                hObj.UIContextMenu=hObj.createContextMenu();
            end
        end

        function updateDataTipSettings(hObj,hTip,hTarget)




            if isprop(hTarget,'DataTipTemplate')&&isvalid(hTarget.DataTipTemplate)
                if~isempty(hObj.UpdateFcn)&&strcmpi(hTarget.DataTipTemplate.DataTipRowsMode,'auto')
                    hTip.UpdateFcn=hObj.UpdateFcn;
                end
                if strcmpi(hTarget.DataTipTemplate.InterpreterMode,'auto')
                    hTip.Interpreter=hObj.Interpreter;
                end
            end
        end

        function interpVal=updateInterpolateValue(hObj,hCursor)
            interpVal='off';
            if strcmpi(hObj.SnapToDataVertex,'off')
                interpVal='on';
            end
            hAx=ancestor(hCursor.DataSource,'axes');
            if~isempty(hAx)&&isa(hAx,'matlab.graphics.axis.AbstractAxes')&&~isempty(hAx.Interactions)
                ind=arrayfun(@(x)isa(x,'matlab.graphics.interaction.interactions.DataTipInteraction'),hAx.Interactions);
                if~isempty(hAx.Interactions(ind))
                    if strcmpi(hAx.Interactions(ind).SnapToDataVertex,'on')
                        interpVal='off';
                    else
                        interpVal='on';
                    end
                end
            end
            if~isequal(hCursor.Interpolate,interpVal)
                hCursor.Interpolate=interpVal;
            end
        end
    end



    methods(Access=private)
        function initializeFigureState(hObj)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                if~isprop(hObj.Figure,'DataCursorState')

                    prop=addprop(hObj.Figure,'DataCursorState');
                    prop.Hidden=true;
                end

                if isempty(hObj.Figure.DataCursorState)...
                    ||~isa(hObj.Figure.DataCursorState,'matlab.graphics.shape.internal.DataCursorState')


                    hObj.Figure.DataCursorState=matlab.graphics.shape.internal.DataCursorState;
                end


                can=findobjinternal(hObj.Figure,'-isa','matlab.graphics.primitive.canvas.HTMLCanvas');
                if~isempty(can)&&...
                    isempty(hObj.DisplayStyleListener)
                    hObj.DisplayStyleListener=event.proplistener(hObj,hObj.findprop('DisplayStyle'),'PostSet',...
                    @(~,~)hObj.displayStyleCallback());
                end
            end
        end

        function displayStyleCallback(hObj)
            if strcmpi(hObj.DisplayStyle,'window')


                delete(findall(hObj.Figure,'-isa','matlab.graphics.shape.internal.PointDataTip'));
            end
        end



        function removeDataTipSelection(hObj,~,e)
            if~isactiveuimode(hObj.Figure,'Exploration.Datacursor')&&...
                ~isa(e.HitObject,'matlab.graphics.shape.internal.ScribePeer')
                currentTip=hObj.getCurrentDataTip();
                set(currentTip,'CurrentTip','off');
            end
        end

        function val=getState(hObj,propName,defaultVal)




            val=defaultVal;

            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                hObj.initializeFigureState();
                val=hObj.Figure.DataCursorState.(propName);
            end

        end

        function setState(hObj,propName,val)




            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                hObj.initializeFigureState();
                hObj.Figure.DataCursorState.(propName)=val;
            end
        end

        function hCursor=createCursor(hObj,hTarget,figPoint)
            hCursor=matlab.graphics.shape.internal.PointDataCursor(hTarget);

            hObj.updateInterpolateValue(hCursor);

            hCursor.moveTo(figPoint);

            hObj.CurrentCursor=hCursor;
        end

        function hTip=createTip(hObj,hCursor)
            hTip=matlab.graphics.shape.internal.PointDataTip(hCursor,...
            'Visible','on',...
            'HandleVisibility','off');



            modeController=matlab.graphics.shape.internal.ModeDataTipController.getInstance();
            hTip.Controller=[hTip.Controller,modeController];

            if(hCursor==hObj.CurrentCursor)
                hTip.CurrentTip='on';
            end

            hObj.updateDataTipSettings(hTip,hCursor.DataSource);
        end
    end

    methods(Access=public,Static,Hidden)
        function deserializeHG1DataTips(hFig,datatipInformation,datatipTipProperties,datatipUpdateFcn)
            datacursormode(hFig,'on');
            hObj=datacursormode(hFig);
            hObj.UpdateFcn=datatipUpdateFcn;

            if isfield(datatipInformation,'InterpolationFactor')...
                &&any([datatipInformation.InterpolationFactor]~=0)



                hObj.SnapToDataVertex='off';
            end

            for i=1:numel(datatipInformation)

                hPDT=hObj.createDatatip(datatipInformation(i).Target,[0,0]);





                position=datatipInformation(i).Position;
                if numel(position)==2

                    position(3)=0;
                end
                hPDT.Cursor.Position=position;



                if isfield(datatipTipProperties,'Orientation')
                    hPDT.Orientation=strrep(datatipTipProperties(i).Orientation,'-','');
                end
                if isfield(datatipTipProperties,'OrientationMode')
                    hPDT.OrientationMode=datatipTipProperties(i).OrientationMode;
                end
            end
            datacursormode(hFig,'off');
        end
    end



    methods(Access=private)
        function initializePanel(hObj)

            hFigPanel=hObj.PanelHandle;
            if isempty(hFigPanel)||~isvalid(hFigPanel)
                hFig=hObj.Figure;
                if~isempty(hFig)&&isvalid(hFig)
                    hFigPanel=matlab.graphics.shape.internal.DataCursorManager.getFigurePanel(hFig);
                end
                hObj.PanelHandle=hFigPanel;
            end
            hFigPanel.Visible='on';
        end
    end

    methods(Access=private,Static)
        hPanel=getFigurePanel(hFig);
    end

    methods(Access=?matlab.graphics.shape.internal.PanelTip,Static)
        hInterface=getModePanelInterface(hFig);
    end
end


function tips=findAllTips(hContainer)
    tips=findall(hContainer,'-class','matlab.graphics.shape.internal.PointDataTip');
    if isempty(tips)
        tips=matlab.graphics.shape.internal.PointDataTip.empty(1,0);
    else
        tips=reshape(tips,1,numel(tips));
    end
    tips=[tips,findTipsInChartContainers(hContainer)];
end

function tips=findTipsInChartContainers(hContainer)
    tips=matlab.graphics.shape.internal.PointDataTip.empty(1,0);
    charts=findall(hContainer,'-isa','matlab.graphics.chartcontainer.ChartContainer');
    if isempty(charts)
        return
    end

    chartaxes=findobjinternal(charts,'-isa','matlab.graphics.axis.AbstractAxes');
    tips=findall(chartaxes,'-class','matlab.graphics.shape.internal.PointDataTip');
    if~isempty(tips)
        tips=reshape(tips,1,numel(tips));
    end
end
