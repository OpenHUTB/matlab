function[info,e]=getFPGADesignWidgets(hObj,groupName)





    info.ParameterGroups={};
    info.Parameters={};
    e=[];
    grpname=DAStudio.message(['codertarget:ui:FPGADesignGroup',groupName]);

    if~l_tgtCreation(hObj)
        if~codertarget.data.isParameterInitialized(hObj,'TargetServices')
            codertarget.data.setParameterValue(hObj,'TargetServices',struct('Running',false));
        end
    end

    try
        if~l_tgtCreation(hObj)
            hardware=codertarget.targethardware.getTargetHardware(hObj);
            if isempty(hardware)
                return
            end
        else
            hardware=hObj;
        end

        if ismember(hardware.Name,...
            codertarget.internal.getCustomHardwareBoardNamesForSoC)

            return;
        end



        info.ParameterGroups={grpname};
        ptagbase='FPGADesign';
        ii=0;

        switch groupName
        case 'TopLevel'
            [ii,info]=l_TopLevelParams(hObj,hardware,ptagbase,ii,info);%#ok<ASGLU> % synth opt, jtag mstr, ps, irq latency, a4l clk, IP clk
        case 'MemControllersPS'
            [ii,info]=l_MemControllerPSParams(hObj,hardware,ptagbase,ii,info);%#ok<ASGLU> % ctrlr clk/dw, overhead, rd/wr first/last
        case 'MemControllersPL'
            [ii,info]=l_MemControllerPLParams(hObj,hardware,ptagbase,ii,info);%#ok<ASGLU> % ctrlr clk/dw, overhead, rd/wr first/last
        case 'Debug'
            [ii,info]=l_DebugParams(hObj,hardware,ptagbase,ii,info);%#ok<ASGLU> % apm, apmmode, atg
        case 'Bogus'
            [ii,info]=l_BogusParams(hObj,hardware,ptagbase,ii,info);%#ok<ASGLU> % to avoid getting CPU clock in target definition
        otherwise
            error('(internal) bad FPGA design group name for Target hardware resources');
        end

    catch e
        info.ParameterGroups={};
        info.Parameters={};
    end
end
function tf=l_tgtCreation(hObj)

    tf=isa(hObj,'codertarget.targethardware.TargetHardwareInfo');
end



function[ii,info]=l_TopLevelParams(hObj,hardware,ptagbase,ii,info)
    PVIS='1';PEN='1';useCbTrue=true;useCbFalse=false;

    ii=ii+1;
    pname='MemMapButton';
    p=l_buttonWidget(hObj,ptagbase,pname,'soc.memmap.csButtonCallback');
    info.Parameters{1}{ii}=p;












    ii=ii+1;
    pname='IncludeJTAGMaster';
    pdef=l_inclJTAGMasterVal(hardware.Name);
    p=l_checkboxWidget(hObj,ptagbase,pname,pdef,PVIS,PEN,useCbFalse);

    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='IncludeProcessingSystem';
    [pen,pdef]=l_inclProcSysVal(hardware.Name);
    p=l_checkboxWidget(hObj,ptagbase,pname,pdef,PVIS,pen,useCbTrue);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='HasPSMemory';
    pdef=l_hasPSMemVal(hardware.Name);
    p=l_checkboxWidget(hObj,ptagbase,pname,pdef,'0','0',useCbFalse);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='HasPLMemory';
    pdef=l_hasPLMemVal(hardware.Name);
    p=l_checkboxWidget(hObj,ptagbase,pname,pdef,'0','0',useCbFalse);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='InterruptLatency';
    [pen,pdefault,pmin,pmax]=l_interruptLatencyDefaults(hardware.Name);
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdefault,PVIS,pen,pmin,pmax);
    p.Visible=0;
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='AXILiteClock';
    [pen,pdefault,pmin,pmax]=l_axiliteClockDefaults(hardware.Name);
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdefault,PVIS,pen,pmin,pmax);
    info.Parameters{1}{ii}=p;



    ii=ii+1;
    pname='AXIHDLUserLogicClock';
    [pen,pdefault,pmin,pmax]=l_userlogicClockDefaults(hardware.Name);
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdefault,PVIS,pen,pmin,pmax);
    info.Parameters{1}{ii}=p;
