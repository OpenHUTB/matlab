






































function[out,e]=FddHSHarq(input,phychcap,syspriority,redversion,modulation,virtualbuffcap)


    if(isempty(input))
        out=[];
        return
    end

    [out,e]=fdd('HsdpaHarqEncoder',input,phychcap,syspriority,redversion,modulation,virtualbuffcap);
    out=double(out);


    if(size(input,1)>size(input,2))
        out=out.';
    end
end