function ret=isAcceptableTargetDataParentClass(h)












    ret=false;
    acceptableTDParentBaseClassNames=...
    Simulink.dd.getAcceptableTargetDataParentBaseClassNames;
    objClsName=class(h);

    for i=1:numel(acceptableTDParentBaseClassNames)

        if strcmp(objClsName,acceptableTDParentBaseClassNames{i})
            ret=true;
            break;
        else

            if isa(h,acceptableTDParentBaseClassNames{i})
                if~additionalPropertiesExist(h,acceptableTDParentBaseClassNames{i})
                    ret=true;
                    break;
                end
            end
        end
    end

end




function ret=additionalPropertiesExist(h,fullBaseClassName)



    ret=true;


    persistent baseClassProperties;
    if isempty(baseClassProperties)
        baseClassProperties=struct;
    end


    tokens=regexp(fullBaseClassName,'\.','split');
    try
        basicProps=getfield(baseClassProperties,tokens{:});
    catch E %#ok<NASGU>
        basicObj=eval(fullBaseClassName);
        basicProps=Simulink.data.getPropList(basicObj);
        baseClassProperties=setfield(baseClassProperties,tokens{:},basicProps);
    end

    allProps=Simulink.data.getPropList(h);


    if(length(basicProps)==length(allProps))
        ret=false;
    end;

end


