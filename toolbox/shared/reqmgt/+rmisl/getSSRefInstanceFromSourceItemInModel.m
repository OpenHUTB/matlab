function out=getSSRefInstanceFromSourceItemInModel(blkOrModel,mainModel)

    if isa(mainModel,'double')
        mainModel=getfullname(mainModel);
    end

    if isModelName(blkOrModel)

        out=Simulink.findBlocks(mainModel,'ReferencedSubsystem',blkOrModel);
    else
        allInstances=slInternal('getActiveSSRefInstancesFromSourceBlock',blkOrModel);
        if isempty(allInstances)
            sepLocations=strfind(blkOrModel,':');

            for index=flip(sepLocations)
                blkOrModelID=blkOrModel(1:index-1);
                resID=blkOrModel(index:end);

                allBlkInstances=slInternal('getActiveSSRefInstancesFromSourceBlock',blkOrModelID);
                if~isempty(allBlkInstances)
                    allInstances=strcat(allBlkInstances,resID);
                    break;
                end
            end
        end

        out=[];
        for index=1:length(allInstances)
            cInstance=allInstances{index};
            instanceModel=strtok(cInstance,':');
            if strcmp(instanceModel,mainModel)
                out(end+1)=rmisl.getHandleFromFullSID(cInstance,true);%#ok<AGROW>
            end
        end

        out=out';

    end
end


function out=isModelName(objNameHandleOrSID)
    out=false;
    if isvarname(objNameHandleOrSID)
        out=true;
        return;
    end

    if ishandle(objNameHandleOrSID)

        try
            out=strcmp(get(objNameHandleOrSID,'Type'),'block_diagram');
            return;
        catch
        end
    end

end