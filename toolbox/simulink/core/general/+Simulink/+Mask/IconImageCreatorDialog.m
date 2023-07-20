




classdef(Hidden=true)IconImageCreatorDialog<handle
    properties(Hidden)
        BlockHandle;
        ImageFile='';
        BasePath='';
        ApplyFcn;
    end
    properties(Access=private)
        m_blockDeleteListener;
    end
    methods
        function obj=IconImageCreatorDialog(blockHandle)



            if nargin>0
                obj.BlockHandle=blockHandle;
            end
        end

        function b=isInternalImagePath(~,imagePath)
            b=strncmp(imagePath,'slx:',4);
        end





        function b=isSuitableForInternalImage(obj)
            if isempty(obj.BlockHandle)
                b=false;
                return;
            end
            r=bdroot(obj.BlockHandle);
            if isempty(r)
                b=false;
                return;
            end
            f=get_param(r,'FileName');
            if isempty(f)
                b=true;
                return;
            end
            [~,~,ext]=slfileparts(f);
            if strcmp(ext,'.slx')
                b=true;
                return;
            end
            b=false;
        end

        function imagePath=optimizeImagePath(obj,imagePath)
            if~obj.isInternalImagePath(imagePath)
                [~,s,e]=slfileparts(imagePath);
                if~isempty(which([s,e]))


                    imagePath=[s,e];
                end
            end
        end

        function[imagePath,hasDisplayString,maskIconTransparency]=getCurrentImageFile(obj)
            hasDisplayString=false;
            maskIconTransparency=0;
            imagePath='';
            [maskObj,canApplyNewMask]=Simulink.Mask.get(obj.BlockHandle);
            if~canApplyNewMask
                imagePath=maskObj.ImageFile;
                maskDisplayString=maskObj.Display;
                maskIconTransparency=maskObj.IconOpaque;
                if~isempty(maskDisplayString)
                    hasDisplayString=true;
                    if isempty(imagePath)
                        maskDisplayString=obj.decodeFileName(maskDisplayString);
                        splittedDisplayString=strsplit(maskDisplayString,'''');
                        imageName=strjoin(splittedDisplayString(2:length(splittedDisplayString)-1),'''');
                        imagePath=which(imageName);
                        if isempty(imagePath)
                            if(exist(imageName,'file')==2)
                                imagePath=imageName;
                            end
                        end
                    end
                end
            end
            imagePath=obj.optimizeImagePath(imagePath);
        end

        function dlgStruct=getDialogSchema(obj)
            hasBlockHandle=~isempty(obj.BlockHandle);
            lblDescription.Type='text';
            if hasBlockHandle
                lblDescription.Name=DAStudio.message('Simulink:Masking:IconImageDialogLblDescription');
            else
                lblDescription.Name=DAStudio.message('SystemBlock:MATLABSystem:SpecifyImageIconFile');
            end
            lblDescription.RowSpan=[1,1];
            lblDescription.ColSpan=[1,1];
            lblDescription.WordWrap=true;

            editIconImagePath.Type='edit';
            if hasBlockHandle

                [imagePath,hasDisplayString,maskIconTransparency]=obj.getCurrentImageFile;
            else
                imagePath=[];
            end
            if isempty(imagePath)
                imagePath=DAStudio.message('Simulink:Masking:IconSelectionNone');
            end
            editIconImagePath.Value=imagePath;
            editIconImagePath.Enabled=false;
            editIconImagePath.RowSpan=[2,2];
            editIconImagePath.ColSpan=[1,4];
            editIconImagePath.Tag='IconImagePath';

            iconImagePathBrowse.Type='pushbutton';
            iconImagePathBrowse.Name=DAStudio.message('Simulink:Masking:BrowseButton');
            iconImagePathBrowse.RowSpan=[2,2];
            iconImagePathBrowse.ColSpan=[5,5];
            iconImagePathBrowse.Source=obj;
            iconImagePathBrowse.ObjectMethod='browseImageLocation';
            iconImagePathBrowse.MethodArgs={'%dialog'};
            iconImagePathBrowse.ArgDataTypes={'handle'};

            iconImagePathClear.Type='pushbutton';
            iconImagePathClear.Name=DAStudio.message('Simulink:Masking:IconSelectionClear');
            iconImagePathClear.RowSpan=[2,2];
            iconImagePathClear.ColSpan=[6,6];
            iconImagePathClear.ObjectMethod='clearImageLocation';
            iconImagePathClear.MethodArgs={'%dialog'};
            iconImagePathClear.ArgDataTypes={'handle'};

            pnlIconImage.Type='panel';
            pnlIconImage.LayoutGrid=[1,6];
            items={editIconImagePath,iconImagePathBrowse,iconImagePathClear};
            pnlIconImage.ColStretch=[0,0,0,0,0,0];
            pnlIconImage.Items=items;

            if hasBlockHandle



                btnInternalImage.Type='checkbox';
                btnInternalImage.Name=DAStudio.message('Simulink:Masking:IconImageDialogStoreCopy');
                btnInternalImage.RowSpan=[2,2];
                btnInternalImage.ColSpan=[1,4];
                btnInternalImage.Value=obj.isInternalImagePath(imagePath);
                btnInternalImage.Tag='UseInternalImage';
                btnInternalImage.Enabled=obj.isSuitableForInternalImage;


                dropdownEntries=[{DAStudio.message('Simulink:Masking:IconTransparencyOpaque')};...
                {DAStudio.message('Simulink:Masking:IconTransparencyTransparent')}];
                if strcmp(get_param(obj.BlockHandle,'BlockType'),'SubSystem')
                    dropdownEntries{end+1}=DAStudio.message('Simulink:Masking:IconTransparencyOpaqueWithPorts');
                end
                dropdownContents.Type='combobox';
                dropdownContents.Entries=dropdownEntries;
                dropdownContents.RowSpan=[4,4];
                dropdownContents.ColSpan=[1,3];
                dropdownContents.Mode=1;
                dropdownContents.Graphical=1;
                dropdownContents.Name=['         ',DAStudio.message('Simulink:Masking:IconTransparencyCombobox')];
                dropdownContents.Tag='IconTransparencyContents';

                switch(maskIconTransparency)
                case 'transparent'
                    dropdownContents.Value=1;
                case 'opaque-with-ports'
                    dropdownContents.Value=2;
                otherwise
                    dropdownContents.Value=0;
                end

            end

            btnApply.Type='pushbutton';
            btnApply.RowSpan=[1,1];
            btnApply.ColSpan=[3,3];
            btnApply.Mode=1;
            btnApply.Name=DAStudio.message('Simulink:Masking:IconImageDialogOKButton');
            btnApply.Source=obj;
            btnApply.ObjectMethod='apply';
            btnApply.MethodArgs={'%dialog'};
            btnApply.ArgDataTypes={'handle'};
            btnApply.Tag='IconImageApply';

            btnCancel.Type='pushbutton';
            btnCancel.Mode=1;
            btnCancel.Name=DAStudio.message('Simulink:Masking:IconImageDialogCancelButton');
            btnCancel.RowSpan=[1,1];
            btnCancel.ColSpan=[4,4];
            btnCancel.Source=obj;
            btnCancel.ObjectMethod='cancel';
            btnCancel.MethodArgs={'%dialog'};
            btnCancel.ArgDataTypes={'handle'};
            btnCancel.Tag='IconImageCancel';

            btnHelp.Type='pushbutton';
            btnHelp.Mode=1;
            btnHelp.Graphical=1;
            btnHelp.Name=DAStudio.message('Simulink:Masking:IconImageDialogHelpButton');
            btnHelp.RowSpan=[1,1];
            btnHelp.ColSpan=[5,5];
            btnHelp.Source=obj;
            if hasBlockHandle
                btnHelp.ObjectMethod='help';
            else
                btnHelp.ObjectMethod='helpSystemObject';
            end
            btnHelp.Tag='IconImageHelp';

            pnlButton.Type='panel';
            pnlButton.LayoutGrid=[1,5];
            pnlButton.ColStretch=[0,0,0,0,0];
            pnlButton.Items={btnApply,btnHelp,btnCancel};

            if hasBlockHandle
                if hasDisplayString
                    dlgStruct.DialogTitle=DAStudio.message('Simulink:Masking:EditIconImageDialogTitle');
                else
                    dlgStruct.DialogTitle=DAStudio.message('Simulink:Masking:AddIconImageDialogTitle');
                end
            else
                dlgStruct.DialogTitle=DAStudio.message('SystemBlock:MATLABSystem:SpecifyImageIcon');
            end

            dlgStruct.DialogTag='IconImageDialog';
            dlgStruct.StandaloneButtonSet=pnlButton;
            dlgStruct.IsScrollable=true;
            if hasBlockHandle
                dlgStruct.Items={lblDescription,pnlIconImage,dropdownContents,btnInternalImage};
            else
                dlgStruct.Items={lblDescription,pnlIconImage};
            end
        end

        function clearImageLocation(~,dlg)
            dlg.setWidgetValue('IconImagePath',DAStudio.message('Simulink:Masking:IconSelectionNone'));
        end

        function browseImageLocation(obj,dlg)
            currentImagePath=dlg.getWidgetValue('IconImagePath');
            if obj.isInternalImagePath(currentImagePath)
                currentImagePath=pwd;
            end

            hasBlockHandle=~isempty(obj.BlockHandle);
            ext='*.png;*.jpg;*.jpeg;*.gif;*.svg';
            ext_cs='*.png,*.jpg,*.jpeg,*.gif,*.svg';
            if hasBlockHandle
                browserTitle=DAStudio.message('Simulink:Masking:IconImagePath');
            else
                browserTitle=DAStudio.message('SystemBlock:MATLABSystem:BrowseImageIcon');

                ext=strcat(ext,';*.dvg');
                ext_cs=strcat(ext_cs,',*.dvg');
            end
            [aFileName,aPathName]=uigetfile({ext,...
            ['All Image Files (',ext_cs,')'];'*.*','All Files (*.*)'},...
            browserTitle,currentImagePath);

            if~isempty(aFileName)
                dlg.setWidgetValue('IconImagePath',[aPathName,aFileName]);
            end
        end

        function apply(obj,dlg)
            currentImagePath=dlg.getWidgetValue('IconImagePath');
            if strcmp(currentImagePath,DAStudio.message('Simulink:Masking:IconSelectionNone'))





                if~isempty(obj.BlockHandle)

                    set_param(obj.BlockHandle,'MaskDisplay','');
                end

                delete(obj);
                return;
            else
                [pathName,fileName,ext]=fileparts(currentImagePath);
                if~obj.isInternalImagePath(currentImagePath)
                    if exist(currentImagePath,'file')~=2

                        dp=DAStudio.DialogProvider;
                        dp.errordlg(DAStudio.message('Simulink:Masking:IconImageInvalid'),...
                        DAStudio.message('Simulink:Masking:IconImageFileErrorDialogTitle'),true);
                        return;
                    end
                end
            end

            if~isempty(obj.BlockHandle)

                [modelPathName,~,~]=fileparts(get_param(bdroot(obj.BlockHandle),'filename'));
                [maskObj,canApplyNewMask]=Simulink.Mask.get(obj.BlockHandle);
                if canApplyNewMask
                    maskObj=Simulink.Mask.create(obj.BlockHandle);
                end

                if contains(path,pathName)||strcmp(modelPathName,pathName)
                    fileNameToUse=[fileName,ext];
                else
                    fileNameToUse=currentImagePath;
                end

                command=['image(''',obj.encodeFileName(fileNameToUse),'''); % '...
                ,DAStudio.message('Simulink:Masking:InternalMaskImageComment')];


                aInterceptor=Simulink.output.StorageInterceptorCb();
                aProcessor=Simulink.output.registerProcessor(aInterceptor);%#ok<NASGU>

                oldDisplayCommand=maskObj.Display;
                maskObj.Display=command;
                aLastMessage=aInterceptor.lastInterceptedMsg();
                if~isempty(aLastMessage)
                    if canApplyNewMask
                        maskObj.delete;
                    else
                        maskObj.Display=oldDisplayCommand;
                    end
                    dp=DAStudio.DialogProvider;
                    dp.errordlg(slprivate('removeHyperLinksFromMessage',aLastMessage.Message),...
                    DAStudio.message('Simulink:Masking:IconImageFileErrorDialogTitle'),true);
                    return;
                end

                currentIconTransparency=dlg.getWidgetValue('IconTransparencyContents');
                switch currentIconTransparency
                case 0
                    maskObj.IconOpaque='opaque';
                case 1
                    maskObj.IconOpaque='transparent';
                otherwise
                    maskObj.IconOpaque='opaque-with-ports';
                end

                useInternalImage=dlg.getWidgetValue('UseInternalImage');
                if useInternalImage
                    Simulink.Mask.convertToInternalImage(obj.BlockHandle);
                else
                    Simulink.Mask.convertToExternalImage(obj.BlockHandle);
                end

            else



                if~isempty(which([fileName,ext]))
                    obj.ImageFile=[fileName,ext];
                elseif~isempty(obj.BasePath)&&strcmp(currentImagePath,fullfile(obj.BasePath,[fileName,ext]))
                    obj.ImageFile=[fileName,ext];
                else
                    obj.ImageFile=currentImagePath;
                end
            end

            if~isempty(obj.ApplyFcn)
                obj.ApplyFcn(obj);
            end

            delete(dlg);
        end

        function cancel(~,dlg)
            delete(dlg);
        end


        function aEncodedFileName=encodeFileName(~,aFileName)
            aEncodedFileName=strrep(aFileName,'''','''''');
        end

        function aDecodeFileName=decodeFileName(~,aFileName)
            aDecodeFileName=strrep(aFileName,'''''','''');
        end

        function help(~)
            helpview([docroot,'/mapfiles/simulink.map'],'icon_ports');
        end

        function helpSystemObject(~)
            helpview(fullfile(docroot,'simulink','helptargets.map'),'matlab_system_icon_ports');
        end

        function showDialog(obj)

            dlg=[];
            dlgs=DAStudio.ToolRoot.getOpenDialogs.find('DialogTag','IconImageDialog');
            for i=1:length(dlgs)
                currentDlg=dlgs(i);
                if isequal(obj.BlockHandle,currentDlg.getDialogSource.BlockHandle)
                    dlg=currentDlg;
                    break;
                end
            end



            if isempty(dlg)
                dlg=DAStudio.Dialog(obj);
                dlg.show;
                obj.m_blockDeleteListener=Simulink.listener(obj.BlockHandle,...
                'ObjectBeingDestroyed',@(src,ev)Simulink.Mask.IconImageCreatorDialog.removeDlg(src,ev,dlg));
            end
        end
    end

    methods(Static=true,Hidden=true)
        function removeDlg(~,~,dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end
    end
end
