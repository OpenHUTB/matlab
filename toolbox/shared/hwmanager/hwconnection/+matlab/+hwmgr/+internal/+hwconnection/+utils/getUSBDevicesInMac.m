function deviceData=getUSBDevicesInMac(usbobj,varargin)















    deviceData=[];
    supportedParams=varargin{:};
    cStr='';
    hexStr='0x';
    defaultStr='';

    obj=matlab.hwmgr.internal.hwconnection.utils.MacDeviceEnumerator;

    if isempty(supportedParams)
        dev_list=obj.getUSBDevices();
    else
        supportedParams=matlab.hwmgr.internal.hwconnection.utils.assignHardwareIDs(supportedParams,cStr,hexStr,defaultStr);
        dev_list=obj.getUSBDevices(supportedParams.vendorid,supportedParams.productid);
    end



    if~isempty(dev_list)










        serialFlag=isequal(usbobj.getMethodIndex,matlab.hwmgr.internal.hwconnection.USBDeviceEnumerator.enum_getSerialPorts);
        mountFlag=isequal(usbobj.getMethodIndex,matlab.hwmgr.internal.hwconnection.USBDeviceEnumerator.enum_getMountPoints);

        if serialFlag||mountFlag


            deviceData=buildStructure(obj,dev_list,supportedParams);
        else

            deviceData=dev_list;
        end
    end

end

function deviceData=buildStructure(obj,dev_list,supportedParams)



    mIndex=1;
    storedPID_Mount=struct('PID',[],'INDEX',[]);

    deviceData=dev_list;

    [~,macVer]=system('sw_vers -productVersion');
    macVerSplit=strsplit(macVer,'.');
    macVerNumber=str2double(strcat(macVerSplit(1),macVerSplit(2)));

    if(macVerNumber>=1011)
        isbelowElcapitan='0';
    else
        isbelowElcapitan='1';
    end



    numDevices=numel(deviceData);
    for i=1:numDevices


        if isempty(supportedParams)||isempty(supportedParams.productname)||...
            ~isempty(regexpi(deviceData(i).ProductName,supportedParams.productname,'once'))

            if(~isempty(deviceData(i).SerialNumber))
                [serialport,bsdname]=obj.getSerialPort(deviceData(i).VendorID,deviceData(i).ProductID,deviceData(i).SerialNumber,isbelowElcapitan);
            else
                [serialport,bsdname]=obj.getSerialPort(deviceData(i).VendorID,deviceData(i).ProductID,isbelowElcapitan);
            end

            if~isempty(serialport)
                if(numel(serialport)>1)


                    if(any(ismember({serialport.SerialPort},{deviceData.SerialPort})))





                    else
                        deviceData(i).SerialPort=char(serialport(1).SerialPort);
                        for k=2:numel(serialport)

                            deviceData(end+1)=deviceData(i);%#ok<AGROW>
                            deviceData(end).SerialPort=char(serialport(k).SerialPort);


                        end
                    end
                else

                    deviceData(i).SerialPort=char(serialport.SerialPort);
                end
            end

            if~isempty(bsdname)
                for j=1:numel(bsdname)
                    [MountPoint,mIndex,storedPID_Mount]=findMountPoint(bsdname,obj,mIndex,storedPID_Mount,deviceData(i).ProductID);
                    deviceData(i).MountPoint=char(MountPoint);
                    if~isempty(deviceData(i).MountPoint)
                        break;
                    end
                end
            end
        end
    end

end

function[MountPoint,mIndex,storedPID_Mount]=findMountPoint(bsdstruct,obj,mIndex,storedPID_Mount,PID)



    bsdname_index=1;
    bsdname_cell={};

    for i=1:numel(bsdstruct)
        bsdname_cell{bsdname_index}=bsdstruct(i).MountPoint;%#ok<AGROW>
        bsdname_index=bsdname_index+1;
    end

    bsdname_index=bsdname_index-1;

    MountPoint=char.empty;

    if(bsdname_index>0)
        if bsdname_index>1
            flag=0;
            for id=1:numel(storedPID_Mount)
                if strncmp(storedPID_Mount(id).PID,PID,4)
                    flag=1;
                    break;
                end
            end
            if flag

                storedPID_Mount(id).INDEX=storedPID_Mount(id).INDEX+1;
                if~(storedPID_Mount(id).INDEX>numel(bsdname_cell))
                    bsd_name=strtrim(bsdname_cell{storedPID_Mount(id).INDEX});
                else
                    bsd_name=strtrim(bsdname_cell{end});
                end
            else
                storedPID_Mount(mIndex).PID=PID;
                storedPID_Mount(mIndex).INDEX=1;
                if~(storedPID_Mount(mIndex).INDEX>numel(bsdname_cell))
                    bsd_name=strtrim(bsdname_cell{storedPID_Mount(mIndex).INDEX});
                else
                    bsd_name=strtrim(bsdname_cell{end});
                end
                mIndex=mIndex+1;
            end
        else
            bsd_name=strtrim(bsdname_cell{bsdname_index});
        end
        output=obj.getDiskUtilList(bsd_name);
        out_tmp=regexp(output,'  ','split');
        out_tmp=out_tmp(~cellfun(@isempty,out_tmp));
        out_tmp=out_tmp(2:end);
        bsd_name=cellstr(bsd_name);



        for j=1:4:numel(out_tmp)
            temp_part{j}=out_tmp{j+3};%#ok<AGROW>
            temp_part{j}=strtrim(temp_part{j});%#ok<AGROW>
            noPartition=isequal(temp_part(j),bsd_name);

            if~noPartition
                temp_part=temp_part(~cellfun(@isempty,temp_part));
                bsd_name=temp_part;
            end
        end

        for count=1:numel(bsd_name)
            grepmountpoint=[bsd_name{count},'| grep Point'];
            tmp_mountpoint=obj.getDiskUtilInfo(grepmountpoint);
            if~isempty(tmp_mountpoint)
                get_mount=regexp(tmp_mountpoint,': ','split');
                get_mount=get_mount(~cellfun(@isempty,get_mount));
                if numel(get_mount)>1
                    MountPoint=strtrim(get_mount(2));
                end
                break;
            end
        end
    end
end
