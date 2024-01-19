classdef DialogSchema

    methods(Static)
        function pGroup=getSystemWidget(hDlgSource,systemTag,systemVal,systemID)
            hBlock=get(hDlgSource.getBlock,'Handle');
            pGroup=getSystemWidgetPanel(hBlock,systemTag,systemVal,systemID);

            pGroup.RowSpan=[1,1];
            pGroup.ColSpan=[1,1];
        end


        function s=getSpecifySystemObject(obj)

            isDesSystem=false;
            hBlock=obj.Platform.BlockHandle;
            bType=get_param(hBlock,'BlockType');
            if strcmp(bType,'MATLABDiscreteEventSystem')
                isDesSystem=true;
            end

            if isDesSystem
                dscptID='SystemBlock:MATLABSystem:SL_DSCPT_MATLAB_DES_SYSTEM';
                grpName='MATLAB Discrete-Event System';
            else
                dscptID='SystemBlock:MATLABSystem:SL_DSCPT_MATLAB_SYSTEM';
                grpName='MATLAB System';
            end
            hText=struct('Type','text','WordWrap',true,...
            'Name',getString(message(dscptID)));
            hGroup=struct('Type','group','Name',grpName,...
            'Tag','MATLABSystemBlock_Description');
            hGroup.Items={hText};
            systemVal=get_param(hBlock,'System');
            pGroup=getSystemWidgetPanel(hBlock,'System',systemVal);
            pGroup.Type='group';

            if isDesSystem
                dialogTag='MATLABDiscreteEventSystemBlock_SpecifySystemObject';
            else
                dialogTag='MATLABSystemBlock_SpecifySystemObject';
            end
            s.DialogTitle=getString(message('SystemBlock:MATLABSystem:MatlabSystemBlockTitle'));
            s.DialogTag=dialogTag;
            s.HelpMethod='slhelp';
            s.HelpArgs={hBlock,'parameter'};
            s.Items={hGroup,pGroup};
            s.LayoutGrid=[length(s.Items)+1,3];
            s.RowStretch=[zeros(1,length(s.Items)),1];
            s.OpenCallback=@onOpenSpecifySystemObjectDialog;
        end


        function onBrowseSystem(hBlock,dlg,systemEditTag,isImmediateApplyMode)
            [fileName,pathName]=uigetfile({'*.m;*.p;*.mlx',...
            message('SystemBlock:MATLABSystem:SystemBlockDialogBrowseDialogFilter').getString},...
            message('SystemBlock:MATLABSystem:SystemBlockDialogBrowseDialogTitle').getString);

            if(fileName==0)
                return;
            end
            fullFileName=fullfile(pathName,fileName);
            systemName=matlab.system.editor.internal.getClassNameFromFile(fullFileName);
            if isempty(which(fullFileName))
                if~openOffPathDialog(pathName,fileName)
                    return;
                end
            end
            if~strcmp(which(fullFileName),which(systemName))
                error(message('SystemBlock:MATLABSystem:SystemBlockDialogSelectedFilePrecedence',fullFileName));
            end
            if~matlab.system.display.isSystem(systemName)
                error(message('SystemBlock:MATLABSystem:SystemBlockDialogSelectedFileInvalid',systemName));
            end

            if isImmediateApplyMode
                set_param(hBlock,'System',systemName);
            else
                dlg.setWidgetValue(systemEditTag,systemName);
            end
        end


        function onNewSystem(hBlock,dlg,actionTag,systemEditTag,isImmediateApplyMode)
            filePathChangeFcn=getFilePathChangeFcn(hBlock,dlg,systemEditTag,isImmediateApplyMode);
            switch(actionTag)
            case 'Basic'
                matlab.system.editor.internal.NewDocumentTemplate.createBasic('FilePathChangeFcn',filePathChangeFcn);
            case 'Advanced'
                matlab.system.editor.internal.NewDocumentTemplate.createAdvanced('FilePathChangeFcn',filePathChangeFcn);
            case 'Simulink'
                matlab.system.editor.internal.NewDocumentTemplate.createSimulinkExtension('FilePathChangeFcn',filePathChangeFcn);
            case 'BasicDes'
                matlab.system.editor.internal.NewDocumentTemplate.createBasicDiscreteEventSystem('FilePathChangeFcn',filePathChangeFcn);
            end
        end
    end
