function genPluginrd(pluginrdInfo,hbuild)



    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        syntool='Xilinx Vivado';
    else
        syntool='Altera QUARTUS II';
    end
    toolVer=sprintf('{''%s''}',pluginrdInfo.ToolVersion);
    fid=fopen('plugin_rd.m','w');
    fprintf(fid,'function hRD = plugin_rd()\n');
    fprintf(fid,'\n%% Reference design definition\n');
    fprintf(fid,'\n%%  Copyright 2018-2020 The MathWorks, Inc.\n');

    fprintf(fid,'\n%%  Construct reference design object\n');
    fprintf(fid,'hRD = hdlcoder.ReferenceDesign(''%s'',''%s'');\n','SynthesisTool',syntool);
    fprintf(fid,'hRD.ReferenceDesignName = ''%s'';\n',pluginrdInfo.refDesignName);
    fprintf(fid,'hRD.BoardName = ''%s'';\n',pluginrdInfo.board_name);


    fprintf(fid,'hRD.SupportedToolVersion = %s;\n',toolVer);


    fprintf(fid,'%% Add custom design files\n');

    putsvivadodesign(fid,pluginrdInfo)

    putIprepository(fid,pluginrdInfo)

    putConstraints(fid,pluginrdInfo)


    fprintf(fid,'%% Add custom design files\n');

    putClockInterface(fid,pluginrdInfo);

    if(isfield(pluginrdInfo,'AXI4Lite'))
        fprintf(fid,'%% add AXI4 and AXI4-Lite slave interfaces\n');

        putAXI4Salveinterface(fid,pluginrdInfo);
    end

    if(isfield(pluginrdInfo,'AXI_Master'))
        for ii=1:numel(pluginrdInfo.AXI_Master)
            putAXI4Masterinterface(fid,pluginrdInfo.AXI_Master(ii),pluginrdInfo);
        end
    end

    if(isfield(pluginrdInfo,'AXI_Stream_Slave'))
        for ii=1:numel(pluginrdInfo.AXI_Stream_Slave)
            putAXI4SlaveStreaminterface(fid,pluginrdInfo.AXI_Stream_Slave(ii));
        end
    end

    if(isfield(pluginrdInfo,'AXI_Stream_Master'))
        for ii=1:numel(pluginrdInfo.AXI_Stream_Master)
            putAXI4MasterStreaminterface(fid,pluginrdInfo.AXI_Stream_Master(ii));
        end
    end

    if(isfield(pluginrdInfo,'AXI_Stream_Video_Slave'))
        for ii=1:numel(pluginrdInfo.AXI_Stream_Video_Slave)
            putAXI4SlaveVideoStreaminterface(fid,pluginrdInfo.AXI_Stream_Video_Slave(ii));
        end
    end

    if(isfield(pluginrdInfo,'AXI_Stream_Video_Master'))
        for ii=1:numel(pluginrdInfo.AXI_Stream_Video_Master)
            putAXI4MasterVideoStreaminterface(fid,pluginrdInfo.AXI_Stream_Video_Master(ii));
        end
    end


    if(isfield(pluginrdInfo,'IntrCon'))
        fprintf(fid,'%% Adding  internal interface connections\n');
        for ii=1:numel(pluginrdInfo.IntrCon)
            putInternalPortInterface(fid,pluginrdInfo.IntrCon(ii));
        end
    end
    if(pluginrdInfo.procexist)

        fprintf(fid,'%% Devicetree file\n');
        fprintf(fid,'hRD.DeviceTreeName  = ''soc_prj.output.dtb''; \n');
    end
    fprintf(fid,'\n\n%% Disabling the JTAG Master\n');
    fprintf(fid,'hRD.AddJTAGMATLABasAXIMasterParameter=false;\n');



    if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))||...
        any(cellfun(@(x)isa(x,'hsb.xilcomp.HDMITx'),hbuild.FMCIO))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.AD9361'),hbuild.FMCIO))

        [~,exportbrdpath]=fileparts(pluginrdInfo.exportBoardDir);
        [~,exportrdpath]=fileparts(pluginrdInfo.exportDirectory);
        genricPath=sprintf('%s.%s',exportbrdpath(2:end),exportrdpath(2:end));
        fprintf(fid,'\n%% validate if HDL file in place\n');
        fprintf(fid,'rdFolder = fileparts(mfilename(''fullpath''));\n');
        fprintf(fid,'[~,dstList] = %s.list3pFiles; %% you need to generate list3pFiles.m under plugin_rd folder.\n',genricPath);
        fprintf(fid,'hasHDLFiles = true;\n\n');
        fprintf(fid,'for i = 1:numel(dstList)\n');
        fprintf(fid,'%sif ~isfile(fullfile(rdFolder,''ipcore'',dstList{i}))\n',getTabStr(1));
        fprintf(fid,'%shasHDLFiles = false;\n',getTabStr(2));
        fprintf(fid,'%sbreak;\n',getTabStr(2));
        fprintf(fid,'%send\n',getTabStr(1));
        fprintf(fid,'end\n\n');

        fprintf(fid,'if ~hasHDLFiles\n');
        fprintf(fid,'%serrordlg(message(''hdlcommon:plugin:ADIHDLNotFound'',''%s'').getString);\n',getTabStr(1),genricPath);
        fprintf(fid,'end\n');
    end
    fprintf(fid,'end\n');
    fclose(fid);
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        pin_constr_file='constr.xdc';
    else
        pin_constr_file='pin_constr.tcl';
    end

    fid1=fopen(fullfile(pin_constr_file),'r');
    str=textscan(fid1,'%s','Delimiter','\n');

    if(isfield(pluginrdInfo,'LED'))
        for i=1:numel(pluginrdInfo.LED)
            conLine=find(cellfun(@(x)contains(x,pluginrdInfo.LED{i}),str{1}));
            str{1}(conLine)=[];
        end
    end


    if(isfield(pluginrdInfo,'DS'))
        for i=1:numel(pluginrdInfo.DS)
            conLine=find(cellfun(@(x)contains(x,pluginrdInfo.DS{i}),str{1}));
            str{1}(conLine)=[];
        end
    end


    if(isfield(pluginrdInfo,'PB'))
        for i=1:numel(pluginrdInfo.PB)
            conLine=find(cellfun(@(x)contains(x,pluginrdInfo.PB{i}),str{1}));
            str{1}(conLine)=[];
        end
    end
    fclose(fid1);

    fid=fopen(fullfile(pin_constr_file),'w');
    conStrfile=str{1}(1:end);
    fprintf(fid,'%s\n',conStrfile{:});
    fclose(fid);
