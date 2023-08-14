




classdef IPReportLibero<hdlturnkey.ip.IPReport


    properties


        IPToolName='Microchip Libero SoC';

    end

    methods

        function obj=IPReportLibero(hIPEmitter)


            obj=obj@hdlturnkey.ip.IPReport(hIPEmitter);

        end

    end

    methods(Access=protected)

        function addSubSectionEmbeddedSystemIntegration(obj,w)


            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            hBusInterface=hTurnkey.getDefaultBusInterface;
            busName=hBusInterface.InterfaceID;
            tclFileFullPath=obj.hIPEmitter.getIPPackageTclFilePath;
            [tclFolder,tclFileName,fileExt]=fileparts(tclFileFullPath);
            tclFileFullName=[tclFileName,fileExt];
            fileStr=[sprintf('This IP Core is generated for the %s environment. ',obj.IPToolName),...
            sprintf('The following steps shows how to integrate the generated IP core into %s environment:',obj.IPToolName)];
            w.addText(fileStr);
            w.addBreak(2);
            fileStr=sprintf('1. In order to instantiate generated IP Core in %s SmartDesign, you have to run the tcl file "%s" which is generated with ipcore in %s folder.',obj.IPToolName,tclFileFullName,[tclFolder,'\']);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=sprintf('2. To run the "%s", open the %s Tool. From the Project Pane, select the Execute Script option.',tclFileFullName,obj.IPToolName);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=sprintf('3. In the Execute Script dialog box, select the %s from %s  path in front of "Script file" and click "Run".',tclFileFullName,[tclFolder,'\']);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=sprintf('4. Connect the %s port of the IP core to the MSS''s AXI port as per Master-Slave communication.',busName);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='5. Connect the clock and reset ports of the IP core to the global clock and reset signals.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='6. Connect external ports and add FPGA pin assignment constraints.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='7. Generate FPGA bitstream and download the bitstream to target device.';
            w.addText(fileStr);
            w.addBreak(2);
        end

        function addIPDefinitionFiles(obj,w)


            w.addBoldText('IP core definition files');
            w.addBreak(1);

            tclFileStr=obj.hIPEmitter.getIPPackageTclFileName;
            tclLink=getFileLink(obj,tclFileStr,obj.hIPEmitter.getIPPackageTclFilePath);
            w.addObject(tclLink);
            w.addBreak(2);
        end

    end
end
