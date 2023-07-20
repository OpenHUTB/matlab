classdef OutdatedProfileReporter<matlab.apps.AppBase


    properties(Access=public)
        OutdatedProfileReportUIFigure matlab.ui.Figure
        Tree matlab.ui.container.Tree
        TheLabel matlab.ui.control.Label
        UpdateModelButton matlab.ui.control.Button
        CloseModelButton matlab.ui.control.Button
    end


    properties(Access=private)
ProfileUseChecker
Model
ProfileNamespace
    end

    methods(Access=private)

        function initializeTree(app)

            missingProfs_title=sprintf('Missing Profiles (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_MissingProfiles.Size);
            deletedStereotypes_title=sprintf('Deleted Stereotypes (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_DeletedPrototypes.Size);
            deletedProps_title=sprintf('Deleted Properties (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_DeletedProperties.Size);
            addedStereotypes_title=sprintf('Added Stereotypes (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_AddedPrototypes.Size);
            addedProps_title=sprintf('Added Properties (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_AddedProperties.Size);
            renamedStereotypes_title=sprintf('Renamed Stereotypes (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_RenamedPrototypes.Size);
            renamedProperties_title=sprintf('Renamed Properties (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_RenamedProperties.Size);
            sterotypeParentChange_title=sprintf('Stereotypes with changed parent (%i)',app.ProfileUseChecker.p_ProfileChangeReport.p_PrototypeParentChanged.Size);

            missingProfs=uitreenode(app.Tree,'Text',missingProfs_title,'NodeData',[],'Tag','MissingProfiles');
            deletedStereotypes=uitreenode(app.Tree,'Text',deletedStereotypes_title,'NodeData',[],'Tag','DeletedStereotypes');
            deletedProps=uitreenode(app.Tree,'Text',deletedProps_title,'NodeData',[],'Tag','DeletedProps');
            addedStereotypes=uitreenode(app.Tree,'Text',addedStereotypes_title,'NodeData',[],'Tag','AddedStereotypes');
            addedProps=uitreenode(app.Tree,'Text',addedProps_title,'NodeData',[],'Tag','AddedProps');
            renamedStereotypes=uitreenode(app.Tree,'Text',renamedStereotypes_title,'NodeData',[],'Tag','RenamedStereotypes');
            renamedProperties=uitreenode(app.Tree,'Text',renamedProperties_title,'NodeData',[],'Tag','RenamedProps');
            sterotypeParentChange=uitreenode(app.Tree,'Text',sterotypeParentChange_title,'NodeData',[],'Tag','ParentChanged');



            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_MissingProfiles.toArray
                uitreenode(missingProfs,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_DeletedPrototypes.toArray
                uitreenode(deletedStereotypes,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_DeletedProperties.toArray
                uitreenode(deletedProps,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_AddedPrototypes.toArray
                uitreenode(addedStereotypes,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_AddedProperties.toArray
                uitreenode(addedProps,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_RenamedPrototypes.toArray
                uitreenode(renamedStereotypes,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_RenamedProperties.toArray
                uitreenode(renamedProperties,'Text',item{1},'NodeData',[]);
            end
            for item=app.ProfileUseChecker.p_ProfileChangeReport.p_PrototypeParentChanged.toArray
                uitreenode(sterotypeParentChange,'Text',item{1},'NodeData',[]);
            end
        end

        function results=centerDialog(app)

            modelId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mf.zero.getModel(app.ProfileNamespace));
            studios=DAS.Studio.getAllStudios;
            studio=[];
            if~bdIsLoaded(modelId.URI)
                return;
            end
            matchingIdx=cellfun(@(s)s.App.blockDiagramHandle==get_param(modelId.URI,'Handle'),DAS.Studio.getAllStudios);
            if any(matchingIdx)
                studio=studios{matchingIdx};
            end
            screensize=get(0,'screensize');
            parentPos=screensize;
            curPos=app.OutdatedProfileReportUIFigure.Position;
            if(~isempty(studio))

                parentPos=studio.getStudioPosition;
                if(parentPos(3)<curPos(3)||parentPos(4)<curPos(4))


                    parentPos=screensize;
                end

            end
            x1=(parentPos(3)-curPos(3))/2+parentPos(1);
            y1=screensize(4)-((parentPos(4)-curPos(4))/2+parentPos(2)+curPos(4));
            app.OutdatedProfileReportUIFigure.Position=[x1,y1,curPos(3),curPos(4)];
        end

        function typeString=getArtifactType(app)
            mdl=mf.zero.getModel(app.ProfileNamespace);
            mdlId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mdl);
            typeString='model';
            if(mdlId.modelType==systemcomposer.services.proxy.ModelType.DICTIONARY_MODEL)
                typeString='dictionary';
            end
        end
    end



    methods(Access=private)


        function startupFcn(app,profileUseChecker,pucMfMdl)
            app.centerDialog();
            mdlId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mf.zero.getModel(app.ProfileNamespace));
            descText=message('SystemArchitecture:Profile:OutdatedProfileUIDesc',mdlId.URI).getString;
            app.TheLabel.Text=descText;
            app.initializeTree();
        end


        function UpdateModelButtonPushed(app,event)
            txn=mf.zero.getModel(app.ProfileNamespace).beginTransaction;
            app.ProfileNamespace.synchronizePostLoad(app.ProfileUseChecker);
            txn.commit;


            if~app.ProfileNamespace.p_IsProfileOutdated
                app.delete;
            else
                uialert(app.OutdatedProfileReportUIFigure,"Failed to synchronize model with profile changes","Failed to Synchronize");
            end
        end


        function CloseModelButtonPushed(app,event)
            mdl=mf.zero.getModel(app.ProfileNamespace);
            mdlId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mdl);
            if(mdlId.modelType==systemcomposer.services.proxy.ModelType.ARCH_COMP_MODEL)
                close_system(mdlId.URI);
            elseif(mdlId.modelType==systemcomposer.services.proxy.ModelType.DICTIONARY_MODEL)
                Simulink.data.dictionary.closeAll([mdlId.URI,'.sldd'],'-discard');
            end
            app.delete;
        end
    end


    methods(Access=private)


        function createComponents(app)


            app.OutdatedProfileReportUIFigure=uifigure('Visible','off');
            app.OutdatedProfileReportUIFigure.Position=[100,100,637,435];
            app.OutdatedProfileReportUIFigure.Name='Outdated Profile Report';
            app.OutdatedProfileReportUIFigure.Tag='SystemArchitecture:Profile:OutdatedProfileReport';


            app.Tree=uitree(app.OutdatedProfileReportUIFigure);
            app.Tree.Position=[14,52,612,300];
            app.Tree.Tag='SystemArchitecture:Profile:ReportTree';


            app.TheLabel=uilabel(app.OutdatedProfileReportUIFigure,'WordWrap','on');
            app.TheLabel.Position=[14,367,612,42];
            typeString=app.getArtifactType();
            app.TheLabel.Text={['One or more profiles attached to the ',typeString,' '''' is outdated or missing . The ',typeString,' might exhibit unexpected behavior.'];['The details of what is outdated and missing is shown below. Please close the ',typeString,' and add any missing profiles'];['to the path or select to update the ',typeString,' with the changes from the profile.']};


            app.UpdateModelButton=uibutton(app.OutdatedProfileReportUIFigure,'push');
            app.UpdateModelButton.ButtonPushedFcn=createCallbackFcn(app,@UpdateModelButtonPushed,true);
            app.UpdateModelButton.Position=[14,19,110,22];
            typeString=app.getArtifactType;
            contextText=[upper(typeString(1)),typeString(2:end)];
            app.UpdateModelButton.Text=['Update ',contextText];
            app.UpdateModelButton.Tag='SystemArchitecture:Profile:UpdateModelButton';


            app.CloseModelButton=uibutton(app.OutdatedProfileReportUIFigure,'push');
            app.CloseModelButton.ButtonPushedFcn=createCallbackFcn(app,@CloseModelButtonPushed,true);
            app.CloseModelButton.Position=[139,19,110,22];
            app.CloseModelButton.Text=['Close ',contextText];
            app.CloseModelButton.Tag='SystemArchitecture:Profile:CloseModelButton';


            app.OutdatedProfileReportUIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=OutdatedProfileReporter(varargin)

            app.ProfileUseChecker=varargin{1};
            app.Model=varargin{2};
            app.ProfileNamespace=app.ProfileUseChecker.p_ProfileNamespace;


            createComponents(app)


            registerApp(app,app.OutdatedProfileReportUIFigure)


            runStartupFcn(app,@(app)startupFcn(app,varargin{:}))

            if nargout==0
                clear app
            end
        end


        function delete(app)


            delete(app.OutdatedProfileReportUIFigure)
        end
    end
end