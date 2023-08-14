




classdef IPReportQsys<hdlturnkey.ip.IPReport


    properties


        IPToolName='Altera Qsys';

    end

    methods

        function obj=IPReportQsys(hIPEmitter)


            obj=obj@hdlturnkey.ip.IPReport(hIPEmitter);

        end

    end

    methods(Access=protected)

        function addSubSectionEmbeddedSystemIntegration(obj,w)


            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            hBusInterface=hTurnkey.getDefaultBusInterface;
            busName=hBusInterface.InterfaceID;
            fileStr=[sprintf('This IP Core is generated for the %s environment. ',obj.IPToolName),...
            sprintf('The following steps are an example showing how to integrate the generated IP core into %s environment:',obj.IPToolName)];
            w.addText(fileStr);
            w.addBreak(2);
            fileStr='1. Copy the IP core folder into the "ip" folder in your Altera Qsys project folder. If there is no folder named "ip", create one. This step adds the IP core into the Qsys project user library.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='2. In the Qsys project, find the IP core in the user library and add the IP core to the design.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr=sprintf('3. Connect the %s port of the IP core to the embedded processor''s AXI master port.',busName);
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='4. Connect the clock and reset ports of the IP core to the global clock and reset signals.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='5. Assign a base address for the IP core.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='6. Connect external ports and add FPGA pin assignment constraints.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='7. Generate FPGA bitstream and download the bitstream to target device.';
            w.addText(fileStr);
            w.addBreak(2);


            addSupportPackageLink(obj,w);
        end

        function addIPDefinitionFiles(obj,w)


            w.addBoldText('IP core definition files');
            w.addBreak(1);

            tclFileStr=obj.hIPEmitter.getIPPackageTclFileName;
            tclLink=getFileLink(obj,tclFileStr,obj.hIPEmitter.getIPPackageTclFilePath);
            w.addObject(tclLink);
            w.addBreak(2);
        end

        function addSupportPackageLink(obj,w)

            fileStr=['If you are targeting Intel SoC hardware supported by HDL Coder Support Package for Intel SoC Devices, ',...
            'you can select the board you are using in the Target platform option in the Set Target > Set Target Device and Synthesis Tool task. ',...
            sprintf('You can then use Embedded System Integration tasks in HDL Workflow Advisor to help you integrate the generated IP core into %s environment.',obj.IPToolName)];
            w.addText(fileStr);
        end

    end

end




