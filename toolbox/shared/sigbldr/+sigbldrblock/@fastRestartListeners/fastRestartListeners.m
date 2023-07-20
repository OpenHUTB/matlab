classdef fastRestartListeners<handle


























    properties(Hidden=true)
ModelName
        Listener_Storage=[]
        ModelHandle=0;
        NumSigBldrBlocks=0;
    end

    methods(Static=true,Hidden=true)
        function new_obj=setup(modelH)


            new_obj=sigbldrblock.fastRestartListeners(modelH);
            new_obj.addBdToMap(new_obj.ModelHandle);
            new_obj.addListeners;
        end

        function cleanup(modelH)





            sigbldrblock.fastRestartListeners.removeBdFromMapAndResetFeatureIfMapIsEmpty(get_param(modelH,'Handle'));
        end









        function[fastRestart,fastRestartModels,numSBBlocks]=disp

            modelEventListenerMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToEventListener;
            if(modelEventListenerMap.isempty())

                fastRestart=false;
                fastRestartModels={};
                numSBBlocks=0;
            else

                fastRestart=true;
                keys=modelEventListenerMap.keys;
                for n=numel(keys):-1:1
                    modelH=keys{n};
                    helperObject=modelEventListenerMap(modelH);
                    fastRestartModels{n}=helperObject.ModelName;
                    numSBBlocks{n}=helperObject.NumSigBldrBlocks;
                end
            end
        end

    end

    methods(Static,Access='private')

        function removeBdFromMapAndResetFeatureIfMapIsEmpty(modelH)



            modelEventListenerMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToEventListener;
            modelSigBldrBlkMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToNumSigBldrBlks;
            if modelSigBldrBlkMap.isKey(modelH)
                numberSigBldr=values(modelSigBldrBlkMap,{modelH});
                if numberSigBldr{1}>1


                    modelSigBldrBlkMap(modelH)=numberSigBldr{1}-1;%#ok
                    helperObject=modelEventListenerMap(modelH);
                    helperObject.NumSigBldrBlocks=numberSigBldr{1}-1;
                else

                    sigbldrblock.fastRestartListeners.removeBdFromMapAndResetFeature(modelH);
                end
            end
        end

        function removeBdFromMapAndResetFeature(modelH)

            modelEventListenerMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToEventListener;
            modelSigBldrBlkMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToNumSigBldrBlks;
            if modelEventListenerMap.isKey(modelH)

                helperObject=modelEventListenerMap(modelH);
                helperObject.removeListeners();
                modelEventListenerMap.remove(modelH);
                modelSigBldrBlkMap.remove(modelH);
            end
            if(modelEventListenerMap.isempty())

                munlock;
            end
        end

        function map=GetMapOfMdlToEventListener



            mlock;
            persistent modelEventListenerMap;

            if~isa(modelEventListenerMap,'containers.Map')
                modelEventListenerMap=...
                containers.Map('KeyType','double','ValueType','any');
            end
            map=modelEventListenerMap;
        end

        function map=GetMapOfMdlToNumSigBldrBlks



            mlock;
            persistent modelSigBldrBlkMap;

            if~isa(modelSigBldrBlkMap,'containers.Map')
                modelSigBldrBlkMap=...
                containers.Map('KeyType','double','ValueType','any');
            end
            map=modelSigBldrBlkMap;
        end
    end

    methods(Access='private')
        function status=addBdToMap(obj,modelH)









            modelEventListenerMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToEventListener;
            modelSigBldrBlkMap=sigbldrblock.fastRestartListeners.GetMapOfMdlToNumSigBldrBlks;
            if~modelEventListenerMap.isKey(modelH)
                modelEventListenerMap(modelH)=obj;%#ok
                modelSigBldrBlkMap(modelH)=obj.NumSigBldrBlocks;%#ok
                status=false;
                return;
            else


                numberSigBldr=values(modelSigBldrBlkMap,{modelH});
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    numActiveSTVBlocks=length(find_system(modelH,'SkipLinks','on',...
                    'AllBlocks','on','MatchFilter',@Simulink.match.activeVariants,...
                    'Tag','STV Subsys'));
                else


                    find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SkipLinks','on','AllBlocks','on','Tag','STV Subsys');
                end
                if numberSigBldr{1}~=numActiveSTVBlocks
                    obj.NumSigBldrBlocks=numActiveSTVBlocks;
                    helperObject=modelEventListenerMap(modelH);
                    helperObject.NumSigBldrBlocks=obj.NumSigBldrBlocks;
                    modelSigBldrBlkMap(modelH)=obj.NumSigBldrBlocks;%#ok<NASGU>
                end
                status=true;
                return;
            end
        end

        function obj=fastRestartListeners(model)




            obj.ModelName=get_param(model,'Name');
            obj.ModelHandle=get_param(obj.ModelName,'Handle');
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                obj.NumSigBldrBlocks=length(find_system(model,'SkipLinks','on',...
                'AllBlocks','on','MatchFilter',@Simulink.match.activeVariants,...
                'Tag','STV Subsys'));
            else


                find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SkipLinks','on','AllBlocks','on','Tag','STV Subsys');
            end
        end

        function delete(obj)
            removeListeners(obj);
        end

        function addListeners(obj)

            bdHandle=obj.ModelHandle;
            obj.addEngineEventListener(bdHandle,'EngineSimStatusTerminating',...
            @obj.terminatingFunction);
        end

        function removeListeners(obj)

            obj.removeEngineEventListener('EngineSimStatusTerminating');
        end

    end

    methods(Access=private)
        function addEngineEventListener(obj,bdHandle,eventType,listenerCallback)

            h=listener(get_param(bdHandle,'Object'),eventType,listenerCallback);
            h=[obj.Listener_Storage;h];
            obj.Listener_Storage=h;
        end

        function removeEngineEventListener(obj,eventType)

            bdListeners=obj.Listener_Storage;
            hl=[];
            for idx=1:length(bdListeners)

                eventName=bdListeners(idx).EventName;
                if~isequal(eventName,eventType)
                    hl=[hl,bdListeners(idx)];%#ok
                end
            end
            obj.Listener_Storage=hl;
        end

        function terminatingFunction(obj,~,~)


            model=obj.ModelHandle;



            sbBlks=find_system(model,'SkipLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'AllBlocks','on','Tag','STV Subsys');
            for idx=1:length(sbBlks)
                sigbuilder_block('stop',sbBlks(idx));
            end
        end
    end
end