end



function putsvivadodesign(fid,pluginrdInfo)
    fprintf(fid,'%% add custom Vivado design\n');
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        fprintf(fid,'hRD.addCustomVivadoDesign( ...\n');
        fprintf(fid,'%s''CustomBlockDesignTcl'', ''%s'');\n',getTabStr(1),'design_1.tcl');
    else
        fprintf(fid,'hRD.addCustomQsysDesign( ...\n');
        fprintf(fid,'%s''CustomQsysPrjFile'', ''%s'');\n',getTabStr(1),'system_top.qsys');
    end
end

function putIprepository(fid,pluginrdInfo)
    fprintf(fid,'%% add additional ipcores\n');
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        fprintf(fid,'hRD.CustomFiles = {''ipcore'',''hsb_xil.tcl''};\n');
    else
        fprintf(fid,'hRD.CustomFiles = {''ip''};\n');
    end
end

function putConstraints(fid,pluginrdInfo)
    fprintf(fid,'%% Add constraint files\n');
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        fprintf(fid,'hRD.CustomConstraints = {''constr.xdc''};\n');
    else
        fprintf(fid,'hRD.CustomConstraints = {''timing_constr.sdc''};\n');
        fprintf(fid,'hRD.CustomConstraints = {''pin_constr.tcl''};\n');
    end
