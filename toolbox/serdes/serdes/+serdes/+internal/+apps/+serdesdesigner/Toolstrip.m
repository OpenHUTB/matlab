classdef Toolstrip<matlab.ui.internal.toolstrip.TabGroup

    properties(Transient=true)
appContainer
statusBar
statusLabel
    end


    properties(Constant)
        SamplesPerSymbolValues=[{'8'};{'16'};{'32'};{'64'};{'128'}];
        ModulationValues=[{'NRZ'};{'PAM3'};{'PAM4'};{'PAM8'};{'PAM16'}];
        SignalingValues=[{'Differential'};{'Single-ended'}];
    end


    properties
AnalysisTabGroup
AnalysisTab

NewBtn
OpenBtn
SaveBtn
DeleteBtn

DefaultLayoutBtn

SymbolTimeLabel
SymbolTimeEdit
SamplesPerSymbolLabel
SamplesPerSymbolDropdown
BERtargetLabel
BERtargetEdit
ModulationLabel
ModulationDropdown
SignalingLabel
SignalingDropdown
JitterBtn

AgcBtn
FfeBtn
VgaBtn
SatAmpBtn
DfeCdrBtn
CdrBtn
CtleBtn
TransparentBtn
AddButtons

PlotSection
PlotBtn
AutoUpdateBtn
AutoUpdateCheckbox
AutoUpdateRadioBtn
ManualUpdateRadioBtn

ExportBtn
    end


    properties(Access=private)
IconRoot
TrashIcon
AgcIcon
FfeIcon
VgaIcon
SatAmpIcon
DfeCdrIcon
CdrIcon
CtleIcon
TransparentIcon

LayoutIcon
JitterIcon
PlotIcon

AutoUpdateIcon
UpdateIcon

