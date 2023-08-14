function newEx=recreateTopException(oldEx,newId,newMsg,newHandles)




    if(strcmp(newId,oldEx.identifier)&&strcmp(newMsg,oldEx.message))


        newEx=oldEx.extractTopException;
    else





        msgSafePaths=strrep(newMsg,'\','\\');

        newEx=MSLException(newHandles,newId,msgSafePaths);

        assert(strcmp(newEx.message,newMsg));

        oldHook=slsvTestingHook('SLSV_POPULATE_MSTACK',1);
        newEx=newEx.setMetaData('ACTION',oldEx.action);
        slsvTestingHook('SLSV_POPULATE_MSTACK',oldHook);
    end
end
