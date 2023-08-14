function resizeWithoutTable=ResizeWithoutTable(h,blkObj)

    if(~roi_exists(h,blkObj))
        if(strcmp(blkObj.specify,'Output size as a percentage of input size'))
            try
                resize=evalin('base',blkObj.rfactor);
            catch %#ok
                resizeWithoutTable=false;
                return;
            end
            [horizFactor,vertFactor]=getXYresizeFactor(h,resize);
            decimatXDir=(horizFactor<100);
            decimatYDir=(vertFactor<100);


            interpXYDir=(~decimatXDir)&&(~decimatYDir);
            resizeOnFlyDec=(decimatXDir||decimatYDir)&&...
            (INTERP_NEAREST(blkObj)||INTERP_BILINEAR(blkObj))&&(~PERFORM_ANTIALIASING(blkObj));

            resizeOnFlyInt=interpXYDir&&(INTERP_NEAREST(blkObj)||INTERP_BILINEAR(blkObj));

            resizeOnFly=resizeOnFlyInt||resizeOnFlyDec;
            resizeWithoutTable=resizeOnFly;

        else




            resizeWithoutTable=false;
        end
    else
        resizeWithoutTable=false;

    end


    function flag=INTERP_NEAREST(blkObj)
        flag=strcmp(blkObj.interp_method,'Nearest neighbor');


        function flag=INTERP_BILINEAR(blkObj)
            flag=strcmp(blkObj.interp_method,'Bilinear');


            function flag=PERFORM_ANTIALIASING(blkObj)
                flag=strcmp(blkObj.antialias,'on');


