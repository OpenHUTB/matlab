function[str]=cellArr2Str(~,signalArray)





    if isempty(signalArray)||~iscell(signalArray)
        str='';
    else
        l=join(signalArray,',');
        str=char(l);
    end
