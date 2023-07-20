function inpBlock=getFcnCallInport(mfFunction)





    zcModel=systemcomposer.architecture.model.SystemComposerModel...
    .getSystemComposerModel(mf.zero.getModel(mfFunction));
    inpBlock=find_system(zcModel.getRootArchitecture().getName(),...
    'SearchDepth',1,'BlockType','Inport',...
    'OutputFunctionCall','on',...
    'Name',mfFunction.getName());

    if~isempty(inpBlock)
        inpBlock=get_param(inpBlock{1},'Handle');
    else
        inpBlock=[];
    end
end
