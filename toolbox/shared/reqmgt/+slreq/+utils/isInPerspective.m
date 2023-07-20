function tf=isInPerspective(objH,checkRoot)







    if nargin<2







        checkRoot=true;
    end


    modelH=bdroot(objH);

    if ischar(modelH)
        if dig.isProductInstalled('Simulink')&&bdIsLoaded(modelH)
            modelH=get_param(modelH,'Handle');
        else
            tf=false;
            return;
        end
    end

    if strcmp(get_param(modelH,'IsHarness'),'on')

        thisModel=get_param(modelH,'OwnerBDName');
    else
        thisModel=modelH;
    end

    tf=get_param(thisModel,'ReqPerspectiveActive')~=0;
    if~tf&&checkRoot



        [~,allModelHs]=slreq.utils.DAStudioHelper.getActiveStudios(thisModel,true);
        for cModel=allModelHs
            if cModel~=modelH&&get_param(cModel,'ReqPerspectiveActive')~=0;
                tf=true;
                return;
            end
        end
    end
end