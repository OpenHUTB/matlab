function flag=validateIPAddressFormat(aAddrs,addrsName)













    narginchk(2,2);

    if(~ischar(aAddrs))
        flag=false;
        return;
    end
    if(~isrow(aAddrs))
        flag=false;
        return;
    end


    dotIndices=find(aAddrs=='.');

    if(length(dotIndices)~=3)
        flag=false;
        return;
    end


    num1=aAddrs(1:dotIndices(1)-1);
    num2=aAddrs(dotIndices(1)+1:dotIndices(2)-1);
    num3=aAddrs(dotIndices(2)+1:dotIndices(3)-1);
    num4=aAddrs(dotIndices(3)+1:length(aAddrs));
    minValue=0;
    maxValue=255;

    flag=checkNumeric(str2double(num1),minValue,maxValue);
    if(flag==false)
        return;
    end
    flag=checkNumeric(str2double(num2),minValue,maxValue);
    if(flag==false)
        return;
    end
    flag=checkNumeric(str2double(num3),minValue,maxValue);
    if(flag==false)
        return;
    end
    flag=checkNumeric(str2double(num4),minValue,maxValue);
    if(flag==false)
        return;
    end

    flag=true;
end

function flag=checkNumeric(x,minValue,maxValue)
    if(isempty(x)||any(~((x>=minValue)&(x<=maxValue))))
        flag=false;
        return;
    end
    flag=true;
end
