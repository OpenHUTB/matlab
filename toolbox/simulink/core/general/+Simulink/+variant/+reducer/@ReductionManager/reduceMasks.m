



function err=reduceMasks(optArgs)
    err=[];


    for mdlId=1:numel(optArgs.ModelRefModelInfoStructsVec)

        err=i_deletePromotedParams(optArgs,mdlId,false);
        if~isempty(err)
            return;
        end
    end



    for libId=1:numel(optArgs.LibInfoStructsVec)

        err=i_deletePromotedParams(optArgs,libId,true);
        if~isempty(err)
            return;
        end
    end
end


function err=i_deletePromotedParams(optArgs,bdIdx,isLibForMask)
    err=[];

    if isLibForMask
        bdInfoStruct=optArgs.LibInfoStructsVec(bdIdx);
    else
        bdInfoStruct=optArgs.ModelRefModelInfoStructsVec(bdIdx);
    end

    blksSVCEMap=bdInfoStruct.BlksSVCEMap;


    allBlksinCurrbd=blksSVCEMap.keys;
    activeBlocksInCurrbd=allBlksinCurrbd(Simulink.variant.utils.i_cell2mat(blksSVCEMap.values)>0);
    maskedBlocks=activeBlocksInCurrbd(strcmp(get_param(activeBlocksInCurrbd,'Mask'),'on'));

    variantRelevantParams=Simulink.variant.reducer.utils.getVariantSubsysRelevantParams();

    if isLibForMask



        maskedBlocks=setdiff(maskedBlocks,bdInfoStruct.HierBlksNotUsed);
    end

    for mskId=1:numel(maskedBlocks)

        maskBlkHandle=get_param(maskedBlocks{mskId},'Handle');
        if any(maskBlkHandle==optArgs.BlocksInserted)
            continue;
        end


        libinfo=Simulink.variant.reducer.utils.getLibInfo(maskedBlocks(mskId));


        if~isempty(libinfo)






            [~,isLibSlxUnderML]=arrayfun(@(x)Simulink.loadsave.resolveFile(x.Library,'slx'),libinfo,'UniformOutput',false);
            [~,isLibMdlUnderML]=arrayfun(@(x)Simulink.loadsave.resolveFile(x.Library,'mdl'),libinfo,'UniformOutput',false);
            isUnderMlrootslx=any(Simulink.variant.utils.i_cell2mat(isLibSlxUnderML));
            isUnderMlrootmdl=any(Simulink.variant.utils.i_cell2mat(isLibMdlUnderML));
            isUnderMlRoot=isUnderMlrootslx||isUnderMlrootmdl;
            if isUnderMlRoot,continue;end



            if~isLibForMask,continue;end

        end

        maskObj=Simulink.Mask.get(maskedBlocks{mskId});

        params=maskObj.Parameters;
        toRemoveParam={};
        for prmId=1:numel(params)
            if~strcmp(params(prmId).Type,'promote')
                continue;
            end





            allblks=params(prmId).TypeOptions;

            isDeleted=true;
            for blkId=1:numel(allblks)
                blkStr=allblks{blkId};

                blkName=ii_getParentBlockFromPath(blkStr);
                if~isempty(blkName)
                    blkPath=i_replaceCarriageReturnWithSpace([maskedBlocks{mskId},'/',blkName]);
                else
                    blkPath=i_replaceCarriageReturnWithSpace(maskedBlocks{mskId});
                end







                if~isKey(blksSVCEMap,blkPath)
                    isDeleted=false;
                    continue;
                end

                isBlkRemoved=(blksSVCEMap(blkPath)==0);






                isNonVariantSubsysWithVariantRelevantParams=false;
                if~isBlkRemoved
                    if contains(params(prmId).TypeOptions,variantRelevantParams)

                        if strcmp(get_param(blkPath,'BlockType'),'SubSystem')

                            isNonVariantSubsysWithVariantRelevantParams=...
                            strcmp(get_param(blkPath,'Variant'),'off');
                        end
                    end
                end



                isDeleted=(isBlkRemoved||isNonVariantSubsysWithVariantRelevantParams)...
                &&isDeleted;

                if~isDeleted
                    break;
                end
            end

            if isDeleted




                toRemoveParam{end+1}=params(prmId).Name;%#ok<AGROW>
            end
        end

        if isLibForMask
            Simulink.variant.reducer.utils.assert(isKey(optArgs.LibBlkToModelInstanceMap,maskedBlocks{mskId}));




            blockToSearchForVars=optArgs.LibBlkToModelInstanceMap(maskedBlocks{mskId});
        else

            blockToSearchForVars=maskedBlocks{mskId};
        end




        try


            if optArgs.IsVariableDependencyAnalysisSuccess

                depVariables=Simulink.findVars(blockToSearchForVars,'SearchMethod','cached');
            else
                depVariables=Simulink.findVars(blockToSearchForVars);
            end
        catch






            continue;
        end


        if~isempty(depVariables)


            toRemoveParam=setdiff(toRemoveParam,{depVariables.Name});
        end


        for prmToRmId=1:numel(toRemoveParam)
            maskObj.removeParameter(toRemoveParam{prmToRmId});
        end

        maskedBlk.BlockPath=maskedBlocks{mskId};
        maskedBlk.DeletedParams=toRemoveParam;
        optArgs.ReportDataObj.addModifiedMaskedBlock(maskedBlk);
    end


    function parentBlk=ii_getParentBlockFromPath(blkPath)
        ind=find(blkPath=='/',1,'last');

        if isempty(ind)||(ind<=1)
            parentBlk='';
        else
            parentBlk=blkPath(1:ind-1);
        end
    end

end


