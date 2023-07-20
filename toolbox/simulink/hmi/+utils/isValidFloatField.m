

function ret=isValidFloatField(value)

    ret=false;
    if isempty(value)||isnan(value)||~isfloat(value)||~isreal(value)
        ret=true;
    end
end