end
function[ii,info]=l_MemControllerPSParams(hObj,hardware,ptagbase,ii,info)
    PEN='1';useCbTrue=true;useCbFalse=false;%#ok<NASGU>

    PVIS='codertarget.fpgadesign.internal.showMemControllersPSWidget(hObj)';

    ii=ii+1;
    pname='AXIMemorySubsystemClockPS';
    [pen,pdef,pmin,pmax]=l_memSysClockDefaults(hardware.Name,'PS memory');
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,pen,pmin,pmax);
    p.Callback='codertarget.fpgadesign.internal.fpgaDesignCallback';
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='AXIMemorySubsystemDataWidthPS';
    [pen,pvalues,pdef]=l_memSysDWidth(hardware.Name,'PS memory');
    p=l_comboWidget(hObj,ptagbase,pname,pvalues,pdef,PVIS,pen,useCbTrue,useCbFalse);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='RefreshOverheadPS';
    [pdef,pmin,pmax]=l_refreshDefaults(hardware.Name,'PS memory');
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,PEN,pmin,pmax);
    info.Parameters{1}{ii}=p;

    for pn={'WriteFirstTransferLatencyPS','WriteLastTransferLatencyPS','ReadFirstTransferLatencyPS','ReadLastTransferLatencyPS'}
        ii=ii+1;
        pname=pn{1};
        [pdef,pmin,pmax]=l_dataTransferDefaults(hardware.Name,pname,'PS memory');
        p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,PEN,pmin,pmax);
        info.Parameters{1}{ii}=p;
    end

end
function[ii,info]=l_MemControllerPLParams(hObj,hardware,ptagbase,ii,info)
    PEN='1';useCbTrue=true;useCbFalse=false;%#ok<NASGU>

    PVIS='codertarget.fpgadesign.internal.showMemControllersPLWidget(hObj)';

    ii=ii+1;
    pname='AXIMemorySubsystemClockPL';
    [pen,pdef,pmin,pmax]=l_memSysClockDefaults(hardware.Name,'PL memory');
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,pen,pmin,pmax);
    p.Callback='codertarget.fpgadesign.internal.fpgaDesignCallback';
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='AXIMemorySubsystemDataWidthPL';
    [pen,pvalues,pdef]=l_memSysDWidth(hardware.Name,'PL memory');
    p=l_comboWidget(hObj,ptagbase,pname,pvalues,pdef,PVIS,pen,useCbTrue,useCbFalse);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='RefreshOverheadPL';
    [pdef,pmin,pmax]=l_refreshDefaults(hardware.Name,'PL memory');
    p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,PEN,pmin,pmax);
    info.Parameters{1}{ii}=p;

    for pn={'WriteFirstTransferLatencyPL','WriteLastTransferLatencyPL','ReadFirstTransferLatencyPL','ReadLastTransferLatencyPL'}
        ii=ii+1;
        pname=pn{1};
        [pdef,pmin,pmax]=l_dataTransferDefaults(hardware.Name,pname,'PL memory');
        p=l_editDoubleWidget(hObj,ptagbase,pname,pdef,PVIS,PEN,pmin,pmax);
        info.Parameters{1}{ii}=p;
    end

