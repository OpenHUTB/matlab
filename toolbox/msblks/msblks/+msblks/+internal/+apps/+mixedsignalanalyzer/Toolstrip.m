classdef Toolstrip<matlab.ui.internal.toolstrip.TabGroup




    properties(Transient=true)
appContainer
statusBar
statusLabel
    end

    properties
AnalysisTabGroup
AnalysisTab

FileSection
FileBtn_New
FileBtn_Open
FileBtn_Import
FileBtn_Save
FileBtn_Update

AnalysisSection
        AnalysisGallery matlab.ui.internal.toolstrip.Gallery
AnalysisButtons
AnalysisBtn_DisplayWaveform
AnalysisBtn_Custom
        AnalysisBtn_New matlab.ui.internal.toolstrip.Button
        AnalysisCustomButtons matlab.ui.internal.toolstrip.GalleryItem
        AnalysisCustomCategory matlab.ui.internal.toolstrip.GalleryCategory
        AnalysisCustomPath char

MetricsSection
MetricsGallery
MetricsButtons
MetricsBtn_TrendChart
MetricsBtn_Histogram
MetricsBtn_PieChart
MetricsBtn_Table

FilterSection
FilterBtn

PlotSection
PlotBtn
PlotListItem_SetPlotScales

MarkersSection
MarkersBtn_Vertical
MarkersTxt_Vertical
MarkersBtn_Horizontal
MarkersTxt_Horizontal
MarkersBtn_DeltaXY
MarkersTxt_DeltaXY
MarkersChk_SnapToWaveform
MarkersChk_SnapToData
MarkersChk_ShowXY

DefaultLayoutSection
DefaultLayoutBtn

ExportSection
ExportBtn

tileDataChildren
tilePlotsChildren
tileOptionsChildren
    end
    properties(Access=private)
View

IconRoot

FileIcon_New
FileIcon_Open
FileIcon_Import
FileIcon_Save
FileIcon_Update_24
FileIcon_Update_16

AnalysisIcon_DisplayWaveform
AnalysisIcon_AnalysisFunction
AnalysisIcon_Custom
AnalysisIcon_New

MetricsIcon_TrendChart
MetricsIcon_Histogram
MetricsIcon_PieChart
MetricsIcon_Table

FilterIcon_16
FilterIcon_24

PlotIcon_16
PlotIcon_24

MarkersIcon_Vertical
MarkersIcon_Horizontal
MarkersIcon_DeltaXY

DefaultLayoutIcon

