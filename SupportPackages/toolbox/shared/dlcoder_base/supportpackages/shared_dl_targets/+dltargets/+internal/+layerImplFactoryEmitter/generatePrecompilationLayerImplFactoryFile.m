










function generatePrecompilationLayerImplFactoryFile(target,workingDir)

    cppTargetString=dltargets.internal.utils.getTargetCppString(target);
    switch target
    case 'mkldnn'
        target='onednn';
    otherwise

    end


    fileExtension='.hpp';
    targetLayerImplFactory=['MW',cppTargetString,'LayerImplFactory'];
    fileName=[targetLayerImplFactory,'_precompile',fileExtension];

    layerImplFactoryFile=fullfile(workingDir,fileName);

    fidLayerImplFactory=fopen(layerImplFactoryFile,'w');


    fileName=['MW',cppTargetString,'LayerImpls_precompile',fileExtension];

    layerImplsFile=fullfile(workingDir,fileName);

    fidLayerImpls=fopen(layerImplsFile,'w');

    iEmitCopyright(fidLayerImplFactory);
    iEmitCopyright(fidLayerImpls);

    iEmitStartOfFile(fidLayerImplFactory,cppTargetString);


    compKeys=dltargets.(target).SupportedLayerImpl.m_supportedLayers;


    layerStrings=cellfun(@(x)dltargets.internal.convertCompKeyToLayerString(x),compKeys,'UniformOutput',false);



    layerStrings=layerStrings(cellfun(@(x)~isempty(x),layerStrings));



    layerStrings=unique(layerStrings);

    for i=1:numel(layerStrings)
        layerString=layerStrings{i};



        createFunctionStruct=dltargets.internal.layerImplFactoryEmitter.populateCreateFunctionStruct(layerString,cppTargetString);

        if dltargets.internal.layerImplFactoryEmitter.layerHasImpl(layerString,cppTargetString)
            iEmitLayerHeaderInclude(fidLayerImpls,createFunctionStruct);

            if dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(layerString)


                iEmitTemplatizedCreateLayerImplDefinition(fidLayerImplFactory,createFunctionStruct);
            else
                iEmitCreateLayerImplDefinition(fidLayerImplFactory,createFunctionStruct);
            end
        else


            iEmitEmptyCreateLayerImplDefinition(fidLayerImplFactory,createFunctionStruct);
        end
    end

    iEmitClassClosingBrace(fidLayerImplFactory);



    isTemplatizedLayerString=cellfun(@(x)dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(x),layerStrings);
    templatizedLayerStrings=layerStrings(isTemplatizedLayerString);
    for i=1:numel(templatizedLayerStrings)
        layerString=templatizedLayerStrings{i};
        createFunctionStruct=dltargets.internal.layerImplFactoryEmitter.populateCreateFunctionStruct(layerString,cppTargetString);
        iEmitTemplatizedCreateLayerImplInstantiations(fidLayerImplFactory,createFunctionStruct);
    end

    iEmitEndOfFile(fidLayerImplFactory);

    fclose(fidLayerImplFactory);
    fclose(fidLayerImpls);
end


function iEmitCopyright(fid)
    fprintf(fid,'/* Copyright 2021-2022 The MathWorks, Inc. */\n');
end





