end
function[ii,info]=l_DebugParams(hObj,hardware,ptagbase,ii,info)
    PVIS='1';PEN='1';useCbTrue=true;useCbFalse=false;

    ii=ii+1;
    pname='MemChDiagLevel';
    pvalbase=['codertarget:ui:',ptagbase,pname];
    val1=DAStudio.message([pvalbase,'None']);
    val2=DAStudio.message([pvalbase,'Basic']);
    pvalues={val1,val2};
    val3depr=DAStudio.message([pvalbase,'Detailed']);
    val4depr=DAStudio.message([pvalbase,'MemImage']);
    p=l_comboWidget(hObj,ptagbase,pname,pvalues,pvalues{1},PVIS,PEN,useCbTrue,useCbTrue);


    if~l_tgtCreation(hObj)&&codertarget.data.isParameterInitialized(hObj,p.Storage)
        switch p.Value
        case{val3depr,val4depr}




            p.Value=val2;
            codertarget.data.setParameterValue(hObj,p.Storage,p.Value);
        otherwise

        end
    end
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='IncludeAXIInterconnectMonitor';
    [pen,pdef]=l_apmEnDef(hardware.Name);
    p=l_checkboxWidget(hObj,ptagbase,pname,pdef,PVIS,pen,useCbFalse);
    info.Parameters{1}{ii}=p;

    ii=ii+1;
    pname='NumberOfTraceEvents';


    p=l_editDoubleWidget(hObj,ptagbase,pname,1024,PVIS,PEN,1,8192);
    info.Parameters{1}{ii}=p;
    p.Visible='codertarget.fpgadesign.internal.showAPMModeWidget(hObj)';
    info.Parameters{1}{ii}=p;
end

function[ii,info]=l_BogusParams(hObj,~,ptagbase,ii,info)
    useCbFalse=false;

    ii=ii+1;
    pname='BogusParameter';
    p=l_checkboxWidget(hObj,ptagbase,pname,0,'0','1',useCbFalse);
    p.DoNotStore=true;
    p.Storage='';
    info.Parameters{1}{ii}=p;
end



function tf=l_isPureFPGA(hwname)
    tf=contains(hwname,{'Artix','Kintex','Virtex'});
end

function[vis,en]=l_synthOptVisEn(hwname)
    if contains(hwname,'Altera')
        vis='0';en='0';
    else
        vis='1';en='1';
    end
end
function dval=l_inclJTAGMasterVal(hwname)


...
...
...
...
...
    dval=1;
end

function[en,dval]=l_inclProcSysVal(hwname)
    if l_isPureFPGA(hwname)


        en='0';dval=0;
    else
        if strcmp(hwname,'ZedBoard')
            en='0';dval=1;
        else
            en='1';dval=1;
        end
    end
end

function dval=l_hasPSMemVal(hwname)
    if l_isPureFPGA(hwname)
        dval=0;
    else
        dval=1;
    end
end

function dval=l_hasPLMemVal(hwname)
    if strcmp(hwname,'ZedBoard')
        dval=0;
    else
        dval=1;
    end
end

function[en,dval,min,max]=l_interruptLatencyDefaults(hwname)

    if l_isPureFPGA(hwname)
        en='0';dval=0;min=0;max=0;
    else

        en='1';dval=10e-6;min=0;max=1;
    end
end
function[en,dval,min,max]=l_axiliteClockDefaults(hwname)%#ok<INUSD>
    en='0';
    dval=50;
    min=50;
    max=50;
end
function[en,dval,min,max]=l_userlogicClockDefaults(hwname)%#ok<INUSD>
    en='1';
    dval=100;
    min=5;
    max=500;
end

function[en,val,min,max]=l_memSysClockDefaults(hwname,PSorPL)
    switch hwname
    case 'Artix-7 35T Arty FPGA evaluation kit'
        en='0';val=83.33;min=83.33;max=83.33;
    case 'Xilinx Kintex-7 KC705 development board'
        en='0';val=200;min=200;max=200;
    case 'ZedBoard'
        en='1';val=100;min=1;max=150;
    case 'Xilinx Zynq ZC706 evaluation kit'
        switch(PSorPL)
        case 'PS memory'
            en='1';val=200;min=1;max=250;
        case 'PL memory'
            en='0';val=200;min=200;max=200;
        end
    case 'Altera Arria 10 SoC development kit'
        switch(PSorPL)
        case 'PS memory'
            en='1';val=200;min=1;max=1000;
        case 'PL memory'
            en='0';val=266;min=266;max=266;
        end
    case 'Altera Cyclone V SoC development kit'
        switch(PSorPL)
        case 'PS memory'
            en='1';val=150;min=1;max=500;
        case 'PL memory'
            en='0';val=150;min=150;max=150;
        end
    case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
        switch(PSorPL)
        case 'PS memory'
            en='1';val=300;min=1;max=600;
        case 'PL memory'
            en='0';val=300;min=300;max=300;
        end
    otherwise
        en='1';val=100;min=1;max=1e12;
    end
