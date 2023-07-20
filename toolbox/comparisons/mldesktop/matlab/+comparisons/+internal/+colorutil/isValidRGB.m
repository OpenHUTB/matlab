function bool=isValidRGB(input)




    bool=isThreeElementVector(input)&&areIntegers(input)...
    &&inRange(input,0,255);
end

function bool=isThreeElementVector(input)
    bool=isvector(input)&&length(input)==3;
end

function bool=areIntegers(input)
    bool=all(isfinite(input),'all')&&all(input==floor(input),'all');
end

function bool=inRange(input,lowerBound,upperBound)
    bool=all(input(:)>=lowerBound)&&all(input(:)<=upperBound);
end