end


function pGroup=getSystemWidgetPanel(hBlock,systemTag,systemVal,systemID)

    isImmediateApplyMode=(nargin>3);

    isDesSystem=false;
    if strcmp(get_param(hBlock,'BlockType'),'MATLABDiscreteEventSystem')
        isDesSystem=true;
    end

    if isDesSystem
        promptId='SystemBlock:MATLABSystem:DiscreteEventSystemObjectName';
    else
        promptId='SystemBlock:MATLABSystem:SystemObjectName';
    end

    nameP.Type='text';
    nameP.Name=getString(message(promptId));
    nameP.Tag=[systemTag,'label'];
    nameP.RowSpan=[1,1];
    nameP.ColSpan=[1,1];
    nameP.Buddy=systemTag;
    nameP.Elide=1;

    nameW.Type='combobox';
    nameW.Name='';
    nameW.Tag=systemTag;
    if isImmediateApplyMode
        nameW.ObjectMethod='handleEditEvent';
        nameW.MethodArgs={'%value',systemID,'%dialog'};
        nameW.ArgDataTypes={'mxArray','int32','handle'};
    else
        nameW.ObjectProperty='System';
    end
    nameW.Editable=true;
    nameW.Value=getSystemObjectName(systemVal);
    nameW.Entries=matlab.system.ui.findSystemObjects(pwd,isDesSystem);
    nameW.PreferredSize=[140,-1];
    nameW.ColSpan=[2,2];
    nameW.RowSpan=[1,1];
    nameW.Enabled=~(Simulink.harness.internal.isHarnessCUT(hBlock)&&~Simulink.harness.internal.isActiveHarnessCUTPropEditable(hBlock));

    if isDesSystem
        toolTipId='SystemBlock:MATLABSystem:DiscreteEventSystemBlockDialogBrowseTooltip';
    else
        toolTipId='SystemBlock:MATLABSystem:SystemBlockDialogBrowseTooltip';
    end
    browseW=struct('Type','pushbutton');
    browseW.Tag='SystemObjectBrowseButton';
    browseW.MatlabMethod='matlab.system.ui.DialogSchema.onBrowseSystem';
    browseW.MatlabArgs={hBlock,'%dialog',nameW.Tag,isImmediateApplyMode};
    browseW.FilePath=fullfile(matlabroot,'toolbox','shared','system','simulink','resources','Open_16.png');
    browseW.ToolTip=message(toolTipId).getString;
    browseW.ColSpan=[3,3];
    browseW.RowSpan=[1,1];
    browseW.MaximumSize=[20,-1];
    browseW.Enabled=~(Simulink.harness.internal.isHarnessCUT(hBlock)&&~Simulink.harness.internal.isActiveHarnessCUTPropEditable(hBlock));

    newW=struct('Type','splitbutton');
    newW.FilePath=fullfile(matlabroot,'toolbox','shared','system','simulink','resources','New_16.png');
    newW.Name=message('SystemBlock:MATLABSystem:SystemBlockDialogNewLabel').getString;
    newW.Tag='SystemObjectNewButton';
    if isDesSystem
        toolTipId='SystemBlock:MATLABSystem:DiscreteEventSystemBlockDialogNewTooltip';
        newW.ActionEntries={...
        matlab.system.ui.NewSystemObjectAction(message('SystemBlock:MATLABSystem:SystemBlockDialogBasicLabel').getString,'BasicDes')};
        newW.DefaultAction='BasicDes';
    else
        toolTipId='SystemBlock:MATLABSystem:SystemBlockDialogNewTooltip';
        newW.ActionEntries={...
        matlab.system.ui.NewSystemObjectAction(message('SystemBlock:MATLABSystem:SystemBlockDialogBasicLabel').getString,'Basic'),...
        matlab.system.ui.NewSystemObjectAction(message('SystemBlock:MATLABSystem:SystemBlockDialogAdvancedLabel').getString,'Advanced'),...
        matlab.system.ui.NewSystemObjectAction(message('SystemBlock:MATLABSystem:SystemBlockDialogSimulinkExtensionLabel').getString,'Simulink')};
        newW.DefaultAction='Basic';
    end
    newW.UseButtonStyleForDefaultAction=true;
    newW.ActionCallback=@(dlg,tag,actionTag)matlab.system.ui.DialogSchema.onNewSystem(hBlock,dlg,actionTag,nameW.Tag,isImmediateApplyMode);
    newW.ToolTip=message(toolTipId).getString;
    newW.ColSpan=[2,3];
    newW.RowSpan=[2,2];
    isLockedModel=strcmp(get(bdroot(hBlock),'lock'),'on');
    linkStatus=get_param(hBlock,'StaticLinkStatus');
    if isLockedModel||strcmp(linkStatus,'resolved')||strcmp(linkStatus,'implicit')
        nameW.Enabled=false;
        browseW.Enabled=false;
        newW.Enabled=false;
    end

    pGroup=struct('Type','panel');
    pGroup.Name='';
    pGroup.Tag=[systemTag,'|SystemPanel'];
    pGroup.Items={nameP,nameW,browseW,newW};
    pGroup.LayoutGrid=[2,3];
    pGroup.ColStretch=[1,1,1];
