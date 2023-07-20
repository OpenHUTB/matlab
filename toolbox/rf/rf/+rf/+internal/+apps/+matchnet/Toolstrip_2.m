classdef Toolstrip_2<matlab.ui.internal.toolstrip.TabGroup




    properties(Transient=true)

    end

    properties(Access=public)
        Tab1 matlab.ui.internal.toolstrip.Tab

    end

    properties(Access=public,Constant)
        LumpedList=horzcat(["Pi","T","L"]+"-Topology",...
        "3"+"-Components")

        LumpedList_icon=horzcat(["Pi","T","L"]+"_Topology",...
        "3"+"_Components")
    end

    properties(Access=public)
        NewSessionButton matlab.ui.internal.toolstrip.Button
        OpenSessionButton matlab.ui.internal.toolstrip.Button
        ImportButton matlab.ui.internal.toolstrip.Button
        SaveSessionButton matlab.ui.internal.toolstrip.SplitButton

        ConstraintsButton matlab.ui.internal.toolstrip.Button

        CenterFrequencyLabel matlab.ui.internal.toolstrip.Label
        CenterFrequencyEditField matlab.ui.internal.toolstrip.EditField

        QFactorLabel matlab.ui.internal.toolstrip.Label
        QFactorEditField matlab.ui.internal.toolstrip.EditField

        ComponentGallery matlab.ui.internal.toolstrip.Gallery
        galleryItems matlab.ui.internal.toolstrip.ToggleGalleryItem

        NewCartesianSplitButton matlab.ui.internal.toolstrip.SplitButton
        NewSmithSplitButton matlab.ui.internal.toolstrip.SplitButton

        GenerateNetworksButton matlab.ui.internal.toolstrip.Button

        DefaultLayoutBtn matlab.ui.internal.toolstrip.Button

        ExportSection matlab.ui.internal.toolstrip.Section
        ExportSplitButton matlab.ui.internal.toolstrip.SplitButton

myCircuitTree
    end

    properties(Access=private)
        IconRoot=fullfile(matlabroot,'toolbox','rf','rf','+rf',...
        '+internal','+apps','+matchnet','Resources')
