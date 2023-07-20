classdef Dialog<handle




    events

SliceAtLocationRequested

UpdateDialogSummary

ThrowError

    end

    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},...
        SetAccess=private,Transient)

WaitBar

        LastOpenDialog matlab.ui.Figure

        ShortcutDialog matlab.ui.Figure

        RegionSelector images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog

        ReviewResults images.internal.app.segmenter.volume.dialogs.ReviewResultsDialog

        Tag="DialogObject"
    end


    methods




        function close(self)

            if isvalid(self.LastOpenDialog)
                uiresume(self.LastOpenDialog);
                close(self.LastOpenDialog);
            end

        end




        function closeAll(self)

            close(self);
            clearWaitBar(self);

            if~isempty(self.ShortcutDialog)&&isvalid(self.ShortcutDialog)
                close(self.ShortcutDialog);
            end

        end




        function displayError(self,msg,title)

            close(self);
            self.LastOpenDialog=errordlg(msg,title,'modal');

        end




        function webDisplayError(self,fig,msg,title)

            close(self);
            uialert(fig,msg,title,'Modal',true);

        end




        function str=displayQuestion(self,quest,title)

            close(self);
            answer=questdlg(quest,title,...
            getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:no')),...
            getString(message('images:commonUIString:cancel')),...
            getString(message('images:commonUIString:cancel')));

            if strcmp(answer,getString(message('images:commonUIString:yes')))
                str='yes';
            elseif strcmp(answer,getString(message('images:commonUIString:no')))
                str='no';
            else
                str='cancel';
            end

        end




        function str=webDisplayQuestion(self,fig,quest,title)

            close(self);

            answer=uiconfirm(fig,quest,title,...
            'Options',{getString(message('images:commonUIString:yes')),...
            getString(message('images:commonUIString:no')),...
            getString(message('images:commonUIString:cancel'))},...
            'DefaultOption',1,'CancelOption',3);

            if strcmp(answer,getString(message('images:commonUIString:yes')))
                str='yes';
            elseif strcmp(answer,getString(message('images:commonUIString:no')))
                str='no';
            else
                str='cancel';
            end

        end




        function displayWarning(~,~,~,varargin)



        end




        function name=displayFilter(self,loc,title,msg,candidates)

            close(self);
            dlg=images.internal.app.utilities.FilterDialog(loc,title,msg,candidates);

            self.LastOpenDialog=dlg.FigureHandle;

            wait(dlg);

            if dlg.Canceled
                name='';
            else
                name=dlg.SelectedLabel;
            end

        end




        function var=importLabelNames(self,loc,title,msg)

            close(self);
            dlg=images.internal.app.utilities.VariableDialog(loc,title,msg,'text');

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            if dlg.Canceled
                var='';
            else
                var=evalin('base',dlg.SelectedVariable);
            end

        end




        function isCanceled=manageAlgorithms(self,loc,title)

            close(self);
            dlg=images.internal.app.segmenter.volume.dialogs.ManageAlgorithmDialog(loc,title);

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            isCanceled=dlg.Canceled;

        end




        function[isCanceled,alg]=addAlgorithm(self,loc,title)

            close(self);
            dlg=images.internal.app.segmenter.volume.dialogs.AddAlgorithmDialog(loc,title);

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            isCanceled=dlg.Canceled;
            alg=dlg.FilePath;

        end




        function startWaitBar(self,useWeb,hfig,msg)

            close(self);

            if isempty(msg)
                msg=getString(message('images:segmenter:pleaseWait'));
            end

            if useWeb
                self.WaitBar=uiprogressdlg(hfig,'Title',msg,...
                'Indeterminate','on');
            else
                self.WaitBar=waitbar(0,msg,'WindowStyle','modal');
            end

        end




        function clearWaitBar(self)

            if~isempty(self.WaitBar)&&isvalid(self.WaitBar)
                close(self.WaitBar);
            end

            self.WaitBar=matlab.ui.Figure.empty;

        end




        function[V,isCanceled]=openVolumeFromWorkspace(self,loc,isBlocked)

            close(self);
            if isBlocked
                dlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:segmenter:importVolume')),getString(message('images:segmenter:variables')),'blockedImage');
            else
                dlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:segmenter:importVolume')),getString(message('images:segmenter:variables')),'grayOrRGBVolume');
            end

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            if dlg.Canceled
                V=[];
            else
                V=evalin('base',dlg.SelectedVariable);
            end

            isCanceled=dlg.Canceled;

        end




        function[V,isCanceled,isError]=openBlockedImageFromWorkspace(self,loc)

            close(self);

            vars=evalin('base','whos');

            TF=false;
            isError=false;

            for idx=1:numel(vars)
                TF=TF||strcmp(vars(idx).class,'blockedImage');
            end

            if TF

                dlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:segmenter:importBlockedImage')),getString(message('images:segmenter:variables')),'blockedImage');

                self.LastOpenDialog=dlg.FigureHandle;
                wait(dlg);

                if dlg.Canceled
                    V=[];
                else
                    V=evalin('base',dlg.SelectedVariable);
                end

                isCanceled=dlg.Canceled;

            else
                isCanceled=true;
                V=[];
                isError=true;
            end

        end




        function[filename,isCanceled]=openVolumeFromFile(self)

            close(self);
            [filename,isCanceled]=images.internal.app.volview.volgetfile();

        end




        function[filename,isCanceled]=openBlockedImageFromFile(self)

            close(self);

            [fname,pathname,filterindex]=uigetfile('',getString(message('images:segmenter:openBlockedImage')));
            isCanceled=(filterindex==0);
            if~isCanceled
                filename=fullfile(pathname,fname);
            else
                filename='';
            end

        end




        function[path,isCanceled]=openBlockedImageFromFolder(self)

            close(self);
            path=uigetdir('',getString(message('images:segmenter:openBlockedImageFolder')));
            isCanceled=isequal(path,0);

        end




        function[directorySelected,isCanceled]=openVolumeFromDICOM(self)

            close(self);
            [directorySelected,isCanceled]=images.internal.app.volview.volgetfolder();

        end




        function[V,isCanceled]=openLabelsFromWorkspace(self,loc)

            close(self);
            dlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:segmenter:importLabels')),getString(message('images:segmenter:variables')),'labelVolume');

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            if dlg.Canceled
                V=[];
            else
                V=evalin('base',dlg.SelectedVariable);
            end

            isCanceled=dlg.Canceled;

        end




        function[filename,isCanceled]=openLabelsFromFile(self)

            close(self);
            [filename,isCanceled]=images.internal.app.volview.volgetfile('*.mat');

        end




        function[file,path,isLogical,isCanceled]=saveLabelsToFile(self,loc,saveAsLogical,eligibleToSaveAsLogical)

            close(self);

            if eligibleToSaveAsLogical&&isempty(saveAsLogical)

                dlg=images.internal.app.segmenter.volume.dialogs.VariableTypeDialog(loc,getString(message('images:segmenter:saveAsLogicalTitle')));

                self.LastOpenDialog=dlg.FigureHandle;
                wait(dlg);

                if dlg.Canceled
                    isLogical=saveAsLogical;
                    isCanceled=true;
                    file=0;
                    path=0;
                    return;
                else
                    isLogical=dlg.IsLogical;
                end

            else
                isLogical=saveAsLogical;
            end

            [file,path]=uiputfile({'*.mat'},getString(message('images:segmenter:saveSegmentation')),'labels');


            isCanceled=isequal(file,0)||isequal(path,0);

        end




        function[path,isCanceled]=saveBlockedLabelsToFolder(self)

            close(self);

            path=uigetdir('',getString(message('images:segmenter:saveSegmentation')));

            isCanceled=isequal(path,0);

        end




        function[varname,isLogical,isCanceled]=saveLabelsToWorkspace(self,loc,saveAsLogical,eligibleToSaveAsLogical)

            close(self);

            if eligibleToSaveAsLogical&&isempty(saveAsLogical)

                dlg=images.internal.app.segmenter.volume.dialogs.VariableTypeWorkspaceDialog(loc,getString(message('images:segmenter:saveToWorkspace')));

                self.LastOpenDialog=dlg.FigureHandle;
                wait(dlg);

                isLogical=dlg.IsLogical;
                varname=dlg.VariableName;
                isCanceled=dlg.Canceled;

            else

                dlg=images.internal.app.segmenter.volume.dialogs.VariableWorkspaceDialog(loc,getString(message('images:segmenter:saveToWorkspace')));

                self.LastOpenDialog=dlg.FigureHandle;
                wait(dlg);

                if eligibleToSaveAsLogical
                    isLogical=saveAsLogical;
                else
                    isLogical=false;
                end

                varname=dlg.VariableName;
                isCanceled=dlg.Canceled;

            end

        end




        function displayShortcuts(self,loc)

            if isempty(self.ShortcutDialog)||~isvalid(self.ShortcutDialog)

                dlg=images.internal.app.segmenter.volume.dialogs.ShortcutsDialog(loc,getString(message('images:segmenter:shortcuts')));
                self.ShortcutDialog=dlg.FigureHandle;
                set(dlg.FigureHandle,'Visible','on');
                set(dlg.FigureHandle,'Tag','ShortcutsDialog')

            else
                movegui(self.ShortcutDialog,'onscreen');
                figure(self.ShortcutDialog);
            end

        end




        function[alpha,isCanceled]=displayLabelVisiblity(self,loc,labels,alpha)

            close(self);

            dlg=images.internal.app.segmenter.volume.dialogs.ShowLabelsDialog(loc,getString(message('images:segmenter:labelVisibleTitle')),labels,alpha);

            self.LastOpenDialog=dlg.FigureHandle;

            wait(dlg);

            alpha=dlg.Visibility;
            isCanceled=dlg.Canceled;

        end




        function displaySettings(self,loc,dlg)

            close(self);

            dlg.Location=loc;
            create(dlg);
            self.LastOpenDialog=dlg.FigureHandle;

        end




        function[pos1,pos2,idx1,idx2,val,isCanceled]=displayRegionSelector(self,loc,alpha,contrastLimits,rotationState,roi,val,mask)

            close(self);

            self.RegionSelector=images.internal.app.segmenter.volume.dialogs.RegionSelectorDialog(loc,alpha,contrastLimits,rotationState);
            self.LastOpenDialog=self.RegionSelector.FigureHandle;

            addlistener(self.RegionSelector,'SliceAtLocationRequested',@(src,evt)notify(self,'SliceAtLocationRequested',evt));
            addlistener(self.RegionSelector,'UpdateSummary',@(src,evt)notify(self,'UpdateDialogSummary',evt));
            addlistener(self.RegionSelector,'ThrowError',@(src,evt)cancelRegionSelector(self,evt));
            initialize(self.RegionSelector);

            if isvalid(self.RegionSelector.FigureHandle)

                if~isempty(roi)
                    setFirstRegion(self.RegionSelector,val,mask);
                end

                if isvalid(self.RegionSelector.FigureHandle)

                    wait(self.RegionSelector);

                end

            end

            isCanceled=self.RegionSelector.Canceled;

            if isCanceled

                pos1=[];
                pos2=[];
                idx1=[];
                idx2=[];
                val=[];

            else

                pos=images.internal.builtins.bwborders(double(self.RegionSelector.MaskOne),self.RegionSelector.Connectivity);
                pos1=fliplr(pos{1});
                pos=images.internal.builtins.bwborders(double(self.RegionSelector.MaskTwo),self.RegionSelector.Connectivity);
                pos2=fliplr(pos{1});
                idx1=self.RegionSelector.SliceOne;
                idx2=self.RegionSelector.SliceTwo;
                val=self.RegionSelector.Value;

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




        function[selectedBlocks,completedBlocks]=displayBlockReviewer(self,loc,bim,blabels,names,metrics,blockFileNames,alpha,cLim,useOriginalData,blockMap,r,g,b,cmap)

            close(self);

            self.ReviewResults=images.internal.app.segmenter.volume.dialogs.ReviewResultsDialog(loc,bim,blabels,names,metrics,blockFileNames,alpha,cLim,useOriginalData,blockMap,r,g,b,cmap);
            self.LastOpenDialog=self.ReviewResults.FigureHandle;

            wait(self.ReviewResults);

            if isa(blabels,'blockedImage')
                completedBlocks=false(blabels.SizeInBlocks);
            else
                completedBlocks=false;
            end

            if self.ReviewResults.Canceled
                selectedBlocks=false;
            else
                if self.ReviewResults.MarkComplete

                    indexMap=self.ReviewResults.IndexMap;
                    indexMap(~self.ReviewResults.Selected,:)=[];
                    if~isempty(indexMap)
                        for idx=1:size(indexMap,1)

                            completedBlocks(indexMap(idx,1),indexMap(idx,2),indexMap(idx,3))=true;
                        end
                    end

                end
                selectedBlocks=self.ReviewResults.Selected;
            end

            delete(self.ReviewResults);
        end




        function[V,isCanceled]=importGroundTruthData(self,loc,allowBlockedImage)

            close(self);

            if allowBlockedImage
                supportedType='blockedImage';
            else
                supportedType='labelVolume';
            end

            dlg=images.internal.app.utilities.VariableDialog(loc,getString(message('images:segmenter:importGroundTruth')),getString(message('images:segmenter:variables')),supportedType);

            self.LastOpenDialog=dlg.FigureHandle;
            wait(dlg);

            if dlg.Canceled
                V=[];
            else
                V=evalin('base',dlg.SelectedVariable);
            end

            isCanceled=dlg.Canceled;

        end

    end

    methods
        function set.LastOpenDialog(self,h)
            self.LastOpenDialog=h;
            self.LastOpenDialog.Tag="LastOpenDialog";
        end
    end

    methods(Access=private)


        function cancelRegionSelector(self,evt)

            close(self);
            notify(self,'ThrowError',evt);

        end

    end


end