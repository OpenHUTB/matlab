function tcc=hdltargetmodelcc(srcBlkHandle)









    tcc=[];




    srcMdlName=strtok(getfullname(srcBlkHandle),'/');
    srcMdlHDLCoderObj=hdlmodeldriver(srcMdlName);

    pir2slBackEnd=srcMdlHDLCoderObj.BackEnd;

    if~isempty(pir2slBackEnd)
        tcc=pir2slBackEnd.TargetModelCC;
    end

