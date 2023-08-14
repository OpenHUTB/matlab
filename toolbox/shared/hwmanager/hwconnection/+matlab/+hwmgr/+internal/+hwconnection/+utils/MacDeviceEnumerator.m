classdef(Hidden)MacDeviceEnumerator<matlab.hwmgr.internal.hwconnection.utils.AbstractMacDeviceEnumerator








    properties

    end

    methods(Hidden)
        function dev_list=getUSBDevices(~,varargin)




            if isempty(varargin)
                vendorid='';
                productid='';
            else
                minmaxInputs=3;
                narginchk(minmaxInputs,minmaxInputs);
                vendorid=varargin{1};
                productid=varargin{2};
            end

            [status,dev_list]=matlab.hwmgr.internal.hwconnection.utils.findMacUSBDevices(vendorid,productid);
            if str2double(status)
                dev_list=char.empty;
            end
        end

        function[serialport,bsdname]=getSerialPort(~,varargin)


            hexStr='0x';


            vendorid=[hexStr,varargin{1}];
            productid=[hexStr,varargin{2}];
            if(nargin>4)
                minmaxInputs=5;
                narginchk(minmaxInputs,minmaxInputs);
                serialno=varargin{3};
                isbelowElcapitan=varargin{4};

                [status,serialport,bsdname]=matlab.hwmgr.internal.hwconnection.utils.findMacSerialPort(vendorid,productid,serialno,isbelowElcapitan);
                if str2double(status)
                    serialport=char.empty;
                    bsdname=char.empty;
                end
            else
                minmaxInputs=4;
                narginchk(minmaxInputs,minmaxInputs);
                isbelowElcapitan=varargin{3};
                [status,serialport,bsdname]=matlab.hwmgr.internal.hwconnection.utils.findMacSerialPort(vendorid,productid,'',isbelowElcapitan);
                if str2double(status)
                    serialport=char.empty;
                    bsdname=char.empty;
                end
            end
        end

        function output=getDiskUtilList(~,diskname)


            [status,output]=system(['diskutil list | grep ',diskname]);
            if status
                output=char.empty;
            end
        end

        function mountpoint=getDiskUtilInfo(~,grepmountpoint)


            [status,mountpoint]=system(['diskutil info ',grepmountpoint]);
            if status
                mountpoint=char.empty;
            end
        end

    end

end