function PropErrorStr(h,prop)









    setnames=h.findProp(prop);
    if isempty(setnames)
        error(message('HDLShared:propset:propNotFound',prop));
    else

        s='';
        for i=1:size(setnames,1)
            s=sprintf('%s  %s\n',s,hierAddrStr(setnames(i,:)));
        end
        error(message('HDLShared:propset:propFoundDisabled',prop,s));
    end


    function y=hierAddrStr(s)


        arrw=repmat({' -> '},size(s));
        y=[s;arrw];
        y=[y{1:end-1}];
