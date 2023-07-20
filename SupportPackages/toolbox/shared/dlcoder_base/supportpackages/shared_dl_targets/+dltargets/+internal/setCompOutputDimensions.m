function setCompOutputDimensions(layerOutputSizes,layerOutputFormats,comp)












    for jOut=1:numel(layerOutputSizes)
        outSize=layerOutputSizes{jOut};
        outFormat=layerOutputFormats{jOut};





        if count(outFormat,"S")==2

            assert(numel(outSize)>=3);

            comp.setOpHeight(outSize(1),jOut-1);
            comp.setOpWidth(outSize(2),jOut-1);
            comp.setOpNumChannels(outSize(3),jOut-1);

        elseif~contains(outFormat,"S")

            comp.setOpHeight(1,jOut-1);
            comp.setOpWidth(1,jOut-1);
            comp.setOpNumChannels(outSize(1),jOut-1);
        end













    end
end
