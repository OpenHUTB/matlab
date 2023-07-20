











function updateLayerImplFactoryHeader(hN,target,codegendir)




    target=dltargets.internal.utils.getTargetCppString(target);
    fileName=['MW',target,'LayerImplFactory.hpp'];
    fullFileName=fullfile(codegendir,fileName);





    [bufferToWrite,existingLayerSet]=iParseExistingFile(fullFileName);


    dltargets.internal.utils.makeFileWritable(fullFileName);
    fid=fopen(fullFileName,'w');
    assert(ftell(fid)==0);




    fprintf(fid,bufferToWrite);




    layerComps=hN.Components;
    builtInLayerCompIndices=arrayfun(@(x)~(x.isDLTCustomLayer()),layerComps);
    builtInLayerComps=layerComps(builtInLayerCompIndices);

    for i=1:numel(builtInLayerComps)
        compKey=getCompKey(builtInLayerComps(i));
        layerString=dltargets.internal.convertCompKeyToLayerString(compKey);


        if~isKey(existingLayerSet,layerString)


            layerGuardName=['CREATE_',upper(layerString),'_LAYER_IMPL_DECLARATION'];
            defineGuard=['\n#ifndef ',layerGuardName,'\n#define ',layerGuardName,'\n'];
            fprintf(fid,defineGuard);



            createFunctionStruct=dltargets.internal.layerImplFactoryEmitter.populateCreateFunctionStruct(layerString,target);

            if dltargets.internal.layerImplFactoryEmitter.layerHasImpl(layerString,target)

                if dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(layerString)


                    iEmitTemplatizedCreateLayerImplDeclarationStart(fid,createFunctionStruct);
                end

                iEmitCreateLayerImplDeclaration(fid,createFunctionStruct);
            else
                iEmitEmptyCreateLayerImplDeclaration(fid,createFunctionStruct);
            end


            fprintf(fid,'\n#endif\n');

            existingLayerSet(layerString)=layerString;
        end
    end


    fprintf(fid,'};\n');


    fprintf(fid,'#endif');

    fclose(fid);
end

function[bufferToWrite,existingLayerSet]=iParseExistingFile(fileName)
    fileContents=fileread(fileName);






    layerImplFactoryClosingBracePattern='}'+asManyOfPattern(' ')+';';
    bufferToWrite=extractBefore(fileContents,layerImplFactoryClosingBracePattern);


    fileContents=dltargets.internal.utils.removeWhitespaces(fileContents);











    returnType='MWCNNLayerImplBase\*';
    methodPrefix='create';
    methodSuffix='LayerImpl';






    layerNameExtractor='(?<layerName>\w*)';
    expression=[returnType,methodPrefix,layerNameExtractor,methodSuffix];
    layerNames=regexp(fileContents,expression,'names');


    existingLayerSet=containers.Map();
    for i=1:numel(layerNames)
        layerString=layerNames(i).layerName;
        existingLayerSet(layerString)=layerString;
    end
end

function iEmitCreateLayerImplDeclaration(fid,createFunctionStruct)





    formalParamList=dltargets.internal.layerImplFactoryEmitter.generateCreateLayerImplParameterLists(createFunctionStruct);

    layerCreateDeclaration=['\n',createFunctionStruct.layerImplBase,'* ',createFunctionStruct.createFunction,formalParamList,';\n\n'];

    nbytes=fprintf(fid,layerCreateDeclaration);
    assert(nbytes>0);
end

function iEmitTemplatizedCreateLayerImplDeclarationStart(fid,createFunctionStruct)






    templateTypeList=dltargets.internal.layerImplFactoryEmitter.generateTemplateTypeLists(createFunctionStruct);

    nbytes=fprintf(fid,['template ',templateTypeList]);
    assert(nbytes>0);
end

function iEmitEmptyCreateLayerImplDeclaration(fid,createFunctionStruct)






    assert(~dltargets.internal.layerImplFactoryEmitter.layerHasImpl(createFunctionStruct.layerString,createFunctionStruct.target))


    defaultParameterList=['(',createFunctionStruct.layer,'*, ',createFunctionStruct.targetNetworkImplBase,'*)'];

    emptyLayerCreateDeclaration=[createFunctionStruct.layerImplBase,'* ',createFunctionStruct.createFunction,defaultParameterList,';\n'];
    nbytes=fprintf(fid,emptyLayerCreateDeclaration);
    assert(nbytes>0);
end
