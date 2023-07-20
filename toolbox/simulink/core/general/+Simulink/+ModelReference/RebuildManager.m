classdef(Sealed)RebuildManager<handle




    properties(Transient,Access=private)
        fSkipMap;
        fBuildMap;
    end

    properties(Access=private)
        ignoreFlag;
    end

    methods(Access=private)
        function obj=RebuildManager()
            obj.fSkipMap=containers.Map('KeyType','char','ValueType','any');
            obj.fBuildMap=containers.Map('KeyType','char','ValueType','any');
            obj.ignoreFlag=false;
        end
    end

    methods(Static)


        function out=getRebuildManager

            persistent rsManager;

            if isempty(rsManager)
                rsManager=Simulink.ModelReference.RebuildManager();
            end
            out=rsManager;
            mlock;
        end

        function clearRebuildManager
            munlock;
            rsManager=Simulink.ModelReference.RebuildManager.getRebuildManager();
            rsManager.fSkipMap=containers.Map('KeyType','char','ValueType','any');
            rsManager.fBuildMap=containers.Map('KeyType','char','ValueType','any');
            if~isempty(rsManager)
                clear 'rsManager';
            end

        end

        function saveRebuildManager(matFileName)

            rsManager=Simulink.ModelReference.RebuildManager.getRebuildManager;
            fSMap=rsManager.fSkipMap;
            fBMap=rsManager.fBuildMap;
            save(matFileName,'fSMap','fBMap');

        end

        function out=loadRebuildManager(matFileName)

            rMgr=load(matFileName);
            rsFMap=rMgr.fSMap;
            rsBMap=rMgr.fBMap;

            rsManager=Simulink.ModelReference.RebuildManager.getRebuildManager;

            rsManager.fSkipMap=rsFMap;
            rsManager.fBuildMap=rsBMap;
            out=rsManager;
        end


        function addModelToSkipList(topModel,modelsToSkip)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();


            bList=isKey(rMgr.fBuildMap,topModel);
            if bList
                DAStudio.error('Simulink:modelReference:AddToSkipBuildListNotEmpty',topModel);
            end


            if isKey(rMgr.fSkipMap,topModel)
                skipList=rMgr.fSkipMap(topModel);
            else
                skipList={};
            end

            skipList=[skipList,modelsToSkip];
            skipList=unique(skipList);
            rMgr.fSkipMap(topModel)=skipList;
        end

        function addModelToBuildList(topModel,modelsToBuild)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();


            sList=isKey(rMgr.fSkipMap,topModel);
            if sList
                DAStudio.error('Simulink:modelReference:AddToBuildSkipListNotEmpty',topModel);
            end


            if isKey(rMgr.fBuildMap,topModel)
                buildList=rMgr.fBuildMap(topModel);
            else
                buildList={};
            end

            buildList=[buildList,modelsToBuild];
            buildList=unique(buildList);
            rMgr.fBuildMap(topModel)=buildList;
        end


        function removeModelFromSkipList(topModel,modelToRemove)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();


            if isKey(rMgr.fSkipMap,topModel)
                skipList=rMgr.fSkipMap(topModel);
            else

                DAStudio.error('Simulink:modelReference:RemoveErrorSkipListEmpty',topModel);
            end



            if~isempty(find(strcmp(skipList,modelToRemove),1))
                skipList=setdiff(skipList,modelToRemove);
            end

            rMgr.fSkipMap(topModel)=skipList;
        end




        function removeModelFromBuildList(topModel,modelToRemove)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();


            if isKey(rMgr.fBuildMap,topModel)
                buildList=rMgr.fBuildMap(topModel);
            else

                DAStudio.error('Simulink:modelReference:RemoveErrorBuildListEmpty',topModel);
            end



            if~isempty(find(strcmp(buildList,modelToRemove),1))
                buildList=setdiff(buildList,modelToRemove);
            end

            rMgr.fBuildMap(topModel)=buildList;
        end




        function skipList=getSkipList(topModel)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();

            if isKey(rMgr.fSkipMap,topModel)
                skipList=rMgr.fSkipMap(topModel);
            else
                skipList={};
            end

        end



        function buildList=getBuildList(topModel)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();

            if isKey(rMgr.fBuildMap,topModel)
                buildList=rMgr.fBuildMap(topModel);
            else
                buildList={};
            end

        end



        function clearSkipListForModel(topModel)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();

            if isKey(rMgr.fSkipMap,topModel)
                remove(rMgr.fSkipMap,topModel);
            end
        end



        function clearBuildListForModel(topModel)

            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();

            if isKey(rMgr.fBuildMap,topModel)
                remove(rMgr.fBuildMap,topModel);
            end
        end



        function listPopulated=isSkipOrBuildListPopulated(topModel)

            if~isempty(Simulink.ModelReference.RebuildManager.getBuildList(topModel))
                listPopulated='build';
            elseif~isempty(Simulink.ModelReference.RebuildManager.getSkipList(topModel))
                listPopulated='skip';
            else
                listPopulated='none';
            end

        end


        function setIgnoreFlag(flagVal)
            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();
            rMgr.ignoreFlag=flagVal;
        end


        function iFlag=getIgnoreFlag()
            rMgr=Simulink.ModelReference.RebuildManager.getRebuildManager();
            iFlag=rMgr.ignoreFlag;
        end
    end
end

