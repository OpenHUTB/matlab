function enumStr=logicalToString(logicalValue,trueValue,falseValue)




    enumStr=falseValue;
    if(logicalValue)
        enumStr=trueValue;
    end
end
