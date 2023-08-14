function testBenchComponentsfromPIR(this)







    for m=1:length(this.OutPortSnk)
        HDLPortName=this.OutportSnk(m).HDLPortName;
        if iscell(HDLPortName)
            sigName=HDLPortName{1};
            if iscell(sigName)

                sigName=sigName{1};
            end
        else
            sigName=HDLPortName;
        end

        if iscell(sigName)
            for ii=1:numel(sigName)
                sigH=hdlsignalfindname(sigName{ii});
                this.OutportSnk(m).PortVType{end+1}=hdlsignalvtype(sigH);
                this.OutportSnk(m).PortSLType{end+1}=hdlsignalsltype(sigH);
            end
        else
            sigH=hdlsignalfindname(sigName);
            this.OutportSnk(m).PortVType=hdlsignalvtype(sigH);
            this.OutportSnk(m).PortSLType=hdlsignalsltype(sigH);
        end


        sigT=sigH.Type;
        if isArrayType(sigT)&&isCharType(sigT.getLeafType)
            this.OutportSnk(m).dataWidth=sigT.Dimensions;
        end
    end


    for m=1:length(this.InportSrc)
        HDLPortName=this.InportSrc(m).HDLPortName;
        if iscell(HDLPortName)
            sigName=HDLPortName{1};
            if iscell(sigName)

                sigName=sigName{1};
            end
        else
            sigName=HDLPortName;
        end

        if iscell(sigName)
            for ii=1:numel(sigName)
                sigH=hdlsignalfindname(sigName{ii});
                this.InportSrc(m).PortVType{end+1}=hdlsignalvtype(sigH);
                this.InportSrc(m).PortSLType{end+1}=hdlsignalsltype(sigH);
            end
        else
            sigH=hdlsignalfindname(sigName);
            this.InportSrc(m).PortVType=hdlsignalvtype(sigH);
            this.InportSrc(m).PortSLType=hdlsignalsltype(sigH);
        end


        sigT=sigH.Type;
        if isArrayType(sigT)&&isCharType(sigT.getLeafType)
            this.InportSrc(m).dataWidth=sigT.Dimensions;
        end
    end


    gp=pir;
    uniquifyClockParams(this);
    outport_list=gp.getTopNetwork.PirOutputPorts;
    op_clken_list=struct([]);
    for i=1:length(outport_list)
        outport=outport_list(i);
        if(outport.isClockEnable)
            outport_srate=outport.Signal.SimulinkRate;

            for j=1:length(op_clken_list)
                if(op_clken_list(j).SimulinkRate==outport_srate)
                    errMsg=message('hdlcoder:engine:multipleclockenables');
                    this.addCheckToDriver([],'error',errMsg);
                    error(errMsg);
                end
            end


            op_clken_list(end+1).SimulinkRate=outport_srate;%#ok<AGROW>
            op_clken_list(end).ClockEnable=outport;
        end
    end


    ce_out_name=hdlgetparameter('clockenableoutputname');
    numCreatedCeOut=0;
    for i=1:length(this.OutportSnk)
        sTime=findPIRSampleTime(this.OutportSnk(i).HDLPortName,outport_list);
        if isempty(op_clken_list)
            clken.Name=ce_out_name;
            this.OutPortSnk(i).ClockEnable=clken;
            op_clken_list(end+1).SimulinkRate=sTime;%#ok<AGROW>
            op_clken_list(end).ClockEnable=clken;
            numCreatedCeOut=numCreatedCeOut+1;
        else
            clkenName=findClkEnb(sTime,op_clken_list);
            if isempty(clkenName)
                if numCreatedCeOut==0

                    clken.Name='hdlc_dummy_tb_enable_signal_internal_name_only';
                else
                    clken.Name=sprintf('%s_%d',ce_out_name,numCreatedCeOut);
                    op_clken_list(end+1).SimulinkRate=sTime;%#ok<AGROW>
                    op_clken_list(end).ClockEnable=clken;
                    numCreatedCeOut=numCreatedCeOut+1;
                end
                this.OutPortSnk(i).ClockEnable=clken;
            else
                this.OutPortSnk(i).ClockEnable.Name=clkenName.Name;
            end
        end
    end
end


function sampleTime=findPIRSampleTime(PortName,PIRPortList)
    if iscell(PortName)
        if iscell(PortName{1})
            port_name=PortName{1}{1};
        else
            port_name=PortName{1};
        end
    else
        port_name=PortName;
    end

    for i=1:length(PIRPortList)
        if strcmpi(port_name,PIRPortList(i).Signal.Name)
            sampleTime=PIRPortList(i).Signal.SimulinkRate;
            break;
        end
    end
end


function clkenName=findClkEnb(sTime,clken_list)
    clkenName=[];
    for i=1:length(clken_list)
        if clken_list(i).SimulinkRate==sTime
            clkenName=clken_list(i).ClockEnable;
            break;
        end
    end
end


