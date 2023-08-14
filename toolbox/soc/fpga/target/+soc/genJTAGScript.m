function genJTAGScript(AXIMasterInfo,hbuild,socsysinfo,verbose)


    productName='SoC Blockset';

    prjDir=socsysinfo.projectinfo.prj_dir;


    defVals=getDefaultValues();


    if~isfolder(prjDir)
        mkdir(prjDir);
    end

    if~(any(cellfun(@(x)isa(x,'soc.xilcomp.JTAGMaster'),hbuild.ComponentList))||any(cellfun(@(x)isa(x,'soc.intelcomp.JTAGMaster'),hbuild.ComponentList)))
        return
    end


    if verbose
        fprintf('---------- Generating AXI Manager script ----------\n');
    end


    fid=fopen(fullfile(prjDir,[socsysinfo.modelinfo.sys,'_aximaster.m']),'w');

    putHeader(fid,productName,socsysinfo);



    if any(struct2array(structfun(@(x)(~isempty(x)),socsysinfo.ipcoreinfo,'UniformOutput',false)))
        putIPRegInfoLoad(fid,socsysinfo.projectinfo.ipinfofile,AXIMasterInfo);
    end




    switch hbuild.Board.Name
    case codertarget.internal.getTargetHardwareNamesForSoC
        fprintf(fid,'\n%% Create hardware object\n');
        fprintf(fid,'hwObj = socHardwareBoard(''%s'',''Connect'',%s);\n',hbuild.Board.Name,'false');
        vendor='hwObj';
    case codertarget.internal.getCustomHardwareBoardNamesForSoC
        vendor=['''',hbuild.Vendor,''''];
    end



    masterObj=putAXIMasterObj(fid,'AXIMasterObj',vendor);


    putUserParameters(fid,AXIMasterInfo,defVals);

    putConfigFunction(fid,AXIMasterInfo,masterObj,defVals);


    if~isempty(socsysinfo.ipcoreinfo.mwipcore_info)
        fprintf(fid,'\n%%%% Initialize user IP core(s)\n\n');
    end
    putDutInfoAndConfig(fid,AXIMasterInfo,socsysinfo,masterObj,defVals,'call');

    putTestbenchArea(fid,AXIMasterInfo,masterObj,defVals);

    releaseAXIMasterObj(fid,masterObj);


    putSupportFcnDivider(fid);


    putDutInfoAndConfig(fid,AXIMasterInfo,socsysinfo,masterObj,defVals,'create');


    fclose(fid);

end




function putHeader(fid,productName,socsysinfo)

    fprintf(fid,'%% This script was automatically generated on %s, during',datetime);
    fprintf(fid,'\n%% %s design generation\n',productName);
    fprintf(fid,'\n%% Generated design information:\n');
    fprintf(fid,'%%\tTarget platform: %s\n',socsysinfo.projectinfo.board);
    fprintf(fid,'%%\tGenerated bitstream: %s\n',socsysinfo.projectinfo.bit_file);
    fprintf(fid,'\n%% NOTE: You must program the FPGA with the generated bitstream file');
    fprintf(fid,'\n%% before running this script\n');
    fprintf(fid,'\n%% Copyright %d The MathWorks, Inc.\n',year(datetime));
end


function putIPRegInfoLoad(fid,ipinfofile,AXIMasterInfo)
    structNames=fieldnames(AXIMasterInfo);
    structNames=strjoin(structNames,', ');
    fprintf(fid,['\n%%%% Load saved AXI master info\n'...
    ,'%% This file contains information used by this script'...
    ,'\n%% Available structs in this file: %s'...
    ,'\nload(''%s'');\n'],structNames,ipinfofile);
end

function putSupportFcnDivider(fid)
    fprintf(fid,'\n\n%%%%\n');
    fprintf(fid,'%% -------------------------------------------------------------------------------\n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%% SUPPORT FUNCTIONS\n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%% -------------------------------------------------------------------------------\n');
    fprintf(fid,'%%%%\n');
end

function putUserParameters(fid,AXIMasterInfo,defVals)
    atgStructName=defVals.structNames.ATG;
    fprintf(fid,'\n%%%% User settings\n\n');

    if isfield(AXIMasterInfo,atgStructName)
        for nn=1:numel(AXIMasterInfo.(atgStructName))
            thisATG=AXIMasterInfo.(atgStructName)(nn);
            if nn==1
                fprintf(fid,'%% AXI Traffic Generator parameters\n');
            end
            printATGParam(fid,thisATG,atgStructName,defVals,nn);
            if nn==numel(AXIMasterInfo.(atgStructName))
                fprintf(fid,'\n');
            end
        end
    end


    if isfield(AXIMasterInfo,'perf_mon')
        fprintf(fid,'%% Performance monitor parameters\n');
        fprintf(fid,'perfMonMode = ''%s'';%% Profile/Trace direction\n\n',AXIMasterInfo.perf_mon.Mode);
    end


    fprintf(fid,'%% Initialize memory contents\n');

end


function addDutComp(fid,ipName,thisComp,masterObj,defVals)
    axiRegs=thisComp.axi_regs;
    fprintf(fid,'\n%%%% Register space for %s IP core.\n',ipName);
    enterPrintUserReg=false;
    for nn=1:numel(axiRegs)




        thisAxiReg=axiRegs(nn);
        thisAxiRegNmae=thisAxiReg.name;
        if strcmpi(thisAxiRegNmae,'IPCore_Reset')
            addrStr=[ipName,'.',thisAxiRegNmae];
            aximasterwrite(fid,masterObj,addrStr,'1','Reset IP core');
        elseif contains(thisAxiRegNmae,'AXI4_Stream_Video')&&contains(thisAxiRegNmae,'Slave')

            printVideoSlave(fid,ipName,thisAxiRegNmae,masterObj,defVals);
        elseif contains(thisAxiRegNmae,'AXI4_Stream')&&~contains(thisAxiRegNmae,'Video')&&contains(thisAxiRegNmae,'Master')

            printStreamMaster(fid,ipName,thisAxiRegNmae,masterObj,defVals);
        elseif~any(strcmpi(thisAxiRegNmae,{'IPCore_Timestamp','IPCore_Enable'}))

            if enterPrintUserReg==false
                fprintf(fid,'\n%% AXI4-Lite Memory-Mapped register access\n');
                enterPrintUserReg=true;
            end
            addrStr=[ipName,'.',thisAxiRegNmae];
            if strcmp(thisAxiReg.direction,'write')
                fprintf(fid,'%% AXI4-Lite register write (Default value from Register Channel)\n');
                aximasterwrite(fid,masterObj,addrStr,num2str(thisAxiReg.default_val));
            else
                fprintf(fid,'%% AXI4-Lite register read\n');
                aximasterread(fid,masterObj,addrStr,'1');
            end
        end
    end
end


function printStreamMaster(fid,ipName,AXIRegName,masterObj,defVals)
    packetSize=defVals.streamParams.packetSize;
    fprintf(fid,'\n%% Default values for %s interface -- %s\n',erase(AXIRegName,'_PacketSize'),ipName);

    fprintf(fid,'%% The TLAST output signal of the interface is generated based on the packet size.\n');
    aximasterwrite(fid,masterObj,[ipName,'.',AXIRegName],[ipName,'.',packetSize]);
end


function printVideoSlave(fid,ipName,AXIRegName,masterObj,defVals)
    fStruct=defVals.structNames.frame;
    fWidth=defVals.videoParams.width;
    fHeight=defVals.videoParams.height;
    fHPorch=defVals.videoParams.hporch;
    fVPorch=defVals.videoParams.vporch;
    if contains(AXIRegName,'_ImageWidth')

        fprintf(fid,'\n%% Default values for %s interface -- %s\n',erase(AXIRegName,'_ImageWidth'),ipName);
        fprintf(fid,'%% Active pixels per line in each video frame. Default value is 1920.\n');
        aximasterwrite(fid,masterObj,[ipName,'.',AXIRegName],[fStruct,'.',fWidth]);
    end

    if contains(AXIRegName,'_ImageHeight')

        fprintf(fid,'%% Active video lines in each video frame. Default value is 1080.\n');
        aximasterwrite(fid,masterObj,[ipName,'.',AXIRegName],[fStruct,'.',fHeight]);
    end

    if contains(AXIRegName,'_HPorch')

        fprintf(fid,'%% Horizontal porch length in each video frame. Default value is 280.\n');
        aximasterwrite(fid,masterObj,[ipName,'.',AXIRegName],[fStruct,'.',fHPorch]);
    end

    if contains(AXIRegName,'_VPorch')

        fprintf(fid,'%% Vertical porch length in each video frame. Default value is 45.\n');
        aximasterwrite(fid,masterObj,[ipName,'.',AXIRegName],[fStruct,'.',fVPorch]);
    end
end


function printATGInit(fid,masterObj,ipName,defVals)
    fprintf(fid,'%% Create IPCore object for traffic generator core(s)\n');
    [fcnName,ipstructure,output,ipcoreName]=getObjFunName(ipName,defVals);
    fprintf(fid,'%s=%s(%s, %s,''%s'');\n',output,fcnName,masterObj,ipstructure,ipcoreName);
    fprintf(fid,'%% Initialize instantiated traffic generator cores\n');
    [fcnName,~,~]=getInitFcnName(ipName,defVals);
    fprintf(fid,'%s(%s);\n',fcnName,output);
end


function printPerfMonInit(fid,masterObj,ipName,defVals)
    fprintf(fid,'%% Create IPCore object for performance monitor core\n');
    [fcnName,ipstructure,output,ipcoreName]=getObjFunName(ipName,defVals);
    fprintf(fid,'%s=%s(%s, %s,''%s'',''Mode'',%s); %% Mode is Profile/Trace\n',output,fcnName,masterObj,ipstructure,ipcoreName,'perfMonMode');
end

function printATGParam(fid,atgStruct,ipName,defVals,num)
    direction=defVals.atgParams.direction;
    mdlBlkName=defVals.atgParams.mdlBlkName;
    fprintf(fid,'%% Generated from %s\n',atgStruct.(mdlBlkName));
    fprintf(fid,'%s(%d).%s = ''%s'';%% Read/Write direction\n',ipName,num,direction,atgStruct.(direction));
end


function printDMAInit(fid,masterObj,ipName,defVals)
    memRegions=defVals.structNames.memRegions;
    fprintf(fid,'%% Create IP core object for DMA core\n');
    [fcnName,ipstructure,output,ipcoreName]=getObjFunName(ipName,defVals);
    fprintf(fid,'%s=%s(%s, %s,''%s'');\n',output,fcnName,masterObj,ipstructure,ipcoreName);
    fprintf(fid,'%% Initialize DMA core\n');
    [fcnName,~,~]=getInitFcnName(ipName,defVals);
    fprintf(fid,'%s(%s,''memoryRegion'',%s);\n',fcnName,output,memRegions);
end


function printVDMAInit(fid,masterObj,ipName,defVals)
    memRegions=defVals.structNames.memRegions;
    [fcnName,ipstructure,output,ipcoreName]=getObjFunName(ipName,defVals);
    switch ipName
    case{'s2mm_vdma','mm2s_vdma'}
        fprintf(fid,'%% Create IPCore object for VDMA core\n');
        fprintf(fid,'%s=%s(%s, %s,''%s'');\n',output,fcnName,masterObj,ipstructure,ipcoreName);
        fprintf(fid,'%% Initialize VDMA core\n');
    case 'vdma_frame_buffer'
        fprintf(fid,'%% Create IPCore object for VDMA Frame Buffer core \n');
        fprintf(fid,'%s=%s(%s, %s,''%s'');\n',output,fcnName,masterObj,ipstructure,ipcoreName);
        fprintf(fid,'%% Initialize VDMA Frame Buffer core \n');
    case 'vdma_hdmi_out'
        fprintf(fid,'%% Create IPCore object for VDMA core for HDMI output\n');
        fprintf(fid,'%s=%s(%s, %s,''%s'');\n',output,fcnName,masterObj,ipstructure,ipcoreName);
        fprintf(fid,'%% Initialize VDMA core for HDMI output\n');
    otherwise
    end
    [fcnName,params,~]=getInitFcnName(ipName,defVals);
    fcnStr=sprintf('%s(%s,''frameParam'', %s,''memoryRegion'', %s)',fcnName,output,params,memRegions);
    fprintf(fid,'%s;\n',fcnStr);
end

function printVtcInit(fid,masterObj,defVals)
    ipName=defVals.structNames.VTC;
    fprintf(fid,'%% Create IPCore object for VTC core\n');
    [fcnName,ipstructure,ipCodeObj,ipcoreName]=getObjFunName(ipName,defVals);
    fprintf(fid,'%s=%s(%s, %s,''%s'');\n',ipCodeObj,fcnName,masterObj,ipstructure,ipcoreName);
    [fcnName,param,output]=getInitFcnName(ipName,defVals);
    fprintf(fid,'%% Initialize VTC core \n');
    fcnStr=sprintf('%s(%s)',fcnName,ipCodeObj);
    fprintf(fid,'%s;\n',fcnStr);
    fprintf(fid,'%s=%s.%s;\n',output,ipCodeObj,param);
end


function putConfigFunction(fid,AXIMasterInfo,masterObj,defVals)
    atgStructName=defVals.structNames.ATG;
    vtcStructName=defVals.structNames.VTC;
    fields=fieldnames(AXIMasterInfo);
    perfMonitor='perf_mon';
    fprintf(fid,'\n%%%% Initialize built-in IP core(s) \n\n');


    if isfield(AXIMasterInfo,vtcStructName)
        printVtcInit(fid,masterObj,defVals);
    end

    for i=1:numel(fields)
        ipName=fields{i};
        switch ipName
        case atgStructName

            printATGInit(fid,masterObj,ipName,defVals);
            fprintf(fid,'\n');
        case{'s2mm_dma','mm2s_dma'}

            printDMAInit(fid,masterObj,ipName,defVals);
        case{'s2mm_vdma','mm2s_vdma','vdma_frame_buffer','vdma_hdmi_out'}

            printVDMAInit(fid,masterObj,ipName,defVals);
        case perfMonitor

            printPerfMonInit(fid,masterObj,ipName,defVals);
        otherwise
        end
    end


end


function defVals=getDefaultValues()
    defVals.structNames=struct('frame','frameParam','memRegions','memRegions',...
    'ATG','atg','VTC','vtc','externalFuncPrefix','soc.util.','profileData','profileDataStruct',...
    'traceData','traceDataStruct','numRuns','NumRuns');
    defVals.videoParams=struct('width','width','height','height','hporch','horizontalPorch','vporch','verticalPorch','bpp','bytePerPixel');
    defVals.streamParams=struct('defaultVal',2048,'packetSize','packetSize');
    defVals.perfMonParams=struct('structName','perf_mon','runs','NumRuns','numSlots','NumSlots');
    defVals.atgParams=struct('direction','ReadWrite','mdlBlkName','BlockName');
end


function masterObj=putAXIMasterObj(fid,masterObj,vendor)
    fprintf(fid,'\n%%%% Create socAXIMaster object\n\n');
    fprintf(fid,'%s = socAXIMaster(%s);\n',masterObj,vendor);
end


function releaseAXIMasterObj(fid,masterObj)
    fprintf(fid,'\n%%%% Release AXI Manager object\n\n');
    fprintf(fid,'%s.release;',masterObj);
end


function putDutInfoAndConfig(fid,AXIMasterInfo,socsysinfo,masterObj,defVals,fcnMode)
    fields=fieldnames(AXIMasterInfo);
    mwIPs=socsysinfo.ipcoreinfo.mwipcore_info;
    for i=1:numel(fields)
        thisIPName=fields{i};

        if endsWith(thisIPName,'_ip')
            index=contains({mwIPs.ipcore_name},thisIPName);
            thisDutComp=mwIPs(index);
            thisDutRegInfo=AXIMasterInfo.(thisIPName);
            [fcnName,params]=getDutInitFcnName(thisDutRegInfo,thisIPName,defVals);
            if~isempty(params)
                fcnStr=sprintf('%s(%s, %s, %s)',fcnName,masterObj,thisIPName,params);
            else
                fcnStr=sprintf('%s(%s, %s)',fcnName,masterObj,thisIPName);
            end
            switch fcnMode
            case 'call'
                fprintf(fid,'%s;\n\n',fcnStr);
            case 'create'
                fprintf(fid,'\nfunction %s\n',fcnStr);
                addDutComp(fid,thisIPName,thisDutComp,masterObj,defVals);
                fprintf(fid,'end\n');
            otherwise
            end
        end
    end
end

function[fcnName,params]=getDutInitFcnName(thisDut,ipName,defVals)
    fParams=defVals.structNames.frame;
    params=[];
    fields=fieldnames(thisDut);
    intfs=regexprep(fields,'_[0-9]_','_');




    if any(contains(intfs,'AXI4_Stream_Video_Slave'))

        params=fParams;
    elseif any(contains(intfs,'AXI4_Stream_Master'))

    elseif any(contains(intfs,'AXI4_Master'))

    end
    fcnName=['init_',ipName];
end

function[fcnName,params,output,ipcoreName]=getObjFunName(ipName,defVals,varargin)
    if nargin>2
        proObj=varargin{1};
    end
    vParams=defVals.structNames.frame;
    initFcnNames=struct('ipObj','socIPCore','profileObj','socMemoryProfiler');
    fcnName=initFcnNames.ipObj;
    params=vParams;
    output=[];
    switch ipName
    case 'mm2s_dma'
        params=ipName;
        output='mm2s_dmaCoreObj';
        ipcoreName='DMA';
    case 's2mm_dma'
        params=ipName;
        output='s2mm_dmaCoreObj';
        ipcoreName='DMA';
    case 'mm2s_vdma'
        params=ipName;
        output='mm2s_vdmaCoreObj';
        ipcoreName='VDMA';
    case 's2mm_vdma'
        params=ipName;
        output='s2mm_vdmaCoreObj';
        ipcoreName='VDMA';
    case 'vdma_frame_buffer'
        params=ipName;
        output='vdma_frame_bufferCoreObj';
        ipcoreName='FrameBuffer';
    case 'vdma_hdmi_out'
        params=ipName;
        output='vdma_hdmi_outCoreObj';
        ipcoreName='HDMI';
    case 'vtc'
        output='vtcCoreObj';
        params=ipName;
        ipcoreName='VTC';
    case 'atg'
        output='atgCoreObj';
        params='atg';
        ipcoreName='TrafficGenerator';
    case 'perf_mon'
        if exist('proObj','var')
            output='profilerObj';
            params='apmCoreObj';
            fcnName=initFcnNames.profileObj;
        else
            output='apmCoreObj';
            params='perf_mon';
        end
        ipcoreName='PerformanceMonitor';
    otherwise
        error(message('soc:msgs:unrecognizeIPType',ipName));
    end
end
function[fcnName,params,output]=getInitFcnName(ipName,defVals,varargin)
    if nargin>2
        input=varargin{1};
    end
    fcnName='initialize';
    vParams=defVals.structNames.frame;
    params=[];
    output=[];
    switch ipName
    case 'mm2s_dma'

    case 's2mm_dma'

    case 'mm2s_vdma'
        params=vParams;

    case 's2mm_vdma'
        params=vParams;

    case 'vdma_frame_buffer'
        params=vParams;

    case 'vdma_hdmi_out'
        params=vParams;

    case 'vtc'
        output=vParams;
        params='FrameInfo';

    case 'atg'
        if exist('input','var')
            fcnName='start';
            params='atgCoreObj';
        else
            fcnName='initialize';
        end
    case 'perf_mon'
        switch input
        case 'init'
            fcnName='initialize';
            params='apmCoreObj';
        case 'collect'
            fcnName='collectMemoryStatistics';
            params='profilerObj';
        case 'plotProfile'
            fcnName='plotMemoryStatistics';
            params='profilerObj';
        case 'plotTrace'
            fcnName='plotMemoryStatistics';
            params='profilerObj';
        end
    otherwise
        error(message('soc:msgs:unrecognizeIPType',ipName));
    end
end

function putTestbenchArea(fid,AXIMasterInfo,masterObj,defVals)
    spaceTab=0;
    perfMonParams=defVals.perfMonParams;
    atgStructName=defVals.structNames.ATG;
    numRuns=defVals.structNames.numRuns;
    if isfield(AXIMasterInfo,perfMonParams.structName)
        [fcnName,~,~]=getInitFcnName('perf_mon',defVals,'init');
        fprintf(fid,'%s(%s);\n',fcnName,'apmCoreObj');
    end
    fprintf(fid,'%%%% Run testbench\n\n');


    if isfield(AXIMasterInfo,perfMonParams.structName)
        ipName=perfMonParams.structName;
        fprintf(fid,'switch perfMonMode \n');
        fprintf(fid,'%scase ''Profile''...\n',getTabStr(1));
        spaceTab=2;
        [fcnName,ipstructure,output,~]=getObjFunName(ipName,defVals,'proObj');
        fprintf(fid,'\n%s%s=%s(%s,%s);\n',getTabStr(spaceTab),output,fcnName,'hwObj',ipstructure);
    end

    if isfield(AXIMasterInfo,atgStructName)
        ipName=atgStructName;
        fprintf(fid,'%s%% Enable ATG(s)\n',getTabStr(spaceTab));
        [fcnName,params,~]=getInitFcnName(ipName,defVals,'run');
        fprintf(fid,'%s%s(%s);\n',getTabStr(spaceTab),fcnName,params);
    end

    if isfield(AXIMasterInfo,perfMonParams.structName)
        ipName=perfMonParams.structName;
        [fcnName,params,~]=getInitFcnName(ipName,defVals,'collect');
        fprintf(fid,'\n%s%% Adjust ''%s'' variable to change the number of consecutive runs of the testbench\n',getTabStr(spaceTab),numRuns);
        fprintf(fid,'%s%s = 100;\n',getTabStr(spaceTab),numRuns);
        fprintf(fid,'%sfor n = 1:%s\n',getTabStr(spaceTab),numRuns);
        fprintf(fid,'%s%s(%s);\n\n',getTabStr(spaceTab+1),fcnName,params);
        fprintf(fid,'%send\n\n',getTabStr(spaceTab));
        [fcnName,params,~]=getInitFcnName(ipName,defVals,'plotProfile');
        fprintf(fid,'%s%% Plot the Performance\n',getTabStr(spaceTab));
        fprintf(fid,'%s%s(%s);\n',getTabStr(spaceTab),fcnName,params);

        fprintf(fid,'%scase ''Trace''...\n',getTabStr(1));

        [fcnName,ipstructure,output,~]=getObjFunName(ipName,defVals,'proObj');
        fprintf(fid,'\n%s%s=%s(%s,%s);\n',getTabStr(spaceTab),output,fcnName,'hwObj',ipstructure);


        if isfield(AXIMasterInfo,atgStructName)
            ipName=atgStructName;
            fprintf(fid,'%s%% Enable ATG(s)\n',getTabStr(spaceTab));
            [fcnName,params,~]=getInitFcnName(ipName,defVals,'run');
            fprintf(fid,'%s%s(%s);\n',getTabStr(spaceTab),fcnName,params);
        end


        ipName=perfMonParams.structName;
        [fcnName,params,~]=getInitFcnName(ipName,defVals,'collect');
        fprintf(fid,'\n%s%% Stop trace mode and obtain trace data.\n',getTabStr(spaceTab));
        fprintf(fid,'%s%% Make sure AXI transactions finished before stopping trace mode.\n',getTabStr(spaceTab));
        fprintf(fid,'%s%s(%s);\n',getTabStr(spaceTab),fcnName,params);
        [fcnName,params,~]=getInitFcnName(ipName,defVals,'plotTrace');
        fprintf(fid,'\n%s%% Display diagnostic trace waveforms in Logic Analyzer\n',getTabStr(spaceTab));
        fprintf(fid,'%s%s(%s);\n',getTabStr(spaceTab),fcnName,params);
        fprintf(fid,'end\n\n');
    else
        fprintf(fid,'%% Adjust ''%s'' variable to change the number of consecutive runs of the testbench\n',numRuns);
        fprintf(fid,['%s = 1;\n'...
        ,'for n = 1:%s\n'...
        ,'    %% Insert testbench stimulus here ...\n'...
        ,'end\n'],numRuns,numRuns);
    end
end

function aximasterwrite(fid,objName,addr,val,varargin)
    comments='';
    if nargin>4
        comments=[' % ',varargin{1}];
    end
    fprintf(fid,'writememory(%s,%s, uint32(%s));%s\n',objName,addr,val,comments);
end

function aximasterread(fid,objName,addr,len)
    fprintf(fid,'readmemory(%s,%s, %s);\n',objName,addr,len);
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