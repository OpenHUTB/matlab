function pathItems=getPathItems(h,blkObj)%#ok





    if(blockHasFixptDialog(blkObj))
        pathItems={'Accumulator',...
        'Product output'};
    else
        pathItems={};
    end


    function hasFixptDialog=blockHasFixptDialog(blkObj)

        if strcmp(blkObj.MaskType,'Draw Shapes')
            dontNeedFillOption=strcmp(blkObj.shape,'Lines');
            mayHaveAntiAntiliasing=~strcmp(blkObj.shape,'Rectangles');
        else
            dontNeedFillOption=strcmp(blkObj.shape,'X-mark')...
            ||strcmp(blkObj.shape,'Plus')||strcmp(blkObj.shape,'Star');
            mayHaveAntiAntiliasing=strcmp(blkObj.shape,'Circle')...
            ||strcmp(blkObj.shape,'X-mark')...
            ||strcmp(blkObj.shape,'Star');
        end

        hasOpacity=(~dontNeedFillOption&&strcmp(blkObj.fill,'on'));

        if(hasOpacity||(mayHaveAntiAntiliasing&&strcmp(blkObj.antialiasing,'on')))
            hasFixptDialog=1;
        else
            hasFixptDialog=0;
        end


