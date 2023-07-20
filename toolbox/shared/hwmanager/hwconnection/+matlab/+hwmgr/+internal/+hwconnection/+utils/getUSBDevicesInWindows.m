function deviceData=getUSBDevicesInWindows(~,varargin)










    inputParams=varargin{:};
    deviceData=[];

    obj=matlab.hwmgr.internal.hwconnection.utils.WindowsDeviceEnumerator();


    if isempty(inputParams)
        usbDevices=obj.getUSBDevices;
    else
        queryString=getQueryString(inputParams);
        if~isempty(queryString)
            usbDevices=obj.getUSBDevices(queryString);
        else
            usbDevices=[];
        end
    end

    if~isempty(usbDevices)&&(usbDevices.Length>0)
        deviceData=buildStructure(usbDevices);
    end
end

function queryString=getQueryString(supportedParams)

    queryString='';
    if~isempty(supportedParams.productname)
        queryString=['Caption like ','''%',supportedParams.productname,'%'''];
    end
    if(~isempty(supportedParams.vendorid)||~isempty(supportedParams.productid))
        if~isempty(queryString)
            combStr='AND ';
        else
            combStr='';
        end
        if~isempty(supportedParams.vendorid)&&~isempty(supportedParams.productid)
            queryString=[queryString,combStr,'DeviceID like ','''%',supportedParams.vendorid,'%',supportedParams.productid,'%'''];
        elseif~isempty(supportedParams.vendorid)
            queryString=[queryString,combStr,'DeviceID like ','''%',supportedParams.vendorid,'%'''];
        else
            queryString=[queryString,combStr,'DeviceID like ','''%',supportedParams.productid,'%'''];
        end
    end
end

function deviceData=buildStructure(usbDevices)


    buildFullStruct=1;
    deviceData=matlab.hwmgr.internal.hwconnection.utils.structureInit(buildFullStruct);

    for idx=1:usbDevices.Length
        deviceData(idx).ProductName=char(usbDevices(idx).Name);
        deviceData(idx).VendorID=regexp(char(usbDevices(idx).DeviceID),'(VEN|VID)\w+','match','once');
        deviceData(idx).VendorID=regexprep(deviceData(idx).VendorID,'(VEN_|VID_)','');
        deviceData(idx).ProductID=regexp(char(usbDevices(idx).DeviceID),'(DEV|PID)\w+','match','once');
        deviceData(idx).ProductID=regexprep(deviceData(idx).ProductID,'(DEV_|PID_)','');
        deviceData(idx).SerialNumber=char(usbDevices(idx).SerialNumber);
        deviceData(idx).Manufacturer=char(usbDevices(idx).Manufacturer);
        deviceData(idx).SerialPort=regexp(char(usbDevices(idx).Name),'COM\d+','match','once');
        deviceData(idx).MountPoint=char(usbDevices(idx).Drive);
    end
end
