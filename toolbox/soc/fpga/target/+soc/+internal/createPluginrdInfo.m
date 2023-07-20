function pluginrdInfo=createPluginrdInfo(hbuild,workflow)



    dutName=workflow.dutName;
    index=find(cellfun(@(x)~isempty(x.BlkName)&&contains(x.BlkName,dutName),hbuild.ComponentList));
    pluginrdInfo.ipName=hbuild.ComponentList{index}.Name;

    pluginrdInfo.refDesignName=workflow.designName;
    pluginrdInfo.board_name=workflow.boardName;

    pluginrdInfo.clock=hbuild.(hbuild.ComponentList{index}.Clk(1).driver).source;
    pluginrdInfo.reset=hbuild.(hbuild.ComponentList{index}.Rst(1).driver).source;

    pluginrdInfo.prj_dir=hbuild.ProjectDir;

    num_master=0;
    intc_gp=hbuild.Interconnect;

    memMst_idx=arrayfun(@(x)(strcmpi(x.usage,'memPS')||strcmpi(x.usage,'memPL')),intc_gp.master,'UniformOutput',true);
    intc_gp.master(memMst_idx)=[];
    num_master=numel(intc_gp.master);
    temp={intc_gp.master.name};
    master_name='';
    master_intel='';
    for ii=1:num_master
        if(ii==1)
            master_name=[master_name,temp{ii}];
            master_intel=[master_intel,sprintf('''%s''',temp{ii})];
        else
            master_name=[master_name,' ',temp{ii}];
            master_intel=sprintf('{%s,''%s''}',master_intel,temp{ii});
        end
    end



    offsetAddr=sprintf('''%s''',hbuild.ComponentList{index}.AXI4Slave.offset);
    if((num_master==1)||(num_master==0))
        offsetCell=offsetAddr;
    else
        offsetCell=['{',offsetAddr,',',offsetAddr,'}'];
    end

    pluginrdInfo.AXI4Lite.baceAddr=offsetCell;
    if(strcmp(hbuild.Vendor,'Intel'))
        pluginrdInfo.AXI4Lite.MasterAddressSpace=master_intel;
    else
        pluginrdInfo.AXI4Lite.MasterAddressSpace={};
    end
    axiLiteintrindex=find(cellfun(@(x)contains(x,pluginrdInfo.ipName),{hbuild.Interconnect.slave.name}));
    pluginrdInfo.AXI4Lite.InterfaceConnection=['S',sprintf('%02d',axiLiteintrindex)];
    AXIInterface=regexprep(hbuild.ComponentList{index}.AXIInterface,'[\W]*','_');


    mstIdx=1;
    slvIdx=1;
    numVStreamMaster=0;
    numVStreamSlave=0;
    numStreamMaster=0;
    numStreamSlave=0;
    for i=1:numel(AXIInterface)
        if(contains(AXIInterface{i},'Master'))

            if(contains(AXIInterface{i},'AXI4_Stream_Video'))
                numVStreamMaster=numVStreamMaster+1;
                pluginrdInfo.AXI_Stream_Video_Master(mstIdx).MstrChnlNum=mstIdx;

                if(strcmp(hbuild.Vendor,'Xilinx'))
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'/',AXIInterface{i}]),hbuild.Connections));
                else
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'.',AXIInterface{i}]),hbuild.Connections));
                end
                if~isempty(conIndex)
                    if(mod(conIndex,2)==0)
                        pluginrdInfo.AXI_Stream_Video_Master(mstIdx).MstrChnlCon=hbuild.Connections{conIndex-1};
                    else
                        pluginrdInfo.AXI_Stream_Video_Master(mstIdx).MstrChnlCon=hbuild.Connections{conIndex+1};
                    end
                end
                pluginrdInfo.AXI_Stream_Video_Master(mstIdx).Mstrdw={};
                pluginrdInfo.AXI_Stream_Video_Master(mstIdx).MstrIntrID=['AXI4-Stream Video',sprintf('%d',i)];

            elseif(contains(AXIInterface{i},'AXI4_Stream'))
                numStreamMaster=numStreamMaster+1;
                pluginrdInfo.AXI_Stream_Master(mstIdx).MstrChnlNum=mstIdx;

                if(strcmp(hbuild.Vendor,'Xilinx'))
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'/',AXIInterface{i}]),hbuild.Connections));
                else
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'.',AXIInterface{i}]),hbuild.Connections));
                end
                if~isempty(conIndex)
                    if(mod(conIndex,2)==0)
                        pluginrdInfo.AXI_Stream_Master(mstIdx).MstrChnlCon=hbuild.Connections{conIndex-1};
                    else
                        pluginrdInfo.AXI_Stream_Master(mstIdx).MstrChnlCon=hbuild.Connections{conIndex+1};
                    end
                end
                pluginrdInfo.AXI_Stream_Master(mstIdx).Mstrdw={};
                pluginrdInfo.AXI_Stream_Master(mstIdx).MstrIntrID=['AXI4-Stream',sprintf('%d',i)];
            end
            mstIdx=mstIdx+1;
        else

            if(contains(AXIInterface{i},'AXI4_Stream_Video'))
                numVStreamSlave=numVStreamSlave+1;
                pluginrdInfo.AXI_Stream_Video_Slave(slvIdx).SlvChnlNum=slvIdx;

                if(strcmp(hbuild.Vendor,'Xilinx'))
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'/',AXIInterface{i}]),hbuild.Connections));
                else
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'.',AXIInterface{i}]),hbuild.Connections));
                end
                if~isempty(conIndex)
                    if(mod(conIndex,2)==0)
                        pluginrdInfo.AXI_Stream_Video_Slave(slvIdx).SlvChnlCon=hbuild.Connections{conIndex-1};
                    else
                        pluginrdInfo.AXI_Stream_Video_Slave(slvIdx).SlvChnlCon=hbuild.Connections{conIndex+1};
                    end
                end
                pluginrdInfo.AXI_Stream_Video_Slave(slvIdx).Slvdw={};
                pluginrdInfo.AXI_Stream_Video_Slave(slvIdx).SlvIntrID=['AXI4-Stream Video',sprintf('%d',i)];

            elseif(contains(AXIInterface{i},'AXI4_Stream'))
                numStreamSlave=numStreamSlave+1;
                pluginrdInfo.AXI_Stream_Slave(slvIdx).SlvChnlNum=slvIdx;

                if(strcmp(hbuild.Vendor,'Xilinx'))
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'/',AXIInterface{i}]),hbuild.Connections));
                else
                    conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'.',AXIInterface{i}]),hbuild.Connections));
                end
                if~isempty(conIndex)
                    if(mod(conIndex,2)==0)
                        pluginrdInfo.AXI_Stream_Slave(slvIdx).SlvChnlCon=hbuild.Connections{conIndex-1};
                    else
                        pluginrdInfo.AXI_Stream_Slave(slvIdx).SlvChnlCon=hbuild.Connections{conIndex+1};
                    end
                end
                pluginrdInfo.AXI_Stream_Slave(slvIdx).Slvdw={};
                pluginrdInfo.AXI_Stream_Slave(slvIdx).SlvIntrID=['AXI4-Stream',sprintf('%d',i)];
            end
            slvIdx=slvIdx+1;
        end
    end


    numRandAccMaster=0;
    readRandAccMaster=[];
    writeRandAccMaster=[];
    pluginrdInfo.AXI_Master=[];
    if(numel(hbuild.ComponentList{index}.AXI4Master)~=0)

        dutIdx=find(cellfun(@(x)contains(x,workflow.dutName),soc.util.getDUT(hbuild.SystemName)));
        dutNames=soc.util.getDUT(hbuild.SystemName);
        soc.util.getDUTIntfInfo(hbuild,dutNames{dutIdx},hbuild.MemMap);
        load(fullfile(pwd,'dutIntfInfo.mat'),'dutIntfInfo');
        delete('dutIntfInfo.mat');
    end
    for ii=1:numel(hbuild.ComponentList{index}.AXI4Master)
        numRandAccMaster=numRandAccMaster+1;
        pluginrdInfo.AXI_Master(ii).MstrChnlNum=num2str(ii);
        pluginrdInfo.AXI_Master(ii).MstrIntrID=['AXI4 Master ',num2str(ii-1)];
        pluginrdInfo.AXI_Master(ii).MstrRdSupport='true';
        pluginrdInfo.AXI_Master(ii).MstrWrSupport='true';
        pluginrdInfo.AXI_Master(ii).MstrMaxDw=[];
        pluginrdInfo.AXI_Master(ii).MstrMaxAw=[];
        pluginrdInfo.AXI_Master(ii).TrgAddrSpace='';
        pluginrdInfo.AXI_Master(ii).MstrChnlCon='';



        conIndex=find(cellfun(@(x)contains(x,[pluginrdInfo.ipName,'/AXI4_Master_',num2str(ii-1)]),{hbuild.Interconnect.master.name}),1);
        if~isempty(conIndex)
            pluginrdInfo.AXI_Master(ii).MstrChnlCon=['axi_intc','S',sprintf('%02d',ii-1),'_AXI'];
        end

        rdIntf=['AXI4 Master ',num2str(ii-1),' Read'];
        wrIntf=['AXI4 Master ',num2str(ii-1),' Write'];

        if isKey(dutIntfInfo,rdIntf)&&isKey(dutIntfInfo,wrIntf)
            readRandAccMaster=[readRandAccMaster,1];
            writeRandAccMaster=[writeRandAccMaster,1];
            pluginrdInfo.AXI_Master(ii).DefaultReadBaseAddr=dutIntfInfo(rdIntf);
            pluginrdInfo.AXI_Master(ii).DefaultWriteBaseAddr=dutIntfInfo(wrIntf);
        elseif isKey(dutIntfInfo,rdIntf)
            readRandAccMaster=[readRandAccMaster,1];
            writeRandAccMaster=[writeRandAccMaster,0];
            pluginrdInfo.AXI_Master(ii).DefaultReadBaseAddr=dutIntfInfo(rdIntf);
            pluginrdInfo.AXI_Master(ii).DefaultWriteBaseAddr=dutIntfInfo(rdIntf);


        elseif isKey(dutIntfInfo,wrIntf)
            readRandAccMaster=[readRandAccMaster,0];
            writeRandAccMaster=[writeRandAccMaster,1];
            pluginrdInfo.AXI_Master(ii).DefaultWriteBaseAddr=dutIntfInfo(wrIntf);
            pluginrdInfo.AXI_Master(ii).DefaultReadBaseAddr=dutIntfInfo(wrIntf);

        end
    end

    interPorts='';
    ledPorts='';
    dsPorts='';
    pbPorts='';
    ledIdx=1;
    pbIdx=1;
    dsIdx=1;
    intConIdx=1;
    if(~isempty(hbuild.Connections))

        conIndex=find(cellfun(@(x)contains(x,hbuild.ComponentList{index}.Name)&&~contains(x,'Master')&&~contains(x,'Slave'),hbuild.Connections));

        for ii=1:numel(conIndex)
            if(mod(conIndex(ii),2)==1)

                if(contains(hbuild.Connections(conIndex(ii)+1),'LED'))
                    pluginrdInfo.LED(ledIdx)=hbuild.Connections(conIndex(ii)+1);
                    ledIdx=ledIdx+1;
                    ledPorts=[ledPorts,' ',hbuild.Connections{conIndex(ii)+1}];
                elseif(contains(hbuild.Connections(conIndex(ii)+1),'DS'))
                    pluginrdInfo.DS(dsIdx)=hbuild.Connections(conIndex(ii)+1);
                    dsIdx=dsIdx+1;
                    dsPorts=[dsPorts,' ',hbuild.Connections{conIndex(ii)+1}];
                elseif(contains(hbuild.Connections(conIndex(ii)+1),'PB'))
                    pluginrdInfo.DS(pbIdx)=hbuild.Connections(conIndex(ii)+1);
                    pbIdx=pbIdx+1;
                    pbPorts=[pbPorts,' ',hbuild.Connections{conIndex(ii)+1}];
                else
                    pluginrdInfo.IntrCon(intConIdx).InterfaceID=hbuild.Connections{conIndex(ii)+1};
                    pluginrdInfo.IntrCon(intConIdx).PortName=sprintf('internalconnection_%d',ii);
                    pluginrdInfo.IntrCon(intConIdx).InterfaceType='OUT';
                    pluginrdInfo.IntrCon(intConIdx).InterfaceConnection=hbuild.Connections{conIndex(ii)+1};
                    interPorts=[interPorts,' ',hbuild.Connections{conIndex(ii)}];
                    intConIdx=intConIdx+1;
                end
            else

                if(contains(hbuild.Connections(conIndex(ii)-1),'LED'))
                    pluginrdInfo.LED(ledIdx)=hbuild.Connections(conIndex(ii)-1);
                    ledIdx=ledIdx+1;
                    ledPorts=[ledPorts,' ',hbuild.Connections{conIndex(ii)-1}];
                elseif(contains(hbuild.Connections(conIndex(ii)-1),'DS'))
                    pluginrdInfo.DS(dsIdx)=hbuild.Connections(conIndex(ii)-1);
                    dsIdx=dsIdx+1;
                    dsPorts=[dsPorts,' ',hbuild.Connections{conIndex(ii)-1}];
                elseif(contains(hbuild.Connections(conIndex(ii)-1),'PB'))
                    pluginrdInfo.PB(pbIdx)=hbuild.Connections(conIndex(ii)-1);
                    pbIdx=pbIdx+1;
                    pbPorts=[pbPorts,' ',hbuild.Connections{conIndex(ii)-1}];
                else
                    pluginrdInfo.IntrCon(intConIdx).InterfaceID=hbuild.Connections{conIndex(ii)-1};
                    pluginrdInfo.IntrCon(intConIdx).PortName=sprintf('internalconnection_%d',ii);
                    pluginrdInfo.IntrCon(intConIdx).InterfaceType='IN';
                    pluginrdInfo.IntrCon(intConIdx).InterfaceConnection=hbuild.Connections{conIndex(ii)-1};
                    interPorts=[interPorts,' ',hbuild.Connections{conIndex(ii)}];
                    intConIdx=intConIdx+1;
                end
            end
        end
    end


    fid=fopen(fullfile(hbuild.ProjectDir,'read_bd.tcl'),'w');
    fprintf(fid,'set prjPath %s\n',regexprep(fullfile(pluginrdInfo.prj_dir,'vivado_prj.xpr'),'\','/'));
    fprintf(fid,'set blockdesign %s\n',['{',regexprep(fullfile(pluginrdInfo.prj_dir,'vivado_prj.srcs/sources_1/bd/design_1/design_1.bd'),'\','/'),'}']);
    fprintf(fid,'set numMastseg %d\n',num_master);
    fprintf(fid,'set mstSeg [list %s]\n',master_name);
    fprintf(fid,'set dutIPCore %s\n',pluginrdInfo.ipName);
    fprintf(fid,'set numVStreamM %d\n',numVStreamMaster);
    fprintf(fid,'set numVStreamS %d\n',numVStreamSlave);
    fprintf(fid,'set numStreamM %d\n',numStreamMaster);
    fprintf(fid,'set numStreamS %d\n',numStreamSlave);
    fprintf(fid,'set numRandAccM %d\n',numRandAccMaster);
    fprintf(fid,'set readRandAccM [list %s]\n',num2str(readRandAccMaster));
    fprintf(fid,'set writeRandAccM [list %s]\n',num2str(writeRandAccMaster));
    fprintf(fid,'set numIntrCon %d\n',intConIdx-1);
    if(strcmp(hbuild.Vendor,'Intel'))
        fprintf(fid,'set quartusPrjPath %s\n',regexprep(fullfile(hbuild.ProjectDir,'quartus_prj.qpf'),'\','/'));
        fprintf(fid,'set qsysPrjPath %s\n',regexprep(fullfile(hbuild.ProjectDir,'system_top.qsys'),'\','/'));
        fprintf(fid,'set qsysTrgPath %s\n',regexprep(fullfile(workflow.exportDirectory,'system_top.qsys'),'\','/'));
    else
        if(numel(hbuild.ComponentList{index}.AXI4Master)~=0)
            pluginrdInfo.memPLoffset='';
            pluginrdInfo.memPLrange='';
            pluginrdInfo.memPSoffset='';
            pluginrdInfo.memPSrange='';
            if(~isempty(hbuild.MemPL))
                for n=1:numel(hbuild.MemPL.AXI4Slave)
                    fprintf(fid,'set memSeg %s\n',hbuild.MemPL.AXI4Slave.name);
                    pluginrdInfo.memPLoffset=hbuild.MemPL.AXI4Slave(n).offset;
                    pluginrdInfo.memPLrange=l_str2hexRange(hbuild.MemPL.AXI4Slave(n).range);
                end
            end
            if(~isempty(hbuild.MemPS))
                for n=1:numel(hbuild.MemPS.AXI4Slave)
                    fprintf(fid,'set memSeg %s\n',hbuild.MemPS.AXI4Slave(n).name);
                    pluginrdInfo.memPSoffset=hbuild.MemPS.AXI4Slave(n).offset;
                    pluginrdInfo.memPSrange=l_str2hexRange(hbuild.MemPS.AXI4Slave(n).range);
                end
            end
        end
        if(intConIdx~=1)
            fprintf(fid,'set intrPorts [list %s]\n',interPorts);
        end
        fprintf(fid,'set numLeds %d\n',ledIdx-1);
        if(ledIdx~=1)
            fprintf(fid,'set ledPorts [list %s]\n',ledPorts);
        end
        fprintf(fid,'set numDSs %d\n',dsIdx-1);
        if(dsIdx~=1)
            fprintf(fid,'set dsPorts [list %s]\n',dsPorts);
        end
        fprintf(fid,'set numPBs %d\n',pbIdx-1);
        if(pbIdx~=1)
            fprintf(fid,'set pbPorts [list %s]\n',pbPorts);
        end
    end
    pluginrdInfo.procexist=~isempty(hbuild.PS7)||~isempty(hbuild.HPS);
    fclose(fid);
end

function hexRange=l_str2hexRange(strRange)
    switch strRange(end)
    case 'K'
        hexRange=dec2hex(str2num(strRange(1:end-1))*1024,8);
    case 'M'
        hexRange=dec2hex(str2num(strRange(1:end-1))*1024*1024,8);
    case 'G'
        hexRange=dec2hex(str2num(strRange(1:end-1))*1024*1024*1024,8);
    case 'T'
        hexRange=dec2hex(str2num(strRange(1:end-1))*1024*1024*1024*1024,8);
    otherwise
        hexRange=dec2hex(str2num(strRange),8);
    end
    hexRange=['0x',hexRange];
end

