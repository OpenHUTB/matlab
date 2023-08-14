classdef BuildSummary<handle





    properties(GetAccess=private,SetAccess=immutable)
StartTime
    end

    properties(GetAccess=private,SetAccess=private)
Entries
DisplayOrder
    end

    methods



        function this=BuildSummary
            this.Entries=[];
            this.StartTime=datetime;
        end




        function updateRebuildReasonIfEmpty(this,model,targetType,reason)

            entry=this.fetchOrCreateEntry(model,targetType);

            if isempty(entry.RebuildReason)
                entry.RebuildReason=reason;
                this.addOrUpdateEntry(entry);
            end
        end




        function updateRebuildReason(this,model,targetType,reason)

            entry=this.fetchOrCreateEntry(model,targetType);
            entry.RebuildReason=reason;
            if isempty(reason)

                entry.WasBuildSuccessful=true;
            end
            this.addOrUpdateEntry(entry);
        end




        function updateAction(this,model,targetType,buildResult)

            wasCodeGenerated=false;
            wasCodeCompiled=false;
            if isfield(buildResult,'WasCodeGenerated')
                wasCodeGenerated=buildResult.WasCodeGenerated;
            end
            if isfield(buildResult,'WasCodeCompiled')
                wasCodeCompiled=buildResult.WasCodeCompiled;
            end

            entry=this.fetchOrCreateEntry(model,targetType);
            entry.WasCodeGenerated=wasCodeGenerated;
            entry.WasCodeCompiled=wasCodeCompiled;
            entry.WasBuildSuccessful=true;
            entry.ActionUnknown=isempty(buildResult);
            this.addOrUpdateEntry(entry);
        end




        function printSummary(this,topMdl,okToPushNags,isSimulinkAccelerator,isRapidAccelerator)

            endTime=datetime;
            buildDuration=between(this.StartTime,endTime);

            entries=this.Entries;


            if~isempty(entries)
                numModels=numel(unique({entries.Model}));

                wasBuiltSuccessfully=[entries.WasBuildSuccessful];
                sucEntries=entries(wasBuiltSuccessfully);
                wasRebuilt=[sucEntries.WasCodeGenerated]|[sucEntries.WasCodeCompiled]|...
                [sucEntries.ActionUnknown];
                rebuiltEntries=sucEntries(wasRebuilt);
                numModelsBuilt=numel(unique({rebuiltEntries.Model}));


                upToDateEntries=sucEntries(~wasRebuilt);
                numModelsUpToDate=numel(unique({upToDateEntries.Model}));



                hasRebuildReason=~cellfun(@isempty,{entries.RebuildReason});
                failedEntries=entries(~wasBuiltSuccessfully&hasRebuildReason);



                entriesToDisplay=[rebuiltEntries,failedEntries];


                coder.build.internal.printBuildSummary(...
                entriesToDisplay,numModelsBuilt,numModelsUpToDate,...
                numModels,okToPushNags,topMdl,buildDuration,...
                isSimulinkAccelerator,isRapidAccelerator);
            end
        end




        function addEntriesForScheduledModels(this,modelNames,target)




            for model=modelNames
                entry=this.fetchOrCreateEntry(model{1},target);
                this.addOrUpdateEntry(entry);
            end
        end




        function mergeForParallelBuild(this,bsFromWorker)


            for entry=bsFromWorker.Entries
                this.addOrUpdateEntry(entry);
            end
        end
    end

    methods(Access=private)



        function addOrUpdateEntry(this,entry)
            if isempty(this.Entries)
                this.Entries=entry;
            else
                idx=strcmp({this.Entries.Key},entry.Key);
                if any(idx)
                    this.Entries(idx)=entry;
                else
                    this.Entries(end+1)=entry;
                end
            end
        end




        function entry=fetchOrCreateEntry(this,model,targetType)
            key=this.createKey(model,targetType);
            if isempty(this.Entries)

                entry=this.createEntry(model,targetType);
            else


                idx=strcmp({this.Entries.Key},key);
                if any(idx)
                    entry=this.Entries(idx);
                else
                    entry=this.createEntry(model,targetType);
                end
            end
        end
    end

    methods(Static,Access=private)



        function key=createKey(model,targetType)

            key=[model,targetType];
        end




        function entry=createEntry(model,targetType)
            entry=coder.build.internal.BuildSummaryEntry;
            entry.Model=model;
            entry.Target=targetType;
            entry.Key=coder.build.internal.BuildSummary.createKey(model,targetType);
        end
    end
end
