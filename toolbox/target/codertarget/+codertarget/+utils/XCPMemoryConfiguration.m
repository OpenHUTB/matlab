classdef XCPMemoryConfiguration<handle








    properties(Access=private)
ModelName
ConfigSet
BuildDir
BuildInfo
ProtocolConfig
    end

    properties(Access=private)






        sizeOfDAQStruct=32
        sizeOfODTStruct=48
        sizeOfODTEntryStruct=8





        sizeOfAdditionalFields=33
    end

    properties(Access=private)
TargetConfiguration
        IsLoggingBufferSizeSetAutomatically=true
        LoggingBufferSize=1000
        NumOfLoggingBuffersPerSampleRate=3
        NumOfProfilingBuffers=10
        IsPackedMode=false
        MaxContiguousSamples=1
    end

    methods(Access=public)

        function obj=XCPMemoryConfiguration(modelName,buildDir,buildInfo)
            obj.ModelName=modelName;
            obj.BuildDir=buildDir;
            obj.BuildInfo=buildInfo;
            obj.ConfigSet=getActiveConfigSet(modelName);

            targetInfo=codertarget.attributes.getTargetHardwareAttributes(obj.ConfigSet);
            extModeInfo=targetInfo.ExternalModeInfo;
            commInterface=codertarget.data.getParameterValue(obj.ConfigSet,'ExtMode.Configuration');

            for i=1:numel(extModeInfo)
                if isequal(extModeInfo(i).Transport.IOInterfaceName,commInterface)
                    obj.ProtocolConfig=extModeInfo(i).ProtocolConfiguration;
                    break;
                end
            end
        end
    end

    methods(Hidden,Access=public)

        function generate(obj)

            if isempty(obj.ProtocolConfig)||~isa(obj.ProtocolConfig,'codertarget.attributes.XCPProtocolConfiguration')
                return
            end


            numBitsPerChar=get_param(obj.ModelName,'TargetBitPerChar');
            if obj.ProtocolConfig.IsByteAddressGranularityEmulation||numBitsPerChar==8
                addressGranularity=1;
            else
                addressGranularity=numBitsPerChar/8;
            end

            cs=getActiveConfigSet(obj.ModelName);
            transportIdx=get_param(cs,'ExtModeTransport');
            transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,transportIdx);


            obj.TargetConfiguration=coder.internal.xcp.XCPTargetConfiguration(...
            transport,addressGranularity);



            xcpDAQProperties=properties(obj.TargetConfiguration);
            for i=1:numel(xcpDAQProperties)
                if isprop(obj.ProtocolConfig,xcpDAQProperties{i})&&...
                    ~isempty(obj.ProtocolConfig.(xcpDAQProperties{i}))
                    obj.TargetConfiguration.(xcpDAQProperties{i})=obj.ProtocolConfig.(xcpDAQProperties{i});
                end
            end


            isSimulinkXCPHost=isequal(codertarget.attributes.getExtModeData('HostInterface',obj.ConfigSet),...
            DAStudio.message('codertarget:ui:ExternalModeSimulinkHostInterface'));
            obj.IsLoggingBufferSizeSetAutomatically=codertarget.attributes.getExtModeData('LoggingBufferAuto',obj.ConfigSet);
            obj.LoggingBufferSize=str2double(codertarget.attributes.getExtModeData('LoggingBufferSize',obj.ConfigSet));
            obj.NumOfLoggingBuffersPerSampleRate=str2double(codertarget.attributes.getExtModeData('LoggingBufferNum',obj.ConfigSet));
            if obj.ProtocolConfig.MaxContigSamples.visible
                obj.IsPackedMode=true;
                obj.MaxContiguousSamples=str2double(codertarget.attributes.getExtModeData('MaxContigSamples',obj.ConfigSet));
            else
                obj.IsPackedMode=isequal(get_param(obj.ModelName,'ExtModeSendContiguousSamples'),'on');
                obj.MaxContiguousSamples=get_param(obj.ModelName,'ExtModeTrigDuration');
            end
            maxNumOfODTsWithThirdPartyHost=obj.ProtocolConfig.MaxNumOfODTsWithThirdPartyHost;
            maxNumOfODTEntriesWithThirdPartyHost=obj.ProtocolConfig.MaxNumOfODTEntriesWithThirdPartyHost;


            obj.addMacrosToBuildInfo();


            memoryConfigurator=coder.internal.xcp.XCPMemoryConfigurator(...
            obj.ModelName,obj.TargetConfiguration);
            memoryConfigurator.SizeOfAdditionalFields=obj.sizeOfAdditionalFields;
            if~isempty(obj.ProtocolConfig.WidthOfTargetDoubleInBytes)
                memoryConfigurator.SizeOfTargetDouble=obj.ProtocolConfig.WidthOfTargetDoubleInBytes;
            end

            if isSimulinkXCPHost||isempty(maxNumOfODTsWithThirdPartyHost)||...
                isempty(maxNumOfODTEntriesWithThirdPartyHost)

                allocateMemoryForProfiling=isSimulinkXCPHost&&...
                isequal(get_param(obj.ConfigSet,'CodeExecutionProfiling'),'on');
                obj.configureMemoryFromSignals(memoryConfigurator,allocateMemoryForProfiling);

            else

                obj.configureMemoryWithThirdPartyMaster(...
                memoryConfigurator,...
                maxNumOfODTsWithThirdPartyHost,...
                maxNumOfODTEntriesWithThirdPartyHost);
            end

        end
    end

    methods(Access=private)

        function configureMemoryFromSignals(obj,memoryConfigurator,allocateMemoryForProfiling)




            obj.BuildInfo.deleteDefines('XCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER');
            obj.BuildInfo.deleteDefines('XCP_MEM_DAQ_RESERVED_POOLS_NUMBER');
            obj.BuildInfo.deleteDefines('XCP_MIN_EVENT_NO_RESERVED_POOL');

            if obj.IsPackedMode
                maxContiguousSamples=obj.MaxContiguousSamples;
            else

                maxContiguousSamples=1;
            end

            if obj.IsLoggingBufferSizeSetAutomatically||...
                obj.ProtocolConfig.LoggingBufferNum.visible

                bufferSize=[];
            elseif obj.ProtocolConfig.LoggingBufferSize.visible
                bufferSize=obj.LoggingBufferSize;
            else
                assert(false,'Either buffer size or buffer num should be visible');
            end

            if allocateMemoryForProfiling
                additionalDAQs=1;
                additionalODTs=1;
                additionalEntries=1;
            else
                additionalDAQs=0;
                additionalODTs=0;
                additionalEntries=0;
            end

            memoryConfigurator.addDefines(...
            obj.BuildInfo,...
            maxContiguousSamples,...
            sizeOfLoggingBuffer=bufferSize,...
            daqCopies=obj.NumOfLoggingBuffersPerSampleRate,...
            additionalDAQs=additionalDAQs,...
            additionalODTs=additionalODTs,...
            additionalEntries=additionalEntries);

        end

        function configureMemoryWithThirdPartyMaster(obj,...
            memoryConfigurator,...
            maxODTsInDAQ,...
            maxEntriesInODT)


            defs=obj.BuildInfo.getDefines;
            idx=contains(defs,'XCP_MEM_DAQ_RESERVED_POOLS_NUMBER');
            numReservedPoolsDefine=defs{idx};
            numOfDAQLists=str2double(extractAfter(numReservedPoolsDefine,'='));

            totODTs=numOfDAQLists*maxODTsInDAQ;

            [mainMem,reservedPools]=memoryConfigurator.getMemoryConfiguration(...
            numOfDAQLists,maxODTsInDAQ,totODTs,maxEntriesInODT,obj.LoggingBufferSize);


            blockNumbers=mainMem.Numbers;
            blockSizes=mainMem.Sizes;
            for i=1:numel(blockNumbers)
                obj.BuildInfo.addDefines(['XCP_MEM_BLOCK_',num2str(i),'_SIZE=',num2str(blockSizes(i))],'OPTS');
                obj.BuildInfo.addDefines(['XCP_MEM_BLOCK_',num2str(i),'_NUMBER=',num2str(blockNumbers(i))],'OPTS');
            end


            obj.BuildInfo.addDefines(['XCP_MEM_RESERVED_POOLS_TOTAL_SIZE=',num2str(reservedPools.TotalSize)]);
            obj.BuildInfo.addDefines(['XCP_MEM_RESERVED_POOLS_NUMBER=',num2str(reservedPools.Number)]);


            obj.BuildInfo.deleteDefines('XCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER');
            obj.BuildInfo.addDefines(['XCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER=',num2str(obj.NumOfLoggingBuffersPerSampleRate)]);
        end

        function addMacrosToBuildInfo(obj)
            obj.BuildInfo.addDefines(['XCP_MAX_CTO_SIZE=',num2str(obj.TargetConfiguration.MaxCTOSize)]);
            obj.BuildInfo.addDefines(['XCP_MAX_DTO_SIZE=',num2str(obj.TargetConfiguration.MaxDTOSize)]);
            obj.BuildInfo.addDefines(['XCP_MAX_ODT_ENTRY_SIZE=',num2str(obj.TargetConfiguration.MaxODTEntrySize)]);
            obj.BuildInfo.addDefines(['XCP_MAX_DAQ=',num2str(obj.TargetConfiguration.MaxDAQ)]);
            obj.BuildInfo.addDefines(['XCP_MIN_DAQ=',num2str(obj.TargetConfiguration.MinDAQ)]);
            obj.BuildInfo.addDefines(['XCP_MAX_EVENT_CHANNEL=',num2str(obj.TargetConfiguration.MaxEventChannel)]);
            obj.BuildInfo.addDefines(['XCP_ID_FIELD_TYPE=',num2str(obj.TargetConfiguration.IdentificationFieldSizeInBytes-1)]);
            obj.BuildInfo.addDefines(['XCP_TIMESTAMP_SIZE=',num2str(obj.TargetConfiguration.TimestampSizeInBytes)]);
            if obj.TargetConfiguration.AddressGranularity==1
                obj.BuildInfo.addDefines('-DXCP_ADDRESS_GRANULARITY=XCP_ADDRESS_GRANULARITY_BYTE');
                if obj.ProtocolConfig.IsByteAddressGranularityEmulation


                    obj.BuildInfo.addDefines('-DXCP_HARDWARE_ADDRESS_GRANULARITY=XCP_ADDRESS_GRANULARITY_WORD');
                end
            elseif obj.TargetConfiguration.AddressGranularity==2
                obj.BuildInfo.addDefines('-DXCP_ADDRESS_GRANULARITY=XCP_ADDRESS_GRANULARITY_WORD');
            end

            [~,names,values]=obj.BuildInfo.getDefines;
            if any(contains(names,'CODERTARGET_XCP_DAQ_PACKED_MODE'))
                if~obj.IsPackedMode
                    obj.BuildInfo.deleteDefines('-DCODERTARGET_XCP_DAQ_PACKED_MODE');
                    obj.BuildInfo.deleteDefines('-DCODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES');
                    obj.deleteMemoryConfigMacrosFromBuildInfo();
                else
                    maxContiguousSamples=str2double(values{contains(names,'CODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES')});
                    if maxContiguousSamples~=obj.MaxContiguousSamples
                        obj.BuildInfo.deleteDefines('-DCODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES');
                        obj.BuildInfo.addDefines(['-DCODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES=',num2str(obj.MaxContiguousSamples)]);
                        obj.deleteMemoryConfigMacrosFromBuildInfo();
                    end
                end
            else
                if obj.IsPackedMode
                    obj.BuildInfo.addDefines('-DCODERTARGET_XCP_DAQ_PACKED_MODE');
                    obj.BuildInfo.addDefines(['-DCODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES=',num2str(obj.MaxContiguousSamples)]);
                    obj.deleteMemoryConfigMacrosFromBuildInfo();
                end
            end
        end



        function deleteMemoryConfigMacrosFromBuildInfo(obj)
            obj.BuildInfo.deleteDefines('XCP_MEM_RESERVED_POOLS_TOTAL_SIZE');
            obj.BuildInfo.deleteDefines('XCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER');
            for i=1:3
                obj.BuildInfo.deleteDefines(['XCP_MEM_BLOCK_',num2str(i),'_SIZE']);
                obj.BuildInfo.deleteDefines(['XCP_MEM_BLOCK_',num2str(i),'_NUMBER']);
            end
        end
    end
end
