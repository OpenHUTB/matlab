classdef IconView<matlab.graphics.shape.internal.image.ImageSource










    properties
        Icon;
        BorderWidth=2;
        IconSize=16;
    end

    properties(Hidden,Transient)
        BackgroundColor=matlab.graphics.shape.internal.image.IconView.DefaultBackground;
        ForegroundColor=matlab.graphics.shape.internal.image.IconView.DefaultForground;
        Selected=false;
        DPIScale=1;
    end

    properties(Constant,Hidden)

        DefaultBackground=[240,240,240];

        DefaultForground=[96,96,96];

        DefaultContrastForground=[255,255,255];

        DefaultSelectionColor=[3,152,252];


        DefaultReverseConstrastSelectionColor=[200,200,255];
        MaxIndex=64;
        MinIndex=1;
    end

    methods
        function im=loadImage(obj)




            im=obj.getTrueColorData;
        end
    end

    methods
        function icon=addDecoration(obj)
            icon=obj.Icon;
        end

        function setDPIScale(obj,scale)


            if~isequal(obj.DPIScale,scale)
                obj.DPIScale=scale;
                notify(obj,'SourceChanged');
            end
        end

        function set.BackgroundColor(this,value)
            updateImageData=~isequal(this.BackgroundColor,value);
            this.BackgroundColor=value;



            if updateImageData
                if rgb2gray(reshape(double(value)/255,[1,1,3]))<.28
                    this.ForegroundColor=this.DefaultContrastForground;
                else
                    this.ForegroundColor=this.DefaultForground;
                end
                notify(this,'SourceChanged');
            end
        end

        function set.Selected(this,selected)
            selectionChanged=~isequal(this.Selected,selected);
            if selectionChanged
                this.Selected=selected;
                notify(this,'SourceChanged');
            end
        end

        function set.Icon(this,iconValue)

            if ischar(iconValue)||isstring(iconValue)



                [I,map,alpha]=imread(iconValue);


                if~isempty(map)

                    I=uint8(round(255*ind2rgb(I,map)));
                end


                if ndims(I)==3


                    grayScaleImage=rgb2gray(I);
                elseif ismatrix(I)
                    if islogical(I)
                        grayScaleImage=double(I);
                    else
                        grayScaleImage=I;
                    end
                else
                    error(message('MATLAB:graphics:shape:internal:image:IconView:InvalidFile'));
                end

                this.Icon=matlab.graphics.shape.internal.image.IconView.indexImageDataFromGrayScale(grayScaleImage,alpha);
            elseif ismatrix(iconValue)

                this.Icon=double(iconValue);
            elseif ndims(iconValue)==3




                nanValues=any(isnan(iconValue),3);

                grayScaleImage=rgb2gray(iconValue);


                if any(nanValues(:))
                    alpha=ones(size(grayScaleImage));
                    alpha(nanValues)=0;
                    this.Icon=matlab.graphics.shape.internal.image.IconView.indexImageDataFromGrayScale(grayScaleImage,alpha);
                else
                    this.Icon=matlab.graphics.shape.internal.image.IconView.indexImageDataFromGrayScale(grayScaleImage);
                end
            else
                error(message('MATLAB:graphics:shape:internal:image:IconView:InvalidIcon'));
            end


            this.Icon=this.addDecoration();

            notify(this,'SourceChanged');
        end

        function imageData=getTrueColorData(this)

            selected=this.Selected;
            indexImage=this.Icon;



            if nargin>=2
                indexedGrayScaleInteger=indexImage;
            else
                indexedGrayScaleInteger=this.Icon;
            end


            backgroundColor=this.BackgroundColor;
            foregroundColor=this.ForegroundColor;
            if foregroundColor(1)<backgroundColor(1)

                colormapLength=this.MaxIndex-this.MinIndex+1;
                if~selected
                    map=[linspace(foregroundColor(1)/255,backgroundColor(1)/255,colormapLength)',...
                    linspace(foregroundColor(2)/255,backgroundColor(2)/255,colormapLength)',...
                    linspace(foregroundColor(3)/255,backgroundColor(3)/255,colormapLength)'];
                else


                    map=zeros(colormapLength,3);
                    map(:,3)=gammaCurve(this.DefaultSelectionColor(3)/255,backgroundColor(3)/255,2.2)';
                    map(:,2)=gammaCurve(this.DefaultSelectionColor(2)/255,backgroundColor(2)/255,1/2.2)';
                    map(:,1)=gammaCurve(this.DefaultSelectionColor(1)/255,backgroundColor(1)/255,1/2.2)';
                end
            else
                if~selected
                    map=[gammaCurve(foregroundColor(1)/255,backgroundColor(1)/255,2.2)',...
                    gammaCurve(foregroundColor(2)/255,backgroundColor(2)/255,2.2)',...
                    gammaCurve(foregroundColor(3)/255,backgroundColor(3)/255,2.2)'];
                else


                    colormapLength=this.MaxIndex-this.MinIndex+1;
                    map=zeros(colormapLength,3);
                    map(:,3)=gammaCurve(this.DefaultReverseConstrastSelectionColor(3)/255,backgroundColor(3)/255,2.2)';
                    map(:,2)=gammaCurve(this.DefaultReverseConstrastSelectionColor(2)/255,backgroundColor(2)/255,1/2.2)';
                    map(:,1)=gammaCurve(this.DefaultReverseConstrastSelectionColor(1)/255,backgroundColor(1)/255,1/2.2)';
                end
            end



            maxDim=max(size(indexedGrayScaleInteger));
            backgroundColorIndex=length(map);
            if size(indexedGrayScaleInteger,1)<maxDim
                beforePadding=round((maxDim-size(indexedGrayScaleInteger,1))/2);
                afterPadding=maxDim-beforePadding-size(indexedGrayScaleInteger,1);
                expandedGrayScaleInteger=repmat(backgroundColorIndex,maxDim,maxDim);
                expandedGrayScaleInteger(beforePadding+1:maxDim-afterPadding,:)=indexedGrayScaleInteger;
                indexedGrayScaleInteger=expandedGrayScaleInteger;
            elseif size(indexedGrayScaleInteger,2)<maxDim
                beforePadding=round((maxDim-size(indexedGrayScaleInteger,2))/2);
                afterPadding=maxDim-beforePadding-size(indexedGrayScaleInteger,2);
                expandedGrayScaleInteger=repmat(backgroundColorIndex,maxDim,maxDim);
                expandedGrayScaleInteger(:,beforePadding+1:maxDim-afterPadding)=indexedGrayScaleInteger;
                indexedGrayScaleInteger=expandedGrayScaleInteger;
            end


            highDPIScaleFactor=this.DPIScale;
            RGB=ind2rgb(indexedGrayScaleInteger,map);
            scaledBorderWidth=round(this.BorderWidth*highDPIScaleFactor);
            contentSize=round(this.IconSize*highDPIScaleFactor);
            buttonSize=contentSize+2*scaledBorderWidth;



            if isempty(RGB)
                RGBscaled=ones(buttonSize,buttonSize,3);
            else
                RGBscaled=repmat(reshape(backgroundColor/255,[1,1,3]),[buttonSize,buttonSize]);
                scaledIconRGB=imresize(RGB,[contentSize,contentSize]);
                RGBscaled(scaledBorderWidth+1:size(scaledIconRGB,1)+scaledBorderWidth,scaledBorderWidth+1:size(scaledIconRGB,2)+scaledBorderWidth,:)=...
                scaledIconRGB;
            end

            imageData=uint8(RGBscaled*255);



            imageData(:,:,4)=255;
        end
    end

    methods(Static)

        function indexImage=indexImageDataFromGrayScale(grayScaleImage,alpha)









            if isa(grayScaleImage,'uint8')
                indexedGrayScaleProportional=double(grayScaleImage)/255;
            elseif isa(grayScaleImage,'uint16')
                indexedGrayScaleProportional=double(grayScaleImage)/(256^2-1);
            else
                indexedGrayScaleProportional=double(grayScaleImage);
            end



            if nargin>=2&&~isempty(alpha)
                alphaProportional=im2double(alpha);
                indexedGrayScaleProportional=1-(1-indexedGrayScaleProportional).*alphaProportional;
            end








            maxGray=max(indexedGrayScaleProportional(:));
            minGray=min(indexedGrayScaleProportional(:));
            if maxGray-minGray>.01/255
                coef=[minGray,1;maxGray,1]\[0;1];
                indexedGrayScaleProportional=indexedGrayScaleProportional*coef(1)+coef(2);
            end




            colormapLength=matlab.graphics.shape.internal.image.IconView.MaxIndex-...
            matlab.graphics.shape.internal.image.IconView.MinIndex+1;
            indexImage=round(indexedGrayScaleProportional*(colormapLength-1)+1);
        end
    end
end

function gammaScale=gammaCurve(a,b,gam)


    colormapLength=matlab.graphics.shape.internal.image.IconView.MaxIndex-...
    matlab.graphics.shape.internal.image.IconView.MinIndex+1;
    gammaScale=(b-a)*((1:colormapLength)/colormapLength).^(gam)+a;
end