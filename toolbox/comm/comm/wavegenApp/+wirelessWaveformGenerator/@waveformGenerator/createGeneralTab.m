function tab=createGeneralTab(obj,defaultTag)




    tab=matlab.ui.internal.toolstrip.Tab(getString(message('comm:waveformGenerator:GenerationTab')));
    tab.Tag='waveformGenerationTab';

    createFileSection(obj,tab);
    createWaveformSection(obj,tab,defaultTag);

    createGenerationSection(obj,tab);

    createExportSection(obj,tab);

end

function createFileSection(obj,tab)

    sec=getFileSection(obj);
    tab.add(sec);

    obj.pNewSessionBtn=find(tab,'NewDefault');
    obj.pNewSessionBtn.Text=getString(message('comm:waveformGenerator:NewSessionBtn'));
    obj.pNewSessionBtn.Description=getString(message('comm:waveformGenerator:NewSessionTT'));
    obj.pNewSessionBtn.Enabled=false;

    openBtn=find(tab,'open');
    openBtn.Text=getString(message('comm:waveformGenerator:OpenSessionBtn'));
    openBtn.Description=getString(message('comm:waveformGenerator:OpenSessionTT'));

    saveBtn=find(tab,'save');
    saveBtn.Text=getString(message('comm:waveformGenerator:SaveSessionBtn'));
    saveBtn.Description=getString(message('comm:waveformGenerator:SaveSessionTT'));

end

function createWaveformSection(obj,tab,defaultTag)

    import matlab.ui.internal.toolstrip.*

    sec=Section(getString(message('comm:waveformGenerator:WaveTypeSection')));
    sec.Tag='generalSection';
    tab.add(sec);

    topCol=sec.addColumn();

    popup=GalleryPopup('ShowSelection',true,'GalleryItemWidth',80);
    popup.Tag='CreateGalleryPopup';

    regs=obj.pRegistrations;

    cnt=1;
    order=zeros(1,length(regs.UniqueTypes));
    for category=regs.UniqueTypes
        category=category{:};%#ok<FXSET>
        categories(cnt)=GalleryCategory(category);%#ok<AGROW>

        for waveform=regs.Children
            if strcmp(waveform.Type,category)
                icon=Icon(waveform.Label);
                btn=ToggleGalleryItem(waveform.Name,icon);
                btn.Tag=replace(waveform.Name,newline,' ');
                btn.Description=waveform.Description;
                addlistener(btn,'ValueChanged',@(a,b,c)waveformTypeChange(obj,waveform.Name));
                categories(cnt).add(btn);

                if strcmp(waveform.Name,defaultTag)
                    btn.Value=true;
                end
                obj.pWaveformGalleryItems{end+1}=btn;
                order(cnt)=waveform.Order;
            end
        end
        cnt=cnt+1;
    end


    [~,idxs]=sort(order,'descend');
    for idx=1:length(regs.UniqueTypes)
        popup.add(categories(idxs(idx)));
    end

    obj.pWaveformGallery=Gallery(popup,'MaxColumnCount',5,'MinColumnCount',1);
    obj.pWaveformGallery.Tag='waveformGallery';
    obj.pWaveformGallery.Description=getString(message('comm:waveformGenerator:WaveformTypeTT'));
    topCol.add(obj.pWaveformGallery);
end

