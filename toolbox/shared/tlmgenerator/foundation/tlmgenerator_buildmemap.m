function Mapping=tlmgenerator_buildmemap(SystemInfo,ConfigInfo)


    try
        structInfoMW=struct('InputName','',...
        'InputPos',int32(0),...
        'InputType','',...
        'InputDim','',...
        'OutputName','',...
        'OutputPos',int32(0),...
        'OutputType','',...
        'OutputDim','',...
        'ParamName','',...
        'ParamPos',int32(0),...
        'ParamType','',...
        'ParamDim','');

        structInfoBitField=struct('Name','',...
        'MW',structInfoMW,...
        'TypeName','',...
        'Type','',...
        'DimName','',...
        'Dim',int32(0),...
        'BitOffsetName','',...
        'BitOffset',int32(0),...
        'ByteOffset',int32(0),...
        'BitWidthName','',...
        'BitWidth',int32(0),...
        'ByteDim',int32(0),...
        'IsInput',false,...
        'IsOutput',false,...
        'IsParam',false,...
        'IsSignExt',false);

        structInfoReg=struct('Name','',...
        'MW',structInfoMW,...
        'TypeName','',...
        'Type','',...
        'DimName','',...
        'Dim',int32(0),...
        'AddrName','',...
        'Addr',int32(0),...
        'AddrHexStr','',...
        'ByteDim',int32(0),...
        'SCMLType','',...
        'SCMLByteDim',int32(0),...
        'ReadAccess',false,...
        'WriteAccess',false,...
        'IsInput',false,...
        'IsOutput',false,...
        'IsParam',false,...
        'BitFieldNum',int32(0),...
        'BitField',structInfoBitField);

        structInfoBank=struct('Name','',...
        'TypeName','',...
        'Type','',...
        'DimName','',...
        'Dim',int32(0),...
        'AddrName','',...
        'Addr',int32(0),...
        'AddrHexStr','',...
        'ByteDim',int32(0),...
        'HasInput',false,...
        'HasOutput',false,...
        'HasParam',false,...
        'RegNumName','',...
        'RegNum',int32(0),...
        'Reg',structInfoReg);




        structSocket=struct('Name','',...
        'SockName','',...
        'BitWidth',int32(32),...
        'ByteWidth',int32(4),...
        'SCMLType','uint32_T',...
        'SCMLByteDim',int32(4),...
        'HasAddress',false,...
        'HasRegister',false,...
        'HasInput',false,...
        'HasOutput',false,...
        'HasParam',false,...
        'BankNumName','',...
        'BankNum',int32(0),...
        'Bank',structInfoBank,...
        'HasTestSet',false,...
        'TestSetBank',structInfoBank,...
        'HasComStat',false,...
        'ComStatBank',structInfoBank,...
        'ByteDim',int32(0));

        structPort=struct('Name','',...
        'PortName','',...
        'MW',structInfoMW,...
        'TypeName','',...
        'Type','',...
        'DimName','',...
        'Dim',int32(0),...
        'ByteDim',int32(0),...
        'ReadAccess',false,...
        'WriteAccess',false,...
        'IsInput',false,...
        'IsOutput',false,...
        'IsParam',false);

        Mapping=struct('SockNum',int32(0),...
        'SockList',structSocket,...
        'PortNum',int32(0),...
        'PortList',structPort);

        if SystemInfo.InStruct.NumPorts
            if iscell(SystemInfo.InStruct.Port)
                SystemInfo.InStruct.Port=cell2mat(SystemInfo.InStruct.Port);
            end
        end

        if SystemInfo.OutStruct.NumPorts
            if iscell(SystemInfo.OutStruct.Port)
                SystemInfo.OutStruct.Port=cell2mat(SystemInfo.OutStruct.Port);
            end
        end

        if SystemInfo.ParamStruct.NumPorts
            if iscell(SystemInfo.ParamStruct.Port)
                SystemInfo.ParamStruct.Port=cell2mat(SystemInfo.ParamStruct.Port);
            end
        end

        if strcmp(ConfigInfo.tlmgComponentSocketMapping,'One combined TLM socket for input data, output data, and control')
            Mapping.SockNum=int32(1);
            Mapping.SockList(1)=structSocket;
            Mapping.SockList(1).Name='combined';
            Mapping.SockList(1).SockName='m_socket_combined';
            Mapping.SockList(1).BitWidth=int32(32);
            Mapping.SockList(1).ByteWidth=int32(4);
            if~strcmp(ConfigInfo.tlmgComponentAddressing,'No memory map')
                Mapping.SockList(1).HasAddress=true;
                if~strcmp(ConfigInfo.tlmgAutoAddressSpecType,'Single input and output address offsets')
                    Mapping.SockList(1).HasRegister=true;
                end
            end

            if SystemInfo.InStruct.NumPorts
                Mapping.SockList(1).HasInput=true;
            end
            if SystemInfo.OutStruct.NumPorts
                Mapping.SockList(1).HasOutput=true;
            end
            if SystemInfo.ParamStruct.NumPorts
                if(strcmp(ConfigInfo.tlmgTunableParamRegOnOffInoutput,'on'))
                    Mapping.SockList(1).HasParam=true;
                end
            end
            if(strcmp(ConfigInfo.tlmgTestAndSetRegOnOffInoutput,'on'))
                Mapping.SockList(1).HasTestSet=true;
            end
            if(strcmp(ConfigInfo.tlmgCommandStatusRegOnOffInoutput,'on'))
                Mapping.SockList(1).HasComStat=true;
            end

        elseif strcmp(ConfigInfo.tlmgComponentSocketMapping,'Three separate TLM sockets for input data, output data, and control')
            Mapping.SockNum=int32(0);
            if SystemInfo.InStruct.NumPorts
                Mapping.SockNum=int32(Mapping.SockNum+1);
                Mapping.SockList(Mapping.SockNum)=structSocket;
                Mapping.SockList(Mapping.SockNum).Name='input';
                Mapping.SockList(Mapping.SockNum).SockName='m_socket_input';
                Mapping.SockList(Mapping.SockNum).BitWidth=int32(32);
                Mapping.SockList(Mapping.SockNum).ByteWidth=int32(4);
                Mapping.SockList(Mapping.SockNum).HasInput=true;
                if~strcmp(ConfigInfo.tlmgComponentAddressingInput,'No memory map')
                    Mapping.SockList(Mapping.SockNum).HasAddress=true;
                    if~strcmp(ConfigInfo.tlmgAutoAddressSpecTypeInput,'Single input and output address offsets')
                        Mapping.SockList(Mapping.SockNum).HasRegister=true;
                    end
                end
            end
            if SystemInfo.OutStruct.NumPorts
                Mapping.SockNum=int32(Mapping.SockNum+1);
                Mapping.SockList(Mapping.SockNum)=structSocket;
                Mapping.SockList(Mapping.SockNum).Name='output';
                Mapping.SockList(Mapping.SockNum).SockName='m_socket_output';
                Mapping.SockList(Mapping.SockNum).BitWidth=int32(32);
                Mapping.SockList(Mapping.SockNum).ByteWidth=int32(4);
                Mapping.SockList(Mapping.SockNum).HasOutput=true;
                if~strcmp(ConfigInfo.tlmgComponentAddressingOutput,'No memory map')
                    Mapping.SockList(Mapping.SockNum).HasAddress=true;
                    if~strcmp(ConfigInfo.tlmgAutoAddressSpecTypeOutput,'Single input and output address offsets')
                        Mapping.SockList(Mapping.SockNum).HasRegister=true;
                    end
                end
            end

            if(strcmp(ConfigInfo.tlmgTunableParamRegOnOffInoutput,'on')||...
                strcmp(ConfigInfo.tlmgTestAndSetRegOnOffInoutput,'on')||...
                strcmp(ConfigInfo.tlmgCommandStatusRegOnOffInoutput,'on'))
                Mapping.SockNum=int32(Mapping.SockNum+1);
                Mapping.SockList(Mapping.SockNum)=structSocket;
                Mapping.SockList(Mapping.SockNum).Name='ctrl';
                Mapping.SockList(Mapping.SockNum).SockName='m_socket_ctrl';
                Mapping.SockList(Mapping.SockNum).BitWidth=int32(32);
                Mapping.SockList(Mapping.SockNum).ByteWidth=int32(4);
                Mapping.SockList(Mapping.SockNum).HasAddress=true;
                Mapping.SockList(Mapping.SockNum).HasRegister=true;

                if SystemInfo.ParamStruct.NumPorts
                    if(strcmp(ConfigInfo.tlmgTunableParamRegOnOffInoutput,'on'))
                        Mapping.SockList(Mapping.SockNum).HasParam=true;
                    end
                end
                if(strcmp(ConfigInfo.tlmgTestAndSetRegOnOffInoutput,'on'))
                    Mapping.SockList(Mapping.SockNum).HasTestSet=true;
                end
                if(strcmp(ConfigInfo.tlmgCommandStatusRegOnOffInoutput,'on'))
                    Mapping.SockList(Mapping.SockNum).HasComStat=true;
                end
            end
        elseif(strcmp(ConfigInfo.tlmgComponentSocketMapping,'Defined by imported IP-XACT file'))
            Mapping=tlmgenerator_ipxactparser(SystemInfo,ConfigInfo,Mapping,structSocket,structInfoBank,structInfoReg,structInfoBitField,structPort);

            if(strcmp(ConfigInfo.tlmgProcessingType,'Callback Function')&&Mapping.PortNum~=0)
                warnsiginputonly=1;
                for ii=1:Mapping.SockNum
                    if Mapping.SockList(ii).HasInput
                        warnsiginputonly=0;
                        break;
                    end
                end
                if warnsiginputonly
                    warning(message('TLMGenerator:TLMTargetCC:SigInputOnly',ConfigInfo.tlmgProcessingType));
                end
            end


            return;
        end


        for SockNum=1:Mapping.SockNum
            BankAddr=int32(0);

            if Mapping.SockList(SockNum).HasInput==true
                try
                    RegAddr=int32(0);
                    Mapping.SockList(SockNum).BankNum=int32(Mapping.SockList(SockNum).BankNum+1);
                    BankNum=Mapping.SockList(SockNum).BankNum;
                    Mapping.SockList(SockNum).Bank(BankNum)=structInfoBank;
                    Mapping.SockList(SockNum).Bank(BankNum).HasInput=true;
                    Mapping.SockList(SockNum).Bank(BankNum).Name=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_IN_BANK'];
                    Mapping.SockList(SockNum).Bank(BankNum).TypeName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_IN_BANK_T'];
                    Mapping.SockList(SockNum).Bank(BankNum).Type='struct';
                    Mapping.SockList(SockNum).Bank(BankNum).DimName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_IN_BANK_DIM'];
                    Mapping.SockList(SockNum).Bank(BankNum).Dim=int32(1);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_IN_BANK_ADDR'];
                    Mapping.SockList(SockNum).Bank(BankNum).Addr=int32(BankAddr);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Addr);
                    Mapping.SockList(SockNum).Bank(BankNum).RegNumName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_IN_REG_NUM'];
                    for i=1:SystemInfo.InStruct.NumPorts
                        try
                            Mapping.SockList(SockNum).Bank(BankNum).RegNum=int32(Mapping.SockList(SockNum).Bank(BankNum).RegNum+1);
                            RegNum=Mapping.SockList(SockNum).Bank(BankNum).RegNum;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum)=structInfoReg;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).IsInput=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).WriteAccess=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Name=[SystemInfo.InStruct.Port(i).Name,'_REG'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.InputName=SystemInfo.InStruct.Port(i).Name;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.InputPos=int32(i-1);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.InStruct.Port(i).Name,'_REG_T'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Type=SystemInfo.InStruct.Port(i).DataType;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.InStruct.Port(i).Name,'_REG_DIM'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.InStruct.Port(i).Dim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.InStruct.Port(i).Name,'_REG_ADDR'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr=int32(RegAddr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.InStruct.Port(i).ByteDim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
                            RegAddr=idivide(RegAddr+Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
                            SystemInfo.InStruct.Port(i).Mapped=int32(SystemInfo.InStruct.Port(i).Mapped+1);
                        catch ME
                            l_me=MException('','reg %s: %s',SystemInfo.InStruct.Port(i).Name,ME.message);
                            throw(l_me);
                        end
                    end
                    Mapping.SockList(SockNum).Bank(BankNum).ByteDim=int32(RegAddr);
                    BankAddr=BankAddr+Mapping.SockList(SockNum).Bank(BankNum).ByteDim;
                catch ME
                    l_me=MException('','building input %s',ME.message);
                    throw(l_me);
                end
            end


            if Mapping.SockList(SockNum).HasOutput==true
                try
                    RegAddr=int32(0);
                    Mapping.SockList(SockNum).BankNum=int32(Mapping.SockList(SockNum).BankNum+1);
                    BankNum=Mapping.SockList(SockNum).BankNum;
                    Mapping.SockList(SockNum).Bank(BankNum)=structInfoBank;
                    Mapping.SockList(SockNum).Bank(BankNum).HasOutput=true;
                    Mapping.SockList(SockNum).Bank(BankNum).Name=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_OUT_BANK'];
                    Mapping.SockList(SockNum).Bank(BankNum).TypeName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_OUT_BANK_T'];
                    Mapping.SockList(SockNum).Bank(BankNum).Type='struct';
                    Mapping.SockList(SockNum).Bank(BankNum).DimName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_OUT_BANK_DIM'];
                    Mapping.SockList(SockNum).Bank(BankNum).Dim=int32(1);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_OUT_BANK_ADDR'];
                    Mapping.SockList(SockNum).Bank(BankNum).Addr=int32(BankAddr);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Addr);
                    Mapping.SockList(SockNum).Bank(BankNum).RegNumName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_OUT_REG_NUM'];
                    for i=1:SystemInfo.OutStruct.NumPorts
                        try
                            Mapping.SockList(SockNum).Bank(BankNum).RegNum=int32(Mapping.SockList(SockNum).Bank(BankNum).RegNum+1);
                            RegNum=Mapping.SockList(SockNum).Bank(BankNum).RegNum;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum)=structInfoReg;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).IsOutput=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ReadAccess=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Name=[SystemInfo.OutStruct.Port(i).Name,'_REG'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.OutputName=SystemInfo.OutStruct.Port(i).Name;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.OutputPos=int32(i-1);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.OutStruct.Port(i).Name,'_REG_T'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Type=SystemInfo.OutStruct.Port(i).DataType;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.OutStruct.Port(i).Name,'_REG_DIM'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.OutStruct.Port(i).Dim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.OutStruct.Port(i).Name,'_REG_ADDR'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr=int32(RegAddr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.OutStruct.Port(i).ByteDim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
                            RegAddr=idivide(RegAddr+Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
                            SystemInfo.OutStruct.Port(i).Mapped=int32(SystemInfo.OutStruct.Port(i).Mapped+1);
                        catch ME
                            l_me=MException('','reg %s: %s',SystemInfo.OutStruct.Port(i).Name,ME.message);
                            throw(l_me);
                        end
                    end
                    Mapping.SockList(SockNum).Bank(BankNum).ByteDim=int32(RegAddr);
                    BankAddr=BankAddr+Mapping.SockList(SockNum).Bank(BankNum).ByteDim;
                catch ME
                    l_me=MException('','building output %s',ME.message);
                    throw(l_me);
                end
            end



            if Mapping.SockList(SockNum).HasParam==true
                try
                    RegAddr=int32(0);
                    Mapping.SockList(SockNum).BankNum=int32(Mapping.SockList(SockNum).BankNum+1);
                    BankNum=Mapping.SockList(SockNum).BankNum;
                    Mapping.SockList(SockNum).Bank(BankNum)=structInfoBank;
                    Mapping.SockList(SockNum).Bank(BankNum).HasParam=true;
                    Mapping.SockList(SockNum).Bank(BankNum).Name=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_PARAM_BANK'];
                    Mapping.SockList(SockNum).Bank(BankNum).TypeName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_PARAM_BANK_T'];
                    Mapping.SockList(SockNum).Bank(BankNum).Type='struct';
                    Mapping.SockList(SockNum).Bank(BankNum).DimName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_PARAM_BANK_DIM'];
                    Mapping.SockList(SockNum).Bank(BankNum).Dim=int32(1);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_PARAM_BANK_ADDR'];
                    Mapping.SockList(SockNum).Bank(BankNum).Addr=int32(BankAddr);
                    Mapping.SockList(SockNum).Bank(BankNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Addr);
                    Mapping.SockList(SockNum).Bank(BankNum).RegNumName=[SystemInfo.Name,'_',Mapping.SockList(SockNum).Name,'_PARAM_REG_NUM'];
                    for i=1:SystemInfo.ParamStruct.NumPorts
                        try
                            Mapping.SockList(SockNum).Bank(BankNum).RegNum=int32(Mapping.SockList(SockNum).Bank(BankNum).RegNum+1);
                            RegNum=Mapping.SockList(SockNum).Bank(BankNum).RegNum;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum)=structInfoReg;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).IsParam=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ReadAccess=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).WriteAccess=true;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Name=[SystemInfo.ParamStruct.Port(i).Name,'_REG'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.ParamName=SystemInfo.ParamStruct.Port(i).Name;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).MW.ParamPos=int32(i-1);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).TypeName=[SystemInfo.ParamStruct.Port(i).Name,'_REG_T'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Type=SystemInfo.ParamStruct.Port(i).DataType;
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).DimName=[SystemInfo.ParamStruct.Port(i).Name,'_REG_DIM'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Dim=int32(SystemInfo.ParamStruct.Port(i).Dim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrName=[SystemInfo.ParamStruct.Port(i).Name,'_REG_ADDR'];
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr=int32(RegAddr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).Addr);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim=int32(SystemInfo.ParamStruct.Port(i).ByteDim);
                            Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).BitFieldNum=int32(0);
                            RegAddr=idivide(RegAddr+Mapping.SockList(SockNum).Bank(BankNum).Reg(RegNum).ByteDim,4,'ceil')*4;
                            SystemInfo.ParamStruct.Port(i).Mapped=int32(SystemInfo.ParamStruct.Port(i).Mapped+1);
                        catch ME
                            l_me=MException('','reg %s: %s',SystemInfo.ParamStruct.Port(i).Name,ME.message);
                            throw(l_me);
                        end
                    end
                    Mapping.SockList(SockNum).Bank(BankNum).ByteDim=int32(RegAddr);
                    BankAddr=BankAddr+Mapping.SockList(SockNum).Bank(BankNum).ByteDim;

                catch ME
                    l_me=MException('','building reg tunable param reg: %s',ME.message);
                    throw(l_me);
                end
            end

            if Mapping.SockList(SockNum).HasTestSet==true
                try
                    RegAddr=int32(0);
                    Mapping.SockList(SockNum).TestSetBank=structInfoBank;
                    Mapping.SockList(SockNum).TestSetBank.Name=[SystemInfo.Name,'_TESTSET_BANK'];
                    Mapping.SockList(SockNum).TestSetBank.TypeName=[SystemInfo.Name,'_testset_bank_T'];
                    Mapping.SockList(SockNum).TestSetBank.Type='uint32_T';
                    Mapping.SockList(SockNum).TestSetBank.DimName=[SystemInfo.Name,'_TESTSET_BANK_DIM'];
                    Mapping.SockList(SockNum).TestSetBank.Dim=int32(1);
                    Mapping.SockList(SockNum).TestSetBank.AddrName=[SystemInfo.Name,'_TESTSET_BANK_ADDR'];
                    Mapping.SockList(SockNum).TestSetBank.Addr=int32(BankAddr);
                    Mapping.SockList(SockNum).TestSetBank.AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).TestSetBank.Addr);
                    Mapping.SockList(SockNum).TestSetBank.RegNumName=[SystemInfo.Name,'_TESTSET_REG_NUM'];
                    Mapping.SockList(SockNum).TestSetBank.RegNum=int32(1);

                    Mapping.SockList(SockNum).TestSetBank.Reg(1)=structInfoReg;
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).ReadAccess=true;
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).WriteAccess=true;
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).Name=[SystemInfo.Name,'_TESTSET_REG'];
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).TypeName=[SystemInfo.Name,'_testset_reg_T'];
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).Type='uint32_T';
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).DimName=[SystemInfo.Name,'_TESTSET_REG_DIM'];
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).Dim=int32(1);
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).AddrName=[SystemInfo.Name,'_TESTSET_REG_ADDR'];
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).Addr=int32(RegAddr);
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).TestSetBank.Reg(1).Addr);
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).ByteDim=int32(4);
                    Mapping.SockList(SockNum).TestSetBank.Reg(1).BitFieldNum=int32(0);
                    RegAddr=idivide(RegAddr+Mapping.SockList(SockNum).TestSetBank.Reg(1).ByteDim,4,'ceil')*4;

                    Mapping.SockList(SockNum).TestSetBank.ByteDim=int32(RegAddr);
                    BankAddr=BankAddr+Mapping.SockList(SockNum).TestSetBank.ByteDim;
                catch ME
                    l_me=MException('','building reg test&set reg: %s',ME.message);
                    throw(l_me);
                end
            end

            if Mapping.SockList(SockNum).HasComStat==true
                try
                    RegAddr=int32(0);
                    Mapping.SockList(SockNum).ComStatBank=structInfoBank;
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).ReadAccess=true;
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).WriteAccess=true;
                    Mapping.SockList(SockNum).ComStatBank.Name=[SystemInfo.Name,'_COMSTAT_BANK'];
                    Mapping.SockList(SockNum).ComStatBank.TypeName=[SystemInfo.Name,'_comstat_bank_T'];
                    Mapping.SockList(SockNum).ComStatBank.Type='uint32_T';
                    Mapping.SockList(SockNum).ComStatBank.DimName=[SystemInfo.Name,'_COMSTAT_BANK_DIM'];
                    Mapping.SockList(SockNum).ComStatBank.Dim=int32(1);
                    Mapping.SockList(SockNum).ComStatBank.AddrName=[SystemInfo.Name,'_COMSTAT_BANK_ADDR'];
                    Mapping.SockList(SockNum).ComStatBank.Addr=int32(BankAddr);
                    Mapping.SockList(SockNum).ComStatBank.AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).ComStatBank.Addr);
                    Mapping.SockList(SockNum).ComStatBank.RegNumName=[SystemInfo.Name,'_COMSTAT_REG_NUM'];
                    Mapping.SockList(SockNum).ComStatBank.RegNum=int32(1);

                    Mapping.SockList(SockNum).ComStatBank.Reg(1)=structInfoReg;
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).Name=[SystemInfo.Name,'_COMSTAT_REG'];
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).TypeName=[SystemInfo.Name,'_comstat_reg_T'];
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).Type='uint32_T';
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).DimName=[SystemInfo.Name,'_COMSTAT_REG_DIM'];
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).Dim=int32(1);
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).AddrName=[SystemInfo.Name,'_COMSTAT_REG_ADDR'];
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).Addr=int32(RegAddr);
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).AddrHexStr=sprintf('0x%08X',Mapping.SockList(SockNum).ComStatBank.Reg(1).Addr);
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).ByteDim=int32(4);
                    Mapping.SockList(SockNum).ComStatBank.Reg(1).BitFieldNum=int32(0);
                    RegAddr=idivide(RegAddr+Mapping.SockList(SockNum).ComStatBank.Reg(1).ByteDim,4,'ceil')*4;

                    Mapping.SockList(SockNum).ComStatBank.ByteDim=int32(RegAddr);
                    BankAddr=BankAddr+Mapping.SockList(SockNum).ComStatBank.ByteDim;
                catch ME
                    l_me=MException('','building command&status reg: %s',ME.message);
                    throw(l_me);
                end
            end
        end



    catch ME
        l_me=MException('TLMGenerator:build','TLMG buildmemap: %s',ME.message);
        Mapping=struct([]);
        setappdata(0,'tlmgME',l_me.message);
        throw(l_me);
    end

end

