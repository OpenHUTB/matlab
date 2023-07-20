classdef RenameDataStoreDialog<handle





    properties(Access=private)


        ParamSource;


        NewName;
    end

    methods
        function obj=RenameDataStoreDialog(paramSource,newName)
            obj.ParamSource=paramSource;
            obj.NewName=newName;
        end

        function dlgStruct=getDialogSchema(obj)

            if(~isempty(get_param(obj.ParamSource,'CachedDataStoreName')))
                oldNameString=get_param(obj.ParamSource,'CachedDataStoreName');
            else
                oldNameString=get_param(obj.ParamSource,'DataStoreName');
            end

            rowIdx=1;

            descTxt.Name=DAStudio.message('Simulink:studio:UpdateAllBlocks');
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
            dlgStruct.OpenCallback=@SLStudio.RenameDataStoreDialog.openCB;
            dlgStruct.PreApplyCallback='preApplyCB';
            dlgStruct.PreApplyArgs={'%source','%dialog'};
            dlgStruct.PreApplyArgsDT={'handle','handle'};
        end

        function[success,errMsg]=preApplyCB(obj,dialog)

            try
                newName=dialog.getWidgetValue('newName');
                SLStudio.RenameDataStoreDialog.renameDSM(...
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
            newName=get_param(h,'DataStoreName');
            dlg=SLStudio.RenameDataStoreDialog(source,newName);
            DAStudio.Dialog(dlg,'','DLG_STANDALONE');
        end










        function renameDSM(paramSource,newName)

            if(~isempty(get_param(paramSource,'CachedDataStoreName')))
                oldName=get_param(paramSource,'CachedDataStoreName');
            else
                oldName=get_param(paramSource,'DataStoreName');
            end

            if isequal(oldName,newName)
                return;
            end

            blk=getfullname(paramSource);

            if~isvarname(newName)
                DAStudio.error('Simulink:DataStores:InvDataStoreName',...
                blk,namelengthmax);
            end


            mdl=bdroot(blk);
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                dsmBlk=find_system(mdl,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'BlockType','DataStoreMemory',...
                'DataStoreName',newName);
            else
                dsmBlk=find_system(mdl,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'Variants','ActiveVariants',...
                'BlockType','DataStoreMemory',...
                'DataStoreName',newName);
            end


            dirty=get_param(mdl,'Dirty');
            cleanupDirty=onCleanup(@()set_param(mdl,'Dirty',dirty));

            currentBlock=get_param(mdl,'CurrentBlock');
            cleanupCurrentBlock=onCleanup(@()set_param(mdl,'CurrentBlock',currentBlock));

            tempH=add_block(blk,blk,'MakeNameUnique','on');
            cleanupTempBlock=onCleanup(@()delete_block(tempH));

            set_param(tempH,'DataStoreName',newName);
            newnameRWBlks=get_param(tempH,'DSReadWriteBlocks');
            clear cleanupTempBlock;
            clear cleanupDirty;

            if~isempty(dsmBlk)||~isempty(newnameRWBlks)
                DAStudio.error('Simulink:Data:RenameAllDataStoreExists',...
                newName);
            end

            dsRWBlks=get_param(paramSource,'DSReadWriteBlocks');

            for i=1:length(dsRWBlks)
                blockH=dsRWBlks(i).handle;
                if Stateflow.SLUtils.isStateflowBlock(blockH)
                    Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
                    blockH,oldName,newName);
                else
                    set_param(blockH,'DataStoreName',newName);
                    SLStudio.RenameDataStoreDialog.renameElementExpressions(blockH,oldName,newName);
                end
            end

            cacheDSReadWriteBlocks=get_param(paramSource,'CachedDSReadWriteBlocks');
            for idx=1:length(cacheDSReadWriteBlocks)
                blockH=cacheDSReadWriteBlocks(idx).handle;
                if Stateflow.SLUtils.isStateflowBlock(blockH)
                    Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
                    blockH,oldName,newName);
                else
                    set_param(blockH,'DataStoreName',newName);
                    SLStudio.RenameDataStoreDialog.renameElementExpressions(blockH,oldName,newName);
                end
            end



            set_param(paramSource,'DataStoreName',newName);
            set_param(blk,'DataStoreName',newName);


            set_param(blk,'CachedDataStoreName','');
            set_param(blk,'CachedDSReadWriteBlocks',[]);
        end

        function renameElementExpressions(blkH,oldName,newName)



            if(isempty(get_param(blkH,'DataStoreElements')))
                return;
            end
            dataStoreElements=strsplit(get_param(blkH,'DataStoreElements'),'#');
            for idx=1:length(dataStoreElements)
                dsmName=regexp(dataStoreElements{idx},'\w+','match');
                if(isequal(dsmName{1},oldName))
                    dataStoreElements{idx}=regexprep(dataStoreElements{idx},oldName,newName,'once');
                end
            end
            set_param(blkH,'DataStoreElements',strjoin(dataStoreElements,'#'));
        end

    end

end

