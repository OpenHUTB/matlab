function openAndHiliteCB(action,rootModelHandle,blockPathAllLevels,transitionId)






    persistent HILITE_DATA;



    mlock;

    switch action
    case{'HiliteBlock','HiliteTransition'}
        HILITE_DATA=i_Unhilite(HILITE_DATA,rootModelHandle);
        HILITE_DATA=i_Hilite(HILITE_DATA,rootModelHandle,blockPathAllLevels,transitionId);
    case 'ClearAll'
        HILITE_DATA=i_Unhilite(HILITE_DATA,rootModelHandle);
    end
end


function data=i_Hilite(data,rootModelHandle,blockPathAllLevels,transitionId)
    hiliteDataStruct=getHiliteDataStruct();
    hiliteDataStruct.ModelHandle=rootModelHandle;
    isHilited=false;
    if~isempty(blockPathAllLevels)
        stateflowH=[];
        slStateflowH=[];
        try
            stateflowH=Simulink.variant.utils.getSFObj(blockPathAllLevels{end},Simulink.variant.utils.StateflowObjectType.CHART);
            slStateflowH=Simulink.variant.utils.getSFObj(blockPathAllLevels{end},Simulink.variant.utils.StateflowObjectType.SIMULINK_FUNCTION);
            if isempty(slStateflowH)
                slStateflowH=Simulink.variant.utils.getSFObj(blockPathAllLevels{end},Simulink.variant.utils.StateflowObjectType.SIMULINK_STATE);
            end
        catch ex %#ok<NASGU>

        end

        if~isempty(stateflowH)


            blockParentObject=stateflowH.getParent();
            if isa(blockParentObject,'Stateflow.Chart')
                stateflowH=Simulink.variant.utils.getSFObj(blockPathAllLevels{end},Simulink.variant.utils.StateflowObjectType.ATOMIC_SUBCHART);
                stateflowH.view();
                stateflowH.highlight();
                hiliteDataStruct.ParentSFChartId=blockParentObject.Id;
                isHilited=true;
            end
        elseif~isempty(slStateflowH)


            slStateflowH.view();
            slStateflowH.highlight();
            hiliteDataStruct.ParentSFChartId=slStateflowH.getParent().Id;
            isHilited=true;
        end

        if~isHilited




            hiliteDataStruct.BlockPathAllLevels=blockPathAllLevels;
            blockPathObject=Simulink.BlockPath(blockPathAllLevels);
            parentBlockPathOrBlockPathObject=blockPathObject.getParent();
            i_openTopModelorBlockinSameStudio(parentBlockPathOrBlockPathObject);
            hilite_system(blockPathObject,'find');
            set_param(blockPathAllLevels{end},'Selected','on');
        end
    elseif~isempty(transitionId)
        stateflowH=sf('IdToHandle',transitionId);
        stateflowH.view();
        stateflowH.highlight();
        hiliteDataStruct.ParentSFChartId=stateflowH.getParent().Id;
    end
    data=[data,hiliteDataStruct];
end


function data=i_Unhilite(data,rootModelHandle)
    if isempty(data)
        return;
    end
    hiliteDataStruct=[];
    for i=1:numel(data)
        if data(i).ModelHandle==rootModelHandle
            hiliteDataStruct=data(i);
            data(i)=[];
        end
    end
    if isempty(hiliteDataStruct)
        return;
    end

    try %#ok<TRYNC>
        if~isempty(hiliteDataStruct.BlockPathAllLevels)
            blockPathAllLevels=hiliteDataStruct.BlockPathAllLevels;


            if all(cellfun(@(blockPath)(getSimulinkBlockHandle(blockPath)),blockPathAllLevels)>-1)


                hilite_system(Simulink.BlockPath(blockPathAllLevels),'none');
            else
                for i=1:numel(blockPathAllLevels)
                    if getSimulinkBlockHandle(blockPathAllLevels{i})>-1


                        hilite_system(blockPathAllLevels{i},'none');
                    end
                end
            end
            highlightedBlock=blockPathAllLevels{end};
            if getSimulinkBlockHandle(highlightedBlock)>-1
                set_param(highlightedBlock,'Selected','off');
            end
        elseif~isempty(hiliteDataStruct.ParentSFChartId)
            sf('Highlight',hiliteDataStruct.ParentSFChartId,[]);
        end
    end
end


function i_openTopModelorBlockinSameStudio(blockPathOrBlockPathObject)
    if isa(blockPathOrBlockPathObject,'Simulink.BlockPath')
        blockPathOrBlockPathObject.open('force','on');
    else

        open_system(blockPathOrBlockPathObject);
    end
end


function hiliteDataStruct=getHiliteDataStruct()
    hiliteDataStruct=struct('ModelHandle',[],'BlockPathAllLevels',[],'ParentSFChartId',[]);
end
