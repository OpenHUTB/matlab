function out=setHilited(url)




    persistent hilited;

    narginchk(1,1);
    prev=hilited;
    hilited=url;


    if~isempty(prev)&&isempty(hilited)
        if iscell(prev)
            prev=prev{1};
        end
        mdl=strtok(prev,':');
        if isValidSlObject(slroot,mdl)
            slprivate('remove_hilite',mdl);
        end
    end

    out=prev;

