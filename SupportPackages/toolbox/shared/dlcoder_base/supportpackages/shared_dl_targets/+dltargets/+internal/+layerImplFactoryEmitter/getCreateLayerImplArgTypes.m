function argTypes=getCreateLayerImplArgTypes(layerString)




    persistent layerStringToCreateArgsMap;

    if isempty(layerStringToCreateArgsMap)
        layerStringToCreateArgsMap=populateLayerStringToCreateArgsMap();
    end

    assert(layerStringToCreateArgsMap.Count>0,'layerString-to-createArgs map is empty');
    assert(layerStringToCreateArgsMap.isKey(layerString),'layerString-to-createArgs map does not contain the given layerString');
    argTypes=layerStringToCreateArgsMap(layerString);
end

function layerStringToCreateArgsMap=populateLayerStringToCreateArgsMap()
    layerStringToCreateArgsMap=containers.Map;

    layerImplFactoryFile=fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWLayerImplFactory.hpp');


    fid=fopen(layerImplFactoryFile,'r');
    assert(ftell(fid)==0);

    while~feof(fid)
        line=fgetl(fid);


        methodPrefix='create';
        methodSuffix='LayerImpl';
        createLayerImplDefinition='virtual'+asManyOfPattern(' ')+...
        'MWCNNLayerImplBase'+asManyOfPattern(' ')+'*'+asManyOfPattern(' ')+...
        methodPrefix+wildcardPattern+methodSuffix;

        if contains(line,createLayerImplDefinition+'(')

            layerString=iExtractLayerString(line,methodPrefix,methodSuffix);



            line=extractAfter(line,createLayerImplDefinition);
            argTypes=dltargets.internal.layerImplFactoryEmitter.extractArgTypes(line,fid);

            layerStringToCreateArgsMap(layerString)=argTypes;
        end
    end
    fclose(fid);
end




function layerString=iExtractLayerString(line,prefix,suffix)
    layerString=extractBefore(line,[suffix,'(']);
    layerString=extractAfter(layerString,prefix);
end
