function updateGeneralPanel(this)








    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    data=vidObj.UserData;

    formatNodePanel.setFramesToAcquire(vidObj.FramesPerTrigger,data.FramesPerTrigger);


    colorSpaceInfo=propinfo(vidObj,'ReturnedColorSpace');
    colorSpaces=colorSpaceInfo.ConstraintValue;



    if~strcmpi(colorSpaceInfo.DefaultValue,'grayscale')
        colorSpaces=setxor(colorSpaces,'bayer');
    else

        bayerInfo=propinfo(vidObj,'BayerSensorAlignment');

        formatNodePanel.updateBayerAlignmentValues(bayerInfo.ConstraintValue,vidObj.BayerSensorAlignment);

    end

    formatNodePanel.updateColorSpaces(colorSpaces,vidObj.ReturnedColorSpace);
