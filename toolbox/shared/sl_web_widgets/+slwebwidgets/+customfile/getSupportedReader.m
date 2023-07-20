function[listOfReaders,descrips,invalidNamespacePlugins]=getSupportedReader(inFileName)




    Simulink.io.FileTypeFactory.getInstance().updateFactoryRegistry();
    listOfReaders=Simulink.io.FileTypeFactory.getInstance().getSupportedReaders(inFileName);

    descrips=cell(1,length(listOfReaders));

    for k=1:length(listOfReaders)
        readerDescrip=slwebwidgets.customfile.getReaderDescription(listOfReaders{k});
        descrips{k}=readerDescrip;
    end


    invalidNamespacePlugins=Simulink.io.FileTypeFactory.getInstance().InvalidNameSpacePlugins;
