function[blkh,nUint32,nSigPerUInt32]=...
    genbitpack(packunpack,type,dims,refBlk,blkSize,blkDist)
















    if nargin<5
        blkSize=[70,24];
    end

    if nargin<6
        blkDist=40;
    end

    addBlockRight=@(src,dest,ref)addBlockR(src,dest,ref,blkSize,blkDist);
    addBlockLeft=@(src,dest,ref)addBlockL(src,dest,ref,blkSize,blkDist);

    dims=prod(double(dims));
    switch lower(packunpack)
    case 'pack'
        pack=true;
        ssName='Packer';
        addSS=addBlockRight;
    case 'unpack'
        pack=false;
        ssName='UnPacker';
        addSS=addBlockLeft;
    otherwise
        error(message('hdlcommon:workflow:BitPackInvalidOperation'));
    end

    dtWidth=type.WordLength;
    dtTotalWidth=ceil(dtWidth/8)*8;
    convertedDataType=sprintf('uint%d',dtTotalWidth);

    if ischar(refBlk)
        refBlk=get_param(refBlk,'handle');
    end

    subsys=get(refBlk,'Parent');

    if(dtWidth>16)||(dims==1)

        if pack
            sSpec=addSS('built-in/SignalSpecification',...
            [subsys,'/sSpec'],refBlk);
            set_param(sSpec,'OutDataTypeStr',fixdt(type));

            dtc=addSS('built-in/DataTypeConversion',[subsys,'/dtc'],sSpec);
            set_param(dtc,...
            'ConvertRealWorld','Stored Integer (SI)',...
            'OutDataTypeStr','uint32',...
            'SaturateOnIntegerOverflow','off');
            addLine(refBlk,sSpec,dtc);
        else
            dtc=addSS('built-in/DataTypeConversion',[subsys,'/dtc'],refBlk);
            set_param(dtc,...
            'ConvertRealWorld','Stored Integer (SI)',...
            'OutDataTypeStr',fixdt(type),...
            'SaturateOnIntegerOverflow','off');
            addLine(dtc,refBlk);
        end
        blkh=dtc;
        nUint32=dims;
        nSigPerUInt32=1;
        return
    end

    [bitPattern,nUint32,nSigPerUInt32]=...
    getPackParams(dtWidth,dtTotalWidth,dims);

    ss=addSS('built-in/Subsystem',[subsys,'/',ssName],refBlk);
    set(ss,'Location',[50,50,500,200]);
    ssName=getfullname(ss);

    load_system('xpcutilitieslib');
    if pack
        ip=add_block('built-in/Inport',[ssName,'/unpacked'],...
        'Position',[15,65,35,85]);
        sSpec=addSS('built-in/SignalSpecification',...
        [ssName,'/sSpec'],ip);
        dtc=addBlockRight('built-in/DataTypeConversion',...
        [ssName,'/upconvert'],sSpec);
        bp=addBlockRight('xpcutilitieslib/Bit Packing ',...
        [ssName,'/pack'],dtc);

        op=addBlockR('built-in/Outport',[ssName,'/packed'],...
        bp,[20,20],blkDist);
        addLine(ip,sSpec,dtc,bp,op);
        addLine(refBlk,ss);

        set_param(sSpec,'OutDataTypeStr',fixdt(type));
        set_param(dtc,...
        'OutDataTypeStr',convertedDataType,...
        'SaturateOnIntegerOverflow','off',...
        'ConvertRealWorld','Stored Integer (SI)');
        set_param(bp,...
        'MaskPackDataSize',sprintf('%d',nUint32),...
        'MaskPackDataType','uint32',...
        'MaskBitPatterns',bitPattern);
        blkh=ss;
    else
        ip=add_block('built-in/Inport',[ssName,'/packed'],...
        'Position',[15,65,35,85]);
        bp=addBlockRight('xpcutilitieslib/Bit Unpacking ',...
        [ssName,'/unpack'],ip);
        dtc=addBlockRight('built-in/DataTypeConversion',...
        [ssName,'/downconvert'],bp);
        op=addBlockR('built-in/Outport',[ssName,'/unpacked'],...
        dtc,[20,20],blkDist);
        addLine(ip,bp,dtc,op);
        addLine(ss,refBlk);

        set_param(dtc,...
        'OutDataTypeStr',fixdt(type),...
        'ConvertRealWorld','Stored Integer (SI)',...
        'SaturateOnIntegerOverflow','off');
        set_param(bp,...
        'MaskBitPatterns',bitPattern,...
        'MaskPackDataType','uint32',...
        'MaskPackDataSize',sprintf('%d',nUint32),...
        'MaskUnpackDataTypes',['{''',convertedDataType,'''}'],...
        'MaskUnpackDataSizes',sprintf('{%d}',dims));
        blkh=ss;
    end



    function blkh=addBlockR(src,dest,ref,destWH,blkDist)





        refPos=get(ref,'Position');
        srcWH=[refPos(3)-refPos(1),refPos(4)-refPos(2)];
        srcOrig=refPos(1:2);
        if nargin<4
            destWH=srcWH;
        end
        if nargin<5
            blkDist=50;
        end


        destOrig=srcOrig+[blkDist+srcWH(1),(srcWH(2)-destWH(2))/2];
        blkh=add_block(src,dest,'MakeNameUnique','on','Position',[destOrig,destOrig+destWH]);


        function blkh=addBlockL(src,dest,ref,destWH,blkDist)





            refPos=get(ref,'Position');
            srcWH=[refPos(3)-refPos(1),refPos(4)-refPos(2)];
            srcOrig=refPos(1:2);
            if nargin<4
                destWH=srcWH;
            end
            if nargin<5
                blkDist=50;
            end


            destOrig=srcOrig+[-blkDist-destWH(1),(srcWH(2)-destWH(2))/2];


            blkh=add_block(src,dest,...
            'MakeNameUnique','on',...
            'Position',[destOrig,destOrig+destWH]);


            function l=addLine(srcBlk,dstBlk,varargin)





                sp=get_param(srcBlk,'PortHandles');
                sp=sp.Outport(1);
                dp=get_param(dstBlk,'PortHandles');
                dp=dp.Inport(1);
                ss=get_param(srcBlk,'Parent');
                l=add_line(ss,sp,dp);


                if(nargin>2)
                    addLine(dstBlk,varargin{:});
                end



                function[str,numUInt32,numSigPerUInt32]=...
                    getPackParams(nBits,nTotalBits,width)

                    skipBits=repmat('-1 ',1,nTotalBits-nBits);

                    numSigPerUInt32=floor(32/nBits);

                    numUInt32=ceil(width/numSigPerUInt32);


                    u32Bound=0;

                    fpBound=0;

                    str='{[';

                    for i=1:width
                        if(fpBound+nBits>32)
                            u32Bound=u32Bound+32;
                            fpBound=0;
                        end
                        tmpStr=sprintf('%d:%d %s',...
                        u32Bound+fpBound,u32Bound+fpBound+nBits-1,skipBits);
                        str=[str,tmpStr];%#ok<AGROW>
                        fpBound=fpBound+nBits;
                    end
                    str(end+(1:2))=']}';
