function tab=createRadioTab(obj)




    tab=matlab.ui.internal.toolstrip.Tab(getString(message('comm:waveformGenerator:TransmissionTab')));
    tab.Tag='transmitterTab';


    createHWSection(obj,tab);


    createTxSection(obj,tab);
end

function createHWSection(obj,tab)

    import matlab.ui.internal.toolstrip.*

    sec2=Section(getString(message('comm:waveformGenerator:HardwareSection')));
    sec2.Tag='hwSection';
    tab.add(sec2);


    col=sec2.addColumn();
    popup=GalleryPopup('ShowSelection',true,'GalleryItemWidth',80);
    popup.Tag='TransmitterGalleryPopup';


    categoryICT=GalleryCategory(getString(message('comm:waveformGenerator:GalleryFamilySignalGenerator')));

    btn=ToggleGalleryItem('Instrument',Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','instrument_24.png')));
    btn.Description=getString(message('comm:waveformGenerator:FamilySignalGeneratorDescriptionInstrument'));
    btn.Value=true;
    btn.Tag=btn.Text;
    addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,'Instrument'));
    categoryICT.add(btn);
    obj.pRadioGalleryItems{end+1}=btn;

    popup.add(categoryICT);


    categoryWT=GalleryCategory(getString(message('comm:waveformGenerator:GalleryFamilyRadioConfiguration')));

    wtradionames=["USRP N310","USRP N320","USRP N321","USRP X310"];
    for name=1:length(wtradionames)
        btn=ToggleGalleryItem(wtradionames(name),Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','SDR_24.png')));
        btn.Description=getString(message('comm:waveformGenerator:FamilyRadioConfigurationDescription',wtradionames(name)));
        btn.Tag=btn.Text;
        addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,btn.Tag,'Wireless Testbench'));
        categoryWT.add(btn);
        obj.pRadioGalleryItems{end+1}=btn;
    end

    popup.add(categoryWT);


    categorySDR=GalleryCategory(getString(message('comm:waveformGenerator:GalleryFamilySDR')));

    btn=ToggleGalleryItem('Pluto',Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','SDR_24.png')));
    btn.Description=getString(message('comm:waveformGenerator:FamilySDRDescriptionPluto'));
    btn.Tag=btn.Text;
    addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,btn.Tag));
    categorySDR.add(btn);
    obj.pRadioGalleryItems{end+1}=btn;


    btn=ToggleGalleryItem(sprintf('USRP\nB/N/X'),Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','SDR_24.png')));
    btn.Description=getString(message('comm:waveformGenerator:FamilySDRDescriptionUSRPBNX'));
    btn.Tag=replace(btn.Text,newline,' ');
    addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,btn.Tag));
    categorySDR.add(btn);
    obj.pRadioGalleryItems{end+1}=btn;

    btn=ToggleGalleryItem(sprintf('USRP\nE'),Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','SDR_24.png')));
    btn.Description=getString(message('comm:waveformGenerator:FamilySDRDescriptionUSRPE'));
    btn.Tag=replace(btn.Text,newline,' ');
    addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,btn.Tag));
    categorySDR.add(btn);
    obj.pRadioGalleryItems{end+1}=btn;

    btn=ToggleGalleryItem(sprintf('Zynq\nBased'),Icon(fullfile(matlabroot,'toolbox','comm','comm','wavegenApp','+wirelessWaveformGenerator','icons','SDR_24.png')));
    btn.Description=getString(message('comm:waveformGenerator:FamilySDRDescriptionZynq'));
    btn.Tag=replace(btn.Text,newline,' ');
    addlistener(btn,'ValueChanged',@(a,b,c)radioTypeChange(obj,btn.Tag));
    categorySDR.add(btn);
    obj.pRadioGalleryItems{end+1}=btn;

    popup.add(categorySDR);



    gallery=Gallery(popup,'MaxColumnCount',5,'MinColumnCount',1);
    gallery.Tag='transmitterGallery';
    gallery.Description=getString(message('comm:waveformGenerator:SelectRadioTT'));
    col.add(gallery);


    col=sec2.addColumn();
    btn1=Button(getString(message('comm:waveformGenerator:FindHardwareBtn')),Icon.SEARCH_24);
    btn1.Tag='findHardware';
    btn1.Description=getString(message('comm:waveformGenerator:ConfigureHWTT'));
    btn1.ButtonPushedFcn=@(a,b)findRadios(obj);
    col.add(btn1);
    obj.pSearchHWBtn=btn1;

end

function createTxSection(obj,tab)

    import matlab.ui.internal.toolstrip.*

    sec2=Section(getString(message('comm:waveformGenerator:TransmissionSection')));
    sec2.Tag='txSection';
    tab.add(sec2);

    col=sec2.addColumn();
    obj.pTransmitBtn=Button(getString(message('comm:waveformGenerator:TransmitBtn')),Icon.RUN_24);
    obj.pTransmitBtn.Tag='transmitWaveform';
    obj.pTransmitBtn.Enabled=false;
    obj.pTransmitBtn.Description=getString(message('comm:waveformGenerator:Configure2TransmitTT'));
    obj.pTransmitBtn.ButtonPushedFcn=@(a,b)transmitWaveform(obj,tab);
    col.add(obj.pTransmitBtn);

    col=sec2.addColumn();


    obj.pExportTxBtn=Button(getString(message('comm:waveformGenerator:ExportMLFromTransmit')),Icon(fullfile(matlabroot,'toolbox','shared','dsp','webscopes','dspwebscopesutils','js','images','generate_script_24.png')));
    obj.pExportTxBtn.Tag='exportMLfromTransmit';
    obj.pExportTxBtn.Enabled=false;
    obj.pExportTxBtn.Description=getString(message('comm:waveformGenerator:ExportMLFromTransmitTT'));
    obj.pExportTxBtn.ButtonPushedFcn=@(a,b)exportToScript(obj,[]);
    col.add(obj.pExportTxBtn);

end
