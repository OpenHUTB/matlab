function validateValueWithinRange(value,propertyName,valueRangeVector,example)






    minValue=valueRangeVector(1);
    maxValue=valueRangeVector(2);

    if(value<minValue)||(value>maxValue)
        error(message('hdlcommon:plugin:ValueNotWithinRange',...
        value,propertyName,minValue,maxValue,example));

    end


end


