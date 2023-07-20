function bfitlisten(objhandle,varargin)







    if(nargin>1)
        figh=ancestor(objhandle,'figure');
        addLineObjectDestroyedListener(objhandle,figh);
        return;
    end

    if(isequal(get(objhandle,'Type'),'axes')&&isequal(get(objhandle,'Tag'),'legend'))||...
        isequal(get(objhandle,'Type'),'legend')
        if isempty(bfitFindProp(objhandle,'bfit_AxesListeners'))
            listeners.userDataChanged=matlab.ui.internal.createListener(objhandle,...
            bfitFindProp(objhandle,'UserData'),'PostSet',bfitCallbackFunction(@userDataChanged,...
            get(objhandle,'parent')));
            bfitAddProp(objhandle,'bfit_AxesListeners');
            set(handle(objhandle),'bfit_AxesListeners',listeners);
        end
        return;
    end

    fig=handle(objhandle);
    if isempty(bfitFindProp(fig,'bfit_FigureListeners'))


        axesH=findobj(fig,'Type','axes');
        listenerObject=fig.getCanvas;
        listener=[];
        sm=listenerObject.StackManager;
        if isempty(sm)
            l=event.listener(listenerObject,'ObjectChildAdded',@(e,d)localAddChild(e,d,fig,listener));
        else
            sl=sm.getLayer(listenerObject,'middle');
            if~isempty(sl)
                listenerObject=sl;
            end
        end
        if~isempty(axesH)


            axesH=axesH(1);
            axesManager=matlab.graphics.shape.internal.AxesLayoutManager.getManager(axesH);
            listener.axesManagerChildadd=matlab.ui.internal.createListener(axesManager,'ObjectChildAdded',...
            bfitCallbackFunction(@figChildAdded,fig));
            listener.axesManagerChildremove=matlab.ui.internal.createListener(axesManager,'ObjectChildRemoved',...
            bfitCallbackFunction(@figChildRemoved,fig));
        else
        end

        listener=localAddRemoveObjectListeners(listenerObject,fig,listener);


        bfitAddProp(fig,'bfit_FigureListeners');
        set(handle(fig),'bfit_FigureListeners',listener);
    end





    plotmgr=matlab.graphics.annotation.internal.getplotmanager;

    lsnr=event.listener(plotmgr,'PlotEditPaste',bfitCallbackFunction(@figPasteDoneCallback,fig));


    if~isprop(handle(fig),'bfit_PlotEditPasteLsnr')
        bfitAddProp(fig,'bfit_PlotEditPasteLsnr');
    end
    set(handle(fig),'bfit_PlotEditPasteLsnr',lsnr);

    lsnr=event.listener(plotmgr,'PlotEditBeforePaste',bfitCallbackFunction(@figBeforePasteCallback,fig));


    if~isprop(handle(fig),'bfit_PlotEditBeforePasteLsnr')
        bfitAddProp(fig,'bfit_PlotEditBeforePasteLsnr');
    end
    set(handle(fig),'bfit_PlotEditBeforePasteLsnr',lsnr);


    axesList=datachildren(fig);
    lineL=plotchild(axesList,3,true);
    for i=lineL'
        if~isempty(get(i,'xdata'))&&~isempty(get(i,'ydata'))&&(~isprop(i,'zdata')||isempty(get(i,'zdata')))

            hProp=bfitFindProp(i,'Tag');
            if isempty(bfitFindProp(i,'bfit_CurveListeners'))
                listener.tagchanged=matlab.ui.internal.createListener(i,hProp,'PostSet',...
                bfitCallbackFunction(@lineTagChanged,fig));
                bfitAddProp(i,'bfit_CurveListeners');
                set(handle(i),'bfit_CurveListeners',listener);
            end

            hPropDisplayName=bfitFindProp(i,'DisplayName');
            if isempty(bfitFindProp(i,'bfit_CurveDisplayNameListeners'))
                listener.displaynamechanged=matlab.ui.internal.createListener(i,hPropDisplayName,'PostSet',...
                bfitCallbackFunction(@lineDisplayNameChanged,fig));
                bfitAddProp(i,'bfit_CurveDisplayNameListeners');
                set(handle(i),'bfit_CurveDisplayNameListeners',listener);
            end

            hPropXDS=bfitFindProp(i,'XDataSource');
            if isempty(bfitFindProp(i,'bfit_CurveXDSListeners'))
                listener.XDataSourceChanged=matlab.ui.internal.createListener(i,hPropXDS,'PostSet',...
                bfitCallbackFunction(@lineXYDataSourceChanged,fig));
                bfitAddProp(i,'bfit_CurveXDSListeners');
                set(handle(i),'bfit_CurveXDSListeners',listener);
            end

            hPropYDS=bfitFindProp(i,'YDataSource');
            if isempty(bfitFindProp(i,'bfit_CurveYDSListeners'))
                listener.YDataSourceChanged=matlab.ui.internal.createListener(i,hPropYDS,'PostSet',...
                bfitCallbackFunction(@lineXYDataSourceChanged,fig));
                bfitAddProp(i,'bfit_CurveYDSListeners');
                set(handle(i),'bfit_CurveYDSListeners',listener);
            end
        end

        hPropXdata=bfitFindProp(i,'XData');
        isNotFunctionLine=~strcmpi(handle(i).Type,"functionline");
        if isempty(bfitFindProp(i,'bfit_CurveXDListeners'))&&isNotFunctionLine
            if~isempty(hPropXdata)
                setappdata(i,'CachedXData',i.XData);
            end
            listener.XDataChanged=matlab.ui.internal.createListener(i,hPropXdata,'PostSet',...
            bfitCallbackFunction(@lineXYZDataChanged,fig));
            bfitAddProp(i,'bfit_CurveXDListeners');
            set(handle(i),'bfit_CurveXDListeners',listener);
        end

        hPropYdata=bfitFindProp(i,'YData');
        if isempty(bfitFindProp(i,'bfit_CurveYDListeners'))&&isNotFunctionLine
            if~isempty(hPropYdata)
                setappdata(i,'CachedYData',i.YData);
            end
            listener.YDataChanged=matlab.ui.internal.createListener(i,hPropYdata,'PostSet',...
            bfitCallbackFunction(@lineXYZDataChanged,fig));
            bfitAddProp(i,'bfit_CurveYDListeners');
            set(handle(i),'bfit_CurveYDListeners',listener);
        end

        hPropZdata=bfitFindProp(i,'ZData');
        if isempty(bfitFindProp(i,'bfit_CurveZDListeners'))&&isNotFunctionLine
            if~isempty(hPropZdata)
                setappdata(i,'CachedZData',i.ZData);
            end
            listener.ZDataChanged=matlab.ui.internal.createListener(i,hPropZdata,'PostSet',...
            bfitCallbackFunction(@lineXYZDataChanged,fig));
            bfitAddProp(i,'bfit_CurveZDListeners');
            set(handle(i),'bfit_CurveZDListeners',listener);
        end

        addLineObjectDestroyedListener(i,fig);

    end



    axesL=findobj(fig,'Type','axes','-or','Type','legend');

    for i=axesL'
        if isempty(bfitFindProp(i,'bfit_AxesListeners'))
            if isequal(get(i,'Tag'),'legend')
                listeners.userDataChanged=matlab.ui.internal.createListener(i,bfitFindProp(i,'UserData'),'PostSet',...
                bfitCallbackFunction(@userDataChanged,fig));
            else
                listeners=addLineListeners(i,fig);
            end
            bfitAddProp(i,'bfit_AxesListeners');
            set(handle(i),'bfit_AxesListeners',listeners);
        end
    end

    function localAddChild(~,d,fig,listener)
        if isa(d.Child,'matlab.graphics.shape.internal.ScribeLayer')&&...
            strcmp(d.Child.Description_I,'middle')
            localAddRemoveObjectListeners(d.Child,fig,listener);
        end

        function listener=localAddRemoveObjectListeners(listenerObject,fig,listener)

            listener.childadd=matlab.ui.internal.createListener(listenerObject,'ObjectChildAdded',...
            bfitCallbackFunction(@figChildAdded,fig));

            listener.childremove=matlab.ui.internal.createListener(listenerObject,'ObjectChildRemoved',...
            bfitCallbackFunction(@figChildRemoved,fig));


            listener.figdelete=matlab.ui.internal.createListener(fig,'ObjectBeingDestroyed',@figDeleted);

            function addLineObjectDestroyedListener(hLine,fig)
                if isempty(bfitFindProp(hLine,'bfit_ChildDestroyedListeners'))
                    lineDeleted=matlab.ui.internal.createListener(handle(hLine),'ObjectBeingDestroyed',...
                    bfitCallbackFunction(@childDestroyed,fig));
                    bfitAddProp(hLine,'bfit_ChildDestroyedListeners');
                    set(handle(hLine),'bfit_ChildDestroyedListeners',lineDeleted);
                end


                function listeners=addLineListeners(ax,fig)

                    [listeners.lineAdded,listeners.lineRemoved]=addListenersForLinesAddedAndRemoved(ax,fig);
                    listeners.claPreReset=event.listener(ax,'ClaPreReset',@(es,ed)captureAxesState(es,ed,ax,fig));


                    function[lineAddedListener,lineRemovedListener]=addListenersForLinesAddedAndRemoved(obj,fig)
                        lineAddedListener=matlab.ui.internal.createListener(obj,'ChildAdded',...
                        bfitCallbackFunction(@axesChildAdded,fig));



                        lineRemovedListener=matlab.ui.internal.createListener(obj.ChildContainer,'ObjectChildRemoved',...
                        bfitCallbackFunction(@axesChildRemoved,fig));


                        function figBeforePasteCallback(~,~,fig)


                            setappdata(fig,'bfit_Pasting',1);


                            function figPasteDoneCallback(~,eventData,fig)







                                rmappdata(fig,'bfit_Pasting');

                                objsCreated=eventData.ObjectsCreated;

                                for i=1:length(objsCreated)
                                    if isa(objsCreated(i),'matlab.graphics.axis.Axes')
                                        axesAddedUpdate(objsCreated(i),fig);
                                    elseif isplotchild(objsCreated(i),2,true)||isplotchild(objsCreated(i),3,true)
                                        lineAddedUpdate(objsCreated(i),fig);
                                    end
                                end


                                function figDeleted(~,event)

                                    if~isempty(bfitFindProp(event.Source,'Basic_Fit_Resid_Figure'))
                                        fitfigtag=getappdata(event.Source,'Basic_Fit_Data_Figure_Tag');
                                        fitfig=bfitfindfitfigure(event.Source,fitfigtag);
                                        bf=get(handle(fitfig),'Basic_Fit_GUI_Object');
                                        if isempty(fitfig)||~ishghandle(fitfig)
                                            return
                                        end
                                        datahandle=double(getappdata(fitfig,'Basic_Fit_Current_Data'));
                                        if~isempty(bf)

                                            guistate=getappdata(datahandle,'Basic_Fit_Gui_State');
                                            guistate.plotresids=0;

                                            residinfo.figuretag=get(handle(fitfig),'Basic_Fit_Fig_Tag');
                                            residinfo.axes=[];
                                            residhandles=Inf(1,12);
                                            residtxtH=[];

                                            setgraphicappdata(datahandle,'Basic_Fit_ResidTxt_Handle',residtxtH);
                                            setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
                                            setgraphicappdata(datahandle,'Basic_Fit_Resid_Handles',residhandles);
                                            setappdata(datahandle,'Basic_Fit_Gui_State',guistate);

                                            basicfitupdategui(fitfig,datahandle)
                                        end
                                    else

                                        if~isempty(bfitFindProp(event.Source,'Data_Stats_GUI_Object'))
                                            ds=get(handle(event.Source),'Data_Stats_GUI_Object');
                                            if~isempty(ds)
                                                ds.closeDataStats;
                                            end
                                        end
                                        if~isempty(bfitFindProp(event.Source,'Basic_Fit_GUI_Object'))
                                            bf=get(handle(event.Source),'Basic_Fit_GUI_Object');
                                            if~isempty(bf)
                                                bf.closeBasicFit;
                                            end
                                        end

                                        datahandle=double(getappdata(event.Source,'Basic_Fit_Current_Data'));
                                        if~isempty(datahandle)
                                            residinfo=getappdata(datahandle,'Basic_Fit_Resid_Info');
                                            fig=ancestor(datahandle,'figure');
                                            if~isempty(residinfo)
                                                residfigure=bfitfindresidfigure(fig,residinfo.figuretag);
                                                if~isempty(residfigure)&&ishghandle(residfigure)&&...
                                                    ~isempty(bfitFindProp(residfigure,'Basic_Fit_Resid_Figure'))

                                                    delete(residfigure);
                                                end
                                            end
                                        end
                                    end


                                    function legendReady(~,~,fig,legH)



                                        fighandle=double(fig);
                                        datahandle=getappdata(fighandle,'Basic_Fit_Current_Data');

                                        if isempty(datahandle)
                                            datahandle=double(getappdata(fighandle,'Data_Stats_Current_Data'));
                                        end
                                        if~isempty(datahandle)
                                            axesH=ancestor(datahandle,'axes');
                                            bfitcreatelegend(axesH,0,[],fighandle,legH);
                                        end


                                        function captureAxesState(~,~,axesH,fig)




                                            lines=findall(axesH,'type','line','tag','');
                                            if~isempty(lines)
                                                if length(lines)==1
                                                    captureLegendStatus(fig);
                                                end
                                            end


                                            function captureLegendStatus(fig)
                                                legends=findall(fig,'tag','legend');
                                                if~isempty(legends)&&any(strcmp(get(legends,'BeingDeleted'),'off'))
                                                    setappdata(fig,'Bfit_Legend_Is_Showing',true);
                                                elseif isappdata(fig,'Bfit_Legend_Is_Showing')
                                                    rmappdata(fig,'Bfit_Legend_Is_Showing');
                                                end



                                                function figChildAdded(~,event,fig)




                                                    if isappdata(fig,'bfit_Pasting')
                                                        return;
                                                    end

                                                    if ishghandle(event.Child,'axes')||ishghandle(event.Child,'legend')
                                                        axesAddedUpdate(event.Child,fig)
                                                    end


                                                    function axesAddedUpdate(axesH,fig)


                                                        if~isequal(axesH.get('Tag'),'legend')&&...
                                                            isequal(axesH.get('HandleVisibility'),'on')

                                                            if isempty(findprop(axesH,'bfit_AxesListeners'))
                                                                listeners=addLineListeners(axesH,fig);

                                                                bfitAddProp(axesH,'bfit_AxesListeners');
                                                                set(axesH,'bfit_AxesListeners',listeners);
                                                            end

                                                            fighandle=double(fig);

                                                            axesList=findobj(fighandle,'Type','axes','-or','Type','legend');
                                                            if isempty(axesList)
                                                                axesCount=0;
                                                            else
                                                                taglines=get(axesList,'Tag');
                                                                notlegendind=~(strcmp('legend',taglines));
                                                                axesCount=length(axesList(notlegendind));
                                                            end
                                                            setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);

                                                            ch=get(double(axesH),'children');



                                                            for i=length(ch):-1:1
                                                                lineAddedUpdate(ch(i),fig);
                                                            end

                                                            if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))&&...
                                                                isappdata(fig,'Basic_Fit_Current_Data')&&...
                                                                ~isempty(getappdata(fig,'Basic_Fit_Current_Data'))
                                                                bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                    bf.enableBasicFitFromM;


                                                                    basicfitupdategui(double(fig),double(getappdata(fig,'Basic_Fit_Current_Data')));

                                                                end
                                                            end

                                                            sObj=settings;
                                                            if sObj.matlab.graphics.showlegacydatastatsapp.ActiveValue&&...
                                                                ~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))&&...
                                                                isappdata(fig,'Data_Stats_Current_Data')&&...
                                                                ~isempty(getappdata(fig,'Data_Stats_Current_Data'))
                                                                ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                if~isempty(ds)
                                                                    ds.enableDataStatsFromM;
                                                                end
                                                            end
                                                        elseif isequal(axesH.get('Tag'),'legend')
                                                            listeners.userDataChanged=matlab.ui.internal.createListener(axesH,bfitFindProp(axesH,'UserData'),'PostSet',bfitCallbackFunction(@userDataChanged,fig));

                                                            legendReady([],[],fig,axesH);
                                                            if isempty(findprop(axesH,'bfit_AxesListeners'))
                                                                bfitAddProp(axesH,'bfit_AxesListeners');
                                                            end
                                                            set(axesH,'bfit_AxesListeners',listeners);
                                                        end

                                                        captureLegendStatus(fig);


                                                        function figChildRemoved(~,event,fig)






                                                            if isequal(fig.get('BeingDeleted'),'on')
                                                                return;
                                                            end

                                                            isAxes=false;

                                                            if isa(event.Child,'matlab.graphics.axis.Axes')
                                                                isAxes=true;
                                                            end

                                                            if isAxes
                                                                axesH=double(event.Child);
                                                                fighandle=double(fig);

                                                                if isResidAxes(fighandle,axesH)

                                                                    fitfigtag=getappdata(fighandle,'Basic_Fit_Data_Figure_Tag');
                                                                    fighandle=bfitfindfitfigure(fighandle,fitfigtag);




                                                                    if isempty(fighandle)
                                                                        return;
                                                                    end


                                                                    datahandle=double(getappdata(fighandle,'Basic_Fit_Current_Data'));
                                                                    fitaxesH=ancestor(datahandle,'axes');
                                                                    if isempty(datahandle)
                                                                        return
                                                                    end

                                                                    residinfo=getappdata(datahandle,'Basic_Fit_Resid_Info');
                                                                    residfigure=bfitfindresidfigure(fighandle,residinfo.figuretag);

                                                                    guistate=getappdata(datahandle,'Basic_Fit_Gui_State');
                                                                    guistate.plotresids=0;


                                                                    if fighandle==residfigure

                                                                        axesHpositionProp=getappdata(datahandle,'Basic_Fit_Fits_Axes_Position_Prop');
                                                                        axesHposition=getappdata(datahandle,'Basic_Fit_Fits_Axes_Position');
                                                                        set(fitaxesH,axesHpositionProp,axesHposition);
                                                                    end


                                                                    residinfo.axes=[];
                                                                    residhandles=Inf(1,12);
                                                                    residtxtH=[];

                                                                    setgraphicappdata(datahandle,'Basic_Fit_ResidTxt_Handle',residtxtH);
                                                                    setappdata(datahandle,'Basic_Fit_Resid_Info',residinfo);
                                                                    setgraphicappdata(datahandle,'Basic_Fit_Resid_Handles',residhandles);
                                                                    setappdata(datahandle,'Basic_Fit_Gui_State',guistate);


                                                                    basicfitupdategui(fighandle,datahandle);

                                                                else

                                                                    axeshandles=double(getappdata(fighandle,'Basic_Fit_Axes_All'));
                                                                    datahandle=double(getappdata(fighandle,'Basic_Fit_Current_Data'));




                                                                    if~isempty(axeshandles)
                                                                        deleteindex=(axeshandles==axesH);
                                                                        axeshandles(deleteindex)=[];
                                                                    end
                                                                    axesCount=length(axeshandles);
                                                                    setgraphicappdata(fighandle,'Basic_Fit_Axes_All',axeshandles);
                                                                    setappdata(fighandle,'Basic_Fit_Fits_Axes_Count',axesCount);



                                                                    if~isempty(datahandle)
                                                                        basicfitupdategui(fighandle,datahandle);
                                                                    end
                                                                end
                                                            end


                                                            function retval=isResidAxes(fighandle,axesH)


                                                                retval=false;

                                                                if~isempty(bfitFindProp(fighandle,'Basic_Fit_Resid_Figure'))
                                                                    retval=true;
                                                                else
                                                                    datahandle=double(getappdata(fighandle,'Basic_Fit_Current_Data'));
                                                                    if~isempty(datahandle)
                                                                        residinfo=getappdata(datahandle,'Basic_Fit_Resid_Info');
                                                                        if~isempty(residinfo)&&isequal(residinfo.axes,axesH)
                                                                            retval=true;
                                                                        end
                                                                    end
                                                                end


                                                                function axesChildAdded(~,evt,fig)




                                                                    childAdded=evt.ChildNode;
                                                                    if~matlab.graphics.illustration.internal.islegendable(childAdded)
                                                                        return
                                                                    end
                                                                    lineAddedUpdate(childAdded,fig);
                                                                    axesH=ancestor(childAdded,'axes');





                                                                    lines=findall(axesH,'type','line','tag','','HandleVisibility','on');
                                                                    if~isempty(lines)
                                                                        if length(lines)==1&&lines(1)==childAdded

                                                                            if isappdata(fig,'Bfit_Legend_Is_Showing')
                                                                                legend(axesH,'show');
                                                                                rmappdata(fig,'Bfit_Legend_Is_Showing');
                                                                            end
                                                                        end
                                                                    end


                                                                    function lineAddedUpdate(line,fig,createLegend)


                                                                        if isequal(get(line,'Tag'),'_TMWZoomLines')
                                                                            return
                                                                        end


                                                                        if nargin<3||isempty(createLegend)
                                                                            createLegend=true;
                                                                        end


                                                                        if isappdata(fig,'bfit_Pasting')
                                                                            return;
                                                                        end


                                                                        parentaxes=ancestor(line,'axes');
                                                                        if~isempty(bfitFindProp(parentaxes,'Basic_Fit_Resid_Axes'))
                                                                            return;
                                                                        end
                                                                        if isequal(get(parentaxes,'Tag'),'legend')
                                                                            return;
                                                                        end


                                                                        if isappdata(double(line),'bfit')
                                                                            bfitclearappdata(line);
                                                                        end






                                                                        if isplotchild(line,3,true)
                                                                            if~isempty(get(line,'xdata'))&&~isempty(get(line,'ydata'))&&(~isprop(line,'zdata')||isempty(get(line,'zdata')))

                                                                                if isprop(line,'DisplayName')&&~isempty(get(line,'DisplayName'))
                                                                                    newtag=get(line,'DisplayName');
                                                                                else
                                                                                    newtag=get(line,'Tag');
                                                                                end
                                                                                if~isempty(newtag)
                                                                                    setappdata(double(line),'bfit_dataname',newtag);
                                                                                end
                                                                                [h,n]=bfitgetdata(fig,2);
                                                                                if isempty(h)
                                                                                    error(message('MATLAB:bfitlisten:NoData'));
                                                                                end


                                                                                if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))

                                                                                    x_str=[];
                                                                                    y_str=[];
                                                                                    xcheck=[];
                                                                                    ycheck=[];
                                                                                    dscurrentdata=double(getappdata(fig,'Data_Stats_Current_Data'));
                                                                                    if isempty(dscurrentdata)


                                                                                        dscurrentindex=1;
                                                                                        dsnewdataHandle=h{1};
                                                                                        [x_str,y_str,xcheck,ycheck]=bfitdatastatselectnew(fig,dsnewdataHandle);

                                                                                        setgraphicappdata(fig,'Data_Stats_Current_Data',dsnewdataHandle);
                                                                                    else

                                                                                        dscurrentindex=find([h{:}]==dscurrentdata);
                                                                                    end
                                                                                    if~isempty(dscurrentindex)

                                                                                        if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                            ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                                            if~isempty(ds)
                                                                                                ds.addData(h,n,dscurrentindex,x_str,y_str,xcheck,ycheck);
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end



                                                                                bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));
                                                                                if isempty(bfcurrentdata)


                                                                                    bfcurrentindex=1;
                                                                                    bfnewdataHandle=h{1};
                                                                                    [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                    currentfit,coeffresidstrings]=bfitselectnew(fig,bfnewdataHandle,createLegend);
                                                                                    setgraphicappdata(fig,'Basic_Fit_Current_Data',bfnewdataHandle);
                                                                                else

                                                                                    bfcurrentindex=find([h{:}]==bfcurrentdata);
                                                                                    axesCount=[];fitschecked=[];bfinfo=[];evalresultsstr=[];
                                                                                    evalresultsx=[];evalresultsy=[];currentfit=[];
                                                                                    sObj=settings;
                                                                                    if sObj.matlab.graphics.showlegacybasicfitapp.ActiveValue
                                                                                        coeffresidstrings=[];
                                                                                    else
                                                                                        coeffresidstrings=cell(1,12);
                                                                                    end
                                                                                end

                                                                                if~isempty(bfcurrentindex)

                                                                                    if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                                                                                        bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                                        if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                                            if isempty(axesCount)
                                                                                                axesCount=-1;
                                                                                            end
                                                                                            if isempty(currentfit)
                                                                                                currentfit=-1;
                                                                                            end
                                                                                            bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                            currentfit,coeffresidstrings);
                                                                                        end
                                                                                    end
                                                                                end



                                                                                hProp=bfitFindProp(line,'Tag');
                                                                                listener.tagchanged=matlab.ui.internal.createListener(line,hProp,'PostSet',bfitCallbackFunction(@lineTagChanged,fig));
                                                                                if isempty(bfitFindProp(line,'bfit_CurveListeners'))
                                                                                    bfitAddProp(line,'bfit_CurveListeners');
                                                                                end
                                                                                set(handle(line),'bfit_CurveListeners',listener);

                                                                                hPropDisplayName=bfitFindProp(line,'DisplayName');
                                                                                listener.displaynamechanged=matlab.ui.internal.createListener(line,hPropDisplayName,'PostSet',...
                                                                                bfitCallbackFunction(@lineDisplayNameChanged,fig));
                                                                                if isempty(bfitFindProp(line,'bfit_CurveDisplayNameListeners'))
                                                                                    bfitAddProp(line,'bfit_CurveDisplayNameListeners');
                                                                                end
                                                                                set(handle(line),'bfit_CurveDisplayNameListeners',listener);


                                                                                hPropXDS=bfitFindProp(line,'XDataSource');
                                                                                listener.XDataSourceChanged=matlab.ui.internal.createListener(line,hPropXDS,'PostSet',...
                                                                                bfitCallbackFunction(@lineXYDataSourceChanged,fig));
                                                                                if isempty(bfitFindProp(line,'bfit_CurveXDSListeners'))
                                                                                    bfitAddProp(line,'bfit_CurveXDSListeners');
                                                                                end
                                                                                set(handle(line),'bfit_CurveXDSListeners',listener);

                                                                                hPropYDS=bfitFindProp(line,'YDataSource');
                                                                                listener.YDataSourceChanged=matlab.ui.internal.createListener(line,hPropYDS,'PostSet',...
                                                                                bfitCallbackFunction(@lineXYDataSourceChanged,fig));
                                                                                if isempty(bfitFindProp(line,'bfit_CurveYDSListeners'))
                                                                                    bfitAddProp(line,'bfit_CurveYDSListeners');
                                                                                end
                                                                                set(handle(line),'bfit_CurveYDSListeners',listener);

                                                                                axesH=ancestor(line,'axes');


                                                                                resetlims(axesH,line);


                                                                                if createLegend
                                                                                    bfitcreatelegend(axesH);
                                                                                end

                                                                                addDataListeners(line,fig,listener);
                                                                            else










                                                                                sv=fig.getCanvas;
                                                                                postListener=event.listener(sv,'PostUpdate',@(es,ed)localNOOP(es,ed));
                                                                                postListener.Callback=@(es,ed)localAddDataListenersAndDeletePostUpdate(line,fig,struct,postListener);
                                                                                setappdata(fig,'PostUpdateListener',postListener);
                                                                            end
                                                                        end


                                                                        function localAddDataListenersAndDeletePostUpdate(line,fig,listener,postListener)


                                                                            addDataListeners(line,fig,listener);
                                                                            delete(postListener);





                                                                            event.AffectedObject=line;
                                                                            lineXYZDataChanged([],event,fig,false);

                                                                            function localNOOP(~,~)


                                                                                function addDataListeners(line,fig,listener)

                                                                                    if strcmpi(handle(line).Type,"functionline")
                                                                                        return
                                                                                    end
                                                                                    hProp=bfitFindProp(line,'XData');
                                                                                    listener.XDataChanged=matlab.ui.internal.createListener(line,hProp,'PostSet',...
                                                                                    bfitCallbackFunction(@lineXYZDataChanged,fig));
                                                                                    if isempty(bfitFindProp(line,'bfit_CurveXDListeners'))
                                                                                        bfitAddProp(line,'bfit_CurveXDListeners');
                                                                                    end
                                                                                    set(handle(line),'bfit_CurveXDListeners',listener);

                                                                                    hProp=bfitFindProp(line,'YData');
                                                                                    listener.YDataChanged=matlab.ui.internal.createListener(line,hProp,'PostSet',...
                                                                                    bfitCallbackFunction(@lineXYZDataChanged,fig));
                                                                                    if isempty(bfitFindProp(line,'bfit_CurveYDListeners'))
                                                                                        bfitAddProp(line,'bfit_CurveYDListeners');
                                                                                    end
                                                                                    set(handle(line),'bfit_CurveYDListeners',listener);

                                                                                    hProp=bfitFindProp(line,'ZData');
                                                                                    listener.ZDataChanged=matlab.ui.internal.createListener(line,hProp,'PostSet',...
                                                                                    bfitCallbackFunction(@lineXYZDataChanged,fig));
                                                                                    if isempty(bfitFindProp(line,'bfit_CurveZDListeners'))
                                                                                        bfitAddProp(line,'bfit_CurveZDListeners');
                                                                                    end
                                                                                    set(handle(line),'bfit_CurveZDListeners',listener);

                                                                                    addLineObjectDestroyedListener(line,fig);



                                                                                    function resetlims(axes,line)

                                                                                        if strcmp(get(axes,'xlimmode'),'manual')
                                                                                            x=double(get(line,'xdata'));
                                                                                            y=double(get(line,'ydata'));
                                                                                            xlim=get(axes,'xlim');
                                                                                            xlim(1)=min(xlim(1),min(x));
                                                                                            xlim(2)=max(xlim(2),max(x));
                                                                                            set(axes,'xlim',xlim);
                                                                                            ylim=get(axes,'ylim');
                                                                                            ylim(1)=min(ylim(1),min(y));
                                                                                            ylim(2)=max(ylim(2),max(y));
                                                                                            set(axes,'ylim',ylim);
                                                                                        end


                                                                                        function childDestroyed(hSrc,~,fig)








                                                                                            if isappdata(fig,'bfit_Pasting')
                                                                                                return;
                                                                                            end

                                                                                            if ishghandle(fig)&&isequal(get(fig,'BeingDeleted'),'on')
                                                                                                return;
                                                                                            end

                                                                                            axesH=ancestor(hSrc,'axes');

                                                                                            if isequal(get(axesH,'BeingDeleted'),'on')
                                                                                                return;
                                                                                            end

                                                                                            lineDeleteUpdate(hSrc,axesH,fig);



                                                                                            function axesChildRemoved(~,event,fig)







                                                                                                if isappdata(fig,'bfit_Pasting')
                                                                                                    return;
                                                                                                end

                                                                                                if ishghandle(fig)&&isequal(get(fig,'BeingDeleted'),'on')
                                                                                                    return;
                                                                                                end

                                                                                                axesH=ancestor(event.Child,'axes');

                                                                                                valid=ishghandle(event.Child);




                                                                                                if valid&&(isa(event.Child,'matlab.graphics.mixin.Chartable')||isa(event.Child,'matlab.graphics.mixin.DataProperties'))




                                                                                                    lineDeleteUpdate(event.Child,axesH,fig);
                                                                                                end


                                                                                                function lineDeleteUpdate(removedline,axesh,fig)



                                                                                                    if isappdata(fig,'bfit_Pasting')
                                                                                                        return;
                                                                                                    end

                                                                                                    appdata=getappdata(double(removedline),'bfit');

                                                                                                    if~isempty(appdata)
                                                                                                        switch appdata.type
                                                                                                        case{'data','data potential'}
                                                                                                            [h,n]=bfitgetdata(fig,3);





                                                                                                            h{end+1}=removedline;
                                                                                                            n{end+1}='';
                                                                                                            if isempty(h)
                                                                                                                error(message('MATLAB:bfitlisten:NoDataInFigure'));
                                                                                                            end

                                                                                                            dsdatahandles=double(getappdata(fig,'Data_Stats_Data_Handles'));
                                                                                                            bfdatahandles=double(getappdata(fig,'Basic_Fit_Data_Handles'));

                                                                                                            if~isempty(dsdatahandles)
                                                                                                                [dscurrentindex,h,n,x_str,y_str,xcheck,ycheck,xcolname,ycolname]=...
                                                                                                                datastatdeletedata(removedline,fig,h,n);
                                                                                                                if~isempty(dscurrentindex)
                                                                                                                    if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                                                        ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                                                                        if~isempty(ds)
                                                                                                                            ds.removeData(h,n,dscurrentindex,x_str,y_str,...
                                                                                                                            xcheck,ycheck,xcolname,ycolname);
                                                                                                                        end
                                                                                                                    end
                                                                                                                end

                                                                                                                dsdatahandles=double(getappdata(fig,'Data_Stats_Data_Handles'));
                                                                                                                dsdatahandles(removedline==dsdatahandles)=[];
                                                                                                                setgraphicappdata(fig,'Data_Stats_Data_Handles',dsdatahandles);
                                                                                                            end

                                                                                                            if~isempty(bfdatahandles)
                                                                                                                [bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                                                currentfit,coeffresidstrings]=basicfitdeletedata(handle(removedline),fig,h,n);
                                                                                                                if~isempty(bfcurrentindex)

                                                                                                                    if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                                                                                                                        bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                                                                        if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                                                                            if isempty(axesCount)
                                                                                                                                axesCount=-1;
                                                                                                                            end
                                                                                                                            if isempty(currentfit)
                                                                                                                                currentfit=-1;
                                                                                                                            end
                                                                                                                            bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                                                            currentfit,coeffresidstrings);
                                                                                                                        end
                                                                                                                    end
                                                                                                                end


                                                                                                                bfdatahandles=double(getappdata(fig,'Basic_Fit_Data_Handles'));
                                                                                                                bfdatahandles(removedline==bfdatahandles)=[];
                                                                                                                setgraphicappdata(fig,'Basic_Fit_Data_Handles',bfdatahandles);
                                                                                                            end


                                                                                                            alldatahandles=double(getappdata(fig,'Basic_Fit_Data_All'));
                                                                                                            alldatahandles(removedline==alldatahandles)=[];
                                                                                                            setgraphicappdata(fig,'Basic_Fit_Data_All',alldatahandles);

                                                                                                            bfitcreatelegend(axesh,true,removedline,fig);

                                                                                                        case{'stat x','stat y'}
                                                                                                            dscurrentdata=double(getappdata(fig,'Data_Stats_Current_Data'));
                                                                                                            if isempty(dscurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            ind=appdata.index;
                                                                                                            xvector=getappdata(double(dscurrentdata),'Data_Stats_X_Showing');
                                                                                                            yvector=getappdata(double(dscurrentdata),'Data_Stats_Y_Showing');
                                                                                                            if isequal(appdata.type,'stat x')
                                                                                                                xhandles=double(getappdata(double(dscurrentdata),'Data_Stats_X_Handles'));
                                                                                                                xvector(ind)=0;
                                                                                                                xhandles(ind)=Inf;
                                                                                                                setappdata(double(dscurrentdata),'Data_Stats_X_Showing',xvector);
                                                                                                                setgraphicappdata(double(dscurrentdata),'Data_Stats_X_Handles',xhandles);
                                                                                                            else
                                                                                                                yhandles=double(getappdata(double(dscurrentdata),'Data_Stats_Y_Handles'));
                                                                                                                yvector(ind)=0;
                                                                                                                yhandles(ind)=Inf;
                                                                                                                setappdata(double(dscurrentdata),'Data_Stats_Y_Showing',yvector);
                                                                                                                setgraphicappdata(double(dscurrentdata),'Data_Stats_Y_Handles',yhandles);
                                                                                                            end
                                                                                                            if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                                                ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                                                                if~isempty(ds)
                                                                                                                    ds.removeStatLine(xvector,yvector);
                                                                                                                end
                                                                                                            end
                                                                                                            bfitcreatelegend(axesh,true,removedline,fig);

                                                                                                        case{'fit'}
                                                                                                            bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));
                                                                                                            if isempty(bfcurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            ind=appdata.index;
                                                                                                            fitvector=getappdata(bfcurrentdata,'Basic_Fit_Showing');
                                                                                                            fithandles=double(getappdata(bfcurrentdata,'Basic_Fit_Handles'));
                                                                                                            fitvector(ind)=0;
                                                                                                            fithandles(ind)=Inf;
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_Showing',fitvector);
                                                                                                            setgraphicappdata(bfcurrentdata,'Basic_Fit_Handles',fithandles);

                                                                                                            guistate=getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
                                                                                                            residhandles=double(getappdata(bfcurrentdata,'Basic_Fit_Resid_Handles'));


                                                                                                            bfitlistenoff(fig)
                                                                                                            if guistate.plotresids
                                                                                                                residinfo=getappdata(bfcurrentdata,'Basic_Fit_Resid_Info');
                                                                                                                residfigure=bfitfindresidfigure(fig,residinfo.figuretag);

                                                                                                                bfitlistenoff(residfigure)
                                                                                                                if ishghandle(residhandles(ind))
                                                                                                                    delete(residhandles(ind));
                                                                                                                end
                                                                                                                residhandles(ind)=Inf;
                                                                                                                setgraphicappdata(double(bfcurrentdata),'Basic_Fit_Resid_Handles',residhandles);

                                                                                                                if guistate.showresid
                                                                                                                    bfitcheckshownormresiduals(guistate.showresid,bfcurrentdata)
                                                                                                                end

                                                                                                                if residfigure~=fig

                                                                                                                    bfitlistenon(residfigure)
                                                                                                                end
                                                                                                            end

                                                                                                            if guistate.equations
                                                                                                                if all(~isfinite(fithandles))
                                                                                                                    eqntxth=double(getappdata(double(bfcurrentdata),'Basic_Fit_EqnTxt_Handle'));
                                                                                                                    if ishghandle(eqntxth)
                                                                                                                        delete(eqntxth);
                                                                                                                    end
                                                                                                                    setappdata(double(bfcurrentdata),'Basic_Fit_EqnTxt_Handle',[]);
                                                                                                                    guistate.equations=0;
                                                                                                                else

                                                                                                                    bfitcheckshowequations(guistate.equations,bfcurrentdata,guistate.digits)
                                                                                                                end
                                                                                                            end


                                                                                                            currentfit=getappdata(double(bfcurrentdata),'Basic_Fit_NumResults_');
                                                                                                            if isequal(ind,currentfit)
                                                                                                                evalresults=getappdata(double(bfcurrentdata),'Basic_Fit_EvalResults');
                                                                                                                if guistate.plotresults
                                                                                                                    if ishghandle(evalresults.handle)
                                                                                                                        delete(evalresults.handle);
                                                                                                                    end
                                                                                                                end

                                                                                                                evalresults.string='';
                                                                                                                evalresults.x=[];
                                                                                                                evalresults.y=[];
                                                                                                                evalresults.handle=[];
                                                                                                                setappdata(double(bfcurrentdata),'Basic_Fit_EvalResults',evalresults);
                                                                                                                guistate.plotresults=0;
                                                                                                            end
                                                                                                            setappdata(double(bfcurrentdata),'Basic_Fit_Gui_State',guistate);

                                                                                                            basicfitupdategui(fig,bfcurrentdata)
                                                                                                            bfitcreatelegend(axesh,true,removedline,fig);
                                                                                                            bfitlistenon(fig)

                                                                                                        case{'eqntxt'}
                                                                                                            bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));
                                                                                                            if isempty(bfcurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            guistate=getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
                                                                                                            guistate.equations=0;
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_EqnTxt_Handle',[]);
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);

                                                                                                            basicfitupdategui(fig,bfcurrentdata)

                                                                                                        case{'residnrmtxt'}
                                                                                                            fitfigtag=getappdata(fig,'Basic_Fit_Data_Figure_Tag');
                                                                                                            fig=bfitfindfitfigure(fig,fitfigtag);
                                                                                                            bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));
                                                                                                            if isempty(bfcurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            guistate=getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
                                                                                                            guistate.showresid=0;
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_ResidTxt_Handle',[]);
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);

                                                                                                            basicfitupdategui(fig,bfcurrentdata)

                                                                                                        case{'evalresults'}
                                                                                                            bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));
                                                                                                            if isempty(bfcurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            evalresults=getappdata(bfcurrentdata,'Basic_Fit_EvalResults');
                                                                                                            guistate=getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
                                                                                                            guistate.plotresults=0;
                                                                                                            evalresults.handle=[];
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_EvalResults',evalresults);
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);

                                                                                                            basicfitupdategui(fig,bfcurrentdata)
                                                                                                            bfitcreatelegend(axesh,true,removedline,fig);

                                                                                                        case{'residual'}
                                                                                                            fitfigtag=getappdata(handle(fig),'Basic_Fit_Data_Figure_Tag');
                                                                                                            fig=bfitfindfitfigure(fig,fitfigtag);


                                                                                                            bfcurrentdata=double(getappdata(handle(fig),'Basic_Fit_Current_Data'));
                                                                                                            if isempty(bfcurrentdata)
                                                                                                                return;
                                                                                                            end
                                                                                                            residhandles=Inf(1,12);
                                                                                                            setgraphicappdata(bfcurrentdata,'Basic_Fit_Resid_Handles',residhandles);
                                                                                                            guistate=getappdata(bfcurrentdata,'Basic_Fit_Gui_State');
                                                                                                            guistate.plotresids=0;
                                                                                                            setappdata(bfcurrentdata,'Basic_Fit_Gui_State',guistate);
                                                                                                            bfitcheckplotresiduals(0,bfcurrentdata,guistate.plottype,~guistate.subplot,guistate.showresid)

                                                                                                            basicfitupdategui(fig,bfcurrentdata)
                                                                                                        otherwise
                                                                                                        end
                                                                                                    end



                                                                                                    function lineTagChanged(~,event,fig)




                                                                                                        if isappdata(fig,'bfit_Pasting')
                                                                                                            return;
                                                                                                        end

                                                                                                        axesH=ancestor(event.AffectedObject,'axes');

                                                                                                        if(~isprop(event.AffectedObject,'DisplayName')||...
                                                                                                            isempty(get(event.AffectedObject,'DisplayName'))&&...
                                                                                                            ~isempty(event.AffectedObject.Tag))

                                                                                                            setappdata(double(event.AffectedObject),'bfit_dataname',event.AffectedObject.Tag)
                                                                                                            updatedataselectors(fig);


                                                                                                            bfitcreatelegend(axesH);
                                                                                                        end


                                                                                                        function lineDisplayNameChanged(~,event,fig)

                                                                                                            setappdata(double(event.AffectedObject),'bfit_dataname',event.AffectedObject.DisplayName);
                                                                                                            updatedataselectors(fig);


                                                                                                            function lineXYDataSourceChanged(~,event,fig)
                                                                                                                changedline=double(event.AffectedObject);
                                                                                                                if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                                                    ds=get(fig,'Data_Stats_GUI_Object');
                                                                                                                    if~isempty(ds)&&isappdata(fig,'Data_Stats_Current_Data')&&...
                                                                                                                        double(getappdata(fig,'Data_Stats_Current_Data'))==changedline
                                                                                                                        [xcolname,ycolname]=bfitdatastatsgetcolnames(changedline);
                                                                                                                        ds.updateColumnNames(xcolname,ycolname);
                                                                                                                    end
                                                                                                                end


                                                                                                                function lineXYZDataChanged(~,event,fig,createLegend)



                                                                                                                    if isappdata(fig,'bfit_Pasting')
                                                                                                                        return;
                                                                                                                    end


                                                                                                                    if nargin<4||isempty(createLegend)
                                                                                                                        createLegend=true;
                                                                                                                    end

                                                                                                                    xd=get(event.AffectedObject,'XData');
                                                                                                                    yd=get(event.AffectedObject,'YData');


                                                                                                                    if isequal(yd,getappdata(event.AffectedObject,'CachedYData'))
                                                                                                                        return
                                                                                                                    end
                                                                                                                    setappdata(event.AffectedObject,'CachedYData',yd)
                                                                                                                    if isequal(xd,getappdata(event.AffectedObject,'CachedXData'))
                                                                                                                        return
                                                                                                                    end
                                                                                                                    setappdata(event.AffectedObject,'CachedXData',xd)

                                                                                                                    zd=[];
                                                                                                                    if isprop(event.AffectedObject,'ZData')

                                                                                                                        zd=get(event.AffectedObject,'ZData');
                                                                                                                        if isequal(zd,getappdata(event.AffectedObject,'CachedZData'))
                                                                                                                            return
                                                                                                                        end
                                                                                                                        setappdata(event.AffectedObject,'CachedZData',zd)
                                                                                                                    end

                                                                                                                    if length(xd)==length(yd)&&isempty(zd)
                                                                                                                        isGoodData=true;
                                                                                                                    else
                                                                                                                        isGoodData=false;
                                                                                                                    end

                                                                                                                    changedline=double(event.AffectedObject);

                                                                                                                    if isappdata(double(changedline),'bfit')
                                                                                                                        wasGoodData=true;
                                                                                                                    else
                                                                                                                        wasGoodData=false;
                                                                                                                    end

                                                                                                                    if wasGoodData&&hasFitsOrResults(changedline)
                                                                                                                        dataName=getappdata(double(changedline),'bfit_dataname');
                                                                                                                        msg=getString(message('MATLAB:graph2d:bfit:DataChangedFitsResultsDeleted',dataName));
                                                                                                                        dlgTitle=getString(message('MATLAB:graph2d:bfit:DataChanged'));
                                                                                                                        dlgh=warndlg(msg,dlgTitle);
                                                                                                                        setgraphicappdata(double(changedline),'Basic_Fit_Dialogbox_Handle',dlgh);
                                                                                                                    end

                                                                                                                    if isGoodData&&wasGoodData

                                                                                                                        gs=getappdata(double(changedline),'Basic_Fit_Gui_State');
                                                                                                                        if~isempty(gs)
                                                                                                                            if double(getappdata(fig,'Basic_Fit_Current_Data'))==double(changedline)
                                                                                                                                evalresults=getappdata(double(changedline),'Basic_Fit_EvalResults');
                                                                                                                                if~isempty(evalresults)&&~isempty(evalresults.y)
                                                                                                                                    bfitevalfitbutton(changedline,-1,evalresults.string,gs.plotresults,1);
                                                                                                                                end

                                                                                                                                numresults=getappdata(double(changedline),'Basic_Fit_NumResults_');
                                                                                                                                if~isempty(numresults)
                                                                                                                                    bfitcalcfit(handle(changedline),-1);
                                                                                                                                end

                                                                                                                                fitvector=getappdata(double(changedline),'Basic_Fit_Showing');

                                                                                                                                if any(fitvector)
                                                                                                                                    for i=find(fitvector==1)
                                                                                                                                        bfitcheckfitbox(false,handle(changedline),i-1,gs.equations,gs.digits,gs.plotresids,...
                                                                                                                                        gs.plottype,~gs.subplot,gs.showresid);
                                                                                                                                    end
                                                                                                                                end


                                                                                                                                if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                                                                                                                                    bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                                                                                    if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                                                                                        bf.dataModified;
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            else

                                                                                                                                bfitreinitbfitdata(changedline);
                                                                                                                            end

                                                                                                                            if gs.normalize
                                                                                                                                xdata=double(get(changedline,'xdata'));
                                                                                                                                normalized=[mean(xdata(~isnan(xdata)));std(xdata(~isnan(xdata)))];
                                                                                                                                setappdata(double(changedline),'Basic_Fit_Normalizers',normalized);
                                                                                                                            end
                                                                                                                            emptycell=cell(12,1);
                                                                                                                            setappdata(double(changedline),'Basic_Fit_Resids',emptycell);
                                                                                                                        end


                                                                                                                        if isappdata(fig,'Data_Stats_Current_Data')
                                                                                                                            guiUpdateNeeded=false;
                                                                                                                            if double(getappdata(fig,'Data_Stats_Current_Data'))==changedline
                                                                                                                                bfitdatastatremovelines(handle(fig),changedline);
                                                                                                                                guiUpdateNeeded=true;
                                                                                                                            end


                                                                                                                            ad=getappdata(double(changedline));
                                                                                                                            names=fieldnames(ad);
                                                                                                                            for i=1:length(names)
                                                                                                                                if strncmp(names{i},'Data_Stats_',11)
                                                                                                                                    rmappdata(double(changedline),names{i});
                                                                                                                                end
                                                                                                                            end

                                                                                                                            if guiUpdateNeeded
                                                                                                                                [x_str,y_str,~,~,xcolname,ycolname]=bfitdatastatselectnew(handle(fig),changedline);
                                                                                                                                if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                                                                    ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                                                                                    if~isempty(ds)
                                                                                                                                        ds.dataModified(x_str,y_str,xcolname,ycolname);
                                                                                                                                    end
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end
                                                                                                                        resetlims(ancestor(changedline,'axes'),changedline);
                                                                                                                    elseif isGoodData&&~wasGoodData
                                                                                                                        lineAddedUpdate(changedline,fig,createLegend);
                                                                                                                    elseif~isGoodData&&wasGoodData
                                                                                                                        axesh=ancestor(changedline,'axes');
                                                                                                                        lineDeleteUpdate(changedline,axesh,fig);

                                                                                                                        bfitclearappdata(changedline);
                                                                                                                        tempProp=bfitFindProp(changedline,'bfit_CurveListeners');
                                                                                                                        if~isempty(tempProp)
                                                                                                                            delete(tempProp);
                                                                                                                        end
                                                                                                                    end


                                                                                                                    function retVal=hasFitsOrResults(line)

                                                                                                                        retVal=false;

                                                                                                                        evalresults=getappdata(double(line),'Basic_Fit_EvalResults');
                                                                                                                        numresults=getappdata(double(line),'Basic_Fit_NumResults_');
                                                                                                                        fitvector=getappdata(double(line),'Basic_Fit_Showing');
                                                                                                                        datastatsx=getappdata(double(line),'Data_Stats_X_Showing');
                                                                                                                        datastatsy=getappdata(double(line),'Data_Stats_Y_Showing');

                                                                                                                        if(~isempty(evalresults)&&~isempty(evalresults.y))||...
                                                                                                                            ~isempty(numresults)||...
                                                                                                                            any(fitvector)||any(datastatsx)||any(datastatsy)
                                                                                                                            retVal=true;
                                                                                                                        end


                                                                                                                        function userDataChanged(~,event,fig)

                                                                                                                            if~isequal(get(event.AffectedObject,'Tag'),'legend')
                                                                                                                                return
                                                                                                                            end


                                                                                                                            if isappdata(fig,'bfit_Pasting')
                                                                                                                                return
                                                                                                                            end

                                                                                                                            ud=event.AffectedObject.UserData;


                                                                                                                            if~isfield(ud,'handles')||~isfield(ud,'lstrings')
                                                                                                                                return
                                                                                                                            end
                                                                                                                            datahandles=ud.handles;
                                                                                                                            datanames=ud.lstrings;
                                                                                                                            for j=1:min(length(datahandles),length(datanames))
                                                                                                                                d=datanames{j};

                                                                                                                                if~isequal(size(d,1),1)
                                                                                                                                    d=d';
                                                                                                                                    d=(d(:))';
                                                                                                                                end

                                                                                                                                if ishghandle(datahandles(j))
                                                                                                                                    setappdata(double(datahandles(j)),'bfit_dataname',d);
                                                                                                                                end
                                                                                                                            end

                                                                                                                            updatedataselectors(fig);


                                                                                                                            function updatedataselectors(fig)


                                                                                                                                [h,n]=bfitgetdata(fig,2);
                                                                                                                                if isempty(h)
                                                                                                                                    return;
                                                                                                                                end

                                                                                                                                bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));

                                                                                                                                if~isempty(bfcurrentdata)
                                                                                                                                    bfcurrentindex=find([h{:}]==bfcurrentdata);
                                                                                                                                    if~isempty(bfcurrentindex)

                                                                                                                                        if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                                                                                                                                            bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                                                                                            if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                                                                                                axesCount=[];fitschecked=[];bfinfo=[];evalresultsstr=[];
                                                                                                                                                evalresultsx=[];evalresultsy=[];currentfit=[];
                                                                                                                                                sObj=settings;
                                                                                                                                                if sObj.matlab.graphics.showlegacybasicfitapp.ActiveValue
                                                                                                                                                    coeffresidstrings=[];
                                                                                                                                                else
                                                                                                                                                    coeffresidstrings=cell(1,12);
                                                                                                                                                end

                                                                                                                                                if isempty(axesCount)
                                                                                                                                                    axesCount=-1;
                                                                                                                                                end
                                                                                                                                                if isempty(currentfit)
                                                                                                                                                    currentfit=-1;
                                                                                                                                                end

                                                                                                                                                bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                                                                                currentfit,coeffresidstrings);
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end

                                                                                                                                dscurrentdata=double(getappdata(fig,'Data_Stats_Current_Data'));
                                                                                                                                if~isempty(dscurrentdata)
                                                                                                                                    dscurrentindex=find([h{:}]==dscurrentdata);
                                                                                                                                    if~isempty(dscurrentindex)
                                                                                                                                        if~isempty(bfitFindProp(fig,'Data_Stats_GUI_Object'))
                                                                                                                                            ds=get(handle(fig),'Data_Stats_GUI_Object');
                                                                                                                                            if~isempty(ds)

                                                                                                                                                x_str=[];
                                                                                                                                                y_str=[];
                                                                                                                                                xcheck=[];
                                                                                                                                                ycheck=[];
                                                                                                                                                ds.addData(h,n,dscurrentindex,x_str,y_str,xcheck,ycheck);
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end


                                                                                                                                function basicfitupdategui(fig,bfcurrentdata)

                                                                                                                                    if~isempty(bfitFindProp(fig,'Basic_Fit_GUI_Object'))
                                                                                                                                        bf=get(handle(fig),'Basic_Fit_GUI_Object');
                                                                                                                                        if~isempty(bf)&&~bf.isBasicFitDialogClosed()
                                                                                                                                            [h,n]=bfitgetdata(fig,2);
                                                                                                                                            if~isempty(bfcurrentdata)
                                                                                                                                                [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings]=...
                                                                                                                                                bfitgetcurrentinfo(bfcurrentdata);
                                                                                                                                                bfcurrentindex=find([h{:}]==bfcurrentdata);
                                                                                                                                                if isempty(bfcurrentindex)
                                                                                                                                                    bfcurrentindex=0;
                                                                                                                                                end
                                                                                                                                            else


                                                                                                                                                bfcurrentindex=0;
                                                                                                                                                axesCount=[];
                                                                                                                                                currentfit=[];
                                                                                                                                                fitschecked=[];
                                                                                                                                                bfinfo=[];
                                                                                                                                                evalresultsstr=[];evalresultsx=[];
                                                                                                                                                evalresultsy=[];
                                                                                                                                                sObj=settings;
                                                                                                                                                if sObj.matlab.graphics.showlegacybasicfitapp.ActiveValue
                                                                                                                                                    coeffresidstrings=[];
                                                                                                                                                else
                                                                                                                                                    coeffresidstrings=cell(1,12);
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                            if isempty(axesCount)
                                                                                                                                                axesCount=-1;
                                                                                                                                            end
                                                                                                                                            if isempty(currentfit)
                                                                                                                                                currentfit=-1;
                                                                                                                                            end
                                                                                                                                            bf.changeData(h,n,bfcurrentindex,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                                                                            currentfit,coeffresidstrings);

                                                                                                                                        end
                                                                                                                                    end



                                                                                                                                    function[dscurrentindex,h,n,x_str,y_str,xcheck,ycheck,xcolname,ycolname]=...
                                                                                                                                        datastatdeletedata(deletedline,fig,h,n)



                                                                                                                                        x_str=[];
                                                                                                                                        y_str=[];
                                                                                                                                        xcheck=[];
                                                                                                                                        ycheck=[];
                                                                                                                                        xcolname='X';
                                                                                                                                        ycolname='Y';

                                                                                                                                        dscurrentdata=double(getappdata(fig,'Data_Stats_Current_Data'));




                                                                                                                                        [xstatsH,ystatsH]=bfitdatastatremovelines(fig,deletedline);


                                                                                                                                        if~isempty(xstatsH)

                                                                                                                                            setgraphicappdata(double(deletedline),'Data_Stats_X_Handles',xstatsH);
                                                                                                                                            setgraphicappdata(double(deletedline),'Data_Stats_Y_Handles',ystatsH);

                                                                                                                                            setappdata(double(deletedline),'Data_Stats_X_Showing',false(1,6));
                                                                                                                                            setappdata(double(deletedline),'Data_Stats_Y_Showing',false(1,6));
                                                                                                                                        end


                                                                                                                                        linetodelete=find([h{:}]==double(deletedline));
                                                                                                                                        h(linetodelete)=[];
                                                                                                                                        n(linetodelete)=[];

                                                                                                                                        if isempty(h)
                                                                                                                                            dscurrentindex=0;
                                                                                                                                            setappdata(fig,'Data_Stats_Current_Data',[]);
                                                                                                                                        else
                                                                                                                                            if isequal(dscurrentdata,double(deletedline))


                                                                                                                                                dscurrentindex=1;
                                                                                                                                                dsnewdataHandle=h{1};

                                                                                                                                                [x_str,y_str,xcheck,ycheck,xcolname,ycolname]=...
                                                                                                                                                bfitdatastatselectnew(fig,dsnewdataHandle);

                                                                                                                                                setgraphicappdata(fig,'Data_Stats_Current_Data',dsnewdataHandle);
                                                                                                                                            else

                                                                                                                                                dscurrentindex=find([h{:}]==dscurrentdata);
                                                                                                                                                if isempty(dscurrentindex)
                                                                                                                                                    error(message('MATLAB:bfitlisten:InconsistentState'))
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                        end


                                                                                                                                        function[bfcurrentindex,h,n,axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,...
                                                                                                                                            currentfit,coeffresidstrings]=basicfitdeletedata(deletedline,fig,h,n)

                                                                                                                                            axesCount=[];fitschecked=[];bfinfo=[];evalresultsstr=[];
                                                                                                                                            evalresultsx=[];evalresultsy=[];currentfit=[];
                                                                                                                                            sObj=settings;
                                                                                                                                            if sObj.matlab.graphics.showlegacybasicfitapp.ActiveValue
                                                                                                                                                coeffresidstrings=[];
                                                                                                                                            else
                                                                                                                                                coeffresidstrings=cell(1,12);
                                                                                                                                            end

                                                                                                                                            bfcurrentdata=double(getappdata(fig,'Basic_Fit_Current_Data'));

                                                                                                                                            [fithandles,residhandles,residinfo]=bfitremovelines(fig,deletedline);


                                                                                                                                            if~isempty(fithandles)

                                                                                                                                                setgraphicappdata(double(deletedline),'Basic_Fit_Handles',fithandles);
                                                                                                                                                setgraphicappdata(double(deletedline),'Basic_Fit_Resid_Handles',residhandles);
                                                                                                                                                setappdata(double(deletedline),'Basic_Fit_Resid_Info',residinfo);

                                                                                                                                                setappdata(double(deletedline),'Basic_Fit_Showing',false(1,12));
                                                                                                                                            end


                                                                                                                                            if~isempty(h)
                                                                                                                                                linetodelete=find([h{:}]==deletedline);
                                                                                                                                                h(linetodelete)=[];
                                                                                                                                                if~isempty(n)
                                                                                                                                                    n(linetodelete)=[];
                                                                                                                                                end
                                                                                                                                            end

                                                                                                                                            if isempty(h)
                                                                                                                                                bfcurrentindex=0;
                                                                                                                                                setappdata(fig,'Basic_Fit_Current_Data',[]);
                                                                                                                                            else
                                                                                                                                                if isequal(double(bfcurrentdata),double(deletedline))


                                                                                                                                                    bfcurrentindex=1;
                                                                                                                                                    bfnewdataHandle=h{1};

                                                                                                                                                    [axesCount,fitschecked,bfinfo,evalresultsstr,evalresultsx,evalresultsy,currentfit,coeffresidstrings]=...
                                                                                                                                                    bfitselectnew(fig,bfnewdataHandle);

                                                                                                                                                    setgraphicappdata(fig,'Basic_Fit_Current_Data',bfnewdataHandle);

                                                                                                                                                    if isempty(currentfit)
                                                                                                                                                        currentfit=-1;
                                                                                                                                                    end
                                                                                                                                                else

                                                                                                                                                    bfcurrentindex=find([h{:}]==bfcurrentdata);
                                                                                                                                                    if isempty(bfcurrentindex)
                                                                                                                                                        error(message('MATLAB:bfitlisten:InconsistentState'))
                                                                                                                                                    end
                                                                                                                                                end
                                                                                                                                            end
