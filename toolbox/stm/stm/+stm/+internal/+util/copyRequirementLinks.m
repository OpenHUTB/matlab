function count=copyRequirementLinks(toFile,toUUID,fromFile,fromUUID,isCut)




    try
        rmiData=rmitm.getReqs(fromFile,fromUUID);
        count=length(rmiData);
        if(count>0)
            rmitm.setReqs(toFile,toUUID,rmiData);
            if(isCut)
                rmitm.setReqs(fromFile,fromUUID,[]);
            end
        end
    catch

    end
end