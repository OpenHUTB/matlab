function strVal=launchColorPicker(currentValue,label)







    [currentRgb,valid]=lGetBlockColorArg(currentValue);


    strVal=missing;
    if valid
        newRgb=uisetcolor(currentRgb,label);
    else
        newRgb=uisetcolor(label);
    end




    if~isequal(newRgb,0)&&~isequal(newRgb,currentRgb)
        strVal=mat2str(newRgb,4);
    end
end

function[v,valid]=lGetBlockColorArg(currentValue)



    v=currentValue.value('1');
    valid=lCorrectType(v)&&lCorrectSize(v)&&lCorrectRange(v);
end


function result=lCorrectSize(v)
    result=numel(v)==3;
end

function result=lCorrectType(v)
    result=isnumeric(v);
end

function result=lCorrectRange(v)
    result=all(v<=1&v>=0);
end
