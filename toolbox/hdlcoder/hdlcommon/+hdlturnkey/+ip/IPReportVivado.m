




classdef IPReportVivado<hdlturnkey.ip.IPReport


    properties


        IPToolName='Xilinx Vivado';

    end

    methods

        function obj=IPReportVivado(hIPEmitter)


            obj=obj@hdlturnkey.ip.IPReport(hIPEmitter);

        end

    end

    methods(Access=protected)


        function info=addSummaryExtraIPCoreItem(obj,info)

            info{end+1}={'IP core zip file name',obj.hIPEmitter.IPPackageZipFileName};
        end


        function addSubSectionEmbeddedSystemIntegration(obj,w)


            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            hBusInterface=hTurnkey.getDefaultBusInterface;
            busName=hBusInterface.InterfaceID;
            fileStr=[sprintf('This IP Core is generated for the %s environment. ',obj.IPToolName),...
            sprintf('The following steps are an example showing how to integrate the generated IP core into %s environment:',obj.IPToolName)];
            w.addText(fileStr);
            w.addBreak(2);
            fileStr=['1. The generated IP core is a zip package file under the IP core folder. ',...
            'Please check the Summary section of this report for the IP zip file name and folder.'];
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=['2. In the Vivado project, go to Project Settings -> IP -> Repository Manager, ',...
            'add the folder containing the IP zip file as IP Repository.'];
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=['3. In Repository Manger, click the "Add IP" button to add IP zip file to the IP repository. ',...
            'This step adds the generated IP into the Vivado IP Catalog.'];
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=['4. In the Vivado project, find the generated IP core in the IP Catalog under category "HDL Coder Generated IP". ',...
            'In you have a Vivado block design open, you can add the generated IP into your block design.'];
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=sprintf('5. Connect the %s port of the IP core to the embedded processor''s AXI master port.',busName);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='6. Connect the clock and reset ports of the IP core to the global clock and reset signals.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='7. Assign an Offset Address for the IP core in the Address Editor.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='8. Connect external ports and add FPGA pin assignment constraints to constraint file.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='9. Generate FPGA bitstream and download the bitstream to target device.';
            w.addText(fileStr);
            w.addBreak(2);


            addSupportPackageLink(obj,w);
        end

        function addIPDefinitionFiles(obj,w)

            w.addBoldText('IP core zip file');
            w.addBreak(1);

            zipFileStr=obj.hIPEmitter.IPPackageZipFileName;
            pcoreFolderPath=obj.hIPEmitter.hIP.getIPCoreFolder;
            folderLink=getFolderLink(obj,zipFileStr,pcoreFolderPath);
            w.addObject(folderLink);
            w.addBreak(2);
        end

        function addHDLSrcFileList(obj,w)
            hdlFolder=obj.hIPEmitter.getHDLSrcFolder;
            srcFileList=obj.hIPEmitter.IPCoreHDLFileList;
            for ii=1:length(srcFileList)
                srcFileStruct=srcFileList{ii};
                srcFile=srcFileStruct.ShortFilePath;
                hdlFileStr=fullfile(hdlFolder,srcFile);
                srcPCorePath=fullfile(obj.hIPEmitter.IPCoreHDLPath,srcFile);
                hdlLink=getFileLink(obj,hdlFileStr,srcPCorePath);
                w.addObject(hdlLink);
                w.addBreak(1);
            end
        end

    end

end




