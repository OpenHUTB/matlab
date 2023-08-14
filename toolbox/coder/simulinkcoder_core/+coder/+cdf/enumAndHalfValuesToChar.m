function[isEnum,dims,enumChar]=enumAndHalfValuesToChar(enumVar)






    isEnum=false;
    dims=[];
    enumChar=[];
    if isenum(enumVar)
        dims=size(enumVar);
        enumVar=enumVar(:);




        enumChar=char(string(enumVar));
        isEnum=true;
    elseif isa(enumVar,'half')
        enumVar=cast(enumVar,'double');
        dims=size(enumVar);
        enumVar=enumVar(:);




        enumChar=char(string(enumVar));
        isEnum=true;
    end
end
