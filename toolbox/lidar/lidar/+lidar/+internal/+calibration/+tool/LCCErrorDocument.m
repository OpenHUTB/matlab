classdef LCCErrorDocument<handle






    properties
        View;
        ErrorDocument;
        UigLayout;
        ErrorAxis;
        ErrorBar;
        ErrorSlider;
        MaxPosition;
        OutlierIdx;
        DirtyBit;
        ClickedBar=[];
        SelectedBar=[];
    end

    methods
        function this=LCCErrorDocument(View,title,tag,errorDocGroupTag)





            this.View=View;
            this.createDocument(title,tag,errorDocGroupTag);
            this.createAxis();
            this.clearDirtyBit();

        end

        function createDocument(this,title,tag,errorDocGroupTag)
            this.ErrorDocument=matlab.ui.internal.FigureDocument();
            this.ErrorDocument.DocumentGroupTag=errorDocGroupTag;
            this.ErrorDocument.Title=title;
            this.ErrorDocument.Tag=tag;
            this.ErrorDocument.Closable=false;
            this.ErrorDocument.Figure.AutoResizeChildren='off';
            this.ErrorDocument.Figure.Color=[1,1,1];
        end

        function removeDocument(this,appContainer)
            if appContainer.hasDocument(this.ErrorDocument.DocumentGroupTag,this.ErrorDocument.Tag)
                appContainer.closeDocument(this.ErrorDocument.DocumentGroupTag,this.ErrorDocument.Tag);
            end
        end

        function createAxis(this)
            this.UigLayout=uigridlayout(this.ErrorDocument.Figure,[1,1],...
            'Padding',[5,5,5,5]);
            this.ErrorAxis=uiaxes(this.UigLayout,'Box','on','Visible','on','Units','normalized','Position',[0,0,1,1]);
            this.ErrorAxis.Toolbar.Visible='off';
            disableDefaultInteractivity(this.ErrorAxis);
        end

        function plotError(this,ErrorData,labelText)
            rErrorData=real(ErrorData);
            this.ErrorBar=bar(this.ErrorAxis,rErrorData,0.4,'FaceColor','flat','EdgeColor','none');
            this.ErrorBar.CData=repmat([0.705,0.870,1],[size(this.ErrorBar.CData,1),1]);
            this.ErrorBar.Tag='errorBars';
            xlabel(this.ErrorAxis,string(message('lidar:lidarCameraCalibrator:ErrorXLabel')));
            ylabel(this.ErrorAxis,labelText);
            maxBar=max([this.ErrorBar.YData]);
            set(this.ErrorAxis,'YLim',[0,maxBar*1.2]);
            this.OutlierIdx=zeros(1,length(ErrorData));
            set(this.ErrorBar,'buttondownfcn',@(es,ev)this.onClickPlot(es,ev));
            this.ErrorAxis.Toolbar.Visible='off';
            disableDefaultInteractivity(this.ErrorAxis);
            addKeyPressListeners(this);
        end

        function onClickPlot(this,es,ev)
            this.onBarClicked(es,ev);
            this.setDirtyBit();
        end

        function onBarClicked(this,es,ev)

            xPoint=ev.IntersectionPoint(1);
            integPart=floor(xPoint);
            fracPart=xPoint-integPart;


            if fracPart>=0.8||fracPart<=0.2
                if fracPart>=0.8
                    idx=integPart+1;
                else
                    if fracPart<=0.2
                        idx=integPart;
                    end
                end
                lineState=getThresholdLineState(this.View);
                if isvalid(es.Parent.Parent.Parent)&&...
                    ~isempty(es.Parent.Parent.Parent.SelectionType)&&...
                    strcmp(es.Parent.Parent.Parent.SelectionType,'alt')
                    if~(isempty(lineState)||(lineState(3)&&lineState(6)&&lineState(9)))


                        return;
                    end
                    this.SelectedBar=[this.SelectedBar,idx];
                    highlightErrorBars(this.View,idx,1);
                    Highlight(this.View.DataBrowserAccepted,idx);
                else
                    this.View.DataBrowserAccepted.Panel.Figure.SelectionType='normal';
                    clickBar(this,idx);
                end
            end
        end

        function createSlider(this)
            this.MaxPosition=max([this.ErrorBar.YData])*1.1;


            this.ErrorSlider=vision.internal.calibration.tool.SelectionLine(...
            this.ErrorAxis,this.MaxPosition,0,this.MaxPosition);


            iptPointerManager(this.ErrorDocument.Figure);
            drawnow;
            enterFcn=@(lineobj,currentPoint)...
            set(lineobj,'Pointer','fleur');
            iptSetPointerBehavior(this.ErrorSlider.Group,enterFcn);


            registerCallback(this);
        end

        function registerCallback(this)

            set(this.ErrorSlider.Group,...
            'ButtonDownFcn',@(es,ev)doLineBtnDown(es,ev),...
            'BusyAction','cancel');

            function doLineBtnDown(es,~)

                set(es.Parent.Parent.Parent,...
                'windowbuttonmotionfcn',@(es,ev)this.doDragLine(es,ev),...
                'BusyAction','cancel');
                set(es.Parent.Parent.Parent,...
                'windowbuttonupfcn',@(es,ev)this.doDragDone(es,ev),...
                'BusyAction','cancel');
            end
        end

        function addKeyPressListeners(this)
            if isempty(this.ErrorDocument.Figure.WindowKeyPressFcn)
                this.ErrorDocument.Figure.WindowKeyPressFcn=@(src,hEvent)keyPressedFcn(this,src,hEvent);
            end
        end

        function keyPressedFcn(this,src,hEvent)
            lineState=getThresholdLineState(this.View);
            if numel(hEvent.Modifier)>1


                return;
            end
            if~(isempty(hEvent.Key)||any(strcmp({'delete','backspace'},hEvent.Key))||...
                isempty(lineState)||(lineState(3)&&lineState(6)&&lineState(9)))






                return
            end
            if~any(strcmp({'delete','backspace'},hEvent.Key))&&isempty(this.ClickedBar)



                return
            end
            idx=this.ClickedBar;


            if~isempty(hEvent.Modifier)&&...
                (any(strcmp(hEvent.Modifier,'control'))||...
                any(strcmp(hEvent.Modifier,'command')))
                if strcmp(hEvent.Key,'a')

                    this.SelectedBar=1:numel(this.ErrorBar.YData);
                    highlightErrorBars(this.View,this.SelectedBar,1);
                    Highlight(this.View.DataBrowserAccepted,this.SelectedBar);
                end
                return
            end

            len=length(this.SelectedBar);

            switch(hEvent.Key)
            case 'leftarrow'
                if~isempty(this.SelectedBar)
                    if len==length(this.ErrorBar.YData)
                        idx=1;
                    else
                        if this.SelectedBar(end)>1
                            idx=this.SelectedBar(end)-1;
                        else
                            idx=1;
                        end
                    end
                end
            case 'rightarrow'
                if~isempty(this.SelectedBar)
                    if this.SelectedBar(end)<length(this.ErrorBar.YData)
                        idx=this.SelectedBar(end)+1;
                    else
                        idx=length(this.ErrorBar.YData);
                    end
                end

            case{'delete','backspace'}
                dbTitle=string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgTitle'));
                dbMsg=string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgMsgDelBtn'));
                response=uiconfirm(this.View.AppContainer,...
                dbMsg,dbTitle,'Options',...
                [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                string(message('MATLAB:uistring:popupdialogs:No'))]);
                if strcmpi(response,string(message('MATLAB:uistring:popupdialogs:No')))
                    return
                else
                    dataBrowser=this.View.DataBrowserAccepted;
                    this.View.Outliers=false(1,numel(dataBrowser.Thumbnails));
                    this.View.Outliers(dataBrowser.HilightedIdx)=true;
                    es=dataBrowser.Thumbnails(dataBrowser.HilightedIdx(1)).CntxtMenu.Children;
                    dataBrowser.multipleDelete(es,1);
                end
                return;
            end


            if~isempty(hEvent.Modifier)&&strcmp(hEvent.Modifier,'shift')&&~ismember(hEvent.Modifier,hEvent.Key)
                temp=this.SelectedBar;
                if idx>this.ClickedBar
                    this.SelectedBar=this.ClickedBar:idx;
                else
                    this.SelectedBar=this.ClickedBar:-1:idx;
                end
                highlightErrorBars(this.View,this.SelectedBar,1);
                Highlight(this.View.DataBrowserAccepted,this.SelectedBar);

                sDiff=setdiff(temp,this.SelectedBar);
                if~isempty(sDiff)
                    highlightErrorBars(this.View,sDiff,0);
                    for thIdx=sDiff
                        resetThumbnail(this.View.DataBrowserAccepted.Thumbnails(thIdx))
                    end
                end
            else
                if isempty(hEvent.Modifier)&&any(strcmp({'rightarrow','leftarrow'},hEvent.Key))
                    clickBar(this,idx);
                end
            end
        end

        function clickBar(this,i)

            es=this.View.DataBrowserAccepted.Thumbnails(i).Himage;
            Scroll(this.View.DataBrowserAccepted,i);
            cbDataBrowserItemClicked(this.View,es,[],this.View.DataBrowserAccepted);
            this.ClickedBar=i;
            if isempty(this.SelectedBar)
                this.SelectedBar=i;
            end
        end

        function highlightBar(this,idx,tf)
            if tf
                c=[0.066,0.443,0.745];
            else
                c=[0.705,0.870,1];
            end
            for i=idx

                this.ErrorBar.FaceColor='flat';
                this.ErrorBar.CData(i,:)=c;
                this.setDirtyBit();
            end
        end

        function doDragLine(this,~,~)
            if this.View.TranslationError.DirtyBit
                this.View.TranslationError.resetState();
            end
            if this.View.RotationError.DirtyBit
                this.View.RotationError.resetState();
            end
            if this.View.ReprojectionError.DirtyBit
                this.View.ReprojectionError.resetState();
            end


            iptPointerManager(this.ErrorDocument.Figure,'disable');


            this.ErrorSlider.switchToLine();


            clicked=get(this.ErrorAxis,'currentpoint');


            ycoord=clicked(1,2,1);

            this.ErrorSlider.setSliderLocation(ycoord);
        end

        function doDragDone(this,es,~)

            set(es,'windowbuttonmotionfcn','')
            set(es,'windowbuttonupfcn','')


            iptPointerManager(this.ErrorDocument.Figure,'enable');


            [~,wasLine]=getState(this.ErrorSlider);
            if wasLine
                hline=findobj(es,'Tag','ThresholdLine');
                updateThreshold(this,hline.YData(1)-eps);
            end
        end

        function updateThreshold(this,val)
            this.OutlierIdx=[this.ErrorBar.YData]>=val;
            updateSelection(this.View,this.OutlierIdx,this);
        end

        function setDirtyBit(this)
            this.DirtyBit=true;
        end

        function clearDirtyBit(this)
            this.DirtyBit=false;
        end

        function resetErrorBars(this)
            this.ErrorBar.FaceColor='flat';
            for i=1:length(this.ErrorBar.YData)

                this.ErrorBar.CData(i,:)=[0.705,0.870,1];
            end
            this.ClickedBar=[];
            this.SelectedBar=[];
        end

        function resetSlider(this)
            if~isempty(this.ErrorSlider)
                this.ErrorSlider.reset();
            end
        end

        function resetOutliers(this)
            this.OutlierIdx=zeros(1,length(this.ErrorBar.XData));
        end

        function resetState(this)
            this.clearDirtyBit();
            this.resetOutliers();
            this.resetErrorBars();
            this.resetSlider();
        end
    end
end