end


function name=getSystemObjectName(name)

    if strcmp(name,'<Enter System Class Name>')||strcmp(name,'MATLAB_System')
        name='';
    end
end


function isSuccess=openOffPathDialog(pathName,fileName)

    isSuccess=false;
    questDlgMsg=message('SystemBlock:MATLABSystem:SystemBlockDialogSelectedFileNotOnPathQString',...
    fullfile(pathName,fileName)).getString;
    questDlgTitle=message('SystemBlock:MATLABSystem:SystemBlockDialogPathDialogTitle').getString;
    addPathMsg=message('SystemBlock:MATLABSystem:SystemBlockDialogBrowseAddPathLabel').getString;
    cancelMsg=message('SystemBlock:MATLABSystem:SystemBlockDialogBrowseCancelLabel').getString;
    choice=questdlg(questDlgMsg,questDlgTitle,addPathMsg,cancelMsg,cancelMsg);

    if strcmp(choice,addPathMsg)
        addpath(pathName);
        isSuccess=true;
    end
end


function fcn=getFilePathChangeFcn(hBlock,dlg,systemTag,isImmediateApplyMode)
    fcn=@(filePath)onFilePathChanged(filePath,hBlock,dlg,systemTag,isImmediateApplyMode);
end


function onFilePathChanged(filePath,hBlock,dlg,systemTag,isImmediateApplyMode)

    if ishandle(dlg)
        sysobjName=matlab.system.editor.internal.getClassNameFromFile(filePath);
        if isImmediateApplyMode
            sysobjPath=which(sysobjName);
            if isempty(sysobjPath)||~exist(sysobjPath,'file')
                fschange(fileparts(filePath));
                sysobjPath=which(sysobjName);
            end
            if~strcmp(which(filePath),sysobjPath)
                return;
            end

            try
                set_param(hBlock,'System',sysobjName);
            catch

                return;
            end
        else
            dlg.setWidgetValue(systemTag,sysobjName);
        end
    else
        matlab.system.editor.internal.DocumentAction.setFilePathChangeFcn(filePath,[]);
    end
end


function onOpenSpecifySystemObjectDialog(dlg)
    dlg.setFocus('System');
end

