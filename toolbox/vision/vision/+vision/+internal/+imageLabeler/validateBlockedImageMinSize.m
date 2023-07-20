function validateBlockedImageMinSize(bimSize)
    validateattributes(bimSize,{'numeric'},{'integer','positive','finite','numel',2});
end
