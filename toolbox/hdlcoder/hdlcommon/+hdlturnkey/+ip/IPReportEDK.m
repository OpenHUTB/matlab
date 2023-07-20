


classdef IPReportEDK<hdlturnkey.ip.IPReport


    properties


        IPToolName='Xilinx EDK';

    end

    methods

        function obj=IPReportEDK(hIPEmitter)


            obj=obj@hdlturnkey.ip.IPReport(hIPEmitter);

        end

    end

    methods(Access=protected)

        function addSubSectionEmbeddedSystemIntegration(obj,w)


            hTurnkey=obj.hIPEmitter.getTurnkeyObject;
            hBusInterface=hTurnkey.getDefaultBusInterface;
            busName=hBusInterface.BusNameMPD;
            fileStr=[sprintf('This IP Core is generated for the %s environment. ',obj.IPToolName),...
            sprintf('The following steps are an example showing how to integrate the generated IP core into %s environment:',obj.IPToolName)];
            w.addText(fileStr);
            w.addBreak(2);
            fileStr='1. Copy the IP core folder into the "pcores" folder in your Xilinx Platform Studio (XPS) project. This step adds the IP core into the XPS project user library.';
            w.addText(fileStr);
            w.addBreak(1);
            fileStr='2. In the XPS project, find the IP core in the user library and add the IP core to the design.';
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

            dataFolder=obj.hIPEmitter.DataFolder;

            w.addBoldText('IP core definition files');
            w.addBreak(1);

            mpdFileStr=fullfile(dataFolder,obj.hIPEmitter.hMPDEmitter.MPDFileName);
            mpdLink=getFileLink(obj,mpdFileStr,obj.hIPEmitter.hMPDEmitter.MPDFilePath);
            w.addObject(mpdLink);
            w.addBreak(1);
            paoFileStr=fullfile(dataFolder,obj.hIPEmitter.hPAOEmitter.PAOFileName);
            paoLink=getFileLink(obj,paoFileStr,obj.hIPEmitter.hPAOEmitter.PAOFilePath);
            w.addObject(paoLink);
            w.addBreak(2);
        end

    end

end



