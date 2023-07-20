function roi_exist=roi_exists(h,blkObj)%#ok
    ROI_SUPPORTED=(strcmp(blkObj.specify,'Number of output rows and columns')...
    &&(INTERP_NEAREST(blkObj)...
    ||INTERP_BILINEAR(blkObj)...
    ||INTERP_BICUBIC(blkObj))...
    &&(~PERFORM_ANTIALIASING(blkObj)));
    roi_exist=ROI_SUPPORTED&&strcmp(blkObj.useROI,'on');


    function flag=INTERP_NEAREST(blkObj)
        flag=strcmp(blkObj.interp_method,'Nearest neighbor');


        function flag=INTERP_BILINEAR(blkObj)
            flag=strcmp(blkObj.interp_method,'Bilinear');


            function flag=INTERP_BICUBIC(blkObj)
                flag=strcmp(blkObj.interp_method,'Bicubic');


                function flag=PERFORM_ANTIALIASING(blkObj)
                    flag=strcmp(blkObj.antialias,'on');


