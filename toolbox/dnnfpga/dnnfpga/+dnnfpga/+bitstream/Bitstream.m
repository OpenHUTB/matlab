classdef Bitstream<handle




    properties


        Name='';


        Path='';

    end

    properties(Hidden=true)


        Hidden=false;

    end

    properties(Access=protected,Hidden=true)



        AbsolutePath='';

    end

    properties(Access=protected)

        BitstreamBuildInfo=[];


        Checksum='';
    end

    methods

        function obj=Bitstream(varargin)

            p=inputParser;
            addParameter(p,'Name','',@(x)(ischar(x)||isstring(x))&&~isempty(x));
            addParameter(p,'Path','',@(x)(ischar(x)||isstring(x))&&~isempty(x));








            addParameter(p,'Hidden',false,@(x)(islogical(x)));




            addParameter(p,'AbsolutePath','',@(x)(ischar(x)||isstring(x)));

            parse(p,varargin{:});

            obj.Name=p.Results.Name;
            obj.Path=p.Results.Path;




            obj.Hidden=p.Results.Hidden;


            if~isempty(p.Results.AbsolutePath)
                obj.setAbsolutePath(p.Results.AbsolutePath);
            end
        end

    end


    methods(Hidden=true)


        function absPath=getAbsolutePath(obj)
            absPath=obj.AbsolutePath;
        end


        function setAbsolutePath(obj,absPath)
            obj.AbsolutePath=absPath;
        end
    end


    methods(Hidden=true)

        function BuildInfo=getBitstreamBuildInfo(obj)












            BuildInfo=obj.BitstreamBuildInfo;
        end

        function loadBitstreamBuildInfo(obj)

            [filePath,fileName,~]=fileparts(obj.AbsolutePath);
            matFile=fullfile(filePath,[fileName,'.mat']);
            try
                matFileStruct=load(matFile);
                BuildInfo=matFileStruct.BitstreamBuildInfo;



                obj.validateBitstreamBuildInfo(BuildInfo);
                obj.BitstreamBuildInfo=BuildInfo;
            catch ME
                msg=MException(message('dnnfpga:workflow:MATFileLoadFailure',matFile));
                msg=msg.addCause(ME);

                throw(msg);
            end

            dnnfpga.validateDLSupportPackage(obj.BitstreamBuildInfo.VendorName,'bitstream');
        end

        function validateBitstreamBuildInfo(~,BuildInfo)
            if~isa(BuildInfo,'dnnfpga.bitstream.BitstreamBuildInfo')
                error(message('dnnfpga:workflow:InvalidBitstreamBuildInfo'));
            end
        end

        function validateProgrammingMethod(obj,programMethod)
            supportedMethods=obj.getSupportedProgrammingMethods();
            if isempty(supportedMethods)
                return;
            end

            if~ismember(programMethod,supportedMethods)
                availMethodsStr=sprintf('%s; ',supportedMethods);
                availMethodsStr(end-1:end)='';
                error(message('dnnfpga:workflow:InvalidProgrammingMethod',char(programMethod),availMethodsStr));
            end
        end

        function validateHWInterface(obj,hwInterface)
            availInterfaces=obj.getAvailableHWInterfaces();
            if~ismember(hwInterface,availInterfaces)
                if isempty(availInterfaces)
                    error(message('dnnfpga:workflow:InvalidHardwareInterfaceEmpty',char(hwInterface)));
                else
                    availInterfacesStr=sprintf('%s; ',availInterfaces);
                    availInterfacesStr(end-1:end)='';
                    error(message('dnnfpga:workflow:InvalidHardwareInterface',char(hwInterface),availInterfacesStr));
                end
            end
        end
    end


    methods(Hidden=true)

        function hPC=getProcessorConfig(obj)
            hPC=obj.BitstreamBuildInfo.ProcessorConfig;
        end

        function hProcessor=getProcessor(obj)
            hProcessor=obj.BitstreamBuildInfo.Processor;
        end


        function vendorName=getVendorName(obj)
            vendorName=obj.BitstreamBuildInfo.VendorName;
        end

        function boardName=getBoardName(obj)
            boardName=obj.BitstreamBuildInfo.BoardName;
        end

        function refDesignName=getReferenceDesignName(obj)
            refDesignName=obj.BitstreamBuildInfo.ReferenceDesignName;
        end

        function freq=getFrequency(obj)
            freq=obj.BitstreamBuildInfo.Frequency;
        end


        function resources=getResources(obj)
            resources=obj.BitstreamBuildInfo.Resources;
        end


        function supportedTool=getSupportedTool(obj)
            supportedTool=obj.BitstreamBuildInfo.SupportedTool;
        end


        function supportedMethods=getSupportedProgrammingMethods(obj)
            supportedMethods=obj.BitstreamBuildInfo.SupportedProgrammingMethods;
        end

        function programFcn=getCustomProgrammingFcn(obj)
            programFcn=obj.BitstreamBuildInfo.CallbackCustomProgrammingMethod;
        end

        function deviceTreeName=getDeviceTreeName(obj)
            deviceTreeName=obj.BitstreamBuildInfo.DeviceTreeName;
        end

        function systemInitName=getSystemInitName(obj)
            systemInitName=obj.BitstreamBuildInfo.SystemInitFolderName;
        end

        function useSplitBitstream=getSplitBitstreamSetting(obj)
            useSplitBitstream=obj.BitstreamBuildInfo.GenerateSplitBitstream;
        end


        function[baseAddr,addrRange]=getDLProcessorAddressSpace(obj)
            baseAddr=obj.BitstreamBuildInfo.DLProcessorBaseAddr;
            addrRange=obj.BitstreamBuildInfo.DLProcessorAddrRange;
        end

        function[baseAddr,addrRange]=getDLMemoryAddressSpace(obj)
            baseAddr=obj.BitstreamBuildInfo.DLMemoryBaseAddr;
            addrRange=obj.BitstreamBuildInfo.DLMemoryAddrRange;
        end


        function hwInterfaces=getAvailableHWInterfaces(obj)
            hwInterfaces=dlhdl.TargetInterface.empty;
            if obj.BitstreamBuildInfo.hasJTAGInterface
                hwInterfaces(end+1)=dlhdl.TargetInterface.JTAG;
            end
            if obj.BitstreamBuildInfo.hasPCIeInterface
                hwInterfaces(end+1)=dlhdl.TargetInterface.PCIe;
            end




            if obj.BitstreamBuildInfo.hasEthernetInterface
                hwInterfaces(end+1)=dlhdl.TargetInterface.Ethernet;
            end

            hwInterfaces(end+1)=dlhdl.TargetInterface.File;
        end

        function jtagChainPos=getJTAGChainPosition(obj)
            jtagChainPos=obj.BitstreamBuildInfo.JTAGChainPosition;
        end

        function irLenBefore=getIRLengthBefore(obj)
            irLenBefore=obj.BitstreamBuildInfo.IRLengthBefore;
        end

        function irLenAfter=getIRLengthAfter(obj)
            irLenAfter=obj.BitstreamBuildInfo.IRLengthAfter;
        end


        function[devNameTx,devNameRx]=getDLProcessorDeviceNames(obj)
            devNameTx=obj.BitstreamBuildInfo.DLProcessorDevNameTx;
            devNameRx=obj.BitstreamBuildInfo.DLProcessorDevNameRx;
        end

        function[devNameTx,devNameRx]=getDLMemoryDeviceNames(obj)
            devNameTx=obj.BitstreamBuildInfo.DLMemoryDevNameTx;
            devNameRx=obj.BitstreamBuildInfo.DLMemoryDevNameRx;
        end


        function matlabVersion=getMATLABVersion(obj)
            matlabVersion=obj.BitstreamBuildInfo.MATLABVersion;
        end
        function processorVersion=getProcessorVersion(obj)
            processorVersion=obj.BitstreamBuildInfo.ProcessorVersion;
        end

    end


    methods(Hidden=true)
        function cksm=getChecksum(obj)
            if isempty(obj.Checksum)
                obj.generateChecksum;
            end
            cksm=obj.Checksum;
        end

        function generateChecksum(obj)
            strInfo=obj.combineCharFields();
            strMD5=rptgen.hash(strInfo);
            bsfMD5=dnnfpga.tool.getFileChecksum(obj.AbsolutePath);
            cksm=upper([strMD5,bsfMD5]);
            obj.Checksum=cksm;
        end
    end

    methods(Access=protected)
        function strInfo=combineCharFields(obj)
            strInfo=sprintf('boardName:\n%s\nprocessor:\n%s\nMATLABVersion:\n%s\nreferenceDesignName:\n%s\nfrequency:\n%d\n',...
            obj.BitstreamBuildInfo.BoardName,...
            obj.BitstreamBuildInfo.Processor.serializeToMCode(),...
            obj.BitstreamBuildInfo.MATLABVersion,...
            obj.BitstreamBuildInfo.ReferenceDesignName,...
            obj.BitstreamBuildInfo.Frequency);
        end
    end

end


