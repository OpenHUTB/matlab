function result=isDefaultProductInstalled()





    persistent HASDEFAULTPRODUCT
    if isempty(HASDEFAULTPRODUCT)
        out=ver(pmsl_defaultproduct);
        HASDEFAULTPRODUCT=~isempty(out);
    end

    result=HASDEFAULTPRODUCT;

end