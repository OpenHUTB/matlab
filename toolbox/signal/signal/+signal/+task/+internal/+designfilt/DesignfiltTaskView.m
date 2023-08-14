classdef DesignfiltTaskView<handle





    properties(Transient)





        UIFigure matlab.ui.Figure
MainGrid

ResponseSelectionAccordion
MainResponseAccordion
ViewFilterResponseAccordion


        ResponseSelectionAccordionPanel=[];


        ViewFilterResponseAccordionPanel=[];
MagAndPhaseButton
GroupDelayButton
PhaseDelayButton
ImpulseResponseButton
StepResponseButton
PZPlotButton
FilterInfoButton
        AnalysisButtonList=["MagAndPhaseButton","GroupDelayButton",...
        "PhaseDelayButton","ImpulseResponseButton","StepResponseButton",...
        "PZPlotButton","FilterInfoButton"]

ResponseViewChangedCallback

        ListenerList=[];
    end

    properties(Constant)
        GALLERY_ICON_SPACING=8;
        GALLERY_ICON_PADDING=5;
        GALLERY_BOTTOM_LINE_HEIGHT=2;

        RESPONSE_ICON_ROW_HEIGHT=50;
        RESPONSE_GALLERY_NUM_ROWS=2;
        RESPONSE_ICON_COLUMN_WIDTH=110;
        RESPONSE_MAX_COLS=4;

        ANALYSIS_ICON_ROW_HEIGHT=50;
        ANALYSIS_ICON_COLUMN_WIDTH=110;
        ANALYSIS_MAX_COLS=4;
    end

    properties(Access=private)



        pResponseViewsMap;
        pResponseViewAccordionsMap;


        pResponseSelectionButtonsMap;


        pResponseList;


        pIsVisualizeGalleryCollapsed=true;
    end

    methods
        function this=DesignfiltTaskView(responseViewChangedCallback,responseList)

            this.pResponseViewsMap=containers.Map;
            this.pResponseViewAccordionsMap=containers.Map;
            this.pResponseSelectionButtonsMap=containers.Map;

            this.pResponseList=responseList;

            this.ResponseViewChangedCallback=responseViewChangedCallback;


            createFigure(this);


            createMainGrid(this);



            addResponseSelectionGroup(this);






            addVisualizeFilterResponseGroup(this);


            setResponseSpecificAndVisualizeFilterControlsVisible(this,false);
        end

        function delete(this)
            deleteListeners(this);
        end

        function fig=getAppContainer(this)

            fig=this.UIFigure;
        end

        function setVisible(this,visibleFlag)

            this.UIFigure.Visible=visibleFlag;
