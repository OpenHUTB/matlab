function validateNonNegIntegerProperty(value,propertyName,example)




    if~isnumeric(value)||rem(value,1)~=0||value<0
        error(message('hdlcommon:plugin:NonNegIntegerProperty',...
        num2str(value),propertyName,example));
    end
end