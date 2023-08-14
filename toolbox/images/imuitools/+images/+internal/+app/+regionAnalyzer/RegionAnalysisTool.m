classdef RegionAnalysisTool<images.internal.app.regionAnalyzer.ImageApp




    properties


AnalysisTab


hScrollpanel
hTable


LoadImageSection
RegionFilteringSection
TableViewSection
ExportSection


hLoadButton
hExcludeBorderCheckbox
hFillHolesCheckbox
hFilterButton
hSortCombo
hSelectPropsButton
hExportButton
hPropertyPickerPanel
hFilterRegionPanel
hTableViewPanel


FigureHandles


hFigCurrent

propsUnsorted


propsSortApplied
maskCurrent



ClientActionListener


regionCheckboxListener
choosePropsButtonListener
imageLoadedListener
filterUpdateListener


    end

    properties(SetAccess=private,SetObservable=true)

maskFilledCleared
    end


    properties(Access=private)

tableSortOrder
propLimitsCache
hasLotsOfObjects

    end



    methods

        function self=RegionAnalysisTool(varargin)


            self=self@images.internal.app.regionAnalyzer.ImageApp(message('images:regionAnalyzer:appName').getString());
            self.appName='imageRegionAnalyzer';

            self.imageLoader=images.internal.app.regionAnalyzer.ImageLoaderBW(false);

            self.removeDocumentBar()


            images.internal.app.utilities.addDDUXLogging(self.hToolGroup,'Image Processing Toolbox','Image Region Analyzer');

            self.hToolGroup.open()
            imageslib.internal.apputil.ScreenUtilities.setInitialToolPosition(self.GroupName);


            self.AnalysisTab=self.hToolGroup.addTab('AnalysisTab',...
            message('images:regionAnalyzer:analysisTabTitle').getString());
            self.hideDataBrowser()


            self.propLimitsCache=images.internal.app.regionAnalyzer.PropertyLimitsCache(self);
            images.internal.app.regionAnalyzer.filterTagGenerator('reset');

            self.LoadImageSection=self.layoutLoadImageSection(self.AnalysisTab);
            self.RegionFilteringSection=self.layoutRegionFilteringSection(self.AnalysisTab);
            self.TableViewSection=self.layoutTableViewSection(self.AnalysisTab);
            self.ExportSection=self.layoutExportSection(self.AnalysisTab);




            self.hFigCurrent=self.createFigure();


            if nargin>0
                self.importImageData(varargin{1});
                self.hasImage=true;
                self.resetFilters()
                self.toggleLoadDependentControls(true)
            else
                self.toggleLoadDependentControls(false)
            end

            self.imageLoadedListener=addlistener(self.imageLoadedEvent,...
            'loaded',@self.reinitializeAppWithImage);
            self.filterUpdateListener=addlistener(self.hFilterRegionPanel.filterUpdateEvent,...
            'settingsChanged',@self.reactToFilterChanges);

            imageslib.internal.apputil.manageToolInstances('add','imageRegionAnalyzer',self);


            self.ClientActionListener=addlistener(self.hToolGroup,...
            'ClientAction',@(hobj,evt)clientActionCB(self,hobj,evt));




            addlistener(self.hToolGroup,'GroupAction',...
            @(~,ed)doClosingSession(self,ed));

        end

        function addMissingProps(self,propNames)

            propsToAdd=setdiff(propNames,fieldnames(self.propsUnsorted));
            if isempty(propsToAdd)
                return
            end


            newProps=regionprops(self.maskCurrent,propsToAdd);

            for p=1:numel(propsToAdd)
                thisField=propsToAdd{p};
                [self.propsUnsorted(:).(thisField)]=deal(newProps.(thisField));
            end


            self.propsSortApplied=self.propsUnsorted(self.tableSortOrder);

        end

        function propNames=interestingProps(self)
            if isstruct(self.propsUnsorted)
                propNames=fieldnames(self.propsUnsorted);
                propNames=setdiff(propNames,'PixelIdxList');
            else
                propNames={};
            end
        end

    end



    methods(Access=private)

        function hSection=layoutRegionFilteringSection(self,parentTab)

            hSection=parentTab.addSection('RegionFiltering',...
            message('images:regionAnalyzer:regionFilteringTitle').getString());

            regionFilteringPanel=toolpack.component.TSPanel(...
            'f:p,f:p',...
            'f:p:g,f:p:g,f:p:g');

            hSection.add(regionFilteringPanel);
            regionFilteringPanel.Name='panelRegionFiltering';

            FilterIcon=toolpack.component.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/Refine_24px.png'));
            self.hFilterButton=toolpack.component.TSDropDownButton(...
            message('images:regionAnalyzer:filterLabel').getString(),...
            FilterIcon);

            self.hFilterRegionPanel=images.internal.app.regionAnalyzer.FilterPanel(self.propLimitsCache);
            self.hFilterButton.Popup=self.hFilterRegionPanel.hPopup;
            self.hFilterButton.Orientation=toolpack.component.ButtonOrientation.VERTICAL;

            self.hLoadDependentControls{end+1}=self.hFilterButton;
            iptui.internal.utilities.setToolTipText(self.hFilterButton,...
            message('images:regionAnalyzer:filterTooltip').getString());
            self.hFilterButton.Name='btnFilterRegions';

            self.hExcludeBorderCheckbox=toolpack.component.TSCheckBox(...
            message('images:regionAnalyzer:excludeBorderLabel').getString());
            self.hLoadDependentControls{end+1}=self.hExcludeBorderCheckbox;
            iptui.internal.utilities.setToolTipText(self.hExcludeBorderCheckbox,...
            message('images:regionAnalyzer:excludeBorderTooltip').getString());
            self.hExcludeBorderCheckbox.Name='chkExcludeBorder';

            self.hFillHolesCheckbox=toolpack.component.TSCheckBox(...
            message('images:regionAnalyzer:fillHolesLabel').getString());
            self.hLoadDependentControls{end+1}=self.hFillHolesCheckbox;
            iptui.internal.utilities.setToolTipText(self.hFillHolesCheckbox,...
            message('images:regionAnalyzer:fillHolesTooltip').getString());
            self.hFillHolesCheckbox.Name='chkFillHoles';


            self.regionCheckboxListener=addlistener([self.hExcludeBorderCheckbox,self.hFillHolesCheckbox],...
            'ItemStateChanged',@(hObj,evt)reactToFilterCheckboxChanges(self,hObj,evt));

            regionFilteringPanel.add(self.hFillHolesCheckbox,'xy(1,1)');
            regionFilteringPanel.add(self.hExcludeBorderCheckbox,'xy(1,2)');
            regionFilteringPanel.add(self.hFilterButton,'xywh(2,1,1,3)');

        end

        function hSection=layoutTableViewSection(self,parentTab)

            hSection=parentTab.addSection('TableView',...
            message('images:regionAnalyzer:propertiesTitle').getString());

            tableViewPanel=toolpack.component.TSPanel(...
            'f:p,f:p,50dlu',...
            'f:p,1dlu,f:p,f:p:g,');
            self.hTableViewPanel=tableViewPanel;

            hSection.add(tableViewPanel);
            tableViewPanel.Name='panelTableView';

            ChoosePropsIcon=toolpack.component.Icon.PROPERTIES_24;
            self.hSelectPropsButton=toolpack.component.TSDropDownButton(...
            message('images:regionAnalyzer:propertiesLabel').getString(),...
            ChoosePropsIcon);

            [propNames,numForDisplay]=images.internal.app.regionAnalyzer.getPropNames();
            self.hPropertyPickerPanel=images.internal.app.regionAnalyzer.PropertiesSelectionPanel(propNames(1:numForDisplay));
            self.hPropertyPickerPanel.SelectedValues=images.internal.app.regionAnalyzer.defaultSubsetOfProps();
            self.hSelectPropsButton.Popup=self.hPropertyPickerPanel.popup;
            self.hSelectPropsButton.Orientation=toolpack.component.ButtonOrientation.VERTICAL;
            iptui.internal.utilities.setToolTipText(self.hSelectPropsButton,...
            message('images:regionAnalyzer:propertiesTooltip').getString());
            self.hSelectPropsButton.Name='btnSelectProps';
            self.hLoadDependentControls{end+1}=self.hSelectPropsButton;

            sortLabel=toolpack.component.TSLabel(getString(message('images:regionAnalyzer:sortLabel')));

            propNames={message('images:regionAnalyzer:unsortedValue').getString(),...
            self.hPropertyPickerPanel.SelectedValues{:}};%#ok<CCAT>

            self.addSortCombo(propNames)

            tableViewPanel.add(self.hSelectPropsButton,'xywh(1,1,1,4)');
            tableViewPanel.add(sortLabel,'xywh(2,1,2,1)');

            addlistener(self.hPropertyPickerPanel,'SelectedIndices','PostSet',@(hObj,evt)onPropertySelection(self,hObj,evt));

        end

        function hSection=layoutExportSection(self,parentTab)

            hSection=parentTab.addSection('Export',getString(message('images:colorSegmentor:export')));

            createMaskPanel=toolpack.component.TSPanel('f:p','f:p');
            hSection.add(createMaskPanel);
            createMaskPanel.Name='panelExport';

            createMaskIcon=toolpack.component.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/CreateMask_24px.png'));

            exportButton=toolpack.component.TSSplitButton(getString(message('images:regionAnalyzer:export')),...
            createMaskIcon);
            addlistener(exportButton,'ActionPerformed',@(hobj,evt)self.exportDataToWorkspace());
            exportButton.Orientation=toolpack.component.ButtonOrientation.VERTICAL;
            exportButton.Name='btnExport';
            iptui.internal.utilities.setToolTipText(exportButton,getString(message('images:colorSegmentor:exportButtonTooltip')));



            style='icon_text';

            exportButton.Popup=toolpack.component.TSDropDownPopup(...
            getExportOptions(),style);
            exportButton.Popup.Name='Export Popup';


            addlistener(exportButton.Popup,'ListItemSelected',...
            @self.exportSplitButtonCallback);

            createMaskPanel.add(exportButton,'xy(1,1)');

            self.hLoadDependentControls{end+1}=exportButton;



            function items=getExportOptions(~)



                exportDataIcon=toolpack.component.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/CreateMask_16px.png'));

                exportFunctionIcon=toolpack.component.Icon(...
                fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));

                exportPropsIcon=toolpack.component.Icon.EXPORT_16;

                items(1)=struct(...
                'Title',getString(message('images:regionAnalyzer:exportImage')),...
                'Description','',...
                'Icon',exportDataIcon,...
                'Help',[],...
                'Header',false);

                items(2)=struct(...
                'Title',getString(message('images:regionAnalyzer:exportProps')),...
                'Description','',...
                'Icon',exportPropsIcon,...
                'Help',[],...
                'Header',false);

                items(3)=struct(...
                'Title',getString(message('images:colorSegmentor:exportFunction')),...
                'Description','',...
                'Icon',exportFunctionIcon,...
                'Help',[],...
                'Header',false);
            end

        end

        function addSortCombo(self,propNames)

            self.hSortCombo=toolpack.component.TSComboBox(propNames);
            self.hLoadDependentControls{end+1}=self.hSortCombo;
            iptui.internal.utilities.setToolTipText(self.hSortCombo,...
            message('images:regionAnalyzer:sortTooltip').getString());
            self.hSortCombo.Name='comboSort';

            self.hTableViewPanel.add(self.hSortCombo,'xywh(2,3,2,1)');
            addlistener(self.hSortCombo,'ActionPerformed',@(~,evt)self.onSortSelectionChanged(evt));




            self.hTableViewPanel.Peer.revalidate();

            self.hSortCombo.Enabled=self.hasImage;
        end

        function removeSortCombo(self)
            self.hTableViewPanel.remove(self.hSortCombo)
        end

    end



    methods(Access=private)

        function hFig=createFigure(self)

            hFig=figure('NumberTitle','off',...
            'Colormap',gray(2),...
            'Tag','RegionAnalysisFigure',...
            'IntegerHandle','off');





            hFig.WindowKeyPressFcn=@(~,~)[];

            self.FigureHandles=hFig;
            self.hToolGroup.addFigure(hFig);



            self.hToolGroup.getFiguresDropTargetHandler.unregisterInterest(hFig);

            hideFigureFromExternalHGEvents(hFig)

            iptPointerManager(hFig);

        end

        function importImageData(self,img)

            self.imageData=self.prepImageData(img);


            self.createScrollpanelView(self.imageData);
            self.maskCurrent=self.imageData;
            self.maskFilledCleared=self.imageData;
        end

        function out=prepImageData(self,in)
            maxNumberOfRegions=getMaxNumberOfRegions();
            cc=bwconncomp(in);
            self.hasLotsOfObjects=(cc.NumObjects>maxNumberOfRegions);

            if self.hasLotsOfObjects
                warndlg(getString(message('images:regionAnalyzer:tooManyObjects',maxNumberOfRegions)),...
                getString(message('images:regionAnalyzer:tooManyObjectsTitle')),...
                'non-modal');
                out=findLargestObjects(in);
            else
                out=in;
            end
        end

        function hFig=createScrollpanelView(self,img)

            hFig=self.FigureHandles;

            hImagePanel=findobj(hFig,'tag','ImagePanel');
            if isempty(hImagePanel)
                hImagePanel=uipanel('Parent',hFig,'Position',[0,0,0.6,1],'BorderType','none','tag','ImagePanel');
            end

            hTablePanel=findobj(hFig,'tag','TablePanel');
            if isempty(hTablePanel)
                hTablePanel=uipanel('Parent',hFig,'Position',[0.6,0,0.4,1],'BorderType','none','tag','TablePanel');
            end

            self.layoutScrollpanel(hImagePanel,img)
            self.layoutTable(hTablePanel,img)

            hideFigureFromExternalHGEvents(hFig)

        end


        function layoutScrollpanel(self,hImagePanel,img)

            if isempty(self.hScrollpanel)||~ishandle(self.hScrollpanel)

                hAx=axes('Parent',hImagePanel);




                warnState=warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
                hIm=imshow(img,'Parent',hAx);
                warning(warnState)

                if isvalid(hAx)
                    images.internal.utils.customAxesInteraction(hAx);
                end

                self.hScrollpanel=imscrollpanel(hImagePanel,hIm);
                set(self.hScrollpanel,'Units','normalized',...
                'Position',[0,0,1,1])

                api=iptgetapi(self.hScrollpanel);
                drawnow()
                api.setMagnification(0.9*api.findFitMag())


                hAx=findobj(self.hScrollpanel,'type','axes');
                set(hAx,'Visible','on');


                set(hAx,'Color',[1,0,0])


                set(hAx,'XTick',[],'YTick',[])

                if isvalid(hAx)
                    images.internal.utils.customAxesInteraction(hAx);
                end

            else




                set(self.hScrollpanel,'Parent',hImagePanel)

            end
        end

        function layoutTable(self,hTablePanel,img)
            propsStruct=self.computeProps(img);
            self.propsUnsorted=propsStruct;
            self.propsSortApplied=propsStruct;
            self.tableSortOrder=1:numel(propsStruct);

            propsStruct=subsetProps(propsStruct,images.internal.app.regionAnalyzer.defaultSubsetOfProps());
            [propsTable,propNames]=prepPropsForDisplay(propsStruct);

            if(isempty(self.hTable)||~isvalid(self.hTable))
                self.hTable=uitable(...
                'Data',propsTable,...
                'Parent',hTablePanel,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'ColumnName',propNames,...
                'RearrangeableColumns','on',...
                'Tag','PropertiesTable',...
                'CellSelectionCallback',@(obj,evt)tableSelectionCallback(self,obj,evt));
            else
                set(self.hTable,'Data',propsTable)
            end


            self.setStatusBarText(getString(message('images:regionAnalyzer:clickTableToSeeRegion')))
        end

        function reinitializeAppWithImage(self,~,~)
            self.hasImage=true;

            if isempty(self.hScrollpanel)
                self.importImageData(self.imageData)
            else
                img=self.prepImageData(self.imageData);
                self.maskCurrent=img;
                self.maskFilledCleared=img;
                self.imageData=img;
                api=iptgetapi(self.hScrollpanel);
                api.replaceImage(self.imageData)
                api.setMagnification(api.findFitMag())
            end

            propsStruct=self.computeProps(self.imageData);
            self.propsUnsorted=propsStruct;
            self.tableSortOrder=1:numel(propsStruct);

            self.resetFilters()
            self.reactToFilterCheckboxChanges()

            self.toggleLoadDependentControls(true)
        end

    end



    methods(Access=private)

        function clientActionCB(self,~,evt)



            if strcmpi(evt.EventData.EventType,'CLOSED')
                appDeleted=~isvalid(self)||~isvalid(self.hToolGroup);
                if~appDeleted
                    self.hScrollpanel=[];
                    self.createFigure();
                    self.toggleLoadDependentControls(false)
                end
            end

        end

    end



    methods(Access=private)

        function doClosingSession(self,event)
            if strcmp(event.EventData.EventType,'CLOSING')
                imageslib.internal.apputil.manageToolInstances('remove','imageRegionAnalyzer',self);
                delete(self);
            end
        end

        function reactToFilterChanges(self,~,~)
            originalMask=self.maskCurrent;
            self.maskCurrent=self.applyFilters(self.maskFilledCleared);


            if~isequal(self.maskCurrent,originalMask)
                self.updateMaskView(self.maskCurrent);
                self.updateTableView(self.maskCurrent);
            end
        end

        function mask=applyFilters(self,mask)
            selections=self.hFilterRegionPanel;
            for idx=1:selections.numberOfSelections
                filterFcn=selections.getSelectionFilterFcn(idx);
                mask=filterFcn(mask);
            end
        end

        function reactToFilterCheckboxChanges(self,~,~)
            self.maskFilledCleared=computeMask(self.imageData,...
            self.hExcludeBorderCheckbox.Selected,...
            self.hFillHolesCheckbox.Selected);
            self.maskCurrent=self.applyFilters(self.maskFilledCleared);


            self.updateMaskView(self.maskCurrent);
            self.updateTableView(self.maskCurrent);
        end

        function tableSelectionCallback(self,~,evt)
            rowsSelected=evt.Indices(:,1);
            props=self.propsSortApplied(rowsSelected);
            pixels=[];
            for p=1:numel(props)
                pixels=[pixels;props(p).PixelIdxList];%#ok<AGROW>
            end

            hIm=findobj(self.hFigCurrent,'type','image');
            adata=ones(size(self.maskCurrent));
            adata(pixels)=0.5;
            set(hIm,'AlphaData',adata)
        end

        function onSortSelectionChanged(self,evt)
            propName=evt.Source.SelectedItem;
            self.sortProperties(propName)
        end

        function sortProperties(self,propName)

            msg=message('images:regionAnalyzer:unsortedValue').getString();
            switch(propName)
            case(msg)

                processUnsortedCase(self);
            otherwise
                if isempty(self.propsUnsorted)
                    processUnsortedCase(self);
                else
                    processSortedCase(self,propName);
                end
            end

            self.updateTableContents(self.propsSortApplied);
        end

        function processUnsortedCase(self)
            self.propsSortApplied=self.propsUnsorted;
            self.tableSortOrder=1:numel(self.propsUnsorted);
        end

        function processSortedCase(self,propName)
            [~,idx]=sort([self.propsUnsorted.(propName)],'descend');
            self.propsSortApplied=self.propsUnsorted(idx);
            self.tableSortOrder=idx;
        end

        function updateTableView(self,newMask)
            self.propsUnsorted=self.computeProps(newMask);
            self.propsSortApplied=self.propsUnsorted;
            self.sortProperties(self.getCurrentSortField())
            self.updateTableContents(self.propsSortApplied)
        end

        function updateTableContents(self,propsStruct)
            hUitable=findobj(self.hTable,'type','uitable');
            propsStruct=subsetProps(propsStruct,self.getSelectedProps());
            propsTable=prepPropsForDisplay(propsStruct);
            set(hUitable,'Data',propsTable)
            fields=fieldnames(propsStruct);
            set(hUitable,'ColumnName',fields);
        end

        function updateMaskView(self,newMask)

            hIm=findobj(self.hFigCurrent,'type','image');


            set(hIm,'CData',newMask)
        end

        function onPropertySelection(self,~,evt)

            if~self.hasImage
                return
            end
            propNames=evt.AffectedObject.SelectedValues;

            self.updateSortCombo(propNames)

            if~isempty(self.propsUnsorted)
                self.addMissingProps(propNames)
                newPropsForDisplay=subsetProps(self.propsSortApplied,propNames);
                self.updateTableContents(newPropsForDisplay)
            end
            if~(isempty(self.propsUnsorted)&&~isstruct(self.propsUnsorted))
                self.addMissingProps(propNames)
                newPropsForDisplay=subsetProps(self.propsSortApplied,propNames);
                self.updateTableContents(newPropsForDisplay)
            end
            self.addMissingProps(propNames)
            newPropsForDisplay=subsetProps(self.propsSortApplied,propNames);
            self.updateTableContents(newPropsForDisplay)


        end

        function updateSortCombo(self,propNames)

            propNames={message('images:regionAnalyzer:unsortedValue').getString(),...
            propNames{:}};%#ok<CCAT>


            selectedProp=self.hSortCombo.SelectedItem;
            [~,idx]=intersect(propNames,selectedProp);




            self.removeSortCombo()
            self.addSortCombo(propNames)

            if isempty(idx)
                self.hSortCombo.SelectedIndex=1;
            else
                self.hSortCombo.SelectedIndex=idx;
            end
        end

        function propNames=getSelectedProps(self)
            propNames=self.hPropertyPickerPanel.SelectedValues;
        end

        function sortField=getCurrentSortField(self)
            sortField=self.hSortCombo.SelectedItem;
        end

        function propsStruct=computeProps(self,mask)
            propNames=self.getSelectedProps();
            propNames{end+1}='PixelIdxList';
            propsStruct=regionprops(mask,propNames);
        end

        function resetFilters(self)

            self.hExcludeBorderCheckbox.Selected=false;
            self.hFillHolesCheckbox.Selected=false;

            selections=self.hFilterRegionPanel;
            selections.reset()

        end

    end



    methods(Access=private)

        function exportSplitButtonCallback(self,src,~)

            switch(src.SelectedIndex)
            case 1
                self.exportDataToWorkspace()

            case 2
                self.exportProperties()

            case 3
                self.generateCode()
            end

        end

        function exportDataToWorkspace(self)

            export2wsdlg({getString(message('images:colorSegmentor:binaryMask'))},...
            {'BW'},{self.maskCurrent});

        end

        function exportProperties(self)

            propsStruct=subsetProps(self.propsSortApplied,self.hPropertyPickerPanel.SelectedValues);
            propsTable=struct2table(propsStruct);

            export2wsdlg({getString(message('images:regionAnalyzer:propsStruct')),...
            getString(message('images:regionAnalyzer:propsTable'))},...
            {'propsStruct','propsTable'},{propsStruct,propsTable});

        end

        function generateCode(self)

            codeGenerator=iptui.internal.CodeGenerator();


            self.addFunctionDeclaration(codeGenerator)
            codeGenerator.addReturn()
            codeGenerator.addHeader(self.appName);

            if(self.hasLotsOfObjects)
                codeGenerator.addLine(sprintf('BW_out = bwareafilt(BW_in, %d);',getMaxNumberOfRegions()))
            else
                codeGenerator.addLine('BW_out = BW_in;')
            end


            if self.hExcludeBorderCheckbox.Selected
                codeGenerator.addComment('Remove portions of the image that touch an outside edge.')
                codeGenerator.addLine('BW_out = imclearborder(BW_out);')
            end

            if self.hFillHolesCheckbox.Selected
                codeGenerator.addComment('Fill holes in regions.')
                codeGenerator.addLine('BW_out = imfill(BW_out, ''holes'');')
            end


            numFilters=self.hFilterRegionPanel.numberOfSelections;
            defaultSettings=true;
            for idx=1:numFilters
                defaultSettings=defaultSettings&&self.hFilterRegionPanel.hasDefaultSettings(idx);
            end

            if(~defaultSettings)
                codeGenerator.addComment('Filter image based on image properties.')
                for idx=1:numFilters
                    if(~self.hFilterRegionPanel.hasDefaultSettings(idx))
                        [~,filterString]=self.hFilterRegionPanel.getSelectionFilterFcn(idx);
                        codeGenerator.addLine(sprintf(filterString,'BW_out','BW_out'))
                    end
                end
            end


            propertyList=self.hPropertyPickerPanel.SelectedValues;

            if~isempty(propertyList)
                propertyString=['{',sprintf('''%s'', ',propertyList{:})];
                propertyString(end-1:end)='';
                propertyString=[propertyString,'}'];

                codeGenerator.addComment('Get properties.')
                codeGenerator.addLine(sprintf('properties = regionprops(BW_out, %s);',...
                propertyString))

                if(~isequal(self.getCurrentSortField(),...
                    message('images:regionAnalyzer:unsortedValue').getString()))


                    codeGenerator.addComment('Sort the properties.')
                    codeGenerator.addLine(sprintf('properties = sortProperties(properties, ''%s'');',...
                    self.getCurrentSortField()))


                    sortingCodeGenerator=generateSortingCode();
                    sortingCode=sortingCodeGenerator.getCodeString();
                    codeGenerator.addSubFunction(sortingCode)
                end

                codeGenerator.addComment('Uncomment the following line to return the properties in a table.')
                codeGenerator.addLine('% properties = struct2table(properties);')

            else

                codeGenerator.addLine('properties = [];');
            end


            codeGenerator.addReturn()


            codeGenerator.putCodeInEditor()


            function sortingCodeGenerator=generateSortingCode()

                sortingCodeGenerator=iptui.internal.CodeGenerator();
                sortingCodeGenerator.addLine('function properties = sortProperties(properties, sortField)')
                sortingCodeGenerator.addComment('Compute the sort order of the structure based on the sort field.')
                sortingCodeGenerator.addLine('[~,idx] = sort([properties.(sortField)], ''descend'');')
                sortingCodeGenerator.addComment('Reorder the entire structure.')
                sortingCodeGenerator.addLine('properties = properties(idx);')

            end

        end

        function addFunctionDeclaration(~,generator)
            fcnName='filterRegions';
            inputs={'BW_in'};
            outputs={'BW_out','properties'};

            h1Line=' Filter BW image using auto-generated code from imageRegionAnalyzer app.';

            description=['filters binary image BW_IN using auto-generated code'...
            ,' from the imageRegionAnalyzer app. BW_OUT has had all of the'...
            ,' options and filtering selections that were specified in'...
            ,' imageRegionAnalyzer applied to it. The PROPERTIES structure'...
            ,' contains the attributes of BW_out that were visible in the app.'];

            generator.addFunctionDeclaration(fcnName,inputs,outputs,h1Line);
            generator.addSyntaxHelp(fcnName,description,inputs,outputs);
        end

    end

    methods(Static)

        function deleteAllTools
            imageslib.internal.apputil.manageToolInstances('deleteAll','imageRegionAnalyzer');
        end

    end

end



function[propsTable,propNames]=prepPropsForDisplay(propsStruct)
    if(isfield(propsStruct,'PixelIdxList'))
        propsStruct=rmfield(propsStruct,'PixelIdxList');
    end
    propsTable=struct2cell(propsStruct)';
    propNames=fieldnames(propsStruct);
end


function subset=subsetProps(fullPropsStruct,propNamesInSubset)
    allFields=fieldnames(fullPropsStruct);
    fieldsToDelete=setdiff(allFields,propNamesInSubset);
    subset=rmfield(fullPropsStruct,fieldsToDelete);
end


function newMask=computeMask(mask,excludeBorder,fillHoles)
    if excludeBorder
        newMask=imclearborder(mask);
    else
        newMask=mask;
    end

    if fillHoles
        newMask=imfill(newMask,'holes');
    end
end


function img=findLargestObjects(img)
    w=warning();
    warning('off','images:bwfilt:tie')
    img=bwpropfilt(img,'area',getMaxNumberOfRegions());
    warning(w);
end


function value=getMaxNumberOfRegions
    value=1000;
end


function hideFigureFromExternalHGEvents(hFig)
    set(hFig,'HandleVisibility','callback');
end
