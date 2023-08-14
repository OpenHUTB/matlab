function hideAccProdFixptTabParams=hideAccProdFixptTabParameters(h,blkObj)




    if hideFixptTabParameters(h,blkObj)

        hideAccProdFixptTabParams=true;
    else

        hideAccProdFixptTabParams=false;
        optimizedNNCaseX=0;
        optimizedNNCaseY=0;

        if(strcmp(blkObj.interp_method,'Nearest neighbor')&&(~roi_exists(h,blkObj))&&ResizeWithoutTable(h,blkObj))
            try
                resize=evalin('base',blkObj.rfactor);
            catch %#ok
                hideAccProdFixptTabParams=false;
                return;
            end

            [horizFactor,vertFactor]=getXYresizeFactor(h,resize);
            horizFactor=horizFactor/100;
            vertFactor=vertFactor/100;

            if(((horizFactor>=1)&&(mod(horizFactor,1)==0))||...
                ((horizFactor<1)&&(mod(1,horizFactor)==0)))
                optimizedNNCaseY=1;
            end
            if(((vertFactor>=1)&&(mod(vertFactor,1)==0))||...
                ((vertFactor<1)&&(mod(1,vertFactor)==0)))
                optimizedNNCaseX=1;
            end
            if(optimizedNNCaseX&&optimizedNNCaseY)
                hideAccProdFixptTabParams=true;
            end
        end
    end


