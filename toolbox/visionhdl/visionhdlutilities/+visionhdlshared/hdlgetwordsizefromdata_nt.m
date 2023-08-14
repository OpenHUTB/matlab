function[WL,FL,signed]=hdlgetwordsizefromdata_nt(data)






%#codegen
    coder.allowpcode('plain');

    if isinteger(data)||islogical(data)
        classtype=class(data);
        n=numerictype(classtype);
        WL=n.WordLength;
        FL=n.FractionLength;
        signed=n.SignednessBool;
    elseif isfloat(data)
        WL=0;
        FL=0;
        signed=1;
    elseif isa(data,'embedded.fi')

        n=numerictype(data);
        if n.isscalingbinarypoint&&n.isfixed
            WL=n.WordLength;
            FL=n.FractionLength;
            signed=n.SignednessBool;
        else
            WL=0;
            FL=0;
            signed=0;
        end
    else
        WL=0;
        FL=0;
        signed=0;

    end
end
