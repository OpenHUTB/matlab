function newStrVal=simplifyString(obj,strVal)




    strVal2=strrep(strVal,'round(','');
    if~isempty(regexp(strVal2,'[a-zA-Z]','once'))
        newStrVal=strVal;
        return
    end
    [val,errStr]=obj.evaluateVariable(strVal);
    if isempty(errStr)
        newStrVal=num2str(val);
    else
        newStrVal=strVal;
    end
end
