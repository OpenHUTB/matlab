function im=getOverlayImage(slice,label,labelColormap,labelAlphamap,contrastLimits)




    slice=imadjust(slice,im2single(contrastLimits));

    if ismatrix(slice)
        slice=repmat(slice,[1,1,3]);
    end

    im=images.internal.builtins.labeloverlay(im2single(slice),double(label),single(labelColormap),single(labelAlphamap));

end