SmithIcon
    end

    methods(Access=public)
        function this=Toolstrip_2()
            this@matlab.ui.internal.toolstrip.TabGroup();
            this.Tag="globalTabGroup";

            this.createIcons();
            this.initTab1();

        end

        function disableButtons(this,value)
            this.SaveSessionButton.Enabled=value;
            this.ConstraintsButton.Enabled=value;
            this.ImportButton.Enabled=value;

            this.CenterFrequencyLabel.Enabled=value;
            this.CenterFrequencyEditField.Enabled=value;

            this.QFactorLabel.Enabled=value;
            this.QFactorEditField.Enabled=value;

            this.NewCartesianSplitButton.Enabled=value;
            this.NewSmithSplitButton.Enabled=value;

            this.GenerateNetworksButton.Enabled=value;

            this.ExportSplitButton.Enabled=value;

            for k=1:length(this.galleryItems)
                this.galleryItems(k).Enabled=value;
                this.galleryItems(k).Value=value;
            end
        end

        function enableButtons(this,value)
            this.ConstraintsButton.Enabled=value;
            this.ImportButton.Enabled=value;

            this.CenterFrequencyLabel.Enabled=value;
            this.CenterFrequencyEditField.Enabled=value;

            this.QFactorLabel.Enabled=value;
            this.QFactorEditField.Enabled=value;
            this.galleryItems(1).Value=value;
            for k=1:length(this.galleryItems)
                this.galleryItems(k).Enabled=value;
            end
            this.GenerateNetworksButton.Enabled=value;
        end


        function selectItem(this,ItemClicked)
            for i=1:length(this.galleryItems)
                if strcmp(ItemClicked.Text,this.galleryItems(i).Text)
                    this.galleryItems(i).Value=true;
                else
                    this.galleryItems(i).Value=false;
                end
            end
            if strcmp(ItemClicked.Text,'L-Topology')
                this.QFactorEditField.Enabled=false;
            else
                this.QFactorEditField.Enabled=true;
            end
            newChangesAvailable(this)
        end

        function newNetworksAvailable(this,e)
            if~strcmpi(e.data.CircuitGroupName,'User-Created Circuits')
                this.GenerateNetworksButton.Enabled=false;
                this.myCircuitTree=[this.myCircuitTree;e.data.Tracker];
            end
        end

        function updateConfig(this,e)
            this.QFactorEditField.Value=num2str(e.data.Q);
            this.CenterFrequencyEditField.Value=num2str(e.data.CenterFrequency/1e9);
            switch e.data.Topology
            case 3
                ItemClicked.Text='3-Components';
            case 'Tee'
                ItemClicked.Text='T-Topology';
            case{2,'L'}
                ItemClicked.Text='L-Topology';
            case 'Pi'
                ItemClicked.Text='Pi-Topology';
            end
            selectItem(this,ItemClicked)
        end

        function newChangesAvailable(this)
            gallery_index=split(this.LumpedList(arrayfun(@(x)x.Value,...
            this.galleryItems)),'-');
            current_set={str2double(this.CenterFrequencyEditField.Value)...
            ,str2double(this.QFactorEditField.Value)...
            ,char(gallery_index(1))};
            if~isempty(this.myCircuitTree)
                check=(cell2mat(this.myCircuitTree(:,1))==current_set{1})...
                &(cell2mat(this.myCircuitTree(:,2))==current_set{2});
                check_top=false(size(check));
                if any(check)
                    for k=1:size(this.myCircuitTree,1)
                        if isnumeric(this.myCircuitTree{k,3})
                            if this.myCircuitTree{k,3}==2
                                check_top(k)=strncmp('L',current_set{3},1);
                            else
                                check_top(k)=(this.myCircuitTree{k,3}==str2double(current_set{3}));
                            end
                        elseif ischar(current_set{3})&&ischar(this.myCircuitTree{k,3})
                            check_top(k)=strncmp(this.myCircuitTree{k,3},current_set{3},1);
                        end
                    end
                end
                if any(check&check_top)
                    this.GenerateNetworksButton.Enabled=false;
                else
                    this.GenerateNetworksButton.Enabled=true;
                end
            else
                this.GenerateNetworksButton.Enabled=true;
            end
        end

        function setDefaultValues(this)
            this.CenterFrequencyEditField.Value='1.5';
            this.QFactorEditField.Value='2';
        end
    end

    methods(Access=protected)
        function createIcons(this)
            import matlab.ui.internal.toolstrip.*
            this.SmithIcon=Icon(fullfile(this.IconRoot,'smith_24.png'));
        end

        function initTab1(this)
            this.Tab1=matlab.ui.internal.toolstrip.Tab(getString(message('rf:matchingnetworkgenerator:Tab1Title')));
            this.Tab1.Tag="designTab";
            this.add(this.Tab1);

            this.initSessionSection();
            this.initRequirementsSection();
            this.initConfigurationSection();
            this.initGenerateSection();
            this.initVisualizationSection();
            this.initViewSection();
            this.initExportSection();
            this.setDefaultValues();
            this.disableButtons(false);
        end

        function initSessionSection(this)
            import matlab.ui.internal.toolstrip.*

            sSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:FileStn')));
            sSection.Tag='sSection';

            newCol=sSection.addColumn();
            this.NewSessionButton=Button(getString(message('rf:matchingnetworkgenerator:FileBtn_New')),Icon.NEW_24);
            newCol.add(this.NewSessionButton);


            openCol=sSection.addColumn();
            this.OpenSessionButton=Button(getString(message('rf:matchingnetworkgenerator:FileBtn_Open')),Icon.OPEN_24);
            openCol.add(this.OpenSessionButton);


            saveCol=sSection.addColumn();
            this.SaveSessionButton=SplitButton(getString(message('rf:matchingnetworkgenerator:FileBtn_Save')),Icon.SAVE_24);
            popup=PopupList();
            this.SaveSessionButton.Popup=popup;
            item=ListItem(getString(message('rf:matchingnetworkgenerator:FileListItem_Save')),Icon.SAVE_16);
            item.ShowDescription=false;
            item.Tag='Save';
            add(popup,item);
            item=ListItem(getString(message('rf:matchingnetworkgenerator:FileListItem_SaveAs')),Icon.SAVE_AS_16);
            item.ShowDescription=false;
            item.Tag='SaveAs';
            add(popup,item);
            saveCol.add(this.SaveSessionButton);


            importCol=sSection.addColumn();
            this.ImportButton=Button(getString(message('rf:matchingnetworkgenerator:FileBtn_Import')),Icon.IMPORT_24);
            importCol.add(this.ImportButton);
            this.ImportButton.Tag='ImportButton';
            this.ImportButton.Description=getString(message('rf:matchingnetworkgenerator:FileTip_Import'));

            this.NewSessionButton.Tag='NewSessionButton';
            this.OpenSessionButton.Tag='OpenSessionButton';
            this.SaveSessionButton.Tag='SaveSessionButton';

            this.NewSessionButton.Description=getString(message('rf:matchingnetworkgenerator:FileTip_New'));
            this.OpenSessionButton.Description=getString(message('rf:matchingnetworkgenerator:FileTip_Open'));
            this.SaveSessionButton.Description=getString(message('rf:matchingnetworkgenerator:FileTip_Save'));
        end

        function initRequirementsSection(this)
            import matlab.ui.internal.toolstrip.*

            rSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:ConstraintsStn')));
            rSection.Tag="rSection";

            constraintsColumn=rSection.addColumn();
            this.ConstraintsButton=Button(getString(message('rf:matchingnetworkgenerator:ConstraintsBtn')),Icon.SETTINGS_24);
            constraintsColumn.add(this.ConstraintsButton);

            this.ConstraintsButton.Tag='ConstraintsButton';
            this.ConstraintsButton.Description=getString(message('rf:matchingnetworkgenerator:ConstraintsTip'));
        end



        function initConfigurationSection(this)
            import matlab.ui.internal.toolstrip.*

            cSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:ConfigurationStn')));
            cSection.Tag="cSection";

            category1=GalleryCategory(getString(message('rf:matchingnetworkgenerator:GalleryLE')));

            for i=1:length(this.LumpedList)
                tmpName=char(this.LumpedList(i));
                tmpNameIcon=char(this.LumpedList_icon(i));
                this.galleryItems(i)=ToggleGalleryItem(tmpName,...
                fullfile(matlabroot,'toolbox','rf','rf','+rf',...
                '+internal','+apps','+matchnet','Resources',...
                [tmpNameIcon,'_24.png']));
                this.galleryItems(i).Tag=tmpName;
                this.galleryItems(i).Enabled=false;
                category1.add(this.galleryItems(i));
                this.galleryItems(i).ValueChangedFcn=@(h,~)selectItem(this,this.galleryItems(i));
                if strcmp(tmpName(1),'L')
                    this.galleryItems(i).Description='2-Components';
                end
            end

            popup=GalleryPopup('ShowSelection',true);
            popup.add(category1);
            this.ComponentGallery=Gallery(popup,'MaxColumnCount',3);

            topologyColumn=cSection.addColumn();
            topologyColumn.add(this.ComponentGallery);

            freqLabelsColumn=cSection.addColumn();
            this.CenterFrequencyLabel=Label(getString(message('rf:matchingnetworkgenerator:FreqLabel')));
            freqLabelsColumn.add(this.CenterFrequencyLabel);
            this.QFactorLabel=Label(getString(message('rf:matchingnetworkgenerator:QFLabel')));
            freqLabelsColumn.add(this.QFactorLabel);

            freqFieldsColumn=cSection.addColumn('Width',50);
            this.CenterFrequencyEditField=EditField;
            addlistener(this.CenterFrequencyEditField,'ValueChanged',@(h,e)newChangesAvailable(this));
            freqFieldsColumn.add(this.CenterFrequencyEditField);

            this.QFactorEditField=EditField;
            addlistener(this.QFactorEditField,'ValueChanged',@(h,e)newChangesAvailable(this));
            freqFieldsColumn.add(this.QFactorEditField);

            this.CenterFrequencyLabel.Tag='CenterFrequencyLabel';
            this.CenterFrequencyLabel.Description=getString(message('rf:matchingnetworkgenerator:FreqLabelTip'));
            this.CenterFrequencyEditField.Description=getString(message('rf:matchingnetworkgenerator:FreqLabelTip'));
            this.QFactorLabel.Tag='CenterFrequencyLabel';
            this.QFactorLabel.Description=getString(message('rf:matchingnetworkgenerator:QFLabelTip'));
            this.QFactorEditField.Description=getString(message('rf:matchingnetworkgenerator:QFLabelTip'));
        end

        function initGenerateSection(this)
            import matlab.ui.internal.toolstrip.*

            gSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:DesignStn')));
            gSection.Tag="gSection";

            generateColumn=gSection.addColumn();
            this.GenerateNetworksButton=Button(sprintf(getString(message('rf:matchingnetworkgenerator:GenerateBtn'))),Icon.RUN_24);
            generateColumn.add(this.GenerateNetworksButton);

            this.GenerateNetworksButton.Tag='GenerateNetworksButton';
            this.GenerateNetworksButton.Description=getString(message('rf:matchingnetworkgenerator:GenerateTip'));
        end

        function initVisualizationSection(this)
            import matlab.ui.internal.toolstrip.*

            vSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:VisualizeStn')));
            vSection.Tag="vSection";

            cartColumn=vSection.addColumn();
            this.NewCartesianSplitButton=SplitButton(getString(message('rf:matchingnetworkgenerator:CartesianBtn')),Icon.PLOT_24);
            popup=PopupList();
            this.NewCartesianSplitButton.Popup=popup;
            item=ListItem('S-parameters');
            item.Description=getString(message('rf:matchingnetworkgenerator:CartesianTip'));
            popup.add(item);

            item=ListItem('VSWR');
            item.Description=getString(message('rf:matchingnetworkgenerator:VSWRTip'));
            item.Tag='VSWR';
            popup.add(item);
            cartColumn.add(this.NewCartesianSplitButton);

            smithColumn=vSection.addColumn();
            this.NewSmithSplitButton=SplitButton(getString(message('rf:matchingnetworkgenerator:SmithBtn')),this.SmithIcon);
            popup=PopupList();
            this.NewSmithSplitButton.Popup=popup;

            item=ListItem('Impedance Transformation');
            item.Tag='Smith Ztransformation';
            item.Description=getString(message('rf:matchingnetworkgenerator:SmithZTip'));
            popup.add(item);

            item=ListItem('S-parameters');
            item.Tag='Smith Sparameters';
            item.Description=getString(message('rf:matchingnetworkgenerator:SmithSTip'));
            popup.add(item);
            smithColumn.add(this.NewSmithSplitButton);

            this.NewCartesianSplitButton.Tag='NewCartesianSplitButton';
            this.NewCartesianSplitButton.Description=getString(message('rf:matchingnetworkgenerator:CartesianTip'));
            this.NewSmithSplitButton.Tag='NewSmithSplitButton';
            this.NewSmithSplitButton.Description=getString(message('rf:matchingnetworkgenerator:SmithTip'));
        end


        function initViewSection(this)
            import matlab.ui.internal.toolstrip.*


            section=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:ViewStn')));
            section.Tag='View';

            column=section.addColumn();
            column.Tag='DefaultLayoutColumn';
            this.DefaultLayoutBtn=Button(getString(message('rf:matchingnetworkgenerator:LayoutBtn')),Icon.LAYOUT_24);
            this.DefaultLayoutBtn.Description=getString(message('rf:matchingnetworkgenerator:LayoutTip'));
            this.DefaultLayoutBtn.Tag='DefaultLayoutBtn';
            column.add(this.DefaultLayoutBtn)
        end

        function initExportSection(this)
            import matlab.ui.internal.toolstrip.*

            this.ExportSection=this.Tab1.addSection(getString(message('rf:matchingnetworkgenerator:ExportBtn')));
            this.ExportSection.CollapsePriority=1;
            this.ExportSection.Tag="eSection";

            exportColumn=this.ExportSection.addColumn();
            this.ExportSplitButton=SplitButton(getString(message('rf:matchingnetworkgenerator:ExportBtn')),...
            Icon.CONFIRM_24);
            this.ExportSplitButton.Description=getString(message('rf:matchingnetworkgenerator:ExportTip'));
            popup=PopupList();
            this.ExportSplitButton.Popup=popup;
            item=ListItem(getString(message('rf:matchingnetworkgenerator:ExportCktTitle')));
            item.Description=getString(message('rf:matchingnetworkgenerator:ExportCktDesc'));
            item.Tag='circuit';
            add(popup,item)
            item=ListItem(getString(message('rf:matchingnetworkgenerator:ExportSparamTitle')));
            item.Description=getString(message('rf:matchingnetworkgenerator:ExportSparamDesc'));
            item.Tag='sparameters';
            add(popup,item)

            exportColumn.add(this.ExportSplitButton);

            this.ExportSplitButton.Tag='ExportSplitButton';
            this.ExportSplitButton.Description=getString(message('rf:matchingnetworkgenerator:ExportTip'));
        end












    end
end
