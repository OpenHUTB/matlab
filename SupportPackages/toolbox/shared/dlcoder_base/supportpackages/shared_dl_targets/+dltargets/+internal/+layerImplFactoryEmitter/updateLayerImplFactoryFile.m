















function updateLayerImplFactoryFile(hN,target,codegendir)




    target=dltargets.internal.utils.getTargetCppString(target);
    fileExtension=iGetFileExtension(target);
    targetLayerImplFactory=['MW',target,'LayerImplFactory'];
    fileName=[targetLayerImplFactory,fileExtension];
    fullFileName=fullfile(codegendir,fileName);



    existingLayerSet=iParseExistingFile(fullFileName,targetLayerImplFactory);




    layerComps=hN.Components;
    builtInLayerCompIndices=arrayfun(@(x)~(x.isDLTCustomLayer()),layerComps);
    builtInLayerComps=layerComps(builtInLayerCompIndices);



    dltargets.internal.utils.makeFileWritable(fullFileName);
    fid=fopen(fullFileName,'a');
    for i=1:numel(builtInLayerComps)
        compKey=getCompKey(builtInLayerComps(i));
        layerString=dltargets.internal.convertCompKeyToLayerString(compKey);


        if~isKey(existingLayerSet,layerString)


            layerGuardName=['CREATE_',upper(layerString),'_LAYER_IMPL_DEFINITION'];
            defineGuard=['\n#ifndef ',layerGuardName,'\n#define ',layerGuardName,'\n'];
            fprintf(fid,defineGuard);



            createFunctionStruct=dltargets.internal.layerImplFactoryEmitter.populateCreateFunctionStruct(layerString,target);

            if dltargets.internal.layerImplFactoryEmitter.layerHasImpl(layerString,target)
                iEmitLayerHeaderInclude(fid,createFunctionStruct);

                if dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(layerString)


                    iEmitTemplatizedCreateLayerImplDefinition(fid,createFunctionStruct);
                else
                    iEmitCreateLayerImplDefinition(fid,createFunctionStruct);
                end
            else


                iEmitEmptyCreateLayerImplDefinition(fid,createFunctionStruct);
            end


            fprintf(fid,'\n#endif\n');

            existingLayerSet(layerString)=layerString;
        end
    end
    fclose(fid);
end

function existingLayerSet=iParseExistingFile(fileName,targetLayerImplFactory)
    fileContents=fileread(fileName);


    fileContents=dltargets.internal.utils.removeWhitespaces(fileContents);











    returnType='MWCNNLayerImplBase\*';
    layerImplFactoryQualifier=[targetLayerImplFactory,'::'];
    methodPrefix='create';
    methodSuffix='LayerImpl';






    layerNameExtractor='(?<layerName>\w*)';
    expression=[returnType,layerImplFactoryQualifier,methodPrefix,layerNameExtractor,methodSuffix];
    layerNames=regexp(fileContents,expression,'names');


    existingLayerSet=containers.Map();
    for i=1:numel(layerNames)
        layerString=layerNames(i).layerName;
        existingLayerSet(layerString)=layerString;
    end
end

function iEmitLayerHeaderInclude(fid,createFunctionStruct)





    layerHeaderInclude=['\n#include "MW',createFunctionStruct.target,createFunctionStruct.layerString,'LayerImpl.hpp"\n'];
    nbytes=fprintf(fid,layerHeaderInclude);
    assert(nbytes>0);
end

function iEmitCreateLayerImplDefinition(fid,createFunctionStruct)








    [formalParamList,~,constructorParamList]=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);

    createLayerImplDefinition=[createFunctionStruct.layerImplBase,'* ',createFunctionStruct.layerImplFactory,'::',createFunctionStruct.createFunction,formalParamList,' {\n'];
    createLayerImplDefinition=[createLayerImplDefinition,'return new ',createFunctionStruct.targetNamespace,'::',createFunctionStruct.layerImpl,constructorParamList,';\n}\n'];

    nbytes=fprintf(fid,createLayerImplDefinition);
    assert(nbytes>0);
end

function iEmitTemplatizedCreateLayerImplDefinition(fid,createFunctionStruct)















    [formalParamList,formalParamTypeList,constructorParamList]=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);


    [templateTypenameParameterList,templateParameterList]=dltargets.internal.layerImplFactoryEmitter.generateTemplateTypeLists(createFunctionStruct);


    createLayerImplDefinition=['template ',templateTypenameParameterList,'\n'];

    createLayerImplDefinition=[createLayerImplDefinition,createFunctionStruct.layerImplBase,'* ',createFunctionStruct.layerImplFactory,'::',createFunctionStruct.createFunction,formalParamList,' {\n'];
    createLayerImplDefinition=[createLayerImplDefinition,'return new ',createFunctionStruct.targetNamespace,'::',createFunctionStruct.layerImpl,templateParameterList,constructorParamList,';\n}\n\n'];



    explicitInstantiations=dltargets.internal.layerImplFactoryEmitter.generateExplicitInstantiations(createFunctionStruct,formalParamTypeList);
    createLayerImplDefinition=[createLayerImplDefinition,explicitInstantiations];

    nbytes=fprintf(fid,createLayerImplDefinition);
    assert(nbytes>0);
end

function iEmitEmptyCreateLayerImplDefinition(fid,createFunctionStruct)





    assert(~dltargets.internal.layerImplFactoryEmitter.layerHasImpl(createFunctionStruct.layerString,createFunctionStruct.target),...
    'Attempting to emit an empty createLayerImpl definition for a layer that has an impl')


    defaultParameterList=['(',createFunctionStruct.layer,'*, ',createFunctionStruct.targetNetworkImplBase,'*)'];

    emptyLayerCreateDefinition=[createFunctionStruct.layerImplBase,'* '...
    ,createFunctionStruct.layerImplFactory,'::',createFunctionStruct.createFunction,defaultParameterList...
    ,'{return NULL;}\n'];

    nbytes=fprintf(fid,emptyLayerCreateDefinition);
    assert(nbytes>0);
end

function fileExtension=iGetFileExtension(target)
    cudaTargets={'Cudnn','Tensorrt'};
    cppTargets={'Onednn','Armneon','Armmali'};
    if any(strcmpi(target,cudaTargets))
        fileExtension='.cu';
    elseif any(strcmpi(target,cppTargets))
        fileExtension='.cpp';
    else
        assert(false,'The file extension is not known for the given target.')
    end
end
