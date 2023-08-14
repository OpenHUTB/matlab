function y=validateValueByDT(candidate,type)


    type=checkNeedEval(type);
    switch class(type)
    case 'char'
        switch type
        case{'single','double'}
            min_t=-realmax(type);
            max_t=realmax(type);
        case{'uint8','uint16','uint32','uint64','int8','int16','int32','int64'}
            min_t=intmin(type);
            max_t=intmax(type);
        otherwise
            if contains(type,'fixdt')
                fdtype=eval(type);
                [min_t,max_t]=getFIMinMax(fi(0,fdtype));
            else
                error('validateRangeByDT does not know how to validate value');
            end
        end
    case 'Simulink.NumericType'
        [min_t,max_t]=getFIMinMax(fi(0,type));
    otherwise
        error('validateRangeByDT does not know how to validate value');
    end
    y=min(max(candidate,min_t),max_t);
end
function[min,max]=getFIMinMax(exemplar)

    sg=exemplar.Signed;
    wl=exemplar.WordLength;
    fl=exemplar.FractionLength;
    if sg
        min=-2^(wl-fl-1);
        max=2^(wl-fl-1)-1;
    else
        min=0;
        max=2^(wl-fl)-1;
    end
end
function ostr=checkNeedEval(istr)
    ostr=istr;
    if ischar(istr)&&...
        ~(any(strcmp(istr,{'int8','int16','int32','int64',...
        'uint8','uint16','uint32','uint64',...
        'single','double'}))||contains(istr,'fixdt'))
        ostr=evalin('base',istr);
    end
end