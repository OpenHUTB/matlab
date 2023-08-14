function verilogwriteRefData(this,tbfid)

    performIO=this.isTextIOSupported;
    cchar=hdlgetparameter('comment_char');
    fprintf(tbfid,this.hdlpackageComment('data',this.TestBenchName));


    initial=['\n\n',...
    '// **************************************\n',...
    ' initial ',cchar,'Input & Output data','\n',...
    ' begin\n'];



    for m=1:length(this.InportSrc)
        port=this.InportSrc(m);
        inlen0=port.datalength;
        portvtype=port.PortVType;

        forceSignals=this.getHDLSignals('force',m);

        if port.dataIsConstant==1
            inlen0=1;
        end

        if strcmp(portvtype(1:4),'wire')
            inputvtype_const=['reg ',portvtype(5:end)];
        else
            inputvtype_const=portvtype;
        end

        if inlen0>1
            slicein=['[0:',int2str(inlen0-1),']'];
        else
            slicein='';
        end


        for ii=1:length(forceSignals)
            fprintf(tbfid,' %s %s %s;\n',inputvtype_const,forceSignals{ii},slicein);
        end
    end



    hasrealoutput=false;
    for m=1:length(this.OutportSnk)
        port=this.OutportSnk(m);
        outlen0=port.datalength;
        portvtype=port.PortVType;
        portsltype=port.PortSLType;

        expectedSignals=this.getHDLSignals('expected',m);

        if port.dataIsConstant==1
            outlen0=1;
        end

        iosize=hdlgetsizesfromtype(portsltype);

        gp=pir;
        isnfp=isNativeFloatingPointMode();
        if(iosize==0&&~gp.getTargetCodeGenSuccess&&~isnfp)
            outputvtype_const='real ';
            hasrealoutput=true;
        elseif strcmp(portvtype(1:4),'wire')
            outputvtype_const=['reg ',portvtype(5:end)];
        else
            outputvtype_const=portvtype;
        end

        if outlen0>1
            sliceout=['[0:',int2str(outlen0-1),']'];
        else
            sliceout='';
        end

        for ii=1:length(expectedSignals)
            fprintf(tbfid,' %s %s %s;\n',outputvtype_const,expectedSignals{ii},sliceout);
        end
    end



    if~isempty(this.InportSrc)
        wrInDatConst=any([this.InportSrc(:).dataIsConstant]);
    else
        wrInDatConst=0;
    end

    if~isempty(this.OutportSnk)
        wrOutDatConst=any([this.OutportSnk(:).dataIsConstant]);
    else
        wrOutDatConst=0;
    end

    wrInitialEnd=any([wrInDatConst,wrOutDatConst,~performIO]);

    if wrInitialEnd==1
        fprintf(tbfid,initial);
    end




    for m=1:length(this.InportSrc)
        port=this.InportSrc(m);
        if performIO&&~port.dataIsConstant
            this.wrToIO(port,true);
        else
            wrToTB(this,port,cchar,tbfid,'in',m);
        end
    end


    for m=1:length(this.OutportSnk)
        port=this.OutportSnk(m);
        if performIO&&~port.dataIsConstant
            this.wrToIO(port,false);
        else
            wrToTB(this,port,cchar,tbfid,'out',m);
        end
    end


    end_st=['\n end ',cchar,' Input & Output data\n',...
    '//************************************\n\n'];
    if wrInitialEnd==1;
        fprintf(tbfid,end_st);
    end



    if(hasrealoutput)
        abs_function=[...
        'function real abs_real;\n',...
        'input real ip_val;\n',...
        hdlgetparameter('comment_char'),' return value = |ip_val|\n',...
        ' begin\n',...
        ' abs_real = (ip_val > 0) ? ip_val : -ip_val;\n',...
        ' end\n',...
        'endfunction //function abs_real\n\n',...
        ];
        fprintf(tbfid,abs_function);
    end

    fprintf(tbfid,'\n');
end


function wrToTB(this,port,cchar,fid,inOut,portIdx)
    if strcmp(inOut,'in')
        [SignalsRe,SignalsIm]=this.getHDLSignals('force',portIdx);
    else
        [SignalsRe,SignalsIm]=this.getHDLSignals('expected',portIdx);
    end

    writeVerilogData(this,port,SignalsRe,inOut,port.data,cchar,fid);
    if~isempty(SignalsIm)
        writeVerilogData(this,port,SignalsIm,inOut,port.data_im,cchar,fid);
    end
end

