function deviceData=getUSBDevicesInLinux(usbobj,varargin)














    deviceData=[];
    supportedParams=varargin{:};
    cStr='';
    hexStr='';
    defaultStr='*';


    obj=matlab.hwmgr.internal.hwconnection.utils.LinuxDeviceEnumerator;

    if isempty(supportedParams)
        dev_list=obj.getUSBDevices();
    else
        supportedParams=matlab.hwmgr.internal.hwconnection.utils.assignHardwareIDs(supportedParams,cStr,hexStr,defaultStr);
        if isempty(supportedParams.productname)
            supportedParams.productname=defaultStr;
        end
        dev_list=obj.getUSBDevices(supportedParams.vendorid,supportedParams.productid,supportedParams.productname);
    end

    if~isempty(dev_list)









        serialFlag=isequal(usbobj.getMethodIndex,matlab.hwmgr.internal.hwconnection.USBDeviceEnumerator.enum_getSerialPorts);
        mountFlag=isequal(usbobj.getMethodIndex,matlab.hwmgr.internal.hwconnection.USBDeviceEnumerator.enum_getMountPoints);

        if(mountFlag||serialFlag)



            deviceData=buildStructure(dev_list,supportedParams);
        else
            deviceData=dev_list;
        end
    end

end

function deviceData=buildStructure(dev_list,supportedParams)

    deviceData=dev_list;
    index=1;

    for i=1:numel(dev_list)


        if~isempty(supportedParams)&&~strcmp(supportedParams.vendorid,'*')...
            &&~strcmpi(supportedParams.vendorid,dev_list(i).VendorID)

            deviceData=clearIndex(deviceData,index);

            continue;
        end

        if~isempty(supportedParams)&&~strcmp(supportedParams.productname,'*')...
            &&isempty(regexpi(dev_list(i).ProductName,supportedParams.productname,'match','once'))

            deviceData=clearIndex(deviceData,index);
            continue;
        end

        index=index+1;
    end

    for i=1:numel(deviceData)





        if~isempty(deviceData(i).MountPoint)
            storage_block=deviceData(i).MountPoint;
            finalMountPoint=findMountPoint(storage_block);
            deviceData(i).MountPoint=strtrim(char(finalMountPoint));
        end
    end
end

function finalMountPoint=findMountPoint(storage_block)





    finalMountPoint=char.empty;
    obj=matlab.hwmgr.internal.hwconnection.utils.LinuxDeviceEnumerator;
    dev_name=strrep(storage_block,'/dev/','');
    parition=obj.getPartitions(dev_name);

    pattern='\s*(?<major>\d+)\s*(?<minor>\d+)\s*(?<blocks>\d+)\s*(?<partition>\w+)';
    partInfo=regexp(parition,pattern,'names');
    temp_part=unique({partInfo.partition});

    for j=1:numel(temp_part)
        noPartition=isequal(temp_part{j},dev_name);


        if~noPartition
            dev_name=cellstr(dev_name);
            part_name=temp_part{j};
            mountpoint=checkDeviceMounted(obj,part_name);
            dev_name=dev_name{1};
        else


            part_name=dev_name;
            mountpoint=checkDeviceMounted(obj,part_name);
        end
        is_notmounted=regexp(mountpoint,'/','once');
        if isempty(is_notmounted)
            finalMountPoint=mountManually(obj,storage_block,dev_name,part_name);
        else
            finalMountPoint=mountpoint;
        end
    end

end

function finalMountPoint=mountManually(obj,storage_block,deviceName,devicePartName)

    finalDevName=strrep(storage_block,deviceName,devicePartName);
    mount=obj.mountDevice(finalDevName);
    isudisks_notavailable=strfind(mount,'Command not found');

    if isudisks_notavailable
        error(message('hwconnection:setup:UDISKSNotAvailable'));
    else

        finalMountPoint=checkDeviceMounted(obj,devicePartName);
    end
end

function mountpoint=checkDeviceMounted(obj,devicename)


    lsblk_output=obj.listBlock(devicename);
    lsblk_partname=regexp(lsblk_output,' ','split');
    lsblk_partname=lsblk_partname(~cellfun(@isempty,lsblk_partname));
    if~isempty(lsblk_partname)
        mountpoint=lsblk_partname{7};
    else
        mountpoint='';
    end
end

function DeviceData=clearIndex(inDeviceData,index)

    DeviceData=inDeviceData;
    if~isempty(DeviceData)
        DeviceData(index)=[];
    end
end