ReportIcon
ScriptIcon
    end

    methods
        function obj=Toolstrip(View)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.statusbar.*;

            obj.View=View;

            title=strcat({getString(message('msblks:mixedsignalanalyzer:MixedSignalAnalyzerText'))},...
            {' - '},...
            {getString(message('msblks:mixedsignalanalyzer:DefaultMixedSignalAnalysisName'))});

            appOptions.Title=title;
            appOptions.Tag="MixedSignalAnalyzer_"+matlab.lang.internal.uuid;
            obj.appContainer=AppContainer(appOptions);

            createIcons(obj);


            createAnalysisTab(obj);
            createFileSection(obj);
            createFilterSection(obj);
            createPlotSection(obj);
            createAnalysisSection(obj);
            createMetricsSection(obj);
            createCustomAnalysisSection(obj);

            createDefaultLayoutSection(obj);
            createExportSection(obj);

            obj.appContainer.add(obj.AnalysisTabGroup);


            qabbtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            qabbtn.DocName='msblks/app_mixedSignalAnalyzer';
            obj.appContainer.add(qabbtn);






            group=FigureDocumentGroup();
            group.Title="Figures";
            obj.appContainer.add(group);


            setInitialLayout(obj);

            obj.appContainer.Visible=true;
        end

    end

    methods
        function setInitialLayout(obj)

            newLayout.gridDimensions.w=3;
            newLayout.gridDimensions.h=1;
            newLayout.tileCount=3;
            newLayout.columnWeights=[0.25,0.50,0.15];
            newLayout.rowWeights=1.0;
            newLayout.tileCoverage=[1,2,3];


            if isempty(obj.tileDataChildren)||isempty(obj.tilePlotsChildren)||isempty(obj.tileOptionsChildren)





                documentDataState.id="data_DataFig";
                documentPlotsState.id="plots_BlankPlotFig";
                documentOptionsState.id="options_OptionsFig";
                obj.tileDataChildren=documentDataState;
                obj.tilePlotsChildren=documentPlotsState;
                obj.tileOptionsChildren=documentOptionsState;
            end


            tileDataOccupancy.children=obj.tileDataChildren;
            tilePlotsOccupancy.children=obj.tilePlotsChildren;
            tileOptionsOccupancy.children=obj.tileOptionsChildren;
            newLayout.tileOccupancy=[tileDataOccupancy,tilePlotsOccupancy,tileOptionsOccupancy];
            obj.appContainer.DocumentLayout=newLayout;
            obj.appContainer.ToolstripEnabled=1;
        end
        function addPlotToLayout(obj,plotTitle)
            documentPlotsState.id=strcat("plots_",plotTitle);
            obj.tilePlotsChildren(end+1)=documentPlotsState;
        end
        function removePlotFromLayout(obj,plotTitle)
            documentPlotsState.id=strcat("plots_",plotTitle);
            for i=1:length(obj.tilePlotsChildren)
                if strcmp(obj.tilePlotsChildren(i).id,documentPlotsState.id)
                    obj.tilePlotsChildren(i)=[];
                    return;
                end
            end
        end

        function createIcons(obj)
            import matlab.ui.internal.toolstrip.*

            obj.IconRoot=fullfile(matlabroot,'toolbox','msblks','msblks','+msblks','+internal','+apps','+mixedsignalanalyzer');

            obj.FileIcon_New=Icon.NEW_24;
            obj.FileIcon_Import=Icon.IMPORT_24;
            obj.FileIcon_Open=Icon.OPEN_24;
            obj.FileIcon_Save=Icon.SAVE_24;
            obj.FileIcon_Update_24=Icon(fullfile(obj.IconRoot,'goalUpdate_24.png'));
            obj.FileIcon_Update_16=Icon(fullfile(obj.IconRoot,'goalUpdate_16.png'));

            obj.AnalysisIcon_DisplayWaveform=Icon(fullfile(obj.IconRoot,'add-analysis-24.png'));
            obj.AnalysisIcon_AnalysisFunction=Icon(fullfile(obj.IconRoot,'analysis-24.png'));
            obj.AnalysisIcon_Custom=Icon(fullfile(obj.IconRoot,'custom-analysis-24.png'));
            obj.AnalysisIcon_New=Icon.NEW_24;

            obj.MetricsIcon_TrendChart=Icon(fullfile(obj.IconRoot,'trend-60.png'));
            obj.MetricsIcon_Histogram=Icon(fullfile(obj.IconRoot,'histogram-60.png'));
            obj.MetricsIcon_PieChart=Icon(fullfile(obj.IconRoot,'pie-60.png'));
            obj.MetricsIcon_Table=Icon(fullfile(obj.IconRoot,'bar-60.png'));

            obj.FilterIcon_16=Icon(fullfile(obj.IconRoot,'filter_16.png'));
            obj.FilterIcon_24=Icon(fullfile(obj.IconRoot,'filter_24.png'));

            obj.PlotIcon_16=Icon(fullfile(obj.IconRoot,'add-display-16.png'));
            obj.PlotIcon_24=Icon(fullfile(obj.IconRoot,'add-display-24.png'));

            obj.MarkersIcon_Vertical=Icon(fullfile(obj.IconRoot,'vertical-cursor-16.png'));
            obj.MarkersIcon_Horizontal=Icon(fullfile(obj.IconRoot,'horizontal-cursor-16.png'));
            obj.MarkersIcon_DeltaXY=Icon(fullfile(obj.IconRoot,'scatter-20.png'));

            obj.DefaultLayoutIcon=Icon(fullfile(obj.IconRoot,'layout_24.png'));

            obj.ReportIcon=Icon(fullfile(obj.IconRoot,'generate-report-16.png'));
            obj.ScriptIcon=Icon(fullfile(obj.IconRoot,'exportMatlabScript_16.png'));
        end

        function createAnalysisTab(obj)
            import matlab.ui.internal.toolstrip.*

            obj.AnalysisTab=Tab(getString(message('msblks:mixedsignalanalyzer:MixedSignalAnalyzerText')));
            obj.AnalysisTab.Tag='tab1';

            obj.AnalysisTabGroup=TabGroup();
            obj.AnalysisTabGroup.Tag="globalTabGroup";
            obj.AnalysisTabGroup.add(obj.AnalysisTab);
        end

        function createFileSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.FileSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:FileSection')));
            obj.FileSection.Tag='FileSection';

            obj.FileBtn_New=Button(getString(message('msblks:mixedsignalanalyzer:FileBtn_New')),obj.FileIcon_New);
            obj.FileBtn_Open=Button(getString(message('msblks:mixedsignalanalyzer:FileBtn_Open')),obj.FileIcon_Open);
            obj.FileBtn_Save=SplitButton(getString(message('msblks:mixedsignalanalyzer:FileBtn_Save')),obj.FileIcon_Save);
            obj.FileBtn_Import=SplitButton(getString(message('msblks:mixedsignalanalyzer:FileBtn_Import')),obj.FileIcon_Import);
            obj.FileBtn_Update=SplitButton(getString(message('msblks:mixedsignalanalyzer:FileBtn_Update')),obj.FileIcon_Update_24);

            obj.FileBtn_New.Tag='FileBtn_New';
            obj.FileBtn_Open.Tag='FileBtn_Open';
            obj.FileBtn_Save.Tag='FileBtn_SaveBtn';
            obj.FileBtn_Import.Tag='FileBtn_Import';
            obj.FileBtn_Update.Tag='FileBtn_UpdateBtn';

            obj.FileBtn_New.Description=getString(message('msblks:mixedsignalanalyzer:FileTip_New'));
            obj.FileBtn_Open.Description=getString(message('msblks:mixedsignalanalyzer:FileTip_Open'));
            obj.FileBtn_Save.Description=getString(message('msblks:mixedsignalanalyzer:FileTip_Save'));
            obj.FileBtn_Import.Description=getString(message('msblks:mixedsignalanalyzer:FileTip_Import'));
            obj.FileBtn_Update.Description=getString(message('msblks:mixedsignalanalyzer:FileTip_Update'));

            column=addColumn(obj.FileSection);add(column,obj.FileBtn_New);
            column=addColumn(obj.FileSection);add(column,obj.FileBtn_Open);
            column=addColumn(obj.FileSection);add(column,obj.FileBtn_Save);
            column=addColumn(obj.FileSection);add(column,obj.FileBtn_Import);
            column=addColumn(obj.FileSection);add(column,obj.FileBtn_Update);


            popup=PopupList();
            obj.FileBtn_Save.Popup=popup;
            obj.FileBtn_Save.Popup.Tag='FileBtn_Save_Popup';

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_Save')),Icon.SAVE_16);
            item.Tag='Save';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_SaveAs')),Icon.SAVE_AS_16);
            item.Tag='SaveAs';
            item.ShowDescription=false;
            add(popup,item)


            popup=PopupList();
            obj.FileBtn_Import.Popup=popup;
            obj.FileBtn_Import.Popup.Tag='FileBtn_Import_Popup';





















            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_ImportFile')));
            item.Tag='Import file';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_ImportWorkspace')));
            item.Tag='Import workspace';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_ImportAdeInfoDatabase')));
            item.Tag='Import AdeInfo database';
            item.ShowDescription=false;
            add(popup,item)


            popup=PopupList();
            obj.FileBtn_Update.Popup=popup;
            obj.FileBtn_Update.Popup.Tag='FileBtn_Update_Popup';





















            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_UpdateFile')));
            item.Tag='Update file';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_UpdateWorkspace')));
            item.Tag='Update workspace';
            item.ShowDescription=false;
            add(popup,item)

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_UpdateAdeInfoDatabase')));
            item.Tag='Update AdeInfo database';
            item.ShowDescription=false;
            add(popup,item)
        end

        function createCustomAnalysisSection(obj)

            files=dir(fullfile(prefdir,'msblks','+msaCustom','*Wrapper.m'));
            if~isempty(files)
                addpath(fullfile(prefdir,'msblks'));
                path=fullfile(prefdir,'msblks','+msaCustom');
                for i=1:length(files)
                    functionName=files(i).name(1:end-9);
                    obj.UpdateAnalysisGallery(path,functionName);
                end
            end
        end

        function createAnalysisSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.AnalysisSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:AnalysisSection')));
            obj.AnalysisSection.Tag='AnalysisSection';


            files=dir(fullfile(matlabroot,'toolbox','msblks','msblks','+msblks','+internal','+mixedsignalanalysis','*Wrapper.m'));
            if isempty(files)
                files=dir(fullfile(matlabroot,'toolbox','msblks','msblks','+msblks','+internal','+mixedsignalanalysis','*Wrapper.p'));
            end


            obj.AnalysisBtn_DisplayWaveform=GalleryItem(getString(message('msblks:mixedsignalanalyzer:AnalysisBtn_DisplayWaveform')),obj.AnalysisIcon_DisplayWaveform);
            obj.AnalysisBtn_DisplayWaveform.Tag='AnalysisBtn_DisplayWaveform';






            obj.AnalysisButtons{1}=obj.AnalysisBtn_DisplayWaveform;

            obj.AnalysisBtn_New=Button(getString(message('msblks:mixedsignalanalyzer:AnalysisBtn_New')),obj.AnalysisIcon_New);
            obj.AnalysisBtn_New.Tag='AnalysisBtn_New';
            obj.AnalysisBtn_New.Description=getString(message('msblks:mixedsignalanalyzer:AnalysisTip_New'));

            obj.AnalysisBtn_New.ButtonPushedFcn=@(h,~)obj.addCustomFunction();

            if~isempty(files)
                for i=1:length(files)
                    functionName=files(i).name(1:end-13);
                    obj.AnalysisButtons{i+1}=GalleryItem(functionName,obj.AnalysisIcon_AnalysisFunction);
                    obj.AnalysisButtons{i+1}.Tag=['AnalysisBtn_',functionName];

                end
            end


            category1=GalleryCategory(getString(message('msblks:mixedsignalanalyzer:AnalysisBuiltIn')));
            for i=1:length(obj.AnalysisButtons)
                category1.add(obj.AnalysisButtons{i});
            end

            popup=GalleryPopup();
            popup.add(category1);
            obj.AnalysisGallery=Gallery(popup,'MaxColumnCount',3);


            column=obj.AnalysisSection.addColumn();
            column.add(obj.AnalysisGallery);
            column=addColumn(obj.AnalysisSection);
            add(column,obj.AnalysisBtn_New);

            addColumn(obj.AnalysisSection);
        end

        function createMetricsSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.MetricsSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:MetricsSection')));
            obj.MetricsSection.Tag='MetricsSection';

            obj.MetricsBtn_TrendChart=GalleryItem(getString(message('msblks:mixedsignalanalyzer:MetricsBtn_TrendChart')),obj.MetricsIcon_TrendChart);
            obj.MetricsBtn_Histogram=GalleryItem(getString(message('msblks:mixedsignalanalyzer:MetricsBtn_Histogram')),obj.MetricsIcon_Histogram);
            obj.MetricsBtn_PieChart=GalleryItem(getString(message('msblks:mixedsignalanalyzer:MetricsBtn_PieChart')),obj.MetricsIcon_PieChart);
            obj.MetricsBtn_Table=GalleryItem(getString(message('msblks:mixedsignalanalyzer:MetricsBtn_Table')),obj.MetricsIcon_Table);

            obj.MetricsBtn_TrendChart.Tag='MetricsBtn_TrendChart';
            obj.MetricsBtn_Histogram.Tag='MetricsBtn_Histogram';
            obj.MetricsBtn_PieChart.Tag='MetricsBtn_PieChart';
            obj.MetricsBtn_Table.Tag='MetricsBtn_Table';

            obj.MetricsBtn_TrendChart.Description=getString(message('msblks:mixedsignalanalyzer:MetricsTip_TrendChart'));
            obj.MetricsBtn_Histogram.Description=getString(message('msblks:mixedsignalanalyzer:MetricsTip_Histogram'));
            obj.MetricsBtn_PieChart.Description=getString(message('msblks:mixedsignalanalyzer:MetricsTip_PieChart'));
            obj.MetricsBtn_Table.Description=getString(message('msblks:mixedsignalanalyzer:MetricsTip_Table'));

            category1=GalleryCategory('');
            category1.add(obj.MetricsBtn_TrendChart);




            popup=GalleryPopup('GalleryItemTextLineCount',1);
            popup.add(category1);
            obj.MetricsGallery=Gallery(popup,'MaxColumnCount',1);

            column=obj.MetricsSection.addColumn();
            column.add(obj.MetricsGallery);

            addColumn(obj.MetricsSection);

            obj.MetricsButtons={
            obj.MetricsBtn_TrendChart,...
            obj.MetricsBtn_Histogram,...
            obj.MetricsBtn_PieChart,...
            obj.MetricsBtn_Table,...
            };
        end

        function createMarkersSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.MarkersSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:MarkersSection')));
            obj.MarkersSection.Tag='MarkersSection';

            column=addColumn(obj.MarkersSection);

            obj.MarkersBtn_Vertical=Button(getString(message('msblks:mixedsignalanalyzer:MarkersBtn_Vertical')),obj.MarkersIcon_Vertical);
            obj.MarkersBtn_Vertical.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_Vertical'));
            obj.MarkersBtn_Vertical.Tag='MarkersBtn_Vertical';

            obj.MarkersBtn_Horizontal=Button(getString(message('msblks:mixedsignalanalyzer:MarkersBtn_Horizontal')),obj.MarkersIcon_Horizontal);
            obj.MarkersBtn_Horizontal.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_Horizontal'));
            obj.MarkersBtn_Horizontal.Tag='MarkersBtn_Horizontal';

            obj.MarkersBtn_DeltaXY=Button(getString(message('msblks:mixedsignalanalyzer:MarkersBtn_DeltaXY')),obj.MarkersIcon_DeltaXY);
            obj.MarkersBtn_DeltaXY.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_DeltaXY'));
            obj.MarkersBtn_DeltaXY.Tag='MarkersBtn_DeltaXY';

            add(column,obj.MarkersBtn_Vertical);
            add(column,obj.MarkersBtn_Horizontal);
            add(column,obj.MarkersBtn_DeltaXY);

            column=addColumn(obj.MarkersSection);

            obj.MarkersChk_SnapToWaveform=CheckBox(getString(message('msblks:mixedsignalanalyzer:MarkersChk_SnapToWaveform')));
            obj.MarkersChk_SnapToWaveform.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_SnapToWaveform'));
            obj.MarkersChk_SnapToWaveform.Tag='MarkersChk_SnapToWaveform';
            obj.MarkersChk_SnapToWaveform.Value=true;

            obj.MarkersChk_SnapToData=CheckBox(getString(message('msblks:mixedsignalanalyzer:MarkersChk_SnapToData')));
            obj.MarkersChk_SnapToData.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_SnapToData'));
            obj.MarkersChk_SnapToData.Tag='MarkersChk_SnapToData';
            obj.MarkersChk_SnapToData.Value=true;

            obj.MarkersChk_ShowXY=CheckBox(getString(message('msblks:mixedsignalanalyzer:MarkersChk_ShowXY')));
            obj.MarkersChk_ShowXY.Description=string(message('msblks:mixedsignalanalyzer:MarkersTip_ShowXY'));
            obj.MarkersChk_ShowXY.Tag='MarkersChk_ShowXY';
            obj.MarkersChk_ShowXY.Value=true;

            column.add(obj.MarkersChk_SnapToWaveform);
            column.add(obj.MarkersChk_SnapToData);
            column.add(obj.MarkersChk_ShowXY);

            obj.MarkersBtn_Vertical.Enabled=false;
            obj.MarkersBtn_Horizontal.Enabled=false;
            obj.MarkersBtn_DeltaXY.Enabled=false;
            obj.MarkersChk_SnapToWaveform.Enabled=false;
            obj.MarkersChk_SnapToData.Enabled=false;
            obj.MarkersChk_ShowXY.Enabled=false;
        end

        function createFilterSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.FilterSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:FilterSection')));
            obj.FilterSection.Tag='FilterSection';

            column=addColumn(obj.FilterSection);

            obj.FilterBtn=Button(getString(message('msblks:mixedsignalanalyzer:FilterBtn')),obj.FilterIcon_24);
            obj.FilterBtn.Description=string(message('msblks:mixedsignalanalyzer:FilterTip'));
            obj.FilterBtn.Tag='FilterBtn';

            add(column,obj.FilterBtn);
        end

        function createPlotSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.PlotSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:PlotSection')));
            obj.PlotSection.Tag='PlotSection';

            column=addColumn(obj.PlotSection);


            obj.PlotBtn=SplitButton(getString(message('msblks:mixedsignalanalyzer:PlotBtn')),obj.PlotIcon_24);
            obj.PlotBtn.Description=string(message('msblks:mixedsignalanalyzer:PlotTip'));
            obj.PlotBtn.Tag='PlotBtn';


            popup=PopupList();
            obj.PlotBtn.Popup=popup;
            obj.PlotBtn.Popup.Tag='PlotBtn_Popup';


            item=ListItem(getString(message('msblks:mixedsignalanalyzer:PlotListItem_AddPlot')),obj.PlotIcon_16);
            item.Tag='PlotListItem_AddPlot';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:PlotListItem_RenamePlot')));
            item.Tag='PlotListItem_RenamePlot';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:PlotListItem_SetPlotScales')));
            item.Tag='PlotListItem_SetPlotScales';
            item.ShowDescription=false;
            add(popup,item);
            obj.PlotListItem_SetPlotScales=item;

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:PlotListItem_TogglePlotGrid')));
            item.Tag='PlotListItem_TogglePlotGrid';
            item.ShowDescription=false;
            add(popup,item);

            add(column,obj.PlotBtn);
        end

        function createDefaultLayoutSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.DefaultLayoutSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:DefaultLayoutSection')));
            obj.DefaultLayoutSection.Tag='Layout';


            column=addColumn(obj.DefaultLayoutSection);

            button=Button(getString(message('msblks:mixedsignalanalyzer:DefaultLayoutBtn')),obj.DefaultLayoutIcon);
            obj.DefaultLayoutBtn=button;
            button.Description=string(message('msblks:mixedsignalanalyzer:DefaultLayoutTip'));

            add(column,button);
        end

        function createExportSection(obj)
            import matlab.ui.internal.toolstrip.*


            obj.ExportSection=obj.AnalysisTab.addSection(getString(message('msblks:mixedsignalanalyzer:ExportSection')));
            obj.ExportSection.CollapsePriority=1;
            obj.ExportSection.Tag='ExportSection';

            column=addColumn(obj.ExportSection);

            obj.ExportBtn=SplitButton(getString(message('msblks:mixedsignalanalyzer:ExportBtn')),Icon.CONFIRM_24);
            obj.ExportBtn.Description=string(message('msblks:mixedsignalanalyzer:ExportTip'));
            obj.ExportBtn.Tag='ExportBtn';


            popup=PopupList();
            obj.ExportBtn.Popup=popup;
            obj.ExportBtn.Popup.Tag='ExportBtn_Popup';







            item=ListItem(getString(message('msblks:mixedsignalanalyzer:ExportListItem_ToReport')),obj.ReportIcon);
            item.Tag='ExportListItem_ToReport';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('msblks:mixedsignalanalyzer:FileListItem_SaveGenericFile')));
            item.Tag='Save generic database file';
            item.ShowDescription=false;
            add(popup,item)








            add(column,obj.ExportBtn);
        end
    end

    methods
        function addCustomFunction(obj)


            app=msblks.internal.mixedsignalanalysis.BaseAnalysis.addAnalysisDlgBox;

            addlistener(app,'CreateIcon','PostSet',@(~,~)obj.UpdateAnalysisGallery(fullfile(prefdir,'msblks','+msaCustom'),app.FunctionNameEditField.Value));






        end

        function UpdateAnalysisGallery(obj,path,functionName)

            import matlab.ui.internal.toolstrip.*



            if isempty(obj.AnalysisCustomButtons)
                obj.AnalysisCustomCategory=GalleryCategory(getString(message('msblks:mixedsignalanalyzer:AnalysisCustom')));


                obj.AnalysisCustomButtons=GalleryItem(functionName,obj.AnalysisIcon_Custom);
                obj.AnalysisCustomButtons.Tag=['CustomAnalysisBtn_',functionName];
                obj.AnalysisCustomButtons.Enabled=false;
                obj.AnalysisCustomCategory.add(obj.AnalysisCustomButtons);


                obj.AnalysisGallery.Popup.add(obj.AnalysisCustomCategory);
            else
                NumButtons=length(obj.AnalysisCustomButtons);
                obj.AnalysisCustomButtons(NumButtons+1)=GalleryItem(functionName,obj.AnalysisIcon_Custom);
                obj.AnalysisCustomButtons(NumButtons+1).Tag=['CustomAnalysisBtn_',functionName];
                obj.AnalysisCustomButtons(NumButtons+1).Enabled=false;
                obj.AnalysisCustomCategory.add(obj.AnalysisCustomButtons(NumButtons+1));
            end


            obj.AnalysisCustomButtons(end).ItemPushedFcn=@(h,e)obj.CallCustomAnalysisFcn(h,e);



        end

        function CallCustomAnalysisFcn(obj,h,~)


            obj.View.runAnalysisCustomFunction(h.Text);
        end
    end

end
