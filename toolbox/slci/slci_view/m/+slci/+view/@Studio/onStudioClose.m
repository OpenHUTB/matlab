


function onStudioClose(obj,varargin)


    vm=slci.view.Manager.getInstance;
    studio=obj.getStudio;

    if~isempty(studio)&&isvalid(studio)
        src=slci.view.internal.getSource(studio);

        vm.clearStudioData(src.modelH);


        vm.clearData(src.modelH);
    end
