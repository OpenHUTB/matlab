function validateIntegerRangeProperty(value,propertyName,low,high,example)




    if~isnumeric(value)||rem(value,1)~=0||value<low||value>high
        error(message('hdlcommon:plugin:IntegerRangeProperty',...
        num2str(value),propertyName,num2str(low),num2str(high),example));
    end
end