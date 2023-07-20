function ProcUnitId=getProcessingUnitId(hCS,PUIndex)






    if nargin<2
        PUIndex=-1;
    end


    if PUIndex==-1
        ProcUnitId=codertarget.targethardware.getProcessingUnitName(hCS);
    else

        allPUs=codertarget.utils.getRegisteredCPUs(hCS);
        allPUs(contains(allPUs,'CLA'))=[];
        ProcUnitId=allPUs{PUIndex};
    end
    if~isempty(ProcUnitId)
        ProcUnitId=regexp(strtrim(ProcUnitId),'\d+$','match','once');
    else
        ProcUnitId=[];
    end
end


