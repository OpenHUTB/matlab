


function onStudioClose(obj,varargin)


    mr=slci.manualreview.Manager.getInstance;
    studio=obj.getStudio;

    src=slci.manualreview.util.getSource(studio);

    mr.clearStudioData(src.modelH);

