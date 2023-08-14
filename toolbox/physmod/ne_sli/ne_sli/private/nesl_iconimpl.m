function img=nesl_iconimpl(blk,mlEvalStr,sourceExt,imageExt,doPermute,fileExists)





    if fileExists

        sourceFile=which(mlEvalStr);


        imgFile=strrep(sourceFile,sourceExt,imageExt);
    else
        packagePath=what(['+',sourceExt]);
        imgFile=fullfile(fileparts(packagePath(1).path),mlEvalStr);
    end



    pos=get_param(blk,'Position');
    imgWidth=pos(3)-pos(1);
    imgHeight=pos(4)-pos(2);
    imgSize=[imgWidth,imgHeight];
    rasterizationFactor=5;


    if strcmp(imageExt,'.svg')
        readSvg=str2func('MG2.SvgIO.readResized');
        img=readSvg(imgFile,rasterizationFactor*imgSize);
    else
        img=imread(imgFile);
    end


    if doPermute
        img=permute(img,[2,1,3]);
    end


end
