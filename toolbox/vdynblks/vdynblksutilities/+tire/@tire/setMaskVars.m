function setMaskVars(tire,block)





    m=size(tire,1);
    n=size(tire,2);
    propName=fieldnames(tire);
    paramValue=zeros(m,n);
    maskObj=get_param(block,'MaskObject');
    maskVars=maskObj.Parameters;
    varList={maskVars.Name};
    maskVarList=ismember(propName,varList);
    propName=propName(maskVarList);
    for idx=1:length(propName)
        for i=1:m
            for j=1:n
                propValue=tire(i,j).(propName{idx});
                if~isempty(propValue)&&~ischar(propValue)
                    paramValue(i,j)=tire(i,j).(propName{idx});
                    set_param(block,[propName{idx}],mat2str(paramValue));
                end
            end
        end

    end
end

