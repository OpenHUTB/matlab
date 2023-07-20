function printXEqualsLine(obj,className,dimstr)












    if isInitialized(obj)
        type=string(getType(obj))+" ";
    else
        type="";
    end

    if nargin>2

        typeStr=dimstr+" "+type+className;
        xeqStr=getString(message('shared_adlib:printXEqualsLine:Array',typeStr));
    else

        xeqStr=type+className;
    end


    fprintf('  %s\n\n',xeqStr);