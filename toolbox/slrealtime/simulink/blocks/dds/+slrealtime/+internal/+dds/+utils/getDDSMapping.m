function[participantLibrary,participant,pubSub,readerWriter]=getDDSMapping(...
    readerWriterPath)





    entities=split(readerWriterPath,"/");


    if(length(entities)==4)
        participantLibrary=entities{1};
        participant=entities{2};
        pubSub=entities{3};
        readerWriter=entities{4};
    else
        participantLibrary='';
        participant='';
        pubSub='';
        readerWriter='';
    end

end