end

function putClockInterface(fid,pluginrdInfo)
    fprintf(fid,'%% add clock interface\n');
    fprintf(fid,'hRD.addClockInterface( ...\n');
    fprintf(fid,'%s''ClockConnection'', ''%s'', ...\n',getTabStr(1),pluginrdInfo.clock);
    fprintf(fid,'%s''ResetConnection'', ''%s'');\n',getTabStr(1),pluginrdInfo.reset);
end

function putAXI4Salveinterface(fid,pluginrdInfo)
    fprintf(fid,'hRD.addAXI4SlaveInterface( ...\n');
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        fprintf(fid,'%s''InterfaceConnection'', ''%s'', ...\n',getTabStr(1),pluginrdInfo.AXI4Lite.InterfaceConnection{:});
        fprintf(fid,'%s''BaseAddress'', %s, ...\n',getTabStr(1),pluginrdInfo.AXI4Lite.baceAddr);
        fprintf(fid,'%s''MasterAddressSpace'', %s);\n',getTabStr(1),pluginrdInfo.AXI4Lite.MasterAddressSpace);
    else
        fprintf(fid,'%s''InterfaceConnection'', %s, ...\n',getTabStr(1),pluginrdInfo.AXI4Lite.MasterAddressSpace);
        fprintf(fid,'%s''BaseAddress'', %s, ...\n',getTabStr(1),pluginrdInfo.AXI4Lite.baceAddr);
        fprintf(fid,'%s''InterfaceType'', ''AXI4'');\n',getTabStr(1));
    end
end

function putAXI4Masterinterface(fid,Master,pluginrdInfo)
    fprintf(fid,'hRD.addAXI4MasterInterface(...\n');
    fprintf(fid,'%s''InterfaceID'', ''%s'', ...\n',getTabStr(1),Master.MstrIntrID);
    fprintf(fid,'%s''ReadSupport'', %s, ...\n',getTabStr(1),Master.MstrRdSupport);
    fprintf(fid,'%s''WriteSupport'',%s, ...\n',getTabStr(1),Master.MstrWrSupport);
    fprintf(fid,'%s''MaxDataWidth'', %d, ...\n',getTabStr(1),Master.MstrMaxDw+1);
    fprintf(fid,'%s''AddrWidth'', %d, ...\n',getTabStr(1),Master.MstrMaxAw+1);
    fprintf(fid,'%s''DefaultReadBaseAddr'', %d, ...\n',getTabStr(1),Master.DefaultReadBaseAddr);
    fprintf(fid,'%s''DefaultWriteBaseAddr'', %d, ...\n',getTabStr(1),Master.DefaultWriteBaseAddr);
    if(strcmp(pluginrdInfo.Vendor,'Xilinx'))
        fprintf(fid,'%s''InterfaceConnection'', ''%s'',...\n',getTabStr(1),Master.MstrChnlCon);
        if~isempty(pluginrdInfo.memPLrange)
            fprintf(fid,'%s''TargetAddressSegments'', {{%s,hex2dec(''%s''),hex2dec(''%s'')}})\n',getTabStr(1),...
            pluginrdInfo.memSegName,pluginrdInfo.memPLoffset,pluginrdInfo.memPLrange);
        end
        if~isempty(pluginrdInfo.memPSrange)
            fprintf(fid,'%s''TargetAddressSegments'', {{%s,hex2dec(''%s''),hex2dec(''%s'')}})\n',getTabStr(1),...
            pluginrdInfo.memSegName,pluginrdInfo.memPSoffset,pluginrdInfo.memPSrange);
        end
    else
        fprintf(fid,'%s''InterfaceConnection'', ''%s'')\n',getTabStr(1),Master.InterfaceConnection);
    end
end

