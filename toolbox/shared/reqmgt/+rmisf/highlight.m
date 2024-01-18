function highlight(highlightHs,fadeHs,modelName,mode)
    modelName=convertStringsToChars(modelName);
    mode=convertStringsToChars(mode);

    if strcmp(mode,'req')||strcmp(mode,'on')
        style=sf_style('req');

    elseif strcmp(mode,'off')
        style=sf_style('off');
    else
        warn(['Unsupported style name in sfHighlight: ',mode]);
        return;
    end
    hasActiveHarness=Simulink.harness.internal.hasActiveHarness(modelName);

    if~strcmp(mode,'off')
        fade_style=sf_style('fade');
        for i=1:length(fadeHs)
            highlightOneObject(fadeHs(i),fade_style,hasActiveHarness);
        end
    end

    allHighlighted=[];
    for i=1:length(highlightHs)
        thisId=highlightHs(i);
        if any(allHighlighted==thisId)
            continue;
        elseif strcmp(mode,'off')
            highlightOneObject(thisId,style,hasActiveHarness);

        else
            allHighlighted=highlightWithParents(thisId,allHighlighted,style,hasActiveHarness);
        end
    end
    machine=find(sfroot,'-isa','Stateflow.Machine','-and','Name',modelName);%#ok<GTARG>
    if~isempty(machine)
        machineID=machine.id;
        sf('Redraw',machineID);
    end
end


function allHighlighted=highlightWithParents(myId,allHighlighted,style,hasActiveHarness)
    highlightOneObject(myId,style,hasActiveHarness);
    parent=sf('ParentOf',myId);
    if sf('IsSubviewer',parent)
        allHighlighted=highlightWithParents(parent,allHighlighted,style,hasActiveHarness);
    end
    allHighlighted(end+1)=myId;
end


function highlightOneObject(objId,style,hasActiveHarness)
    sf_set_style(objId,style);
    if hasActiveHarness
        sfrt=sfroot;
        sfObj=sfrt.idToHandle(objId);
        harnessObjSid=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(sfObj);
        if~isempty(harnessObjSid)
            harnessObj=Simulink.ID.getHandle(harnessObjSid);
            if~isa(harnessObj,'Stateflow.Object')
                harnessObj=sfprivate('block2chart',harnessObj);
                sf_set_style(harnessObj,style);
            else
                sf_set_style(harnessObj.Id,style);
            end
        end
    end
end

