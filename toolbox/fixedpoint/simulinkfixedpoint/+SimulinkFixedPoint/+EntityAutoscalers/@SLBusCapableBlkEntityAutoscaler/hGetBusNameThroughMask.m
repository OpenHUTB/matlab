function[isBusName,busName,busObj]=hGetBusNameThroughMask(h,busName,blkObj)%#ok<INUSL>












    isBusName=false;
    busObj=[];
    if isempty(busName)
        busObj=[];
        return;
    end

    parentPath=blkObj.Parent;
    mdl=bdroot(blkObj.Parent);

    while~strcmp(parentPath,mdl)&&...
        strncmp(parentPath,mdl,length(mdl))&&...
        contains(parentPath,'/')

        if~isempty(blkObj)
            if fxptds.isStateflowChartObject(blkObj)
                parentObj=blkObj.up;
            else
                parentObj=blkObj.getParent;
            end
        end





        if isa(parentObj,'Stateflow.Object')


            chartId=sf('DataChartParent',parentObj.Id);
            blkHandle=sf('Private','chart2block',chartId);
            parentObj=get_param(blkHandle,'Object');
        end

        if isempty(parentObj)
            try
                parentObj=get_param(parentPath,'Object');
            catch


                parentPath=regexprep(parentPath,'/[^\/]+$','');
                blkObj=[];
                continue;
            end
        end

        if hasmask(parentObj.Handle)==2

            busReplacementIdx=find(strcmp(parentObj.MaskNames,busName),1);
            if~isempty(busReplacementIdx)
                maskVal=parentObj.MaskValues;
                busName=maskVal{busReplacementIdx};
            end
        end
        blkObj=parentObj;
        parentPath=parentObj.Parent;
    end


    try

        busObj=evalinGlobalScope(bdroot(blkObj.handle),...
        busName);
        if isa(busObj,'Simulink.Bus')
            isBusName=true;
            return;
        else
            return;
        end
    catch
        return;
    end



