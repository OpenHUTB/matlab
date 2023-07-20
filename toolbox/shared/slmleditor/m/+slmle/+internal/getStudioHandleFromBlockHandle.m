function[studio,top]=getStudioHandleFromBlockHandle(blockH)



    studio=[];
    top='';

    try
        top=bdroot(blockH);

        st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        for i=1:length(st)
            currentStudio=st(i);
            for mdlH=currentStudio.App.getBlockDiagramHandles
                if mdlH==top
                    studio=currentStudio;
                    return;
                end
            end
        end

    catch ME
        disp(ME.message);
    end

