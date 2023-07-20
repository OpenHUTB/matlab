function boolResult=needMetricsUpdate(thisCloneGroup,newVal)







    boolResult=true;
    children=thisCloneGroup.parent.children;
    n=length(children);
    numOfChecked=0;

    for i=1:n
        if children(i).edit=='1'
            numOfChecked=numOfChecked+1;
            if numOfChecked>=2
                return;
            end
        end
    end

    if(strcmp(newVal,'1')&&numOfChecked<2)||...
        (strcmp(newVal,'0')&&numOfChecked<1)
        boolResult=false;
    end
end
