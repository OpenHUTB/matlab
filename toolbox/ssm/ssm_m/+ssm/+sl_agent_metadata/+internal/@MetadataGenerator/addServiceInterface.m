function addServiceInterface(mf0,itfValues,interfaceName)









    if isempty(mf0)||~isa(mf0,'mf.zero.Model')||isempty(itfValues)||~isa(itfValues,'cell')
        return
    end

    zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf0);
    portIntrfCatalog=zcModel.getPortInterfaceCatalog();


    exeInterface=systemcomposer.architecture.model.swarch.ServiceInterface.createPortInterface(mf0,interfaceName);

    for idx=1:length(itfValues)

        itfValue=itfValues{1};
        if isfield(itfValue,'element')

            fElem=exeInterface.addElement(itfValue.element);


            if isfield(itfValue,'arguments')
                for idy=1:length(itfValue.arguments)
                    fElem.addFunctionArgument(itfValue.arguments{idy});
                end
            end
        end
    end


    portIntrfCatalog.insertPortInterface(exeInterface);
end


