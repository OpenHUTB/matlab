function vhdlwriteRefData(this,tbfid)

    performIO=this.isTextIOSupported;
    fprintf(tbfid,[this.hdlpackageComment('data',this.TestBenchName),'\n']);

    if hdlgetparameter('vhdl_package_required')==1

        hdlpackage=['USE work.',hdlgetparameter('vhdl_package_name'),'.ALL;\n'];
    else
        hdlpackage='\n';
    end

    hdlpackage=[hdlpackage,'LIBRARY IEEE;\nUSE IEEE.std_logic_1164.all;\n'];
    hdlpackage=[hdlpackage,'USE IEEE.numeric_std.ALL;\n'];
    tbPackName=[this.TestBenchName,hdlgetparameter('package_suffix')];
    hdlpackage=[hdlpackage,'USE work.',tbPackName,'.ALL;\n\n'];
    tbDataPackName=[this.TestBenchName,this.TestBenchDataPostFix];
    hdlpackage=[hdlpackage,'PACKAGE ',tbDataPackName,' IS\n\n'];
    fprintf(tbfid,hdlpackage);



    for m=1:length(this.InportSrc)
        signal=this.InportSrc(m);
        newtype=signal.HDLNewType;

        forceSignals=this.getHDLSignals('force',m);

        if~performIO||signal.dataIsConstant
            for ii=1:length(forceSignals)
                fprintf(tbfid,...
                ['  CONSTANT ',forceSignals{ii},' : ',newtype,';\n']);
            end
        end
    end
    for m=1:length(this.OutportSnk)
        signal=this.OutportSnk(m);
        newtype=signal.HDLNewType;

        expectedSignals=this.hdlSignals.ExpectedSignals{m};
        if~performIO||signal.dataIsConstant
            for ii=1:length(expectedSignals)
                fprintf(tbfid,['  CONSTANT ',expectedSignals{ii},' : ',...
                newtype,';\n']);
            end
        end
    end
    fprintf(tbfid,['\nEND ',this.TestBenchName,this.TestBenchDataPostFix,';\n\n']);



    fprintf(tbfid,['PACKAGE BODY ',this.TestBenchName,...
    this.TestBenchDataPostFix,' IS\n\n']);
    for m=1:length(this.InportSrc)
        port=this.InportSrc(m);

        if performIO&&~port.dataIsConstant

            this.wrToIO(port,true);
        else
            wrToTB(this,port,tbfid,'in',m);
        end
    end


    for m=1:length(this.OutportSnk)
        port=this.OutportSnk(m);

        if performIO&&~port.dataIsConstant

            this.wrToIO(port,false);
        else
            wrToTB(this,port,tbfid,'out',m);
        end
    end
    fprintf(tbfid,['END ',this.TestBenchName,this.TestBenchDataPostFix,';\n']);
end

function wrToTB(this,port,fid,inOut,portIdx)
    if strcmp(inOut,'in')
        [SignalsRe,SignalsIm]=this.getHDLSignals('force',portIdx);
    else
        [SignalsRe,SignalsIm]=this.getHDLSignals('expected',portIdx);
    end

    VHDL93WrData(this,port,SignalsRe,port.data,fid);
    if~isempty(SignalsIm)
        VHDL93WrData(this,port,SignalsIm,port.data_im,fid);
    end
end


function VHDL93WrData(this,port,constantName,data,fileId)
    portvtype=port.PortVType;
    portsltype=port.PortSLType;
    newtype=port.HDLNewType;
    vectorSize=port.VectorPortSize;
    len0=port.datalength;

    [iosize,iobp,iosigned]=hdlgetsizesfromtype(portsltype);
    isStdLogicVector=this.isStdLogicVector(portvtype,portsltype);

    if port.dataIsConstant==1
        len0=1;
    end

    numPorts=length(constantName);
    if ndims(data)==2 %#ok<ISMAT>
        numData=size(data);
        numData=numData(2);
    else
        numData=1;
    end
    for jj=1:numPorts
        currentConstant=constantName{jj};

        if numPorts==numData

            currentData=data(:,jj);
            currentVectorSize=1;
        else

            currentData=data;
            currentVectorSize=vectorSize;
        end
        [currentData,ismod4]=this.prepareData(currentData,len0,...
        currentVectorSize,iosigned,iosize,iobp);

        constants=['  CONSTANT ',currentConstant,' : ',newtype,' :=\n    (\n'];
        fprintf(fileId,constants);
        constants=VHDL93data2str(currentData,isStdLogicVector,iosize,iobp,...
        iosigned,ismod4);

        if currentVectorSize>1
            constants=fixVector(constants,currentVectorSize);
            constants=[constants(1:end-2),');\n\n'];
        else
            constants=[constants(1:end-3),');\n\n'];
        end

        fprintf(fileId,constants);
    end
end


function const=VHDL93data2str(data,isStdLogicVector,iosize,iobp,...
    iosigned,ismod4)
    if iosize==0
        const=[];
        for i=1:length(data)
            const=[const,'         ',hdlconstantvalue(data(i),iosize,iobp,...
            iosigned,'hex'),',\n'];%#ok<AGROW>
        end
    else
        if iosize==1
            prestr='         ''';
            poststr=''',\n';
        else
            if isStdLogicVector&&ismod4
                prestr='         X"';
                poststr='",\n';
            else
                prestr='         SLICE(X"';
                poststr=['",',int2str(iosize),'),\n'];
            end
        end
        const=formatTBData(prestr,data,poststr);
    end
end


function const=fixVector(const,vectorsize)
    validWord='[a-zA-z0-9-+\'']+';
    first=regexp(const,['\s',validWord]);
    last=regexp(const,['\w+','\s']);

    const(first(1))='(';
    for i=1:((length(first)/vectorsize)-1)
        const(first(i*(vectorsize)+1))='(';
    end
    for i=1:(length(last)/vectorsize)
        const(last(i*vectorsize)-2:last(i*vectorsize)+1)='),\n';
    end

    const=[const(1:end-3),')\n'];
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

            endpos=pos+plen;
            const(pos:endpos-1)=prestr;
            pos=endpos;
            endpos=pos+dlen;
            const(pos:endpos-1)=data(ii,:);
            pos=endpos;
            endpos=pos+elen;
            const(pos:endpos-1)=poststr;
            pos=endpos;
        end
    end
end


