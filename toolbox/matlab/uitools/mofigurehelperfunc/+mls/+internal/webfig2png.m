function[bytes,width,height]=webfig2png(fig,dpi,clientDpi,thumbnailSize,varargin)






    if nargin<4
        thumbnailSize=[];
    end

    p=inputParser;
    p.addParameter('method','print',@(arg)any(validatestring(arg,{'print','getframe'})));
    p.addParameter('imageFormat','png',@(arg)any(validatestring(arg,mls.internal.ImageUtils.SupportedImageFormats)));
    p.addParameter('imageQuality',1.0,@(arg)validateattributes(arg,{'double'},{'scalar','real','>',0,'<=',1.0}));
    p.parse(varargin{:});
    method=validatestring(p.Results.method,{'print','getframe'});

    if strcmp(method,'getframe')
        drawnow;
        pixels=getframe(fig);
        if~isempty(thumbnailSize)
            thumbnail=imresize(pixels.cdata,thumbnailSize);
            [height,width,~]=size(thumbnail);
            bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(thumbnail,p.Results.imageFormat,p.Results.imageQuality);
        else
            [height,width,~]=size(pixels.cdata);
            bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(pixels.cdata,p.Results.imageFormat,p.Results.imageQuality);
        end
        return;
    end

    if clientDpi>0
        [bytes,width,height]=localUsingPrintFixedDpi(fig,clientDpi,thumbnailSize,p.Results.imageFormat,p.Results.imageQuality);
    else
        [bytes,width,height]=localUsingPrint(fig,dpi,thumbnailSize,p.Results.imageFormat,p.Results.imageQuality);
    end

end



function[bytes,cols,rows]=localUsingPrintFixedDpi(fig,clientDpi,thumbnailSize,imageFormat,imageQuality)



    oldPrintTemplate=get(fig,'printtemplate');
    oldPaperVals=getPaperProperties(fig);


    set(fig,'printtemplate',[]);


    set(fig,'PaperPositionMode','Auto');


    set(fig,'InvertHardCopy','off');

    drawnow;
    pixels=print(fig,'-RGBImage',['-r',num2str(clientDpi)]);


    setPaperProperties(fig,oldPaperVals);
    set(fig,'printtemplate',oldPrintTemplate);

    if~isempty(thumbnailSize)
        thumbnail=imresize(pixels,thumbnailSize);
        [rows,cols,~]=size(thumbnail);
        bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(thumbnail,imageFormat,imageQuality);
    else
        [rows,cols,~]=size(pixels);
        bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(pixels,imageFormat,imageQuality);
    end

end



function[bytes,cols,rows]=localUsingPrint(fig,dpi,thumbnailSize,imageFormat,imageQuality)


    oldPrintTemplate=get(fig,'printtemplate');
    oldPaperVals=getPaperProperties(fig);


    set(fig,'printtemplate',[]);


    currUnits=get(fig,'Units');
    pos=get(fig,'Position');
    posPixels=hgconvertunits(fig,pos,currUnits,'Pixels',0);

    baseDpi=get(groot,'ScreenPixelsPerInch');
    scaleDpi=(baseDpi/72);
    dpi=round(dpi*scaleDpi);
    maxDpi=round(300*scaleDpi);

    if(dpi<baseDpi)
        dpi=baseDpi;
    elseif(dpi>maxDpi)
        dpi=maxDpi;
    end

    set(fig,'PaperPositionMode','Manual');
    set(fig,'PaperUnits','Inches');

    set(fig,'PaperPosition',posPixels.*[0,0,1/baseDpi,1/baseDpi]);


    set(fig,'InvertHardCopy','off');

    drawnow;
    pixels=print(fig,'-RGBImage',['-r',num2str(dpi)]);


    setPaperProperties(fig,oldPaperVals);
    set(fig,'printtemplate',oldPrintTemplate);

    if~isempty(thumbnailSize)
        thumbnail=imresize(pixels,thumbnailSize);
        [rows,cols,~]=size(thumbnail);
        bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(thumbnail,imageFormat,imageQuality);
    else
        [rows,cols,~]=size(pixels);
        bytes=mls.internal.ImageUtils.getBytesFromCDataRGB(pixels,imageFormat,imageQuality);
    end
end


function props=getPaperProperties(fig)
    ppFields={'PaperUnits','PaperPosition','PaperPositionMode','InvertHardCopy'};
    ppVals=get(fig,ppFields);
    props={ppFields,ppVals};
end

function setPaperProperties(fig,oldProps)
    set(fig,oldProps{1},oldProps{2});
end
