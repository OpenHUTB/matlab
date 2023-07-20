function maskImagePath(obj)











    if~obj.ver.isSLX||isR2019aOrEarlier(obj.ver)
        blocks=Simulink.findBlocks(obj.modelName,'MaskDisplay','image',...
        Simulink.FindOptions('Regexp',true));
        for i=1:numel(blocks)
            Simulink.Mask.convertToExternalImage(blocks(i));
        end
    end

    if isR2012bOrEarlier(obj.ver)


        masks=obj.findBlocks('Mask','on');

        for i=1:length(masks)
            linkStatus=get_param(masks{i},'LinkStatus');
            if isequal(linkStatus,'resolved')
                continue;
            end

            originalMaskDisplayString=get_param(masks{i},'MaskDisplay');








            maskDisplayStringWithIMREAD=regexprep(originalMaskDisplayString,'((^|\s|;)image\s*\(\s*)''([^'']*)''([^\)]*\))','$1imread(''$2'')$3');
            maskDisplayStringWithIMREAD=regexprep(maskDisplayStringWithIMREAD,'((^|\s|;)image)[\t ]+''([^%;]+)''[ \t]*($|\n|;)','$1(imread(''$2''))$3');
            maskDisplayStringWithIMREAD=regexprep(maskDisplayStringWithIMREAD,'((^|\s|;)image)[ \t]+([^''%;\(\)\t\n ]+[^%\n;]*)($|\n|;|%)','$1(imread(''$2''))$3');

            if~strcmp(originalMaskDisplayString,maskDisplayStringWithIMREAD)
                set_param(masks{i},'MaskDisplay',maskDisplayStringWithIMREAD);
            end
        end
    end

end
