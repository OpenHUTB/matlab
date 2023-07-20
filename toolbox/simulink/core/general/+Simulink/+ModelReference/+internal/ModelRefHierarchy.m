classdef ModelRefHierarchy<handle




    properties(Access=private)
        RootSystem;
        Options;
        OptionList;
        ModelNameSet;
        GraphHandle;
        RefModels;
        ModelBlocks;
        ModelsToClose;
        TraversedModels;
    end


    methods(Access=public)

        function this=ModelRefHierarchy()
            resetProperties(this);
        end



        function varArgOut=search(obj,numArgIn,numArgOut,varArgIn)
            if numArgIn>0
                [varArgIn{:}]=convertStringsToChars(varArgIn{:});
            end
            resetProperties(obj);
            parseAndInitialize(obj,numArgIn,numArgOut,varArgIn);











            processor_callback=Simulink.ModelReference.internal.handleWarningForFindMdlrefsVariants();



            processor1=Simulink.output.registerProcessor(processor_callback,'Event','ALL');%#ok
            clnup=onCleanup(@()clear('processor1','processor_callback'));




            obj.Options.TopModelHasCompiledVariantInfo=...
            isVariantMatchFilter(obj)&&...
            slInternal('hasCompiledVariantInfoInTopModel',get_param(bdroot(obj.RootSystem),'Handle'));

            searchEntry(obj,obj.RootSystem);

            clear clnup;
            if obj.Options.ReturnTopModelAsLastElement


                obj.RefModels{end}=bdroot(obj.RootSystem);
            else

                obj.RefModels=obj.RefModels(1:end-1);
            end


            closeModels(obj,obj.ModelsToClose);


            varArgOut{1}=obj.RefModels;
            varArgOut{2}=obj.ModelBlocks;
            varArgOut{3}=obj.GraphHandle;
        end
    end

    methods(Access=private)

        function resetProperties(obj)
            obj.RootSystem='';
            obj.Options.AllLevels=true;
            obj.Options.IncludeProtectedModels=false;
            obj.Options.LookUnderMasks='all';
            obj.Options.FollowLinks='on';
            obj.Options.IgnoreVariantErrors=false;
            obj.Options.Variants='InterimDefaultActivePlusCodeVariants';
            obj.Options.IncludeCommented='off';
            obj.Options.KeepModelsLoaded=false;
            obj.Options.ReturnTopModelAsLastElement=true;
            obj.Options.WarnForInvalidModelRefs=false;
            obj.Options.MatchFilter={};
            obj.OptionList={};
            obj.GraphHandle=[];
            obj.RefModels={};
            obj.ModelBlocks={};
            obj.ModelsToClose={};
            obj.TraversedModels={};



            obj.ModelNameSet=containers.Map();
            obj.Options.TopModelHasCompiledVariantInfo=false;
        end


        function result=isValueLogical(~,val)
            result=(islogical(val)||...
            (isscalar(val)&&isnumeric(val)&&isreal(val)&&...
            (val==0||val==1)));
        end


        function result=isValueLogicalStr(~,val)
            result=any(strcmp(val,{'on','off'}));
        end


        function parseAndInitialize(obj,numArgIn,numArgOut,varArgIn)
            checkArguments(obj,numArgIn,numArgOut,varArgIn);
            initializeProperties(obj,varArgIn{1});
        end



        function checkArguments(obj,numArgIn,numArgOut,varArgIn)
            switch numArgIn
            case 0
                DAStudio.error('Simulink:modelReference:findMdlrefsUsage');
            case 1
            case 2
                if obj.isValueLogical(varArgIn{2})
                    obj.Options.AllLevels=varArgIn{2};
                else
                    DAStudio.error('Simulink:modelReference:findMdlrefsSecondArgTrueFalse');
                end
            otherwise
                obj.checkNameValuePair(numArgIn,varArgIn(2:end));
            end


            if numArgOut>3
                DAStudio.error('Simulink:modelReference:findMdlrefsInvalidNumberOfOutputs');
            end





            if~(strcmp(obj.Options.Variants,'InterimDefaultActivePlusCodeVariants')||...
                isempty(obj.Options.MatchFilter))
                DAStudio.error('Simulink:Commands:FindSystemMatchFilterUsedWithVariantsOption');
            end

        end


        function initializeProperties(obj,firstInputArg)

            isLoaded=obj.setRootSystem(firstInputArg);


            obj.constructOptionList();


            obj.GraphHandle=Simulink.ModelReference.internal.ModelRefGraph(obj.ModelNameSet);


            obj.GraphHandle.addTopModel(obj.RootSystem,isLoaded);
        end


        function checkNameValuePair(obj,numArgIn,varArgIn)

            if~isequal(mod(length(varArgIn),2),0)
                DAStudio.error('Simulink:modelReference:findMdlrefsUsage');
            end


            for i=1:2:length(varArgIn)
                name=varArgIn{i};
                value=varArgIn{i+1};


                if~ischar(name)
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringForName',...
                    numArgIn-length(varArgIn)+i);
                end


                switch(name)
                case 'LookUnderMasks'
                    if~ischar(value)
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                    end
                    obj.Options.LookUnderMasks=value;

                case 'FollowLinks'
                    if obj.isValueLogical(value)||obj.isValueLogicalStr(value)
                        obj.Options.FollowLinks=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'AllLevels'
                    if obj.isValueLogical(value)
                        obj.Options.AllLevels=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'IncludeProtectedModels'
                    if obj.isValueLogical(value)
                        obj.Options.IncludeProtectedModels=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'IgnoreVariantErrors'
                    if obj.isValueLogical(value)
                        obj.Options.IgnoreVariantErrors=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'Variants'
                    if~ischar(value)
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue',name);
                    end

                    switch value
                    case{'ActivePlusCodeVariants','ActiveVariants','AllVariants'}
                        obj.Options.Variants=value;

                    otherwise
                        DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',value);
                    end

                case 'IncludeCommented'
                    if obj.isValueLogical(value)||obj.isValueLogicalStr(value)
                        obj.Options.IncludeCommented=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'KeepModelsLoaded'
                    if obj.isValueLogical(value)
                        obj.Options.KeepModelsLoaded=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'ReturnTopModelAsLastElement'
                    if obj.isValueLogical(value)
                        obj.Options.ReturnTopModelAsLastElement=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'WarnForInvalidModelRefs'
                    if obj.isValueLogical(value)
                        obj.Options.WarnForInvalidModelRefs=value;
                    else
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue',name);
                    end

                case 'MatchFilter'
                    if slfeature('MatchFilterEnabled')<1
                        DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                    end
                    if~isa(value,'function_handle')
                        DAStudio.error('Simulink:modelReference:nameValuePairNeedsFunctionValue',name);
                    end
                    if~isempty(obj.Options.MatchFilter)
                        DAStudio.error('Simulink:modelReference:nameValuePairDuplicate','MatchFilter');
                    end
                    obj.Options.MatchFilter=value;

                otherwise
                    DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter',name);
                end
            end
        end



        function constructOptionList(obj)
            obj.OptionList={'FollowLinks',obj.Options.FollowLinks,...
            'LookUnderMasks',obj.Options.LookUnderMasks,...
            'LookUnderReadProtectedSubsystems','on',...
            'IncludeCommented',obj.Options.IncludeCommented};





            if isempty(obj.Options.MatchFilter)&&slfeature('FindSystemVariantsRemoval')<7
                obj.OptionList=[obj.OptionList,'Variants',obj.Options.Variants];
            end
            if~isempty(obj.Options.MatchFilter)
                obj.OptionList=[obj.OptionList,'MatchFilter',{obj.Options.MatchFilter}];
            end
            obj.OptionList=[obj.OptionList,'BlockType','ModelReference'];
        end



        function isLoaded=setRootSystem(obj,aSystem)

            obj.RootSystem=aSystem;


            if~ischar(aSystem)

                if~ishandle(aSystem)
                    DAStudio.error('Simulink:modelReference:findMdlrefsFirstArgModel');
                end

                obj.RootSystem=getfullname(aSystem);
            else
                obj.ModelsToClose=slprivate('load_model',aSystem);
            end
            isLoaded=isempty(obj.ModelsToClose);

            obj.checkForViableModelObject();
        end


        function checkForViableModelObject(obj)

            modelObject=get_param(obj.RootSystem,'object');


            if~(isa(modelObject,'Simulink.BlockDiagram')||...
                isa(modelObject,'Simulink.SubSystem')||...
                isa(modelObject,'Simulink.ModelReference'))
                DAStudio.error('Simulink:modelReference:findMdlrefsFirstArgModel');
            end
        end



        function flag=isVariantMatchFilter(obj)
            flag=~isempty(obj.Options.MatchFilter)&&...
            (isequal(obj.Options.MatchFilter,@Simulink.match.activeVariants)||...
            isequal(obj.Options.MatchFilter,@Simulink.match.codeCompileVariants));
        end



        function flag=checkIfModelIsInactiveFromTopModelContext(obj,aBlock)


            cvi=...
            slInternal('getCompiledVariantInfoForModel',get_param(bdroot(obj.RootSystem),'Handle'),aBlock);




            flag=(isequal(obj.Options.MatchFilter,@Simulink.match.activeVariants)&&~cvi.IsActive)||...
            (isequal(obj.Options.MatchFilter,@Simulink.match.codeCompileVariants)&&~cvi.IsInCodegen);
        end




        function searchEntry(obj,parentModel)
            try
                mdlsToClose=slprivate('load_model',parentModel);
            catch me

                if obj.Options.WarnForInvalidModelRefs

                    obj.RefModels=[obj.RefModels;parentModel];
                    MSLDiagnostic('Simulink:modelReference:findMdlrefsInvalidModel',...
                    parentModel,me.message).reportAsWarning;
                    return;
                end
                rethrow(me);
            end
            obj.storeIsModelLoaded(mdlsToClose,parentModel);
            blocks=find_system(parentModel,obj.OptionList{:});


            if isempty(blocks)
                obj.RefModels=[obj.RefModels;parentModel];
                closeModels(obj,mdlsToClose);
                return;
            end

            obj.ModelBlocks=[obj.ModelBlocks;blocks];
            obj.addModelToTraversedList(parentModel);
            models.protected={};


            for i=1:length(blocks)
                aBlock=blocks{i};





                if obj.Options.TopModelHasCompiledVariantInfo&&...
                    checkIfModelIsInactiveFromTopModelContext(obj,aBlock)



                    obj.ModelBlocks(contains(obj.ModelBlocks,aBlock))=[];
                    continue;
                end

                blockInfo=getInfoOnOneBlock(obj,aBlock);


                for j=1:length(blockInfo.files)
                    childStruct=obj.getProtectedAttributes(blockInfo,j);



                    if(childStruct.IsProtected&&~obj.Options.IncludeProtectedModels)...
                        ||obj.cyclesDetected(childStruct.Name)
                        continue;
                    end


                    if~isKey(obj.ModelNameSet,childStruct.Name)
                        obj.GraphHandle.addModel(childStruct);
                        if childStruct.IsProtected
                            models.protected=[models.protected;{childStruct.Name}];
                        elseif obj.Options.AllLevels
                            searchEntry(obj,childStruct.Name);
                        else
                            obj.RefModels=[obj.RefModels;{childStruct.Name}];
                        end
                    end


                    obj.GraphHandle.addEdgeToGraph(parentModel,childStruct.Name,...
                    aBlock,blockInfo.sim_modes{j});
                end
            end


            closeModels(obj,mdlsToClose);
            obj.removeModelFromTraversedList();


            models.protected=setdiff(models.protected,obj.RefModels);


            obj.RefModels=[obj.RefModels;models.protected;{parentModel}];
        end



        function info=getInfoOnOneBlock(obj,aBlock)


            switch obj.Options.Variants
            case{'ActivePlusCodeVariants','InterimDefaultActivePlusCodeVariants'}
                info.protected=get_param(aBlock,'CodeVariantProtectedModels');
                info.files=get_param(aBlock,'CodeVariantModelFiles');
                info.names=get_param(aBlock,'CodeVariantModelNames');
                info.sim_modes=get_param(aBlock,'CodeVariantSimulationModes');

            case 'AllVariants'
                info.protected=get_param(aBlock,'ProtectedModels');
                info.files=get_param(aBlock,'ModelFiles');
                info.names=get_param(aBlock,'ModelNames');
                info.sim_modes=get_param(aBlock,'ModelSimulationModes');

            case 'ActiveVariants'
                info.protected={get_param(aBlock,'ProtectedModel')};
                info.files={get_param(aBlock,'ModelFile')};
                info.sim_modes={get_param(aBlock,'SimulationMode')};



                if(isequal(info.protected{1},'on'))
                    info.names={''};
                else
                    info.names={get_param(aBlock,'ModelName')};
                end
            end
        end





        function result=getProtectedAttributes(~,blockInfo,index)
            if isequal(blockInfo.protected{index},'on')
                result.Name=blockInfo.files{index};
                result.IsProtected=true;
            else
                result.Name=blockInfo.names{index};
                result.IsProtected=false;
            end
            result.IsLoaded=false;
        end


        function result=cyclesDetected(obj,childName)
            result=false;



            if any(strcmp(childName,obj.TraversedModels))
                result=true;
                strPathToModel=slprivate('strcat_with_separator',obj.TraversedModels,':');
                modelRefLoop=[strPathToModel,':',childName];
                MSLDiagnostic('Simulink:modelReference:detectedModelReferenceLoop',modelRefLoop).reportAsWarning;
            end
        end


        function addModelToTraversedList(obj,model)
            obj.TraversedModels=[obj.TraversedModels,{model}];
        end


        function removeModelFromTraversedList(obj)
            obj.TraversedModels=obj.TraversedModels(1:end-1);
        end


        function closeModels(obj,modelsToClose)
            if~obj.Options.KeepModelsLoaded
                slprivate('close_models',modelsToClose);
            end
        end

        function storeIsModelLoaded(obj,modelsToClose,model)


            if isequal(model,obj.RootSystem)
                return;
            end

            isLoaded=isempty(modelsToClose);

            vertexID=obj.ModelNameSet(model);
            obj.GraphHandle.setIsModelLoaded(vertexID,isLoaded);
        end

    end

end


