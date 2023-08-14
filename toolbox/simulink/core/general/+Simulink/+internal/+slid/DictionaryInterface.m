
classdef DictionaryInterface







    methods(Static)

        function functionList=getListOfAvailableSLFunctions()



            functionStringSet=containers.Map;


            openModels=find_system('SearchDepth',0);


            for model=openModels'


                dictBD=get_param(model{1},'DictionarySystem');



                slidFunctions=dictBD.Interface.Function.toArray;


                for slidFunction=slidFunctions
                    if~isempty(slidFunction)
                        functionStringSet(slidFunction.Prototype)...
                        =true;
                    end
                end

            end


            functionList=functionStringSet.keys;

        end

        function functionList=getFunctionsForModel(modelScopes,dictSpec)

            functionList=[];
            [AllFunctionList,sourceList]=Simulink.internal.slid.DictionaryInterface.getListOfFunctionsFromDictionary(dictSpec);
            for i=1:length(modelScopes)
                modelScope=modelScopes{i};
                [srcParts{1:3}]=...
                cellfun(@(x)fileparts(x),sourceList,'UniformOutput',false);
                srcFileNameList=srcParts{2};
                functionList=AllFunctionList(strcmp(srcFileNameList,modelScope));
            end

        end

        function protoTypeList=getFunctionPrototypesFromDictionary(filespec)


            [functionList,sourceList]=Simulink.internal.slid.DictionaryInterface.getListOfFunctionsFromDictionary(filespec);

            protoTypeList=Simulink.internal.slid.DictionaryInterface.rearrangeFunctionList(functionList,sourceList);

        end


        function protoTypeList=getFunctionPrototypesFromModel(bdroot)


            [functionList,sourceList]=Simulink.internal.slid.DictionaryInterface.getListOfFunctionsFromModel(bdroot);
            protoTypeList=Simulink.internal.slid.DictionaryInterface.rearrangeFunctionList(functionList,sourceList);
        end


        function[functionList,sourceList]=getListOfFunctionsFromDictionary(filespec)

            ddConn=Simulink.dd.open(filespec);
            broker=ddConn.getBroker();

            [functionList,sourceList]=Simulink.internal.slid.DictionaryInterface.getListOfFunctionsFromBroker(broker);

        end


        function[elements,sourceList]=lookupByName(filespec,name,namespaceType)


            elements=mf.zero.ModelElement.empty;
            sourceList={};
            tmpmodel=mf.zero.Model.createTransientModel();

            ddConn=Simulink.dd.open(filespec);
            broker=ddConn.getBroker();

            dataDefs=broker.lookupSymbolByNameInAllSources(name,tmpmodel);
            entityInfoVec=zeros(1,length(dataDefs));
            for idx=1:length(dataDefs)
                entityInfoVec.emplace_back(slid.broker.EntityInfo.createEntityInfoFromDataDefinition(dataDefs(idx),mdl));
            end





            L=length(entityInfoVec);
            if L>0
                elements(1:L)=arrayfun(@(x)x.EntityObject,entityInfoVec);
                [sourceList{1:L}]=entityInfoVec(:).Source;
            end
        end

        function refURLs=getReferencesURLs(filespec)



            refURLs={};

            conn=Simulink.dd.open(filespec);
            broker=conn.getBroker();
            config=broker.getActiveBrokerConfig;
            if~isempty(config)
                refURLs=config.getExplicitExternalSourceList(true);
            end

        end

        function addReference(filespec,refURL)


            if~exist(refURL,'file')
                DAStudio.error('SLDD:sldd:RefFileNotFound','refURL');
            end
            [~,~,ext]=fileparts(refURL);


            hasAdapter=sl.data.adapter.AdapterManagerV2.hasReadingAdapters(refURL);



            if~hasAdapter
                DAStudio.error('SLDD:sldd:UnsupportedModelAsReference');


            end

            if strcmp(ext,'.slx')

                info=Simulink.MDLInfo(refURL);
                if(simulink_version(info.ReleaseName)<simulink_version('R2017b'))
                    DAStudio.error('SLDD:sldd:UnsupportedModelAsReference');
                end
            end

            isOpen=any(ismember(Simulink.data.dictionary.getOpenDictionaryPaths,filespec));
            if isOpen
                conn=Simulink.dd.open(filespec);
                broker=conn.getBroker();
                config=broker.getActiveBrokerConfig;
                tmpModel=mf.zero.Model.createTransientModel();
                if~isempty(config)
                    r=config.addExplicitExternalSource(refURL,tmpModel);
                    if slfeature('SlddReferenceFilePart')>0&&r.Success&&r.IsNew
                        Simulink.dd.markReferencePartDirty(filespec);
                    end
                end
            end

        end

        function removeReference(filespec,refURL)



            conn=Simulink.dd.open(filespec);
            broker=conn.getBroker();
            config=broker.getActiveBrokerConfig;
            if~isempty(config)
                if config.isSource(refURL)
                    config.removeExplicitExternalSource(refURL);
                    broker.captureSourceClosureForLibSLDDs(slfeature('SLModelBroker')<1&&slfeature('SLDDBroker')<1);
                    if slfeature('SlddReferenceFilePart')>0
                        Simulink.dd.markReferencePartDirty(filespec);
                    end
                end
            end

        end

    end


    methods(Static,Access=private)

        function protoTypeList=rearrangeFunctionList(functionList,sourceList)

            protoTypeList={};
            if~isempty(functionList)
                [protoTypeList{1:length(functionList)}]=...
                deal(functionList.Prototype);
                L=length(protoTypeList);
                for idx=1:L
                    [~,srcModelName,srcExt]=fileparts(sourceList{idx});
                    if strcmp(functionList(idx).Visibility,'scoped')
                        if contains(protoTypeList{idx},'=')
                            protoTypeList{idx}=regexprep(...
                            protoTypeList{idx},...
                            ['= ',functionList(idx).Name,'\('],...
                            ['= ',srcModelName,'.',functionList(idx).Name,'(']);
                        else

                            protoTypeList{idx}=regexprep(...
                            protoTypeList{idx},...
                            [functionList(idx).Name,'\('],...
                            [srcModelName,'.',functionList(idx).Name,'(']);
                        end
                    end
                    sourceFile=[srcModelName,srcExt];
                    protoTypeList{idx}=[protoTypeList{idx},':',sourceFile];
                end
            end
        end


        function[functionList,sourceList]=getListOfFunctionsFromBroker(broker)

            functionList=mf.zero.ModelElement.empty;
            sourceList={};
            tmpmodel=mf.zero.Model.createTransientModel();








            L=length(entityInfoVec);
            if L>0
                functionList(1:L)=arrayfun(@(x)x.EntityObject,entityInfoVec);
                [sourceList{1:L}]=entityInfoVec(:).Source;
            end
        end


        function[functionList,sourceList]=getListOfFunctionsFromModel(bdroot)
            broker=bdroot.getBroker();
            [functionList,sourceList]=Simulink.internal.slid.DictionaryInterface.getListOfFunctionsFromBroker(broker);

        end
    end

end


