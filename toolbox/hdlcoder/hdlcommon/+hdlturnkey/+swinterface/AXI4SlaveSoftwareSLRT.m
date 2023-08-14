


classdef AXI4SlaveSoftwareSLRT<hdlturnkey.swinterface.AXI4SlaveSoftware



    properties(Access=protected)


        DriverBlockLibrary='';
        AXI4SlaveWriteBlock='';
        AXI4SlaveReadBlock='';

    end

    properties(Access=protected,Constant)


        blockSpace=40;
        blockSizeWidth=70;
        blockSizeHeight=40;
        blockSizeHeightSmall=24;

    end


    properties(Access=protected)
    end


    methods
        function obj=AXI4SlaveSoftwareSLRT(hFGPAInterface,isCoProcessorMode,hasMATLABAXIMasterConnection,isAXI4ReadbackEnabled,writeDriverBlock,readDriverBlock)


            obj=obj@hdlturnkey.swinterface.AXI4SlaveSoftware(hFGPAInterface,isCoProcessorMode,hasMATLABAXIMasterConnection,isAXI4ReadbackEnabled);
            obj.AXI4SlaveWriteBlock=writeDriverBlock;
            obj.AXI4SlaveReadBlock=readDriverBlock;
        end

    end


    methods(Static,Access=protected)
        function addHandshakeBlock(~,~,~,~)


            error('should not reach here as SLRT workflow does not support co-processing mode anymore.');
        end
    end
    methods(Access=protected)

        function destBlockPath=addAXI4SlaveWriteBlock(obj,hModelGen,srcBlockPath,addrOffset,numAxiWriteBlocks,portName,hDataType,hAddr)


            portDims=hDataType.Dimension;
            portPath=srcBlockPath;
            blockSize=[obj.blockSizeWidth,obj.blockSizeHeight];

            if hDataType.isBoolean
                portDataType=fixdt('boolean');
            else
                portDataType=fixdt(hDataType.Signed,hDataType.WordLength,-hDataType.FractionLength);
            end







            if hDataType.isSingle
                packBlkName=portName;
                packBlkPath=portPath;
            else
                [blkh,packedVectorSize]=...
                hdlslrt.backend.genbitpack('pack',portDataType,portDims,portPath,blockSize,obj.blockSpace);
                packBlkPath=getfullname(blkh);
                packBlkName=get_param(blkh,'Name');
                if hAddr.NeedBitPacking&&hAddr.PackedVectorSize~=packedVectorSize
                    error(message('hdlcommon:workflow:BitPackingMismatch'));
                end
            end


            newBlkPath=obj.addPCIReadWriteBlk('write',portName,packBlkPath,packBlkName,hModelGen,hAddr,hDataType);


            destBlockPath=newBlkPath;
        end


        function srcBlockPath=addAXI4SlaveReadBlock(obj,hModelGen,destBlockPath,addrOffset,dataTypeStr,portDim,numAxiReadBlocks,portName,hDataType,hAddr)


            portDims=hDataType.Dimension;
            portPath=destBlockPath;
            blockSize=[obj.blockSizeWidth,obj.blockSizeHeight];

            if hDataType.isBoolean
                portDataType=fixdt('boolean');
            else
                portDataType=fixdt(hDataType.Signed,hDataType.WordLength,-hDataType.FractionLength);
            end



            if hDataType.isSingle
                packBlkName=portName;
                packBlkPath=portPath;
            else
                [blkh,packedVectorSize]=...
                hdlslrt.backend.genbitpack('unpack',portDataType,portDims,portPath,blockSize,obj.blockSpace);
                packBlkPath=getfullname(blkh);
                packBlkName=get_param(blkh,'Name');
                if hAddr.NeedBitPacking&&hAddr.PackedVectorSize~=packedVectorSize
                    error(message('hdlcommon:workflow:BitPackingMismatch'));
                end
            end


            newBlkPath=obj.addPCIReadWriteBlk('read',portName,packBlkPath,packBlkName,hModelGen,hAddr,hDataType);


            srcBlockPath=newBlkPath;
        end


        function newBlkPath=addPCIReadWriteBlk(obj,blkName,portName,refBlkPath,refBlkName,hModelGen,hAddr,hDataType)




            addrStart=hAddr.AddressStart;
            pciAddrStartStr=hdlturnkey.data.Address.convertAddrInternalToModelGenStr(addrStart);


            if hAddr.NeedStrobe
                addrStrobe=hAddr.AddressStrobe;
                pciAddrStrobeStr=hdlturnkey.data.Address.convertAddrInternalToModelGenStr(addrStrobe);
            else
                pciAddrStrobeStr='0';
            end


            portDimStr=sprintf('%d',hAddr.AddressLength);



            if(hDataType.isSingle)
                portType='single';
            else
                portType='uint32';
            end


            driverBlockParams={...
            'port_name',portName,...
            'port_offset',pciAddrStartStr,...
            'strobe',pciAddrStrobeStr,...
            'port_dim',portDimStr,...
            'port_type',portType};

            if strcmp(blkName,'write')

                blockName=sprintf('PCIWrite_%s',portName);
                newBlkPath=hModelGen.addLibraryBlock(obj.AXI4SlaveWriteBlock,'Right',refBlkPath,driverBlockParams,'BlockName',blockName);
            elseif strcmp(blkName,'read')

                blockName=sprintf('PCIRead_%s',portName);
                newBlkPath=hModelGen.addLibraryBlock(obj.AXI4SlaveReadBlock,'Left',refBlkPath,driverBlockParams,'BlockName',blockName);

            end
        end


        function tagName=getTagName(~,portName)
            tagName=sprintf('%s_tag',regexprep(portName,'\W','_'));
        end


        function AXI4SlaveWriteSubSystemName=getAXI4SlaveWriteSubSystemName(~)
            AXI4SlaveWriteSubSystemName='PCIWrite';
        end
        function AXI4SlaveReadSubSystemName=getAXI4SlaveReadSubSystemName(~)
            AXI4SlaveReadSubSystemName='PCIRead';
        end

    end


    methods(Access=protected)
    end

end