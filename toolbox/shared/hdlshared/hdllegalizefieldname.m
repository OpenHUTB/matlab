function out=hdllegalizefieldname(in)





    if isempty(in)||~ischar(in)
        error(message('HDLShared:directemit:illegalarg'));
    end



    out=strrep(in,'&','and');







    out=regexprep(out,'\W','_');



    out=lower(out);