function putAXI4MasterStreaminterface(fid,Master)
    fprintf(fid,'hRD.addAXI4StreamInterface( ...\n');
    fprintf(fid,'%s''MasterChannelEnable'', true, ...\n',getTabStr(1));
    fprintf(fid,'%s''SlaveChannelEnable'', false, ...\n',getTabStr(1));

    fprintf(fid,'%s''MasterChannelConnection'', ''%s'', ...\n',getTabStr(1),Master.MstrChnlCon);
    fprintf(fid,'%s''MasterChannelDataWidth'', %d, ...\n',getTabStr(1),Master.Mstrdw+1);
    fprintf(fid,'%s''InterfaceID'', ''%s'');\n',getTabStr(1),Master.MstrIntrID);
end

function putAXI4SlaveStreaminterface(fid,Slave)
    fprintf(fid,'hRD.addAXI4StreamInterface( ...\n');
    fprintf(fid,'%s''MasterChannelEnable'', false, ...\n',getTabStr(1));
    fprintf(fid,'%s''SlaveChannelEnable'', true, ...\n',getTabStr(1));

    fprintf(fid,'%s''SlaveChannelConnection'', ''%s'', ...\n',getTabStr(1),Slave.SlvChnlCon);
    fprintf(fid,'%s''SlaveChannelDataWidth'', %d, ...\n',getTabStr(1),Slave.Slvdw+1);
    fprintf(fid,'%s''InterfaceID'', ''%s'');\n',getTabStr(1),Slave.SlvIntrID);
end
function putAXI4MasterVideoStreaminterface(fid,Master)
    fprintf(fid,'hRD.addAXI4StreamVideoInterface( ...\n');
    fprintf(fid,'%s''MasterChannelEnable'', true, ...\n',getTabStr(1));
    fprintf(fid,'%s''SlaveChannelEnable'', false, ...\n',getTabStr(1));

    fprintf(fid,'%s''MasterChannelConnection'', ''%s'', ...\n',getTabStr(1),Master.MstrChnlCon);
    fprintf(fid,'%s''MasterChannelDataWidth'', %d, ...\n',getTabStr(1),Master.Mstrdw+1);
    fprintf(fid,'%s''InterfaceID'', ''%s'');\n',getTabStr(1),Master.MstrIntrID);
end

function putAXI4SlaveVideoStreaminterface(fid,Slave)
    fprintf(fid,'hRD.addAXI4StreamVideoInterface( ...\n');
    fprintf(fid,'%s''MasterChannelEnable'', false, ...\n',getTabStr(1));
    fprintf(fid,'%s''SlaveChannelEnable'', true, ...\n',getTabStr(1));

    fprintf(fid,'%s''SlaveChannelConnection'', ''%s'', ...\n',getTabStr(1),Slave.SlvChnlCon);
    fprintf(fid,'%s''SlaveChannelDataWidth'', %d, ...\n',getTabStr(1),Slave.Slvdw+1);
    fprintf(fid,'%s''InterfaceID'', ''%s'');\n',getTabStr(1),Slave.SlvIntrID);
end
function putInternalPortInterface(fid,port)
    fprintf(fid,'hRD.addInternalIOInterface( ...\n');
    fprintf(fid,'%s''InterfaceID'',''%s'', ...\n',getTabStr(1),port.InterfaceID);
    if(strcmp(port.InterfaceType,'O'))
        fprintf(fid,'%s''InterfaceType'', ''OUT'', ...\n',getTabStr(1));
    else
        fprintf(fid,'%s''InterfaceType'', ''IN'', ...\n',getTabStr(1));
    end
    fprintf(fid,'%s''PortName'', ''%s'', ...\n',getTabStr(1),port.PortName);
    fprintf(fid,'%s''PortWidth'', %d, ...\n',getTabStr(1),port.PortWidth);
    fprintf(fid,'%s''InterfaceConnection'', ''%s'');\n',getTabStr(1),port.InterfaceConnection);
end

function tabs=getTabStr(num)
    tab='    ';
    tabs='';
    if eq(num,1)
        tabs=tab;
    else
        for nn=1:num
            tabs=[tabs,tab];%#ok<AGROW>
        end
    end
end
