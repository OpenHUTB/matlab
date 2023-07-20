function valueStr=getStrForCompoundType(value)










    [r,c]=size(value);
    valueStr=['<',num2str(r),'x',num2str(c),' ',class(value),'>'];
end
