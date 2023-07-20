function setSliceMapperForModelHierarchy(obj,origSys,sliceMdl,sliceXfrmr)




    sliceMdlH=get_param(sliceMdl,'Handle');
    obj.currentSliceName=sliceMdl;
    obj.currentSliceMdlH=sliceMdlH;
    obj.currentSliceMap=sliceXfrmr.sliceMapper;


    modelslicerprivate('sliceMdlMapperObj','set',sliceMdlH,sliceXfrmr.sliceMapper);






    warning_obj=warning('query',...
    'Simulink:Harness:BlockDiagramHarnessNameChange');
    old_warning_state=warning_obj.state;
    warning('off','Simulink:Harness:BlockDiagramHarnessNameChange');

    save_system(sliceMdl);




    warning(old_warning_state,'Simulink:Harness:BlockDiagramHarnessNameChange');

    open_system(sliceMdl);


    allRefModels=keys(sliceXfrmr.sliceMapper.refMdlInfo);
    refMdlCnt=numel(allRefModels);
    allModels=zeros(1,refMdlCnt+1);
    allModels(1)=get_param(bdroot(origSys),'Handle');
    for idx=1:refMdlCnt
        try
            allModels(idx+1)=get_param(allRefModels{idx},'Handle');
        catch Mex
        end
    end
    if Simulink.SubsystemType.isModelBlock(obj.sliceSubSystemH)
        allModels(end+1)=get_param(get_param(obj.sliceSubSystemH,'ModelName'),'handle');
    end

    modelslicerprivate('sliceActiveModelMapper','set',allModels,sliceXfrmr.sliceMapper);
end
