function[factors,isneg,factorlength,finalshift]=csdfactors(ival,ivalbp)







    if nargin==1
        ivalbp=0;
    end

    switch class(ival)
    case 'double'
        val=floor(ival*2^ivalbp+0.5);
        vallog2=hdl.ceillog2(val);
    case{'uint8','int8','uint16','int16','uint32','int32'}
        val=double(ival);
        vallog2=ceil(log2(abs(val)));
    case 'uint64'
        val=fi(ival,0,64,0);
        vallog2=hdl.ceillog2(val);
    case 'int64'
        val=fi(ival,1,64,0);
        vallog2=hdl.ceillog2(val);
    case 'embedded.fi'
        val=reinterpretcast(ival,numerictype(ival.signed,ival.wordLength,0));
        val.bin=ival.bin;
        vallog2=hdl.ceillog2(val);
    end

    isneg=(val<0);
    tmp_val=abs(val);
    factors=[];
    for ii=vallog2:-1:3
        high=tmp_val/((2.^ii)+1);
        if floor(high)==high
            factors(end+1)=((2.^ii)+1);
            tmp_val=high;
        end
        low=tmp_val/((2.^ii)-1);
        if floor(low)==low
            factors(end+1)=((2.^ii)-1);
            tmp_val=low;
        end
    end

    if tmp_val~=1
        factors=[factors,factor(tmp_val)];
    end
    factors=sort(factors);
    factors=factors(end:-1:1);

    findtwos=find(factors==2);
    if isempty(findtwos)
        factorlength=length(factors);
        finalshift=0;
    else
        factorlength=findtwos(1)-1;
        finalshift=length(findtwos);
    end


