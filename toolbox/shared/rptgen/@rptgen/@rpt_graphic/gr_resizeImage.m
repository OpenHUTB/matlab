function actualOutputFile=gr_resizeImage(this,inputFile,desiredOutputFile)
















    try
        [img,map]=imread(inputFile);
    catch ex
        if strcmpi(ex.identifier,'MATLAB:imagesci:imread:fileFormat')
            this.status(...
            getString(message('rptgen:r_rpt_graphic:invalidFormatMessage')),...
            2);
        else
            this.status(ex.message,1);
        end
        actualOutputFile='';
        return
    end


    iSizeInPixels=[size(img,1),size(img,2)];


    ppi=get(0,'ScreenPixelsPerInch');
    switch lower(this.ViewportUnits)
    case 'inches'
        conversionFactor=ppi;
    case 'points'
        conversionFactor=ppi/72;
    case 'centimeters'
        conversionFactor=ppi/2.54;
    otherwise
        conversionFactor=1;
    end
    viewportSizeInPixels=conversionFactor*this.ViewportSize;


    if strcmpi(this.ViewportType,'zoom')
        scaling=max(this.ViewportZoom,0.1)/100;
        newSize=scaling*iSizeInPixels;

        if(newSize(1)>viewportSizeInPixels(1))||...
            (newSize(2)>viewportSizeInPixels(2))

            viewportScale=viewportSizeInPixels./iSizeInPixels;
            scaling=min(viewportScale(1),viewportScale(2));
        end

    else

        viewportScale=viewportSizeInPixels./iSizeInPixels;
        scaling=min(viewportScale(1),viewportScale(2));
    end


    if~isempty(map)
        img=ind2rgb(img,map);


        [unused,unused,fileExt]=fileparts(desiredOutputFile);%#ok<ASGLU>
        actualOutputFile=regexprep(desiredOutputFile,[fileExt,'$'],'.jpg');
        this.status('Index image file detected.  Changing output type to jpeg.',2);
    else
        actualOutputFile=desiredOutputFile;
    end


    resizedImg=locResizeImage(img,scaling);
    try
        imwrite(resizedImg,actualOutputFile);
    catch ex
        actualOutputFile='';
        this.status(ex.message,1);
    end


    function out=locResizeImage(in,scale)




        out_size=round(scale*[size(in,1),size(in,2)]);


        if islogical(in)
            out=false([out_size,3]);
        else
            out=zeros([out_size,3],class(in));
        end


        in=double(in);


        temp=zeros(out_size(1),size(in,2),3);


        for k=1:3
            temp(:,:,k)=resize_columns(in(:,:,k),out_size(1));
        end



        if islogical(out)
            for k=1:3

                out(:,:,k)=resize_columns(temp(:,:,k)',out_size(2))'>=0.5;
            end
        else
            for k=1:3
                out(:,:,k)=resize_columns(temp(:,:,k)',out_size(2))';
            end
        end


        function out=resize_columns(in,Mout)






            scale=Mout/size(in,1);


            if(scale<1)
                filter_length=11;
                b=design_filter(11,scale)';





                pad_length=floor(filter_length/2);
                in=[in(ones(pad_length,1),:);in;in(end*ones(pad_length,1),:)];


                in=conv2(in,b,'valid');
            end


            yi=linspace(1,size(in,1),Mout)';
            out=interp1(in,yi);


            function b=design_filter(N,Wn)



                odd=rem(N,2);
                vec=1:floor(N/2);
                vec2=pi*(vec-(1-odd)/2);

                wind=.54-.46*cos(2*pi*(vec-1)/(N-1));
                b=[fliplr(sin(Wn*vec2)./vec2).*wind,Wn];
                b=b([vec,floor(N/2)+(1:odd),fliplr(vec)]);
                b=b/abs(polyval(b,1));
