classdef TargetEthernet<dnnfpga.hardware.Target




    properties(Constant)

        Interface=dlhdl.TargetInterface.Ethernet;
    end

    properties(Access=protected)

        DefaultProgrammingMethod=hdlcoder.ProgrammingMethod.Download;
    end

    properties(Dependent)

IPAddress
Username
    end

    properties(Access=protected)

hLinuxShell
    end

    methods(Access=public)
        function obj=TargetEthernet(vendor,varargin)

            obj=obj@dnnfpga.hardware.Target(vendor);


            [varargin{:}]=convertStringsToChars(varargin{:});


            switch lower(obj.Vendor)
            case 'xilinx'
                defaultIPAddr=xilinxsoc.getSavedDeviceAddress;
                defaultUsername=xilinxsoc.getSavedUsername;
                defaultPassword=xilinxsoc.getSavedPassword;
                defaultSSHPort=xilinxsoc.getSavedSSHPort;
            case 'intel'
                defaultIPAddr=intelsoc.getSavedDeviceAddress;
                defaultUsername=intelsoc.getSavedUsername;
                defaultPassword=intelsoc.getSavedPassword;
                defaultSSHPort=intelsoc.getSavedSSHPort;
            otherwise
                error(message('dnnfpga:workflow:InvalidVendor',vendor,strjoin({'Xilinx','Intel'},', ')));
            end


            p=inputParser;
            p.addParameter('IPAddress',defaultIPAddr,@obj.validateIPAddress);
            p.addParameter('Username',defaultUsername,@(s)ischar(s));
            p.addParameter('Password',defaultPassword,@(s)ischar(s));
            p.addParameter('Port',defaultSSHPort,@mustBeNumeric);

            parse(p,varargin{:});


            ipaddress=p.Results.IPAddress;
            username=p.Results.Username;
            password=p.Results.Password;
            port=p.Results.Port;


            switch lower(obj.Vendor)
            case 'xilinx'
                obj.hLinuxShell=xilinxsoc(ipaddress,username,password,port,Connect=false);
            case 'intel'
                obj.hLinuxShell=intelsoc(ipaddress,username,password,port,Connect=false);
            otherwise
                error(message('dnnfpga:workflow:InvalidVendor',vendor,strjoin({'Xilinx','Intel'},', ')));
            end
            obj.hFPGA=fpga(obj.hLinuxShell);
        end

        function validateConnection(obj)
            try

                dnnfpga.disp(message('dnnfpga:workflow:ValidateSSHConnection'));
                obj.validateSSHConnection(20);


                validateConnection@dnnfpga.hardware.Target(obj);
            catch ME
                ME_new=obj.getTroubleshootingException(ME);
                throw(ME_new);
            end
        end
    end


    methods
        function ipaddress=get.IPAddress(obj)
            ipaddress=obj.hLinuxShell.DeviceAddress;
        end

        function username=get.Username(obj)
            username=obj.hLinuxShell.Username;
        end
    end


    methods(Access=public,Hidden=true)

        function validateSSHConnection(obj,varargin)
            try
                obj.hLinuxShell.validateConnection(varargin{:});

            catch ME

                defaultUsername='root';
                defaultPassword='root';
                if strcmp(obj.Vendor,'Intel')
                    defaultPassword='cyclonevsoc';
                end
                exampleStr=sprintf('dlhdl.Target("%s", "Interface", "Ethernet", "Username", "%s", "Password", "%s")',obj.Vendor,defaultUsername,defaultPassword);
                ME1=MException(message('dnnfpga:workflow:SSHConnectionFailure',ME.message,defaultUsername,defaultPassword,exampleStr));
                throw(ME1);
            end
        end

        function output=system(obj,varargin)
            output=obj.hLinuxShell.system(varargin{:});
        end

        function putFile(obj,varargin)
            obj.hLinuxShell.putFile(varargin{:});
        end

        function getFile(obj,varargin)
            obj.hLinuxShell.getFile(varargin{:});
        end

        function d=dir(obj,varargin)
            d=obj.hLinuxShell.dir(varargin{:});
        end

        function deleteFile(obj,varargin)
            obj.hLinuxShell.deleteFile(varargin{:});
        end
    end

    methods(Hidden)
        function programBitstreamDownload(obj,hBitstream)
            bitstreamPath=hBitstream.getAbsolutePath();
            deviceTreePath=hBitstream.getDeviceTreeName();
            systemInitPath=hBitstream.getSystemInitName();
            rdName=hBitstream.getReferenceDesignName();
            useSplitBit=hBitstream.getSplitBitstreamSetting;


            try
                obj.validateSSHConnection(30);
            catch ME
                ME_new=obj.getTroubleshootingException(ME);
                throw(ME_new);
            end


            switch obj.Vendor
            case 'Xilinx'
                obj.hLinuxShell.programFPGA(bitstreamPath,deviceTreePath,SystemInitPath=systemInitPath,ReferenceDesignName=rdName);
            case 'Intel'
                obj.programIntelBitstreamDownload(bitstreamPath,deviceTreePath,systemInitPath,rdName,useSplitBit);
            end
        end

        function programIntelBitstreamDownload(obj,bitstreamPath,deviceTreePath,systemInitPath,rdName,useSplitBit)



            numTrys=3;
            for ii=1:numTrys
                try
                    obj.hLinuxShell.programFPGA(bitstreamPath,deviceTreePath,SystemInitPath=systemInitPath,ReferenceDesignName=rdName,UseSplitBitstream=useSplitBit);


                    break;
                catch ME


                    copyFileErrorIDs={'socio:utils:SCPWriteFileError','socio:utils:SCPSessionError','shared_linuxservices:utils:SCPWriteFileError','shared_linuxservices:utils:SCPSessionError'};
                    hasCopyFileError=ismember(ME.identifier,copyFileErrorIDs)||any(cellfun(@(ex)ismember(ex.identifier,copyFileErrorIDs),ME.cause));



                    if hasCopyFileError
                        if ii==1

                            dnnfpga.disp(sprintf('%s. Attempting another time.',ME.message));
                        elseif ii<numTrys

                            dnnfpga.disp(sprintf('%s. Attempting another time after rebooting.',ME.message));
                            obj.rebootLinux;
                        else

                            rethrow(ME);
                        end
                    else

                        rethrow(ME);
                    end
                end
            end
        end

        function rebootLinux(obj)

            obj.validateSSHConnection(10);


            obj.hLinuxShell.reboot;
        end
    end

    methods(Access=protected)

        function configureFPGAObjectForBitstream(obj,hBitstream)



            [ipBaseAddr,ipAddrRange]=hBitstream.getDLProcessorAddressSpace;
            [ipDevNameWrite,ipDevNameRead]=hBitstream.getDLProcessorDeviceNames;
            obj.hFPGA.addAXI4SlaveInterface(...
            "InterfaceID","DLProcessor",...
            "BaseAddress",ipBaseAddr,...
            "AddressRange",ipAddrRange,...
            "WriteDeviceName",ipDevNameWrite,...
            "ReadDeviceName",ipDevNameRead);



            [memBaseAddr,memAddrRange]=hBitstream.getDLMemoryAddressSpace;
            [memDevNameWrite,memDevNameRead]=hBitstream.getDLMemoryDeviceNames;

            writeFrameLength=100e3;
            readFrameLength=1e6;
            timeout=5;

            hWriteDriver=fpgaio.driver.DatamoverWrite(...
            'IPAddress',obj.IPAddress,...
            'DeviceName',memDevNameWrite,...
            'SamplesPerFrame',writeFrameLength,...
            'Timeout',timeout);

            hReadDriver=fpgaio.driver.DatamoverRead(hWriteDriver,...
            'IPAddress',obj.IPAddress,...
            'DeviceName',memDevNameRead,...
            'SamplesPerFrame',readFrameLength,...
            'Timeout',timeout);

            obj.addMemoryInterface("Memory",memBaseAddr,memAddrRange,hWriteDriver,hReadDriver,"Full");
        end
    end


    methods(Static,Hidden)
        function validateIPAddress(ipAddr)
            matlabshared.internal.Utilities.checkValidIp(ipAddr,'IP Address');
        end
    end

end
