function svgString=process_image(obj,params)




    svgString='';
    position=[];

    if(numel(params)>1)
        position=params{2};
    end
    if(strcmpi(obj.Units,'normalized'))
        if(isempty(position))
            position=[0,0,1,1];
        end

        if(isnumeric(position))
            position(1)=position(1)*obj.Width;
            position(2)=position(2)*obj.Height;
            position(3)=position(3)*obj.Width;
            position(4)=position(4)*obj.Height;
        end
    end


    imageURL=params{1};
    if(iscell(imageURL))
        imageURL=imageURL{1};
    end


    if(isempty(imageURL))
        return;
    end



    if(isnumeric(imageURL))


        filePath=obj.ImageSavePath;
        tempNumber=randi(100000);
        tempFilePath=fullfile(filePath{:},['temp',char(string(tempNumber)),'.png']);



        while(exist(tempFilePath,'file'))
            tempNumber=randi(100000);
            tempFilePath=fullfile(filePath{:},['temp',char(string(tempNumber)),'.png']);
        end

        imwrite(imageURL,tempFilePath);
        imageURL=tempFilePath;
    end



    if(~isempty(regexp(imageURL,'svg$','match')))
        obj.SVGPath=imageURL;
        return;
    end


    var=imfinfo(imageURL);
    imgWidth=var.Width;
    imgHeight=var.Height;
    tempPath=strsplit(var.Filename,'/');
    fullImagePath=fullfile(tempPath{:});
    imageURL=['file:///',fullImagePath];
    imageURL=regexprep(imageURL,'\','/');



    if(isempty(position))


        svgString=['<image xlink:href="',string(imageURL),'" x="0" y="0" width="',string(obj.Width),'" height="',string(obj.Height),'" preserveAspectRatio="none"/>'];
        return;
    end
    if(ischar(position))

        imgProperties=['width="',string(imgWidth),'" height="',string(imgHeight),'" '];

        if(strcmp(position,'center'))
            svgString=['<image xlink:href="',string(imageURL),'" x="',string((obj.Width-imgWidth)/2),'" y="',string((obj.Height-imgHeight)/2),'" ',imgProperties,'d:options="AnchorX:Center;AnchorY:Center;ScalingOnResize:ShrinkOnly"/>'];
        end
        if(strcmp(position,'top-left'))
            svgString=['<image xlink:href="',string(imageURL),'" x="0" y="0" ',imgProperties,'d:options="AnchorX:Left;AnchorY:Top;ScalingOnResize:ShrinkOnly"/>'];
        end
        if(strcmp(position,'top-right'))
            svgString=['<image xlink:href="',string(imageURL),'" x="',string(obj.Width-imgWidth),'" y="0" ',imgProperties,' d:options="AnchorX:Right;AnchorY:Top;ScalingOnResize:ShrinkOnly"/>'];
        end
        if(strcmp(position,'bottom-left'))
            svgString=['<image xlink:href="',string(imageURL),'" x="0" y="',string(obj.Height-imgHeight),'" ',imgProperties,'d:options="AnchorX:Left;AnchorY:Bottom;ScalingOnResize:ShrinkOnly"/>'];
        end
        if(strcmp(position,'bottom-right'))
            svgString=['<image xlink:href="',string(imageURL),'" x="',string(obj.Width-imgWidth),' "y="',string(obj.Height-imgHeight),'" ',imgProperties,'d:options="AnchorX:Right;AnchorY:Bottom;ScalingOnResize:ShrinkOnly"/>'];
        end
    else
        svgString=['<image xlink:href="',string(imageURL),'" x="',string(position(1)),'" y="',string(obj.Height-position(2)-position(4)),'" width="',position(3),'" height="',position(4),'"/>'];
    end
    svgString=[svgString,'\n'];


    svgString=strjoin(string(svgString),'');
end