function createGenerationSection(obj,tab)

    import matlab.ui.internal.toolstrip.*

    sec2=Section(getString(message('comm:waveformGenerator:GenerationSection')));
    sec2.Tag='generateSection';
    tab.add(sec2);

    col=sec2.addColumn();
    impairIcon=Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','phaseNoiseImpairment.png'));
    btn1=ToggleButton(getString(message('comm:waveformGenerator:ImpairBtn')),impairIcon);
    btn1.Tag='impairments';
    btn1.Description=getString(message('comm:waveformGenerator:ImpairTT'));
    col.add(btn1);
    obj.pImpairBtn=btn1;
    obj.pImpairBtn.ValueChangedFcn=@(a,b)toggleImpairments(obj,[]);


    btn1=DropDownButton(getString(message('comm:waveformGenerator:VisualizeBtn')),Icon.PLOT_16);
    btn1.DynamicPopupFcn=@(a,b)updateScopeOptions(obj,[]);
    btn1.Description=getString(message('comm:waveformGenerator:VisualizeTT'));
    btn1.Tag='plots';
    col.add(btn1);
    obj.pPlotsBtn=btn1;

    btn1=Button(getString(message('comm:waveformGenerator:DefaultLayoutBtn')),Icon.LAYOUT_16);
    btn1.Description=getString(message('comm:waveformGenerator:LayoutTT'));
    btn1.Tag='layout';
    btn1.ButtonPushedFcn=@(a,b)defaultLayout(obj,[]);
    col.add(btn1);

    col=sec2.addColumn();
    btn1=Button(getString(message('comm:waveformGenerator:GenerateBtn')),Icon.RUN_24);
    btn1.Tag='generate';
    btn1.Description=getString(message('comm:waveformGenerator:GenerateTT'));
    btn1.ButtonPushedFcn=@(a,b)generateWaveform(obj,tab,true);
    col.add(btn1);
    obj.pGenerateBtn=btn1;
end


function createExportSection(obj,tab)

    import matlab.ui.internal.toolstrip.*

    sec2=Section(getString(message('comm:waveformGenerator:ExportSection')));
    sec2.Tag='exportSection';
    sec2.CollapsePriority=20;

    tab.add(sec2);

    col=sec2.addColumn();
    btn1=SplitButton(getString(message('comm:waveformGenerator:ExportBtn')),Icon.CONFIRM_24);
    btn1.Tag='export';
    btn1.Description=getString(message('comm:waveformGenerator:ExportTT'));
    col.add(btn1);
    obj.pExportBtn=btn1;


    sub_popup=PopupList();

    obj.pExport2WS=ListItem(getString(message('comm:waveformGenerator:exportToWorkspace')));
    obj.pExport2WS.Icon=matlab.ui.internal.toolstrip.Icon.EXPORT_16;
    obj.pExport2WS.ShowDescription=false;
    obj.pExport2WS.Enabled=false;
    obj.pExport2WS.Tag='exportToWorkspace';
    obj.pExport2WS.ItemPushedFcn=@(a,b)exportToWorkspace(obj,[]);

    obj.pExport2File=ListItem(getString(message('comm:waveformGenerator:exportToFile')));
    obj.pExport2File.Icon=matlab.ui.internal.toolstrip.Icon.EXPORT_16;
    obj.pExport2File.ShowDescription=false;
    obj.pExport2File.Enabled=false;
    obj.pExport2File.Tag='exportToFile';
    obj.pExport2File.ItemPushedFcn=@(a,b)exportToFile(obj,[]);

    sub_item3=ListItem(getString(message('comm:waveformGenerator:exportToScript')));
    sub_item3.Icon=matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','ExportMatlabCode_16.png'));
    sub_item3.ShowDescription=false;
    sub_item3.Tag='generateMLCode';
    sub_item3.ItemPushedFcn=@(a,b)exportToScript(obj,[]);

    export2Simulink=ListItem(getString(message('comm:waveformGenerator:exportToSimulink')));
    export2Simulink.Icon=matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','exportModel_16.png'));
    export2Simulink.ShowDescription=false;
    export2Simulink.Tag='exportToSimulink';
    export2Simulink.ItemPushedFcn=@(a,b)exportToSimulink(obj,[]);

    sub_popup.add(obj.pExport2WS);
    sub_popup.add(obj.pExport2File);
    sub_popup.add(sub_item3);
    sub_popup.add(export2Simulink);

    btn1.Popup=sub_popup;

    btn1.ButtonPushedFcn=@(a,b)topLevelExportCallback(obj,[]);
end

function topLevelExportCallback(obj,~)
    if~isempty(obj.pWaveform)

        obj.exportToWorkspace();
    else


        obj.exportToScript();
    end
end
