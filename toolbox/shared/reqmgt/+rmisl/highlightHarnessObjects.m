function result=highlightHarnessObjects(harnessName)




    [slReq,sfReq,reqInside,sfFade]=rmisl.getHarnessObjectsWithReqs(harnessName);


    cutH=get_param([harnessName,':1'],'Handle');
    cutColor=get_param(cutH,'HiliteAncestors');
    if any(strcmp(cutColor,{'fade','off','none'}))

        cutColors={};
    else
        [cutObjs,cutColors]=cacheCutColors(cutH);
    end
    set_param(harnessName,'HiliteAncestors','fade');
    if~isempty(cutColors)
        restoreCutColors(cutObjs,cutColors);
    end


    harnessH=get_param(harnessName,'Handle');
    for i=1:length(slReq)
        if slReq(i)~=harnessH
            set_param(slReq(i),'HiliteAncestors','reqHere');
        end
    end


    if~isempty(sfReq)||~isempty(sfFade)
        rmisf.highlight(sfReq,sfFade,harnessName,'req');
    end


    for i=1:length(reqInside)
        if~strcmp(get_param(reqInside(i),'HiliteAncestors'),'reqHere')
            set_param(reqInside(i),'HiliteAncestors','reqInside');
        end
    end

    result=~isempty(slReq)||~isempty(sfReq)||~isempty(reqInside);

end

function[coloredObjs,colors]=cacheCutColors(cutH)
    cutObj=get_param(cutH,'Object');
    cutBlocks=find(cutObj,'-isa','Simulink.Block');
    isColored=false(size(cutBlocks));
    colors=cell(size(cutBlocks));
    for i=1:length(cutBlocks)
        oneObj=cutBlocks(i);
        oneColor=oneObj.HiliteAncestors;
        if any(strcmp(oneColor,{'off','none'}))
            isColored(i)=true;
            colors{i}='fade';
        elseif~strcmp(oneColor,'fade')

            isColored(i)=true;
            colors{i}=oneColor;
        end
    end
    coloredObjs=cutBlocks(isColored);
    colors(~isColored)=[];
end

function restoreCutColors(cutObjs,colors)
    for i=1:length(cutObjs)
        cutObjs(i).HiliteAncestors=colors{i};
    end
end
