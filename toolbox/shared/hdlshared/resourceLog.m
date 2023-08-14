function resourceLog(size1,size2,opType)




    resrc=PersistentHDLResource;
    if~isempty(resrc)
        switch opType
        case{'add','sub','mul','mux','mem'}
            newElement=[num2str(opType),'_comp_',num2str(size1),'x',num2str(size2)];
            numElement=1;
        case 'reg'
            newElement=[num2str(opType),'_comp_',num2str(size1)];
            numElement=size2;
        end

        if isKey(resrc(end).bom,newElement)
            resrc(end).bom(newElement)=resrc(end).bom(newElement)+numElement;
        else
            resrc(end).bom(newElement)=numElement;
        end
        PersistentHDLResource(resrc);
    end