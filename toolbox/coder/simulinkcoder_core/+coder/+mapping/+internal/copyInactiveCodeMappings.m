function copyInactiveCodeMappings(model,varargin)


















    if nargin<2
        overwriteCodeSpecifications=false;
    else
        overwriteCodeSpecifications=varargin{1};
    end

    [dstModelMapping,dstMappingType]=Simulink.CodeMapping.getCurrentMapping(model);

    if isequal(dstMappingType,'CoderDictionary')&&...
        isequal(get_param(model,'UseEmbeddedCoderFeatures'),'off')
        dstMappingType='SimulinkCoderCTarget';
        dstModelMapping=Simulink.CodeMapping.get(model,dstMappingType);
        if~isempty(dstModelMapping)&&~overwriteCodeSpecifications

            return;
        end
    end

    if~isempty(dstModelMapping)&&~overwriteCodeSpecifications

        error(['Active target already has a mapping. Do not use ',...
        'coder.mapping.internal.copyInactiveCodeMappings in this scenario.']);
    end

    if~isequal(dstMappingType,'CoderDictionary')&&...
        ~isequal(dstMappingType,'SimulinkCoderCTarget')

        DAStudio.error('coderdictionary:api:supportedForCTarget',get_param(model,'Name'));
    end

    if isequal(dstMappingType,'CoderDictionary')
        srcMappingType='SimulinkCoderCTarget';
        srcDictionaryType='SimulinkCoderCDictionary';
        dstDictionaryType='EmbeddedCoderCDictionary';
    else
        srcMappingType='CoderDictionary';
        srcDictionaryType='EmbeddedCoderCDictionary';
        dstDictionaryType='SimulinkCoderCDictionary';
    end

    srcModelMapping=Simulink.CodeMapping.get(model,srcMappingType);
    if isempty(srcModelMapping)

        return;
    end

    if isempty(dstModelMapping)

        configSet=getActiveConfigSet(model);
        coder.mapping.internal.create(...
        model,configSet,...
        'noSharedDictionary',true,...
        'MappingType',dstMappingType);

        dstModelMapping=Simulink.CodeMapping.get(model,dstMappingType);
    end

    builtInStorageClasses={'ExportedGlobal','ImportedExtern',...
    'ImportedExternPointer'};


    CopyIndividualDataMappings();

    function CopyIndividualDataMappings()
        CopyInportMappings();
        CopyOutportMappings();
        CopyModelParameterMappings();
        CopyStateMappings();
        CopyDataStoreMappings();
        CopySignalMappings();
    end

    function CopyInportMappings()
        for src=srcModelMapping.Inports
            dst=dstModelMapping.Inports.findobj('Block',src.Block);
            CopyMapping(dst,src);
        end
    end

    function CopyOutportMappings()
        for src=srcModelMapping.Outports
            dst=dstModelMapping.Outports.findobj('Block',src.Block);
            CopyMapping(dst,src);
        end
    end

    function CopyModelParameterMappings()
        for src=srcModelMapping.ModelScopedParameters
            paramName=src.Parameter;
            dst=dstModelMapping.ModelScopedParameters.findobj('Parameter',paramName);
            CopyMapping(dst,src);
        end
    end

    function CopyStateMappings()
        for src=srcModelMapping.States
            srcBlockPath=src.OwnerBlockPath;
            dst=dstModelMapping.States.findobj('OwnerBlockPath',srcBlockPath);
            if~isempty(dst)
                CopyMapping(dst,src);
            end
        end
    end

    function CopyDataStoreMappings()
        for src=srcModelMapping.DataStores
            srcBlockPath=src.OwnerBlockPath;
            dst=dstModelMapping.DataStores.findobj('OwnerBlockPath',srcBlockPath);
            CopyMapping(dst,src);
        end
    end

    function CopySignalMappings()
        for src=srcModelMapping.Signals
            srcPortHandle=src.PortHandle;
            dst=dstModelMapping.Signals.findobj('PortHandle',srcPortHandle);
            if isempty(dst)
                try

                    dstModelMapping.addSignal(srcPortHandle);
                    dst=dstModelMapping.Signals.findobj('PortHandle',srcPortHandle);
                catch


                    return
                end
            end
            CopyMapping(dst,src);
        end

        if overwriteCodeSpecifications



            for dst=dstModelMapping.Signals
                dstPortHandle=dst.PortHandle;
                src=srcModelMapping.Signals.findobj('PortHandle',dstPortHandle);
                if isempty(src)


                    dstModelMapping.removeSignal(dstPortHandle);
                end
            end
        end
    end

    function CopyMapping(dstMapping,srcMapping)





        if~overwriteCodeSpecifications&&...
            ~isempty(dstMapping.MappedTo)&&...
            ~isempty(dstMapping.MappedTo.StorageClass)



            return;
        end

        if isempty(srcMapping.MappedTo)||...
            isempty(srcMapping.MappedTo.StorageClass)

            dstMapping.unmap();
            return;
        end

        if isempty(srcMapping.MappedTo.StorageClass.UUID)

            dstMapping.map('')
        else
            srcUuid=srcMapping.MappedTo.StorageClass.UUID;
            srcSCRef=coderdictionary.data.SlCoderDataClient.getElementByUUIDOfCoderDataTypeInDictionary(...
            get_param(model,'Handle'),srcDictionaryType,'StorageClasses',srcUuid);
            if(srcSCRef.isEmpty())


                return;
            end
            srcSCName=srcSCRef.getProperty('Name');

            isBuiltInSC=any(strcmp(srcSCName,builtInStorageClasses));
            if isBuiltInSC
                dstScRef=coderdictionary.data.SlCoderDataClient.getElementByNameOfCoderDataTypeInDictionary(...
                get_param(model,'Handle'),dstDictionaryType,'StorageClasses',srcSCName);

                dstUUID=dstScRef.getProperty('UUID');
                dstMapping.map(dstUUID)
            else



                dstMapping.map('')
            end
        end


        dstMapping.setIdentifier(srcMapping.getIdentifier())
    end

end