function writeVerilogData(this,port,signals,inOrOut,data,cchar,fid)
    vectorSize=port.VectorPortSize;
    signame=port.loggingPortName;

    if strcmp(inOrOut,'in')
        fprintf(fid,'\n %s Input data for %s\n',cchar,signame);
    else
        fprintf(fid,'\n %s Output data for %s\n',cchar,signame);
    end

    for ii=1:length(signals)
        if vectorSize>1
            currentData=data(:,ii);
        else
            currentData=data;
        end

        VerilogAccWrData(this,port,signals{ii},inOrOut,currentData,fid);
    end
end



function VerilogAccWrData(this,signal,portname,portType,data,fid)

    portsltype=signal.PortSLType;

    inlen0=signal.datalength;

    [iosize,iobp,iosigned]=hdlgetsizesfromtype(portsltype);
    if signal.dataIsConstant==1
        inlen0=1;
    end

    vectorSize=1;
    data=this.prepareData(data,inlen0,vectorSize,iosigned,iosize,iobp);

    const=Verilogdata2str(data,portname,portType,iosize,iobp,iosigned);

    fprintf(fid,const);

end

function const=Verilogdata2str(data,portname,portType,iosize,iobp,iosigned)
    [sample,~]=size(data);
    idx=int2str((0:sample-1)');

    if iosize==0
        prestr=sprintf(' %s',portname);
        p=pir;
        isnfp=isNativeFloatingPointMode();
        if strcmpi(portType,'in')&&~p.getTargetCodeGenSuccess&&~isnfp
            assignstr=' <= $realtobits(';
            poststr=');\n';
        else
            assignstr=' <= ';
            poststr=';\n';
        end
        const=[];
        if sample==1
            for ii=1:sample
                const=[const,prestr,assignstr,hdlconstantvalue(data(ii),iosize,iobp,iosigned,'hex'),poststr];%#ok<AGROW>
            end
        else
            for ii=1:sample
                const=[const,prestr,'[',idx(ii,:),']',assignstr,hdlconstantvalue(data(ii),iosize,iobp,iosigned,'hex'),poststr];%#ok<AGROW>
            end
        end
    else
        poststr=';\n';
        if sample==1
            prestr=[' ',portname,' <= ',int2str(iosize),'''h'];
            const=formatTBData(prestr,data,poststr);
        else
            prestr=[' ',portname,'['];
            midstr=['] <= ',int2str(iosize),'''h'];
            const=formatTBData2(prestr,idx,midstr,data,poststr);
        end
    end

end

function const=formatTBData(prestr,data,poststr)
    if length(data)<10000
        tmp=strcat(cellstr(prestr),data,cellstr(poststr));
        const=sprintf('%s',tmp{:});
    else
        plen=length(prestr);
        elen=length(poststr);
        dlen=length(data(1,:));
        numdata=size(data,1);
        clen=numdata*(plen+dlen+elen);
        sp=' ';
        const=repmat(sp,1,clen);
        pos=1;
        for ii=1:numdata

            endpos=pos+plen-1;
            const(pos:endpos)=prestr;
            pos=endpos+1;
            endpos=pos+dlen-1;
            const(pos:endpos)=data(ii,:);
            pos=endpos+1;
            endpos=pos+elen-1;
            const(pos:endpos)=poststr;
            pos=endpos+1;
        end
    end
end

function const=formatTBData2(prestr,data1,midstr,data2,poststr)
    if length(data1)<10000
        tmp=strcat(cellstr(prestr),data1,cellstr(midstr),data2,cellstr(poststr));
        const=sprintf('%s',tmp{:});
    else
        plen=length(prestr);
        mlen=length(midstr);
        elen=length(poststr);
        d1len=length(data1(1,:));
        d2len=length(data2(1,:));
        numdata=size(data1,1);
        clen=numdata*(plen+d1len+mlen+d2len+elen);
        sp=' ';
        const=repmat(sp,1,clen);
        pos=1;
        for ii=1:numdata

            endpos=pos+plen-1;
            const(pos:endpos)=prestr;
            pos=endpos+1;
            endpos=pos+d1len-1;
            const(pos:endpos)=data1(ii,:);
            pos=endpos+1;
            endpos=pos+mlen-1;
            const(pos:endpos)=midstr;
            pos=endpos+1;
            endpos=pos+d2len-1;
            const(pos:endpos)=data2(ii,:);
            pos=endpos+1;
            endpos=pos+elen-1;
            const(pos:endpos)=poststr;
            pos=endpos+1;
        end
    end
end


