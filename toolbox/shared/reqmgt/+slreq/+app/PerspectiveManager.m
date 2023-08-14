classdef PerspectiveManager<handle







    events
ReqPerspectiveChange


ReqSpreadsheetToggled
    end

    properties(GetAccess=private,SetAccess=private)
inPerspective


        disableModelHs;



        graphLibraryBadgeDisabled=false;
    end

    properties(Constant)
        iconPathOn=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','perspective_disabled.png');
        iconPathOff=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','perspective_enabled.png');
    end

    methods

        function this=PerspectiveManager()
            this.inPerspective=containers.Map('KeyType','double','ValueType','logical');
            GLUE2.addDomainTransformativeGroupCreatorCallback('Simulink','ReqPerspectives',...
            @this.createPerspectiveGroupCallback);
            GLUE2.addDomainTransformativeGroupCreatorCallback('Stateflow','ReqPerspectives',...
            @this.createPerspectiveGroupSFCallback);
        end


        function delete(this)%#ok<INUSD>
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Simulink','ReqPerspectives');
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Stateflow','ReqPerspectives');
        end

        function togglePerspective(this,cStudio,isCmdLine)


            if nargin<3
                isCmdLine=false;
            end
            studioHelper=slreq.utils.DAStudioHelper.createHelper(cStudio);
            target=studioHelper.TopModelHandle;
            canvasTarget=studioHelper.ActiveModelHandle;

            bdTarget=bdroot(target);
            if~slreq.utils.isInPerspective(bdTarget,false)
                if isempty(get_param(bdTarget,'FileName'))&&~strcmpi(get_param(bdTarget,'IsHarness'),'on')


                    slreq.utils.errorDlgForEmptyModel('open perspective');
                    return;
                end
            end

            modelH=rmisl.getOwnerModelFromHarness(target);


            if bdIsLibrary(modelH)
                if~get_param(modelH,'ReqPerspectiveActive')
                    if strcmp(get_param(modelH,'lock'),'on')...



                        if isCmdLine
                            hyperLink=['<a href="matlab:rmisl.notifycb(''UnlockLibrary'', ''',getfullname(modelH),''')">',getString(message('Slvnv:slreq:UnlockLibrary')),'</a>'];
                            error(message('Slvnv:slreq:RequirementsPerspectiveUnlockLibraryCMDLine',hyperLink));
                        else
                            rmisl.notify(bdroot,message('Slvnv:slreq:RequirementsPerspectiveUnlockLibrary'),message('Slvnv:slreq:UnlockLibrary'));
                        end
                        return;
                    elseif strcmp(get_param(modelH,'lock'),'off')
                        libraryLockBadge=diagram.badges.get('graphlock','Graph');
                        do=slreq.utils.diagramResolve(modelH);

                        libraryLockBadge.setVisible(do,false);
                        this.graphLibraryBadgeDisabled=true;
                    end
                else
                    if this.graphLibraryBadgeDisabled
                        libraryLockBadge=diagram.badges.get('graphlock','Graph');
                        do=slreq.utils.diagramResolve(modelH);

                        libraryLockBadge.setVisible(do,true);
                        this.graphLibraryBadgeDisabled=false;
                    end
                end
            end

            lsm=slreq.linkmgr.LinkSetManager.getInstance;


            if lsm.hasPendingBannerMessage(modelH)
                messageObjs=lsm.getPendingBannerMessage(modelH);

                rmisl.notify(modelH,messageObjs{1},messageObjs{2});




                lsm.clearPendingBannerMessage(false);
            end

            if~isKey(this.inPerspective,modelH)

                this.inPerspective(modelH)=false;
                isFirstTime=true;
            else
                isFirstTime=false;
            end

            this.inPerspective(modelH)=~this.inPerspective(modelH);

            if isFirstTime





                lsm.scanMATLABPathOnSlreqInit(lsm.METADATA_SCAN_INIT_MODE_UI);
            end




            isLocked=~rmisl.isUnlocked(modelH,0);
            if isLocked
                Simulink.harness.internal.setBDLock(modelH,false);
                c=onCleanup(@()Simulink.harness.internal.setBDLock(modelH,true));
            end



            set_param(modelH,'ReqPerspectiveActive',this.inPerspective(modelH));





            canvasModelH=rmisl.getOwnerModelFromHarness(canvasTarget);
            this.notify('ReqPerspectiveChange',...
            slreq.app.PerspectiveChangeEvent(this.inPerspective(modelH),modelH,canvasModelH,cStudio));














            if isFirstTime
                slreq.internal.delayedLinksetLoader('load');
            end

            if this.inPerspective(modelH)
                hasLinkSet=false;
                modelFile=get_param(modelH,'FileName');
                if(~isempty(modelFile))
                    linkSetFile=slreq.data.ReqData.getInstance.getLinkSet(modelFile);
                    if~isempty(linkSetFile)&&exist(linkSetFile.filepath,'file')
                        hasLinkSet=true;
                    end
                end

                if~hasLinkSet

                    helpCount=rmisl.internalConfigVal('PerspectiveHelpCount');
                    if isempty(helpCount)
                        helpCount=0;
                    end

                    if(helpCount<3)

                        if isFirstTime
                            rmisl.internalConfigVal('PerspectiveHelpCount',helpCount+1);
                        end

                        rmisl.notify(modelH,message('Slvnv:slreq:PerspectiveStart'),...
                        message('Slvnv:slreq:PerspectiveHelp'));
                    end
                end
            end
        end

        function yesno=getStatus(this,target)
            modelH=rmisl.getOwnerModelFromHarness(target);
            if~isKey(this.inPerspective,modelH)

                yesno=false;
            else
                yesno=this.inPerspective(modelH);
            end
        end

        function removeFromPerspectiveMap(this,modelH)



            if isKey(this.inPerspective,modelH)
                this.inPerspective.remove(modelH);
            end
        end


        function addInDisabledModelList(this,modelH)
            this.disableModelHs(end+1)=modelH;
        end

        function removeFromDisabledModelList(this,modelH)
            this.disableModelHs(this.disableModelHs==modelH)=[];
        end

        function disableModelHs=getDisabledModelList(this)
            disableModelHs=this.disableModelHs;
        end

        function[out,msg]=sanityCheckForTogglePerspective(this,modelH)







            out=true;
            msg='';

            if rmiut.isBuiltinNoRmi(modelH)
                out=false;
                if nargout>1
                    msg=message('Slvnv:slreq:ErrorEnterPerspectiveDueToBuiltInLibrary');

                end
                return;
            end






            rt=sfroot;
            modelName=get_param(modelH,'Name');
            sfMachines=rt.find('-isa','Stateflow.Machine','Name',modelName);
            if~isempty(sfMachines)&&length(sfMachines)==1
                charts=sfMachines.find('-isa','Stateflow.Chart');
                if length(charts)==1&&Stateflow.App.IsStateflowApp(charts.Id)
                    modelH=sfprivate('machine2model',sfMachines.Id);
                    this.addInDisabledModelList(modelH);
                end
            end


            if ismember(modelH,this.disableModelHs)

                out=false;
                msg=message('Slvnv:slreq:ErrorEnterPerspectiveDueToDisabledModelList',getfullname(modelH));
                return;
            end

        end

        function[studio,rootModel]=checkModelBeforeTogglingPerspective(this,modelNameOrHandle)






























            if ischar(modelNameOrHandle)&&(~dig.isProductInstalled('Simulink')||~bdIsLoaded(modelNameOrHandle))



                error(message('Slvnv:slreq:ErrorEnterPerspectiveDueToUnopenedModel',modelNameOrHandle))
            end

            modelH=get_param(modelNameOrHandle,'Handle');
            modelName=getfullname(modelH);

            [studio,rootModel]=this.getStudioForShowingPerspective(modelH);
            if isempty(studio)
                error(message('Slvnv:slreq:ErrorEnterPerspectiveDueToUnopenedModel',modelName))
            end

            [isValidModel,msg]=this.sanityCheckForTogglePerspective(modelH);

            if~isValidModel
                error(msg);
            end
        end

        function[studio,studioRootModelH]=getStudioForShowingPerspective(~,modelH)
















            [studioRootModelH,~,canvasModelHandle,studio]=slreq.utils.DAStudioHelper.getCurrentBDHandle();
            if canvasModelHandle==modelH
                return;
            end

            st=slreq.utils.DAStudioHelper.getAllStudios(modelH,true);

            if~isempty(st)
                studio=st(1);
                studioRootModelH=studio.App.blockDiagramHandle;
                return;
            end

            st=slreq.utils.DAStudioHelper.getActiveStudios(modelH,true);

            if isempty(st)
                studio=[];
            else
                studio=st(1);
                studioRootModelH=studio.App.blockDiagramHandle;
            end

        end
    end

    methods(Access=private)
        function createPerspectiveGroupCallback(this,callbackInfo)
            info=callbackInfo.EventData;
            if info.getBlockHandle()==0
                client=info.getPerspectivesClient;
                this.displayPerspectiveControls(client);
            end
        end

        function createPerspectiveGroupSFCallback(this,callbackInfo)
            info=callbackInfo.EventData;
            if info.getBlockHandle()==0
                client=info.getPerspectivesClient;
                this.displayPerspectiveControlsSF(client);
            end
        end

        function displayPerspectiveControls(this,client)
            studioHelper=slreq.utils.DAStudioHelper.createHelper(client.getEditor);
            modelH=studioHelper.TopModelHandle;

            if~this.sanityCheckForTogglePerspective(modelH)
                return;
            end

            option=this.getPerspectiveControlOption(modelH,client);
            option.setSelectionCallback(@this.onClickHandler);
        end

        function displayPerspectiveControlsSF(this,client)
            modelH=slreq.app.getModelSF(client);

            if~this.sanityCheckForTogglePerspective(modelH)
                return;
            end

            option=this.getPerspectiveControlOption(modelH,client);
            option.setSelectionCallback(@this.onClickHandlerSF);
        end


        function option=getPerspectiveControlOption(this,modelH,client)
            location=GLUE2.getPerspectivesGroupLocation('Requirements');
            group=client.newTransformativeGroup(getString(message('Slvnv:slreq:Requirements')),location,false);

            if this.getStatus(modelH)
                myPath=this.iconPathOff;
                tooltip=getString(message('Slvnv:slreq:ExitPerspective'));
                bubleStr=getString(message('Slvnv:slreq:PerspectiveExit'));
            else
                myPath=this.iconPathOn;
                tooltip=getString(message('Slvnv:slreq:EnterPerspective'));
                bubleStr=getString(message('Slvnv:slreq:PerspectiveEnter'));
            end
            option=group.newOption('reqoption',myPath,bubleStr,tooltip);
        end


        function onClickHandler(this,callbackInfo)
            info=callbackInfo.EventData;
            client=info.getPerspectivesClient;
            editor=client.getEditor;
            studio=editor.getStudio;
            this.togglePerspective(studio);

            client.closePerspectives;
        end

        function onClickHandlerSF(this,callbackInfo)

            info=callbackInfo.EventData;
            client=info.getPerspectivesClient;

            editor=client.getEditor;
            studio=editor.getStudio;

            this.togglePerspective(studio);

            client.closePerspectives;
        end
    end
end