classdef RenameGotoTagDialog<handle





    properties(Access=private)


        ParamSource;


        NewName;
    end

    methods
        function obj=RenameGotoTagDialog(paramSource,newName)
            obj.ParamSource=paramSource;
            obj.NewName=newName;
        end

        function dlgStruct=getDialogSchema(obj)

            oldNameString=get_param(obj.ParamSource,'GotoTag');

            rowIdx=1;

            descTxt.Name=DAStudio.message('Simulink:studio:UpdateAllBlocksGotoTag');
            descTxt.Type='text';
            descTxt.WordWrap=true;
            descTxt.RowSpan=[rowIdx,rowIdx];
            descTxt.ColSpan=[1,2];

            rowIdx=rowIdx+1;

            oldNameTitle.Name=DAStudio.message('Simulink:studio:OldName');
            oldNameTitle.Type='text';
            oldNameTitle.RowSpan=[rowIdx,rowIdx];
            oldNameTitle.ColSpan=[1,1];

            oldName.Name=oldNameString;
            oldName.Type='text';
            oldName.Tag='oldName';
            oldName.RowSpan=[rowIdx,rowIdx];
            oldName.ColSpan=[2,2];

            rowIdx=rowIdx+1;

            newNameTitle.Name=DAStudio.message('Simulink:studio:NewName');
            newNameTitle.Type='text';
            newNameTitle.RowSpan=[rowIdx,rowIdx];
            newNameTitle.ColSpan=[1,1];

            newName.Type='edit';
            newName.Value=obj.NewName;
            newName.Tag='newName';
            newName.RowSpan=[rowIdx,rowIdx];
            newName.ColSpan=[2,2];

            dlgStruct.DialogTitle=DAStudio.message('Simulink:studio:RenameAllTitle');
            dlgStruct.DialogTag=['RenameAll:',oldNameString];
            dlgStruct.Items={descTxt,oldNameTitle,oldName,...
            newNameTitle,newName};
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};
            dlgStruct.LayoutGrid=[rowIdx,2];
            dlgStruct.ColStretch=[0,1];
            dlgStruct.Sticky=true;
            dlgStruct.OpenCallback=@SLStudio.RenameGotoTagDialog.openCB;
            dlgStruct.PreApplyCallback='preApplyCB';
            dlgStruct.PreApplyArgs={'%source','%dialog'};
            dlgStruct.PreApplyArgsDT={'handle','handle'};
        end

        function[success,errMsg]=preApplyCB(obj,dialog)

            try
                newName=dialog.getWidgetValue('newName');
                SLStudio.RenameGotoTagDialog.renameGotoTag(...
                obj.ParamSource,newName);

                success=true;
                errMsg='';
            catch e
                success=false;
                errMsg=e.message;
            end

        end
    end

    methods(Static,Access=private)
        function openCB(dastudioDlg)
            dastudioDlg.setFocus('newName');
        end
    end

    methods(Static,Hidden)
        function launch(source)
            h=source.getBlock.Handle;
            newName=get_param(h,'GotoTag');
            dlg=SLStudio.RenameGotoTagDialog(source,newName);
            DAStudio.Dialog(dlg,'','DLG_STANDALONE');
        end










        function renameGotoTag(paramSource,newName)

            oldName=get_param(paramSource,'GotoTag');
            if isequal(oldName,newName)
                return;
            end

            blk=getfullname(paramSource);

            if~isvarname(newName)
                DAStudio.error('Simulink:blocks:InvGotoFromTagName',...
                blk,namelengthmax);
            end


            tagVisibility=get_param(blk,'TagVisibility');
            rootBd=bdroot(blk);
            switch tagVisibility
            case 'global'


                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    gotoBlk=find_system(rootBd,...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'MatchFilter',@Simulink.match.activeVariants,...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                else
                    gotoBlk=find_system(rootBd,...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'Variants','ActiveVariants',...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                end
            case 'local'



                parent=get_param(blk,'Parent');
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    gotoBlk=find_system(parent,...
                    'SearchDepth','1',...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'MatchFilter',@Simulink.match.activeVariants,...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                else
                    gotoBlk=find_system(parent,...
                    'SearchDepth','1',...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'Variants','ActiveVariants',...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                end
            case 'scoped'



                mdl=get_param(blk,'Parent');
                if Simulink.internal.useFindSystemVariantsMatchFilter()
                    gotoBlk=find_system(mdl,...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'MatchFilter',@Simulink.match.activeVariants,...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                else
                    gotoBlk=find_system(mdl,...
                    'LookUnderMasks','on',...
                    'FollowLinks','on',...
                    'Variants','ActiveVariants',...
                    'BlockType','Goto',...
                    'GotoTag',newName);
                end
            otherwise
                assert(false);
            end


            dirty=get_param(rootBd,'Dirty');
            cleanupDirty=onCleanup(@()set_param(rootBd,'Dirty',dirty));

            currentBlock=get_param(rootBd,'CurrentBlock');
            cleanupCurrentBlock=onCleanup(@()set_param(rootBd,'CurrentBlock',currentBlock));

            tempH=add_block(blk,blk,'MakeNameUnique','on');
            cleanupTempBlock=onCleanup(@()delete_block(tempH));

            set_param(tempH,'GotoTag',newName);
            newnameFromBlks=get_param(tempH,'FromBlocks');
            clear cleanupTempBlock;
            clear cleanupDirty;

            if~isempty(gotoBlk)||~isempty(newnameFromBlks)
                DAStudio.error('Simulink:Data:RenameAllGotoTagExists',newName);
            end

            correspondingBlks=get_param(paramSource,'FromBlocks');
            tagVBlk=get_param(paramSource,'TagVisibilityBlock');
            if~isempty(tagVBlk)
                correspondingBlks(end+1).handle=get_param(tagVBlk,'handle');
            end

            oldName=get_param(paramSource,'GotoTag');

            for i=1:length(correspondingBlks)
                blockH=correspondingBlks(i).handle;
                if Stateflow.SLUtils.isStateflowBlock(blockH)
                    Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
                    blockH,oldName,newName);
                else
                    set_param(blockH,'GotoTag',newName);
                end
            end



            set_param(paramSource,'GotoTag',newName);
            set_param(blk,'GotoTag',newName);
        end

    end

end

