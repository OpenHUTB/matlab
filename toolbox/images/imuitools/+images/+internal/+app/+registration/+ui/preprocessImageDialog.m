function[fixed,moving,isFixedRGB,isMovingRGB,isFixedNormalized,isMovingNormalized,movingRGB]=preprocessImageDialog(fixed,moving,sameFileFlag,hfig)





    import images.internal.app.registration.ui.*;


    [fixed,isFixedNormalized]=normalizeFloatImages(fixed);
    [moving,isMovingNormalized]=normalizeFloatImages(moving);


    [fixed,isFixedRGB]=convertRGBtoGray(fixed);
    [moving,isMovingRGB,movingRGB]=convertRGBtoGray(moving);


    if any([isFixedRGB,isMovingRGB,isFixedNormalized,isMovingNormalized,sameFileFlag])

        catMessage='';

        if sameFileFlag
            catMessage=getMessageString('sameImage');
        end

        if isFixedRGB||isMovingRGB
            if~isempty(catMessage)
                catMessage=sprintf('%s \n\n',catMessage);
            end
            catMessage=[catMessage,getMessageString('convertToGray')];
        end

        if isFixedNormalized||isMovingNormalized
            if~isempty(catMessage)
                catMessage=sprintf('%s \n\n',catMessage);
            end
            catMessage=[catMessage,getMessageString('floatImage')];
        end


        uialert(hfig,catMessage,getMessageString('inputWarnDlgName'),'Icon','warning');

    end

end

function[im,isDataNormalized]=normalizeFloatImages(im)

    isDataNormalized=false;

    if~isfloat(im)
        return;
    end


    finiteIdx=isfinite(im(:));
    hasNansInfs=~all(finiteIdx);

    isOutsideRange=any(im(finiteIdx)>1)||any(im(finiteIdx)<0);

    if hasNansInfs

        im(isnan(im))=0;


        im(im==Inf)=1;


        im(im==-Inf)=0;

        isDataNormalized=true;
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
        isDataNormalized=true;
    end

end

function[im,isRGB,RGBImage]=convertRGBtoGray(im)

    isRGB=size(im,3)==3;

    if isRGB
        RGBImage=im;
        im=rgb2gray(im);
    else
        RGBImage=[];
    end

end
