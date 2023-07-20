classdef ReviewResultsDialog<images.internal.app.utilities.OkCancelDialog





    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=protected,Transient)

        Slice images.internal.app.segmenter.volume.display.Slice
        Slider images.internal.app.segmenter.volume.display.Slider
        Viewer orthosliceViewer
        Table matlab.ui.control.Table
        AdditionalTables cell
        MarkAsComplete matlab.ui.control.CheckBox
        SelectAll matlab.ui.control.CheckBox
        ViewerPanel matlab.ui.container.Panel

    end

    properties(GetAccess=public,SetAccess=protected)

        Selected(:,:)logical
        MarkComplete(1,1)logical=false;
        IndexMap(:,3)double

    end

    properties(Access=protected)

        BlockedImage(1,1)blockedImage
        BlockedLabels(1,1)blockedImage
        Volume(:,:,:,:)
        Labels(:,:,:)
Categories
Metrics
        FileNames(:,:)string
        Alpha(1,1)double
        ContrastLimits(:,:)double
        UseOriginalData(1,1)logical
        RedLimits(:,:)double
        GreenLimits(:,:)double
        BlueLimits(:,:)double
BlockMap
Colormap
        IsBlocked(1,1)logical

    end

    methods




        function self=ReviewResultsDialog(loc,bim,blabels,names,metrics,blockFileNames,alpha,cLim,useOriginalData,blockMap,r,g,b,cmap)

            self=self@images.internal.app.utilities.OkCancelDialog(loc,getString(message('images:segmenter:reviewDialogTitle')));

            self.IsBlocked=isa(bim,'blockedImage');

            if self.IsBlocked
                self.BlockedImage=bim;
                self.BlockedLabels=blabels;
            else
                self.Volume=bim;
                self.Labels=blabels;
            end

            self.Size=[1000,600];
            self.Categories=names;
            self.Metrics=metrics;
            self.FileNames=blockFileNames;
            self.Alpha=alpha;
            self.ContrastLimits=cLim;
            self.UseOriginalData=useOriginalData;
            self.RedLimits=r;
            self.GreenLimits=g;
            self.BlueLimits=b;
            self.BlockMap=blockMap;
            self.Colormap=cmap;

            create(self);

            self.Table.Selection=1;

            self.Table.Position=[1,1,self.Table.Parent.Position(3:4)];

            if numel(self.Categories)>1&&~isempty(self.Metrics)
                for idx=1:numel(self.AdditionalTables)
                    t=self.AdditionalTables{idx};
                    t.Position=[1,1,t.Parent.Position(3:4)];
                end
            end

        end




        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);

            if self.IsBlocked
                self.Ok.Text=getString(message('images:segmenter:acceptSelected'));
            else
                self.Ok.Text=getString(message('images:segmenter:acceptResults'));
            end
            set(self.Ok,'Position',[self.Size(1)-(2*self.ButtonSpace)-(3*self.ButtonSize(1)),self.ButtonSpace,(2*self.ButtonSize(1)),self.ButtonSize(2)]);
            set(self.Cancel,'Position',[self.Size(1)-self.ButtonSpace-self.ButtonSize(1),self.ButtonSpace,self.ButtonSize]);

            if self.IsBlocked
                addTable(self);
                addCheckBox(self);
                updateSliceViewer(self,1);
            else
                addVolumeTable(self);
                displayViewer(self,self.Volume,self.Labels);
                self.FigureHandle.Visible='on';
            end

        end

    end

    methods(Access=protected)


        function[vol,label]=readBlock(self,idx)

            idx=self.IndexMap(idx,:);

            label=getBlock(self.BlockedLabels,idx);

            if nnz(isnan(self.BlockMap))==4
                nanidx=[idx,1];
            else
                nanidx=idx;
            end

            idx=self.BlockMap;
            idx(isnan(idx))=nanidx;

            vol=getBlock(self.BlockedImage,idx);


            vol=images.internal.app.segmenter.volume.data.rescaleVolume(squeeze(vol),self.RedLimits,self.GreenLimits,self.BlueLimits);


        end


        function okClicked(self)

            if self.IsBlocked
                if any(self.Selected)
                    self.Canceled=false;
                    self.MarkComplete=self.MarkAsComplete.Value;
                    close(self);
                end
            else
                self.Selected=true;
                self.Canceled=false;
                close(self);
            end

        end


        function addTable(self)

            firstMetric='';

            if isfield(self.Metrics,'SmallestRegion')
                smallestRegion=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='SmallestRegion';
                title=getString(message('images:segmenter:smallestRegion'));
            end
            if isfield(self.Metrics,'LargestRegion')
                largestRegion=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='LargestRegion';
                title=getString(message('images:segmenter:largestRegion'));
            end
            if isfield(self.Metrics,'NumberOfRegions')
                numberOfRegions=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='NumberOfRegions';
                title=getString(message('images:segmenter:numRegions'));
            end
            if isfield(self.Metrics,'Dice')
                diceMetric=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='Dice';
                title=getString(message('images:segmenter:diceMetric'));
            end
            if isfield(self.Metrics,'BFScore')
                bfscoreMetric=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='BFScore';
                title=getString(message('images:segmenter:bfscoreMetric'));
            end
            if isfield(self.Metrics,'Jaccard')
                jaccardMetric=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='Jaccard';
                title=getString(message('images:segmenter:jaccardMetric'));
            end
            if isfield(self.Metrics,'VolumeFraction')
                volumeFraction=cell([numel(self.FileNames),numel(self.Categories)]);
                firstMetric='VolumeFraction';
                title=getString(message('images:segmenter:volumeFraction'));
            end
            if isfield(self.Metrics,'Custom')
                nMetrics=numel(self.Metrics(1).CustomName);
                customMetric=cell([numel(self.FileNames),numel(self.Categories)*nMetrics]);
                firstMetric='Custom';
                title=char(self.Metrics(1).CustomName(1));
            end

            if numel(self.Categories)>1&&~isempty(firstMetric)
                tabgp=uitabgroup('Parent',self.FigureHandle,'Position',[(self.Size(1)/2)+(self.ButtonSpace/2),self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1)/2-(1.5*self.ButtonSpace),self.Size(2)-(3*self.ButtonSpace)-self.ButtonSize(2)],...
                'SelectionChangedFcn',@(src,evt)changeSelectedTab(self,evt));
                tab1=uitab(tabgp,'Title',title);
                hParent=tab1;
            else
                hParent=uipanel('Parent',self.FigureHandle,'Position',[(self.Size(1)/2)+(self.ButtonSpace/2),self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1)/2-(1.5*self.ButtonSpace),self.Size(2)-(3*self.ButtonSpace)-self.ButtonSize(2)],...
                'BorderType','none');
            end



            drawnow;

            datacell=cell([numel(self.FileNames),2]);

            self.IndexMap=zeros([numel(self.FileNames),3]);

            for idx=1:numel(self.FileNames)
                datacell(idx,:)={true,char(self.FileNames(idx))};
                blockIndex=str2double(strsplit(self.FileNames(idx),'_'));
                self.IndexMap(idx,:)=blockIndex;
                if isfield(self.Metrics,'VolumeFraction')
                    volumeFraction(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).VolumeFraction';
                end
                if isfield(self.Metrics,'NumberOfRegions')
                    numberOfRegions(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).NumberOfRegions';
                end
                if isfield(self.Metrics,'LargestRegion')
                    largestRegion(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).LargestRegion';
                end
                if isfield(self.Metrics,'SmallestRegion')
                    smallestRegion(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).SmallestRegion';
                end
                if isfield(self.Metrics,'Jaccard')
                    jaccardMetric(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).Jaccard';
                end
                if isfield(self.Metrics,'BFScore')
                    bfscoreMetric(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).BFScore';
                end
                if isfield(self.Metrics,'Dice')
                    diceMetric(idx,:)=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).Dice';
                end
                if isfield(self.Metrics,'Custom')
                    customData=self.Metrics(blockIndex(1),blockIndex(2),blockIndex(3)).Custom;
                    customMetric(idx,:)=reshape(customData,[1,numel(customData)]);
                end
            end

            self.Selected=true([numel(self.FileNames),1]);

            if numel(self.Categories)>1
                colName=[{getString(message('images:segmenter:selected')),getString(message('images:segmenter:blockTitle'))},self.Categories'];
                dataBlank=datacell;

                if~isempty(firstMetric)
                    switch firstMetric
                    case 'Custom'
                        datacell=[datacell,customMetric(:,1:numel(self.Categories))];
                    case 'VolumeFraction'
                        datacell=[datacell,volumeFraction];
                    case 'Jaccard'
                        datacell=[datacell,jaccardMetric];
                    case 'Dice'
                        datacell=[datacell,diceMetric];
                    case 'BFScore'
                        datacell=[datacell,bfscoreMetric];
                    case 'NumberOfRegions'
                        datacell=[datacell,numberOfRegions];
                    case 'LargestRegion'
                        datacell=[datacell,largestRegion];
                    case 'SmallestRegion'
                        datacell=[datacell,smallestRegion];
                    end
                end
            else
                colName={getString(message('images:segmenter:selected')),getString(message('images:segmenter:blockTitle'))};

                if isfield(self.Metrics,'Custom')
                    colName=[colName,cellstr(self.Metrics(1).CustomName)];
                    datacell=[datacell,customMetric];
                end

                if isfield(self.Metrics,'VolumeFraction')
                    colName=[colName,{getString(message('images:segmenter:volumeFraction'))}];
                    datacell=[datacell,volumeFraction];
                end

                if isfield(self.Metrics,'Jaccard')
                    colName=[colName,{getString(message('images:segmenter:jaccardMetric'))}];
                    datacell=[datacell,jaccardMetric];
                end

                if isfield(self.Metrics,'BFScore')
                    colName=[colName,{getString(message('images:segmenter:bfscoreMetric'))}];
                    datacell=[datacell,bfscoreMetric];
                end

                if isfield(self.Metrics,'Dice')
                    colName=[colName,{getString(message('images:segmenter:diceMetric'))}];
                    datacell=[datacell,diceMetric];
                end

                if isfield(self.Metrics,'NumberOfRegions')
                    colName=[colName,{getString(message('images:segmenter:numRegions'))}];
                    datacell=[datacell,numberOfRegions];
                end

                if isfield(self.Metrics,'LargestRegion')
                    colName=[colName,{getString(message('images:segmenter:largestRegion'))}];
                    datacell=[datacell,largestRegion];
                end

                if isfield(self.Metrics,'SmallestRegion')
                    colName=[colName,{getString(message('images:segmenter:smallestRegion'))}];
                    datacell=[datacell,smallestRegion];
                end

            end
            if isempty(firstMetric)
                colFormat={'logical','char'};
                colEdit=false([1,2]);
            else
                colFormat=[{'logical','char'},repmat({'numeric'},[1,numel(self.Categories)])];
                colEdit=false([1,numel(self.Categories)+2]);
            end
            colEdit(1)=true;

            self.Table=uitable(...
            'Data',datacell,...
            'Tag','MetricTable',...
            'Parent',hParent,...
            'Position',[1,1,hParent.Position(3:4)],...
            'FontSize',12,...
            'Enable','on',...
            'ColumnName',colName,...
            'ColumnFormat',colFormat,...
            'RowName',{},...
            'Visible','on',...
            'SelectionType','row',...
            'RowStriping','on',...
            'ColumnSortable',true,...
            'ColumnWidth','auto',...
            'ColumnEditable',colEdit,...
            'CellEditCallback',@(src,evt)selectionChanged(self,evt),...
            'CellSelectionCallback',@(src,evt)selectRow(self,evt));

            if numel(self.Categories)>1

                if isfield(self.Metrics,'Custom')&&nMetrics>1
                    n=numel(self.Categories);
                    for idx=2:nMetrics
                        tab=uitab(tabgp,'Title',char(self.Metrics(1).CustomName(idx)));
                        addAdditionalTable(self,[dataBlank,customMetric(:,(n*(idx-1))+1:(n*(idx)))],tab,colName,colFormat,colEdit);
                    end
                end

                if isfield(self.Metrics,'VolumeFraction')&&~strcmp(firstMetric,'VolumeFraction')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:volumeFraction')));
                    addAdditionalTable(self,[dataBlank,volumeFraction],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'Jaccard')&&~strcmp(firstMetric,'Jaccard')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:jaccardMetric')));
                    addAdditionalTable(self,[dataBlank,jaccardMetric],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'BFScore')&&~strcmp(firstMetric,'BFScore')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:bfscoreMetric')));
                    addAdditionalTable(self,[dataBlank,bfscoreMetric],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'Dice')&&~strcmp(firstMetric,'Dice')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:diceMetric')));
                    addAdditionalTable(self,[dataBlank,diceMetric],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'NumberOfRegions')&&~strcmp(firstMetric,'NumberOfRegions')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:numRegions')));
                    addAdditionalTable(self,[dataBlank,numberOfRegions],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'LargestRegion')&&~strcmp(firstMetric,'LargestRegion')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:largestRegion')));
                    addAdditionalTable(self,[dataBlank,largestRegion],tab,colName,colFormat,colEdit);
                end

                if isfield(self.Metrics,'SmallestRegion')&&~strcmp(firstMetric,'SmallestRegion')
                    tab=uitab(tabgp,'Title',getString(message('images:segmenter:smallestRegion')));
                    addAdditionalTable(self,[dataBlank,smallestRegion],tab,colName,colFormat,colEdit);
                end

            end

        end


        function addAdditionalTable(self,data,hParent,colName,colFormat,colEdit)

            t=uitable(...
            'Data',data,...
            'Tag','MetricTable',...
            'Parent',hParent,...
            'Position',[1,1,hParent.Position(3:4)],...
            'FontSize',12,...
            'Enable','on',...
            'ColumnName',colName,...
            'ColumnFormat',colFormat,...
            'RowName',{},...
            'Visible','on',...
            'SelectionType','row',...
            'RowStriping','on',...
            'ColumnSortable',true,...
            'ColumnWidth','auto',...
            'ColumnEditable',colEdit,...
            'CellEditCallback',@(src,evt)selectionChanged(self,evt),...
            'CellSelectionCallback',@(src,evt)selectRow(self,evt));

            self.AdditionalTables{end+1}=t;

        end


        function addVolumeTable(self)

            firstMetric='';

            datacell=self.Categories';
            rowName={getString(message('images:segmenter:metrics'))};

            if isfield(self.Metrics,'Custom')
                firstMetric='Custom';
                datacell=[datacell;self.Metrics.Custom'];
                rowName=[rowName;cellstr(self.Metrics.CustomName)'];
            end
            if isfield(self.Metrics,'VolumeFraction')
                firstMetric='VolumeFraction';
                datacell=[datacell;self.Metrics.VolumeFraction'];
                rowName=[rowName;getString(message('images:segmenter:volumeFraction'))];
            end
            if isfield(self.Metrics,'Jaccard')
                firstMetric='Jaccard';
                datacell=[datacell;self.Metrics.Jaccard'];
                rowName=[rowName;getString(message('images:segmenter:jaccardMetric'))];
            end
            if isfield(self.Metrics,'BFScore')
                firstMetric='BFScore';
                datacell=[datacell;self.Metrics.BFScore'];
                rowName=[rowName;getString(message('images:segmenter:bfscoreMetric'))];
            end
            if isfield(self.Metrics,'Dice')
                firstMetric='Dice';
                datacell=[datacell;self.Metrics.Dice'];
                rowName=[rowName;getString(message('images:segmenter:diceMetric'))];
            end
            if isfield(self.Metrics,'NumberOfRegions')
                firstMetric='NumberOfRegions';
                datacell=[datacell;self.Metrics.NumberOfRegions'];
                rowName=[rowName;getString(message('images:segmenter:numRegions'))];
            end
            if isfield(self.Metrics,'LargestRegion')
                firstMetric='LargestRegion';
                datacell=[datacell;self.Metrics.LargestRegion'];
                rowName=[rowName;getString(message('images:segmenter:largestRegion'))];
            end
            if isfield(self.Metrics,'SmallestRegion')
                firstMetric='SmallestRegion';
                datacell=[datacell;self.Metrics.SmallestRegion'];
                rowName=[rowName;getString(message('images:segmenter:smallestRegion'))];
            end

            if~isempty(firstMetric)

                hParent=uipanel('Parent',self.FigureHandle,'Position',[(self.Size(1)/2)+(self.ButtonSpace/2),self.ButtonSize(2)+(2*self.ButtonSpace),self.Size(1)/2-(1.5*self.ButtonSpace),self.Size(2)-(3*self.ButtonSpace)-self.ButtonSize(2)],...
                'BorderType','none');



                drawnow;

                colFormat=repmat({'numeric'},[1,numel(self.Categories)]);
                colEdit=false([1,numel(self.Categories)]);

                self.Table=uitable(...
                'Data',datacell,...
                'Tag','MetricTable',...
                'Parent',hParent,...
                'Position',[1,1,hParent.Position(3:4)],...
                'FontSize',12,...
                'Enable','on',...
                'ColumnName',{},...
                'ColumnFormat',colFormat,...
                'RowName',rowName,...
                'Visible','on',...
                'SelectionType','row',...
                'RowStriping','on',...
                'ColumnSortable',true,...
                'ColumnWidth','auto',...
                'ColumnEditable',colEdit);

            end

            self.Selected=false;

        end


        function updateSliceViewer(self,idx)

            self.FigureHandle.Visible='on';

            dlg=uiprogressdlg(self.FigureHandle,'Title',getString(message('images:segmenter:waitForNextBlock')),...
            'Indeterminate','on');

            [vol,label]=readBlock(self,idx);

            displayViewer(self,vol,label);

            close(dlg);

        end

        function displayViewer(self,vol,label)

            if isempty(self.Viewer)

                if~self.IsBlocked&&isempty(self.Metrics)
                    pos=[1,self.ButtonSpace+self.ButtonSize(2),self.Size(1),self.Size(2)-self.ButtonSize(2)-(2*self.ButtonSpace)];
                else
                    pos=[1,self.ButtonSpace+self.ButtonSize(2),self.Size(1)/2,self.Size(2)-self.ButtonSize(2)-(2*self.ButtonSpace)];
                end

                self.ViewerPanel=uipanel('Parent',self.FigureHandle,...
                'Position',pos,...
                'BorderType','none');

                self.Viewer=orthosliceViewer(vol,'Parent',self.ViewerPanel,'DisplayRangeInteraction','off','CrosshairColor',[0.349,0.667,0.847]);
                self.Viewer.LabelColor=self.Colormap;
                self.Viewer.LabelOpacity=repmat(self.Alpha,[256,1]);

            end

            setData(self.Viewer,vol,label);

            [hXYAxes,hYZAxes,hXZAxes]=getAxesHandles(self.Viewer);
            set(hXYAxes,'Interactions',[]);
            set(hYZAxes,'Interactions',[]);
            set(hXZAxes,'Interactions',[]);
            set(hXYAxes.Toolbar,'Visible','off');
            set(hYZAxes.Toolbar,'Visible','off');
            set(hXZAxes.Toolbar,'Visible','off');

            drawnow;

        end


        function addCheckBox(self)

            self.MarkAsComplete=uicheckbox('Parent',self.FigureHandle,...
            'Position',[self.ButtonSpace,self.ButtonSpace,self.Size(1)/2-self.ButtonSpace,self.ButtonSize(2)],...
            'Value',false,...
            'Tag','MarkComplete',...
            'Text',getString(message('images:segmenter:markSelected')),...
            'FontSize',12);

            self.SelectAll=uicheckbox('Parent',self.FigureHandle,...
            'Position',[(self.Size(1)/2)+(self.ButtonSpace/2),self.ButtonSpace,self.Size(1)/2-(3*self.ButtonSpace)-(3*self.ButtonSize(1)),self.ButtonSize(2)],...
            'Value',true,...
            'Tag','SelectAll',...
            'ValueChangedFcn',@(src,evt)selectAll(self,evt.Value),...
            'Text',getString(message('images:segmenter:selectAll')),...
            'FontSize',12);

        end


        function selectRow(self,evt)

            if~isempty(evt.Source.Selection)
                if~isscalar(evt.Source.Selection)
                    evt.Source.Selection=evt.Source.Selection(1);
                end
            else
                removeCellFocus(self,evt.Source);
                evt.Source.Selection=1;
            end

            updateSliceViewer(self,evt.Source.Selection(1));

        end


        function removeCellFocus(~,obj)



            obj.SelectionType='cell';
            obj.SelectionType='row';

        end


        function selectionChanged(self,evt)

            self.Selected(evt.Indices(1))=evt.NewData;

            if all(self.Selected)
                self.SelectAll.Value=true;
            else
                self.SelectAll.Value=false;
            end

            if~any(self.Selected)
                self.Ok.Enable='off';
            else
                self.Ok.Enable='on';
            end

        end


        function selectAll(self,TF)

            self.Selected(:)=TF;

            self.Table.Data(:,1)=repmat({TF},size(self.Selected));

            if numel(self.Categories)>1
                for idx=1:numel(self.AdditionalTables)
                    t=self.AdditionalTables{idx};
                    t.Data(:,1)=repmat({TF},size(self.Selected));
                end
            end

            if~TF
                self.Ok.Enable='off';
            else
                self.Ok.Enable='on';
            end

        end


        function changeSelectedTab(self,evt)

            idx=evt.OldValue.Children(1).Selection;
            t=evt.NewValue.Children(1);

            t.Selection=idx(1);
            t.Data(:,1)=num2cell(self.Selected);

        end

    end

end
