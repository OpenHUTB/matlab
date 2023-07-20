




classdef(Abstract)IPReport<handle


    properties

        ReportFileName='';
        ReportFilePath='';


        hIPEmitter=[];


cssStyles
        isMinClkEnbl;
    end

    properties(Constant)
        ReportFilePostfix='ip_core_report.html';
        ReportTitlePrefix='IP Core Generation Report for';

    end

    properties(Abstract)

IPToolName
    end

    properties(Hidden=true)

        PrintAllReport=false;
    end

    methods(Abstract,Access=protected)

        addSubSectionEmbeddedSystemIntegration(obj,w)
    end

    methods

        function obj=IPReport(hIPEmitter)


            obj.hIPEmitter=hIPEmitter;

            obj.cssStyles.Global.table_GlobalCss=hdlhtmlreporter.CSS.ElementCSS('selector','type','elementName','table','width','100%','border','1px solid black');
            obj.cssStyles.Global.div_GlobalCss=hdlhtmlreporter.CSS.ElementCSS('selector','type','elementName','div','line-heigh','90%');

            obj.cssStyles.Group.tableDistinctRow_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','distinctCellColor','elementName','td','background-color','#eeeeff');
            obj.cssStyles.Group.reportTable_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','reportTableHeader','elementName','thead','background-color','#eeeeee','font-weight','bold');
            obj.cssStyles.Group.summaryTableSndColOddRow_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','summaryTableSndColOddRow','elementName','td','background-color','#eeeeff','text-align','right');
            obj.cssStyles.Group.summaryTableSndColEvenRow_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','summaryTableSndColEvenRow','elementName','td','text-align','right');
            obj.cssStyles.Group.section_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','sectionHeading','elementName','h3','color','#000066','font-weight','bold');
            obj.cssStyles.Group.title_GroupCss=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','title','elementName','h2','color','#000066','font-weight','bold');
        end

        function generateReport(obj)


            obj.ReportFileName=getReportFileName(obj);
            obj.ReportFilePath=getReportFilePath(obj);


            docHtmlFilePath=obj.ReportFilePath;


            reportTitleStr=sprintf('%s %s',obj.ReportTitlePrefix,getModelName(obj));


            globalCss={obj.cssStyles.Global.table_GlobalCss,obj.cssStyles.Global.div_GlobalCss};
            w=hdlhtmlreporter.hdlhtmlreporter(docHtmlFilePath,reportTitleStr,{},globalCss);

            w.addHeading(reportTitleStr,2,{obj.cssStyles.Group.title_GroupCss});


            addSummarySection(obj,w);


            addInterfaceSection(obj,w);

            if~isempty(obj.getBusProtocal)

                addAddressSection(obj,w);
            end


            addBitPackingOrder(obj,w);

            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            dcPorts=hTurnkey.hTable.hTableMap.getConnectedPortList('FPGA Data Capture');
            hasDataCpature=numel(dcPorts)>0;


            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('IP Core User Guide',sectionCss);

            addIPCoreGuide(obj,w);

            if hasDataCpature
                bufferSize=hTurnkey.hD.hIP.getIPDataCaptureBufferSize;
                sequenceDepth=hTurnkey.hD.hIP.getIPDataCaptureSequenceDepth;

                addFPGADataCaptureGuide(obj,w,bufferSize,sequenceDepth);

            end


            if(hTurnkey.hStream.isFrameToSampleMode)

                addFrameToSample(obj,w);
            end

            w.commitSection;


            addFileListSection(obj,w)


            w.dumpHTML;


            copyToHDLCodeGenReportFolder(obj);


            link=obj.getCmdLineLink(obj.ReportFileName,obj.ReportFilePath);
            hdldisp(message('hdlcommon:hdlturnkey:IPCoreReportGen',link).getString());

        end

        function showReport(obj)
            reportFilePath=obj.getReportFilePath;
            web(reportFilePath,'-new');
        end

        function copyToHDLCodeGenReportFolder(obj)


            sourcePath=obj.getReportFilePath;
            targetPath=obj.getPCoreReportHtmlFilePath;

            copyfile(sourcePath,targetPath,'f');
        end

        function reportFileName=getReportFileName(obj)

            reportFileName=sprintf('%s_%s',getModelName(obj),obj.ReportFilePostfix);
        end

        function docHtmlFilePath=getReportFilePath(obj)

            docHtmlFilePath=fullfile(obj.getPCoreDocFolder,getReportFileName(obj));
        end

        function reportFilePath=getReportFileRelativePath(obj)

            reportFilePath=fullfile(obj.hIPEmitter.DocFolder,obj.ReportFileName);
        end

        function docFolder=getPCoreDocFolder(obj)

            docFolder=fullfile(obj.hIPEmitter.hIP.getIPCoreFolder,obj.hIPEmitter.DocFolder);
        end

        function reportFolder=getPCoreReportFolder(obj)

            codegenFolder=obj.getDIDriver.hCodeGen.hCHandle.hdlGetCodegendir;
            if obj.getDIDriver.isMLHDLC
                reportFolder=codegenFolder;
            else
                reportFolder=fullfile(codegenFolder,'html');
            end
        end

        function reportHtmlFilePath=getPCoreReportHtmlFilePath(obj)

            reportHtmlFilePath=fullfile(getPCoreReportFolder(obj),getReportFileName(obj));
        end


        function link=generateSystemLink(obj,path,h)
            if isempty(path)
                link=hdlhtmlreporter.html.Text('');
                return;
            end

            if~obj.getDIDriver.isMLHDLC
                if nargin<3
                    h=[];
                end

                if isempty(h)
                    try
                        h=get_param(path,'Handle');
                    catch
                        h=[];
                    end
                end
                [~,nameVisible]=fileparts(path);
                if isempty(h)
                    link=hdlhtmlreporter.html.Text(path);
                else
                    link=obj.generateSystemLinkFromHandle(nameVisible,h);
                end
            else
                link=hdlhtmlreporter.html.Text(path);
            end
        end

    end

    methods(Access=protected)

        function addSummarySection(obj,w)



            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('Summary',sectionCss);


            hCodeGen=obj.getDIDriver.hCodeGen;
            modelName=hCodeGen.ModelName;
            dutName=hCodeGen.getDutName;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='Verilog';
            end
            pcoreFolderPath=obj.hIPEmitter.hIP.getIPCoreFolder;
            ipcoreFolderLink=getFolderLink(obj,pcoreFolderPath,pcoreFolderPath);


            info={};
            info{end+1}={'IP core name',obj.hIPEmitter.hIP.getIPCoreName};
            info{end+1}={'IP core version',obj.hIPEmitter.hIP.getIPCoreVersion};

            info{end+1}={'IP core folder',ipcoreFolderLink};


            info=obj.addSummaryExtraIPCoreItem(info);


            ipRepository=obj.hIPEmitter.hIP.getIPRepository;
            if~isempty(ipRepository)
                info{end+1}={'IP repository',ipRepository};
            end

            info{end+1}={'Target platform',obj.getDIDriver.get('Board')};
            info{end+1}={'Target tool',obj.getDIDriver.get('Tool')};
            info{end+1}={'Target language',targetL};


            if obj.getDIDriver.showEmbeddedTasks
                info{end+1}={'Reference Design',obj.hIPEmitter.hIP.getReferenceDesign};
            end

            if~obj.getDIDriver.isMLHDLC
                info{end+1}={'Model',obj.generateSystemLink(modelName)};
                info{end+1}={'Model version',get_param(modelName,'ModelVersion')};
            else
                info{end+1}={'Function/Script Name',obj.generateSystemLink(modelName)};
            end
            hdlCoderVerInfo=ver('hdlcoder');
            version=hdlCoderVerInfo.Version;
            info{end+1}={'HDL Coder version',version};

            info{end+1}={'IP core generated on',datestr(obj.hIPEmitter.hIP.getTimestamp)};
            info{end+1}={'IP core generated for',...
            obj.generateSystemLink(dutName)};


            rowNum=length(info);
            colNum=length(info{1});
            table=w.createTable(rowNum,colNum,false);
            numResources=length(info);
            for i=1:numResources
                if mod(i,2)
                    cellCssStyleFirstCol={obj.cssStyles.Group.tableDistinctRow_GroupCss};
                    cellCssStyleSndCol={obj.cssStyles.Group.summaryTableSndColOddRow_GroupCss};
                else
                    cellCssStyleFirstCol={};
                    cellCssStyleSndCol={obj.cssStyles.Group.summaryTableSndColEvenRow_GroupCss};
                end

                table.createEntry(i,1,cellCssStyleFirstCol);
                entry1=info{i}{1};
                if ischar(entry1)
                    table.addText(entry1);
                else
                    table.addObject(entry1);
                end

                table.createEntry(i,2,cellCssStyleSndCol);
                entry2=info{i}{2};
                if ischar(entry2)
                    table.addText(entry2);
                else
                    table.addObject(entry2);
                end
            end
            w.commitTable(table)
            w.commitSection;
        end

        function info=addSummaryExtraIPCoreItem(~,info)

        end

        function addInterfaceSection(obj,w)



            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('Target Interface Configuration',sectionCss);

            if~isempty(obj.getBusProtocal)

                hCodeGen=obj.getDIDriver.hCodeGen;
                modelName=hCodeGen.ModelName;
                interfaceStr=sprintf('You chose the following target interface configuration for ');
                w.addText(interfaceStr);
                modelLink=obj.generateSystemLink(modelName);
                w.addObject(modelLink);
                w.addText(':');
                w.addBreak(2);


                execMode=obj.getDIDriver.get('ExecutionMode');
                w.addText('Processor/FPGA synchronization mode: ');
                w.addBoldText(execMode);
                w.addBreak(2);
            end


            w.addText('Target platform interface table:');
            w.addBreak(1);
            [info,header]=obj.getDIDriver.hTurnkey.hTable.drawReportTable;


            addReportTable(obj,w,info,header);
            w.commitSection;
        end

        function addAddressSection(obj,w)

            hTurnkey=obj.getDIDriver.hTurnkey;


            [busProtocal,hBusInterface]=obj.getBusProtocal;
            if hBusInterface.isEmptyAXI4SlaveInterface
                return;
            end


            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('Register Address Mapping',sectionCss);


            obj.isMinClkEnbl=obj.hIPEmitter.hIP.hD.hTurnkey.hElab.hDUTLayer.MinimizeClkEnableActive;


            info={};
            info=hBusInterface.hBaseAddr.exportAddressList(info,obj.isMinClkEnbl);
            defineVectorStrobe=strcmp('Free running',obj.hIPEmitter.hIP.hD.get('ExecutionMode'));
            [info,header]=hBusInterface.hIPCoreAddr.exportAddressList(info,obj.isMinClkEnbl,defineVectorStrobe);


            addrStr=sprintf('The following %s bus accessible registers were generated for this IP core:',busProtocal);
            w.addText(addrStr);
            w.addBreak(2);


            addReportTable(obj,w,info,header);
            w.addBreak(1);



            hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;
            if obj.getDIDriver.showEmbeddedTasks
                isAXI4SlaveInterfaceInuse=hRD.isAXI4SlaveInterfaceInUse;
                refdesign=obj.hIPEmitter.hIP.getReferenceDesign;



                if isAXI4SlaveInterfaceInuse
                    baseaddr=hRD.getAXI4SlaveBaseAddress;
                    addrspace=hRD.getAXISlaveMasterAddressSpace;
                    fileStr1=sprintf('Following are the AXI4 slave Base address and Master address space specified in the reference design:');
                    w.addText(fileStr1);
                    fileStr2=(sprintf('%s.',refdesign));
                    w.addBoldText(fileStr2);
                    w.addBreak(1);
                    fileStr3=sprintf('AXI4 Slave Base Address:');
                    w.addText(fileStr3);
                    if iscell(baseaddr)
                        fileStr4=sprintf('%s\t',baseaddr{:});
                    else
                        fileStr4=sprintf('%s',baseaddr);
                    end
                    w.addBoldText(fileStr4);
                    w.addBreak(1);
                    fileStr5=sprintf('AXI4 Slave Master connection:');
                    w.addText(fileStr5);
                    if iscell(addrspace)
                        fileStr6=sprintf('%s\t',addrspace{:});
                    else
                        fileStr6=sprintf('%s',addrspace);
                    end
                    w.addBoldText(fileStr6);
                    w.addBreak(1);
                    fileStr7=sprintf('Use the AXI4 Slave Base Address plus Address offset to access the IP Core registers shown in Register Address Mapping table');
                    w.addText(fileStr7);
                    w.addBreak(2);
                end
            end


            AXI4RegisterReadback=hTurnkey.hD.hIP.getAXI4ReadbackEnable;



            if(AXI4RegisterReadback)
                readbackStr='ON';
            else
                readbackStr='OFF';
            end



            addReadbackStr=sprintf('The AXI4 slave write register readback is %s for the IP core.',readbackStr);
            w.addText(addReadbackStr);
            w.addBreak(1);


            fileStr='The register address mapping is also in the following C header file for you to use when programming the processor:';
            w.addText(fileStr);
            w.addBreak(1);

            chFolder=obj.hIPEmitter.CHeaderFolder;
            chFileStr=fullfile(chFolder,obj.hIPEmitter.hCHEmitter.CHeaderFileName);
            chLink=getFileLink(obj,chFileStr,obj.hIPEmitter.hCHEmitter.CHeaderFilePath);
            w.addObject(chLink);
            w.addBreak(1);
            w.addText('The IP core name is appended to the register names to avoid name conflicts.');
            w.commitSection;
        end


        function addBitPackingOrder(obj,w)



            isVectorSignalPresent=0;
            hTurnkey=obj.getDIDriver.hTurnkey;


            [isExternalInterfaceAssigned,~,hIOPortCell]=hdlturnkey.interface.InterfaceExternal.isExternalInterfaceAssigned(hTurnkey);
            if isExternalInterfaceAssigned
                for i=1:length(hIOPortCell)
                    isVectorSignalPresent=isVectorSignalPresent||hIOPortCell{i}.isVector;
                end
            end

            [isExternalIOInterfaceAssigned,~,hIOPortCell]=hdlturnkey.interface.InterfaceExternalIO.isExternalIOInterfaceAssigned(hTurnkey);
            if isExternalIOInterfaceAssigned
                for i=1:length(hIOPortCell)
                    isVectorSignalPresent=isVectorSignalPresent||hIOPortCell{i}.isVector;
                end
            end

            [isInternalIOInterfaceAssigned,~,hIOPortCell]=hdlturnkey.interface.InterfaceInternalIOBase.isInternalIOInterfaceAssigned(hTurnkey);
            if isInternalIOInterfaceAssigned
                for i=1:length(hIOPortCell)
                    isVectorSignalPresent=isVectorSignalPresent||hIOPortCell{i}.isVector;
                end
            end



            if isVectorSignalPresent
                sectionCss={obj.cssStyles.Group.section_GroupCss};
                w.addSection('Bit Packing Order',sectionCss);

                fileStr1=sprintf('Following is the general representation of data packing order and data unpacking order for Vector Input and output cases for Internal IO, External IO and External port interfaces.');
                fileStr2=sprintf('If it is assumed that an interface is mapped to one input(or output) port of the model which has a port width of 128 and port dimension of 4, then:');
                w.addText(fileStr1);
                w.addText(fileStr2);
                w.addBreak(2);
                fileStr3=sprintf(' Following is the bit packing order to the DUT IP for Input vector case.');
                w.addText(fileStr3);
                w.addBreak(2);

                obj.addReportImage(w,'InBitPacking.jpg');
                w.addBreak(1);

                fileStr4=sprintf(' Following is the bit unpacking order from the DUT IP for Vector Output case.');
                w.addText(fileStr4);
                w.addBreak(2);

                obj.addReportImage(w,'OutBitPacking.jpg');
                fileStr5=sprintf('It should be noted that the above instances are just for demonstration purpose and may not represent the actual mapped port width and port dimension. ');
                w.addText(fileStr5);
                w.commitSection;
            end
        end

        function addFrameToSample(obj,w)

            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('Frame to Sample Mode',sectionCss);

            hCodeGen=obj.getDIDriver.hCodeGen;
            modelName=hCodeGen.ModelName;
            interfaceStr=sprintf('You enabled the streaming matrix transform for ');
            w.addText(interfaceStr);
            modelLink=obj.generateSystemLink(modelName);
            w.addObject(modelLink);
            w.addText(':');
            w.addBreak(2);

            fileStr1=sprintf('HDL Coder generated the valid/ready signals for the streamed ports and the logic to handle the back pressure. These signals are mapped to TValid and TReady for the AXI4 Stream interfaces referenced in the target platform interface table.');
            w.addText(fileStr1);

            w.commitSection;

        end

        function addIPCoreGuide(obj,w)


            hTurnkey=obj.getDIDriver.hTurnkey;



            w.addBoldText('Theory of Operation');
            w.addBreak(2);




            AXI4RegisterReadbackPipelineRatio=hTurnkey.hD.hIP.getInsertAXI4PipelineRegisterEnable;




            AXI4IORegisterCount=hTurnkey.getDefaultBusInterface.AXI4IORegCount;



            readDelay=hTurnkey.getDefaultBusInterface.AXI4ReadDelay+1;



            if strcmp(AXI4RegisterReadbackPipelineRatio,'auto')
                AXI4RegisterReadbackPipelineRatioValue=35;
            elseif strcmp(AXI4RegisterReadbackPipelineRatio,'off')
                AXI4RegisterReadbackPipelineRatioValue=0;
            else
                AXI4RegisterReadbackPipelineRatioValue=str2double(AXI4RegisterReadbackPipelineRatio);
            end

            if obj.PrintAllReport

                if~isempty(obj.getBusProtocal)
                    addSubSectionAXIInterface(obj,w);
                end
                w.addBoldText('[Comment, not in real report] Optional (External Port):');
                w.addBreak(1);
                addSubSectionExternal(obj,w);
            else

                if~isempty(obj.getBusProtocal)
                    addSubSectionAXIInterface(obj,w);
                end
                if hdlturnkey.interface.InterfaceExternal.isExternalInterfaceAssigned(hTurnkey)
                    addSubSectionExternal(obj,w);
                end


                if(AXI4RegisterReadbackPipelineRatioValue~=0)&&~isempty(obj.getBusProtocal)
                    addPipelineRegisterAXISection(obj,w,AXI4RegisterReadbackPipelineRatioValue,AXI4IORegisterCount,readDelay);
                    w.addBreak(2);
                end
            end

            if~isempty(obj.getBusProtocal)



                w.addBoldText('Processor/FPGA Synchronization');
                w.addBreak(2);


                if obj.PrintAllReport

                    w.addBoldText('[Comment] Option1 (Free running):');
                    w.addBreak(1);
                    addSubSectionFreeRunning(obj,w);

                    imageName=hTurnkey.hExecMode.getExecModeImage('Free running');
                    obj.addReportImage(w,imageName);

                    w.addBoldText('[Comment] Option2 (Coprocessing):');
                    w.addBreak(1);
                    addSubSectionCoprocessing(obj,w);

                    imageName=hTurnkey.hExecMode.getExecModeImage('Coprocessing - blocking');
                    obj.addReportImage(w,imageName);

                else
                    if hTurnkey.isCoProcessorMode
                        addSubSectionCoprocessing(obj,w);
                    else
                        addSubSectionFreeRunning(obj,w);
                    end
                end


                execMode=obj.getDIDriver.get('ExecutionMode');
                imageName=hTurnkey.hExecMode.getExecModeImage(execMode);
                obj.addReportImage(w,imageName);



                [~,hBusInterface]=obj.getBusProtocal;
                if~isempty(hBusInterface)&&hBusInterface.hIPCoreAddr.HasStrobePort
                    addSubSectionvectorStrobe(obj,w);
                end



                hRD=hTurnkey.hD.hIP.getReferenceDesignPlugin;




                if~isempty(hRD)
                    hasDynamicAXI4SlaveInterface=hRD.hasDynamicAXI4SlaveInterface;
                    if hasDynamicAXI4SlaveInterface
                        w.addBoldText(sprintf('Use AXI Manager to control the IP core from MATLAB'));
                        w.addBreak(2);


                        BaseAddr=hRD.getAXI4SlaveBaseAddress;

                        IPAddress=string(hRD.getEthernetIPAddressValue);
                        PortAddress=string(hRD.EthernetPortAddr);
                        NumChannels=hRD.EthernetNumChannels;
                        MACAddress=hRD.EthernetMACAddr;

                        Interface=string(hRD.getAXIParameterValue);
                        InterfaceFdc=string(hRD.getFDCParameterValue);
                        fileStr1=sprintf(' In 1.2 Step "Set Target Reference design", "Insert AXI Manager" is set to "%s". This adds Matlab as an "AXI Manager" to control the DUT IP core using AXI4 interface as shown.',Interface);
                        w.addText(fileStr1);
                        w.addBreak(2);


                        if Interface=='JTAG'
                            obj.addReportImage(w,'Insert_JTAG_AXI_Master.jpg');
                        else
                            obj.addReportImage(w,'Insert_Ethernet_AXI_Manager.jpg');
                        end
                        w.addBreak(1);


                        fileStr2=sprintf('Requires a HDL Verifier license to use this feature. After that use MATLAB® Command line interface to access the DUT IP core registers. The Base Address of AXI4 Slave is ');
                        w.addText(fileStr2);

                        if((InterfaceFdc=='Ethernet')||(Interface=='Ethernet'))
                            fileStr3=(sprintf('%s .',BaseAddr));
                            w.addBoldText(fileStr3);
                            w.addBreak(2);
                            fileStrEth1=(sprintf('Ethernet MAC properties:'));
                            w.addText(fileStrEth1);
                            w.addBreak(1);
                            fileStrEth2=(sprintf('Ethernet MAC Address: '));
                            w.addText(fileStrEth2);
                            fileStrEth3=(sprintf('%s',MACAddress));
                            w.addBoldText(fileStrEth3);
                            w.addBreak(1);
                            fileStrEth4=(sprintf('IP Address: '));
                            w.addText(fileStrEth4);
                            fileStrEth5=(sprintf('%s',IPAddress));
                            w.addBoldText(fileStrEth5);
                            w.addBreak(1);
                            fileStrEth6=(sprintf('Number of Ethernet MAC Channels: '));
                            w.addText(fileStrEth6);
                            fileStrEth7=(sprintf('%d',NumChannels));
                            w.addBoldText(fileStrEth7);
                            w.addBreak(1);
                            fileStrEth8=(sprintf('Port Address: '));
                            w.addText(fileStrEth8);
                            fileStrEth9='';
                            udpInterfaces={};
                            for p=1:length(PortAddress)
                                fileStrEth9=[fileStrEth9,(sprintf('%s ',PortAddress{p}))];
                            end

                            w.addBoldText(fileStrEth9);
                            w.addBreak(1);

                            fileStrEth10='(';

                            if hRD.getEthernetAXIParameterValue
                                udpInterfaces=[udpInterfaces,'AXI Manager'];
                            end
                            if hRD.getEthernetFDCParameterValue
                                udpInterfaces=[udpInterfaces,'FPGA Data Capture'];
                            end

                            for p=1:length(udpInterfaces)
                                if(p>=2)
                                    fileStrEth10=[fileStrEth10,', '];
                                end
                                fileStrEth10=[fileStrEth10,(sprintf('%s Port Address : %s ',udpInterfaces{p},PortAddress{p}))];
                            end
                            fileStrEth10=[fileStrEth10,')'];
                            w.addText(fileStrEth10);
                            w.addBreak(2);
                        else
                            fileStr3=(sprintf('%s .',BaseAddr));
                            w.addBoldText(fileStr3);
                            w.addBreak(2);

                        end

                        fileStr4=sprintf('An example AXI Manager commands to access the DUT IP register is :');
                        w.addText(fileStr4);
                        w.addBreak(1);

                        fileStr5=sprintf('1. Create the AXI master object');
                        w.addText(fileStr5);
                        w.addBreak(1);

                        if Interface=='JTAG'
                            fileStr6=sprintf('h = aximanager(\''ToolName\'') Here ToolName = xilinx/altera');
                        else
                            fileStr6=sprintf('h = aximaster(\''ToolName\'',\''interface\'',\''UDP\'',\''DeviceAddress\'',\''%s\''); Here ToolName = xilinx/altera',IPAddress);
                        end
                        w.addText(fileStr6);
                        w.addBreak(2);

                        fileStr7=sprintf('2. Command to write into IP Core registers: ');
                        w.addText(fileStr7);
                        w.addBreak(1);

                        fileStr8=sprintf('h.writememory(\''BaseAddress+AddressOffset\'', WriteValue)');
                        w.addText(fileStr8);
                        w.addBreak(2);

                        fileStr9=sprintf('3. Command to read from IP Core registers: ');
                        w.addText(fileStr9);
                        w.addBreak(1);

                        fileStr10=sprintf('h.readmemory(\''BaseAddress+AddressOffset\'',1)');
                        w.addText(fileStr10);
                        w.addBreak(2);
                    end
                end
            end



            w.addBoldText(sprintf('%s Environment Integration',obj.IPToolName));
            w.addBreak(2);


            addSubSectionEmbeddedSystemIntegration(obj,w);

        end

        function addFPGADataCaptureGuide(obj,w,bufferSize,sequenceDepth)

            w.addBreak(2);
            w.addBoldText('Use FPGA Data Capture');
            w.addBreak(2);

            w.addText(['FPGA Data Capture Buffer Size: ',bufferSize]);
            w.addBreak(1);
            w.addText(['FPGA Data Capture Sequence Depth: ',sequenceDepth]);







            w.addBreak(1);

            folder=fullfile(obj.hIPEmitter.hIP.getIPCoreFolder,'fpga_data_capture');
            w.addText(['The FPGA Data Capture related files are located in ',folder]);
            w.addBreak(1);

            script=['addpath ',folder,';launchDataCaptureApp;'];


            w.addBreak(1);

            w.addText('Capture Data into MATLAB');
            runCmd=['<a href="matlab:',script,'">launchDataCaptureApp</a>'];
            txt=l_getNumberListHtml({...
            ['Run the generated script ',runCmd,' to open the Data Capture app.'],...
            'On the Triggers tab, specify a trigger condition. If you do not specify a condition, the default behavior is to capture data immediately.',...
            'On the Data Types tab, specify data types for the captured signals.',...
            'Press the Capture button to capture data into a workspace variable.'});
            w.addText(txt);
            modelname='FPGADataCapture_model';
            modelpath=fullfile(obj.hIPEmitter.hIP.getIPCoreFolder,'fpga_data_capture',[modelname,'.slx']);
            if exist(modelpath,'file')
                w.addText('Capture Data into Simulink');
                runCmd=['<a href="matlab:addpath ',folder,';',modelname,'">',modelname,'</a>'];
                txt=l_getNumberListHtml({...
                ['In the generated model ',runCmd,', open the FPGA Data Reader block. '],...
                'Click the "Launch Signal and Trigger Editor" button. ',...
                'On the Triggers tab, specify a trigger condition. If you do not specify a condition, the default behavior is to capture data immediately.',...
                'On the Data Types tab, specify data types for the captured signals.',...
                'Run the model to capture data.'});
                w.addText(txt);
            end
            w.addBreak(2);

            function txt=l_getNumberListHtml(input)
                tmp=cell(1,numel(input));
                for m=1:numel(input)
                    tmp{m}=['<li>',input{m},'</li>'];
                end
                txt=['<ol>',tmp{:},'</ol>'];
            end
        end

        function addSupportPackageLink(obj,w)

            fileStr=['If you are targeting Xilinx Zynq hardwares supported by HDL Coder Support Package for Xilinx Zynq Platform, ',...
            'you can select the board you are using in the Target platform option in the Set Target > Set Target Device and Synthesis Tool task. ',...
            sprintf('You can then use Embedded System Integration tasks in HDL Workflow Advisor to help you integrate the generated IP core into %s environment.',obj.IPToolName)];
            w.addText(fileStr);
        end

        function addSubSectionAXIInterface(obj,w)


            hTurnkey=obj.getDIDriver.hTurnkey;

            if obj.PrintAllReport

                w.addBoldText('[Comment, not in real report] Option1 (AXI4 only):');
                w.addBreak(1);
                addParagraphAXIBus(obj,w);
                imageName='doc_arch_axi4_lite.jpg';
                obj.addReportImage(w,imageName);
                w.addBoldText('[Comment, not in real report] Option3 (AXI4 and AXI4-Stream):');
                w.addBreak(1);
                addParagraphAXI4Stream(obj,w);
                w.addBoldText('[Comment, not in real report] Option2 (AXI4 and AXI Stream Video):');
                w.addBreak(1);
                addParagraphAXIVDMA(obj,w);
            else

                addParagraphAXIBus(obj,w);


                busProtocal=obj.getBusProtocal;
                switch lower(busProtocal)
                case 'axi4'
                    if hTurnkey.hStream.isAXI4StreamAssigned
                        imageName='doc_arch_axi4_stream.jpg';
                    elseif hTurnkey.hStream.isAXI4VDMAMode
                        imageName='doc_arch_axi4_vstream.jpg';
                    else
                        imageName='doc_arch_axi4.jpg';
                    end
                case 'axi4-lite'
                    if hTurnkey.hStream.isAXI4StreamAssigned
                        imageName='doc_arch_axi4_lite_stream.jpg';
                    elseif hTurnkey.hStream.isAXI4VDMAMode
                        imageName='doc_arch_axi4_lite_vstream.jpg';
                    else
                        imageName='doc_arch_axi4_lite.jpg';
                    end
                otherwise

                    imageName='doc_arch_axi4_lite.jpg';
                end
                obj.addReportImage(w,imageName);

                if hTurnkey.hStream.isAXI4StreamAssigned
                    addParagraphAXI4Stream(obj,w);
                elseif hTurnkey.hStream.isAXI4VDMAMode
                    addParagraphAXIVDMA(obj,w);
                end
            end
        end

        function addParagraphAXIBus(obj,w)

            busProtocal=obj.getBusProtocal;
            busStr1=sprintf('This IP core is designed to be connected to an embedded processor with an ');
            w.addText(busStr1);
            busStr2=sprintf('%s interface. ',busProtocal);
            w.addBoldText(busStr2);
            busStr3=sprintf('The processor acts as master, and the IP core acts as slave. ');
            busStr4=sprintf('By accessing the generated registers via the %s interface, ',busProtocal);
            busStr5=sprintf('the processor can control the IP core, and read and write data from and to the IP core. ');
            busSection=[busStr3,busStr4,busStr5];
            w.addText(busSection);
            w.addBreak(2);

            useStr1=sprintf('For example, to reset the IP core, write 0x1 to the bit 0 of IPCore_Reset register. ');



            if(obj.isMinClkEnbl)
                useStr2=sprintf('');
            else
                useStr2=sprintf('To enable or disable the IP core, write 0x1 or 0x0 to the IPCore_Enable register. ');
            end
            useStr3=sprintf('To access the data ports of the MATLAB/Simulink algorithm, read or write to the associated data registers.');
            useSection=[useStr1,useStr2,useStr3];
            w.addText(useSection);
            w.addBreak(2);
        end

        function addParagraphAXI4Stream(obj,w)

            busProtocal=obj.getBusProtocal;
            hStream=obj.getDIDriver.hTurnkey.hStream;
            streamStr1=sprintf('This IP core also includes the AXI4-Stream interfaces ');
            w.addText(streamStr1);
            streamStr2=sprintf('%s. ',hStream.printAssignedAXI4StreamChannelIDs);
            w.addBoldText(streamStr2);
            streamStr3=sprintf('The AXI4-Stream interfaces can be connected to the processor via a DMA controller, or they can be connected to other IP cores with AXI4-Stream interfaces. ');
            streamStr4=sprintf('For example, the diagram above shows a design using AXI4-Stream interfaces as the data path, and using %s interface as the control path. ',busProtocal);
            useSection=[streamStr3,streamStr4];
            w.addText(useSection);

            msg=hStream.getReadyUnassignedMsg();
            if~isempty(msg)
                w.addBreak(2);
                w.addText(['Warning: ',msg.getString]);
            end
            w.addBreak(2);
        end

        function addParagraphAXIVDMA(obj,w)

            busProtocal=obj.getBusProtocal;
            hTurnkey=obj.getDIDriver.hTurnkey;
            hStreamCell=hTurnkey.hStream.getAssignedAXI4VDMAInterface;
            vdmaStr1=sprintf('This IP core also supports the video streaming interfaces ');
            w.addText(vdmaStr1);
            vdmaStr2=sprintf('%s',hStreamCell{1}.InterfaceID);
            w.addBoldText(vdmaStr2);
            vdmaStr3=sprintf(' and ');
            w.addText(vdmaStr3);
            vdmaStr4=sprintf('%s. ',hStreamCell{2}.InterfaceID);
            w.addBoldText(vdmaStr4);
            vdmaStr5=sprintf('The video streaming interfaces can be connected to the processor via a DMA controller, or they can be connected to other IP cores with the same streaming interfaces. ');
            vdmaStr6=sprintf('This IP core starts to process the streaming data once it detects the incoming input video stream, and it starts to stream out the result as soon as it is available. ');
            vdmaStr7=sprintf('For example, the diagram above shows a design using video streaming interfaces as the data path, and using %s interface as the control path. ',busProtocal);
            useSection=[vdmaStr5,vdmaStr6,vdmaStr7];
            w.addText(useSection);
            w.addBreak(2);
        end

        function addSubSectionExternal(obj,w)
            exStr1=sprintf('This IP core also support the ');
            w.addText(exStr1);
            exStr2=sprintf('External Port ');
            w.addBoldText(exStr2);
            exStr3=sprintf('interface. To connect the external ports to the FPGA external IO pins, add FPGA pin assignment constraints in the %s environment.',...
            obj.IPToolName);
            w.addText(exStr3);
            w.addBreak(2);

        end



        function addPipelineRegisterAXISection(obj,w,pipelineRatio,AXI4IORegisterCount,readDelay)
            pipeStr1=sprintf('The AXI4 Slave port to pipeline register ratio selected as %d in task 3.2 for this model. The default delay to read AXI4 register is one clock cycle.',pipelineRatio);
            w.addText(pipeStr1);
            pipeStr2='Depending on the selected ratio and IO connected to AXI4 interface, register pipelining is introduced in the read logic of AXI4 registers.';
            w.addText(pipeStr2);
            if(pipelineRatio>AXI4IORegisterCount)
                pipeStr6=sprintf('For your model AXI4 pipeline register ratio setting %d is larger than all the readable AXI4 slave registers. Total readable AXI4 slave registers are %d, so no pipelining is added to the AXI4 register read back logic.',pipelineRatio,AXI4IORegisterCount);
                w.addText(pipeStr6);
            else
                pipeStr3='This adds the extra delay along with the default delay in the read logic.';
                w.addText(pipeStr3);
                pipeStr4=sprintf('For this model readable AXI4 slave registers are %d and read delay for each AXI4 register is %d clock cycle.',AXI4IORegisterCount,readDelay);
                w.addText(pipeStr4);
                pipeStr5='Following diagram depicts the read functionality of the AXI4 registers.';
                w.addText(pipeStr5);
                w.addBreak(2);
                imageName='doc_arch_axi4_Pipeline_Register.jpg';
                obj.addReportImage(w,imageName);
            end
        end

        function addSubSectionvectorStrobe(obj,w)

            w.addBoldText('Vector Data Read/Write with Strobe Synchronization');
            w.addBreak(2);
            vsStr='All the elements of vector data are treated as synchronous to the IP core algorithm logic. Additional strobe registers added for each vector input and output port maintain this synchronization across multiple sequential AXI4 reads/writes. For input ports, the strobe register controls the enables on a set of shadow registers, allowing the IP core logic to see all the updated vector elements simultaneously. For output ports, the strobe register controls the synchronous capturing of vector data to be read.';
            w.addText(vsStr);
            w.addBreak(2);
            vsStr2='To read a vector data port, first write the strobe address with 0x1, then read each desired data element from corresponding address range. To write a vector data port, first write each desired data element, then write 0x1 to the strobe address to complete the transaction.';
            w.addText(vsStr2);
            w.addBreak(2);
            obj.addReportImage(w,'vector_strobe.jpg');
            w.addBreak(2);
        end
        function addSubSectionFreeRunning(obj,w)

            execMode=obj.getDIDriver.get('ExecutionMode');
            frStr1='The ';
            w.addText(frStr1);
            frStr2=sprintf('%s ',execMode);
            w.addBoldText(frStr2);
            frStr3=['mode means there is no explicit synchronization between embedded processor software execution (SW) and the IP core (HW). ',...
            'SW and HW runs independently. The data written from the processor to IP core takes effect immediately, ',...
            'and the data read from the IP core is the latest data available on the IP core output ports. ',...
            ];
            w.addText(frStr3);
            w.addBreak(2);
        end

        function addSubSectionCoprocessing(obj,w)

            execMode=obj.getDIDriver.get('ExecutionMode');
            cpStr1='In ';
            w.addText(cpStr1);
            cpStr2=sprintf('%s ',execMode);
            w.addBoldText(cpStr2);
            cpStr3=['mode, the IP core (HW) is generated with explicit blocking synchronization, so it causes embedded processor software execution (SW) to wait for the HW to finish. ',...
            'For example, as shown in the diagram below, for each SW sample, the processor first sends input data to the IP core. The processor then starts the IP core processing by writing 0x1 to the IPCore_Strobe register. ',...
            'The processor then polls the IPCore_Ready register to check whether IP Core has finished its processing. ',...
            'Once the processor reads a value of 0x1 from the IPCore_Ready register, the processor then reads the data out from the IP core. '];
            w.addText(cpStr3);
            w.addBreak(2);
        end

        function addFileListSection(obj,w)


            chFolder=obj.hIPEmitter.CHeaderFolder;


            sectionCss={obj.cssStyles.Group.section_GroupCss};
            w.addSection('IP Core File List',sectionCss);


            w.addText('The IP core folder is located at:');
            w.addBreak(1);

            pcoreFolderPath=obj.hIPEmitter.hIP.getIPCoreFolder;
            mpdLink=getFolderLink(obj,pcoreFolderPath,pcoreFolderPath);
            w.addObject(mpdLink);
            w.addBreak(1);
            w.addText('Following files are generated under this folder:');
            w.addBreak(2);


            addIPDefinitionFiles(obj,w)


            w.addBoldText('IP core report');
            w.addBreak(1);

            reportFileStr=obj.getReportFileRelativePath;
            docLink=getHtmlLink(obj,reportFileStr,obj.ReportFilePath);
            w.addObject(docLink);
            w.addBreak(2);


            w.addBoldText('IP core HDL source files');
            w.addBreak(1);

            obj.addHDLSrcFileList(w);
            w.addBreak(1);

            if~isempty(obj.getBusProtocal)

                w.addBoldText('IP core C header file');
                w.addBreak(1);

                chFileStr=fullfile(chFolder,obj.hIPEmitter.hCHEmitter.CHeaderFileName);
                chLink=getFileLink(obj,chFileStr,obj.hIPEmitter.hCHEmitter.CHeaderFilePath);
                w.addObject(chLink);
            end
            w.commitSection;
        end

        function addHDLSrcFileList(obj,w)
            hdlFolder=obj.hIPEmitter.getHDLSrcFolder;
            hCodeGen=obj.getDIDriver.hCodeGen;
            srcFileList=obj.hIPEmitter.IPCoreSrcFileList;
            for ii=1:length(srcFileList)
                srcFileStruct=srcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);

                if~strcmpi(extName,hCodeGen.getVHDLExt)&&~strcmpi(extName,hCodeGen.getVerilogExt)
                    continue;
                end
                srcFileName=sprintf('%s%s',fileName,extName);
                hdlFileStr=fullfile(hdlFolder,srcFileName);
                srcPCorePath=fullfile(obj.hIPEmitter.IPCoreHDLPath,srcFileName);
                hdlLink=getFileLink(obj,hdlFileStr,srcPCorePath);
                w.addObject(hdlLink);
                w.addBreak(1);
            end

            if(targetcodegen.alteradspbadriver.getDSPBALibSynthesisScriptsNeededPostMakehdl(hCodeGen.cgInfoBackupCopy))
                libFiles=targetcodegen.alteradspbadriver.getDSPBALibFiles();
                for jj=1:length(libFiles)
                    [~,fName,fExt]=fileparts(libFiles{jj});
                    srcFileName=[fName,fExt];
                    hdlFileStr=fullfile(hdlFolder,srcFileName);
                    srcPCorePath=fullfile(obj.hIPEmitter.IPCoreHDLPath,srcFileName);
                    hdlLink=getFileLink(obj,hdlFileStr,srcPCorePath);
                    w.addObject(hdlLink);
                    w.addBreak(1);
                end








            end

        end

        function addIPDefinitionFiles(obj,w)%#ok<INUSD>

        end

        function addReportImage(obj,w,imageName)

            imageFolder=obj.getDIDriver.hTurnkey.ImageFolder;
            sourcePath=fullfile(imageFolder,imageName);
            targetDocPath=fullfile(obj.getPCoreDocFolder,imageName);
            targetReportPath=fullfile(obj.getPCoreReportFolder,imageName);
            copyfile(sourcePath,targetDocPath,'f');
            copyfile(sourcePath,targetReportPath,'f');

            w.addImage(imageName);
            w.addBreak(2);
        end

        function addReportTable(obj,w,info,header)
            rowNum=length(info);
            colNum=length(header);
            tableCssStyles={obj.cssStyles.Group.reportTable_GroupCss};
            table=w.createTable(rowNum+1,colNum,true,tableCssStyles);
            for ii=1:colNum
                table.createEntry(1,ii);
                table.addText(header{ii});
            end
            for ii=1:rowNum
                if~mod(ii,2)
                    cellCssStyle={obj.cssStyles.Group.tableDistinctRow_GroupCss};
                else
                    cellCssStyle={};
                end

                for jj=1:colNum
                    table.createEntry(ii+1,jj,cellCssStyle);
                    entryContent=info{ii}{jj};
                    if ischar(entryContent)
                        table.addText(entryContent);
                    else
                        table.addObject(entryContent);
                    end
                end
            end
            w.commitTable(table);
        end

        function modelName=getModelName(obj)
            modelName=obj.getDIDriver.hCodeGen.ModelName;
        end

        function link=getFileLink(~,filename,filepath)
            href=sprintf('matlab:edit(''%s'')',filepath);
            link=hdlhtmlreporter.html.Link(href,filename,'',{});
        end

        function link=getFolderLink(~,foldername,folderpath)
            href=sprintf('matlab:uiopen(''%s'')',fullfile(folderpath,'*.*'));
            link=hdlhtmlreporter.html.Link(href,foldername,'',{});
        end

        function link=getHtmlLink(~,filename,filepath)
            href=sprintf('matlab:web(''%s'')',filepath);
            link=hdlhtmlreporter.html.Link(href,filename,'',{});
        end

        function link=getCmdLineLink(~,filename,filepath)
            link=sprintf('<a href="matlab:web(''%s'')">%s</a>',...
            filepath,filename);
        end

        function hDI=getDIDriver(obj)
            hDI=obj.hIPEmitter.hIP.hD;
        end


        function link=generateSystemLinkFromHandle(~,name,h)
            sid=Simulink.ID.getSID(h);
            href=sprintf('matlab:Simulink.ID.hilite(''%s'')',sid);
            cssStyle=hdlhtmlreporter.CSS.ElementCSS('selector','class','className','code2model','elementName','a');
            link=hdlhtmlreporter.html.Link(href,name,'code2model',{cssStyle});
        end


        function[busProtocal,hBusInterface]=getBusProtocal(obj)
            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            hBusInterface=hTurnkey.getDefaultBusInterface;
            if isempty(hBusInterface)||hBusInterface.isEmptyAXI4SlaveInterface
                busProtocal=[];
            else
                busProtocal=hBusInterface.BusProtocol;
            end
        end
    end

end




