function genPluginboard(pluginrdInfo,hbuild)



    plugin_board=fullfile(pluginrdInfo.exportBoardDir,'plugin_board.m');
    fid=fopen(plugin_board,'w');
    fprintf(fid,'function hB = plugin_board()\n');
    fprintf(fid,'%% Board definition\n\n');
    fprintf(fid,'%%   Copyright 2012-2014 The MathWorks, Inc.\n\n');
    fprintf(fid,'%% Construct board object\n');
    fprintf(fid,'hB = hdlcoder.Board;\n');
    fprintf(fid,'hB.BoardName    = ''%s'';\n\n',pluginrdInfo.board_name);
    fprintf(fid,'%% FPGA device information\n');

    if(strcmp(hbuild.Vendor,'Xilinx'))
        fprintf(fid,'hB.FPGAVendor   = ''%s'';\n',hbuild.Vendor);
        if any(strcmp(pluginrdInfo.FPGAFamily,{'zynquplusRFSOC','zynquplusRFSOCes1'}))
            fprintf(fid,'hB.FPGAFamily = ''Zynq UltraScale+ RFSoC'';\n');
            fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.PartName);
            fprintf(fid,'hB.FPGAPackage = '''';\n');
            fprintf(fid,'hB.FPGASpeed =  '''';\n\n');
            fprintf(fid,'%% Tool information\n');
            fprintf(fid,'hB.SupportedTool = {''Xilinx Vivado''};\n\n');
        elseif((isprop(hbuild.Board,'DeviceFamily')&&strcmpi(hbuild.Board.DeviceFamily,'mpsoc'))||...
            strcmp(hbuild.Board.BoardID,'zcu102'))
            fprintf(fid,'hB.FPGAFamily = ''Zynq UltraScale+'';\n');
            fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.PartName);
            fprintf(fid,'hB.FPGAPackage = '''';\n');
            fprintf(fid,'hB.FPGASpeed =  '''';\n\n');
            fprintf(fid,'%% Tool information\n');
            fprintf(fid,'hB.SupportedTool = {''Xilinx Vivado''};\n\n');
        elseif(strcmp(pluginrdInfo.FPGAFamily,'kintex7'))
            fprintf(fid,'hB.FPGAFamily = ''Kintex7'';\n');
            fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.FPGADevice);
            fprintf(fid,'hB.FPGAPackage = ''%s'';\n',pluginrdInfo.FPGAPackage);
            fprintf(fid,'hB.FPGASpeed =  ''%s'';\n\n',pluginrdInfo.FPGASpeed);
            fprintf(fid,'%% Tool information\n');
            fprintf(fid,'hB.SupportedTool = {''Xilinx Vivado''};\n\n');
        elseif(strcmp(pluginrdInfo.FPGAFamily,'zynq'))
            fprintf(fid,'hB.FPGAFamily = ''Zynq'';\n');
            fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.FPGADevice);
            fprintf(fid,'hB.FPGAPackage = ''%s'';\n',pluginrdInfo.FPGAPackage);
            fprintf(fid,'hB.FPGASpeed =  ''%s'';\n\n',pluginrdInfo.FPGASpeed);
            fprintf(fid,'%% Tool information\n');
            fprintf(fid,'hB.SupportedTool = {''Xilinx Vivado''};\n\n');
        elseif(strcmp(pluginrdInfo.FPGAFamily,'artix7'))
            fprintf(fid,'hB.FPGAFamily = ''Artix7'';\n');
            fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.FPGADevice);
            fprintf(fid,'hB.FPGAPackage = ''%s'';\n',pluginrdInfo.FPGAPackage);
            fprintf(fid,'hB.FPGASpeed =  ''%s'';\n\n',pluginrdInfo.FPGASpeed);
            fprintf(fid,'%% Tool information\n');
            fprintf(fid,'hB.SupportedTool = {''Xilinx Vivado''};\n\n');
        end
    else
        fprintf(fid,'hB.FPGAVendor   = ''Altera'';\n');
        fprintf(fid,'hB.FPGAFamily = ''%s'';\n',pluginrdInfo.FPGAFamily);
        fprintf(fid,'hB.FPGADevice = ''%s'';\n',pluginrdInfo.PartName);
        fprintf(fid,'hB.FPGAPackage = '''';\n');
        fprintf(fid,'hB.FPGASpeed =  '''';\n\n');
        fprintf(fid,'%% Tool information\n');
        fprintf(fid,'hB.SupportedTool = {''Altera QUARTUS II''};\n\n');
    end


    fprintf(fid,'%% FPGA JTAG chain position\n');
    chainPos=soc.internal.getJTAGChainPosition(hbuild.Board.Name);
    fprintf(fid,'hB.JTAGChainPosition = %d;\n\n',chainPos);


    fprintf(fid,'%% external I/O interface\n');
    if(isfield(pluginrdInfo,'LED'))
        numLeds=numel(pluginrdInfo.LED);
        FPGAPin='';
        IOstd='';
        for ii=1:numLeds
            ledIdx=find(cellfun(@(x)contains(x,pluginrdInfo.LED{ii}),{hbuild.ExternalIO.name}));
            FPGAPin=[FPGAPin,sprintf(' ''%s''',hbuild.ExternalIO(ledIdx).pin)];
            if(strcmp(hbuild.Vendor,'Xilinx'))
                IOstd=[IOstd,sprintf('{ ''%s'' }',insertAfter(hbuild.ExternalIO(ledIdx).std,' ','= '))];
            else
                IOstd=[IOstd,sprintf('{ ''%s'' }',hbuild.ExternalIO(ledIdx).std)];
            end
            if(ii<numLeds)
                FPGAPin=[FPGAPin,','];
                IOstd=[IOstd,','];
            end
        end
        FPGAPin=['{',FPGAPin,'}'];
        IOstd=['{',IOstd,'}'];
        fprintf(fid,'hB.addExternalIOInterface( ...\n');
        fprintf(fid,'''InterfaceID'',    ''LEDs General Purpose'', ...\n');
        fprintf(fid,'''InterfaceType'',  ''OUT'', ...\n');
        fprintf(fid,'''PortName'',       ''GPLEDs'', ...\n');
        fprintf(fid,'''PortWidth'',       %d, ...\n',numLeds);
        fprintf(fid,'''FPGAPin'',       %s, ...\n',FPGAPin);
        fprintf(fid,'''IOPadConstraint'',       %s)\n\n',IOstd);
    end

    if(isfield(pluginrdInfo,'PB'))
        numPbs=numel(pluginrdInfo.PB);
        FPGAPin='';
        IOstd='';
        for ii=1:numPbs
            pbIdx=find(cellfun(@(x)contains(x,pluginrdInfo.PB{ii}),{hbuild.ExternalIO.name}));
            FPGAPin=[FPGAPin,sprintf(' ''%s''',hbuild.ExternalIO(pbIdx).pin)];
            if(strcmp(hbuild.Vendor,'Xilinx'))
                IOstd=[IOstd,sprintf('{ ''%s'' }',insertAfter(hbuild.ExternalIO(pbIdx).std,' ','= '))];
            else
                IOstd=[IOstd,sprintf('{ ''%s'' }',hbuild.ExternalIO(pbIdx).std)];
            end
            if(ii<numPbs)
                FPGAPin=[FPGAPin,','];
                IOstd=[IOstd,','];
            end
        end
        FPGAPin=['{',FPGAPin,'}'];
        IOstd=['{',IOstd,'}'];
        fprintf(fid,'hB.addExternalIOInterface( ...\n');
        fprintf(fid,'''InterfaceID'',    ''Push Buttons'', ...\n');
        fprintf(fid,'''InterfaceType'',  ''IN'', ...\n');
        fprintf(fid,'''PortName'',       ''PushButtons'', ...\n');
        fprintf(fid,'''PortWidth'',       %d, ...\n',numPbs);
        fprintf(fid,'''FPGAPin'',       %s, ...\n',FPGAPin);
        fprintf(fid,'''IOPadConstraint'',       %s)\n\n',IOstd);
    end
    if(isfield(pluginrdInfo,'DS'))
        numDIPs=numel(pluginrdInfo.DS);
        FPGAPin='';
        IOstd='';
        for ii=1:numDIPs
            dpIdx=find(cellfun(@(x)contains(x,pluginrdInfo.DS{ii}),{hbuild.ExternalIO.name}));
            FPGAPin=[FPGAPin,sprintf(' ''%s''',hbuild.ExternalIO(dpIdx).pin)];
            if(strcmp(hbuild.Vendor,'Xilinx'))
                IOstd=[IOstd,sprintf('{ ''%s'' }',insertAfter(hbuild.ExternalIO(dpIdx).std,' ','= '))];
            else
                IOstd=[IOstd,sprintf('{ ''%s'' }',hbuild.ExternalIO(dpIdx).std)];
            end
            if(ii<numDIPs)
                FPGAPin=[FPGAPin,','];
                IOstd=[IOstd,','];
            end
        end
        FPGAPin=['{',FPGAPin,'}'];
        IOstd=['{',IOstd,'}'];
        fprintf(fid,'hB.addExternalIOInterface( ...\n');
        fprintf(fid,'''InterfaceID'',    ''DIP Switches'', ...\n');
        fprintf(fid,'''InterfaceType'',  ''IN'', ...\n');
        fprintf(fid,'''PortName'',       ''GPDIP'', ...\n');
        fprintf(fid,'''PortWidth'',       %d, ...\n',numDIPs);
        fprintf(fid,'''FPGAPin'',       %s, ...\n',FPGAPin);
        fprintf(fid,'''IOPadConstraint'',       %s)\n\n',IOstd);
    end

    fprintf(fid,'end\n');
    fclose(fid);
end