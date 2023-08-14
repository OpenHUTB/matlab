function ibits=csdrecode(inputvalue,wordsize)








    if wordsize<1
        error(message('HDLShared:directemit:badwordsize',wordsize));
    end

    switch class(inputvalue)
    case 'double'
        ibits=[0,dec2bin(abs(inputvalue),wordsize)~='0'];
    case{'uint8','int8','uint16','int16','uint32','int32','uint64','int64'}
        ibits=[0,dec2bin(abs(double(inputvalue)),wordsize)~='0'];
    case 'embedded.fi'
        ibits=[0,(bin(inputvalue)~='0')];
    end

    run=false;
    for ii=numel(ibits)-1:-1:1
        if~run&&ibits(ii)==1&&ibits(ii+1)==1
            run=true;
            ibits(ii+1)=-1;
            ibits(ii)=0;
        elseif run&&ibits(ii)==1
            ibits(ii)=0;
        elseif run
            ibits(ii)=1;
            run=false;
        end
    end

    for ii=1:numel(ibits)-2
        if ibits(ii:ii+2)==[1,0,-1]
            ibits(ii:ii+2)=[0,1,1];
        end
    end
