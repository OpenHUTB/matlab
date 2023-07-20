classdef(Hidden)LinuxDeviceEnumerator<matlab.hwmgr.internal.hwconnection.utils.AbstractLinuxDeviceEnumerator







    properties

    end
    methods(Hidden)
        function dev_list=getUSBDevices(~,varargin)




            if isempty(varargin)
                vendorid='*';
                productid='*';
                productname='*';
            else
                minmaxInputs=4;
                narginchk(minmaxInputs,minmaxInputs);
                vendorid=varargin{1};
                productid=varargin{2};
                productname=varargin{3};
            end

            [status,dev_list]=matlab.hwmgr.internal.hwconnection.utils.findLinuxUSBDevices(vendorid,productid,productname);

            if str2double(status)
                dev_list=char.empty;
            end
        end

        function paritionInfo=getPartitions(~,dev_name)





            [status,paritionInfo]=system(['cat /proc/partitions | grep ',dev_name]);
            if status
                paritionInfo=char.empty;
            end
        end

        function mount=mountDevice(~,full_devname)





            [status,mount]=system(['udisks --mount ',full_devname]);
            if status
                mount=char.empty;
            end
        end

        function lsblk_output=listBlock(~,dev_name)




            [status,lsblk_output]=system(['lsblk | grep ',dev_name]);
            if status
                lsblk_output=char.empty;
            end
        end
    end
end