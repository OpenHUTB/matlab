function signalEditorSLDVHarness(obj)




    if isReleaseOrEarlier(obj.ver,'R2021b')


        multiSimCall='Sldv.HarnessUtils.openMultiSimulationDesignStudy;';
        currentPostLoadFcn=get_param(obj.modelName,'PostLoadFcn');
        newPostLoadFcn=strrep(currentPostLoadFcn,multiSimCall,'');

        set_param(obj.modelName,'PostLoadFcn',newPostLoadFcn);
    end
end
