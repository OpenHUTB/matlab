function y=getDTypeSigned(type,varargin)


    switch class(type)
    case 'char'
        noapostdtype=strrep(type,'''','');
        if(contains(type,'fixdt'))
            noapostdtype=eval(noapostdtype);
            y=noapostdtype.Signed;
        elseif(contains(type,'embedded.fi'))
            y=strcmpi(varargin{1}.Signedness,'Signed');
        else
            switch(noapostdtype)
            case{'uint8','uint16','uint32','uint64'}
                y=false;
            case{'int8','int16','int32','int64','single','double'}
                y=true;
            otherwise
                error('Unknown dtype');
            end
        end
    case 'Simulink.NumericType'
        y=type.Signed;
    otherwise
        error(['Bad data type for channel. '...
        ,'It should be char or Simulink.NumericType']);
    end
end