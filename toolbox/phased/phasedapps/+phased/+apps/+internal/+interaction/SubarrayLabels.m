classdef SubarrayLabels<handle&matlab.mixin.SetGet




    events

SubarrayNamesUpdated
    end


    properties(SetAccess=private,Transient)


SubarrayColorMatrix


        Current(1,1)double=2;


        DataInternal categorical=categorical.empty;


        MaxLabelsAllowed(1,1)double=255;


ColormapInternal


ColorOrder


BrushDataLogical


        UndoIndex=0


        RedoIndex=0


        LabelUpdateListener event.listener


AppHandle

    end


    properties(Constant,Hidden)

        Border=2;

        HeaderHeight=34;

        EntryHeight=24;

        ScrollBarWidth=5;

    end


    properties(SetAccess=private,Transient)

        Header matlab.ui.container.Panel

        Panel matlab.ui.container.Panel


AddButton


UndoButton


RedoButton


        Entries phased.apps.internal.interaction.Entry


        Key phased.apps.internal.interaction.Key


        ScrollBar phased.apps.internal.interaction.ScrollBar

    end
    properties(SetAccess=private,Dependent)


CurrentName


CurrentColor



NumberOfLabels



Names


    end


    methods




        function self=SubarrayLabels(AppHandle,pos)

            if AppHandle.IsSubarray
                hfig=AppHandle.SubarrayPartitionFig;
                self.AppHandle=AppHandle;
                createPanel(self,hfig,pos);
                createAddButton(self,pos,hfig);
                createScrollBar(self,hfig,pos);
                wireUpKey(self);
            end
        end



        function wireUpKey(self)

            self.Key=phased.apps.internal.interaction.Key(self.AppHandle,self.AppHandle.SubarrayPartitionFig);

        end




        function update(self,names,color)

            resetSelectedEntry=numel(names)~=numel(self.Entries);

            reorderRequired=false;

            for idx=1:numel(names)



                if idx>numel(self.Entries)
                    addArrayOfEntries(self,names{idx},color(idx,:));
                    reorderRequired=true;
                else
                    self.Entries(idx).Name=names{idx};
                    self.Entries(idx).Color=color(idx,:);
                    if strcmp(self.AppHandle.Container,'ToolGroup')
                        self.Entries(idx).NameUI.Enable='inactive';
                    end
                end

            end

            if numel(names)<numel(self.Entries)

                delete(self.Entries(idx+1:end));
                self.Entries(idx+1:end)=[];
                reorderRequired=true;

            end

            if reorderRequired

                pixelsUsed=self.EntryHeight*numel(self.Entries);
                figurePosition=get(ancestor(self.Panel,'figure'),'Position');
                pixelsAllowed=figurePosition(4)-self.HeaderHeight;

                pos=self.Panel.Position;

                if pixelsAllowed>pixelsUsed


                    pos(2)=pixelsAllowed-pixelsUsed+1;
                else

                    pos(2)=1;
                end

                reorderEntries(self,1);

                pos(4)=self.EntryHeight*(numel(self.Entries));

                self.Panel.Position=pos;

            end

            if resetSelectedEntry
                updateCurrentSelection(self,idx);
            end

            if~isempty(self.Entries)&&~isempty(self.ScrollBar)
                self.ScrollBar.Enabled=true;
                pos=self.Panel.Position;
                update(self.ScrollBar,[pos(2),pos(2)+pos(4)]);
            end

            if isequal(self.NumberOfLabels,1)
                self.Entries(self.NumberOfLabels).DeleteBtnUI.Enable='off';
            end
        end





        function scroll(self,scrollCount)



            pixelsUsed=self.EntryHeight*numel(self.Entries);
            figurePosition=get(ancestor(self.Panel,'figure'),'Position');
            pixelsAllowed=figurePosition(4)-self.HeaderHeight;
            pos=self.Panel.Position;

            if pixelsAllowed>pixelsUsed+1


                return;
            end

            if scrollCount>0
                val=moveDown(self,abs(scrollCount));
            else
                val=moveUp(self,abs(scrollCount),pixelsAllowed);
            end

            if val==0
                return;
            end

            pos(2)=pos(2)+val;
            self.Panel.Position=pos;

            if~isempty(self.Entries)
                update(self.ScrollBar,[pos(2),pos(2)+pos(4)]);
            end

        end




        function up(self)

            if self.Current>1

                updateCurrentSelection(self,self.Current-1);
                snapCurrentSelectionIntoView(self);

            end

        end




        function down(self)

            if self.Current<numel(self.Entries)

                updateCurrentSelection(self,self.Current+1);
                snapCurrentSelectionIntoView(self);
            end
            return;
        end




        function resize(self,pos)

            headerpos=pos;

            pos(4)=pos(4)-self.HeaderHeight;
            pos(3)=pos(3)-self.ScrollBarWidth;

            if any(pos<1)
                return;
            end

            headerpos(2)=headerpos(4)-self.HeaderHeight+1;
            headerpos(4)=self.HeaderHeight;

            self.Header.Position=headerpos;
            set(self.AddButton,'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)]);
            set(self.UndoButton,'Position',[self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)]);
            set(self.RedoButton,'Position',[2*self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)]);
            scrollbarPosition=[pos(3)+1,pos(2),self.ScrollBarWidth,pos(4)];
            resize(self.ScrollBar,scrollbarPosition);

            positionEntries(self,pos);
            if strcmp(self.AppHandle.Container,'ToolGroup')

                drawnow();
            end

            if~isempty(self.Entries)&&~isempty(self.ScrollBar)
                self.ScrollBar.Enabled=true;
                pos=self.Panel.Position;
                update(self.ScrollBar,[pos(2),pos(2)+pos(4)]);
            end
            resize(self.AppHandle.BannerMessage);
        end




        function clear(self)
            delete(self.Entries);
            delete(self.AddButton);
            delete(self.UndoButton);
            delete(self.RedoButton);
            self.Entries=phased.apps.internal.interaction.Entry.empty;
            clear(self.ScrollBar);
        end
    end


    methods


        function entryClicked(self,src)

            idx=find(self.Entries==src);

            if~isempty(idx)
                updateCurrentSelection(self,idx);
            end

        end



        function entryRemoved(self,evt)
            removeLabel(self,evt.Label)
        end


        function addArrayOfEntries(self,name,color)



            newEntry=phased.apps.internal.interaction.Entry(self.Panel,self.AppHandle,getNextLocation(self),name,color);

            addlistener(newEntry,'EntryClicked',@(src,evt)entryClicked(self,src));
            addlistener(newEntry,'EntryRemoved',@(src,evt)entryRemoved(self,evt));

            self.Entries=[self.Entries;newEntry];

        end


        function y=getNextLocation(self)

            pixelsUsed=self.EntryHeight*numel(self.Entries);
            figurePosition=get(ancestor(self.Panel,'figure'),'Position');
            pixelsAllowed=figurePosition(4)-self.HeaderHeight;

            pos=self.Panel.Position;

            if pixelsAllowed>pixelsUsed+self.EntryHeight


                pos(2)=pixelsAllowed-pixelsUsed-self.EntryHeight+1;
            else

                pos(2)=1;
            end

            reorderEntries(self,self.EntryHeight+1);

            pos(4)=self.EntryHeight*(numel(self.Entries)+1);
            y=1;

            self.Panel.Position=pos;

        end


        function reorderEntries(self,y)

            for idx=numel(self.Entries):-1:1
                self.Entries(idx).Y=y;
                y=y+self.EntryHeight;
            end

        end


        function positionEntries(self,pos)

            pixelsUsed=self.EntryHeight*numel(self.Entries);
            pixelsAllowed=pos(4);

            pos(2)=pixelsAllowed-pixelsUsed+1;
            pos(4)=self.EntryHeight*numel(self.Entries);


            self.Panel.Position=pos;

            set(self.Entries,'Width',pos(3));

            if~isempty(self.Entries)
                update(self.ScrollBar,[pos(2),pos(2)+pos(4)]);
            end

        end


        function val=moveUp(self,mag,pixelsAllowed)

            pos=self.Panel.Position;

            y=pos(2)+pos(4);

            if y<=pixelsAllowed+1



                val=0;
            elseif y<=pixelsAllowed+(mag*self.EntryHeight)+1
                val=pixelsAllowed+1-y;

            else
                val=-(mag*self.EntryHeight);
            end
        end


        function val=moveDown(self,mag)


            y=self.Panel.Position(2);

            if y>=1

                val=0;
            elseif y>=1-(mag*self.EntryHeight)


                val=1-y;
            else
                val=(mag*self.EntryHeight);
            end
        end


        function snapCurrentSelectionIntoView(self)

            pixelsUsed=self.EntryHeight*numel(self.Entries);
            figurePosition=get(ancestor(self.Panel,'figure'),'Position');
            pixelsAllowed=figurePosition(4)-self.HeaderHeight;
            pos=self.Panel.Position;

            if pixelsAllowed>pixelsUsed+1


                return;
            end

            entry=self.Entries(self.Current);

            y=entry.Y+pos(2);

            if y>=1&&y<=pixelsAllowed-self.EntryHeight+1


                return;
            end




            if self.Current==1&&y<=pixelsAllowed-self.EntryHeight+2
                return;
            end

            if self.Current==numel(self.Entries)&&y>1
                return;
            end

            if y<1


                val=1-y;
            else


                val=(pixelsAllowed-self.EntryHeight+1)-y;
            end

            if val==0
                return;
            end

            pos(2)=pos(2)+val;
            self.Panel.Position=pos;

            if~isempty(self.Entries)
                update(self.ScrollBar,[pos(2),pos(2)+pos(4)]);
            end

        end



        function updateCurrentSelection(self,idx)

            if self.Current~=idx
                if self.Current>0&&self.Current<=numel(self.Entries)
                    self.Entries(self.Current).Selected=false;
                    if strcmp(self.AppHandle.Container,'ToolGroup')
                        self.Entries(self.Current).NameUI.Enable='inactive';
                    end
                end
                self.Current=idx;

                self.Entries(self.Current).Selected=true;
                if strcmp(self.AppHandle.Container,'ToolGroup')
                    self.Entries(idx).NameUI.Enable='inactive';
                end
            else
                self.Entries(self.Current).Selected=true;
            end
            brushSelectionUpdate(self);
        end


        function createColorMap(self)

            if isempty(self.ColorOrder)
                self.ColorOrder=[...
                perms([0,0.25,0.5]);...
                perms([0,0.25,0.75]);...
                perms([0,0.5,0.75]);...
                perms([0.25,0.5,0.75]);...
                perms([0.25,0.5,1]);...
                perms([0.25,0.75,1]);...
                perms([0.5,0.75,1])];
                rs=rng(6);
                self.ColorOrder=self.ColorOrder(randperm(size(self.ColorOrder,1)),:);
                rng(rs);
                self.ColorOrder=[get(0,'DefaultAxesColorOrder');self.ColorOrder];
            end
            defaultPosRGB=[0.04,0.51,0.78];
            NumSubArrays=255;
            self.ColormapInternal=repmat(defaultPosRGB,...
            NumSubArrays,1);
            Showsubarray=1:NumSubArrays;
            if~isempty(Showsubarray)
                for s=1:length(Showsubarray)
                    ColorOrderIdx=mod(s-1,length(self.ColorOrder))+1;
                    subarray_idx=Showsubarray(s);
                    self.ColormapInternal(subarray_idx,:)=...
                    repmat(self.ColorOrder(ColorOrderIdx,:),1,1);
                end

            end

        end


        function createPanel(self,hfig,pos)

            pos(4)=pos(4)-self.HeaderHeight;
            pos(3)=pos(3)-self.ScrollBarWidth;

            self.Panel=uipanel('Parent',hfig,...
            'AutoResizeChildren','off',...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','EntryPanel');

        end


        function createScrollBar(self,hfig,pos)

            scrollbarPosition=[pos(3)+1,pos(2),self.ScrollBarWidth,pos(4)];

            self.ScrollBar=phased.apps.internal.interaction.ScrollBar(hfig,scrollbarPosition);

        end


        function createAddButton(self,pos,hfig)

            pos(2)=pos(4)-self.HeaderHeight+1;
            pos(4)=self.HeaderHeight;

            createColorMap(self)

            self.LabelUpdateListener=event.listener(self,'SubarrayNamesUpdated',@(src,evt)labelNamesUpdated(self,...
            evt.Names,...
            evt.Colormap));

            self.Header=uipanel('Parent',hfig,...
            'AutoResizeChildren','off',...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Tag','HeaderPanel');


            addIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Add_24.png');
            if strcmp(self.AppHandle.Container,'ToolGroup')
                addIcon=double(imread(addIcon))/255;
                addIcon(addIcon==0)=NaN;
                self.AddButton=uicontrol('Style','pushbutton',...
                'Parent',self.Header,...
                'Units','pixels',...
                'Enable','on',...
                'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'CData',addIcon,...
                'Tag','subarrayaddbutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayaddTT')),...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)labelAdd(self));
            else
                self.AddButton=uibutton('Parent',self.Header,...
                'Text','',...
                'Enable','on',...
                'Position',[self.Border+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'Icon',addIcon,...
                'Tag','subarrayaddbutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayaddTT')),...
                'HorizontalAlignment','left',...
                'ButtonPushedFcn',@(~,~)labelAdd(self));
            end


            undoIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Undo_24.png');
            if strcmp(self.AppHandle.Container,'ToolGroup')
                undoIcon=double(imread(undoIcon))/255;
                undoIcon(undoIcon==0)=NaN;
                self.UndoButton=uicontrol('Style','pushbutton',...
                'Parent',self.Header,...
                'Units','pixels',...
                'Enable','off',...
                'Position',[self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'CData',undoIcon,...
                'Tag','undobutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayundoTT')),...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)elementUndo(self));
            else
                self.UndoButton=uibutton('Parent',self.Header,...
                'Text','',...
                'Enable','off',...
                'Position',[self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'Icon',undoIcon,...
                'Tag','undobutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayundoTT')),...
                'HorizontalAlignment','left',...
                'ButtonPushedFcn',@(~,~)elementUndo(self));
            end


            redoIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Redo_24.png');
            if strcmp(self.AppHandle.Container,'ToolGroup')
                redoIcon=double(imread(redoIcon))/255;
                redoIcon(redoIcon==0)=NaN;
                self.RedoButton=uicontrol('Style','pushbutton',...
                'Parent',self.Header,...
                'Units','pixels',...
                'Enable','off',...
                'Position',[2*self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'CData',redoIcon,...
                'Tag','redobutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayredoTT')),...
                'HorizontalAlignment','left',...
                'Callback',@(~,~)elementRedo(self));
            else
                self.RedoButton=uibutton('Parent',self.Header,...
                'Text','',...
                'Enable','off',...
                'Position',[2*self.Header.Position(4)+1,self.Border+1,self.Header.Position(4)-self.Border,self.Header.Position(4)-(2*self.Border)],...
                'Icon',redoIcon,...
                'Tag','redobutton',...
                'Tooltip',getString(message('phased:apps:arrayapp:subarrayredoTT')),...
                'HorizontalAlignment','left',...
                'ButtonPushedFcn',@(~,~)elementRedo(self));
            end



            r=size(self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection,1);
            for i=1:r
                self.DataInternal=addcats(self.DataInternal,createUniqueLabelName(self));
            end

            updateNames(self);


            if isempty(self.AppHandle.StoreData)
                self.AppHandle.StoreData{1}=self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection;
                self.AppHandle.StoreNames{1}=self.Names;
            else
                idx=numel(self.AppHandle.StoreData);
                self.AppHandle.StoreData{idx+1}=self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection;
                self.AppHandle.StoreNames{idx+1}=self.Names;
            end

            notify(self,'SubarrayNamesUpdated',phased.apps.internal.interaction.NamesUpdatedEventData(...
            self.Names,self.ColormapInternal));
        end


        function label=createUniqueLabelName(self)

            for idx=1:self.MaxLabelsAllowed


                label=['Subarray',num2str(idx)];


                if~iscategory(self.DataInternal,label)


                    break;
                end

            end

        end

        function idx=getLabelIndex(self,label)

            idx=find(cellfun(@(x)strcmp(x,label),self.Names));
        end

        function updateNames(self)


            notify(self,'SubarrayNamesUpdated',phased.apps.internal.interaction.NamesUpdatedEventData(...
            self.Names,self.ColormapInternal));

        end

        function labelNamesUpdated(self,names,color)

            update(self,names,color);
        end

        function labelAdd(self)



            elemIndex=reshape(self.AppHandle.ElementIndex(~cellfun(@isempty,self.AppHandle.ElementIndex)),1,[]);


            if isequal(numel(self.Entries),1)
                self.Entries.DeleteBtnUI.Enable='on';
            end

            if isequal(self.NumberOfLabels,numel(elemIndex))
                self.DataInternal=addcats(self.DataInternal,createUniqueLabelName(self));
                updateNames(self);
            else
                addSubarrayError(self,self.Entries(end).Name);
                return;
            end

            idx=numel(self.AppHandle.StoreData);
            self.AppHandle.StoreData{idx+1}={'add',self.AppHandle.CurrentArray.SubarraySelection};
            self.AppHandle.StoreNames{idx+1}=self.Names;


            self.AppHandle.StoreDataIndex=numel(self.AppHandle.StoreData);
            UndoRedoEnableState(self);
            resize(self,self.AppHandle.SubarrayPartitionFig.Position);
        end

        function elementUndo(self)


            if self.AppHandle.StoreDataIndex>1
                setAppStatus(self.AppHandle,true);
                self.AppHandle.StoreDataIndex=self.AppHandle.StoreDataIndex-1;
                currentstorednames=numel(self.AppHandle.StoreNames{self.AppHandle.StoreDataIndex});
                previousstorednames=numel(self.AppHandle.StoreNames{self.AppHandle.StoreDataIndex+1});
                UndoRedoUpdate(self,currentstorednames,previousstorednames);
                self.UndoIndex=self.UndoIndex+1;
                UndoRedoEnableState(self);
                setAppStatus(self.AppHandle,false);
            end
        end

        function elementRedo(self)


            if self.AppHandle.StoreDataIndex>=1
                if numel(self.AppHandle.StoreData)>self.AppHandle.StoreDataIndex
                    setAppStatus(self.AppHandle,true);
                    self.AppHandle.StoreDataIndex=self.AppHandle.StoreDataIndex+1;
                    currentstorednames=numel(self.AppHandle.StoreNames{self.AppHandle.StoreDataIndex});
                    previousstorednames=numel(self.AppHandle.StoreNames{self.AppHandle.StoreDataIndex-1});
                    UndoRedoUpdate(self,currentstorednames,previousstorednames)
                end
                self.RedoIndex=self.RedoIndex+1;
                UndoRedoEnableState(self);
                setAppStatus(self.AppHandle,false);
            end
        end

        function UndoRedoUpdate(self,currentstorednames,previousstorednames)
            if iscell(self.AppHandle.StoreData{self.AppHandle.StoreDataIndex})
                if strcmp(self.AppHandle.StoreData{self.AppHandle.StoreDataIndex}{1},'add')
                    selMatrix=self.AppHandle.StoreData{self.AppHandle.StoreDataIndex}{2};
                else
                    selMatrix=self.AppHandle.StoreData{self.AppHandle.StoreDataIndex}{3};
                end
            else
                selMatrix=self.AppHandle.StoreData{self.AppHandle.StoreDataIndex};
            end


            if~isequal(currentstorednames,previousstorednames)
                self.DataInternal=[];
                for i=1:(currentstorednames)
                    labelname=self.AppHandle.StoreNames{self.AppHandle.StoreDataIndex};
                    self.DataInternal=addcats(self.DataInternal,labelname{i});
                end
            end
            updateNames(self);

            self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection=selMatrix;

            self.AppHandle.ElementIndex=[];
            self.AppHandle.SubarrayElementWeights=[];
            for i=1:size(selMatrix,1)
                self.AppHandle.ElementIndex{i}=find(selMatrix(i,:)');
                self.AppHandle.SubarrayElementWeights{i}=selMatrix(i,self.AppHandle.ElementIndex{i});
            end
            self.AppHandle.CurrentArray.SubarraySelection=selMatrix;


            self.AppHandle.ToolStripDisplay.PlotButtons{1}.Value=true;
            notify(self.AppHandle.ToolStripDisplay,'NewPlotRequest',...
            phased.apps.internal.controller.NewPlotEventData(...
            'arrayGeoFig'));

            updateOpenPlots(self.AppHandle);
            if~isequal(currentstorednames,previousstorednames)
                updateArrayCharTable(self.AppHandle)
            end
            adjustLayout(self.AppHandle)

            self.AppHandle.IsChanged=true;
            setAppTitle(self.AppHandle,self.AppHandle.DefaultSessionName)

            self.AppHandle.ParametersPanel.ArrayDialog.Panel.Title=...
            assignArrayDialogTitle(self.AppHandle.ParametersPanel.ArrayDialog);
        end

        function UndoRedoEnableState(self)
            if self.AppHandle.StoreDataIndex<=1
                self.UndoButton.Enable='off';
            else
                self.UndoButton.Enable='on';
            end
            if self.UndoIndex>self.RedoIndex
                self.RedoButton.Enable='on';
            else
                self.RedoButton.Enable='off';
            end
        end

        function removeLabel(self,label)

            setAppStatus(self.AppHandle,true);
            idx=getLabelIndex(self,label);
            if~isequal(idx,self.NumberOfLabels)
                colororderidx=mod(idx,49);
                if~isequal(colororderidx,0)
                    self.ColorOrder(colororderidx,:)=[];
                else
                    self.ColorOrder(49,:)=[];
                end
                self.ColorOrder(49,:)=rand([1,3],'single');
                createColorMap(self);
            end

            self.AppHandle.ElementIndex{idx}=[];
            self.AppHandle.SubarrayElementWeights{idx}=[];
            self.AppHandle.ElementIndex=reshape(self.AppHandle.ElementIndex(~cellfun(@isempty,self.AppHandle.ElementIndex)),1,[]);
            self.AppHandle.SubarrayElementWeights=reshape(self.AppHandle.SubarrayElementWeights(~cellfun(@isempty,self.AppHandle.SubarrayElementWeights)),1,[]);


            self.DataInternal=removecats(self.DataInternal,label);
            if isequal(self.NumberOfLabels,1)
                self.Entries(self.NumberOfLabels).DeleteBtnUI.Enable='off';
            end

            updateNames(self);

            numElem=getNumElements(self.AppHandle.CurrentArray);
            numSubArray=numel(self.AppHandle.ElementIndex);
            selMatrix=zeros(numSubArray,numElem);

            for idx=1:numSubArray
                selMatrix(idx,sort(self.AppHandle.ElementIndex{idx}))=1;
            end
            self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection=selMatrix;
            self.AppHandle.CurrentArray.SubarraySelection=selMatrix;
            disableAnalyzeButton(self.AppHandle)

            updateOpenPlots(self.AppHandle);
            updateArrayCharTable(self.AppHandle);
            self.AppHandle.IsChanged=true;
            setAppTitle(self.AppHandle,self.AppHandle.DefaultSessionName)
            idx=numel(self.AppHandle.StoreData);
            self.AppHandle.StoreData{idx+1}={'delete',label,selMatrix};
            self.AppHandle.StoreNames{idx+1}=self.Names;
            self.AppHandle.StoreDataIndex=numel(self.AppHandle.StoreData);

            UndoRedoEnableState(self);

            setAppStatus(self.AppHandle,false);

        end

        function brushSelectionUpdate(self)

            h=brush(self.AppHandle.ArrayGeometryFig);
            h.Color=self.ColormapInternal(self.Current,:);
            h.Enable='on';
            h.ActionPostCallback={@brushedDataCallback,self};
            function brushedDataCallback(figHandle,~,self)


                setAppStatus(self.AppHandle,true);
                hMode=getuimode(figHandle,'Exploration.Brushing');
                hMode.ShowContextMenu=false;
                hMode.UseContextMenu='off';
                modeState=hMode.ModeStateData;


                if isequal(size(modeState.brushObjects,1),2)&&strcmp(modeState.brushObjects(2).Tag,'Overlapped Elements')
                    elementpos=getElementPosition(self.AppHandle.CurrentArray)';
                    brushindex_elements=find(modeState.brushObjects(1).BrushData);
                    brushindex_overlap=find(modeState.brushObjects(2).BrushData);
                    brush_elementpos=[modeState.brushObjects(1).XData(brushindex_elements);modeState.brushObjects(1).YData(brushindex_elements);modeState.brushObjects(1).ZData(brushindex_elements)]';
                    brush_overlappos=[modeState.brushObjects(2).XData(brushindex_overlap);modeState.brushObjects(2).YData(brushindex_overlap);modeState.brushObjects(2).ZData(brushindex_overlap)]';
                    brushdata_element=ismember(elementpos,brush_elementpos,'rows').';
                    if~isempty(brushindex_overlap)
                        brushdata_overlap=ismember(elementpos,brush_overlappos,'rows').';
                        brushdata=brushdata_element+brushdata_overlap;
                    else
                        brushdata=brushdata_element;
                    end
                else
                    brushdata=modeState.brushObjects(1).BrushData;
                end

                self.BrushDataLogical=logical(brushdata.');
                lindx=find(self.BrushDataLogical);

                axesHandle=hMode.FigureHandle.CurrentAxes;

                isOverlap=findall(modeState.brushObjects,'Tag','Overlapped Elements');
                hscatter=findall(axesHandle,'Tag','Elements');
                if~isempty(isOverlap)&&~isempty(brush_elementpos)
                    brush_pos=find(ismember(hscatter.YData,brush_elementpos(2)));
                    if isequal(hscatter.CData(brush_pos,:),modeState.color)
                        setAppStatus(self.AppHandle,false);
                        return;
                    end
                else
                    if isequal(hscatter.CData(lindx,:),modeState.color)
                        setAppStatus(self.AppHandle,false);
                        return;
                    end
                end

                if~isempty(lindx)
                    previouselementIndex=self.AppHandle.ElementIndex;
                    previouselementWeights=self.AppHandle.SubarrayElementWeights;


                    for i=1:numel(lindx)
                        for j=1:numel(self.AppHandle.ElementIndex)
                            if~isempty(self.AppHandle.ElementIndex{j})
                                idx=find(self.AppHandle.ElementIndex{j}==lindx(i));
                                self.AppHandle.ElementIndex{j}=setdiff(self.AppHandle.ElementIndex{j},lindx(i));
                                if~isempty(idx)
                                    self.AppHandle.SubarrayElementWeights{j}(idx)=[];
                                end
                            end
                        end
                    end

                    for i=1:numel(lindx)
                        if~(self.Current>numel(self.AppHandle.ElementIndex))
                            self.AppHandle.ElementIndex{self.Current}=[self.AppHandle.ElementIndex{self.Current};lindx(i)];
                            self.AppHandle.SubarrayElementWeights{self.Current}=[self.AppHandle.SubarrayElementWeights{self.Current},1];
                            [self.AppHandle.ElementIndex{self.Current},sortidx]=sort(self.AppHandle.ElementIndex{self.Current});
                            self.AppHandle.SubarrayElementWeights{self.Current}=self.AppHandle.SubarrayElementWeights{self.Current}(fliplr(sortidx));
                        else
                            self.AppHandle.ElementIndex{self.Current}=[lindx(i)];
                            self.AppHandle.SubarrayElementWeights{self.Current}=1;
                        end
                    end


                    indexwithzeros=find(cellfun(@isempty,self.AppHandle.ElementIndex));
                    if~isempty(indexwithzeros)
                        self.AppHandle.ElementIndex=previouselementIndex;
                        self.AppHandle.SubarrayElementWeights=previouselementWeights;
                        emptySubarrayName=[];
                        for i=1:numel(indexwithzeros)
                            if isempty(emptySubarrayName)
                                emptySubarrayName=self.Entries(indexwithzeros(i)).Name;
                            else
                                emptySubarrayName=strcat(emptySubarrayName,',',self.Entries(indexwithzeros(i)).Name);
                            end
                        end
                        addSubarrayError(self,emptySubarrayName);
                    end

                    numElem=getNumElements(self.AppHandle.CurrentArray);
                    numSubArray=numel(self.AppHandle.ElementIndex);
                    selMatrix=zeros(numSubArray,numElem);
                    drawnow;
                    for idx=1:numSubArray
                        selMatrix(idx,sort(self.AppHandle.ElementIndex{idx}))=self.AppHandle.SubarrayElementWeights{idx};
                    end

                    self.AppHandle.CurrentArray.SubarraySelection=selMatrix;
                    self.AppHandle.ParametersPanel.AdditionalConfigDialog.SubarraySelection=selMatrix;
                    disableAnalyzeButton(self.AppHandle)
                    updateArrayCharTable(self.AppHandle);
                    updateOpenPlots(self.AppHandle)
                    self.AppHandle.IsChanged=true;
                    setAppTitle(self.AppHandle,self.AppHandle.DefaultSessionName)

                    idx=numel(self.AppHandle.StoreData);
                    self.AppHandle.StoreData{idx+1}=selMatrix;
                    self.AppHandle.StoreNames{idx+1}=self.Names;


                    self.AppHandle.StoreDataIndex=numel(self.AppHandle.StoreData);
                    UndoRedoEnableState(self);
                end

                setAppStatus(self.AppHandle,false);
            end
        end
        function addSubarrayError(self,name)
            if strcmp(self.AppHandle.Container,'ToolGroup')
                h=errordlg(getString(message('phased:apps:arrayapp:addsubarrayerr',name)),...
                getString(message('phased:apps:arrayapp:errordlg')),...
                'modal');
                uiwait(h);
            else
                uialert(self.AppHandle.ToolGroup,...
                getString(message('phased:apps:arrayapp:addsubarrayerr',name)),...
                getString(message('phased:apps:arrayapp:errordlg')));
            end
        end
    end

    methods

        function n=get.NumberOfLabels(self)

            n=numel(categories(self.DataInternal));

        end




        function names=get.Names(self)

            names=categories(self.DataInternal);

        end




        function name=get.CurrentName(self)
            name=self.Names{self.Current};
        end
    end
end