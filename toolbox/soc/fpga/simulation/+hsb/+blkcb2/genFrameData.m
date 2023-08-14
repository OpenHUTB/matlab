function[data,err]=genFrameData(dim,exemplar,chwidth,tnum,cntriv,mode)


    type=class(exemplar);
    if~hsb.blkcb2.getDTypeSigned(type,exemplar)&&cntriv<0
        cntriv=0;
    end

    persistent cnt
    if tnum==0
        cnt=double(cntriv);
    end
    err=0;
    dimflt=prod(dim(1:end));


    genhdlr_i=struct('random',@getRandomInt,...
    'counter',@getCounterInt,...
    'ones',@getOnes);
    genhdlr_i64=struct('random',@getRandomInt64,...
    'counter',@getCounterInt,...
    'ones',@getOnes);
    genhdlr_f=struct('random',@getRandom,...
    'counter',@getCounter,...
    'ones',@getOnes);
    genhdlr_fi=struct('random',@getRandomFI,...
    'counter',@getCounterFI,...
    'ones',@getOnes);

    switch class(type)
    case 'char'
        switch type
        case{'uint8','uint16','uint32','int8','int16','int32'}
            if strcmp(mode,'counter')
                [data,cnt]=genhdlr_i.(mode)(dimflt,type,chwidth,cntriv,tnum,cnt);
            else
                data=genhdlr_i.(mode)(dimflt,type,chwidth,cntriv,tnum);
            end
        case{'uint64','int64'}
            if strcmp(mode,'counter')
                [data,cnt]=genhdlr_i64.(mode)(dimflt,type,chwidth,cntriv,tnum,cnt);
            else
                data=genhdlr_i64.(mode)(dimflt,type,chwidth,cntriv,tnum);
            end
        case{'double','single'}
            data=genhdlr_f.(mode)(dimflt,type,chwidth,cntriv,tnum);
        otherwise
            if contains(type,'fixdt')
                if strcmp(mode,'counter')
                    [data,cnt]=genhdlr_fi.(mode)(dimflt,exemplar,chwidth,cntriv,tnum,cnt);
                else
                    data=genhdlr_fi.(mode)(dimflt,exemplar,chwidth,cntriv,tnum);
                end
            elseif contains(type,'embedded.fi')
                if strcmp(mode,'counter')
                    [data,cnt]=genhdlr_fi.(mode)(dimflt,exemplar,chwidth,cntriv,tnum,cnt);
                else
                    data=genhdlr_fi.(mode)(dimflt,exemplar,chwidth,cntriv,tnum);
                end
            else
                data=ones(1,dimflt);
                err=1;
            end
        end
    case 'Simulink.NumericType'
        data=genhdlr_fi.(mode)(dimflt,type,chwidth,cntriv,tnum);
    otherwise
        data=ones(1,dimflt);
        err=1;
    end
end



function da=getRandomInt(dimf,type,chwidth,cntriv,tnum)%#ok
    da=randi([intmin(type),intmax(type)],1,dimf,type);
end

function da=getRandomInt64(dimf,type,chwidth,cntriv,tnum)%#ok
    switch type
    case 'int64'
        da=cast((rand(1,dimf,'double')-0.5)*double(intmax(type)),type);
    otherwise
        da=cast(rand(1,dimf,'double')*double(intmax(type)),type);
    end
end

function[da,cnt]=getCounterInt(dimf,type,chwidth,cntriv,tnum,cnt)%#ok








    da=[];
    for i=1:dimf
        if cnt>intmax(type)
            cnt=double(intmin(type));
        end
        da(end+1)=cnt;%#ok<AGROW>
        cnt=cnt+1;
    end

end
function da=getOnes(dimf,type,chwidth,cntriv,tnum,varargin)%#ok
    if~ischar(type)
        da=(2^chwidth-1)*ones(dimf,1,'like',type);
    else
        da=(2^chwidth-1)*ones(dimf,1,type);
    end
end


function da=getRandom(dimf,type,chwidth,cntriv,tnum)%#ok
    da=rand(1,dimf,type);
end
function da=getCounter(dimf,type,chwidth,cntriv,tnum)%#ok
    da=(cntriv:cntriv+dimf-1)+rand(1,dimf,type)+dimf*tnum;
end


function da=getRandomFI(dimf,exemplar,chwidth,cntriv,tnum)%#ok
    sg=exemplar.Signed;
    wl=exemplar.WordLength;
    fl=exemplar.FractionLength;
    maxfi=2^(wl-fl);
    if sg
        da=fi((rand(1,dimf,'double')-0.5)*maxfi,sg,wl,fl)';
    else
        da=fi(rand(1,dimf,'double')*maxfi,sg,wl,fl)';
    end
end
function[da,cnt]=getCounterFI(dimf,exemplar,chwidth,cntriv,tnum,cnt)%#ok
    sg=exemplar.Signed;
    wl=exemplar.WordLength;
    fl=exemplar.FractionLength;
    [minfi,maxfi]=getFIMinMax(sg,wl,fl);


    data=[];
    for i=1:dimf
        if cnt>maxfi
            cnt=double(minfi);
        end
        data(end+1)=cnt;%#ok<AGROW>
        cnt=cnt+1;
    end

    if fl
        da=fi(data'+rand(dimf,1,'double'),sg,wl,fl);
    else
        da=fi(data',sg,wl,fl);
    end
end
function[min,max]=getFIMinMax(sg,wl,fl)

    if sg
        min=-2^(wl-fl-1);
        max=2^(wl-fl-1)-1;
    else
        min=0;
        max=2^(wl-fl)-1;
    end
end