end
function[en,pvalues,pdefault]=l_memSysDWidth(hwname,PSorPL)
    switch hwname
    case 'Artix-7 35T Arty FPGA evaluation kit'
        en='1';
        pvalues={'32','64','128'};
        pdefault='64';
    case 'Xilinx Kintex-7 KC705 development board'
        en='1';
        pvalues={'32','64','128','256','512'};
        pdefault='64';
    case 'ZedBoard'
        en='0';
        pvalues={'64'};
        pdefault='64';
    case 'Xilinx Zynq ZC706 evaluation kit'
        switch(PSorPL)
        case 'PS memory'
            en='0';
            pvalues={'64'};
            pdefault='64';
        case 'PL memory'
            en='1';
            pvalues={'32','64','128','256','512'};
            pdefault='64';
        end
    case 'Altera Arria 10 SoC development kit'
        switch(PSorPL)
        case 'PS memory'
            en='0';
            pvalues={'64'};
            pdefault='64';
        case 'PL memory'
            en='0';
            pvalues={'512'};
            pdefault='512';
        end
    case 'Altera Cyclone V SoC development kit'
        switch(PSorPL)
        case 'PS memory'
            en='0';
            pvalues={'64'};
            pdefault='64';
        case 'PL memory'
            en='0';
            pvalues={'64'};
            pdefault='64';
        end
    case 'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit'
        switch(PSorPL)
        case 'PS memory'
            en='0';
            pvalues={'128'};
            pdefault='128';
        case 'PL memory'
            en='0';
            pvalues={'128'};
            pdefault='128';
        end
    otherwise
        en='1';
        pvalues={'8','16','32','64','128','256','512','1024'};
        pdefault='64';
    end
end
function[dval,min,max]=l_refreshDefaults(hwname,PSorPL)%#ok<INUSD>
    dval=2.3;min=0;max=100;
end
function[dval,min,max]=l_dataTransferDefaults(hwname,kind,PSorPL)%#ok<INUSL>

    switch kind
    case 'ReadFirstTransferLatency',dval=5;min=0;max=1e3;
    case 'ReadLastTransferLatency',dval=1;min=0;max=1e3;
    case 'WriteFirstTransferLatency',dval=4;min=0;max=1e3;
    case 'WriteLastTransferLatency',dval=4;min=0;max=1e3;
    otherwise,dval=5;min=0;max=1e3;
    end
end


function[pen,pdefault]=l_apmEnDef(hwname)
    if contains(hwname,'Altera')
        pen='1';pdefault=0;
    else
        pen='1';pdefault=0;
    end
end
function[pen,pdefault]=l_atgEnDef(hwname)
    if contains(hwname,'Altera')
        pen='1';pdefault=0;
    else
        pen='1';pdefault=0;
    end
end



