function varargout=PUPCodegenCb(varargin)

%#codegen
%#ok<*EMCA>
    coder.allowpcode('plain');

    switch varargin{1}
    case 'calcDerivedInfo'
        [varargout{1:nargout}]=calcDerivedInfo(varargin{2:end});
    case 'checkAddressRange'
        [varargout{1:nargout}]=checkAddressRange(varargin{2:end});
    case 'packToBytes'
        [varargout{1:nargout}]=packToBytes(varargin{2:end});
    case 'unpackFromBytes'
        [varargout{1:nargout}]=unpackFromBytes(varargin{2:end});
    otherwise
        error(message('soc:msgs:InternalUnknownCodegenFunction',...
        varargin{1},'PUPCodegenCb'));
    end
end



function[gatherCount,nthBurstSize,burstCount]=calcDerivedInfo(transactionLength,ChLength,ChTDATAWidth,ChFrameGatherBufferSize,ChGatherBufferSize)



    coder.extrinsic('hsb.blkcb2.cbutils');
    MAX_BURST_COUNT=coder.const(hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_COUNT'));
    MAX_BURST_BEATS=coder.const(hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_BEATS'));
    MAX_BURST_SIZE=coder.const(hsb.blkcb2.cbutils('GetSystemConstant','MAX_BURST_SIZE'));

    chTDATASize=(ChTDATAWidth/8);
    burstMaxLength=min(MAX_BURST_BEATS,ceil(MAX_BURST_SIZE/chTDATASize));
    burstMaxSize=burstMaxLength*chTDATASize;
    l_ChFrameGatherBufferSize=ChLength*chTDATASize;
    l_ChGatherBufferSize=ceil(burstMaxSize/l_ChFrameGatherBufferSize)*l_ChFrameGatherBufferSize;
    assert(l_ChFrameGatherBufferSize==ChFrameGatherBufferSize,'bad ChFrameGatherBufferSize');
    assert(l_ChGatherBufferSize==ChGatherBufferSize,'bad ChGatherBufferSize');




    burstCount=ceil(transactionLength/burstMaxLength);
    if burstCount>MAX_BURST_COUNT
        error(message('soc:msgs:BurstCountTooLargeA4M',transactionLength,burstCount,MAX_BURST_COUNT));
    end


    nthBurstLength=rem(transactionLength,burstMaxLength);
    if nthBurstLength==0
        nthBurstLength=burstMaxLength;
    end
    nthBurstSize=nthBurstLength*chTDATASize;

    gatherCount=transactionLength/ChLength;




    assert((gatherCount>=1),...
    ['Transaction length must be greater than or equal to channel length. All channel data must be used in a transaction.\n',...
    'Transaction length: %d\nChannel length: %d\nGather count: %g\n'],...
    transactionLength,ChLength,gatherCount);
    assert(gatherCount==round(gatherCount),...
    ['Transaction length must be multiple of channel length. All channel data must be used in a transaction.\n',...
    'Transaction length: %d\nChannel length: %d\nGather count: %g\n'],...
    transactionLength,ChLength,gatherCount);







    if ChLength>burstMaxLength
        x=ChLength/burstMaxLength;
        unaligned=(x~=round(x));
        if unaligned
            assert(transactionLength==ChLength,...
            ['Transaction length must equal the channel length for large, unaligned bursts.\n',...
            'Transaction length: %d\nChannel length: %d\nMax burst length:%d'],...
            transactionLength,ChLength,burstMaxLength);
        end

    else
        x=burstMaxLength/ChLength;
        unaligned=(x~=round(x));
        if unaligned
            assert(transactionLength<burstMaxLength,...
            ['Transaction length must not exceed max burst length for unaligned bursts.\n',...
            'Transaction length: %d\nMax burst length:%d'],...
            transactionLength,burstMaxLength);
        end

    end

end

function checkAddressRange(Addr,Len,DSMSize,MasterKind,ChTDATAWidth)

    ChTDATAByteWidth=(ChTDATAWidth/8);
    ByteLen=Len*ChTDATAByteWidth;

    assert(Addr<DSMSize,message('soc:msgs:AddrOutOfBounds',MasterKind,DSMSize,Addr,Len,ByteLen));

    assert(ByteLen<=DSMSize,message('soc:msgs:LenOutOfBounds',MasterKind,DSMSize,Addr,Len,ByteLen));

    assert(Addr+ByteLen<=DSMSize,message('soc:msgs:TransOutOfBounds',MasterKind,DSMSize,Addr,Len,ByteLen))
end

function dout=packToBytes(din,ChBitPacked,ChTDATAPadWidth,ChLength,ChTDATAWidth,ChWidth,ChCompLength,ChFrameGatherBufferSize,ChDimensions,exemplarChDatum)



    dimMismatch=coder.const(l_checkDims(size(din),size(zeros([ChDimensions,1]))));
    dtypeMismatch=coder.const(l_checkType(zeros(1,1,'like',din),exemplarChDatum));

    if dtypeMismatch||dimMismatch
        dout=zeros([ChFrameGatherBufferSize,1],'uint8');
        return;
    end


    if(isfloat(din))
        tmpdout=typecast(din(:),'uint8');
    else
        if(ChBitPacked)
            if any(strcmp(class(din),{'embedded.fi','Simulink.NumericType'}))

                if(din.WordLength==8)||(din.WordLength==16)||...
                    (din.WordLength==32)||(din.WordLength==64)

                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    ChByteWidth=coder.const(ChWidth/8);

                    tmpdout=zeros([ChFrameGatherBufferSize,1],'uint8');
                    tmpdin=fi2sim(din);
                    for idx=1:ChLength
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            pbidx=(idx-1)*ChTDATAByteWidth+(cidx-1)*ChByteWidth;
                            bdata=typecast(tmpdin(pcidx),'uint8');
                            tmpdout(pbidx+1:pbidx+ChByteWidth)=bdata(:);
                        end
                    end
                elseif(ChTDATAWidth<=64)

                    sign=coder.const(exemplarChDatum.Signed);
                    tmpstorage=coder.const(class(fi2sim(fi(0,sign,ChTDATAWidth,0))));
                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    mask=coder.const(cast(2^uint64(ChWidth)-1,tmpstorage));

                    tmpdout=zeros([ChFrameGatherBufferSize,1],'uint8');
                    tmpdin=fi2sim(din);
                    for idx=1:ChLength
                        pval=zeros([1,1],tmpstorage);
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            pval=bitor(pval,bitshift(bitand(cast(tmpdin(pcidx),tmpstorage),mask),ChWidth*(cidx-1)));
                        end
                        bdata=typecast(pval,'uint8');
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        tmpdout(pbidx+1:pbidx+ChTDATAByteWidth)=bdata(:);
                    end
                elseif(ChTDATAWidth>64)&&(ChWidth<=64)

                    sign=coder.const(exemplarChDatum.Signed);
                    if sign
                        tmpstorage='int64';
                    else
                        tmpstorage='uint64';
                    end
                    wlen_storage=int32(64);
                    numw_storage=coder.const(int32(ChTDATAWidth/wlen_storage));
                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    mask=coder.const(cast(2^uint64(ChWidth)-1,tmpstorage));

                    tmpdout=zeros([ChFrameGatherBufferSize,1],'uint8');
                    tmpdin=fi2sim(din);
                    for idx=1:ChLength
                        pval=zeros([numw_storage,1],tmpstorage);
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            nbshift=int32(ChWidth*(cidx-1));
                            widx=idivide(nbshift,wlen_storage)+1;
                            nbshift=nbshift-wlen_storage*(widx-1);
                            pval(widx)=bitor(pval(widx),bitshift(bitand(cast(tmpdin(pcidx),tmpstorage),mask),nbshift));
                            if(nbshift+ChWidth)>wlen_storage
                                pval(widx+1)=bitor(pval(widx+1),bitshift(bitand(cast(tmpdin(pcidx),tmpstorage),mask),nbshift-wlen_storage));
                            end
                        end
                        bdata=typecast(pval,'uint8');
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        tmpdout(pbidx+1:pbidx+ChTDATAByteWidth)=bdata(:);
                    end
                else

                    sign=coder.const(exemplarChDatum.Signed);
                    wordlen=coder.const(int32(exemplarChDatum.WordLength));
                    wlen_storage=int32(64);
                    numw_storage=coder.const(int32(ChTDATAWidth/wlen_storage));
                    numw_data=coder.const(idivide(wordlen,wlen_storage,'ceil'));
                    tmpstorage='uint64';
                    ChWidthLast=coder.const(ChWidth-(wlen_storage*(numw_data-1)));
                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    mask=coder.const(cast(bitshift(intmax('uint64'),ChWidthLast-64),tmpstorage));

                    tmpdout=zeros([ChFrameGatherBufferSize,1],'uint8');
                    tmpdin=fi2sim(din);
                    for idx=1:ChLength
                        pval=zeros([numw_storage,1],tmpstorage);
                        for cidx=1:ChCompLength
                            for tidx=1:numw_data
                                pcidx=(idx-1)*numw_data+(cidx-1)*ChLength*numw_data+tidx;
                                nbshift=int32(ChWidth*(cidx-1)+(tidx-1)*wlen_storage);
                                widx=idivide(nbshift,wlen_storage)+1;
                                nbshift=nbshift-wlen_storage*(widx-1);
                                if tidx==numw_data
                                    pval(widx)=bitor(pval(widx),bitshift(bitand(tmpdin(pcidx),mask),nbshift));
                                    if(nbshift+ChWidthLast)>wlen_storage
                                        pval(widx+1)=bitor(pval(widx+1),bitshift(bitand(tmpdin(pcidx),mask),nbshift-wlen_storage));
                                    end
                                else
                                    pval(widx)=bitor(pval(widx),bitshift(tmpdin(pcidx),nbshift));
                                    if(nbshift+wlen_storage)>wlen_storage
                                        pval(widx+1)=bitor(pval(widx+1),bitshift(tmpdin(pcidx),nbshift-wlen_storage));
                                    end
                                end
                            end
                        end
                        bdata=typecast(pval,'uint8');
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        tmpdout(pbidx+1:pbidx+ChTDATAByteWidth)=bdata(:);
                    end
                end
            else

                tmpdout=zeros([ChFrameGatherBufferSize,1],'uint8');
                ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                ChByteWidth=coder.const(ChWidth/8);
                for idx=1:ChLength
                    for cidx=1:ChCompLength
                        pcidx=(cidx-1)*ChLength+idx;
                        pbidx=(idx-1)*ChTDATAByteWidth+(cidx-1)*ChByteWidth;
                        bdata=typecast(din(pcidx),'uint8');
                        tmpdout(pbidx+1:pbidx+ChByteWidth)=bdata(:);
                    end
                end
            end
        else

            if any(strcmp(class(din),{'embedded.fi','Simulink.NumericType'}))
                tmpdout=typecast(fi2sim(din(:)),'uint8');
            elseif isinteger(din)
                tmpdout=typecast(din(:),'uint8');
            else
                msg=hsb.blkcb2.UtilsCodegenCb('getMessage','soc:msgs:CannotPackToBytes',...
                ChBitPacked,ChTDATAPadWidth,ChLength,ChTDATAWidth,ChWidth,ChCompLength);
                error(msg);
            end
        end
    end

    dout=reshape(tmpdout,[],1);
end

function dout=unpackFromBytes(din,ChBitPacked,exemplarChDatum,ChLength,ChTDATAWidth,ChWidth,ChDimensions,ChCompLength,ChCompBitRanges)

    if isfloat(exemplarChDatum)
        tmpdout=typecast(din,class(exemplarChDatum));
        dout=reshape(tmpdout,[ChDimensions,1]);
    else
        if(ChBitPacked)
            if any(strcmp(class(exemplarChDatum),{'embedded.fi','Simulink.NumericType'}))

                if(exemplarChDatum.WordLength==8)||(exemplarChDatum.WordLength==16)||...
                    (exemplarChDatum.WordLength==32)||(exemplarChDatum.WordLength==64)

                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    ChByteWidth=coder.const(ChWidth/8);
                    sign=coder.const(exemplarChDatum.Signed);
                    fistorage=coder.const(class(fi2sim(exemplarChDatum(1))));
                    dout=zeros([ChDimensions,1],'like',exemplarChDatum);
                    tmpdout=zeros([ChDimensions,1],fistorage);
                    for idx=1:ChLength
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            pbidx=(idx-1)*ChTDATAByteWidth+(cidx-1)*ChByteWidth;
                            bdata=din(pbidx+1:pbidx+ChByteWidth);
                            tmpdout(pcidx)=typecast(bdata(:),fistorage);
                        end
                    end
                    dout(:)=sim2fi(tmpdout,...
                    sign,...
                    exemplarChDatum.WordLength,...
                    exemplarChDatum.FractionLength);
                elseif(ChTDATAWidth<=64)

                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    sign=coder.const(exemplarChDatum.Signed);
                    tmpstorage=coder.const(class(fi2sim(fi(0,0,ChTDATAWidth,0))));
                    mask=coder.const(cast(2^ChWidth-1,tmpstorage));
                    signextmask=coder.const(bitcmp(cast(2^ChWidth-1,tmpstorage)));
                    signmask=coder.const(cast(2^(ChWidth-1),tmpstorage));

                    fistorage=coder.const(class(fi2sim(exemplarChDatum(1))));
                    dout=zeros([ChDimensions,1],'like',exemplarChDatum);
                    tmpdout=zeros([ChDimensions,1],fistorage);
                    for idx=1:ChLength
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        bdata=din(pbidx+1:pbidx+ChTDATAByteWidth);
                        pval=typecast(bdata,tmpstorage);
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            tmp=bitand(bitshift(pval,-ChWidth*(cidx-1)),mask);
                            if sign
                                if bitand(tmp,signmask)
                                    tmp=bitor(tmp,signextmask);
                                end
                            end
                            tmp0=typecast(tmp,fistorage);
                            tmpdout(pcidx)=tmp0(1);
                        end
                    end
                    dout(:)=sim2fi(tmpdout,...
                    sign,...
                    exemplarChDatum.WordLength,...
                    exemplarChDatum.FractionLength);
                elseif(ChTDATAWidth>64)&&(ChWidth<=64)

                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    sign=coder.const(exemplarChDatum.Signed);
                    tmpstorage='uint64';
                    wlen_storage=int32(64);
                    mask=coder.const(cast(2^uint64(ChWidth)-1,tmpstorage));
                    signextmask=coder.const(bitcmp(cast(2^uint64(ChWidth)-1,tmpstorage)));
                    signmask=coder.const(cast(2^(uint64(ChWidth)-1),tmpstorage));

                    fistorage=coder.const(class(fi2sim(exemplarChDatum(1))));
                    dout=zeros([ChDimensions,1],'like',exemplarChDatum);
                    tmpdout=zeros([ChDimensions,1],fistorage);
                    for idx=1:ChLength
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        bdata=din(pbidx+1:pbidx+ChTDATAByteWidth);
                        pval=typecast(bdata,tmpstorage);
                        for cidx=1:ChCompLength
                            pcidx=(cidx-1)*ChLength+idx;
                            nbshift=int32(ChWidth*(cidx-1));
                            widx=idivide(nbshift,wlen_storage)+1;
                            nbshift=nbshift-wlen_storage*(widx-1);
                            tmp=bitand(bitshift(pval(widx),-nbshift),mask);
                            if(nbshift+ChWidth)>wlen_storage
                                tmp=bitor(tmp,bitand(bitshift(pval(widx+1),wlen_storage-nbshift),mask));
                            end
                            if sign
                                if bitand(tmp,signmask)
                                    tmp=bitor(tmp,signextmask);
                                end
                            end
                            tmp0=typecast(tmp,fistorage);
                            tmpdout(pcidx)=tmp0(1);
                        end
                    end
                    dout(:)=sim2fi(tmpdout,...
                    sign,...
                    exemplarChDatum.WordLength,...
                    exemplarChDatum.FractionLength);
                else

                    ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                    sign=coder.const(exemplarChDatum.Signed);
                    wordlen=coder.const(int32(exemplarChDatum.WordLength));
                    tmpstorage='uint64';
                    wlen_storage=int32(64);
                    numw_data=coder.const(idivide(wordlen,wlen_storage,'ceil'));
                    ChWidthLast=coder.const(ChWidth-(wlen_storage*(numw_data-1)));
                    mask=coder.const(cast(bitshift(intmax('uint64'),ChWidthLast-64),tmpstorage));
                    signextmask=coder.const(bitcmp(cast(bitshift(intmax('uint64'),ChWidthLast-64),tmpstorage)));
                    signmask=coder.const(cast(bitshift(intmax('uint64'),ChWidthLast-65)+1,tmpstorage));

                    fistorage=coder.const(class(fi2sim(exemplarChDatum(1))));
                    dout=zeros([ChDimensions,1],'like',exemplarChDatum);
                    tmpdout=zeros([prod(ChDimensions)*numw_data,1],fistorage);
                    for idx=1:ChLength
                        pbidx=(idx-1)*ChTDATAByteWidth;
                        bdata=din(pbidx+1:pbidx+ChTDATAByteWidth);
                        pval=typecast(bdata,tmpstorage);
                        for cidx=1:ChCompLength
                            for tidx=1:numw_data
                                pcidx=(idx-1)*numw_data+(cidx-1)*ChLength*numw_data+tidx;
                                nbshift=int32(ChWidth*(cidx-1)+(tidx-1)*wlen_storage);
                                widx=idivide(nbshift,wlen_storage)+1;
                                nbshift=nbshift-wlen_storage*(widx-1);
                                if tidx==numw_data
                                    tmp=bitand(bitshift(pval(widx),-nbshift),mask);
                                    if(nbshift+ChWidthLast)>wlen_storage
                                        tmp=bitor(tmp,bitand(bitshift(pval(widx+1),wlen_storage-nbshift),mask));
                                    end
                                    if sign
                                        if bitand(tmp,signmask)
                                            tmp=bitor(tmp,signextmask);
                                        end
                                    end
                                else
                                    tmp=bitshift(pval(widx),-nbshift);
                                    if(nbshift+wlen_storage)>wlen_storage
                                        tmp=bitor(tmp,bitshift(pval(widx+1),wlen_storage-nbshift));
                                    end
                                end

                                tmpdout(pcidx)=tmp;
                            end
                        end
                    end
                    dout(:)=sim2fi(tmpdout,...
                    sign,...
                    exemplarChDatum.WordLength,...
                    exemplarChDatum.FractionLength);
                end
            else


                dout=zeros([ChDimensions,1],'like',exemplarChDatum);
                ChTDATAByteWidth=coder.const(ChTDATAWidth/8);
                ChByteWidth=coder.const(ChWidth/8);
                for idx=1:ChLength
                    for cidx=1:ChCompLength
                        pcidx=(cidx-1)*ChLength+idx;
                        pbidx=(idx-1)*ChTDATAByteWidth+(cidx-1)*ChByteWidth;
                        bdata=din(pbidx+1:pbidx+ChByteWidth);
                        dout(pcidx)=typecast(bdata(:),class(exemplarChDatum));
                    end
                end
            end
        else

            if any(strcmp(class(exemplarChDatum),{'embedded.fi','Simulink.NumericType'}))
                fistorage=coder.const(class(fi2sim(exemplarChDatum(1))));
                dtmp=typecast(din,fistorage);
                tmpdout=sim2fi(dtmp,...
                exemplarChDatum.Signed,...
                exemplarChDatum.WordLength,...
                exemplarChDatum.FractionLength);
            elseif isinteger(exemplarChDatum)
                tmpdout=typecast(din,class(exemplarChDatum));
            else
                msg=hsb.blkcb2.UtilsCodegenCb('getMessage','soc:msgs:CannotUnpackFromBytes',...
                ChBitPacked,ChLength,ChTDATAWidth,ChWidth,ChCompLength);
                error(msg);
            end
            dout=reshape(tmpdout,[ChDimensions,1]);
        end
    end

end

function haveMismatch=l_checkDims(diDims,dlgDims)
    haveMismatch=false;



    dlgElems=prod(dlgDims);
    diElems=prod(diDims);
    dlgFirstIsNumElems=(dlgDims(1)==dlgElems);
    diFirstIsNumElems=(diDims(1)==diElems);


    if(dlgElems==diElems&&dlgFirstIsNumElems&&diFirstIsNumElems)


    elseif((length(diDims)~=length(dlgDims))||...
        (~all(diDims==dlgDims)))
        haveMismatch=true;
    end

end

function haveMismatch=l_checkType(dtDType,dlgDType)
    haveMismatch=false;

    if any(strcmp(class(dtDType),{'embedded.fi','Simulink.NumericType'}))
        if any(strcmp(class(dlgDType),{'embedded.fi','Simulink.NumericType'}))

            if(dlgDType.Signed~=dtDType.Signed)||...
                (dlgDType.WordLength~=dtDType.WordLength)||...
                (dlgDType.FractionLength~=dtDType.FractionLength)
                haveMismatch=true;
            else
                haveMismatch=false;
            end
        else
            haveMismatch=true;
        end
    else
        if any(strcmp(class(dlgDType),{'embedded.fi','Simulink.NumericType'}))


            if isfloat(dtDType)
                haveMismatch=true;
            else
                T=numerictype(dtDType);
                if(dlgDType.Signed~=T.Signed)||...
                    (dlgDType.WordLength~=T.WordLength)||...
                    (dlgDType.FractionLength~=T.FractionLength)
                    haveMismatch=true;
                else
                    haveMismatch=false;
                end
            end
        else

            if~strcmp(class(dtDType),class(dlgDType))
                haveMismatch=true;
            else
                haveMismatch=false;
            end
        end
    end
end




