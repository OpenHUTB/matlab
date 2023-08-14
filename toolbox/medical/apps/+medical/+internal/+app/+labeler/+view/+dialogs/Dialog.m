classdef Dialog<handle




    properties(Access=protected)

        MATFileFilterSpec={'*.mat','MAT-files (*.mat)'};
        VolumeModeFilterSpec={'*.dcm'}

WaitBar

UseDarkMode

    end

    events

BringAppToFront

SliceAtIndexRequested
UpdateDialogSummary
ThrowError

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)
        OpenDialog matlab.ui.Figure
        ShortcutDialog matlab.ui.Figure
        AutomationHelpDialog matlab.ui.Figure
RegionSelector
    end

    methods

        function self=Dialog(useDarkMode)
            self.UseDarkMode=useDarkMode;
        end

        function delete(self)

            delete(self.OpenDialog);
            self.clearWaitBar();

            if~isempty(self.ShortcutDialog)&&isvalid(self.ShortcutDialog)
                close(self.ShortcutDialog);
            end

            if~isempty(self.AutomationHelpDialog)&&isvalid(self.AutomationHelpDialog)
                close(self.AutomationHelpDialog);
            end

        end


        function close(self)

            if isvalid(self.OpenDialog)
                uiresume(self.OpenDialog);
                close(self.OpenDialog);
            end

            if~isempty(self.ShortcutDialog)&&isvalid(self.ShortcutDialog)
                close(self.ShortcutDialog);
            end

            if~isempty(self.AutomationHelpDialog)&&isvalid(self.AutomationHelpDialog)
                close(self.AutomationHelpDialog);
            end

        end


        function[location,isCanceled]=newSessionLocation(self,loc)

            location='';

            self.close();

            dlg=medical.internal.app.labeler.view.dialogs.NewSessionDialog(loc);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            addlistener(dlg,'BringAppToFront',@(src,evt)self.notify('BringAppToFront'));
            self.OpenDialog=dlg.FigureHandle;
            dlg.wait();

            self.notify('BringAppToFront');

            if~dlg.Canceled
                location=dlg.SessionFolder;
            end

            isCanceled=dlg.Canceled;

        end


        function[directorySelected,isCanceled]=openSession(self)

            self.close();

            defaultPath=userpath;

            directorySelected=uigetdir(defaultPath,getString(message('medical:medicalLabeler:openSession')));
            if directorySelected==0
                directorySelected='';
                isCanceled=true;
            else
                directorySelected=string(directorySelected);
                isCanceled=false;
            end


        end


        function[filename,isCanceled]=importVolumeFromFile(self)

            self.close();

            title=getString(message('medical:medicalLabeler:importVolume'));
            filterSpec=medical.internal.app.labeler.utils.createVolumeModeFilterSpec();
            [filename,isCanceled]=medical.internal.app.utils.getfile(filterSpec,'MultiSelect',true,'Title',title);
            filename=string(filename);

        end


        function[filename,isCanceled]=importImageSequenceFromFile(self)

            self.close();

            title=getString(message('medical:medicalLabeler:importImage'));
            filterSpec=medical.internal.app.labeler.utils.createImageModeFilterSpec();
            [filename,isCanceled]=medical.internal.app.utils.getfile(filterSpec,'MultiSelect',true,'Title',title);
            filename=string(filename);

        end


        function[directorySelected,isCanceled]=importVolumeFromDICOMFolder(self)

            self.close();

            directorySelected=images.internal.app.volview.volgetfolder();
            if isempty(directorySelected)
                isCanceled=true;
            else
                directorySelected=string(directorySelected);
                isCanceled=false;
            end


        end


        function[filename,isCanceled]=importLabelDefsFromFile(self)

            self.close();

            dialogTitle=getString(message('medical:medicalLabeler:importLabelDefinitions'));
            [filename,isCanceled]=medical.internal.app.labeler.view.dialogs.importFromFileDialog("DialogTitle",dialogTitle);
            filename=string(filename);

        end


        function[filename,isCanceled]=importGroundTruthFromFile(self)

            self.close();

            dialogTitle=getString(message('medical:medicalLabeler:importGroundTruth'));
            [filename,isCanceled]=medical.internal.app.labeler.view.dialogs.importFromFileDialog("DialogTitle",dialogTitle);
            filename=string(filename);

        end


        function[var,isCanceled]=importGroundTruthFromWksp(self,loc)

            self.close();

            isCanceled=false;
            var='';

            dialogTitle=getString(message('medical:medicalLabeler:importGroundTruth'));
            msg=getString(message('images:segmenter:variables'));

            dlg=images.internal.app.utilities.VariableDialog(loc,dialogTitle,msg,'groundTruthMedical');
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            if dlg.Canceled
                isCanceled=true;
            else
                var=evalin('base',dlg.SelectedVariable);
            end

        end


        function[filename,isCanceled]=exportGroundTruthToFile(self)

            self.close();

            isCanceled=false;
            filename='';

            [file,path]=uiputfile(self.MATFileFilterSpec,...
            getString(message('medical:medicalLabeler:exportGroundTruth')),'groundTruthMed');

            if file==0
                isCanceled=true;
            else
                filename=fullfile(path,file);
                filename=string(filename);
            end

        end


        function[filename,isCanceled]=exportLabelDefsToFile(self)

            self.close();

            isCanceled=false;
            filename='';

            [file,path]=uiputfile(self.MATFileFilterSpec,...
            getString(message('medical:medicalLabeler:exportLabelDefinitions')),'labelDefinitions');

            if file==0
                isCanceled=true;
            else
                filename=fullfile(path,file);
                filename=string(filename);
            end

        end


        function[dicomCollection,isCanceled]=importCollectionFromWorkspace(self,loc)

            self.close();

            title=getString(message('medical:medicalLabeler:addDicomCollection'));
            msg=getString(message('medical:medicalLabeler:dicomCollection'));
            dlg=images.internal.app.utilities.VariableDialog(loc,title,msg,'dicomCollection');
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            if dlg.Canceled
                dicomCollection='';
            else
                dicomCollection=evalin('base',dlg.SelectedVariable);
            end

            isCanceled=dlg.Canceled;

        end


        function[pos1,pos2,idx1,idx2,val,interpSliceDir,isCanceled]=displayRegionSelector(self,loc,alpha,contrastLimits,rotationState,roi,val,mask,startIdx,isDataOblique,pixSize,sliceDir)

            close(self);

            self.RegionSelector=medical.internal.app.labeler.view.dialogs.RegionSelectorDialog(loc,alpha,contrastLimits,rotationState,startIdx,isDataOblique,pixSize,sliceDir);
            if self.UseDarkMode
                self.RegionSelector.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=self.RegionSelector.FigureHandle;

            addlistener(self.RegionSelector,'SliceAtLocationRequested',@(src,evt)notify(self,'SliceAtIndexRequested',evt));
            addlistener(self.RegionSelector,'UpdateSummary',@(src,evt)notify(self,'UpdateDialogSummary',evt));
            addlistener(self.RegionSelector,'ThrowError',@(src,evt)cancelRegionSelector(self,evt));
            initialize(self.RegionSelector);

            if isvalid(self.RegionSelector.FigureHandle)

                if~isempty(roi)
                    setFirstRegion(self.RegionSelector,val,mask);
                end

                if isvalid(self.RegionSelector.FigureHandle)

                    wait(self.RegionSelector);
                    self.notify('BringAppToFront');

                end

            end

            isCanceled=self.RegionSelector.Canceled;

            if isCanceled

                pos1=[];
                pos2=[];
                idx1=[];
                idx2=[];
                val=[];
                interpSliceDir=[];

            else

                pos=images.internal.builtins.bwborders(double(self.RegionSelector.MaskOne),self.RegionSelector.Connectivity);
                pos1=fliplr(pos{1});
                pos=images.internal.builtins.bwborders(double(self.RegionSelector.MaskTwo),self.RegionSelector.Connectivity);
                pos2=fliplr(pos{1});
                idx1=self.RegionSelector.SliceOne;
                idx2=self.RegionSelector.SliceTwo;
                val=self.RegionSelector.Value;
                interpSliceDir=self.RegionSelector.SliceDirection;

            end

            delete(self.RegionSelector);

        end


        function updateRegionSelector(self,vol,labels,cmap,idx,maxIdx)

            if~isempty(self.RegionSelector)&&isvalid(self.RegionSelector)

                update(self.RegionSelector,vol,labels,cmap,idx,maxIdx);

            end

        end


        function updateDialogSummary(self,data,color)

            if~isempty(self.RegionSelector)&&isvalid(self.RegionSelector)

                updateSummary(self.RegionSelector,data,color);

            end

        end


        function displayShortcuts(self,loc)

            if isempty(self.ShortcutDialog)||~isvalid(self.ShortcutDialog)

                dlg=medical.internal.app.labeler.view.dialogs.ShortcutsDialog(loc);
                if self.UseDarkMode
                    dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
                end
                self.ShortcutDialog=dlg.FigureHandle;
                set(dlg.FigureHandle,'Visible','on');
                set(dlg.FigureHandle,'Tag','ShortcutsDialog')

            else
                movegui(self.ShortcutDialog,'onscreen');
                figure(self.ShortcutDialog);
            end

        end

        function displayAutomationHelp(self,loc,dataFormat)

            if isempty(self.AutomationHelpDialog)||~isvalid(self.AutomationHelpDialog)

                dlg=medical.internal.app.labeler.view.dialogs.AutomationHelpDialog(loc,dataFormat);
                if self.UseDarkMode
                    dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
                end
                self.AutomationHelpDialog=dlg.FigureHandle;
                set(dlg.FigureHandle,'Visible','on');

            else
                movegui(self.AutomationHelpDialog,'onscreen');
                figure(self.AutomationHelpDialog);
            end

        end


        function name=displayFilter(self,loc,title,msg,candidates)

            self.close();

            dlg=images.internal.app.utilities.FilterDialog(loc,title,msg,candidates);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            if dlg.Canceled
                name='';
            else
                name=dlg.SelectedLabel;
            end

        end


        function[selectedViews,filename,isCanceled]=snapshotVolumeMode(self,loc,sliceViewNames)

            self.close();

            dlg=medical.internal.app.labeler.view.dialogs.SnapshotDialog(loc,sliceViewNames);

            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end

            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            isCanceled=dlg.Canceled;

            if isCanceled
                selectedViews='';
                filename='';
            else
                selectedViews=dlg.SelectedViews;
                filename=dlg.FilenamePrefix;
            end

        end


        function[filename,isCanceled]=snapshotImageSequenceMode(~)

            [filename,path]=uiputfile("*.png",getString(message('medical:medicalLabeler:saveSnapshot')));
            if filename==0
                isCanceled=true;
                filename=[];
            else
                isCanceled=false;
                filename=fullfile(path,filename);
            end

        end


        function[saveToValue,isCanceled]=saveRendering(self,loc)

            self.close();

            title=getString(message('medical:medicalLabeler:saveCurrentRendering'));
            msg=getString(message('medical:medicalLabeler:renderingName'));
            dlg=medical.internal.app.labeler.view.dialogs.SaveDialog(loc,title,msg);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            isCanceled=dlg.Canceled;

            if isCanceled
                saveToValue='';
            else
                saveToValue=dlg.SaveToValue;
                saveToValue=string(saveToValue);
            end

        end


        function[removeRenderingTags,isCanceled]=manageCustomRendering(self,loc,names,tags)

            self.close();

            dlg=medical.internal.app.labeler.view.dialogs.ManageCustomRenderingDialog(loc,names,tags);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            isCanceled=dlg.Canceled;

            if isCanceled
                removeRenderingTags='';
            else
                removeRenderingTags=dlg.RemoveRenderingList;
                removeRenderingTags=string(removeRenderingTags);
            end

        end


        function[isCanceled,alg]=addAlgorithm(self,loc,title)

            self.close();

            dlg=images.internal.app.segmenter.volume.dialogs.AddAlgorithmDialog(loc,title);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            isCanceled=dlg.Canceled;
            alg=dlg.FilePath;

        end


        function isCanceled=manageAlgorithms(self,loc,title)

            self.close();

            dlg=images.internal.app.segmenter.volume.dialogs.ManageAlgorithmDialog(loc,title);
            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;
            wait(dlg);
            self.notify('BringAppToFront');

            isCanceled=dlg.Canceled;

        end


        function displaySettings(self,loc,dlg)

            self.close();

            dlg.Location=loc;
            create(dlg);

            if self.UseDarkMode
                dlg.FigureHandle.Theme=matlab.graphics.internal.themes.darkTheme;
            end
            self.OpenDialog=dlg.FigureHandle;

        end


        function displayError(self,hParent,msg,title)

            self.close();
            uialert(hParent,msg,title,'Modal',true);

        end


        function displayWarning(self,hParent,msg,title)

            self.close();
            uialert(hParent,msg,title,'Modal',true,'Icon','warning');

        end


        function isCanceled=askQuestion(self,hParent,question,title)

            self.close();

            isCanceled=false;

            answer=uiconfirm(hParent,question,title,...
            'Options',{getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:cancel'))},...
            'DefaultOption',2,...
            'CancelOption',2);

            if strcmp(answer,getString(message('images:commonUIString:cancel')))
                isCanceled=true;
            end

        end


        function startWaitBar(self,hParent,title,msg)

            self.close();

            if isempty(title)
                title=getString(message('images:segmenter:pleaseWait'));
            end

            self.WaitBar=uiprogressdlg(hParent,...
            'Title',title,...
            'Message',msg,...
            'Indeterminate','on');

        end


        function updateWaitBarMessage(self,msg)
            if~isempty(self.WaitBar)&&isvalid(self.WaitBar)
                self.WaitBar.Message=msg;
            end
        end


        function clearWaitBar(self)

            self.close();

            if~isempty(self.WaitBar)&&isvalid(self.WaitBar)
                close(self.WaitBar);
            end

        end

    end

    methods(Access=protected)


        function cancelRegionSelector(self,evt)

            close(self);
            self.notify(ThrowError',evt);
            self.notify('BringAppToFront');

        end

    end

end
