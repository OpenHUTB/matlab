function val=getTitle(p,place)


    if nargin<2
        place='top';
    end
    if strcmpi(place,'top')
        h=p.hTitleTop;
    else
        h=p.hTitleBottom;
    end
    if isempty(h)
        val='';
    else
        str=h.String;


        val=downdateDataLabels(str);




        if iscell(val)&&isscalar(val)
            val=val{1};
        end
    end
