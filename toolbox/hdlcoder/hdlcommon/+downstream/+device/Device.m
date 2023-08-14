


classdef Device<hgsetget


    properties

        hDeviceData='';


        PluginPath='';


        hToolDriver=0;
    end

    properties(Access=protected,Hidden=true)
        DeviceXMLFileName='';
    end


    methods

        function obj=Device(hToolDriver)

            obj.hToolDriver=hToolDriver;

            obj.DeviceXMLFileName='device_list.xml';

        end

        function loadDeviceData(obj,toolName)



            if strcmpi(toolName,'Xilinx ISE')
                obj.hDeviceData=downstream.device.XilinxDeviceData(obj);
            elseif strcmpi(toolName,'Altera QUARTUS II')
                obj.hDeviceData=downstream.device.AlteraDeviceData(obj);
            elseif strcmpi(toolName,'Xilinx Vivado')
                obj.hDeviceData=downstream.device.XilinxVivadoDeviceData(obj);
            elseif strcmpi(toolName,'Microchip Libero SoC')
                obj.hDeviceData=downstream.device.MicrosemiLiberoSoCDeviceData(obj);
            elseif strcmpi(toolName,'Intel Quartus Pro')
                obj.hDeviceData=downstream.device.IntelQuartusProDeviceData(obj);
            else

                obj.hDeviceData=downstream.device.DeviceData(obj);
            end


            if obj.existDeviceDataXML
                obj.hDeviceData.loadXML(fullfile(obj.PluginPath,obj.DeviceXMLFileName));
                return;
            end


            obj.retrieveDeviceData;
        end

        function retrieveDeviceData(obj)



            deviceData=obj.hDeviceData.getDeviceData;


            obj.hDeviceData.setDeviceData(deviceData);


            obj.hDeviceData.saveXML(obj.hToolDriver.hTool.ToolName,fullfile(obj.PluginPath,obj.DeviceXMLFileName));
        end

        function isExist=existDeviceDataXML(obj)
            if exist(fullfile(obj.PluginPath,obj.DeviceXMLFileName),'file')
                isExist=true;
            else
                isExist=false;
            end
        end

    end


    methods(Access=public)

        function familyList=listFamily(obj)

            familyList=obj.hDeviceData.listFamily;
        end

        function deviceList=listDevice(obj,familyStr)

            deviceList=obj.hDeviceData.listDevice(familyStr);
        end

        function packageList=listPackage(obj,familyStr,deviceStr)

            packageList=obj.hDeviceData.listPackage(familyStr,deviceStr);
        end

        function speedList=listSpeed(obj,familyStr,deviceStr)

            speedList=obj.hDeviceData.listSpeed(familyStr,deviceStr);
        end
    end

end