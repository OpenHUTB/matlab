function out=imadjustGPUImpl(img,lowIn,highIn,lowOut,highOut,gammaIn,imgClass)%#codegen







    coder.allowpcode('plain');
    coder.inline('always');

    out=coder.nullcopy(img);

    for dim=1:size(img,3)
        inpImg=img(:,:,dim);
        outImg=coder.nullcopy(inpImg);
        t_lowIn=lowIn(dim);
        t_gammaIn=gammaIn(dim);
        t_highIn=highIn(dim);
        t_lowOut=lowOut(dim);
        t_InDiff=highIn(dim)-lowIn(dim);
        t_OutDiff=highOut(dim)-lowOut(dim);


        coder.gpu.internal.kernelImpl(false);
        for i=1:numel(inpImg)

            if~isa(imgClass,'double')
                img_pix=im2double(inpImg(i));
            else
                img_pix=inpImg(i);
            end


            img_pix=max(t_lowIn,min(t_highIn,img_pix));


            img_pix=((img_pix-t_lowIn)/t_InDiff)^t_gammaIn;
            img_pix=img_pix*t_OutDiff+t_lowOut;


            if~isa(imgClass,'double')
                outImg(i)=images.internal.changeClass(imgClass,img_pix);
            else
                outImg(i)=img_pix;
            end
        end

        out(:,:,dim)=outImg;
    end
