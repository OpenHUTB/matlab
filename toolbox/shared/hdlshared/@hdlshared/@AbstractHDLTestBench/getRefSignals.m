function[hdlsignals,outRef_vec,outRefTmp_vec,dataTable_vec]=getRefSignals(this,snk)


    hdlsignals=[];
    outRef_vec=[];
    outRefTmp_vec=[];
    dataTable_vec=[];
    refPostfix=hdlgetparameter('TestBenchReferencePostFix');
    isVerilog=hdlgetparameter('isverilog');

    outportNames=this.getHDLSignals('out',snk);

    for ii=1:length(outportNames)
        [~,outRefIdx]=hdlnewsignal(hdllegalname([outportNames{ii},refPostfix]),'block',...
        -1,0,0,snk.PortVType,snk.PortSLType);
        hdlsignals=[hdlsignals,makehdlsignaldecl(outRefIdx)];%#ok
        outRef_vec=[outRef_vec,outRefIdx];%#ok
    end

    if isVerilog||(hdlgetparameter('ScalarizePorts')~=0)
        vectorLength=0;
    else
        vectorLength=snk.VectorPortSize;
    end

    if(isVerilog)
        portVType=hdlblockdatatype(snk.PortSLType);
    else
        portVType=snk.PortVType;
    end

    isComplex=this.isPortComplex(snk);
    if(isComplex)
        stride=2;
    else
        stride=1;
    end
    nameIndex=1;

    if this.isPortOverClked(snk)
        for ii=1:stride:length(outportNames)
            if(isComplex)
                realPostfix=hdlgetparameter('complex_real_postfix');
                imagPostfix=hdlgetparameter('complex_imag_postfix');


                PortName=regexprep(outportNames{nameIndex},realPostfix,'');
                PortName=regexprep(PortName,imagPostfix,'');
            else
                PortName=outportNames{nameIndex};
            end
            nameIndex=nameIndex+1;
            if~isTextIOSupported(this)
                [~,dataTable]=hdlnewsignal([PortName,'_dataTable'],...
                'block',-1,isComplex,vectorLength,snk.PortVType,...
                snk.PortSLType);
                hdlsignals=[hdlsignals,makehdlsignaldecl(dataTable)];%#ok
                dataTable_vec=[dataTable_vec,dataTable];%#ok

                [~,outRefTmp]=hdlnewsignal(hdllegalname([PortName,refPostfix,'Tmp']),...
                'block',-1,isComplex,vectorLength,portVType,...
                snk.PortSLType);
                hdlsignals=[hdlsignals,makehdlsignaldecl(outRefTmp)];%#ok
                outRefTmp_vec=[outRefTmp_vec,outRefTmp];%#ok      
            end
        end
    end
