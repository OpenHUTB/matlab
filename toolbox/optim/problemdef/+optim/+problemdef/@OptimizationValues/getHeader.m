function header=getHeader(obj)









    className=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
    dimStr=matlab.mixin.CustomDisplay.convertDimensionsToString(obj);


    if isempty(obj)
        header=getString(message('optim_problemdef:OptimizationValues:getHeader:EmptyHeader',dimStr,className));
    elseif isscalar(obj)
        header=getString(message('optim_problemdef:OptimizationValues:getHeader:ScalarHeader',className));
    else
        header=getString(message('optim_problemdef:OptimizationValues:getHeader:VectorHeader',dimStr,className));
    end


    header=[blanks(2),header,newline];

end