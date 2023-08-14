


classdef AddressManager<handle








    properties


        hAddressList=[];

    end

    methods
        function obj=AddressManager(hAddList)


            obj.hAddressList=hAddList;
        end
        function addrStartArray=registerAddressForIOPort(obj,hIOPort,portName,hDataType,...
            portType,hTableMap,addrStart,addrStartArray,dispFlattenedPortName,hAddrList)
















            if nargin<7
                addrStart=[];
            end
            if nargin<8
                addrStartArray=[];
            end
            if nargin<9
                dispFlattenedPortName=portName;
            end
            if nargin<10
                hAddrList=obj.hAddressList;
            end
            if(isa(hDataType,'hdlturnkey.data.TypeBus'))
                busMemberIDList=hDataType.getMemberIDList;
                hAddrListNew=hAddrList.registerAddressList(dispFlattenedPortName,hdlturnkey.data.AddrType.USER);
                for idx=1:length(busMemberIDList)
                    memberName=busMemberIDList{idx};
                    memberType=hDataType.getMemberType(memberName);
                    dispFlattenedPortNameNew=[dispFlattenedPortName,'.',memberName];
                    addrStartArray=obj.registerAddressForIOPort(hIOPort,portName,...
                    memberType,portType,hTableMap,...
                    addrStart,addrStartArray,dispFlattenedPortNameNew,hAddrListNew);



                    addrStart=[];
                end
            else

                if isempty(hDataType)
                    portVectorSize=hIOPort.Dimension;
                    portWordLength=hIOPort.WordLength;
                    dispTypeStr=hIOPort.DispDataType;
                elseif hDataType.isArrayType
                    portVectorSize=hDataType.Dimension;
                    portWordLength=hDataType.BaseType.WordLength;
                    dispTypeStr=sprintf('%s (%d)',hDataType.SLType,hDataType.Dimension);
                else
                    portVectorSize=1;
                    portWordLength=hDataType.WordLength;
                    dispTypeStr=hDataType.SLType;
                end


                addrLength=hdlshared.internal.VectorAddressUtils.getPackingParams(...
                portVectorSize,portWordLength,...
                hAddrList.RegisterWidth,hAddrList.BitPacking,...
                hAddrList.BytePacking);

                if isempty(addrStart)

                    addrStart=obj.allocateAddressWithMsg(addrLength,portName);
                    addrStartArray(end+1)=addrStart;
                end


                obj.setUserAddressAssigned(addrStart,...
                portVectorSize,portWordLength,portName,portType,hIOPort,hTableMap,...
                hAddrList,dispFlattenedPortName,dispTypeStr,hDataType);

            end
        end
        function setUserAddressAssigned(obj,addrStart,portVectorSize,portWordLength,portName,portType,hIOPort,hTableMap,...
            hAddrList,dispFlattenedPortName,dispTypeStr,hDataType)







            if nargin<9
                hAddrList=obj.hAddressList;
            end
            if nargin<10
                dispFlattenedPortName=portName;
            end
            if nargin<11
                dispTypeStr='';
            end
            if nargin<12
                hDataType=[];
            end

            addrLength=hdlshared.internal.VectorAddressUtils.getPackingParams(...
            portVectorSize,portWordLength,...
            hAddrList.RegisterWidth,hAddrList.BitPacking,...
            hAddrList.BytePacking);



            [isAssigned,hAssignedAddr,addrDup]=obj.isAddressAssigned(addrStart,addrLength);
            if isAssigned
                if hAssignedAddr.isDUTAddress
                    assignedPortName=sprintf('port "%s"',hAssignedAddr.AssignedPortName);
                else
                    assignedPortName='internal port';
                end
                InterfaceOpt=hTableMap.getInterfaceOption(hIOPort.PortName);
                if isempty(InterfaceOpt)
                    strobeSig=false;
                else
                    Strobeindex=find(strcmpi(InterfaceOpt,'WriteSync')==1);
                    if~isempty(Strobeindex)
                        strobeSig=str2double(InterfaceOpt{Strobeindex+1});
                    else
                        strobeSig=false;
                    end
                end

                if~isempty(InterfaceOpt)
                    if strobeSig

                    else
                        error(message('hdlcommon:workflow:DupAddressSpec',...
                        hdlturnkey.data.Address.convertAddrInternalToStr(addrDup),portName,assignedPortName));
                    end
                else
                    error(message('hdlcommon:workflow:DupAddressSpec',...
                    hdlturnkey.data.Address.convertAddrInternalToStr(addrDup),portName,assignedPortName));
                end
            end

            if hAddrList.ShiftRegisterDecoder
                portAddressDecoder='ShiftRegister';
            else
                portAddressDecoder='FlatRegister';
            end

            InterfaceOption=hTableMap.getInterfaceOption(hIOPort.PortName);
            if isempty(InterfaceOption)
                portlevelReadback='inherit';
                strobeSig=false;
            else
                Strobeindex=find(strcmpi(InterfaceOption,'WriteSync')==1);
                if~isempty(Strobeindex)
                    strobeSig=str2double(InterfaceOption{Strobeindex+1});
                else
                    strobeSig=false;
                end
                Readbackindex=find(strcmpi(InterfaceOption,'EnableReadback')==1);
                if~isempty(Readbackindex)
                    portlevelReadback=InterfaceOption{Readbackindex+1};
                else
                    portlevelReadback='inherit';
                end
            end

            if strobeSig

                hAddrList.registerAddressStrobePort(addrStart,portName,portVectorSize,portWordLength,strobeSig);
            else

                hAddrList.registerAddress(addrStart,...
                hdlturnkey.data.AddrType.USER,portName,portType,...
                portVectorSize,portWordLength,portAddressDecoder,dispFlattenedPortName,dispTypeStr,hDataType,portlevelReadback);
            end
        end

        function addrStart=allocateAddressWithMsg(obj,addrLength,portName)





            [isAvailable,addrStart]=obj.allocateAddress(addrLength);
            if~isAvailable
                error(message('hdlcommon:workflow:MaxAddresses',...
                getMaxAddressLength(obj),portName));
            end
        end

        function hAddrCell=getAllAssignedAddressObj(obj,hAddrList)













            if nargin<2
                hAddrList=obj.hAddressList;
            end

            if~hAddrList.hasSubAddressList
                hAddrCell=hAddrList.getAllAssignedAddressObj;
            else


                hAddrCell={};
                hAddrListCell=obj.getAllAssignedAddressListObj(hAddrList);
                for idx=1:length(hAddrListCell)
                    hAddrCell=horzcat(hAddrCell,hAddrListCell{idx}.getAllAssignedAddressObj);%#ok<AGROW>
                end
            end
        end
        function hAddr=getAddress(obj,addrValue)



            hAddr=[];
            hAddrCell=obj.getAllAssignedAddressObj;
            for ii=1:length(hAddrCell)
                hAddrUnit=hAddrCell{ii};
                if addrValue>=hAddrUnit.AddressStart&&...
                    addrValue<=hAddrUnit.AddressEnd
                    hAddr=hAddrUnit;
                    return;
                end
            end
        end

        function hAddr=getAddressWithName(obj,assignedPortName,hAddressList)



            if nargin<3
                hAddressList=obj.hAddressList;
            end
            hAddr=[];
            if hAddressList.NameObjMap.isKey(assignedPortName)
                hAddr=hAddressList.NameObjMap(assignedPortName);
            end
        end


    end

    methods(Access=private)

        function[isAvailable,addrStart]=allocateAddress(obj,addrLength)





            isAvailable=false;
            addrStart=0;


            blockSize=hdlshared.internal.VectorAddressUtils.getAddrBlockSize(addrLength);

            ii=obj.hAddressList.AddressLowerBound;
            while ii<=obj.hAddressList.AddressUpperBound

                blockStartAddr=hdlshared.internal.VectorAddressUtils.getNextBlockStartAddr(ii,blockSize);
                blockEndAddr=blockStartAddr+blockSize-1;


                if blockEndAddr>obj.hAddressList.AddressUpperBound
                    return;
                end

                [isAssigned,hAssignedPCIAddr]=obj.isAddressAssigned(blockStartAddr,addrLength);
                if isAssigned
                    hAddr=hAssignedPCIAddr;
                    ii=hAddr.AddressEnd+1;
                else

                    isAvailable=true;
                    addrStart=blockStartAddr;
                    return;
                end
            end
        end

        function hAddrListCell=getAllAssignedAddressListObj(obj,hAddrList,hAddrListCell)









            if nargin<2
                hAddrList=obj.hAddressList;
            end
            if nargin<3
                hAddrListCell={};
            end
            hAddrListCell{end+1}=hAddrList;
            if hAddrList.hasSubAddressList
                hSubAddrList=hAddrList.getAllAssignedAddressListObj;
                for idx=1:length(hSubAddrList)
                    hAddrListCell=obj.getAllAssignedAddressListObj(...
                    hSubAddrList{idx},hAddrListCell);
                end
            end
        end

        function[isAssigned,hAssignedPCIAddr,addrDup]=isAddressAssigned(obj,addrStart,addrLength)



            isAssigned=false;
            hAssignedPCIAddr=[];
            addrDup=0;


            hAddrCell=obj.getAllAssignedAddressObj;


            addrEnd=obj.hAddressList.calculateAddressEnd(addrStart,addrLength);



            for idx=1:length(hAddrCell)
                hAddrUnit=hAddrCell{idx};
                if(addrStart>=hAddrUnit.AddressStart&&...
                    addrStart<=hAddrUnit.AddressEnd)
                    isAssigned=true;
                    hAssignedPCIAddr=hAddrUnit;
                    addrDup=addrStart;
                    return;
                elseif(addrEnd>=hAddrUnit.AddressStart&&...
                    addrEnd<=hAddrUnit.AddressEnd)
                    isAssigned=true;
                    hAssignedPCIAddr=hAddrUnit;
                    addrDup=addrEnd;
                    return;
                elseif(hAddrUnit.AddressStart>=addrStart&&...
                    hAddrUnit.AddressStart<=addrEnd)
                    isAssigned=true;
                    hAssignedPCIAddr=hAddrUnit;
                    addrDup=hAddrUnit.AddressStart;
                end

            end
        end

    end

end


