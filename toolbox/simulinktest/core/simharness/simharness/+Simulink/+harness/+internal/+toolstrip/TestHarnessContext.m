classdef TestHarnessContext<dig.CustomContext








    properties(SetAccess=immutable)
        ModelHandle(1,1)double;
    end

    properties(SetAccess=public,SetObservable=true)

        harnessName(1,1)string;


        rebuildWithoutCompile(1,1)logical=false;
        rebuildOnOpen(1,1)logical=false;
        rebuildModelData(1,1)logical=false;


        syncOnOpenClose(1,1)logical=true;
        syncOnOpenOnly(1,1)logical=false;
        syncOnPushRebuildOnly(1,1)logical=false;


        canPushChangesToMainModel(1,1)logical=true;


        canDetachAndExportTestHarnessModel(1,1)logical=true;


        pushCheckRebuildEnabled(1,1)logical=true;
        rebuildWithoutCompileEnabled(1,1)logical=true;
        otherRebuildOptionsEnabled(1,1)logical=true;


        syncOnOpenCloseEnabled(1,1)logical=true;
        syncOnOpenOnlyEnabled(1,1)logical=true;
        syncOnPushRebuildOnlyEnabled(1,1)logical=true;


        syncOnPushRebuildOnlyText(1,1)string;
    end

    methods
        function obj=TestHarnessContext(modelHandle)
            app=struct;
            app.name='testHarnessModelApp';
            app.defaultContextType='';
            app.defaultTabName='';
            app.priority=0;

            obj@dig.CustomContext(app);
            obj.ModelHandle=modelHandle;

            if strcmp(get_param(modelHandle,'IsHarness'),'off')

                return;
            end



            obj.refresh;
        end

        function computeAvailabilityOfRebuildOptions(obj,h)
            if~bdIsLibrary(h.model)&&~bdIsSubsystem(h.model)

                obj.otherRebuildOptionsEnabled=true;
                obj.pushCheckRebuildEnabled=true;



                CUTIsLinkedSS=false;
                if strcmp(h.ownerType,'Simulink.SubSystem')
                    CUTIsLinkedSS=strcmp(get_param(h.ownerFullPath,'LinkStatus'),'resolved')||...
                    strcmp(get_param(h.ownerFullPath,'LinkStatus'),'inactive');
                end

                if(strcmp(h.ownerType,'Simulink.ModelReference')||...
                    strcmp(h.ownerType,'Simulink.BlockDiagram')||...
                    CUTIsLinkedSS||...
                    h.verificationMode==0)
                    obj.rebuildWithoutCompileEnabled=true;
                else
                    obj.rebuildWithoutCompileEnabled=false;
                end

            else

                obj.otherRebuildOptionsEnabled=false;
                obj.rebuildWithoutCompileEnabled=false;
                obj.pushCheckRebuildEnabled=false;
            end
        end

        function computeAvailabilityOfSyncOptions(obj,h)

            CUTIsImplicitLink=false;
            if ishandle(h.ownerHandle)&&strcmp(get_param(h.ownerHandle,'Type'),'block')
                CUTIsImplicitLink=Simulink.harness.internal.isImplicitLink(h.ownerHandle);
            end

            if obj.isZCModel(h.model)

                obj.syncOnOpenCloseEnabled=false;
                obj.syncOnOpenOnlyEnabled=true;
                obj.syncOnPushRebuildOnlyEnabled=false;
            elseif~strcmp(h.ownerType,'Simulink.BlockDiagram')&&...
                ~CUTIsImplicitLink&&...
                h.verificationMode==0
                obj.syncOnOpenCloseEnabled=(h.synchronizationMode~=2);
                obj.syncOnOpenOnlyEnabled=(h.synchronizationMode~=2);
                obj.syncOnPushRebuildOnlyEnabled=false;
                obj.syncOnPushRebuildOnlyText=message('Simulink:Harness:SyncOptExplicitFull').getString;
            else
                obj.syncOnOpenCloseEnabled=false;
                obj.syncOnOpenOnlyEnabled=false;
                obj.syncOnPushRebuildOnlyEnabled=false;
                obj.syncOnPushRebuildOnlyText=message('Simulink:Harness:SyncOptExplicitOneWay').getString;
            end





            activeHarness=Simulink.harness.internal.getHarnessList(h.model,'active');
            if~isempty(activeHarness)&&(slfeature('MultipleHarnessOpen')>0)
                openHarnesses=Simulink.harness.internal.getHarnessList(h.model,'loaded');
                if h.synchronizationMode~=2&&length(openHarnesses)>1
                    obj.syncOnOpenCloseEnabled=(h.synchronizationMode==0);
                    obj.syncOnOpenOnlyEnabled=(h.synchronizationMode==1);
                end
            end

        end

        function computeAvailabilityOfPushOptions(obj,h)


            openHarnesses=Simulink.harness.internal.getHarnessList(h.model,'loaded');
            obj.canPushChangesToMainModel=(~obj.isZCModel(h.model)&&obj.pushCheckRebuildEnabled)&&length(openHarnesses)<=1;
        end

        function computeAvailabilityOfDetachAndExportOptions(obj,h)

            obj.canDetachAndExportTestHarnessModel=~obj.isZCModel(h.model);
        end

        function ret=isZCModel(obj,model)%#ok<INUSL> 

            ret=false;
            if~bdIsLibrary(model)&&Simulink.internal.isArchitectureModel(model)
                ret=true;
            end
        end

        function refresh(obj)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(obj.ModelHandle);
            if isempty(h)



                return;
            end


            obj.computeAvailabilityOfRebuildOptions(h);


            obj.computeAvailabilityOfSyncOptions(h);


            obj.computeAvailabilityOfPushOptions(h);


            obj.computeAvailabilityOfDetachAndExportOptions(h);


            obj.harnessName=h.name;
            obj.rebuildWithoutCompile=h.graphical;
            obj.rebuildOnOpen=h.rebuildOnOpen;
            obj.rebuildModelData=h.rebuildModelData;
            obj.syncOnOpenClose=(h.synchronizationMode==0);
            obj.syncOnOpenOnly=(h.synchronizationMode==1);
            obj.syncOnPushRebuildOnly=(h.synchronizationMode==2);
        end
    end

end
