function im=normalizeImageData(im)









    imageClass=class(im);

    switch imageClass

    case{'uint8','logical'}
        im=im2single(im);

    case{'single','double'}
        im=scaleFloatingPoint(im2single(im));

    otherwise
        im=scaleInteger(im);

    end


    if size(im,3)==1
        im=repmat(im,[1,1,3]);
    end


    if size(im,3)>=4
        im=im(:,:,1:3);
    end
end

function im=scaleFloatingPoint(im)


    finiteIdx=isfinite(im(:));
    hasNansInfs=~all(finiteIdx);


    isOutsideRange=any(im(finiteIdx)>1)||any(im(finiteIdx)<0);


    if hasNansInfs

        im(isnan(im))=0;

        im(im==Inf)=1;

        im(im==-Inf)=0;
    end


    if isOutsideRange
        imMax=max(im(:));
        imMin=min(im(:));
        if isequal(imMax,imMin)


            im=0*im;
        else
            if hasNansInfs

                im(finiteIdx)=(im(finiteIdx)-imMin)./(imMax-imMin);
            else
                im=(im-imMin)./(imMax-imMin);
            end
        end
    end

end

function im=scaleInteger(im)

    limits=double([min(im(:)),max(im(:))]);

    if limits(2)==limits(1)
        im=single(im);
    else
        delta=1/(limits(2)-limits(1));
        im=imlincomb(delta,im,-limits(1)*delta,'single');
    end


    im=max(0,min(im,1));

end