function p=l_comboWidget(hObj,ptagbase,pname,pvalues,pdefault,pvis,pen,usevalchgcb,usedefaultcb)
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();

    ptag=[ptagbase,pname];
    pstorage=[ptagbase,'.',pname];
    p.Name=DAStudio.message(['codertarget:ui:',ptag]);
    p.ToolTip=DAStudio.message(['codertarget:ui:',ptag,'ToolTip']);
    p.Tag=ptag;
    p.Type='combobox';
    p.SaveValueAsString='1';
    p.Entries=pvalues;
    if usevalchgcb
        p.Callback='codertarget.fpgadesign.internal.fpgaDesignCallback';
    end
    p.Visible=pvis;
    p.Enabled=pen;
    p.RowSpan=eval(p.RowSpan);
    p.ColSpan=eval(p.ColSpan);
    p.DialogRefresh=false;
    p.DoNotStore=false;
    p.Storage=pstorage;
    if~l_tgtCreation(hObj)
        if codertarget.data.isParameterInitialized(hObj,pstorage)
            p.Value=codertarget.data.getParameterValue(hObj,pstorage);
        else
            if usedefaultcb
                p.ValueType='callback';
                p.Value=sprintf('codertarget.fpgadesign.internal.fpgaDesignCallback(hObj,''default'',fieldName, ''%s'')',pdefault);
            else
                p.Value=pdefault;
                codertarget.data.setParameterValue(hObj,pstorage,p.Value);
            end
        end
    else
        entries=sprintf('%s; ',p.Entries{:});
        p.Entries=entries(1:end-1);
        p.Value=num2str(pdefault);
    end
end

function p=l_checkboxWidget(hObj,ptagbase,pname,pdefault,pvis,pen,usecb)
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();

    ptag=[ptagbase,pname];
    pstorage=[ptagbase,'.',pname];
    p.Name=DAStudio.message(['codertarget:ui:',ptag]);
    p.ToolTip=DAStudio.message(['codertarget:ui:',ptag,'ToolTip']);
    p.Tag=ptag;
    p.Type='checkbox';
    if usecb
        p.Callback='codertarget.fpgadesign.internal.fpgaDesignCallback';
    end
    p.Visible=pvis;
    p.Enabled=pen;
    p.RowSpan=eval(p.RowSpan);
    p.ColSpan=eval(p.ColSpan);
    p.DialogRefresh=false;
    p.DoNotStore=false;
    p.Storage=pstorage;
    if~l_tgtCreation(hObj)
        if codertarget.data.isParameterInitialized(hObj,pstorage)
            p.Value=codertarget.data.getParameterValue(hObj,pstorage);
        else
            p.Value=pdefault;
            codertarget.data.setParameterValue(hObj,pstorage,p.Value);
        end
    else
        p.Value=mat2str(pdefault);
    end
end

function p=l_editDoubleWidget(hObj,ptagbase,pname,pdefault,pvis,pen,pmin,pmax)%#ok<INUSD>
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();

    ptag=[ptagbase,pname];
    pstorage=[ptagbase,'.',pname];
    p.Name=DAStudio.message(['codertarget:ui:',ptag]);
    p.ToolTip=DAStudio.message(['codertarget:ui:',ptag,'ToolTip']);
    p.Tag=ptag;
    p.Type='edit';
    p.Visible=pvis;
    p.Enabled=pen;
    p.RowSpan=eval(p.RowSpan);
    p.ColSpan=eval(p.ColSpan);
    p.DialogRefresh=false;
    p.DoNotStore=false;
    p.Storage=pstorage;
    p.ValueType='double';

    p.Callback='codertarget.fpgadesign.internal.fpgaDesignCallback';

    if~l_tgtCreation(hObj)
        if codertarget.data.isParameterInitialized(hObj,pstorage)
            p.Value=codertarget.data.getParameterValue(hObj,pstorage);
        else
            p.Value=pdefault;
            codertarget.data.setParameterValue(hObj,pstorage,p.Value);
        end
    else
        p.Value=mat2str(pdefault);
    end


end

function p=l_buttonWidget(hObj,ptagbase,pname,cb)
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();

    ptag=[ptagbase,pname];
    p.Name=DAStudio.message(['codertarget:ui:',ptag]);
    p.ToolTip=DAStudio.message(['codertarget:ui:',ptag,'ToolTip']);
    p.Tag=ptag;
    p.Type='pushbutton';
    p.Callback=cb;
    p.Visible='1';
    p.Enabled='1';
    p.RowSpan=eval(p.RowSpan);
    p.ColSpan=eval(p.ColSpan);
    p.DialogRefresh=false;
    p.DoNotStore=true;
end





...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

