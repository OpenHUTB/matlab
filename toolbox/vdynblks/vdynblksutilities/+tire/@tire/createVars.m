function createVars(tire)




    m=size(tire,1);
    n=size(tire,2);
    propName=fieldnames(tire);
    paramValue=zeros(m,n);
    ok2dump=false;
    for idx=1:length(propName)
        for i=1:m
            for j=1:n
                propValue=tire(i,j).(propName{idx});
                if~isempty(propValue)&&~ischar(propValue)
                    paramValue(i,j)=tire(i,j).(propName{idx});
                    ok2dump=true;
                else
                    ok2dump=false;
                end
            end
        end
        if ok2dump
            assignin('caller',[propName{idx}],paramValue);
        end
    end
end

