function applyInlineTransforms(obj,hasMdlRef,sliceXfrmr,replaceModelBlockH,sliceMdl,hdls,origSys,sliceRootSys)




    import Transform.*;
    if(hasMdlRef&&obj.options.InlineOptions.ModelBlocks)

        origMdlH=get_param(obj.model,'Handle');

        blockRepObj=Sldv.xform.BlkReplacer.getInstance(true,false);


        cachedProps.StandAloneMode=blockRepObj.StandAloneMode;
        cachedProps.MdlInlinerOnlyMode=blockRepObj.MdlInlinerOnlyMode;
        cachedProps.InlinerOrigMdlH=blockRepObj.InlinerOrigMdlH;
        cachedProps.NotifyMdlInlineFcn=blockRepObj.NotifyMdlInlineFcn;
        cachedProps.NotifyData=blockRepObj.NotifyData;
        cachedProps.PathTranslationInfo=blockRepObj.PathTranslationInfo;

        try
            blockRepObj.StandAloneMode=true;
            blockRepObj.MdlInlinerOnlyMode=true;

            if obj.isSubsystemSlice
                if~Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
                    blockRepObj.InlinerOrigMdlH=get_param(bdroot(origSys),'Handle');
                else
                    blockRepObj.InlinerOrigMdlH=get_param(...
                    get_param(obj.sliceSubSystemH,'modelname'),'handle');
                end
            else
                blockRepObj.InlinerOrigMdlH=origMdlH;
            end
            blockRepObj.NotifyMdlInlineFcn=@ModelSlicer.notifyModelInlined;
            blockRepObj.NotifyData={sliceXfrmr.sliceMapper,obj.refMdlToMdlBlk};

            pathXlate.replacableModelBlockH=replaceModelBlockH;
            pathXlate.origSubPath=[];
            pathXlate.replaceSubPath=[];
            if obj.isSubsystemSlice
                if~Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
                    [~,origSubPath]=strtok(getfullname(get_param(obj.sliceSubSystemH,'Parent')),'/');
                    pathXlate.origSubPath=origSubPath;
                    pathXlate.replaceSubPath=sliceRootSys;
                else
                    pathXlate.replaceSubPath=[sliceRootSys,'/',get_param(obj.sliceSubSystemH,'Name')];
                end


            end
            blockRepObj.PathTranslationInfo=pathXlate;
            sliceMdlH=get_param(sliceMdl,'Handle');
            [status,~,msg]=blockRepObj.executeReplacements(sliceMdlH,[],false);%#ok<ASGLU>
        catch Mx
        end


        blockRepObj.StandAloneMode=cachedProps.StandAloneMode;
        blockRepObj.MdlInlinerOnlyMode=cachedProps.MdlInlinerOnlyMode;
        blockRepObj.InlinerOrigMdlH=cachedProps.InlinerOrigMdlH;
        blockRepObj.NotifyMdlInlineFcn=cachedProps.NotifyMdlInlineFcn;
        blockRepObj.NotifyData=cachedProps.NotifyData;
        blockRepObj.PathTranslationInfo=cachedProps.PathTranslationInfo;
    end

    if obj.options.InlineOptions.SubsystemReferences
        slInternal('convertAllSSRefBlocksToSubsystemBlocks',...
        get_param(sliceMdl,'handle'));
    end

    if obj.options.InlineOptions.Libraries
        breakLibraryLinks(sliceMdl);
    end

    obj.inlineVariantsTransforms(hasMdlRef,sliceXfrmr,replaceModelBlockH,hdls,origSys,sliceRootSys);


end
