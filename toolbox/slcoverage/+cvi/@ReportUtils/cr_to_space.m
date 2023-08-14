function out=cr_to_space(in)




    out=in;
    if~isempty(in)
        out(in==10)=char(32);
    end

