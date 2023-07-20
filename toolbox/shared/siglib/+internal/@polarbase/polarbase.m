classdef(Abstract)polarbase<handle




    methods(Static,Hidden,Abstract)
        [p,idx]=getCurrentPlot(ax)
    end

    methods(Static,Abstract)
formats
        keywords(p)
multiaxes
    end

    methods(Abstract)
        add(p,varargin)

        replace(p,varargin)
    end

    methods(Access=protected,Abstract)
        group=displayGroupLong(obj)
        group=displayGroupShort(obj,varname)
    end

    methods(Access=protected,Abstract)
        adjustFontSize(p)

        enableContextMenus(p,state)
        cacheColorValues(p)
        create_context_menus(p)
        createDataContextMenu(p,hParent)
        delKeyPressed(p)
        fig=createNewFigure(p)
        createListeners(p)
        strs=createStringsForLegend(p)
        destroyInstanceSpecificStuff(p,ax)
        ax=destroyStuffThatGetsRestoredWhenPlotIsCalled(p)
        drawCircles(p,isRotating)
        FigKeyEvent(p,ev)
        str=figureDataCursorUpdateFcn(p,e);
        [siz,mul]=getAngleFontSize(p,dir)
        [siz,mul]=getMagFontSize(p,dir)
        pInUse=getPolarAxes(p,forceReset)
        props=getSetObservableProps(p)
        s=initSplash(p)
        y=isPolariAxes(p)
        labelAngles(p)
        legend(p,varargin)
        legendBeingDestroyed(p)
        parseData(p,args)
        [args,pre_pv,post_pv]=parsePVPairArgs(p,args)
        [Zplane,hline,hglow]=points_recreateAllLines(p,Nd);
        plot(p,varargin)
        plot_axes(p,wasDirty);
        plot_data(p);
        plot_data_points(p);
        resetWidgetHandleProperties(p)
        setTitle(p,titleStr,place)
        updateAngleTickLabelColor(p)
        update=updateCache(p)
        updateDataLabels(p,action)
        updateGridView(p)
    end

    methods(Hidden,Abstract)
        addLegendMenus(p,hc,make)
        autoChangeMouseBehavior(p,s)
        s=computeHoverLocation(p,ev)
        createGridContextMenu(p,hParent)
        c_updateLayout(p)
        executeDelayedParamChanges(p)
        installMouseBehavior(p,behaviorStr)
        y=isIntensityData(p)
        z=getDataPlotZ(p,datasetIndex)
        h=getDataWidgetHandles(p)
        th=getNormalizedAngle(p,theta)
        overrideAngleTickLabelVis(p,st)
        plot_glow(p,state,datasetIdx)
        reorderDataPlot(p,dir,datasetIdx)
        setDataPlotZ(p,z);
    end

    methods(Access=protected)
        pt=bestFontSize(p)
        cacheChangeInAxesPosition(p)
        changeAxesHoldState(p)
        createTitlesContextMenu(p,hParent)
        deleteListeners(p)
        deleteObjectsInProperty(p,propName)
        destroyAxes(p)
        destroyAxesChildren(p)
        destroyAxesContent(p)
        pt=getFontSize(p)
        z=getGridZ(p)
        getParentFig(p)
        c=getPointsNextPlotColor(p)
        val=getTitle(p,place)
        [siz,mul]=getTitleFontSize(p,sel,dir)
        y=isLegendVisible(p)
        legendInteractiveChange(p)
        legendMarkedClean(p)
        y=mustDeferPropertyChange(p,propName)
        m_toggleLegend(p)
        openPropertyEditor_Dataset(p)
        post_pv=parseArgs(p,args)
        args=parseLeadingHandle(p,args)

        plot_data_points_active(p);
        [Zplane,hline,hglow]=points_AddOrRemoveLinesAsNeeded(p,Nd);
        propChange(p)
        restoreFigurePointer(p)
        titleStringChanged(p,select)
        updateAngleFont(p)
        updateColorOrder(p)
        updateLegend(p)
        updateTitleFont(p)
    end

    methods(Hidden)
        changeMouseBehavior(p,mouseBehavior,signalChangedState)
        enableListeners(p,state)
        pdata=getAllDatasets(p)
        bgcolor=getBackgroundColorOfAxes(p)
        N=getNumDatasets(p)
        mb_Dispatch(p,ev,fcnType)
        resetToolTip(p)
        resizeAxes(p)
        showAllProperties(obj)
        showToolTipAndPtr_default(p)
        updateTitlePos(p,select)
    end
end
