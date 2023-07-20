classdef HDLCodeInfo<handle




    properties(Access=protected)
        m_HDLCoderCtx;
        m_Pir;
        m_TopNtwk;
        m_CodeInfo;
    end

    methods







        function this=HDLCodeInfo(Ctx)
            this.m_HDLCoderCtx=Ctx;
            this.m_Pir=pir(Ctx.ModelName);
            this.m_TopNtwk=this.m_Pir.getTopNetwork;
            this.m_CodeInfo=RTW.ComponentInterface;
        end






        function build(this)
            this.m_CodeInfo.Name=this.m_TopNtwk.Name;
            this.setClocks;
            this.setTiming;
            this.setInputs;
            this.setOutputs;

        end






        function publish(this)
            codeInfo=this.m_CodeInfo;%#ok
            dir=this.m_HDLCoderCtx.hdlGetCodegendir;
            save(fullfile(dir,'codeInfo.mat'),'codeInfo');
        end







        function setClocks(this)
            ClockPorts=this.m_TopNtwk.getInputPorts('clock');
            ResetPorts=this.m_TopNtwk.getInputPorts('reset');
            ClockEnPorts=this.m_TopNtwk.getInputPorts('clock_enable');

            if isempty(ClockPorts)
                return;
            end

            ClockTbl=this.get2DClockTable();
            gp=pir;
            ClockRpt=gp.getClockReportData;

            for ii=1:length(ClockTbl(:,1))
                HDLClockInt(ii)=RTW.HDLClockInterface;%#ok<*AGROW>
                for jj=1:length(ClockTbl(ii,:))
                    if isempty(ClockTbl{ii,jj})
                        break;
                    end

                    if ClockTbl{ii,jj}.Kind==0

                        for kk=1:length(ClockPorts)
                            ClockPort=ClockPorts(kk);
                            if strcmp(ClockPort.Name,ClockTbl{ii,jj}.Name)


                                HDLClockInt(ii).Period=ClockTbl{ii,jj}.Ratio*ClockRpt.modelBaseRate;
                                ClockPortInfo=pirgetdatatypeinfo(ClockPort.Signal.Type);
                                ClockPortInfo.hdltype=ClockPort.Signal.VType;
                                ClockTypeProp=this.addHDLTypeProp(ClockPortInfo);
                                ClockImpl=RTW.Variable(ClockTypeProp,...
                                ClockPort.Name,this.m_TopNtwk.Name);
                                HDLClockInt(ii).Clock=ClockImpl;
                                break;
                            end
                        end

                    elseif ClockTbl{ii,jj}.Kind==1

                        for kk=1:length(ResetPorts)
                            ResetPort=ResetPorts(kk);
                            if strcmp(ResetPort.Name,ClockTbl{ii,jj}.Name)
                                ResetPortInfo=pirgetdatatypeinfo(ResetPort.Signal.Type);
                                ResetPortInfo.hdltype=ResetPort.Signal.VType;
                                ResetTypeProp=this.addHDLTypeProp(ResetPortInfo);
                                ResetImpl=RTW.Variable(ResetTypeProp,...
                                ResetPort.Name,this.m_TopNtwk.Name);
                                HDLClockInt(ii).Reset=ResetImpl;
                                break;
                            end
                        end


                    elseif ClockTbl{ii,jj}.Kind==2

                        for kk=1:length(ClockEnPorts)
                            ClockEnPort=ClockEnPorts(kk);
                            if strcmp(ClockEnPort.Name,ClockTbl{ii,jj}.Name)
                                ClockEnPortInfo=pirgetdatatypeinfo(ClockEnPort.Signal.Type);
                                ClockEnPortInfo.hdltype=ClockEnPort.Signal.VType;
                                ClockEnTypeProp=this.addHDLTypeProp(ClockEnPortInfo);
                                ClockEnImpl=RTW.Variable(ClockEnTypeProp,...
                                ClockEnPort.Name,this.m_TopNtwk.Name);
                                HDLClockInt(ii).ClockEnable=ClockEnImpl;
                                break;
                            end
                        end

                    end

                end
            end


            this.m_CodeInfo.ClockProperties=HDLClockInt;

        end







        function setTiming(this)
            gp=pir;
            ClockRpt=gp.getClockReportData;
            ClockEnPorts=this.m_TopNtwk.getOutputPorts('clock_enable');

            for ii=1:length(ClockRpt.clockData)
                TimeProp=RTW.HDLTimingInterface;
                TimeProp.TimingMode='PERIODIC';
                TimeProp.SamplePeriod=ClockRpt.clockData(ii).sampleTime;
                if ClockRpt.clockData(ii).ratio==-1

                    TimeProp.BaseRateRatio=ClockRpt.clockData(ii).sampleTime/ClockRpt.modelBaseRate;
                else
                    TimeProp.BaseRateRatio=ClockRpt.clockData(ii).ratio;
                end




                if length(this.m_CodeInfo.ClockProperties)==1
                    TimeProp.Clock=this.m_CodeInfo.ClockProperties;
                    ll=length(this.m_CodeInfo.ClockProperties.Timing)+1;
                    if ll==1
                        this.m_CodeInfo.ClockProperties.Timing=TimeProp;
                    else
                        this.m_CodeInfo.ClockProperties.Timing(ll)=TimeProp;
                    end

                elseif length(this.m_CodeInfo.ClockProperties)>1
                    for jj=1:length(this.m_CodeInfo.ClockProperties)


                        if strcmp(this.m_CodeInfo.ClockProperties(jj).Clock.Identifier,...
                            ClockRpt.clockData(ii).name)
                            TimeProp.Clock=this.m_CodeInfo.ClockProperties(jj);
                            ll=length(this.m_CodeInfo.ClockProperties(jj).Timing)+1;
                            if ll==1
                                this.m_CodeInfo.ClockProperties(jj).Timing=TimeProp;
                            else
                                this.m_CodeInfo.ClockProperties(jj).Timing(ll)=TimeProp;
                            end
                            break;
                        end
                    end
                end

                this.addTimingProp(TimeProp);
            end


            if isempty(ClockEnPorts)
                return;
            end

            for ii=1:length(ClockEnPorts)
                ClockEnPort=ClockEnPorts(ii);
                for jj=1:length(this.m_CodeInfo.TimingProperties)
                    if this.AlmostEqual(this.m_CodeInfo.TimingProperties(jj).SamplePeriod,...
                        ClockEnPort.Signal.SimulinkRate)

                        ClockEnPortInfo=pirgetdatatypeinfo(ClockEnPort.Signal.Type);
                        ClockEnPortInfo.hdltype=ClockEnPort.Signal.VType;
                        ClockEnTypeProp=this.addHDLTypeProp(ClockEnPortInfo);
                        ClockEnImpl=RTW.Variable(ClockEnTypeProp,ClockEnPort.Name,this.m_TopNtwk.Name);
                        ll=length(this.m_CodeInfo.TimingProperties(jj).ClockEnableOut)+1;
                        if ll==1
                            this.m_CodeInfo.TimingProperties(jj).ClockEnableOut=ClockEnImpl;
                        else
                            this.m_CodeInfo.TimingProperties(jj).ClockEnableOut(ll)=ClockEnImpl;
                        end

                        break;
                    end
                end
            end
        end



        function SLPort_Name=maybeReconstructOrigSLName(this,origName,portNames,rT)
            SLPort_Name=origName;
            if length(portNames)>1
                RePfix=this.m_HDLCoderCtx.getParameter('complex_real_postfix');
                RePfixLen=length(RePfix);
                if~isempty(strfind(SLPort_Name,[RePfix,'_0']))
                    SLPort_Name=SLPort_Name(1:end-RePfixLen-2);
                elseif~isempty(strfind(SLPort_Name,RePfix))
                    SLPort_Name=SLPort_Name(1:end-RePfixLen);
                elseif~isempty(strfind(SLPort_Name,'_0'))
                    SLPort_Name=SLPort_Name(1:end-2);
                end
            end

            if rT.isRecordType
                recNameExt=['_',rT.MemberNames{1}];
                k=strfind(SLPort_Name,recNameExt);
                if~isempty(k)
                    k=k(end);
                    if(k+length(recNameExt)-1)==length(SLPort_Name)
                        SLPort_Name=SLPort_Name(1:k-1);
                    end
                end
            end
        end

        function SLTimeProp=defineTimingInterface(this,SLPort)

            SLTimeProp=RTW.HDLTimingInterface;
            timeProps=this.m_CodeInfo.TimingProperties;
            for jj=1:length(timeProps)
                if this.AlmostEqual(timeProps(jj).SamplePeriod,...
                    SLPort.Signal.SimulinkRate)
                    SLTimeProp=timeProps(jj);
                    break;
                end
            end
        end








        function setInputs(this)
            hN=this.m_TopNtwk;
            if isempty(hN.SLInputPorts)
                return;
            end


            portIdx=1;
            for ii=1:length(hN.SLInputPorts)
                SLPort=hN.SLInputPorts(ii);
                if~strcmpi(SLPort.Kind,'Data')
                    continue;
                end

                SLTimeProp=this.defineTimingInterface(SLPort);


                rT=hN.getDUTOrigInputRecordPortType(ii-1);
                if rT.isRecordType
                    numRecElem=rT.NumberOfMembersFlattened;
                    portNames={};
                    for jj=1:numRecElem
                        pn=hN.getHDLInputPortNames(portIdx-1);
                        if~iscell(pn)
                            pn={pn};
                        end
                        for kk=1:numel(pn)
                            portNames{end+1}=pn{kk};
                        end
                        portIdx=portIdx+1;
                    end
                else
                    portNames=hN.getHDLInputPortNames(portIdx-1);

                    if~iscell(portNames)
                        portNames={portNames};
                    end
                    portIdx=portIdx+1;
                end


                SLPortInfo=pirgetdatatypeinfo(rT);
                SLTypeProp=this.addSLTypeProp(SLPortInfo);


                HDLImpl=RTW.Variable(coder.types.Fixed,'','');
                for jj=1:length(portNames)
                    HDLName=portNames{jj};

                    for kk=1:length(hN.PirInputPorts)
                        HDLPort=hN.PirInputPorts(kk);
                        if strcmp(HDLPort.Name,HDLName)
                            break;
                        end
                    end


                    HDLPortInfo=pirgetdatatypeinfo(HDLPort.Signal.Type);
                    HDLPortInfo.hdltype=HDLPort.Signal.VType;
                    HDLTypeProp=this.addHDLTypeProp(HDLPortInfo);


                    HDLImpl(jj)=RTW.Variable(HDLTypeProp,HDLName,hN.Name);
                end

                SLPort_Name=this.maybeReconstructOrigSLName(SLPort.Name,...
                portNames,rT);
                if length(HDLImpl)>1

                    HDLCollect=RTW.TypedCollection;
                    HDLCollect.Elements=HDLImpl;
                    RTWdi=HDLCollect;
                else
                    RTWdi=HDLImpl;
                end

                dataInterface(ii)=RTW.DataInterface('',SLPort_Name,RTWdi,...
                SLTimeProp);


                dataInterface(ii).Type=SLTypeProp;
            end


            this.m_CodeInfo.Inports=dataInterface;
        end








        function setOutputs(this)
            hN=this.m_TopNtwk;
            if isempty(hN.SLOutputPorts)
                return;
            end


            portIdx=1;
            for ii=1:length(hN.SLOutputPorts)
                SLPort=hN.SLOutputPorts(ii);
                if~strcmpi(SLPort.Kind,'Data')
                    continue;
                end

                if SLPort.isTestpoint()
                    continue;
                end

                SLTimeProp=this.defineTimingInterface(SLPort);


                rT=hN.getDUTOrigOutputRecordPortType(ii-1);
                if rT.isRecordType
                    numRecElem=rT.NumberOfMembersFlattened;
                    portNames={};
                    for jj=1:numRecElem
                        pn=hN.getHDLOutputPortNames(portIdx-1);
                        if~iscell(pn)
                            pn={pn};
                        end
                        for kk=1:numel(pn)
                            portNames{end+1}=pn{kk};
                        end
                        portIdx=portIdx+1;
                    end
                else
                    portNames=hN.getHDLOutputPortNames(portIdx-1);

                    if~iscell(portNames)
                        portNames={portNames};
                    end
                    portIdx=portIdx+1;
                end


                SLPortInfo=pirgetdatatypeinfo(rT);
                SLTypeProp=this.addSLTypeProp(SLPortInfo);


                HDLImpl=RTW.Variable(coder.types.Fixed,'','');
                for jj=1:length(portNames)
                    HDLName=portNames{jj};

                    for kk=1:length(hN.PirOutputPorts)
                        HDLPort=hN.PirOutputPorts(kk);
                        if strcmp(HDLPort.Name,HDLName)
                            break;
                        end
                    end


                    HDLPortInfo=pirgetdatatypeinfo(HDLPort.Signal.Type);
                    HDLPortInfo.hdltype=HDLPort.Signal.VType;
                    HDLTypeProp=this.addHDLTypeProp(HDLPortInfo);


                    HDLImpl(jj)=RTW.Variable(HDLTypeProp,HDLName,hN.Name);
                end

                SLPort_Name=this.maybeReconstructOrigSLName(SLPort.Name,...
                portNames,rT);
                if length(HDLImpl)>1

                    HDLCollect=RTW.TypedCollection;
                    HDLCollect.Elements=HDLImpl;
                    RTWdi=HDLCollect;
                else
                    RTWdi=HDLImpl;
                end

                dataInterface(ii)=RTW.DataInterface('',SLPort_Name,RTWdi,...
                SLTimeProp);


                dataInterface(ii).Type=SLTypeProp;

            end


            this.m_CodeInfo.Outports=dataInterface;
        end







        function outTimeProp=addTimingProp(this,inTimeProp)

            TimePropNum=length(this.m_CodeInfo.TimingProperties);
            TimePropNew=true;
            outTimeProp=inTimeProp;

            if TimePropNum==0
                this.m_CodeInfo.TimingProperties=inTimeProp;
            else
                for kk=1:TimePropNum
                    if this.m_CodeInfo.TimingProperties(kk).SamplePeriod==inTimeProp.SamplePeriod
                        TimePropNew=false;
                        outTimeProp=this.m_CodeInfo.TimingProperties(kk);
                        break;
                    end
                end
                if TimePropNew
                    this.m_CodeInfo.TimingProperties(TimePropNum+1)=inTimeProp;
                end
            end

        end








        function outTypeProp=addSLTypeProp(this,SLPortInfo)

            if strcmp(SLPortInfo.sltype,'bus')
                TypeProp=this.convert2SLBusType(SLPortInfo);
            elseif SLPortInfo.isvector
                TypeProp=this.convert2SLMatrixType(SLPortInfo);
            elseif SLPortInfo.iscomplex
                TypeProp=this.convert2SLComplexType(SLPortInfo);
            else
                TypeProp=this.convert2SLNumericType(SLPortInfo);
            end

            TypePropNum=length(this.m_CodeInfo.Types);
            TypePropNew=true;
            outTypeProp=TypeProp;

            if TypePropNum==0
                this.m_CodeInfo.Types=TypeProp;
            else
                for kk=1:TypePropNum
                    if strcmp(this.m_CodeInfo.Types(kk).Name,TypeProp.Name)
                        TypePropNew=false;
                        outTypeProp=this.m_CodeInfo.Types(kk);
                        break;
                    end
                end
                if TypePropNew
                    this.m_CodeInfo.Types(TypePropNum+1)=TypeProp;
                end
            end
        end







        function TypeProp=convert2SLNumericType(~,SLPortInfo)

            if strcmp(SLPortInfo.sltype,'double')
                SLPortInfo.wordsize=64;
            elseif strcmp(SLPortInfo.sltype,'single')
                SLPortInfo.wordsize=32;
            end
            TypeProp=embedded.numerictype;
            TypeProp.WordLength=SLPortInfo.wordsize;
            TypeProp.BinaryPoint=SLPortInfo.binarypoint;
            TypeProp.SignednessBool=SLPortInfo.issigned;
            TypeProp.Name=SLPortInfo.sltype;
            TypeProp.Identifier=TypeProp.Name;
            TypeProp=coder.types.Type.createCoderType(TypeProp);
        end







        function TypeProp=convert2SLComplexType(this,SLPortInfo)
            TypeProp=coder.types.Complex;
            TypeProp.Name=['complex_',SLPortInfo.sltype];
            TypeProp.Identifier=TypeProp.Name;
            SLPortInfo.iscomplex=false;
            TypeProp.BaseType=this.addSLTypeProp(SLPortInfo);
        end







        function TypeProp=convert2SLMatrixType(this,SLPortInfo)
            TypeProp=coder.types.Matrix;
            TypeProp.Dimensions(1,1)=SLPortInfo.dims;
            TypeProp.Name=sprintf('matrix%dx%s',SLPortInfo.dims,SLPortInfo.sltype);
            SLPortInfo.isvector=false;
            TypeProp.BaseType=this.addSLTypeProp(SLPortInfo);
        end









        function TypeProp=convert2SLBusType(this,SLPortInfo)
            TypeProp=coder.types.Complex;
            TypeProp.Name='unspecified_bus_type';
            TypeProp.Identifier=TypeProp.Name;
        end







        function outTypeProp=addHDLTypeProp(this,HWPortInfo)

            if HWPortInfo.isvector
                TypeProp=this.convert2HDLMatrixType(HWPortInfo);
            else
                TypeProp=this.convert2HDLNumericType(HWPortInfo);
            end

            TypePropNum=length(this.m_CodeInfo.Types);
            TypePropNew=true;
            outTypeProp=TypeProp;

            if TypePropNum==0
                this.m_CodeInfo.Types=TypeProp;
            else
                for kk=1:TypePropNum
                    if strcmp(this.m_CodeInfo.Types(kk).Name,TypeProp.Name)
                        TypePropNew=false;
                        outTypeProp=this.m_CodeInfo.Types(kk);
                        break;
                    end
                end
                if TypePropNew
                    this.m_CodeInfo.Types(TypePropNum+1)=TypeProp;
                end
            end

        end







        function TypeProp=convert2HDLNumericType(~,HWPortInfo)

            if strcmp(HWPortInfo.sltype,'double')
                HWPortInfo.wordsize=64;
            elseif strcmp(HWPortInfo.sltype,'single')
                HWPortInfo.wordsize=32;
            end

            TypeProp=embedded.numerictype;
            TypeProp.WordLength=HWPortInfo.wordsize;
            TypeProp.BinaryPoint=HWPortInfo.binarypoint;
            TypeProp.SignednessBool=HWPortInfo.issigned;
            TypeProp.Name=[HWPortInfo.sltype,'_hdl'];
            TypeProp.Identifier=HWPortInfo.hdltype;
            TypeProp=coder.types.Type.createCoderType(TypeProp);
        end







        function TypeProp=convert2HDLMatrixType(this,HWPortInfo)
            TypeProp=coder.types.Matrix;
            TypeProp.Dimensions(1,1)=HWPortInfo.dims;
            TypeProp.Name=sprintf('matrix%dx%s_hdl',HWPortInfo.dims,HWPortInfo.sltype);
            TypeProp.Identifier=HWPortInfo.hdltype;
            HWPortInfo.hdltype=hdlportdatatype(HWPortInfo.sltype);
            HWPortInfo.isvector=false;
            TypeProp.BaseType=this.addHDLTypeProp(HWPortInfo);
        end









        function Clock2DTbl=get2DClockTable(this)
            ClockTbl=this.m_Pir.getClockTable(0);



            jj=0;
            for ii=1:length(ClockTbl)
                if ClockTbl(ii).Kind==0
                    jj=jj+1;
                end
            end

            Clock2DTbl=cell(jj,3);


            jj=1;
            for ii=1:length(ClockTbl)
                if ClockTbl(ii).Kind==0
                    Clock2DTbl(jj,1)={ClockTbl(ii)};
                    jj=jj+1;
                end
            end



            for ii=1:length(ClockTbl)
                if ClockTbl(ii).Kind~=0
                    for jj=1:length(Clock2DTbl(:,1))
                        if ClockTbl(ii).Ratio==Clock2DTbl{jj,1}.Ratio
                            if ClockTbl(ii).Kind==1
                                Clock2DTbl(jj,2)={ClockTbl(ii)};
                            else
                                Clock2DTbl(jj,3)={ClockTbl(ii)};
                            end
                            break;
                        end
                    end
                end
            end

        end






        function ret=AlmostEqual(this,val1,val2)
            if(val1==val2)
                ret=true;
            elseif(val1*val2<=0)
                ret=false;
            else
                [num,den]=this.GetRAT(val1/val2);
                ret=(num==den);
            end
        end











        function[Num,Den]=GetRAT(~,Xin)
            if(Xin==0)
                Num=uint32(0);
                Den=uint32(1);
                return;
            end

            prevErr=inf;
            prevNum=uint32(0);
            Num=uint32(1);
            prevDen=uint32(1);
            Den=uint32(0);
            if Xin>1
                rTol=eps*Xin;
            else
                rTol=eps*1;
            end
            x=Xin;

            while 1

                d=uint32(floor(x));
                x=x-double(d);


                tmp=uint32(Num);
                Num=uint32(Num)*uint32(d)+uint32(prevNum);
                prevNum=uint32(tmp);
                tmp=uint32(Den);
                Den=uint32(Den)*uint32(d)+uint32(prevDen);
                prevDen=uint32(tmp);

                err=abs(Xin-((double(Num))/(double(Den))));

                if(err>prevErr)


                    Num=uint32(prevNum);
                    Den=uint32(prevDen);
                    break;
                end
                if(x==0||err<=rTol)
                    break;
                end
                prevErr=err;
                x=1/x;

            end
        end

    end
end


