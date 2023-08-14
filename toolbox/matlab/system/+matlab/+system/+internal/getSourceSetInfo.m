function info=getSourceSetInfo(obj)




    propOrInput=makePropertyOrInputPolicy({},{},{},{});
    propOrMethod=makePropertyOrMethodPolicy({},{},{});
    propertyOnly=makeTargetPropertyPolicy({});
    disabled=makeTargetPropertyPolicy({});

    if~obj.hasSourceSets()
        info=makeTopLevelStruct(propOrInput,propOrMethod,propertyOnly,disabled);
        return
    end


    m=metaclass(obj);
    mpList=m.PropertyList;

    sourceSetIdx=false(numel(mpList),1);

    for i=1:numel(mpList)
        mp=mpList(i);
        if isa(mp,'matlab.system.CustomMetaProp')
            sourceSetIdx(i)=mp.PropertyPortPolicy;
        end
    end

    sourceSetMetaProperties=mpList(sourceSetIdx);

    mmList=m.MethodList;

    for sourceSetMetaProp=sourceSetMetaProperties(:)'
        sourceSet=sourceSetMetaProp.DefaultValue;
        policy=getPolicy(sourceSet,obj.getExecPlatformIndex());
        if isa(policy,'matlab.system.internal.PropertyOrInput')
            propOrInput=addPropertyOrInputPolicy(propOrInput,obj,policy,sourceSetMetaProp.Name);

        elseif isa(policy,'matlab.system.internal.PropertyOrMethod')
            propOrMethod=addPropertyOrMethodPolicy(propOrMethod,obj,policy,sourceSetMetaProp,mmList);

        elseif isa(policy,'matlab.system.internal.PropertyOnly')
            propertyOnly=addTargetNameOnlyPolicy(propertyOnly,sourceSetMetaProp);

        else
            assert(isa(policy,'matlab.system.internal.DisabledOnly'))
            disabled=addTargetNameOnlyPolicy(disabled,sourceSetMetaProp);
        end
    end

    propOrInput=sortPropertyOrInputByIndex(propOrInput);


    validateParamPortIndices(propOrInput);


    propOrInput=renumberPropertyOrInputIndices(propOrInput);

    info=makeTopLevelStruct(propOrInput,propOrMethod,propertyOnly,disabled);
end

function policies=addTargetNameOnlyPolicy(policies,mp)
    newPolicy=makeTargetPropertyPolicy(getTargetPropName(mp.Name));

    policies=[policies;newPolicy];
end

function newPolicy=makeTargetPropertyPolicy(targetPropName)
    newPolicy=struct('TargetProp',targetPropName);
end

function policies=addPropertyOrInputPolicy(policies,sysobj,policyObj,setPropName)

    targetPropName=getTargetPropName(setPropName);


    useInput=~useProperty(policyObj,sysobj,targetPropName);

    newPolicy=makePropertyOrInputPolicy(targetPropName,...
    useInput,...
    policyObj.InputOrdinal,...
    policyObj.InputLabel);

    policies=[policies;newPolicy];
end

function newPolicy=makePropertyOrInputPolicy(targetPropName,useInput,inputIndex,inputLabel)
    newPolicy=struct('TargetProp',targetPropName,...
    'UseInput',useInput,...
    'Index',inputIndex,...
    'InputLabel',inputLabel);
end

function policies=addPropertyOrMethodPolicy(policies,sysObj,policyObj,mp,mmList)
    targetPropName=getTargetPropName(mp.Name);

    useMethod=~useProperty(policyObj,sysObj,targetPropName);

    methodName=policyObj.MethodName;

    newPolicy=makePropertyOrMethodPolicy(targetPropName,...
    useMethod,...
    methodName);


    if useMethod
        validatePropMethod(methodName,mmList);
    end

    policies=[policies;newPolicy];
end

function newPolicy=makePropertyOrMethodPolicy(targetPropName,useMethod,methodName)
    newPolicy=struct('TargetProp',targetPropName,...
    'UseMethod',useMethod,...
    'MethodName',methodName);
end

function validatePropMethod(methodName,mmList)

    methodObj=findobj(mmList,'Name',methodName);

    if isempty(methodObj)

        error(message('MATLAB:system:sourceSetControlMethodMissing',methodName));
    end

    if methodObj.Static||methodObj.Abstract
        error(message('MATLAB:system:sourceSetControlMethodStaticAbstract',methodName));
    end

    if(size(methodObj.InputNames,1)~=1)
        error(message('MATLAB:system:sourceSetControlMethodInvalid',methodName));
    end
end

function paramPort=sortPropertyOrInputByIndex(paramPort)
    [~,permIdx]=sort([paramPort.Index]);
    paramPort=paramPort(permIdx);
end

function validateParamPortIndices(paramPort)



    for n=1:numel(paramPort)
        if paramPort(n).Index>n
            error(message('MATLAB:system:missingPropertyPortIndex',n));
        elseif paramPort(n).Index<n
            error(message('MATLAB:system:duplicatePropertyPortIndex',n));
        end
    end
end

function paramPort=renumberPropertyOrInputIndices(paramPort)
    idxCounter=1;
    for idx=1:numel(paramPort)
        if paramPort(idx).UseInput
            paramPort(idx).Index=idxCounter;
            idxCounter=idxCounter+1;
        else
            paramPort(idx).Index=0;
        end
    end
end

function info=makeTopLevelStruct(propOrInput,propOrMethod,propertyOnly,disabled)
    info=struct('PropertyOrInput',propOrInput,...
    'PropertyOrMethod',propOrMethod,...
    'PropertyOnly',propertyOnly,...
    'Disabled',disabled);
end

function targetPropName=getTargetPropName(setPropName)
    targetPropName=extractBefore(setPropName,strlength(setPropName)-2);
end
