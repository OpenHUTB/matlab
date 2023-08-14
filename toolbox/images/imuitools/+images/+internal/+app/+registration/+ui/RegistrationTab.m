classdef RegistrationTab<handle



    properties(Access={
        ?uitest.factory.Tester,...
        ?images.internal.app.registration.ImageRegistration,...
        ?images.internal.app.registration.Controller,...
        ?images.internal.app.registration.ui.View})


LoadFromFileDialog
WorkspaceDialog
ExportDialog

    end

    properties

        thisTab;


        newSessionButton;
        loadSessionButton;


        gallery;
        galleryItems;


        runEstimationButton;
        comparisonButton;


        exportButton;

saveFlag
        loadFromFilePopupItem;
        loadFromWorkspacePopupItem;
        exportToWorkspace;
        exportToFunction;
    end

    events
loadedNewImages
clearDataBrowser
runAlignment
    end

    methods

        function tool=RegistrationTab(name)
            import matlab.ui.internal.toolstrip.Tab;


            tool.thisTab=Tab(name);


            tool.setupSessionSection();


            tool.setupTechniqueGallerySection();


            tool.setupRegistrationSection();


            tool.setupComparisonSection();


            tool.setupExportSection();

            tool.disableAllButtons();

        end

        function[]=setupSessionSection(tool)
            import matlab.ui.internal.toolstrip.*;
            import images.internal.app.registration.ui.*;

            section=tool.thisTab.addSection(getMessageString('session'));
            section.Tag='sessionSection';

            c=section.addColumn();
            tool.newSessionButton=SplitButton(getMessageString('newSession'),Icon.IMPORT_24);
            tool.newSessionButton.Tag='newSessionButton';
            tool.newSessionButton.Description=getMessageString('newSessionTooltip');
            popup=PopupList;
            tool.loadFromFilePopupItem=ListItem(getMessageString('loadFromFile'),Icon.OPEN_16);
            tool.loadFromFilePopupItem.Tag='loadFromFile';
            tool.loadFromFilePopupItem.ShowDescription=false;
            tool.loadFromWorkspacePopupItem=ListItem(getMessageString('loadFromWorkspace'),Icon.IMPORT_16);
            tool.loadFromWorkspacePopupItem.Tag='loadFromWorkspace';
            tool.loadFromWorkspacePopupItem.ShowDescription=false;
            popup.add(tool.loadFromFilePopupItem);
            popup.add(tool.loadFromWorkspacePopupItem);
            tool.newSessionButton.Popup=popup;
            c.add(tool.newSessionButton);

        end

        function[]=setupTechniqueGallerySection(tool)
            import matlab.ui.internal.toolstrip.*;
            import images.internal.app.registration.ui.*;

            section=tool.thisTab.addSection(getMessageString('technique'));
            section.Tag='techniqueGallerySection';

            topCol=section.addColumn();


            featureCategory=GalleryCategory(getMessageString('featureBasedRegistration'));
            featureCategory.Tag='FeatureCategory';
            intensityCategory=GalleryCategory(getMessageString('intensityBasedRegistration'));
            intensityCategory.Tag='IntensityCategory';
            nonRigidCategory=GalleryCategory(getMessageString('nonrigidBasedRegistration'));
            nonRigidCategory.Tag='NonRigidCategory';

            popup=GalleryPopup();
            popup.Tag='GalleryPopup';
            popup.add(featureCategory);
            popup.add(intensityCategory);
            popup.add(nonRigidCategory);


            SURFIcon=fullfile(matlabroot,'toolbox','images','icons','SURF.png');
            tool.galleryItems.SURF=GalleryItem('SURF',Icon(SURFIcon));
            tool.galleryItems.SURF.Tag='SURFGalleryButton';
            tool.galleryItems.SURF.Description=getMessageString('SURFTooltip');
            featureCategory.add(tool.galleryItems.SURF);


            FASTIcon=fullfile(matlabroot,'toolbox','images','icons','FAST.png');
            tool.galleryItems.FAST=GalleryItem('FAST',Icon(FASTIcon));
            tool.galleryItems.FAST.Tag='FASTGalleryButton';
            tool.galleryItems.FAST.Description=getMessageString('FASTTooltip');
            featureCategory.add(tool.galleryItems.FAST);


            BRISKIcon=fullfile(matlabroot,'toolbox','images','icons','BRISK.png');
            tool.galleryItems.BRISK=GalleryItem('BRISK',Icon(BRISKIcon));
            tool.galleryItems.BRISK.Tag='BRISKGalleryButton';
            tool.galleryItems.BRISK.Description=getMessageString('BRISKTooltip');
            featureCategory.add(tool.galleryItems.BRISK);


            HarrisIcon=fullfile(matlabroot,'toolbox','images','icons','Harris.png');
            tool.galleryItems.Harris=GalleryItem('Harris',Icon(HarrisIcon));
            tool.galleryItems.Harris.Tag='HarrisGalleryButton';
            tool.galleryItems.Harris.Description=getMessageString('HarrisTooltip');
            featureCategory.add(tool.galleryItems.Harris);


            MinEigenIcon=fullfile(matlabroot,'toolbox','images','icons','MinEigen.png');
            tool.galleryItems.MinEigen=GalleryItem('MinEigen',Icon(MinEigenIcon));
            tool.galleryItems.MinEigen.Tag='MinEigenGalleryButton';
            tool.galleryItems.MinEigen.Description=getMessageString('MinEigenTooltip');
            featureCategory.add(tool.galleryItems.MinEigen);


            MSERIcon=fullfile(matlabroot,'toolbox','images','icons','MSER.png');
            tool.galleryItems.MSER=GalleryItem('MSER',Icon(MSERIcon));
            tool.galleryItems.MSER.Tag='MSERGalleryButton';
            tool.galleryItems.MSER.Description=getMessageString('MSERTooltip');
            featureCategory.add(tool.galleryItems.MSER);


            KAZEIcon=fullfile(matlabroot,'toolbox','images','icons','SURF.png');
            tool.galleryItems.KAZE=GalleryItem('KAZE',Icon(KAZEIcon));
            tool.galleryItems.KAZE.Tag='KAZEGalleryButton';
            tool.galleryItems.KAZE.Description=getMessageString('KAZETooltip');
            featureCategory.add(tool.galleryItems.KAZE);


            ORBIcon=fullfile(matlabroot,'toolbox','images','icons','BRISK.png');
            tool.galleryItems.ORB=GalleryItem('ORB',Icon(ORBIcon));
            tool.galleryItems.ORB.Tag='ORBGalleryButton';
            tool.galleryItems.ORB.Description=getMessageString('ORBTooltip');
            featureCategory.add(tool.galleryItems.ORB);


            MonoIcon=fullfile(matlabroot,'toolbox','images','icons','Monomodal_Intensity.png');
            tool.galleryItems.Monomodal=GalleryItem(getMessageString('monomodalIntensity'),Icon(MonoIcon));
            tool.galleryItems.Monomodal.Tag='MonomodalGalleryButton';
            tool.galleryItems.Monomodal.Description=getMessageString('MonoTooltip');
            intensityCategory.add(tool.galleryItems.Monomodal);


            MultiIcon=fullfile(matlabroot,'toolbox','images','icons','Multimodal_Intensity.png');
            tool.galleryItems.Multimodal=GalleryItem(getMessageString('multimodalIntensity'),Icon(MultiIcon));
            tool.galleryItems.Multimodal.Tag='MultimodalGalleryButton';
            tool.galleryItems.Multimodal.Description=getMessageString('MultiTooltip');
            intensityCategory.add(tool.galleryItems.Multimodal);


            CorrIcon=fullfile(matlabroot,'toolbox','images','icons','Correlation.png');
            tool.galleryItems.xCorr=GalleryItem(getMessageString('phaseCorrelation'),Icon(CorrIcon));
            tool.galleryItems.xCorr.Tag='correlationGalleryButton';
            tool.galleryItems.xCorr.Description=getMessageString('PhaseTooltip');
            intensityCategory.add(tool.galleryItems.xCorr);


            NonrigidIcon=fullfile(matlabroot,'toolbox','images','icons','Nonrigid.png');
            tool.galleryItems.Nonrigid=GalleryItem(getMessageString('nonrigid'),Icon(NonrigidIcon));
            tool.galleryItems.Nonrigid.Tag='NonrigidGalleryButton';
            tool.galleryItems.Nonrigid.Description=getMessageString('DemonsTooltip');
            nonRigidCategory.add(tool.galleryItems.Nonrigid);

            tool.gallery=Gallery(popup,'MaxColumnCount',4,'MinColumnCount',3);
            topCol.add(tool.gallery);
        end

        function[]=setupRegistrationSection(tool)
            import matlab.ui.internal.toolstrip.*;
            import images.internal.app.registration.ui.*;

            section=tool.thisTab.addSection(getMessageString('runRegistration'));
            section.Tag='registrationSection';

            c=section.addColumn();
            tool.runEstimationButton=Button(getMessageString('runEstimation'),Icon.RUN_24);
            tool.runEstimationButton.Tag='runEstimationButton';
            tool.runEstimationButton.Description=getMessageString('runEstimationTooltip');
            tool.runEstimationButton.ButtonPushedFcn=@(~,~)tool.runCallback();
            c.add(tool.runEstimationButton);
        end

        function[]=setupComparisonSection(tool)
            import matlab.ui.internal.toolstrip.*;
            import images.internal.app.registration.ui.*;

            section=tool.thisTab.addSection(getMessageString('comparison'));
            section.Tag='comparisonSection';
            c=section.addColumn('HorizontalAlignment','center');

            overlayLabel=Label(getMessageString('overlay'));
            c.add(overlayLabel);

            overlayTypes={'Green-Magenta';'Red-Cyan';'Difference';'Checkerboard';'Flicker'};
            tool.comparisonButton=DropDown(overlayTypes);
            tool.comparisonButton.Tag='comparisonButton';
            tool.comparisonButton.Description=getMessageString('overlayTooltip');
            tool.comparisonButton.Value='Green-Magenta';

            c.add(tool.comparisonButton);
        end

        function[]=setupExportSection(tool)
            import matlab.ui.internal.toolstrip.*;
            import images.internal.app.registration.ui.*;

            section=tool.thisTab.addSection(getMessageString('export'));
            section.Tag='exportSection';
            topCol=section.addColumn();
            tool.exportButton=SplitButton(getMessageString('export'),Icon.CONFIRM_24);
            tool.exportButton.Description=getMessageString('exportTooltip');
            tool.exportButton.Tag='ExportButton';
            popup=PopupList;
            tool.exportToWorkspace=ListItem(getMessageString('exportToWorkspace'));
            tool.exportToWorkspace.ShowDescription=false;
            tool.exportToWorkspace.Tag='exportToWorkspace';
            tool.exportToFunction=ListItem(getMessageString('exportToFunction'));
            tool.exportToFunction.ShowDescription=false;
            tool.exportToFunction.Tag='exportToFunction';
            popup.add(tool.exportToWorkspace);
            popup.add(tool.exportToFunction);
            tool.exportButton.Popup=popup;
            tool.exportButton.Enabled=false;
            topCol.add(tool.exportButton);
        end

        function[]=disableAllButtons(tool)
            tool.galleryItems.SURF.Enabled=false;
            tool.galleryItems.MSER.Enabled=false;
            tool.galleryItems.Nonrigid.Enabled=false;
            tool.galleryItems.xCorr.Enabled=false;
            tool.galleryItems.FAST.Enabled=false;
            tool.galleryItems.BRISK.Enabled=false;
            tool.galleryItems.Harris.Enabled=false;
            tool.galleryItems.MinEigen.Enabled=false;
            tool.galleryItems.KAZE.Enabled=false;
            tool.galleryItems.ORB.Enabled=false;
            tool.galleryItems.Monomodal.Enabled=false;
            tool.galleryItems.Multimodal.Enabled=false;
            tool.exportButton.Enabled=false;
            tool.comparisonButton.Enabled=false;
            tool.runEstimationButton.Enabled=false;
            tool.saveFlag=false;
        end

        function[]=enableAllButtons(tool)
            tool.galleryItems.SURF.Enabled=true;
            tool.galleryItems.MSER.Enabled=true;
            tool.galleryItems.Nonrigid.Enabled=true;
            tool.galleryItems.xCorr.Enabled=true;
            tool.galleryItems.FAST.Enabled=true;
            tool.galleryItems.BRISK.Enabled=true;
            tool.galleryItems.Harris.Enabled=true;
            tool.galleryItems.MinEigen.Enabled=true;
            tool.galleryItems.KAZE.Enabled=true;
            tool.galleryItems.ORB.Enabled=true;
            tool.galleryItems.Monomodal.Enabled=true;
            tool.galleryItems.Multimodal.Enabled=true;
            tool.comparisonButton.Enabled=true;
            tool.saveFlag=true;
        end

        function[]=enableBinaryButtons(tool)
            tool.galleryItems.SURF.Enabled=true;
            tool.galleryItems.MSER.Enabled=true;
            tool.galleryItems.Nonrigid.Enabled=true;
            tool.galleryItems.xCorr.Enabled=true;
            tool.galleryItems.FAST.Enabled=true;
            tool.galleryItems.BRISK.Enabled=true;
            tool.galleryItems.Harris.Enabled=true;
            tool.galleryItems.MinEigen.Enabled=true;
            tool.galleryItems.KAZE.Enabled=true;
            tool.galleryItems.ORB.Enabled=true;
            tool.galleryItems.Monomodal.Enabled=false;
            tool.galleryItems.Multimodal.Enabled=false;
            tool.comparisonButton.Enabled=true;
            tool.saveFlag=true;
        end

        function enableRunButton(tool,TF)
            tool.runEstimationButton.Enabled=TF;
            tool.comparisonButton.Enabled=true;
        end

        function enableExportButton(tool,TF)
            tool.exportButton.Enabled=TF;
            tool.comparisonButton.Enabled=true;
        end

        function disableWhenEmpty(tool)
            tool.exportButton.Enabled=false;
            tool.comparisonButton.Enabled=false;
            tool.runEstimationButton.Enabled=false;
        end

        function deleteGallery(tool)
            delete(tool.gallery);
        end

        function setRunTooltip(tool,msg)
            if isempty(char(msg))
                tool.runEstimationButton.Description=images.internal.app.registration.ui.getMessageString('runEstimationTooltip');
            else
                tool.runEstimationButton.Description=msg;
            end
        end

        function enableORB(tool)
            tool.galleryItems.ORB.Enabled=true;
        end

        function disableORB(tool)
            tool.galleryItems.ORB.Enabled=false;
        end

    end


    methods

        function newSessionButtonCallback(tool,hfig,loc,app)


            import images.internal.app.registration.ui.*;
            if tool.saveFlag
                openTab=blowAwaySessionDialog(hfig);
                if~openTab
                    return;
                end
            end


            tool.LoadFromFileDialog=images.internal.app.registration.ui.LoadImagesDialog(loc(1:2),hfig,app);
            wait(tool.LoadFromFileDialog);

            if tool.LoadFromFileDialog.Canceled
                return;
            end



            if(~isempty(tool.LoadFromFileDialog.fixedImage)&&~isempty(tool.LoadFromFileDialog.movingImage))
                imageData.fixed=tool.LoadFromFileDialog.fixedImage;
                imageData.moving=tool.LoadFromFileDialog.movingImage;

                isBinary=islogical(imageData.fixed)||islogical(imageData.moving);

                imageData.fixedRefObj=tool.LoadFromFileDialog.fixedReferenceObject;
                imageData.movingRefObj=tool.LoadFromFileDialog.movingReferenceObject;
                imageData.movingTransform=tool.LoadFromFileDialog.movingTransform;
                imageData.userLoadedTransform=tool.LoadFromFileDialog.userLoadedTransform;
                imageData.userLoadedFixedRefObj=tool.LoadFromFileDialog.userLoadedFixedRefObj;
                imageData.userLoadedMovingRefObj=tool.LoadFromFileDialog.userLoadedMovingRefObj;
                imageData.isFixedRGB=tool.LoadFromFileDialog.isFixedRGB;
                imageData.isMovingRGB=tool.LoadFromFileDialog.isMovingRGB;
                imageData.isMovingNormalized=tool.LoadFromFileDialog.isMovingNormalized;
                imageData.isFixedNormalized=tool.LoadFromFileDialog.isFixedNormalized;
                imageData.titleString=tool.LoadFromFileDialog.titleString;
                imageData.movingRGBImage=tool.LoadFromFileDialog.RGBImage;

                if tool.LoadFromFileDialog.preloadTechniques
                    imageData.initialArguments={'Phase Correlation','MSER','SURF'};
                else
                    imageData.initialArguments={};
                end

                evtData=images.internal.app.registration.model.customEventData(imageData);
                notify(tool,'clearDataBrowser');
                if isBinary
                    tool.enableBinaryButtons();
                else
                    tool.enableAllButtons();
                end

                if~tool.LoadFromFileDialog.preloadTechniques
                    disableWhenEmpty(tool);
                end

                notify(tool,'loadedNewImages',evtData);
            end


        end

        function runCallback(tool)
            notify(tool,'runAlignment');
        end

        function loadImagesFromWorkspaceCallback(tool,hfig,loc)


            import images.internal.app.registration.ui.*;
            if tool.saveFlag
                openTab=blowAwaySessionDialog(hfig);
                if~openTab
                    return;
                end
            end


            tool.WorkspaceDialog=images.internal.app.registration.ui.LoadFromWorkspace(loc(1:2),hfig);
            wait(tool.WorkspaceDialog);

            if tool.WorkspaceDialog.Canceled
                return;
            end

            if(~isempty(tool.WorkspaceDialog.fixedImage)&&~isempty(tool.WorkspaceDialog.movingImage))
                imageData.fixed=tool.WorkspaceDialog.fixedImage;
                imageData.moving=tool.WorkspaceDialog.movingImage;

                isBinary=islogical(imageData.fixed)||islogical(imageData.moving);

                imageData.fixedRefObj=tool.WorkspaceDialog.fixedReferenceObject;
                imageData.movingRefObj=tool.WorkspaceDialog.movingReferenceObject;
                imageData.movingTransform=tool.WorkspaceDialog.movingTransform;
                imageData.userLoadedTransform=tool.WorkspaceDialog.userLoadedTransform;
                imageData.userLoadedFixedRefObj=tool.WorkspaceDialog.userLoadedFixedRefObj;
                imageData.userLoadedMovingRefObj=tool.WorkspaceDialog.userLoadedMovingRefObj;
                imageData.isFixedRGB=tool.WorkspaceDialog.isFixedRGB;
                imageData.isMovingRGB=tool.WorkspaceDialog.isMovingRGB;
                imageData.isMovingNormalized=tool.WorkspaceDialog.isMovingNormalized;
                imageData.isFixedNormalized=tool.WorkspaceDialog.isFixedNormalized;
                imageData.titleString=tool.WorkspaceDialog.titleString;
                imageData.movingRGBImage=tool.WorkspaceDialog.RGBImage;

                if tool.WorkspaceDialog.preloadTechniques
                    imageData.initialArguments={'Phase Correlation','MSER','SURF'};
                else
                    imageData.initialArguments={};
                end

                evtData=images.internal.app.registration.model.customEventData(imageData);
                notify(tool,'clearDataBrowser');
                if isBinary
                    tool.enableBinaryButtons();
                else
                    tool.enableAllButtons();
                end

                if~tool.WorkspaceDialog.preloadTechniques
                    disableWhenEmpty(tool);
                end

                notify(tool,'loadedNewImages',evtData);
            end

        end


        function exportToWorkspaceCallback(tool,~,evtData,loc)

            import images.internal.app.registration.ui.*;

            tool.ExportDialog=images.internal.app.utilities.ExportToWorkspaceDialog(loc,getMessageString('exportToWorkspace'),"movingReg",string(getMessageString('exportVarLabel')));
            wait(tool.ExportDialog);

            if~tool.ExportDialog.Canceled
                assignin('base',tool.ExportDialog.VariableName,evtData.data);
            end

        end

        function exportToFunctionCallback(~,~,evtData,hfig)

            import images.internal.app.registration.ui.*;

            if any(contains(evtData.data.alignmentType,{'SURF','FAST','BRISK','Harris','MinEigen','MSER','KAZE','ORB'}))
                s=settings;
                showDialog=s.images.imageregistrationtool.CVSTWarningDialog.ActiveValue;
                if showDialog
                    uialert(hfig,getMessageString('CVTRequired'),getMessageString('CVTRequiredTitle'),'Icon','warning');
                    s.images.imageregistrationtool.CVSTWarningDialog.PersonalValue=false;
                end
            end

            images.internal.app.registration.ui.generateImageRegistrationCode(evtData.data);
        end

    end

end
