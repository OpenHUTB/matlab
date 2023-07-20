



function cacheSlCustomizationData(obj)
    cacheFilePath=obj.getCacheFilePath;




    [MACE,~,jsongStringForRootLevelFolders]=Advisor.Utils.exportJSON('','MACE');
    save(cacheFilePath,'MACE');
    MACE_RootLevelFolders=jsongStringForRootLevelFolders;
    save(cacheFilePath,'-append','MACE_RootLevelFolders');





    CustomizationData=obj.slCustomizationDataStructure;
    CustomizationData.Version=Advisor.Manager.Version;
    lc=matlab.internal.i18n.locale.default;
    CustomizationData.MessagesLocale=lc.Messages;
    CustomizationData.MACE=true;
    fcnHandleCellarray=cell(size(CustomizationData.checkCellArray));
    allFcnHandleString='';
    for i=1:length(CustomizationData.checkCellArray)
        if isa(CustomizationData.checkCellArray{i},'ModelAdvisor.Check')
            fcnHandleCellarray{i}.Callback=CustomizationData.checkCellArray{i}.Callback;
            CustomizationData.checkCellArray{i}.Callback=[];
            fcnHandleCellarray{i}.InputParametersCallback=CustomizationData.checkCellArray{i}.InputParametersCallback;
            CustomizationData.checkCellArray{i}.InputParametersCallback=[];
            fcnHandleCellarray{i}.ListViewActionCallback=CustomizationData.checkCellArray{i}.ListViewActionCallback;
            CustomizationData.checkCellArray{i}.ListViewActionCallback=[];
            fcnHandleCellarray{i}.ListViewCloseCallback=CustomizationData.checkCellArray{i}.ListViewCloseCallback;
            CustomizationData.checkCellArray{i}.ListViewCloseCallback=[];
            if isa(CustomizationData.checkCellArray{i}.Action,'ModelAdvisor.Action')
                fcnHandleCellarray{i}.ActionCallbackHandle=CustomizationData.checkCellArray{i}.Action.CallbackHandle;
                CustomizationData.checkCellArray{i}.Action.CallbackHandle=[];
            end
            eval(['FcnHandle_',num2str(i),'=fcnHandleCellarray{i};']);
            allFcnHandleString=[allFcnHandleString,',''FcnHandle_',num2str(i),''''];%#ok<AGROW>
        end
    end
    save(cacheFilePath,'-append','CustomizationData');


    VerificationData=struct();
    VerificationData.Version=CustomizationData.Version;
    VerificationData.MACE=CustomizationData.MACE;
    VerificationData.MessagesLocale=CustomizationData.MessagesLocale;
    VerificationData.matlabroot=matlabroot;
    save(cacheFilePath,'-append','VerificationData');

    if~isempty(allFcnHandleString)
        eval(['save(cacheFilePath,''-append''',allFcnHandleString,');']);
    end

end