drawnow
        end

        function setValueChangedCallback(this,widgetName,cbFcn)

            if ismember(widgetName,this.pResponseList)
                btn=this.pResponseSelectionButtonsMap(char(widgetName));
                btn.ValueChangedFcn=cbFcn;
            else
                this.(widgetName).ValueChangedFcn=cbFcn;
            end
        end

        function val=getResponse(this)
            val='select';
            responses=keys(this.pResponseSelectionButtonsMap);
            for idx=1:numel(responses)
                resp=responses{idx};
                btn=this.pResponseSelectionButtonsMap(resp);
                if btn.Value
                    val=resp;
                end
            end
        end

        function viewObj=getResponseViewObject(this,response)
            viewObj=[];
            if isKey(this.pResponseViewsMap,response)
                viewObj=this.pResponseViewsMap(response);
            end
        end

        function acc=getResponseViewAccordion(this,response)
            acc=[];
            if isKey(this.pResponseViewAccordionsMap,response)
                acc=this.pResponseViewAccordionsMap(response);
            end
        end

        function flag=isReadyForScript(this)
            resp=getResponse(this);
            viewObj=getResponseViewObject(this,resp);
            if isempty(viewObj)
                flag=false;
            else
                flag=isReadyForScript(viewObj);
            end
        end

        function reset(this)



            resetAnalysisButtonsValues(this);
        end

        function updateView(this,viewSettings,whatChanged,prevResponse,actResponse)

            if nargin<3

                whatChanged='';
            end
            switch whatChanged
            case 'response'
                viewObj=getResponseViewObject(this,actResponse);




                if strcmp(prevResponse,actResponse)&&~isempty(viewObj)&&...
                    isGroupsRendered(viewObj)
                    makeControlsVisibleFlag=...
                    updateGroups(this,actResponse,viewSettings);
                else

                    updateResponseButtons(this,actResponse);



                    addResponseObj(this,actResponse);

                    makeControlsVisibleFlag=...
                    updateGroups(this,actResponse,viewSettings);




                    updateCurrentResponseAccordion(this,prevResponse,actResponse);
                end
            otherwise
                makeControlsVisibleFlag=updateGroups(this,getResponse(this),viewSettings);
            end
            setResponseSpecificAndVisualizeFilterControlsVisible(this,makeControlsVisibleFlag)

            if isReadyForScript(this)
                enableAnalysisButtons(this,true);
            else
                enableAnalysisButtons(this,false);
            end
        end

        function resetAnalysisButtonsValues(this)
            for idx=1:numel(this.AnalysisButtonList)
                propName=this.AnalysisButtonList(idx);
                btn=this.(propName);
                if propName=="MagAndPhaseButton"
                    btn.Value=true;
                else
                    btn.Value=false;
                end
            end
        end

        function enableAnalysisButtons(this,enabFlag)
            for idx=1:numel(this.AnalysisButtonList)
                propName=this.AnalysisButtonList(idx);
                btn=this.(propName);
                btn.Enable=enabFlag;
            end
        end

        function updateViewFilterAnalysisControlsState(this,st)
            this.MagAndPhaseButton.Value=st.ViewMagAndPhase;
            this.GroupDelayButton.Value=st.ViewGroupDelay;
            this.PhaseDelayButton.Value=st.ViewPhaseDelay;
            this.ImpulseResponseButton.Value=st.ViewImpulseResponse;
            this.StepResponseButton.Value=st.ViewStepResponse;
            this.PZPlotButton.Value=st.ViewPZPlot;
            this.FilterInfoButton.Value=st.ViewFilterInfo;
        end

        function updateResponseButtons(this,newResponse)


            responses=keys(this.pResponseSelectionButtonsMap);
            for idx=1:numel(responses)
                resp=responses{idx};
                btn=this.pResponseSelectionButtonsMap(resp);
                btn.Value=strcmp(newResponse,resp);
            end
        end
    end




    methods(Access=protected)
        function fig=createFigure(this)

            import signal.task.internal.designfilt.msgid2txt

            fig=signal.task.internal.BaseTask.createFigureWindow(...
            msgid2txt('TaskTitle'),'designfilt');
            fig.Position=uiscopes.getDefaultPosition([600,750]);
            this.UIFigure=fig;
        end

        function createMainGrid(this)






            this.MainGrid=signal.task.internal.BaseTask.createMainGrid(...
            this.UIFigure,4,'designfilt');
            this.MainGrid.RowHeight={'fit','fit',0,0};
            this.MainGrid.RowSpacing=0;




            this.ResponseSelectionAccordion=...
            signal.task.internal.BaseTask.createAccordion(...
            this.MainGrid,'ResponseSelection');
            this.setLayout(this.ResponseSelectionAccordion,2,1);







            this.ViewFilterResponseAccordion=...
            signal.task.internal.BaseTask.createAccordion(...
            this.MainGrid,'ViewFilterResponse');
            this.setLayout(this.ViewFilterResponseAccordion,4,1);
        end

        function addResponseSelectionGroup(this)


            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt


            accordionPanel=BaseTask.createAccordionPanel(...
            this.ResponseSelectionAccordion,msgid2txt('ResponseHeader'),...
            'Response');
            this.ResponseSelectionAccordionPanel=accordionPanel;

            maxCols=this.RESPONSE_MAX_COLS;

            galleryWidth=maxCols*this.RESPONSE_ICON_COLUMN_WIDTH+...
            maxCols*this.GALLERY_ICON_SPACING+...
            (maxCols+1)*this.GALLERY_ICON_PADDING;

            galleryHeight=this.RESPONSE_GALLERY_NUM_ROWS*this.RESPONSE_ICON_ROW_HEIGHT+...
            this.RESPONSE_GALLERY_NUM_ROWS*10;




            mainGridContainer=uigridlayout(accordionPanel);
            mainGridContainer.Padding=[0,15,0,3];
            mainGridContainer.ColumnSpacing=0;
            mainGridContainer.RowSpacing=0;
            mainGridContainer.ColumnWidth={galleryWidth};

            mainGridContainer.RowHeight={galleryHeight+this.GALLERY_BOTTOM_LINE_HEIGHT};



            mainGrid=uigridlayout(mainGridContainer);
            mainGrid.Padding=[0,0,0,0];
            mainGrid.ColumnSpacing=0;
            mainGrid.RowSpacing=0;
            mainGrid.ColumnWidth={galleryWidth};
            mainGrid.RowHeight={galleryHeight,this.GALLERY_BOTTOM_LINE_HEIGHT-1};


            panel=uipanel(mainGrid);


            addBottomLine(this,mainGrid);



            responseSelectionGrid=uigridlayout(panel,'Scrollable','on');
            responseSelectionGrid.Padding=[0,0,0,0];
            responseSelectionGrid.ColumnSpacing=0;
            responseSelectionGrid.RowSpacing=0;
            responseSelectionGrid.ColumnWidth={'1x'};
            responseSelectionGrid.RowHeight={'fit'};

            numResponses=numel(this.pResponseList);

            responseIconsGrid=uigridlayout(responseSelectionGrid,...
            'ColumnSpacing',this.GALLERY_ICON_SPACING,'RowSpacing',...
            this.GALLERY_ICON_SPACING,'Tag','ResponseIconsGrid');
            responseIconsGrid.ColumnWidth=repmat({this.RESPONSE_ICON_COLUMN_WIDTH},maxCols,1);
            responseIconsGrid.RowHeight=num2cell(repmat(this.RESPONSE_ICON_ROW_HEIGHT,1,ceil(numResponses/maxCols)));
            padding=this.GALLERY_ICON_PADDING;
            responseIconsGrid.Padding=[padding,padding,padding,padding];

            iconsPath=fullfile(matlabroot,'toolbox','signal','signal','+signal','+task','+internal','+designfilt','icons');
            colNum=1;
            rowNum=1;
            for idx=1:numResponses
                resp=this.pResponseList(idx);
                if colNum>maxCols
                    rowNum=ceil(idx/maxCols);
                    colNum=1;
                end
                iconStr=strrep(resp,'fir','');
                iconStr=strrep(iconStr,'iir','');
                iconPath=fullfile(iconsPath,"designfiltLiveTask_"+string(iconStr)+"_60.png");
                btn=createStateButton(this,responseIconsGrid,msgid2txt(resp),...
                iconPath,resp,rowNum,colNum,resp);
                colNum=colNum+1;
                this.pResponseSelectionButtonsMap(char(resp))=btn;
            end
        end

        function addVisualizeFilterResponseGroup(this)


            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt



            accordionPanel=BaseTask.createAccordionPanel(...
            this.ViewFilterResponseAccordion,msgid2txt('DisplayResultsHeader'),...
            'DisplayResults');
            this.ViewFilterResponseAccordionPanel=accordionPanel;
            this.ViewFilterResponseAccordionPanel.CollapsedChangedFcn=@(~,~)this.updateVisualizeGalleryCollapsedFlag;

            maxCols=this.ANALYSIS_MAX_COLS;

            galleryWidth=maxCols*this.ANALYSIS_ICON_COLUMN_WIDTH+...
            maxCols*this.GALLERY_ICON_SPACING+...
            (maxCols+1)*this.GALLERY_ICON_PADDING;

            galleryHeight=this.ANALYSIS_ICON_ROW_HEIGHT+10;




            mainGridContainer=uigridlayout(accordionPanel);
            mainGridContainer.Padding=[0,0,0,0];
            mainGridContainer.ColumnSpacing=0;
            mainGridContainer.RowSpacing=0;
            mainGridContainer.ColumnWidth={galleryWidth};

            mainGridContainer.RowHeight={galleryHeight+this.GALLERY_BOTTOM_LINE_HEIGHT};




            mainGrid=uigridlayout(mainGridContainer);
            mainGrid.Padding=[0,0,0,0];
            mainGrid.ColumnSpacing=0;
            mainGrid.RowSpacing=0;
            mainGrid.ColumnWidth={galleryWidth};
            mainGrid.RowHeight={galleryHeight,this.GALLERY_BOTTOM_LINE_HEIGHT-1};


            panel=uipanel(mainGrid);


            addBottomLine(this,mainGrid);



            analysisGrid=uigridlayout(panel,'Scrollable','on');
            analysisGrid.Padding=[0,0,0,0];
            analysisGrid.ColumnSpacing=0;
            analysisGrid.RowSpacing=0;
            analysisGrid.ColumnWidth={'1x'};
            analysisGrid.RowHeight={'fit'};

            analyses=["MagAndPhase","GroupDelay","PhaseDelay",...
            "ImpulseResponse","StepResponse","PZPlot","FilterInfo"];
            numAnalyses=numel(analyses);
            maxCols=this.ANALYSIS_MAX_COLS;

            analysisIconGrid=uigridlayout(analysisGrid,...
            'ColumnSpacing',this.GALLERY_ICON_SPACING,'RowSpacing',...
            this.GALLERY_ICON_SPACING,'Tag','AnalysisIconsGrid');
            analysisIconGrid.ColumnWidth=repmat({this.ANALYSIS_ICON_COLUMN_WIDTH},maxCols,1);
            analysisIconGrid.RowHeight=num2cell(repmat(this.ANALYSIS_ICON_ROW_HEIGHT,1,ceil(numAnalyses/maxCols)));
            padding=this.GALLERY_ICON_PADDING;
            analysisIconGrid.Padding=[padding,padding,padding,padding];

            iconsPath=fullfile(matlabroot,'toolbox','signal','signal','+signal','+task','+internal','+designfilt','icons');
            icons={fullfile(iconsPath,'designfiltLiveTask_magphase_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_grpdelay_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_phasedelay_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_impulse_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_step_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_polezero_60.png');...
            fullfile(iconsPath,'designfiltLiveTask_info_60.png')};

            colNum=1;
            rowNum=1;
            for idx=1:numAnalyses
                if colNum>maxCols
                    rowNum=ceil(idx/maxCols);
                    colNum=1;
                end
                propName=analyses(idx)+"Button";
                btn=createStateButton(this,analysisIconGrid,...
                msgid2txt(analyses(idx)),icons{idx},analyses(idx),rowNum,colNum);

                colNum=colNum+1;
                this.(propName)=btn;
            end
            resetAnalysisButtonsValues(this);
        end

        function addResponseObj(this,response)

            if~strcmp(response,'select')
                if~isKey(this.pResponseViewsMap,response)

                    acc=signal.task.internal.BaseTask.createAccordion([],response);
                    acc.Visible='off';
                    this.pResponseViewAccordionsMap(response)=acc;

                    responseView=signal.task.internal.designfilt.responseViewFactory(response,acc);
                    addResponseViewListener(this,responseView);
                    this.pResponseViewsMap(response)=responseView;
                end
            end
        end

        function addResponseViewListener(this,responseViewObj)


            this.ListenerList=[this.ListenerList;...
            addlistener(responseViewObj,"responseViewChange",this.ResponseViewChangedCallback)];
        end

        function makeControlsVisibleFlag=updateGroups(this,response,viewSettings)


            viewObj=getResponseViewObject(this,response);
            if isempty(viewObj)


                makeControlsVisibleFlag=false;
                return;
            end



            updateGroups(viewObj,viewSettings);
            makeControlsVisibleFlag=true;
        end

        function setResponseSpecificAndVisualizeFilterControlsVisible(this,flag)


            if flag
                this.MainGrid.RowHeight(3:4)={'fit','fit'};
                this.ViewFilterResponseAccordionPanel.Collapsed=this.pIsVisualizeGalleryCollapsed;
            else
                this.MainGrid.RowHeight(3:4)={0,0};
            end
        end

        function updateCurrentResponseAccordion(this,prevResponse,actResponse)



            prevViewAcc=getResponseViewAccordion(this,prevResponse);
            if~isempty(prevViewAcc)
                prevViewAcc.Visible='off';
                prevViewAcc.Parent=[];
            end

            actViewAcc=getResponseViewAccordion(this,actResponse);
            if~isempty(actViewAcc)
                actViewAcc.Parent=this.MainGrid;
                this.setLayout(actViewAcc,3,1);
                actViewAcc.Visible='on';
            end
        end

        function deleteListeners(this)
            for idx=1:numel(this.ListenerList)
                delete(this.ListenerList(idx));
            end
            this.ListenerList=[];
        end

        function addBottomLine(this,grid)
            ax=uiaxes(grid,'YLimMode','manual',...
            'XLimMode','manual','Toolbar',[],'XTick',[],...
            'YTick',[],'Color',[0.94,0.94,0.94]);
            disableDefaultInteractivity(ax);

            yline(ax,0,'LineWidth',this.GALLERY_BOTTOM_LINE_HEIGHT,'Color',[0.7,0.7,0.7]);
        end

        function btn=createStateButton(~,parent,txt,iconPath,tag,row,col,userData)
            btn=uibutton(parent,'state',...
            'IconAlignment','top',...
            'Text',txt,...
            'FontSize',10,...
            'Icon',iconPath,...
            'Tag',string(tag)+"_Button");
            btn.Layout.Row=row;
            btn.Layout.Column=col;
            if nargin==8
                btn.UserData=userData;
            end
        end

        function updateVisualizeGalleryCollapsedFlag(this)
            this.pIsVisualizeGalleryCollapsed=~this.pIsVisualizeGalleryCollapsed;
        end
    end

    methods(Static,Hidden)
        function setLayout(widget,row,col)

            widget.Layout.Row=row;
            widget.Layout.Column=col;
        end
    end
end
