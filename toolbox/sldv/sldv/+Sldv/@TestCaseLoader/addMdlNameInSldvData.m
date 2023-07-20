function[status,sldvdata]=addMdlNameInSldvData(obj,sldvdata)




    modelH=obj.mModelH;
    curMdlName=get_param(modelH,'Name');
    status=true;
    if~isfield(sldvdata,'ModelInformation')


        sldvdata.ModelInformation.Name=curMdlName;
    else


        if~isfield(sldvdata.ModelInformation,'Name')


            sldvdata.ModelInformation.Name=curMdlName;
        else


            if~strcmp(sldvdata.ModelInformation.Name,curMdlName)
                status=false;
                sldvdata.ModelInformation.Name=curMdlName;
            end
        end
    end
end
