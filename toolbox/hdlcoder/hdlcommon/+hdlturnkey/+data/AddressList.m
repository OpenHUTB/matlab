


classdef AddressList<handle


    properties











        AddressLowerBound=0;
        AddressUpperBound=0;

    end

    properties(Hidden=true)




        ElementObjMap=[];






        AddressObjOnlyMap=[];






        AddressListObjOnlyMap=[];


        TypeObjMap=[];


        NameObjMap=[];


        BitPacking=true;


        ShiftRegisterDecoder=true;


        AddrDecoderPipeline=false;


        BytePacking=false;


        RegisterWidth=32;


        HasStrobePort=false;


        InitValue=0;





        AssignedName='';
    end

    properties(Access=private)




        IsLocked=false;
    end

    methods

        function obj=AddressList()

            cleanAssignment(obj);
        end

        function cleanAssignment(obj)

            obj.ElementObjMap=containers.Map('KeyType','double','ValueType','any');
            obj.AddressObjOnlyMap=containers.Map('KeyType','double','ValueType','any');
            obj.AddressListObjOnlyMap=containers.Map('KeyType','char','ValueType','any');
            obj.TypeObjMap=containers.Map('KeyType','int32','ValueType','any');
            obj.NameObjMap=containers.Map('KeyType','char','ValueType','any');
        end

        function isLocked=getLockStatus(obj)
            isLocked=obj.IsLocked;
        end

        function setLockStatus(obj,isLocked)
            obj.IsLocked=isLocked;
        end

        function cleanScheduledElab(obj)

            hAddrCell=getAllAssignedAddressObj(obj);
            for ii=1:length(hAddrCell)
                hAddr=hAddrCell{ii};
                if hAddr.ElabScheduled
                    hAddr.cleanScheduledElab;
                end
            end
        end

        function cleanAddrWithType(obj,addrType)

            hAddrCell=getAddressCellWithType(obj,addrType);
            for ii=1:length(hAddrCell)
                hAddr=hAddrCell{ii};
                removeAddressWithStartAddr(obj,hAddr.AddressStart);
                removeAddressWithName(obj,hAddr.AssignedPortName);
            end
            removeAddressWithType(obj,addrType);
        end


        function hAddrListNew=registerAddressList(obj,portName,addrType)

            hAddrListNew=hdlturnkey.data.AddressList();


            hAddrListNew.BitPacking=obj.BitPacking;
            hAddrListNew.BytePacking=obj.BytePacking;
            hAddrListNew.RegisterWidth=obj.RegisterWidth;
            hAddrListNew.HasStrobePort=obj.HasStrobePort;
            hAddrListNew.AddrDecoderPipeline=obj.AddrDecoderPipeline;
            hAddrListNew.ShiftRegisterDecoder=obj.ShiftRegisterDecoder;
            hAddrListNew.AddressLowerBound=obj.AddressLowerBound;
            hAddrListNew.AddressUpperBound=obj.AddressUpperBound;
            hAddrListNew.AssignedName=portName;
            obj.AddressListObjOnlyMap(portName)=hAddrListNew;


            addAdderssToTypeObjMap(obj,hAddrListNew,addrType);


            addAdderssToNameObjMap(obj,hAddrListNew,portName);

        end


        function hAddr=registerAddress(obj,addrStart,addrType,portName,...
            portType,portVectorSize,portWordLength,portAddressDecoder,...
            dispFlattenedPortName,dispTypeStr,dataType,portlevelReadback,requestStrobe)




            if obj.IsLocked
                error(message('hdlcommon:workflow:AddrListLocked',portName));
            end

            if nargin<13
                requestStrobe=false;
            end

            if nargin<12
                portlevelReadback='inherit';
            end
            if nargin<11
                dataType=[];
            end

            if nargin<10
                dispTypeStr='';
            end

            if nargin<9
                dispFlattenedPortName=portName;
            end

            if nargin<8

                portAddressDecoder=obj.getDefaultShiftRegisterDecoder();
            end
            if nargin<7
                portWordLength=1;
            end
            if nargin<6
                portVectorSize=1;
            end
            if nargin<5
                portType=hdlturnkey.IOType.IN;
            end


            [addrLength,packedWordLength,needPacking]=...
            hdlshared.internal.VectorAddressUtils.getPackingParams(...
            portVectorSize,portWordLength,obj.RegisterWidth,...
            obj.BitPacking,obj.BytePacking);


            hAddr=obj.setAddressAssigned(addrStart,addrLength);


            hAddr.AddressType=addrType;

            obj.addAdderssToTypeObjMap(hAddr,addrType);


            hAddr.AssignedPortName=portName;


            hAddr.FlattenedPortName=replace(dispFlattenedPortName,'.','_');


            hAddr.DispFlattenedPortName=dispFlattenedPortName;


            hAddr.DispDataType=dispTypeStr;


            hAddr.DataType=dataType;


            hAddr.RequestStrobePort=requestStrobe;


            hAddr.PortlevelRegisterReadback=portlevelReadback;

            hAddr.AssignedPortType=portType;

            addAdderssToNameObjMap(obj,hAddr,dispFlattenedPortName);


            hAddr.PortVectorSize=portVectorSize;
            hAddr.PortWordLength=portWordLength;
            if obj.BitPacking
                hAddr.NeedBitPacking=needPacking;
                hAddr.PackedVectorSize=addrLength;
                hAddr.PackedWordLength=packedWordLength;
            elseif obj.BytePacking
                error('not supported yet');
            end


            hAddr.AddrBlockSize=hdlshared.internal.VectorAddressUtils.getAddrBlockSize(addrLength);


            if addrLength>1


                switch portAddressDecoder
                case 'ShiftRegister'
                    hAddr.UseShiftRegister=true;
                otherwise
                    hAddr.UseShiftRegister=false;
                end
            end


            if obj.AddrDecoderPipeline
                hAddr.AddrDecoderPipeline=true;
            end
        end

        function registerAddressStrobePort(obj,addrStart,portName,...
            portVectorSize,portWordLength,requestStrobe)

            if obj.IsLocked
                error(message('hdlcommon:workflow:AddrListLocked',portName));
            end


            [addrLength,~,~]=...
            hdlshared.internal.VectorAddressUtils.getPackingParams(...
            portVectorSize,portWordLength,obj.RegisterWidth,...
            obj.BitPacking,obj.BytePacking);


            hAddr=obj.setAddressAssignedforStrobe(addrStart,addrLength,portName);


            hAddr.RequestStrobePort=requestStrobe;
            if requestStrobe
                hAddr.AsssignedStrobePortName=portName;
            end
        end

        function hAddr=registerAddressAuto(obj,portName,addrType,...
            portType,portVectorSize,portWordLength,requestStrobe)

            if nargin<7
                requestStrobe=false;
            end
            if nargin<6
                portWordLength=1;
            end
            if nargin<5
                portVectorSize=1;
            end
            if nargin<4||isempty(portType)
                portType=hdlturnkey.IOType.IN;
            end
            if nargin<3||isempty(addrType)
                addrType=hdlturnkey.data.AddrType.UNKNOWN;
            end


            hAddrManager=hdlturnkey.data.AddressManager(obj);
            addrLength=hdlshared.internal.VectorAddressUtils.getPackingParams(...
            portVectorSize,portWordLength,obj.RegisterWidth,...
            obj.BitPacking,obj.BytePacking);
            addrStart=hAddrManager.allocateAddressWithMsg(addrLength,portName);


            portAddressDecoder=obj.getDefaultShiftRegisterDecoder();

            hAddr=registerAddress(obj,addrStart,addrType,portName,...
            portType,portVectorSize,portWordLength,portAddressDecoder,...
            portName,'',[],requestStrobe);
        end



        function hAddr=getAddress(obj,addrValue)

            hAddr=[];
            hAddrCell=getAllAssignedAddressObj(obj);
            for ii=1:length(hAddrCell)
                hAddrUnit=hAddrCell{ii};
                if addrValue>=hAddrUnit.AddressStart&&...
                    addrValue<=hAddrUnit.AddressEnd
                    hAddr=hAddrUnit;
                    return;
                end
            end
        end

        function hAddr=getAddressWithType(obj,addrType)

            hAddr=[];
            hAddrCell=getAddressCellWithType(obj,addrType);
            if~isempty(hAddrCell)
                hAddr=hAddrCell{1};
            end
        end

        function hAddrCell=getAddressCellWithType(obj,addrType)


            hAddrCell={};
            key=int32(addrType);
            if obj.TypeObjMap.isKey(key)
                hAddrCell=obj.TypeObjMap(key);
            end
        end

        function hAddr=getAddressWithName(obj,assignedPortName)

            hAddr=[];
            if obj.NameObjMap.isKey(assignedPortName)
                hAddr=obj.NameObjMap(assignedPortName);
            end
        end

        function[isAssigned,hAssignedPCIAddr,addrDup]=isAddressAssigned(obj,addrStart,addrLength)

            isAssigned=false;
            hAssignedPCIAddr=[];
            addrDup=0;

            addrEnd=calculateAddressEnd(obj,addrStart,addrLength);


            hAddrStart=getAddress(obj,addrStart);
            if~isempty(hAddrStart)&&hAddrStart.Assigned
                isAssigned=true;
                hAssignedPCIAddr=hAddrStart;
                addrDup=addrStart;
                return;
            end


            if addrEnd==addrStart
                return;
            end


            hAddrEnd=getAddress(obj,addrEnd);
            if~isempty(hAddrEnd)&&hAddrEnd.Assigned
                isAssigned=true;
                hAssignedPCIAddr=hAddrEnd;
                addrDup=addrEnd;
                return;
            end


            hAddrCell=getAllAssignedAddressObj(obj);
            for ii=1:length(hAddrCell)
                hAddr=hAddrCell{ii};
                if hAddr.AddressStart>addrStart&&...
                    hAddr.AddressEnd<addrEnd
                    isAssigned=true;
                    hAssignedPCIAddr=hAddr;
                    addrDup=hAddr.AddressStart;
                    return;
                end
            end
        end


        function isAssigned=isAnyAddressAssigned(obj)
            isAssigned=false;
            hAddrCell=obj.getAllAssignedAddressObj;
            if(~isempty(hAddrCell))
                isAssigned=true;
            end
        end

        function isTrue=hasSubAddressList(obj)


            isTrue=obj.AddressListObjOnlyMap.Count>0;
        end
        function hAddrListCell=getAllAssignedAddressListObj(obj)

            hAddrListCell=obj.AddressListObjOnlyMap.values;
        end
        function hAddrCell=getAllAssignedAddressObj(obj)

            hAddrCell=obj.AddressObjOnlyMap.values;
        end

        function addrLength=getMaxAddressLength(obj)
            addrLength=obj.AddressUpperBound-obj.AddressLowerBound+1;
        end

        function portAddressDecoder=getDefaultShiftRegisterDecoder(obj)

            if obj.ShiftRegisterDecoder
                portAddressDecoder='ShiftRegister';
            else
                portAddressDecoder='FlatRegister';
            end
        end

        function[info,header]=exportAddressList(obj,info,isMinClkEnbl,defineVectorStrobe)


            if nargin<4
                defineVectorStrobe=false;
            end

            header={'Register Name','Address Offset','Description'};


            hAddrManager=hdlturnkey.data.AddressManager(obj);
            hAddrCell=hAddrManager.getAllAssignedAddressObj;
            for ii=1:length(hAddrCell)
                hAddr=hAddrCell{ii};
                if hAddr.AddressLength==1

                    addrOffsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);

                    addrDesc=hAddr.Description;
                else


                    addrOffsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);

                    addrDesc='';
                    if~isempty(hAddr.Description)
                        addrDesc=sprintf('%s',hAddr.Description);
                    end
                    addrEnd=obj.calculateVectorEndAddress(hAddr.AddressStart,hAddr.AddressLength);
                    addrEndStr=hdlturnkey.data.Address.convertAddrInternalToCStr(addrEnd);
                    vecDesc=sprintf(', vector with %d elements, address ends at %s',hAddr.AddressLength,addrEndStr);
                    addrDesc=sprintf('%s%s',addrDesc,vecDesc);
                end


                if~isempty(hAddr.DescName)
                    addrName=hAddr.DescName;
                else
                    addrName=hAddr.AssignedPortName;
                end





                if(isMinClkEnbl)
                    if~(strcmpi(addrName,'IPCore_Enable'))
                        info{end+1}={addrName,addrOffsetStr,addrDesc};%#ok<*AGROW>
                    end
                else
                    info{end+1}={addrName,addrOffsetStr,addrDesc};%#ok<*AGROW>
                end



                if defineVectorStrobe&&hAddr.NeedStrobe
                    obj.HasStrobePort=true;


                    addrOffsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStrobe);


                    nameBase=regexprep(addrName,'_Data$','');
                    addrDesc=sprintf('strobe register for port %s',nameBase);
                    addrName=sprintf('%s_Strobe',nameBase);
                    info{end+1}={addrName,addrOffsetStr,addrDesc};%#ok<*AGROW>
                end

            end
        end

        function hAddr=setAddressAssigned(obj,addrStart,addrLength)



            [addrEnd,needStrobe,addrStrobe]=obj.calculateAddressEnd(addrStart,addrLength);


            hAddr=hdlturnkey.data.Address(addrStart,addrLength,addrEnd,needStrobe,addrStrobe);
            hAddr.Assigned=true;


            obj.ElementObjMap(hAddr.AddressStart)=hAddr;


            obj.AddressObjOnlyMap(hAddr.AddressStart)=hAddr;
        end

        function hAddr=setAddressAssignedforStrobe(obj,addrStart,addrLength,portName)


            [addrEnd,needStrobe,addrStrobe]=obj.calculateAddressEnd(addrStart,addrLength);


            hAddr=hdlturnkey.data.Address(addrStart,addrLength,addrEnd,needStrobe,addrStrobe);
            hAddr.Assigned=true;

            hasKey=isKey(obj.ElementObjMap,addrStart);
            if hasKey
                mapValue=obj.ElementObjMap(addrStart);
                mapValue.RequestStrobePort=true;
                mapValue.AsssignedStrobePortName=portName;
                obj.ElementObjMap(addrStart)=mapValue;
                hAddr=mapValue;
            end
        end

        function[addrEnd,needStrobe,addrStrobe]=calculateAddressEnd(~,addrStart,addrLength)


            addrStrobe=hdlshared.internal.VectorAddressUtils.getStrobeAddr(addrStart,addrLength);


            if addrStrobe==0
                addrEnd=addrStart;
                needStrobe=false;
            else
                needStrobe=true;
                addrEnd=addrStrobe;
            end

        end

    end


    methods(Access=private)


        function addrEnd=calculateVectorEndAddress(~,addrStart,addrLength)

            if addrLength==1

                addrEnd=addrStart;
            else

                addrEnd=addrStart+addrLength-1;
            end
        end

        function addAdderssToTypeObjMap(obj,hAddr,addrType)


            hAddrCell=getAddressCellWithType(obj,addrType);

            hAddrCell{end+1}=hAddr;
            obj.TypeObjMap(int32(addrType))=hAddrCell;
        end

        function addAdderssToNameObjMap(obj,hAddr,assignedPortName)

            if obj.NameObjMap.isKey(assignedPortName)
                error(message('hdlcommon:workflow:DupPortName',assignedPortName));
            end
            obj.NameObjMap(assignedPortName)=hAddr;
        end

        function removeAddressWithStartAddr(obj,startAddr)
            if obj.ElementObjMap.isKey(startAddr)
                remove(obj.ElementObjMap,startAddr);
            end
            if obj.AddressObjOnlyMap.isKey(startAddr)
                remove(obj.AddressObjOnlyMap,startAddr);
            end
        end

        function removeAddressWithType(obj,addrType)
            key=int32(addrType);
            if obj.TypeObjMap.isKey(key)
                remove(obj.TypeObjMap,key);
            end
        end

        function removeAddressWithName(obj,assignedPortName)
            if obj.NameObjMap.isKey(assignedPortName)
                remove(obj.NameObjMap,assignedPortName);
            end
        end

    end

end

