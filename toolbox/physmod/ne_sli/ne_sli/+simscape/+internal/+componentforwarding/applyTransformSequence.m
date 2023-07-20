function componentSettings=applyTransformSequence(componentSettings,transforms)










    for idx=1:numel(transforms)
        componentSettings=apply(transforms(idx),componentSettings);
    end

end