ExportScriptIcon
ExportAmiIcon
    end


    methods

        function obj=Toolstrip()
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.statusbar.*;
            title=strcat({getString(message('serdes:serdesdesigner:SerdesDesignerText'))},...
            {' - '},...
            {getString(message('serdes:serdesdesigner:DefaultSerdesDesignName'))});

            appOptions.Title=title;
            appOptions.Tag='SerdesDesigner';
            obj.appContainer=AppContainer(appOptions);
            obj.appContainer.UserDocumentTilingEnabled=0;

            obj.statusBar=StatusBar();
            obj.statusBar.Tag="TestStatusBar";
            obj.statusLabel=StatusLabel();
            obj.statusLabel.Text="";
            obj.statusBar.add(obj.statusLabel);
            obj.appContainer.add(obj.statusBar);

            createIcons(obj);

            createAnalysisTab(obj);
            createFileSection(obj);
            createConfigurationSection(obj);
            createElementsSection(obj);
            createPlotsSection(obj);
            createAnalysisSection(obj);
            createDefaultLayoutSection(obj);
            createExportSection(obj);

            obj.appContainer.add(obj.AnalysisTabGroup);


            qabbtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            qabbtn.DocName='serdesDesigner';
            obj.appContainer.add(qabbtn);


            group=FigureDocumentGroup();
            group.Title="Figures";
            obj.appContainer.add(group);


            setInitialLayout(obj);

            obj.appContainer.Visible=true;
        end


        function name=getButtonName(obj,button)
            switch button
            case obj.AgcBtn
                name=string(message('serdes:serdesdesigner:AgcBtn'));
            case obj.FfeBtn
                name=string(message('serdes:serdesdesigner:FfeBtn'));
            case obj.VgaBtn
                name=string(message('serdes:serdesdesigner:VgaBtn'));
            case obj.SatAmpBtn
                name=string(message('serdes:serdesdesigner:SatAmpBtn'));
            case obj.DfeCdrBtn
                name=string(message('serdes:serdesdesigner:DfeCdrBtn'));
            case obj.CdrBtn
                name=string(message('serdes:serdesdesigner:CdrBtn'));
            case obj.CtleBtn
                name=string(message('serdes:serdesdesigner:CtleBtn'));
            case obj.TransparentBtn
                name=string(message('serdes:serdesdesigner:TransparentBtn'));
            otherwise
                name=string(message('serdes:serdesdesigner:UnspecifiedBtn'));
            end
        end
    end


    methods
        function setInitialLayout(obj)

            newLayout.gridDimensions.w=2;
            newLayout.gridDimensions.h=2;
            newLayout.tileCount=3;
            newLayout.columnWeights=[0.29,0.71];
            newLayout.rowWeights=[0.38,0.62];
            newLayout.tileCoverage=[1,1;2,3];
            document1State.id="canvas_CanvasFig";
            document2State.id="parameters_ParametersFig";
            document3State.id="plots_PlotsFig_Blank";
            document4State.id="plots_PlotsFig_PulseRes";
            document5State.id="plots_PlotsFig_ImpulseRes";
            document6State.id="plots_PlotsFig_StatEye";
            document7State.id="plots_PlotsFig_PrbsWaveform";
            document8State.id="plots_PlotsFig_Contours";
            document9State.id="plots_PlotsFig_Bathtub";
            document10State.id="plots_PlotsFig_BER";
            document11State.id="plots_PlotsFig_COM";
            document12State.id="plots_PlotsFig_Report";
            document13State.id="plots_PlotsFig_CTLE_Transfer_Function";
            tile1Children(1)=document1State;
            tile2Children(1)=document2State;
            tile3Children(1)=document3State;
            tile3Children(2)=document4State;
            tile3Children(3)=document5State;
            tile3Children(4)=document6State;
            tile3Children(5)=document7State;
            tile3Children(6)=document8State;
            tile3Children(7)=document9State;
            tile3Children(8)=document10State;
            tile3Children(9)=document11State;
            tile3Children(10)=document12State;
            tile3Children(11)=document13State;
            tile1Occupancy.children=tile1Children;
            tile2Occupancy.children=tile2Children;
            tile3Occupancy.children=tile3Children;
            newLayout.tileOccupancy=[tile1Occupancy,tile2Occupancy,tile3Occupancy];

            obj.appContainer.DocumentLayout=newLayout;

            obj.appContainer.ToolstripEnabled=1;
        end


        function setTestLayout(obj)
            newLayout.gridDimensions.w=2;
            newLayout.gridDimensions.h=2;
            newLayout.tileCount=3;
            newLayout.columnWeights=[0.29,0.71];
            newLayout.rowWeights=[0.38,0.62];
            newLayout.tileCoverage=[1,1;2,3];
            document1State.id="canvas_CanvasFig";
            document2State.id="parameters_ParametersFig";
            document3State.id="plots_PlotsFig_Blank";
            document4State.id="plots_PlotsFig_PulseRes";
            document5State.id="plots_PlotsFig_ImpulseRes";
            document6State.id="plots_PlotsFig_StatEye";
            document7State.id="plots_PlotsFig_PrbsWaveform";
            document8State.id="plots_PlotsFig_Contours";
            document9State.id="plots_PlotsFig_Bathtub";
            document10State.id="plots_PlotsFig_BER";
            document11State.id="plots_PlotsFig_COM";
            document12State.id="plots_PlotsFig_Report";
            document13State.id="plots_PlotsFig_CTLE_Transfer_Function";
            tile1Children(1)=document1State;
            tile2Children(1)=document2State;
            tile3Children(1)=document3State;
            tile3Children(2)=document4State;
            tile3Children(3)=document5State;
            tile3Children(4)=document6State;
            tile3Children(5)=document7State;
            tile3Children(6)=document8State;
            tile3Children(7)=document9State;
            tile3Children(8)=document10State;
            tile3Children(9)=document11State;
            tile3Children(10)=document12State;
            tile3Children(11)=document13State;
            tile1Occupancy.children=tile1Children;
            tile2Occupancy.children=tile2Children;
            tile3Occupancy.children=tile3Children;
            newLayout.tileOccupancy=[tile1Occupancy,tile3Occupancy,tile2Occupancy];
            obj.appContainer.DocumentLayout=newLayout;

            obj.appContainer.ToolstripEnabled=1;
        end

        function createIcons(obj)
            import matlab.ui.internal.toolstrip.*

            obj.IconRoot=fullfile(matlabroot,'toolbox','serdes','serdes','+serdes','+internal','+apps','+serdesdesigner');
            obj.TrashIcon=Icon(fullfile(obj.IconRoot,'trash_24.png'));
            obj.AgcIcon=Icon(fullfile(obj.IconRoot,'agc_24.png'));
            obj.FfeIcon=Icon(fullfile(obj.IconRoot,'ffe_24.png'));
            obj.VgaIcon=Icon(fullfile(obj.IconRoot,'vga_24.png'));
            obj.SatAmpIcon=Icon(fullfile(obj.IconRoot,'satAmp_24.png'));
            obj.DfeCdrIcon=Icon(fullfile(obj.IconRoot,'dfeCdr_24.png'));
            obj.CdrIcon=Icon(fullfile(obj.IconRoot,'cdr_24.png'));
            obj.CtleIcon=Icon(fullfile(obj.IconRoot,'ctle_24.png'));
            obj.TransparentIcon=Icon(fullfile(obj.IconRoot,'transparent_24.png'));

            obj.LayoutIcon=Icon(fullfile(obj.IconRoot,'layout_24.png'));
            obj.JitterIcon=Icon(fullfile(obj.IconRoot,'jitter_24.png'));
            obj.PlotIcon=Icon(fullfile(obj.IconRoot,'plot_24.png'));
            obj.AutoUpdateIcon=Icon(fullfile(obj.IconRoot,'AutoUpdateBlock_24.png'));
            obj.UpdateIcon=Icon(fullfile(obj.IconRoot,'Run_24.png'));
            obj.ExportScriptIcon=Icon(fullfile(obj.IconRoot,'exportMatlabScript_16.png'));
            obj.ExportAmiIcon=Icon(fullfile(obj.IconRoot,'exportIbisAmi_16.png'));
        end


        function createAnalysisTab(obj)
            import matlab.ui.internal.toolstrip.*
            obj.AnalysisTab=Tab(getString(message('serdes:serdesdesigner:SerdesDesignerText')));
            obj.AnalysisTab.Tag="tab1";

            obj.AnalysisTabGroup=TabGroup();
            obj.AnalysisTabGroup.Tag="globalTabGroup";
            obj.AnalysisTabGroup.add(obj.AnalysisTab);

        end


        function createFileSection(obj)
            import matlab.ui.internal.toolstrip.*
            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:FileSection')));
            section.Tag='File';

            column=addColumn(section);
            button=Button(getString(message('serdes:serdesdesigner:NewBtn')),Icon.NEW_24);
            button.Tag='NewBtn';
            obj.NewBtn=button;
            button.Description=getString(message('serdes:serdesdesigner:NewDesign'));

            button.Enabled=false;
            add(column,button);

            column=addColumn(section);
            button=Button(getString(message('serdes:serdesdesigner:OpenBtn')),Icon.OPEN_24);
            button.Tag='OpenBtn';
            obj.OpenBtn=button;
            button.Description=getString(message('serdes:serdesdesigner:OpenDesign'));
            button.Enabled=false;
            add(column,button);

            column=addColumn(section);
            button=SplitButton(getString(message('serdes:serdesdesigner:SaveBtn')),Icon.SAVE_24);
            button.Tag='SaveBtn';
            obj.SaveBtn=button;
            button.Description=getString(message('serdes:serdesdesigner:SaveDesign'));

            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='SaveBtn_Popup';
            item=ListItem(getString(message('serdes:serdesdesigner:SaveSave')),Icon.SAVE_16);
            item.Tag='Save';
            item.ShowDescription=false;
            add(popup,item);
            item=ListItem(getString(message('serdes:serdesdesigner:SaveSaveAs')),Icon.SAVE_AS_16);
            item.Tag='Save as';
            item.ShowDescription=false;
            add(popup,item)

            button.Enabled=false;
            add(column,button);
        end


        function createDefaultLayoutSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:LayoutSection')));
            section.Tag='Layout';


            column=addColumn(section);

            button=Button(getString(message('serdes:serdesdesigner:DefaultBtn')),obj.LayoutIcon);
            obj.DefaultLayoutBtn=button;
            button.Description=string(message('serdes:serdesdesigner:DefaultLayout'));

            button.Enabled=false;
            add(column,button);
        end



















































































































        function createConfigurationSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:ConfigurationSection')));
            section.Tag='Configuration';



            obj.SymbolTimeLabel=Label(getString(message('serdes:serdesdesigner:SymbolTimeText')));
            obj.SymbolTimeEdit=EditField('100');
            obj.SymbolTimeEdit.Tag='SymbolTime';
            obj.SymbolTimeEdit.Description=string(message('serdes:serdesdesigner:SetSymbolTime'));
            obj.SymbolTimeLabel.Description=obj.SymbolTimeEdit.Description;

            obj.SamplesPerSymbolLabel=Label(getString(message('serdes:serdesdesigner:SamplesPerSymbolText')));
            obj.SamplesPerSymbolDropdown=DropDown();
            obj.SamplesPerSymbolDropdown.replaceAllItems(obj.SamplesPerSymbolValues);
            obj.SamplesPerSymbolDropdown.Value='16';
            obj.SamplesPerSymbolDropdown.Tag='SamplesPerSymbol';
            obj.SamplesPerSymbolDropdown.Description=string(message('serdes:serdesdesigner:SetSamplesPerSymbol'));
            obj.SamplesPerSymbolLabel.Description=obj.SamplesPerSymbolDropdown.Description;

            obj.BERtargetLabel=Label(getString(message('serdes:serdesdesigner:BERtargetText')));
            obj.BERtargetEdit=EditField('1e-6');
            obj.BERtargetEdit.Tag='BERtarget';
            obj.BERtargetEdit.Description=string(message('serdes:serdesdesigner:SetBERtarget'));
            obj.BERtargetLabel.Description=obj.BERtargetEdit.Description;

            obj.ModulationLabel=Label(getString(message('serdes:serdesdesigner:ModulationText')));
            obj.ModulationDropdown=DropDown();
            obj.ModulationDropdown.replaceAllItems(obj.ModulationValues);
            obj.ModulationDropdown.Value='NRZ';
            obj.ModulationDropdown.Tag='Modulation';
            obj.ModulationDropdown.Description=string(message('serdes:serdesdesigner:SetModulation'));
            obj.ModulationLabel.Description=obj.ModulationDropdown.Description;

            obj.SignalingLabel=Label(getString(message('serdes:serdesdesigner:SignalingText')));
            obj.SignalingDropdown=DropDown();
            obj.SignalingDropdown.replaceAllItems(obj.SignalingValues);
            obj.SignalingDropdown.Value='Differential';
            obj.SignalingDropdown.Tag='Signaling';
            obj.SignalingDropdown.Description=string(message('serdes:serdesdesigner:SetSignaling'));
            obj.SignalingLabel.Description=obj.SignalingDropdown.Description;

            column=section.addColumn('HorizontalAlignment','right');
            column.add(obj.SymbolTimeLabel);
            column.add(obj.SamplesPerSymbolLabel);
            column.add(obj.BERtargetLabel);

            column=section.addColumn('width',95);
            column.add(obj.SymbolTimeEdit);
            column.add(obj.SamplesPerSymbolDropdown);
            column.add(obj.BERtargetEdit);




            column=section.addColumn('HorizontalAlignment','right','width',70);

            column.add(obj.ModulationLabel);
            column.add(obj.SignalingLabel);

            column=section.addColumn('width',96);
            column.add(obj.ModulationDropdown);
            column.add(obj.SignalingDropdown);


            column=addColumn(section);
            button=Button(getString(message('serdes:serdesdesigner:JitterBtn')),obj.JitterIcon);
            button.Tag='JitterBtn';
            obj.JitterBtn=button;
            button.Description=string(message('serdes:serdesdesigner:SetJitter'));
            add(column,button);
        end

        function createElementsSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:BlocksSection')));
            section.Tag='Add';

            obj.AgcBtn=GalleryItem(getString(message('serdes:serdesdesigner:AgcBtn')),obj.AgcIcon);
            obj.FfeBtn=GalleryItem(getString(message('serdes:serdesdesigner:FfeBtn')),obj.FfeIcon);
            obj.VgaBtn=GalleryItem(getString(message('serdes:serdesdesigner:VgaBtn')),obj.VgaIcon);
            obj.SatAmpBtn=GalleryItem(getString(message('serdes:serdesdesigner:SatAmpBtn')),obj.SatAmpIcon);
            obj.DfeCdrBtn=GalleryItem(getString(message('serdes:serdesdesigner:DfeCdrBtn')),obj.DfeCdrIcon);
            obj.CdrBtn=GalleryItem(getString(message('serdes:serdesdesigner:CdrBtn')),obj.CdrIcon);
            obj.CtleBtn=GalleryItem(getString(message('serdes:serdesdesigner:CtleBtn')),obj.CtleIcon);
            obj.TransparentBtn=GalleryItem(getString(message('serdes:serdesdesigner:TransparentBtn')),obj.TransparentIcon);

            obj.AgcBtn.Tag='AgcBtn';
            obj.FfeBtn.Tag='FfeBtn';
            obj.VgaBtn.Tag='VgaBtn';
            obj.SatAmpBtn.Tag='SatAmpBtn';
            obj.DfeCdrBtn.Tag='DfeCdrBtn';
            obj.CdrBtn.Tag='CdrBtn';
            obj.CtleBtn.Tag='CtleBtn';
            obj.TransparentBtn.Tag='TransparentBtn';

            obj.AgcBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:AgcBtn'))));
            obj.FfeBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:FfeBtn'))));
            obj.VgaBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:VgaBtn'))));
            obj.SatAmpBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:SatAmpBtn'))));
            obj.DfeCdrBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:DfeCdrBtn'))));
            obj.CdrBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:CdrBtn'))));
            obj.CtleBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:CtleBtn'))));
            obj.TransparentBtn.Description=string(message('serdes:serdesdesigner:AddElement',string(message('serdes:serdesdesigner:TransparentBtn'))));

            category1=GalleryCategory('');
            category1.add(obj.AgcBtn);
            category1.add(obj.FfeBtn);
            category1.add(obj.VgaBtn);
            category1.add(obj.SatAmpBtn);
            category1.add(obj.DfeCdrBtn);
            category1.add(obj.CdrBtn);
            category1.add(obj.CtleBtn);
            category1.add(obj.TransparentBtn);

            popup=GalleryPopup();
            popup.add(category1);
            gallery=Gallery(popup);

            column=section.addColumn();
            column.add(gallery);

            column=addColumn(section);

            button=Button(getString(message('serdes:serdesdesigner:DeleteBtn')),Icon.DELETE_24);
            button.Description=string(message('serdes:serdesdesigner:DeleteElement'));
            button.Tag='DeleteBtn';
            button.Enabled=false;
            obj.DeleteBtn=button;
            add(column,button);

            obj.AddButtons=[obj.AgcBtn,obj.FfeBtn,obj.VgaBtn,obj.SatAmpBtn,obj.DfeCdrBtn...
            ,obj.CdrBtn,obj.CtleBtn,obj.TransparentBtn];
        end

        function createPlotsSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:PlotsSection')));
            section.CollapsePriority=2;
            section.Tag='Plot';
            obj.PlotSection=section;

            column=addColumn(section);

            button=SplitButton(getString(message('serdes:serdesdesigner:AddPlotsBtn')),obj.PlotIcon);
            button.Description=string(message('serdes:serdesdesigner:ShowResults'));
            button.Tag='PlotBtn';
            obj.PlotBtn=button;


            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='PlotBtn_Popup';

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsPulseResponse')));
            item.Tag='Pulse Response';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsImpulseResponse')));
            item.Tag='Impulse Response';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsStatEye')));
            item.Tag='STAT Eye';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsPrbsWaveform')));
            item.Tag='PRBS Waveform';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsContours')));
            item.Tag='Contours';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsBathtub')));
            item.Tag='Bathtub';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsBER')));
            item.Tag='BER';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsCOM')));
            item.Tag='COM';
            item.ShowDescription=false;


            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsReport')));
            item.Tag='Report';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsCTLE')));
            item.Tag='CTLE Transfer Function';
            item.ShowDescription=false;
            add(popup,item);

            item=ListItem(getString(message('serdes:serdesdesigner:AddPlotsAll')));
            item.Tag='All';
            item.ShowDescription=false;
            add(popup,item);

            button.Enabled=false;
            add(column,button);

        end

        function createAnalysisSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:AnalysisSection')));
            section.CollapsePriority=2;
            section.Tag='Plot';
            obj.PlotSection=section;

            column=addColumn(obj.PlotSection,'HorizontalAlignment','left');
            group=ButtonGroup;
            radioBtn=RadioButton(group,getString(message('serdes:serdesdesigner:AnalyzeRadioBtnAuto')));
            radioBtn.Description=string(message('serdes:serdesdesigner:AutoResults'));
            radioBtn.Tag='AutoUpdateRadioBtn';
            radioBtn.Enabled=false;
            radioBtn.Value=true;
            obj.AutoUpdateRadioBtn=radioBtn;
            add(column,radioBtn);
            radioBtn=RadioButton(group,getString(message('serdes:serdesdesigner:AnalyzeRadioBtnManual')));
            radioBtn.Tag='ManualUpdateRadioBtn';
            radioBtn.Enabled=false;
            radioBtn.Value=false;
            obj.ManualUpdateRadioBtn=radioBtn;
            add(column,radioBtn);

            column=addColumn(obj.PlotSection,'HorizontalAlignment','center');
            button=Button(getString(message('serdes:serdesdesigner:AnalyzeBtn')),obj.AutoUpdateIcon);
            button.Description='';
            button.Tag='AutoUpdateBtn';
            button.Enabled=false;
            obj.AutoUpdateBtn=button;
            add(column,button);



            checkbox=CheckBox(getString(message('serdes:serdesdesigner:AutoAnalyzeChk')));
            checkbox.Description=string(message('serdes:serdesdesigner:AutoResults'));
            checkbox.Tag='AutoUpdateCheckbox';
            checkbox.Enabled=false;
            checkbox.Value=true;
            obj.AutoUpdateCheckbox=checkbox;

        end

        function isAuto=isAutoUpdate(obj)
            isAuto=obj.AutoUpdateCheckbox.Value;
        end

        function toggleAutoUpdateButton(obj)
            if obj.AutoUpdateCheckbox.Value

                obj.AutoUpdateBtn.Description='';
                obj.AutoUpdateBtn.Enabled=false;
                obj.AutoUpdateBtn.Icon=obj.AutoUpdateIcon;
            else

                obj.AutoUpdateBtn.Description=string(message('serdes:serdesdesigner:UpdateResults'));
                obj.AutoUpdateBtn.Enabled=true;
                obj.AutoUpdateBtn.Icon=obj.UpdateIcon;
            end
        end

        function createExportSection(obj)
            import matlab.ui.internal.toolstrip.*


            section=obj.AnalysisTab.addSection(getString(message('serdes:serdesdesigner:ExportSection')));
            section.CollapsePriority=1;
            section.Tag='Export';

            column=addColumn(section);
            button=SplitButton(getString(message('serdes:serdesdesigner:ExportBtn')),Icon.CONFIRM_24);
            obj.ExportBtn=button;
            button.Description=string(message('serdes:serdesdesigner:Export'));
            button.Tag='ExportBtn';


            popup=PopupList();
            button.Popup=popup;
            button.Popup.Tag='ExportBtn_Popup';

            if builtin('license','test','SIMULINK')&&~isempty(ver('simulink'))
                item=ListItem(getString(message('serdes:serdesdesigner:ExportSerDesSystemToSimulink')),Icon.CONFIRM_16);
                item.Tag='SerDes Toolbox (Simulink)';
                item.ShowDescription=false;
                add(popup,item);
            end

            item=ListItem(getString(message('serdes:serdesdesigner:ExportSerDesSystemToMATLABscript')),obj.ExportScriptIcon);
            item.Tag='Generate MATLAB script';
            item.ShowDescription=false;
            add(popup,item);

            if builtin('license','test','SIMULINK')&&~isempty(ver('simulink'))
                item=ListItem(getString(message('serdes:serdesdesigner:ExportSerDesSystemToAMIModel')),obj.ExportAmiIcon);
                item.Tag='Make IBIS-AMI';
                item.ShowDescription=false;
                add(popup,item);
            end

            button.Enabled=false;
            add(column,button);
        end
    end
end
