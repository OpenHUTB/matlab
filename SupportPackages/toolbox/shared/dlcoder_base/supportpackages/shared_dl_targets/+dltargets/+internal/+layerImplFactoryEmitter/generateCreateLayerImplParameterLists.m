















function[formalParamList,formalParamTypeList,constructorParamList]=generateCreateLayerImplParameterLists(createFunctionStruct)





    assert(iscell(createFunctionStruct.createArgTypes)&~isempty(createFunctionStruct.createArgTypes),'createArgTypes should be a nonempty cell array');
    formalParamList='(';
    formalParamTypeList='(';
    constructorParamList='(';



    for i=1:numel(createFunctionStruct.createArgTypes)

        argumentType=createFunctionStruct.createArgTypes{i};









        if strcmp(argumentType,[createFunctionStruct.targetNetworkImpl,'*'])
            assert(dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(createFunctionStruct.layerString),...
            'We should not encounter a formal parameter of type MWTargetNetworkImpl unless we are parsing a templatized layer constructor declaration.');
            argumentType=[createFunctionStruct.targetNetworkImplBase,'*'];
        end

        argumentName=['arg',num2str(i)];

        formalParamList=[formalParamList,argumentType,' ',argumentName,',\n'];%#ok
        formalParamTypeList=[formalParamTypeList,argumentType,',\n'];%#ok

        if strcmp(argumentType,[createFunctionStruct.targetNetworkImplBase,'*'])

            argumentName=['static_cast<',createFunctionStruct.targetNamespace,'::',createFunctionStruct.targetNetworkImpl,'*>(',argumentName,')'];%#ok
        end

        constructorParamList=[constructorParamList,argumentName,',\n'];%#ok
    end


    formalParamList=extractBefore(formalParamList,numel(formalParamList)-2);
    formalParamTypeList=extractBefore(formalParamTypeList,numel(formalParamTypeList)-2);
    constructorParamList=extractBefore(constructorParamList,numel(constructorParamList)-2);


    formalParamList=[formalParamList,')'];
    formalParamTypeList=[formalParamTypeList,')'];
    constructorParamList=[constructorParamList,')'];
end
