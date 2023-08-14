function bitWidth=getSignalBitWidth(this,Signal)%#ok<INUSL>

    if strfind(Signal.FiType,'std')
        bitWidth=str2double(regexprep(Signal.FiType,'std',''));
    else
        a=hdlgetallfromsltype(Signal.FiType);
        bitWidth=a.size;
    end