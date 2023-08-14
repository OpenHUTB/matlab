function[url,width,height]=getFigureImageUrl(hFig,dpi,clientDpi,method,thumbnailSize,imageFormat,imageQuality)
    if nargin<4
        method='print';
    end
    if nargin<5
        thumbnailSize=[];
    end
    if nargin<6
        imageFormat='png';
        imageQuality=1.0;
    end

    if(imageQuality<0||imageQuality>=1)
        imageQuality=1.0;
    end

    [data,width,height]=mls.internal.webfig2png(hFig,dpi,clientDpi,thumbnailSize,...
    'method',method,'imageFormat',imageFormat,'imageQuality',imageQuality);

    base64String=matlab.net.base64encode(data);
    url=sprintf('data:image/%s;base64,%s',imageFormat,base64String);
end
