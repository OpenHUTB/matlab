function visionsyslinit(fcnName)




    [status,~]=license('checkout','Video_and_Image_Blockset');

    if~status
        error(message('MATLAB:license:NoFeature',fcnName,'Video_and_Image_Blockset'))
    end