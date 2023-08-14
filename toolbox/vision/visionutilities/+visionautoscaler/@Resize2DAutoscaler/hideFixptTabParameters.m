function hideFixptTabParams=hideFixptTabParameters(h,blkObj)%#ok



    hideFixptTabParams=false;
    try
        resize=evalin('base',blkObj.rfactor);


        if(strcmp(blkObj.specify,'Output size as a percentage of input size'))
            if(length(resize)==2)
                horizFactor=resize(1)/100;
                vertFactor=resize(2)/100;
            else
                vertFactor=resize(1)/100;
                horizFactor=vertFactor;
            end
            if((horizFactor==1)&&(vertFactor==1))
                hideFixptTabParams=1;
            end
        end
    catch %#ok

        hideFixptTabParams=false;
    end


