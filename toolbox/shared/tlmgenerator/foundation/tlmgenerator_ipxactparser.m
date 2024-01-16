function Mapping=tlmgenerator_ipxactparser(SystemInfo,ConfigInfo,Mapping,structSocket,structInfoBank,structInfoReg,structInfoBitField,structPort)

    try

        filename=ConfigInfo.tlmgIPXactPath;

        if~isempty(which(filename))
            filename=which(filename);
        end
        root=parseFile(matlab.io.xml.dom.Parser,filename);
        compList=root.getElementsByTagName('spirit:component');

        if compList.getLength==0
            l_me=MException('','no spirit:component');
            throw(l_me);
        end

        if compList.getLength~=1
            l_me=MException('','too many spirit:component');
            throw(l_me);
        end

        component=compList.item(0);
        MWInfo=l_FindMWInfo(component);
        if~strcmp(MWInfo.MWBlock,ConfigInfo.tlmgRtwCompName)
            error(message('TLMGenerator:TLMTargetCC:MWBlockNotMatched',MWInfo.MWBlock));
        end

        busList=component.getElementsByTagName('spirit:busInterface');

        for ii=0:busList.getLength-1

            busCurr=busList.item(ii);
            MWMap=l_FindMWMap(busCurr);

            if~MWMap.isMWMap
                continue;
            end
            name=l_getFirstLevelUniqueElement(busCurr,'spirit:name');
            if numel(name)==0
                l_me=MException('','spirit:busInterface without spirit:name');
                throw(l_me);
            end
            busName=char(name.getFirstChild.getData);
            portMapList=busCurr.getElementsByTagName('spirit:portMap');
            if portMapList.getLength==1
                portMap=portMapList.item(0);
                physicalPort=l_getFirstLevelUniqueElement(portMap,'spirit:physicalPort');
                if numel(physicalPort)==0
                    l_me=MException('','spirit:portMap without spirit:physicalPort');
                    throw(l_me);
                end
                name=l_getFirstLevelUniqueElement(physicalPort,'spirit:name');
                if numel(name)==0
                    l_me=MException('','spirit:physicalPort without spirit:name');
                    throw(l_me);
                end
                SockName=char(name.getFirstChild.getData);
            else
                SockName=busName;
            end
            slave=l_getFirstLevelUniqueElement(busCurr,'spirit:slave');
            if numel(slave)==0
                error(message('TLMGenerator:TLMTargetCC:BusNotSlave',busName));
            end
            endianness=l_getFirstLevelUniqueElement(busCurr,'spirit:endianness');
            if numel(endianness)~=0
                BusEndianness=char(endianness.getFirstChild.getData);
                if~strcmp(BusEndianness,'little')
                    error(message('TLMGenerator:TLMTargetCC:BusNotLittleEndian',busName));
                end
            end
            bitsInLau=l_getFirstLevelUniqueElement(busCurr,'spirit:bitsInLau');
            if numel(bitsInLau)~=0
                BusBitsInLau=int32(sscanf(char(bitsInLau.getFirstChild.getData),'%i'));
                if BusBitsInLau~=8
                    error(message('TLMGenerator:TLMTargetCC:BusBitsInLau',busName));
                end
            end
            memoryMapRef=l_getFirstLevelUniqueElement(slave,'spirit:memoryMapRef');
            if(numel(MWMap.MWMapInput)~=0)||...
                (numel(MWMap.MWMapOutput)~=0)||...
                (numel(MWMap.MWMapParam)~=0)
                if numel(memoryMapRef)~=0
                    error(message('TLMGenerator:TLMTargetCC:BusMemMap',busName));
                end

                if(strcmp(ConfigInfo.tlmgSCMLOnOff,'on'))
                    error(message('TLMGenerator:TLMTargetCC:BusNoMemMapSCML',busName));
                end


                if(numel(MWMap.MWMapInput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                    error(message('TLMGenerator:TLMTargetCC:BusInputParamMix',busName));
                end

                if(numel(MWMap.MWMapOutput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                    error(message('TLMGenerator:TLMTargetCC:BusOutputParamMix',busName));
                end

                Mapping.SockNum=Mapping.SockNum+1;
                Mapping.SockList(Mapping.SockNum)=structSocket;
                Mapping.SockList(Mapping.SockNum).Name=SockName;
                Mapping.SockList(Mapping.SockNum).BitWidth=int32(32);
                Mapping.SockList(Mapping.SockNum).ByteWidth=int32(4);
                Mapping.SockList(Mapping.SockNum).SockName=SockName;
                Mapping.SockList(Mapping.SockNum).HasAddress=false;
                Mapping.SockList(Mapping.SockNum).HasRegister=false;
                [Mapping.SockList(Mapping.SockNum),SystemInfo]=l_BuildSockNoMem(Mapping.SockList(Mapping.SockNum),SystemInfo,ConfigInfo,MWMap,structInfoBank,structInfoReg);

            else
                if numel(memoryMapRef)==0
                    error(message('TLMGenerator:TLMTargetCC:BusNoMemMap',busName));
                end
                memoryMapName=char(memoryMapRef.getAttribute('spirit:memoryMapRef'));
                memoryMap=l_findMemoryMap(memoryMapName,component);

                Mapping.SockNum=Mapping.SockNum+1;
                Mapping.SockList(Mapping.SockNum)=structSocket;
                Mapping.SockList(Mapping.SockNum).Name=SockName;
                Mapping.SockList(Mapping.SockNum).SockName=SockName;
                Mapping.SockList(Mapping.SockNum).HasAddress=true;
                Mapping.SockList(Mapping.SockNum).HasRegister=true;
                [Mapping.SockList(Mapping.SockNum),SystemInfo]=l_BuildSockMem(Mapping.SockList(Mapping.SockNum),SystemInfo,ConfigInfo,memoryMap,structInfoBank,structInfoReg,structInfoBitField);

            end
        end
        model=l_getFirstLevelUniqueElement(component,'spirit:model');
        if~numel(model)==0
            portList=model.getElementsByTagName('spirit:port');
            for ii=0:portList.getLength-1

                portCurr=portList.item(ii);

                MWMap=l_FindPortMWMap(portCurr);
                if(strcmp(ConfigInfo.tlmgIPXactUnmappedSig,'off'))
                    if~MWMap.isMWMap
                        continue;
                    end
                end
                name=l_getFirstLevelUniqueElement(portCurr,'spirit:name');
                if numel(name)==0
                    l_me=MException('','spirit:port without spirit:name');
                    throw(l_me);
                end
                PortName=char(name.getFirstChild.getData);

                wire=l_getFirstLevelUniqueElement(portCurr,'spirit:wire');
                if numel(wire)==0
                    continue;
                end

                direction=l_getFirstLevelUniqueElement(wire,'spirit:direction');
                if numel(direction)==0
                    l_me=MException('','spirit:port %s without spirit:direction',PortName);
                    throw(l_me);
                end
                PortDir=char(direction.getFirstChild.getData);

                PortType='';
                wireTypeDefList=wire.getElementsByTagName('spirit:wireTypeDef');
                if wireTypeDefList.getLength~=0
                    for jj=0:wireTypeDefList.getLength-1

                        wireTypeDefCurr=wireTypeDefList.item(jj);

                        typeDefinition=l_getFirstLevelUniqueElement(wireTypeDefCurr,'spirit:typeDefinition');
                        if numel(typeDefinition)==0
                            continue;
                        end
                        PortTypeDef=char(typeDefinition.getFirstChild.getData);
                        if~strcmp(PortTypeDef,'systemc.h')
                            continue;
                        end
                        typeName=l_getFirstLevelUniqueElement(wireTypeDefCurr,'spirit:typeName');
                        if numel(typeName)==0
                            l_me=MException('','spirit:port %s without spirit:typeName',PortName);
                            throw(l_me);
                        end
                        PortType=char(typeName.getFirstChild.getData);
                    end
                end
                if numel(MWMap.MWMapInput)>1
                    error(message('TLMGenerator:TLMTargetCC:SigTooManyMWMapInput',PortName));
                end
                if numel(MWMap.MWMapOutput)>1
                    error(message('TLMGenerator:TLMTargetCC:SigTooManyMWMapOutput',PortName));
                end
                if numel(MWMap.MWMapParam)>1
                    error(message('TLMGenerator:TLMTargetCC:SigTooManyMWMapParam',PortName));
                end
                if(numel(MWMap.MWMapInput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                    error(message('TLMGenerator:TLMTargetCC:SigInputParamMix',PortName));
                end

                if(numel(MWMap.MWMapOutput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                    error(message('TLMGenerator:TLMTargetCC:SigOutputParamMix',PortName));
                end

                if(numel(MWMap.MWMapInput)~=0)&&(numel(MWMap.MWMapOutput)~=0)
                    error(message('TLMGenerator:TLMTargetCC:SigInputOutputMix',PortName));
                end

                Mapping.PortNum=Mapping.PortNum+1;
                Mapping.PortList(Mapping.PortNum)=structPort;
                Mapping.PortList(Mapping.PortNum).Name=PortName;
                Mapping.PortList(Mapping.PortNum).PortName=PortName;
                Mapping.PortList(Mapping.PortNum).TypeName=[PortName,'_T'];
                Mapping.PortList(Mapping.PortNum).Type=PortType;
                Mapping.PortList(Mapping.PortNum).DimName=[PortName,'_DIM'];
                Mapping.PortList(Mapping.PortNum).Dim=int32(1);
                if strcmp(PortDir,'out')
                    Mapping.PortList(Mapping.PortNum).ReadAccess=true;
                end
                if strcmp(PortDir,'in')
                    Mapping.PortList(Mapping.PortNum).WriteAccess=true;
                end
                if~strcmp(PortDir,'in')&&~strcmp(PortDir,'out')
                    error(message('TLMGenerator:TLMTargetCC:SigNotInOrOut',PortName));
                end

                if numel(MWMap.MWMapInput)~=0
                    if Mapping.PortList(Mapping.PortNum).WriteAccess==false
                        error(message('TLMGenerator:TLMTargetCC:SigOutInput',PortName));
                    end

                    Mapping.PortList(Mapping.PortNum).IsInput=true;

                    found=0;
                    for jj=1:SystemInfo.InStruct.NumPorts
                        if strcmp(MWMap.MWMapInput{1},SystemInfo.InStruct.Port(jj).Name)
                            SystemInfo.InStruct.Port(jj).Mapped=int32(SystemInfo.InStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:InputNotFoundSig',MWMap.MWMapInput{1},PortName));
                    end
                    Mapping.PortList(Mapping.PortNum).MW.InputName=SystemInfo.InStruct.Port(jj).Name;
                    Mapping.PortList(Mapping.PortNum).MW.InputPos=int32(jj-1);
                    Mapping.PortList(Mapping.PortNum).MW.InputType=SystemInfo.InStruct.Port(jj).DataType;
                    Mapping.PortList(Mapping.PortNum).MW.InputDim=int32(SystemInfo.InStruct.Port(jj).Dim);

                    if isempty(Mapping.PortList(Mapping.PortNum).Type)
                        Mapping.PortList(Mapping.PortNum).Type=SystemInfo.InStruct.Port(jj).DataType;
                        Mapping.PortList(Mapping.PortNum).Dim=int32(SystemInfo.InStruct.Port(jj).Dim);
                    end
                end

                if numel(MWMap.MWMapOutput)~=0
                    if Mapping.PortList(Mapping.PortNum).ReadAccess==false
                        error(message('TLMGenerator:TLMTargetCC:SigInOutput',PortName));
                    end

                    Mapping.PortList(Mapping.PortNum).IsOutput=true;

                    found=0;
                    for jj=1:SystemInfo.OutStruct.NumPorts
                        if strcmp(MWMap.MWMapOutput{1},SystemInfo.OutStruct.Port(jj).Name)
                            SystemInfo.OutStruct.Port(jj).Mapped=int32(SystemInfo.OutStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:OutputNotFoundSig',MWMap.MWMapOutput{1},PortName));
                    end



                    Mapping.PortList(Mapping.PortNum).MW.OutputName=SystemInfo.OutStruct.Port(jj).Name;
                    Mapping.PortList(Mapping.PortNum).MW.OutputPos=int32(jj-1);
                    Mapping.PortList(Mapping.PortNum).MW.OutputType=SystemInfo.OutStruct.Port(jj).DataType;
                    Mapping.PortList(Mapping.PortNum).MW.OutputDim=int32(SystemInfo.OutStruct.Port(jj).Dim);

                    if isempty(Mapping.PortList(Mapping.PortNum).Type)
                        Mapping.PortList(Mapping.PortNum).Type=SystemInfo.OutStruct.Port(jj).DataType;
                        Mapping.PortList(Mapping.PortNum).Dim=int32(SystemInfo.OutStruct.Port(jj).Dim);
                    end
                end

                if numel(MWMap.MWMapParam)~=0

                    Mapping.PortList(Mapping.PortNum).IsParam=true;

                    found=0;
                    for jj=1:SystemInfo.ParamStruct.NumPorts
                        if strcmp(MWMap.MWMapParam{1},SystemInfo.ParamStruct.Port(jj).Name)
                            SystemInfo.ParamStruct.Port(jj).Mapped=int32(SystemInfo.ParamStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:ParamNotFoundSig',MWMap.MWMapParam{1},PortName));
                    end



                    Mapping.PortList(Mapping.PortNum).MW.ParamName=SystemInfo.ParamStruct.Port(jj).Name;
                    Mapping.PortList(Mapping.PortNum).MW.ParamPos=int32(jj-1);
                    Mapping.PortList(Mapping.PortNum).MW.ParamType=SystemInfo.ParamStruct.Port(jj).DataType;
                    Mapping.PortList(Mapping.PortNum).MW.ParamDim=int32(SystemInfo.ParamStruct.Port(jj).Dim);

                    if isempty(Mapping.PortList(Mapping.PortNum).Type)
                        Mapping.PortList(Mapping.PortNum).Type=SystemInfo.ParamStruct.Port(jj).DataType;
                        Mapping.PortList(Mapping.PortNum).Dim=int32(SystemInfo.ParamStruct.Port(jj).Dim);
                    end
                end


            end
        end

        if strcmp(ConfigInfo.tlmgGenerateTestbenchOnOff,'on')
            for i=1:SystemInfo.InStruct.NumPorts
                if SystemInfo.InStruct.Port(i).Mapped==0
                    error(message('TLMGenerator:TLMTargetCC:InputNotMapped',SystemInfo.InStruct.Port(i).Name));
                end
            end
            for i=1:SystemInfo.OutStruct.NumPorts
                if SystemInfo.OutStruct.Port(i).Mapped==0
                    error(message('TLMGenerator:TLMTargetCC:OutputNotMapped',SystemInfo.OutStruct.Port(i).Name));
                end
            end
        end

    catch ME
        l_me=MException('','TLMG ipxactparser: %s',ME.message);
        throw(l_me);
    end
end

function MemoryMap=l_findMemoryMap(memoryMapName,component)
    memoryMapList=component.getElementsByTagName('spirit:memoryMap');
    if memoryMapList.getLength==0
        l_me=MException('','Cannot a spirit:memoryMap in the component');
        throw(l_me);
    end
    found=0;
    for jj=0:memoryMapList.getLength-1
        memoryMapCurr=memoryMapList.item(jj);
        name=l_getFirstLevelUniqueElement(memoryMapCurr,'spirit:name');
        if numel(name)==0
            l_me=MException('','spirit:memoryMap %d does not have a spirit:name',jj);
            throw(l_me);
        end
        if strcmp(memoryMapName,char(name.getFirstChild.getData))
            found=1;
            break;
        end
    end
    if found==0
        l_me=MException('','spirit:memoryMap %s not found\n',memoryMapName);
        throw(l_me);
    end
    MemoryMap=memoryMapCurr;
end

function Element=l_getFirstLevelUniqueElement(parentNode,tagName)

    ListElement=l_getFirstLevelListElements(parentNode,tagName);

    Element='';

    if numel(ListElement)==0
        return;
    end

    if numel(ListElement)>1
        l_me=MException('','%s is not unique in %s\n',tagName,parentNode.getTagName);
        throw(l_me);
    end

    Element=ListElement{1};

end


function ListElement=l_getFirstLevelListElements(parentNode,tagName)
    nodeList=parentNode.getElementsByTagName(tagName);

    ListElement={};

    if~(nodeList.getLength>0)
        return;
    end
    jj=1;
    for ii=0:nodeList.getLength-1
        if nodeList.item(ii).getParentNode==parentNode
            ListElement{jj}=nodeList.item(ii);
            jj=jj+1;
        end
    end
end


function ret=l_FindPortMWMap(parentNode)
    vendorExtensions=l_getFirstLevelUniqueElement(parentNode,'spirit:vendorExtensions');
    if numel(vendorExtensions)==0


        ret=l_FindMWMap(parentNode);
    else
        ret=l_FindMWMap(vendorExtensions);

        if~ret.isMWMap
            ret=l_FindMWMap(parentNode);
        end
    end
end


function ret=l_FindMWMap(parentNode)
    ret=struct('isMWMap',false,...
    'MWMapInput','',...
    'MWMapOutput','',...
    'MWMapParam','');
    params=l_getFirstLevelUniqueElement(parentNode,'spirit:parameters');
    if numel(params)==0
        return;
    end
    paramList=l_getFirstLevelListElements(params,'spirit:parameter');
    if numel(paramList)==0
        return;
    end

    for ii=1:numel(paramList)
        name=l_getFirstLevelUniqueElement(paramList{ii},'spirit:name');
        if strcmp(char(name.getFirstChild.getData),'MWMap')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.isMWMap=str2num(data);
        end

        if strcmp(char(name.getFirstChild.getData),'MWMapInput')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.isMWMap=true;
            ll=numel(ret.MWMapInput)+1;
            ret.MWMapInput{ll}=data;
        end

        if strcmp(char(name.getFirstChild.getData),'MWMapOutput')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.isMWMap=true;
            ll=numel(ret.MWMapOutput)+1;
            ret.MWMapOutput{ll}=data;
        end

        if strcmp(char(name.getFirstChild.getData),'MWMapParam')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.isMWMap=true;
            ll=numel(ret.MWMapParam)+1;
            ret.MWMapParam{ll}=data;
        end

    end

end


function ret=l_FindFalseMWMap(parentNode)
    ret=struct('isMWMap',true);
    params=l_getFirstLevelUniqueElement(parentNode,'spirit:parameters');
    if numel(params)==0
        return;
    end
    paramList=l_getFirstLevelListElements(params,'spirit:parameter');
    if numel(paramList)==0
        return;
    end

    for ii=1:numel(paramList)
        name=l_getFirstLevelUniqueElement(paramList{ii},'spirit:name');
        if strcmp(char(name.getFirstChild.getData),'MWMap')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.isMWMap=str2num(data);
        end
    end
end


function ret=l_FindMWInfo(parentNode)
    ret=struct('MWVendor','',...
    'MWVersion','',...
    'MWModel','',...
    'MWBlock','');
    params=l_getFirstLevelUniqueElement(parentNode,'spirit:parameters');
    if numel(params)==0
        return;
    end
    paramList=l_getFirstLevelListElements(params,'spirit:parameter');
    if numel(paramList)==0
        return;
    end

    for ii=1:numel(paramList)
        name=l_getFirstLevelUniqueElement(paramList{ii},'spirit:name');
        if strcmp(char(name.getFirstChild.getData),'MWVendor')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.MWVendor=data;
        end

        if strcmp(char(name.getFirstChild.getData),'MWVersion')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.MWVersion=data;
        end

        if strcmp(char(name.getFirstChild.getData),'MWModel')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.MWModel=data;
        end

        if strcmp(char(name.getFirstChild.getData),'MWBlock')
            value=l_getFirstLevelUniqueElement(paramList{ii},'spirit:value');
            data=char(value.getFirstChild.getData);
            ret.MWBlock=data;
        end

    end

end


function[type,byte]=l_FindSCMLType(ByteDim)
    type='';
    byte=int32(0);
    if(ByteDim<=1)
        type='unsigned char';
        byte=int32(1);
    elseif(ByteDim<=2)
        type='unsigned short';
        byte=int32(2);
    elseif(ByteDim<=4)
        type='unsigned int';
        byte=int32(4);
    elseif(ByteDim<=8)
        type='unsigned long long';
        byte=int32(8);
    elseif(ByteDim<=16)
        type='sc_dt::sc_biguint<128>';
        byte=int32(16);
    elseif(ByteDim<=32)
        type='sc_dt::sc_biguint<256>';
        byte=int32(32);
    elseif(ByteDim<=64)
        type='sc_dt::sc_biguint<512>';
        byte=int32(64);
    end
end


function[ByteDimAlign]=l_FindByteDimAlign(ByteDim)
    ByteDimAlign=int32(0);
    if(ByteDim<=1)
        ByteDimAlign=int32(1);
    elseif(ByteDim<=2)
        ByteDimAlign=int32(2);
    elseif(ByteDim<=4)
        ByteDimAlign=int32(4);
    elseif(ByteDim<=8)
        ByteDimAlign=int32(8);
    elseif(ByteDim<=16)
        ByteDimAlign=int32(16);
    elseif(ByteDim<=32)
        ByteDimAlign=int32(32);
    elseif(ByteDim<=64)
        ByteDimAlign=int32(64);
    end
end


function[Sock,SystemInfo]=l_BuildSockNoMem(Sock,SystemInfo,ConfigInfo,MWMap,structInfoBank,structInfoReg)
    BankAddr=int32(0);
    if numel(MWMap.MWMapInput)~=0
        Sock.HasInput=true;
        RegAddr=int32(0);
        Sock.BankNum=int32(Sock.BankNum+1);
        BankNum=Sock.BankNum;
        Sock.Bank(BankNum)=structInfoBank;
        Sock.Bank(BankNum).HasInput=true;
        Sock.Bank(BankNum).Name=[Sock.Name,'_IN_BANK'];
        Sock.Bank(BankNum).TypeName=[Sock.Name,'_IN_BANK_T'];
        Sock.Bank(BankNum).Type='struct';
        Sock.Bank(BankNum).DimName=[Sock.Name,'_IN_BANK_DIM'];
        Sock.Bank(BankNum).Dim=int32(1);
        Sock.Bank(BankNum).AddrName=[Sock.Name,'_IN_REG_ADDR'];
        Sock.Bank(BankNum).Addr=int32(BankAddr);
        Sock.Bank(BankNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Addr);
        Sock.Bank(BankNum).RegNumName=[Sock.Name,'_IN_REG_NUM'];

        for ii=1:numel(MWMap.MWMapInput)
            found=0;
            for jj=1:SystemInfo.InStruct.NumPorts
                if strcmp(MWMap.MWMapInput{ii},SystemInfo.InStruct.Port(jj).Name)
                    SystemInfo.InStruct.Port(jj).Mapped=int32(SystemInfo.InStruct.Port(jj).Mapped+1);
                    found=1;
                    break;
                end
            end
            if found==0
                error(message('TLMGenerator:TLMTargetCC:InputNotFoundBus',MWMap.MWMapInput{ii},Sock.Name));
            end
            Sock.Bank(BankNum).RegNum=int32(Sock.Bank(BankNum).RegNum+1);
            RegNum=Sock.Bank(BankNum).RegNum;
            Sock.Bank(BankNum).Reg(RegNum)=structInfoReg;
            Sock.Bank(BankNum).Reg(RegNum).IsInput=true;
            Sock.Bank(BankNum).Reg(RegNum).WriteAccess=true;
            Sock.Bank(BankNum).Reg(RegNum).Name=[SystemInfo.InStruct.Port(jj).Name,'_REG'];
            Sock.Bank(BankNum).Reg(RegNum).MW.InputName=SystemInfo.InStruct.Port(jj).Name;
            Sock.Bank(BankNum).Reg(RegNum).MW.InputPos=int32(jj-1);
            Sock.Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.InStruct.Port(jj).Name,'_REG_T'];
            Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.InStruct.Port(jj).DataType;
            Sock.Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.InStruct.Port(jj).Name,'_REG_DIM'];
            Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.InStruct.Port(jj).Dim);
            Sock.Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.InStruct.Port(jj).Name,'_REG_ADDR'];
            Sock.Bank(BankNum).Reg(RegNum).Addr=int32(RegAddr);
            Sock.Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Reg(ii).Addr);
            Sock.Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.InStruct.Port(jj).ByteDim);
            Sock.Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
            RegAddr=idivide(RegAddr+Sock.Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
        end
        Sock.Bank(BankNum).ByteDim=int32(RegAddr);
        BankAddr=BankAddr+Sock.Bank(BankNum).ByteDim;
    end

    if numel(MWMap.MWMapOutput)~=0
        Sock.HasOutput=true;
        RegAddr=int32(0);
        Sock.BankNum=int32(Sock.BankNum+1);
        BankNum=Sock.BankNum;
        Sock.Bank(BankNum)=structInfoBank;
        Sock.Bank(BankNum).HasOutput=true;
        Sock.Bank(BankNum).Name=[Sock.Name,'_OUT_BANK'];
        Sock.Bank(BankNum).TypeName=[Sock.Name,'_OUT_BANK_T'];
        Sock.Bank(BankNum).Type='struct';
        Sock.Bank(BankNum).DimName=[Sock.Name,'_OUT_BANK_DIM'];
        Sock.Bank(BankNum).Dim=int32(1);
        Sock.Bank(BankNum).AddrName=[Sock.Name,'_OUT_BANK_ADDR'];
        Sock.Bank(BankNum).Addr=int32(BankAddr);
        Sock.Bank(BankNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Addr);
        Sock.Bank(BankNum).RegNumName=[Sock.Name,'_OUT_BANK_NUM'];

        for ii=1:numel(MWMap.MWMapOutput)
            found=0;
            for jj=1:SystemInfo.OutStruct.NumPorts
                if strcmp(MWMap.MWMapOutput{ii},SystemInfo.OutStruct.Port(jj).Name)
                    SystemInfo.OutStruct.Port(jj).Mapped=int32(SystemInfo.OutStruct.Port(jj).Mapped+1);
                    found=1;
                    break;
                end
            end
            if found==0
                error(message('TLMGenerator:TLMTargetCC:OutputNotFoundBus',MWMap.MWMapOutput{ii},Sock.Name));
            end
            Sock.Bank(BankNum).RegNum=int32(Sock.Bank(BankNum).RegNum+1);
            RegNum=Sock.Bank(BankNum).RegNum;
            Sock.Bank(BankNum).Reg(RegNum)=structInfoReg;
            Sock.Bank(BankNum).Reg(RegNum).IsOutput=true;
            Sock.Bank(BankNum).Reg(RegNum).ReadAccess=true;
            Sock.Bank(BankNum).Reg(RegNum).Name=[SystemInfo.OutStruct.Port(jj).Name,'_REG'];
            Sock.Bank(BankNum).Reg(RegNum).MW.OutputName=SystemInfo.OutStruct.Port(jj).Name;
            Sock.Bank(BankNum).Reg(RegNum).MW.OutputPos=int32(jj-1);
            Sock.Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.OutStruct.Port(jj).Name,'_REG_T'];
            Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.OutStruct.Port(jj).DataType;
            Sock.Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.OutStruct.Port(jj).Name,'_REG_DIM'];
            Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.OutStruct.Port(jj).Dim);
            Sock.Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.OutStruct.Port(jj).Name,'_REG_ADDR'];
            Sock.Bank(BankNum).Reg(RegNum).Addr=int32(RegAddr);
            Sock.Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Reg(RegNum).Addr);
            Sock.Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.OutStruct.Port(jj).ByteDim);
            Sock.Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
            RegAddr=idivide(RegAddr+Sock.Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
        end
        Sock.Bank(BankNum).ByteDim=int32(RegAddr);
        BankAddr=BankAddr+Sock.Bank(BankNum).ByteDim;
    end

    if numel(MWMap.MWMapParam)~=0
        Sock.HasParam=true;
        RegAddr=int32(0);
        Sock.BankNum=int32(Sock.BankNum+1);
        BankNum=Sock.BankNum;
        Sock.Bank(BankNum)=structInfoBank;
        Sock.Bank(BankNum).HasParam=true;
        Sock.Bank(BankNum).Name=[SystemInfo.Name,'_',Sock.Name,'_PARAM_BANK'];
        Sock.Bank(BankNum).TypeName=[SystemInfo.Name,'_',Sock.Name,'_PARAM_BANK_T'];
        Sock.Bank(BankNum).Type='struct';
        Sock.Bank(BankNum).DimName=[SystemInfo.Name,'_',Sock.Name,'_PARAM_BANK_DIM'];
        Sock.Bank(BankNum).Dim=int32(1);
        Sock.Bank(BankNum).AddrName=[SystemInfo.Name,'_',Sock.Name,'_PARAM_BANK_ADDR'];
        Sock.Bank(BankNum).Addr=int32(BankAddr);
        Sock.Bank(BankNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Addr);
        Sock.Bank(BankNum).RegNumName=[SystemInfo.Name,'_',Sock.Name,'_PARAM_BANK_NUM'];

        for ii=1:numel(MWMap.MWMapParam)
            found=0;
            for jj=1:SystemInfo.ParamStruct.NumPorts
                if strcmp(MWMap.MWMapParam{ii},SystemInfo.ParamStruct.Port(jj).Name)
                    SystemInfo.ParamStruct.Port(jj).Mapped=int32(SystemInfo.ParamStruct.Port(jj).Mapped+1);
                    found=1;
                    break;
                end
            end
            if found==0
                error(message('TLMGenerator:TLMTargetCC:ParamNotFoundBus',MWMap.MWMapParam{ii},Sock.Name));
            end
            Sock.Bank(BankNum).RegNum=int32(Sock.Bank(BankNum).RegNum+1);
            RegNum=Sock.Bank(BankNum).RegNum;
            Sock.Bank(BankNum).Reg(RegNum)=structInfoReg;
            Sock.Bank(BankNum).Reg(RegNum).IsParam=true;
            Sock.Bank(BankNum).Reg(RegNum).ReadAccess=true;
            Sock.Bank(BankNum).Reg(RegNum).WriteAccess=true;
            Sock.Bank(BankNum).Reg(RegNum).Name=[SystemInfo.ParamStruct.Port(jj).Name,'_REG'];
            Sock.Bank(BankNum).Reg(RegNum).MW.ParamName=SystemInfo.ParamStruct.Port(jj).Name;
            Sock.Bank(BankNum).Reg(RegNum).MW.ParamPos=int32(jj-1);
            Sock.Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.ParamStruct.Port(jj).Name,'_REG_T'];
            Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.ParamStruct.Port(jj).DataType;
            Sock.Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.ParamStruct.Port(jj).Name,'_REG_DIM'];
            Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.ParamStruct.Port(jj).Dim);
            Sock.Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.ParamStruct.Port(jj).Name,'_REG_ADDR'];
            Sock.Bank(BankNum).Reg(RegNum).Addr=int32(BankAddr+RegAddr);
            Sock.Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Reg(RegNum).Addr);
            Sock.Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.ParamStruct.Port(jj).ByteDim);
            Sock.Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
            RegAddr=idivide(RegAddr+Sock.Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
        end
        Sock.Bank(BankNum).ByteDim=int32(RegAddr);
        BankAddr=BankAddr+Sock.Bank(BankNum).ByteDim;
    end
    Sock.ByteDim=int32(BankAddr);
end


function[Sock,SystemInfo]=l_BuildSockMem(Sock,SystemInfo,ConfigInfo,memoryMap,structInfoBank,structInfoReg,structInfoBitField)
    name=l_getFirstLevelUniqueElement(memoryMap,'spirit:name');
    if numel(name)==0
        l_me=MException('','spirit:memoryMap without spirit:name');
        throw(l_me);
    end
    MemoryMapName=char(name.getFirstChild.getData);
    addressUnitBits=l_getFirstLevelUniqueElement(memoryMap,'spirit:addressUnitBits');
    if numel(addressUnitBits)~=0
        MemoryMapAddressUnitBits=int32(sscanf(char(addressUnitBits.getFirstChild.getData),'%i'));
        if MemoryMapAddressUnitBits~=8
            error(message('TLMGenerator:TLMTargetCC:MemoryMapAddressUnitBits',MemoryMapName));
        end
    end
    addressBlockList=memoryMap.getElementsByTagName('spirit:addressBlock');
    if addressBlockList.getLength==0
        error(message('TLMGenerator:TLMTargetCC:MemapNoAddrBlock',MemoryMapName));
    end

    for ll=0:addressBlockList.getLength-1

        addressBlockCurr=addressBlockList.item(ll);
        addressBlockMWMap=l_FindFalseMWMap(addressBlockCurr);
        if~addressBlockMWMap.isMWMap
            continue;
        end
        name=l_getFirstLevelUniqueElement(addressBlockCurr,'spirit:name');
        if numel(name)==0
            l_me=MException('','In spirit:memoryMap %s spirit:addressBlock without spirit:name',MemoryMapName);
            throw(l_me);
        end
        BlockName=char(name.getFirstChild.getData);
        baseAddress=l_getFirstLevelUniqueElement(addressBlockCurr,'spirit:baseAddress');
        if numel(baseAddress)==0
            l_me=MException('','In spirit:memoryMap %s spirit:addressBlock %s without spirit:baseAddress',MemoryMapName,BlockName);
            throw(l_me);
        end
        BlockAddr=int32(sscanf(char(baseAddress.getFirstChild.getData),'%i'));
        if BlockAddr<0
            error(message('TLMGenerator:TLMTargetCC:BlockAddrMin',MemoryMapName,BlockName));
        end
        range=l_getFirstLevelUniqueElement(addressBlockCurr,'spirit:range');
        if numel(range)==0
            l_me=MException('','In spirit:memoryMap %s spirit:addressBlock %s without spirit:range',MemoryMapName,BlockName);
            throw(l_me);
        end
        BlockRange=int32(sscanf(char(range.getFirstChild.getData),'%i'));
        if BlockRange<1
            error(message('TLMGenerator:TLMTargetCC:BlockRangeMin',MemoryMapName,BlockName));
        end
        width=l_getFirstLevelUniqueElement(addressBlockCurr,'spirit:width');
        if numel(width)==0
            l_me=MException('','In spirit:memoryMap %s spirit:addressBlock %s without spirit:width',MemoryMapName,BlockName);
            throw(l_me);
        end
        BlockWidth=int32(sscanf(char(width.getFirstChild.getData),'%i'));

        registerList=addressBlockCurr.getElementsByTagName('spirit:register');

        for ii=0:registerList.getLength-1
            registerCurr=registerList.item(ii);
            MWMap=l_FindFalseMWMap(registerCurr);
            if~MWMap.isMWMap
                continue;
            end

            MWMap=l_FindMWMap(registerCurr);
            if(strcmp(ConfigInfo.tlmgIPXactUnmapped,'off'))
                if~MWMap.isMWMap
                    continue;
                end
            end

            Sock.BitWidth=BlockWidth;
            Sock.ByteWidth=l_FindByteDimAlign(int32(idivide(Sock.BitWidth,8,'ceil')));

            if(strcmp(ConfigInfo.tlmgSCMLOnOff,'on'))
                [type,byte]=l_FindSCMLType(Sock.ByteWidth);
                Sock.SCMLType=type;
                Sock.SCMLByteDim=byte;
                if isempty(Sock.SCMLType)
                    error(message('TLMGenerator:TLMTargetCC:BlockSCMLTypeNotFound',MemoryMapName,BlockName));
                end
            end
            Sock.BankNum=int32(Sock.BankNum+1);
            BankNum=Sock.BankNum;
            Sock.Bank(BankNum)=structInfoBank;
            Sock.Bank(BankNum).Name=BlockName;
            Sock.Bank(BankNum).TypeName=[BlockName,'_T'];
            Sock.Bank(BankNum).Type='struct';
            Sock.Bank(BankNum).DimName=[BlockName,'_DIM'];
            Sock.Bank(BankNum).Dim=int32(1);
            Sock.Bank(BankNum).AddrName=[BlockName,'_ADDR'];
            Sock.Bank(BankNum).Addr=BlockAddr;
            Sock.Bank(BankNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Addr);
            Sock.Bank(BankNum).RegNumName=[BlockName,'_REG_NUM'];
            Sock.Bank(BankNum).RegNum=int32(0);
            Sock.Bank(BankNum).ByteDim=BlockRange;
            break;
        end

        for ii=0:registerList.getLength-1
            registerCurr=registerList.item(ii);
            MWMap=l_FindFalseMWMap(registerCurr);
            if~MWMap.isMWMap
                continue;
            end

            MWMap=l_FindMWMap(registerCurr);
            if(strcmp(ConfigInfo.tlmgIPXactUnmapped,'off'))
                if~MWMap.isMWMap
                    continue;
                end
            end
            name=l_getFirstLevelUniqueElement(registerCurr,'spirit:name');
            if numel(name)==0
                l_me=MException('','In spirit:memoryMap %s spirit:register without spirit:name',MemoryMapName);
                throw(l_me);
            end
            RegisterName=char(name.getFirstChild.getData);
            addressOffset=l_getFirstLevelUniqueElement(registerCurr,'spirit:addressOffset');
            if numel(addressOffset)==0
                l_me=MException('','In spirit:memoryMap %s spirit:register %s without spirit:addressOffset',MemoryMapName,RegisterName);
                throw(l_me);
            end
            RegisterOffset=int32(sscanf(char(addressOffset.getFirstChild.getData),'%i'));
            if RegisterOffset<0
                error(message('TLMGenerator:TLMTargetCC:RegisterOffsetMin',MemoryMapName,RegisterName));
            end

            size=l_getFirstLevelUniqueElement(registerCurr,'spirit:size');
            if numel(size)==0
                l_me=MException('','In spirit:memoryMap %s spirit:register %s without spirit:size',MemoryMapName,RegisterName);
                throw(l_me);
            end
            RegisterSize=int32(sscanf(char(size.getFirstChild.getData),'%i'));
            if RegisterSize<1
                error(message('TLMGenerator:TLMTargetCC:RegisterSizeMin',MemoryMapName,RegisterName));
            end

            access=l_getFirstLevelUniqueElement(registerCurr,'spirit:access');
            if numel(access)==0
                RegisterAccess='read-write';
            else
                RegisterAccess=char(access.getFirstChild.getData);
            end

            if numel(MWMap.MWMapInput)>1
                error(message('TLMGenerator:TLMTargetCC:TooManyMWMapInput',MemoryMapName,RegisterName));
            end
            if numel(MWMap.MWMapOutput)>1
                error(message('TLMGenerator:TLMTargetCC:TooManyMWMapOutput',MemoryMapName,RegisterName));
            end
            if numel(MWMap.MWMapParam)>1
                error(message('TLMGenerator:TLMTargetCC:TooManyMWMapParam',MemoryMapName,RegisterName));
            end
            if(numel(MWMap.MWMapInput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                error(message('TLMGenerator:TLMTargetCC:RegInputParamMix',MemoryMapName,RegisterName));
            end

            if(numel(MWMap.MWMapOutput)~=0)&&(numel(MWMap.MWMapParam)~=0)
                error(message('TLMGenerator:TLMTargetCC:RegOutputParamMix',MemoryMapName,RegisterName));
            end

            Sock.Bank(BankNum).RegNum=int32(Sock.Bank(BankNum).RegNum+1);
            RegNum=Sock.Bank(BankNum).RegNum;
            Sock.Bank(BankNum).Reg(RegNum)=structInfoReg;
            Sock.Bank(BankNum).Reg(RegNum).Name=RegisterName;
            Sock.Bank(BankNum).Reg(RegNum).TypeName=[RegisterName,'_T'];
            Sock.Bank(BankNum).Reg(RegNum).Type='uint8_T';
            Sock.Bank(BankNum).Reg(RegNum).DimName=[RegisterName,'_DIM'];
            Sock.Bank(BankNum).Reg(RegNum).Dim=l_FindByteDimAlign(int32(idivide(RegisterSize,8,'ceil')));
            Sock.Bank(BankNum).Reg(RegNum).AddrName=[RegisterName,'_ADDR'];
            Sock.Bank(BankNum).Reg(RegNum).Addr=RegisterOffset;
            Sock.Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Sock.Bank(BankNum).Reg(RegNum).Addr);
            Sock.Bank(BankNum).Reg(RegNum).ByteDim=l_FindByteDimAlign(int32(idivide(RegisterSize,8,'ceil')));
            Sock.Bank(BankNum).Reg(RegNum).BitFieldNum=0;
            if strcmp(RegisterAccess,'read-only')||strcmp(RegisterAccess,'read-write')
                Sock.Bank(BankNum).Reg(RegNum).ReadAccess=true;
            end
            if strcmp(RegisterAccess,'write-only')||strcmp(RegisterAccess,'read-write')
                Sock.Bank(BankNum).Reg(RegNum).WriteAccess=true;
            end

            if(strcmp(ConfigInfo.tlmgSCMLOnOff,'on'))
                [type,byte]=l_FindSCMLType(Sock.Bank(BankNum).Reg(RegNum).ByteDim);
                Sock.Bank(BankNum).Reg(RegNum).SCMLType=type;
                Sock.Bank(BankNum).Reg(RegNum).SCMLByteDim=byte;
                if isempty(Sock.Bank(BankNum).Reg(RegNum).SCMLType)
                    error(message('TLMGenerator:TLMTargetCC:RegSCMLTypeNotFound',MemoryMapName,BlockName,RegisterName));
                end
            end


            if numel(MWMap.MWMapInput)~=0
                if Sock.Bank(BankNum).Reg(RegNum).WriteAccess==false
                    error(message('TLMGenerator:TLMTargetCC:InputReadOnly',MemoryMapName,RegisterName));
                end

                Sock.HasInput=true;
                Sock.Bank(BankNum).HasInput=true;
                Sock.Bank(BankNum).Reg(RegNum).IsInput=true;

                found=0;
                for jj=1:SystemInfo.InStruct.NumPorts
                    if strcmp(MWMap.MWMapInput{1},SystemInfo.InStruct.Port(jj).Name)
                        SystemInfo.InStruct.Port(jj).Mapped=int32(SystemInfo.InStruct.Port(jj).Mapped+1);
                        found=1;
                        break;
                    end
                end
                if found==0
                    error(message('TLMGenerator:TLMTargetCC:InputNotFound',MWMap.MWMapInput{1},MemoryMapName,RegisterName));
                end
                if int32(SystemInfo.InStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).ByteDim)
                    error(message('TLMGenerator:TLMTargetCC:RegInputSize',MemoryMapName,RegisterName,SystemInfo.InStruct.Port(jj).Name));
                end

                Sock.Bank(BankNum).Reg(RegNum).MW.InputName=SystemInfo.InStruct.Port(jj).Name;
                Sock.Bank(BankNum).Reg(RegNum).MW.InputPos=int32(jj-1);
                Sock.Bank(BankNum).Reg(RegNum).MW.InputType=SystemInfo.InStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).MW.InputDim=int32(SystemInfo.InStruct.Port(jj).Dim);

                Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.InStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.InStruct.Port(jj).Dim);
            end

            if numel(MWMap.MWMapOutput)~=0
                if Sock.Bank(BankNum).Reg(RegNum).ReadAccess==false
                    error(message('TLMGenerator:TLMTargetCC:OutputWriteOnly',MemoryMapName,RegisterName));
                end

                Sock.HasOutput=true;
                Sock.Bank(BankNum).HasOutput=true;
                Sock.Bank(BankNum).Reg(RegNum).IsOutput=true;

                found=0;
                for jj=1:SystemInfo.OutStruct.NumPorts
                    if strcmp(MWMap.MWMapOutput{1},SystemInfo.OutStruct.Port(jj).Name)
                        SystemInfo.OutStruct.Port(jj).Mapped=int32(SystemInfo.OutStruct.Port(jj).Mapped+1);
                        found=1;
                        break;
                    end
                end
                if found==0
                    error(message('TLMGenerator:TLMTargetCC:OutputNotFound',MWMap.MWMapOutput{1},MemoryMapName,RegisterName));
                end
                if int32(SystemInfo.OutStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).ByteDim)
                    error(message('TLMGenerator:TLMTargetCC:RegOutputSize',MemoryMapName,RegisterName,SystemInfo.OutStruct.Port(jj).Name));
                end

                Sock.Bank(BankNum).Reg(RegNum).MW.OutputName=SystemInfo.OutStruct.Port(jj).Name;
                Sock.Bank(BankNum).Reg(RegNum).MW.OutputPos=int32(jj-1);
                Sock.Bank(BankNum).Reg(RegNum).MW.OutputType=SystemInfo.OutStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).MW.OutputDim=int32(SystemInfo.OutStruct.Port(jj).Dim);

                Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.OutStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.OutStruct.Port(jj).Dim);
            end

            if numel(MWMap.MWMapParam)~=0
                Sock.HasParam=true;
                Sock.Bank(BankNum).HasParam=true;
                Sock.Bank(BankNum).Reg(RegNum).IsParam=true;

                found=0;
                for jj=1:SystemInfo.ParamStruct.NumPorts
                    if strcmp(MWMap.MWMapParam{1},SystemInfo.ParamStruct.Port(jj).Name)
                        SystemInfo.ParamStruct.Port(jj).Mapped=int32(SystemInfo.ParamStruct.Port(jj).Mapped+1);
                        found=1;
                        break;
                    end
                end
                if found==0
                    error(message('TLMGenerator:TLMTargetCC:ParamNotFound',MWMap.MWMapParam{1},MemoryMapName,RegisterName));
                end
                if int32(SystemInfo.ParamStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).ByteDim)
                    error(message('TLMGenerator:TLMTargetCC:RegParamSize',MemoryMapName,RegisterName,SystemInfo.ParamStruct.Port(jj).Name));
                end

                Sock.Bank(BankNum).Reg(RegNum).MW.ParamName=SystemInfo.ParamStruct.Port(jj).Name;
                Sock.Bank(BankNum).Reg(RegNum).MW.ParamPos=int32(jj-1);
                Sock.Bank(BankNum).Reg(RegNum).MW.ParamType=SystemInfo.ParamStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).MW.ParamDim=int32(SystemInfo.ParamStruct.Port(jj).Dim);

                Sock.Bank(BankNum).Reg(RegNum).Type=SystemInfo.ParamStruct.Port(jj).DataType;
                Sock.Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.ParamStruct.Port(jj).Dim);
            end

            fieldList=registerCurr.getElementsByTagName('spirit:field');

            for kk=0:fieldList.getLength-1
                fieldCurr=fieldList.item(kk);

                MWMap=l_FindMWMap(fieldCurr);
                if(strcmp(ConfigInfo.tlmgIPXactUnmapped,'off'))
                    if~MWMap.isMWMap
                        continue;
                    end
                end

                name=l_getFirstLevelUniqueElement(fieldCurr,'spirit:name');
                if numel(name)==0
                    l_me=MException('','In spirit:memoryMap %s spirit:register %s spirit:field without spirit:name',MemoryMapName,RegisterName);
                    throw(l_me);
                end
                FieldName=char(name.getFirstChild.getData);


                bitWidth=l_getFirstLevelUniqueElement(fieldCurr,'spirit:bitWidth');
                if numel(bitWidth)==0
                    l_me=MException('','In spirit:memoryMap %s spirit:register %s spirit:field %s without spirit:bitWidth',MemoryMapName,RegisterName,FieldName);
                    throw(l_me);
                end
                FieldBitWidth=int32(sscanf(char(bitWidth.getFirstChild.getData),'%i'));

                if FieldBitWidth<1
                    error(message('TLMGenerator:TLMTargetCC:BitFieldWidthMin',MemoryMapName,RegisterName,FieldName));
                end

                if FieldBitWidth>64
                    error(message('TLMGenerator:TLMTargetCC:BitFieldWidthMax',MemoryMapName,RegisterName,FieldName));
                end

                bitOffset=l_getFirstLevelUniqueElement(fieldCurr,'spirit:bitOffset');
                if numel(bitOffset)==0
                    l_me=MException('','In spirit:memoryMap %s spirit:register %s  spirit:field %s without spirit:bitOffset',MemoryMapName,RegisterName,FieldName);
                    throw(l_me);
                end
                FieldBitOffset=int32(sscanf(char(bitOffset.getFirstChild.getData),'%i'));

                if FieldBitOffset<0
                    error(message('TLMGenerator:TLMTargetCC:BitFieldOffsetMin',MemoryMapName,RegisterName,FieldName));
                end

                if(FieldBitOffset+FieldBitWidth)>RegisterSize
                    error(message('TLMGenerator:TLMTargetCC:BitFieldOutsideRegister',MemoryMapName,RegisterName,FieldName));
                end

                if(FieldBitWidth>57)&&(mod(FieldBitOffset,8)~=0)
                    error(message('TLMGenerator:TLMTargetCC:BitFieldOffsetAlign',MemoryMapName,RegisterName,FieldName));
                end

                if numel(MWMap.MWMapInput)>1
                    error(message('TLMGenerator:TLMTargetCC:BitFieldTooManyMWMapInput',MemoryMapName,RegisterName,FieldName));
                end
                if numel(MWMap.MWMapOutput)>1
                    error(message('TLMGenerator:TLMTargetCC:BitFieldTooManyMWMapOutput',MemoryMapName,RegisterName,FieldName));
                end
                if numel(MWMap.MWMapParam)>1
                    error(message('TLMGenerator:TLMTargetCC:BitFieldTooManyMWMapParam',MemoryMapName,RegisterName,FieldName));
                end


                Sock.Bank(BankNum).Reg(RegNum).BitFieldNum=int32(Sock.Bank(BankNum).Reg(RegNum).BitFieldNum+1);
                BitFieldNum=Sock.Bank(BankNum).Reg(RegNum).BitFieldNum;
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum)=structInfoBitField;
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Name=[RegisterName,'_',FieldName];
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).TypeName=[RegisterName,'_',FieldName,'_T'];
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).DimName=[RegisterName,'_',FieldName,'_DIM'];
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitOffsetName=[RegisterName,'_',FieldName,'_OFFSET'];
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitOffset=FieldBitOffset;
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).ByteOffset=int32(idivide(FieldBitOffset,8,'floor'));
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitWidthName=[RegisterName,'_',FieldName,'_WIDTH'];
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitWidth=FieldBitWidth;
                Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).ByteDim=l_FindByteDimAlign(int32(idivide(FieldBitWidth,8,'ceil')));

                if numel(MWMap.MWMapInput)~=0
                    if Sock.Bank(BankNum).Reg(RegNum).WriteAccess==false
                        error(message('TLMGenerator:TLMTargetCC:InputReadOnly',MemoryMapName,RegisterName));
                    end

                    Sock.HasInput=true;
                    Sock.Bank(BankNum).HasInput=true;
                    Sock.Bank(BankNum).Reg(RegNum).IsInput=true;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsInput=true;

                    found=0;
                    for jj=1:SystemInfo.InStruct.NumPorts
                        if strcmp(MWMap.MWMapInput{1},SystemInfo.InStruct.Port(jj).Name)
                            SystemInfo.InStruct.Port(jj).Mapped=int32(SystemInfo.InStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:BitFieldInputNotFound',MWMap.MWMapInput{1},MemoryMapName,RegisterName,FieldName));
                    end

                    if int32(SystemInfo.InStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).ByteDim)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldInputSize',MemoryMapName,RegisterName,FieldName,SystemInfo.InStruct.Port(jj).Name));
                    end
                    if int32(SystemInfo.InStruct.Port(jj).BitWidth)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitWidth)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldInputSize',MemoryMapName,RegisterName,FieldName,SystemInfo.InStruct.Port(jj).Name));
                    end
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.InputName=SystemInfo.InStruct.Port(jj).Name;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.InputPos=int32(jj-1);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.InputType=SystemInfo.InStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.InputDim=int32(SystemInfo.InStruct.Port(jj).Dim);

                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Type=SystemInfo.InStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Dim=int32(SystemInfo.InStruct.Port(jj).Dim);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=false;

                    if SystemInfo.InStruct.Port(jj).Signed&&...
                        (SystemInfo.InStruct.Port(jj).ByteDim*8>SystemInfo.InStruct.Port(jj).BitWidth)&&...
                        SystemInfo.InStruct.Port(jj).Dim==1
                        Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=true;
                    end
                end

                if numel(MWMap.MWMapOutput)~=0
                    if Sock.Bank(BankNum).Reg(RegNum).ReadAccess==false
                        error(message('TLMGenerator:TLMTargetCC:OutputWriteOnly',MemoryMapName,RegisterName));
                    end

                    Sock.HasOutput=true;
                    Sock.Bank(BankNum).HasOutput=true;
                    Sock.Bank(BankNum).Reg(RegNum).IsOutput=true;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsOutput=true;

                    found=0;
                    for jj=1:SystemInfo.OutStruct.NumPorts
                        if strcmp(MWMap.MWMapOutput{1},SystemInfo.OutStruct.Port(jj).Name)
                            SystemInfo.OutStruct.Port(jj).Mapped=int32(SystemInfo.OutStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:BitFieldOutputNotFound',MWMap.MWMapOutput{1},MemoryMapName,RegisterName,FieldName));
                    end

                    if int32(SystemInfo.OutStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).ByteDim)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldOutputSize',MemoryMapName,RegisterName,FieldName,SystemInfo.OutStruct.Port(jj).Name));
                    end
                    if int32(SystemInfo.OutStruct.Port(jj).BitWidth)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitWidth)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldOutputSize',MemoryMapName,RegisterName,FieldName,SystemInfo.OutStruct.Port(jj).Name));
                    end

                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.OutputName=SystemInfo.OutStruct.Port(jj).Name;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.OutputPos=int32(jj-1);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.OutputType=SystemInfo.OutStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.OutputDim=int32(SystemInfo.OutStruct.Port(jj).Dim);

                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Type=SystemInfo.OutStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Dim=int32(SystemInfo.OutStruct.Port(jj).Dim);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=false;
                    if SystemInfo.OutStruct.Port(jj).Signed&&...
                        (SystemInfo.OutStruct.Port(jj).ByteDim*8>SystemInfo.OutStruct.Port(jj).BitWidth)&&...
                        SystemInfo.OutStruct.Port(jj).Dim==1
                        Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=true;
                    end
                end

                if numel(MWMap.MWMapParam)~=0
                    Sock.HasParam=true;
                    Sock.Bank(BankNum).HasParam=true;
                    Sock.Bank(BankNum).Reg(RegNum).IsParam=true;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsParam=true;

                    found=0;
                    for jj=1:SystemInfo.ParamStruct.NumPorts
                        if strcmp(MWMap.MWMapParam{1},SystemInfo.ParamStruct.Port(jj).Name)
                            SystemInfo.ParamStruct.Port(jj).Mapped=int32(SystemInfo.ParamStruct.Port(jj).Mapped+1);
                            found=1;
                            break;
                        end
                    end
                    if found==0
                        error(message('TLMGenerator:TLMTargetCC:BitFieldParamNotFound',MWMap.MWMapParam{1},MemoryMapName,RegisterName,FieldName));
                    end

                    if int32(SystemInfo.ParamStruct.Port(jj).ByteDim)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).ByteDim)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldParamSize',MemoryMapName,RegisterName,FieldName,SystemInfo.ParamStruct.Port(jj).Name));
                    end
                    if int32(SystemInfo.ParamStruct.Port(jj).BitWidth)~=int32(Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).BitWidth)
                        error(message('TLMGenerator:TLMTargetCC:BitFieldParamSize',MemoryMapName,RegisterName,FieldName,SystemInfo.ParamStruct.Port(jj).Name));
                    end
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.ParamName=SystemInfo.ParamStruct.Port(jj).Name;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.ParamPos=int32(jj-1);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.ParamType=SystemInfo.ParamStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).MW.ParamDim=int32(SystemInfo.ParamStruct.Port(jj).Dim);

                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Type=SystemInfo.ParamStruct.Port(jj).DataType;
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).Dim=int32(SystemInfo.ParamStruct.Port(jj).Dim);
                    Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=false;
                    if SystemInfo.ParamStruct.Port(jj).Signed&&...
                        (SystemInfo.ParamStruct.Port(jj).ByteDim*8>SystemInfo.ParamStruct.Port(jj).BitWidth)&&...
                        SystemInfo.ParamStruct.Port(jj).Dim==1
                        Sock.Bank(BankNum).Reg(RegNum).BitField(BitFieldNum).IsSignExt=true;
                    end
                end
            end

        end
    end

    MaxAddr=int32(-1);
    for kk=1:Sock.BankNum
        if Sock.Bank(kk).Addr>MaxAddr
            Sock.ByteDim=int32(Sock.Bank(kk).Addr+Sock.Bank(kk).ByteDim);
            MaxAddr=Sock.Bank(kk).Addr;
        end
    end
    Sock.ByteDim=idivide(Sock.ByteDim,Sock.ByteWidth,'ceil')*Sock.ByteWidth;
end

