function convertToInternalImages(modelName)



    blocks=Simulink.findBlocks(modelName,'MaskDisplay','image',Simulink.FindOptions('Regexp',true));
    if~isempty(blocks)


        opts=Simulink.internal.BDLoadOptions(modelName);
        r=opts.readerHandle;
        if~isempty(r)
            m=r.getMatchingPartNames('/simulink/maskimages/');
            for i=1:numel(m)
                Simulink.slx.extractFileForPart(modelName,m{i});
            end
        end


        f=get_param(modelName,'UnpackedLocation');
        f=slfullfile(f,'simulink','maskimages');
        if isempty(Simulink.loadsave.resolveFolder(f))
            mkdir(f);
        end

        for i=1:numel(blocks)
            Simulink.Mask.convertToInternalImage(blocks(i));
        end
    end

end