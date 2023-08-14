function tpinfo=pirgetvaluetypeinfo(hVal)

















    tpinfo.iscomplex=0;
    tpinfo.numdims=1;
    tpinfo.dims=1;
    tpinfo.isscalar=1;
    tpinfo.isvector=0;
    tpinfo.ismatrix=0;
    tpinfo.vector=0;
    tpinfo.isrowvec=0;
    tpinfo.iscolvec=0;
    tpinfo.isnative=1;
    tpinfo.isdouble=0;
    tpinfo.issingle=0;
    tpinfo.ishalf=0;
    tpinfo.isfloat=0;


    if~isreal(hVal)
        tpinfo=pirgetvaluetypeinfo(real(hVal));
        tpinfo.iscomplex=1;
    elseif~isscalar(hVal)
        tpinfo=pirgetvaluetypeinfo(hVal(1));
        tpinfo.numdims=length(size(hVal));
        tpinfo.dims=size(hVal);
        tpinfo.isscalar=0;
        tpinfo.isvector=1;
        tpinfo.isrowvec=isrow(hVal);
        tpinfo.iscolvec=iscolumn(hVal);
        tpinfo.ismatrix=~(tpinfo.isrowvec||tpinfo.iscolvec);
    else
        switch class(hVal)
        case 'double'
            tpinfo.sltype='double';
            tpinfo.issigned=1;
            tpinfo.wordsize=64;
            tpinfo.binarypoint=52;
            tpinfo.isdouble=1;
            tpinfo.isfloat=1;
        case 'single'
            tpinfo.sltype='double';
            tpinfo.issigned=1;
            tpinfo.wordsize=32;
            tpinfo.binarypoint=23;
            tpinfo.issingle=1;
            tpinfo.isfloat=1;
        case 'half'
            tpinfo.sltype='fixdt(''half'')';
            tpinfo.issigned=1;
            tpinfo.wordsize=16;
            tpinfo.binarypoint=10;
            tpinfo.ishalf=1;
            tpinfo.isfloat=1;
            tpinfo.isnative=0;
        case 'logical'
            tpinfo.sltype='boolean';
            tpinfo.wordsize=1;
            tpinfo.issigned=0;
            tpinfo.binarypoint=0;
        case{'int8','int16','int32','int64',...
            'uint8','uint16','uint32','uint64'}
            cls=class(hVal);
            tpinfo.sltype=cls;
            tpinfo.issigned=strcmpi(cls(1),'i');
            if tpinfo.issigned
                tpinfo.wordsize=str2double(strtok(cls,'int'));
            else
                tpinfo.wordsize=str2double(strtok(cls,'uint'));
            end
            tpinfo.binarypoint=0;
        case 'embedded.fi'
            tpinfo.isnative=0;
            tpinfo.wordsize=hVal.WordLength;
            tpinfo.issigned=hVal.Signed;
            tpinfo.binarypoint=-hVal.FractionLength;

            if hVal.Signed
                c='s';
            else
                c='u';
            end

            if tpinfo.binarypoint>0
                bpstr=sprintf('_E%d',tpinfo.binarypoint);
            elseif tpinfo.binarypoint<0
                bpstr=sprintf('_En%d',-tpinfo.binarypoint);
            else
                bpstr='';
            end
            tpinfo.sltype=sprintf('%sfix%s%d',c,bpstr,tpinfo.wordsize);
        otherwise
            cls=class(hVal);
            if isSLEnumType(cls)
                tpinfo.sltype=sprintf('Enum: %s',cls);
            else
                error(message('hdlcommon:hdlcommon:unhandleddatatype',cls));
            end
        end
    end
end
