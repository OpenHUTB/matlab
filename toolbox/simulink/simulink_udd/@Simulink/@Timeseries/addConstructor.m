function addConstructor(h,constrCellArray)






    dataContainer=h.getContainer('Data');
    if~isempty(dataContainer)
        set(dataContainer,'Dataconstructor',constrCellArray)
    end
