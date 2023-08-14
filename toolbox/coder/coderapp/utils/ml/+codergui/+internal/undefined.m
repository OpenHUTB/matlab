function result=undefined(testValue)



    if nargin>0
        result=strcmp(class(testValue),'codergui.internal.util.Undefined');%#ok<STISA>
    else
        result=codergui.internal.util.Undefined.VALUE;
    end
end