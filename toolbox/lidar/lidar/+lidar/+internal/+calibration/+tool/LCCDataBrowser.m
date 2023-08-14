classdef LCCDataBrowser<matlab.ui.internal.databrowser.AbstractDataBrowser







    properties
        View;
        Model;
        UigLayout;
        Thumbnails;
        HilightedIdx;
        StartupTextArea;
        SelectedThumbnails;
        AnchorTh;
    end

    methods

        function this=LCCDataBrowser(View,Model,name,title,height)
            this=this@matlab.ui.internal.databrowser.AbstractDataBrowser(name,title);
            this.View=View;
            this.Model=Model;
            this.setPreferredWidth(0.18);
            this.setPreferredHeight(height);
            this.Thumbnails=lidar.internal.calibration.tool.DataThumbnail.empty;
            buildLayout(this);
        end

        function createStartupText(this)
            if~isempty(this.Thumbnails)
                return
            end
            if isempty(this.UigLayout)
                this.UigLayout=uigridlayout(this.Figure,[1,1]);
            end
            if ishandle(this.UigLayout.Children)&~isempty(this.UigLayout.Children)
                return
            end
            color=double(~this.UigLayout.BackgroundColor);
            this.UigLayout.Padding=[5,5,5,5];
            this.StartupTextArea=uilabel(this.UigLayout,'FontColor',color,'FontSize',14);
            this.StartupTextArea.Text=string(message('lidar:lidarCameraCalibrator:DataBrowserStartupText',...
            this.Model.getMinDataPairsForCalibration()));
            this.StartupTextArea.WordWrap='on';
            this.StartupTextArea.HorizontalAlignment='left';
            this.StartupTextArea.VerticalAlignment='top';
            toggleCollapse(this);
        end

        function setBgColor(this,color)
            this.Figure.Color=color;
            if(~isempty(this.UigLayout))
                this.UigLayout.BackgroundColor=color;
            end
        end

        function buildLayout(this)


            uig=uigridlayout(this.Figure,[1,1]);
            uig.Tag=strcat('uig',this.Name);


            uig.Scrollable='on';
            uig.Padding=[0,0,0,0];
            uig.RowSpacing=5;


            this.UigLayout=uig;

        end

        function populateDataBrowser(this,isAccepted)


            if~isempty(this.StartupTextArea)

                this.StartupTextArea.Parent=[];
                this.StartupTextArea=[];
                this.UigLayout.Padding=[0,0,0,0];
            end
            if~isempty(this.UigLayout.Children)

                removeAllThumbnails(this);
            end

            setBgColor(this,[0,0,0]);
            nDataPairs=this.Model.NumDatapairs;
            for i=1:nDataPairs
                this.UigLayout.RowHeight{i}="fit";
            end

            orgInd=find(isAccepted);
            for i=1:length(orgInd)
                this.Thumbnails(i)=lidar.internal.calibration.tool.DataThumbnail(...
                this,orgInd(i),i,...
                @(hSource,hEvent)cbDataBrowserItemClicked(this.View,hSource,hEvent,this));
                addCntxtMenu(this.Thumbnails(i));
            end
            this.toggleCollapse();

            addKeyPressListeners(this);
        end

        function newLoc=moveThumbnail(this,indToMove,toDataBrowser)

            thumbnailToMove=removeThumbnail(this,indToMove);

            newLoc=addThumbnail(toDataBrowser,thumbnailToMove);

            addCntxtMenu(toDataBrowser.Thumbnails(newLoc));
        end

        function thumbnailToMove=removeThumbnail(this,idx)

            thumbnailToMove=this.Thumbnails(idx);

            this.Thumbnails(idx)=[];

            [tf,loc]=ismember(idx,this.HilightedIdx);
            if tf
                this.HilightedIdx(loc)=[];
            end
        end

        function idx=addThumbnail(this,thumbnail)

            idx=length(this.Thumbnails)+1;
            for i=1:length(this.Thumbnails)
                temp=this.Thumbnails(i);
                if temp.OrgIndex<thumbnail.OrgIndex
                    continue;
                else
                    idx=i;
                    break;
                end
            end
            this.Thumbnails=[this.Thumbnails(1:idx-1),thumbnail,this.Thumbnails(idx:end)];


            this.UigLayout.RowHeight{idx}="fit";
            this.Thumbnails(idx).UigLayout.Parent=this.UigLayout;
            this.Thumbnails(idx).UigLayout.Layout.Row=this.Thumbnails(idx).OrgIndex;
            this.Thumbnails(idx).Parent=this;
            this.Thumbnails(idx).Himage.UserData=idx;
            this.Thumbnails(idx).Himage.ImageClickedFcn=@(hSource,hEvent)cbDataBrowserItemClicked(this.View,hSource,[],this);
            this.UigLayout.Scrollable='on';
        end

        function deleteThumbnail(this,idx)
            orgIndex=this.Thumbnails(idx).OrgIndex;
            removeDatapair(this.Model,orgIndex);
            updateOrgIndex(this,orgIndex);
            thumbnail=removeThumbnail(this,idx);
            thumbnail.UigLayout.Parent=[];

        end

        function multipleDelete(this,es,isCalibrationClicked)


            doProceed=false;
            outliers=find(this.View.Outliers);
            if any(outliers==es.UserData)

                if numel(this.Thumbnails)>=getMinDataPairsForCalibration(this.Model)&&...
                    numel(this.Thumbnails)-numel(outliers)<getMinDataPairsForCalibration(this.Model)
                    response=uiconfirm(this.View.AppContainer,...
                    string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgMsg',...
                    getMinDataPairsForCalibration(this.Model))),...
                    string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgTitle')),...
                    'Options',...
                    [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                    string(message('MATLAB:uistring:popupdialogs:No'))]);
                    if strcmpi(response,string(message('MATLAB:uistring:popupdialogs:No')))
                        return
                    else
                        doProceed=true;
                        isCalibrationClicked=false;
                    end
                end
                outliers=flip(outliers);
                for i=outliers
                    deleteThumbnail(this,i);
                end
            else




                n=numel(this.HilightedIdx);
                if strcmp(this.Name,string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')))&&...
                    numel(this.Thumbnails)>=getMinDataPairsForCalibration(this.Model)&&...
                    numel(this.Thumbnails)-n<getMinDataPairsForCalibration(this.Model)&&...
isCalibrationClicked
                    response=uiconfirm(this.View.AppContainer,...
                    string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgMsg',...
                    getMinDataPairsForCalibration(this.Model))),...
                    string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgTitle')),...
                    'Options',...
                    [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                    string(message('MATLAB:uistring:popupdialogs:No'))]);
                    if strcmpi(response,string(message('MATLAB:uistring:popupdialogs:No')))
                        return
                    else
                        doProceed=true;
                        isCalibrationClicked=false;
                    end
                end

                userdata=zeros(size(this.HilightedIdx));
                for j=1:numel(this.HilightedIdx)
                    userdata(j)=this.Thumbnails(this.HilightedIdx(j)).CntxtMenu.Children.UserData;
                end
                userdata=sort(userdata,'descend');
                for j=userdata
                    deleteThumbnail(this,j);
                end
            end
            if isCalibrationClicked
                doCalibration(this.Model);
            end
            if doProceed
                clearCalibrationResults(this.Model);
            end
            this.Figure.SelectionType='normal';
            update(this.View,this.Model);
            toggleCollapse(this);
        end

        function removeAllThumbnails(this)
            n=length(this.Thumbnails);
            for i=n:-1:1
                th=this.Thumbnails(i);
                th.UigLayout.Parent=[];
                delete(th);
                this.Thumbnails(i)=[];
            end
            toggleCollapse(this);
        end

        function makeThumbnailsVisible(this)
            for i=1:length(this.Thumbnails)
                this.Thumbnails(i).UigLayout.Visible='on';
            end
        end

        function updateLabels(this)


            for i=1:length(this.UigLayout.Children)
                updateLabelText(this.Thumbnails(i),i);
            end
        end

        function updateLayout(this)


            for i=1:numel(this.Thumbnails)
                this.Thumbnails(i).UigLayout.Layout.Row=this.Thumbnails(i).OrgIndex;
            end
        end

        function setContextMenuEnabledState(this,state)
            for i=1:numel(this.Thumbnails)
                this.Thumbnails(i).setContextMenuEnabledState(state);
            end
        end

        function updateOrgIndex(this,idx)


            h1=this.View.DataBrowserAccepted;
            h2=this.View.DataBrowserRejected;
            indToUpdate=[h1.Thumbnails.OrgIndex]>idx;
            values=num2cell([h1.Thumbnails(indToUpdate).OrgIndex]-1);
            [h1.Thumbnails(indToUpdate).OrgIndex]=values{:};

            indToUpdate=[h2.Thumbnails.OrgIndex]>idx;
            values=num2cell([h2.Thumbnails(indToUpdate).OrgIndex]-1);
            [h2.Thumbnails(indToUpdate).OrgIndex]=values{:};

            updateLayout(h1);
            updateLayout(h2);
        end

        function updateFigures(this,idx)
            orgIndex=this.Thumbnails(idx).OrgIndex;
            updateFigureInView(this.Model,this.View,orgIndex);
        end

        function updateCntxtMenu(this,isCalibrateClicked)
            if strcmp(this.Name,string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')))

                if isCalibrateClicked
                    for i=1:length(this.Thumbnails)
                        updateCntxtMenutoRemoveAndRecalibrate(this.Thumbnails(i),i);
                    end
                else
                    for i=1:length(this.Thumbnails)
                        updateCntxtMenutoRemove(this.Thumbnails(i),i);
                    end
                end
            else
                for i=1:length(this.Thumbnails)
                    updateCntxtMenutoRemove(this.Thumbnails(i),i);
                end
            end









        end

        function resetThumbnails(this)

            if~isempty(this.HilightedIdx)
                for i=this.HilightedIdx
                    if(i<=length(this.Thumbnails))
                        resetThumbnail(this.Thumbnails(i));
                    end
                end
            end
            this.HilightedIdx=[];
        end

        function Highlight(this,idx)

            color=[0.066,0.443,0.745];
            for i=idx
                this.Thumbnails(i).UigLayout.BackgroundColor=color;
                this.Thumbnails(i).Himage.BackgroundColor=color;



                if~ismember(this.Thumbnails(i).Himage.UserData,this.HilightedIdx)
                    this.HilightedIdx=...
                    [this.HilightedIdx,this.Thumbnails(i).Himage.UserData];
                end
            end
        end

        function toggleCollapse(this)
            if isempty(this.Thumbnails)&&~isempty(this.UigLayout)&&isempty(this.UigLayout.Children)
                this.Panel.Collapsed=true;
            else
                this.Panel.Collapsed=false;
            end
        end

        function Scroll(this,idx)
            if~isempty(this.UigLayout.Children)&&(idx<=length(this.Thumbnails))
                childPos=this.Thumbnails(idx).getPosition(idx);
                y=childPos(2);
                scroll(this.UigLayout,[1,y]);
            end
        end

        function addKeyPressListeners(this)
            if isempty(this.Figure.WindowKeyPressFcn)
                this.Panel.Figure.WindowKeyPressFcn=@(hSource,hEvent)keyPressedFcn(this,hSource,hEvent);
            end
        end

        function keyPressedFcn(this,hSource,hEvent)
            if isempty(this.Thumbnails)
                return
            end
            if numel(hEvent.Modifier)>1


                return;
            end
            this.SelectedThumbnails=[];


            if~isempty(hEvent.Modifier)&&...
                (any(strcmp(hEvent.Modifier,'control'))||...
                any(strcmp(hEvent.Modifier,'command')))

                if this.View.EditROIMode||this.View.SelectCheckerboardMode

                    return
                end
                if strcmp(hEvent.Key,'a')


                    this.SelectedThumbnails=1:numel(this.Thumbnails);
                    this.Highlight(this.SelectedThumbnails);
                    if strcmp(this.Name,string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')))
                        highlightErrorBars(this.View,this.SelectedThumbnails,1);
                    end
                end
                return
            end

            len=numel(this.HilightedIdx);
            if len>0
                currentSelection=this.HilightedIdx(len);
            else
                return;
            end
            newSelection=-1;
            switch(hEvent.Key)
            case 'uparrow'
                if currentSelection<=1||length(this.Thumbnails)==1

                    newSelection=1;
                else
                    newSelection=currentSelection-1;
                end
            case 'downarrow'
                if currentSelection>=length(this.Thumbnails)

                    newSelection=length(this.Thumbnails);
                else
                    newSelection=currentSelection+1;
                end
            case 'home'
                newSelection=1;
            case 'end'
                newSelection=length(this.Thumbnails);
            case 'pageup'
                childPos=this.Thumbnails(1).getPosition(1);
                drawnow;
                count=this.Figure.Position(4)/childPos(4);
                newSelection=this.HilightedIdx(len)-floor(count);
                if newSelection<1
                    newSelection=1;
                end
            case 'pagedown'
                childPos=this.Thumbnails(1).getPosition(1);
                drawnow;
                count=this.Figure.Position(4)/childPos(4);
                newSelection=this.HilightedIdx(len)+floor(count);
                if newSelection>numel(this.Thumbnails)
                    newSelection=numel(this.Thumbnails);
                end
            case{'delete','backspace'}
                if this.View.EditROIMode||this.View.SelectCheckerboardMode


                    return
                end
                isCalibrationClicked=this.Model.isCalibrationDone()&&strcmp(string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')),this.Name);
                if isCalibrationClicked
                    dbTitle=string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgTitle'));
                    dbMsg=string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateDlgMsgDelBtn'));
                else
                    dbTitle=string(message('lidar:lidarCameraCalibrator:RemoveDlgTitle'));
                    dbMsg=string(message('lidar:lidarCameraCalibrator:RemoveDlgMsgDelBtn'));
                end
                response=uiconfirm(this.View.AppContainer,...
                dbMsg,dbTitle,'Options',...
                [string(message('MATLAB:uistring:popupdialogs:Yes')),...
                string(message('MATLAB:uistring:popupdialogs:No'))]);
                if strcmpi(response,string(message('MATLAB:uistring:popupdialogs:No')))
                    return
                else
                    es=this.Thumbnails(this.HilightedIdx(1)).CntxtMenu.Children;
                    this.multipleDelete(es,isCalibrationClicked);
                end
            end

            if(newSelection==currentSelection)&&...
                (length(this.HilightedIdx)==1)


                return
            end



            if~isempty(hEvent.Modifier)&&strcmp(hEvent.Modifier,'shift')&&newSelection~=-1



                if newSelection>this.AnchorTh
                    this.SelectedThumbnails=this.AnchorTh:newSelection;
                else
                    this.SelectedThumbnails=this.AnchorTh:-1:newSelection;
                end

                sDiff=setdiff(this.HilightedIdx,this.SelectedThumbnails);
                if~isempty(sDiff)
                    for thIdx=sDiff
                        resetThumbnail(this.Thumbnails(thIdx));
                    end
                end
                this.Highlight(this.SelectedThumbnails);
                if strcmp(this.Name,string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')))
                    highlightErrorBars(this.View,this.SelectedThumbnails,1);
                    highlightErrorBars(this.View,sDiff,0);
                end
            end

            if newSelection~=-1&&isempty(this.SelectedThumbnails)
                this.Panel.Figure.SelectionType='normal';
                this.View.cbDataBrowserItemClicked(this.Thumbnails(newSelection).Himage,[],this);
                if~this.isInScrollableView(newSelection)
                    this.Scroll(newSelection);
                end
            end
        end

        function result=isInScrollableView(this,idx)



            containerPos=[this.UigLayout.ScrollableViewportLocation(:)',this.Figure.Position(3:4)];
            drawnow;
            childPos=this.Thumbnails(idx).getPosition(idx);
            result=this.doRectanglesIntersect(childPos,containerPos);
        end

        function flag=doRectanglesIntersect(this,childPos,containerPos)
            flag=true;
            childY1=childPos(2);
            childY2=childPos(2)-childPos(4);
            containerY1=containerPos(2);
            containerY2=containerPos(2)-containerPos(4);
            if~(childY1<containerY1&&childY1>containerY2&&childY2<containerY1&&childY2>containerY2)



                flag=false;
            end
        end
    end
end