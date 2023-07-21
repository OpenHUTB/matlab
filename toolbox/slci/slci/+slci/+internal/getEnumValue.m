function value=getEnumValue(data)


    value=zeros(numel(data),1);
    for i=1:numel(data)
        element=data(i);
        value(i)=element.double;
    end
end