function iEmitStartOfFile(fid,cppTargetString)

    headerGuard=['MW_',upper(cppTargetString),'_LAYER_IMPL_FACTORY_PRECOMPILE'];



    fprintf(fid,['#ifndef ',headerGuard,'\n']);
    fprintf(fid,['#define ',headerGuard,'\n']);








    fprintf(fid,'#ifdef PRECOMPILE_LAYERFILES\n');
    fprintf(fid,'#include "layer/MWLayerImplFactory.hpp"\n');
    fprintf(fid,'#else\n');
    fprintf(fid,'#include "MWLayerImplFactory.hpp"\n');
    fprintf(fid,'#endif\n');
    fprintf(fid,['#include "MW',cppTargetString,'TargetNetworkImpl.hpp"\n']);
    fprintf(fid,['#include "MW',cppTargetString,'LayerImpls_precompile.hpp"\n']);



    fprintf(fid,'class MWCNNLayer;\n');
    fprintf(fid,'class MWCNNLayerImplBase;\n');


    layerImplFactoryClass=['MW',cppTargetString,'LayerImplFactory'];
    fprintf(fid,['class ',layerImplFactoryClass,' final : public MWLayerImplFactory {\n']);


    fprintf(fid,'public:\n');


    fprintf(fid,['MW',cppTargetString,'LayerImplFactory() {}\n']);


    fprintf(fid,['virtual ~MW',cppTargetString,'LayerImplFactory() {}\n']);
end


function iEmitClassClosingBrace(fid)

    fprintf(fid,'}; \n');
end


function iEmitEndOfFile(fid)

    fprintf(fid,'#endif');
end

function iEmitLayerHeaderInclude(fid,createFunctionStruct)





    layerHeaderInclude=['\n#include "MW',createFunctionStruct.target,createFunctionStruct.layerString,'LayerImpl.hpp"\n'];
    nbytes=fprintf(fid,layerHeaderInclude);
    assert(nbytes>0);
end

function iEmitCreateLayerImplDefinition(fid,createFunctionStruct)








    [formalParamList,~,constructorParamList]=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);

    createLayerImplDefinition=[createFunctionStruct.layerImplBase,'* ',createFunctionStruct.createFunction,formalParamList,' {\n'];
    createLayerImplDefinition=[createLayerImplDefinition,'return new ',createFunctionStruct.targetNamespace,'::',createFunctionStruct.layerImpl,constructorParamList,';\n}\n'];

    nbytes=fprintf(fid,createLayerImplDefinition);
    assert(nbytes>0);
end

function iEmitTemplatizedCreateLayerImplDefinition(fid,createFunctionStruct)











    [formalParamList,~,constructorParamList]=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);


    [templateTypenameParameterList,templateParameterList]=dltargets.internal.layerImplFactoryEmitter.generateTemplateTypeLists(createFunctionStruct);


    createLayerImplDefinition=['template ',templateTypenameParameterList,'\n'];

    createLayerImplDefinition=[createLayerImplDefinition,createFunctionStruct.layerImplBase,'* ',createFunctionStruct.createFunction,formalParamList,' {\n'];
    createLayerImplDefinition=[createLayerImplDefinition,'return new ',createFunctionStruct.targetNamespace,'::',createFunctionStruct.layerImpl,templateParameterList,constructorParamList,';\n}\n\n'];

    nbytes=fprintf(fid,createLayerImplDefinition);
    assert(nbytes>0);
end

function iEmitTemplatizedCreateLayerImplInstantiations(fid,createFunctionStruct)







    [~,formalParamTypeList]=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);



    explicitInstantiations=dltargets.internal.layerImplFactoryEmitter.generateExplicitInstantiations(createFunctionStruct,formalParamTypeList);

    nbytes=fprintf(fid,explicitInstantiations);
    assert(nbytes>0);
end

function iEmitEmptyCreateLayerImplDefinition(fid,createFunctionStruct)





    assert(~dltargets.internal.layerImplFactoryEmitter.layerHasImpl(createFunctionStruct.layerString,createFunctionStruct.target),...
    'Attempting to emit an empty createLayerImpl definition for a layer that has an impl')


    defaultParameterList=['(',createFunctionStruct.layer,'*, ',createFunctionStruct.targetNetworkImplBase,'*)'];

    emptyLayerCreateDefinition=[createFunctionStruct.layerImplBase,'* '...
    ,createFunctionStruct.createFunction,defaultParameterList...
    ,'{return NULL;}\n'];

    nbytes=fprintf(fid,emptyLayerCreateDefinition);
    assert(nbytes>0);
end
