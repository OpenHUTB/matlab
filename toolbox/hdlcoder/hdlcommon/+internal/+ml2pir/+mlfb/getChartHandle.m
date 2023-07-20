function chartH=getChartHandle(blockPath)



    rt=sfroot;


    sfChartH=rt.find('-isa','Stateflow.Chart','Path',blockPath);
    emChartH=rt.find('-isa','Stateflow.EMChart','Path',blockPath);
    if isempty(sfChartH)&&isempty(emChartH)
        blockPath=correctForLibraries(blockPath);
        sfChartH=rt.find('-isa','Stateflow.Chart','Path',blockPath);
        emChartH=rt.find('-isa','Stateflow.EMChart','Path',blockPath);
    end

    chartH=[sfChartH,emChartH];
end

function blockPath=correctForLibraries(blockPath)

    [topLevel,~]=strtok(blockPath,'/');
    libraryInfo=libinfo(topLevel);





    blockPath=[blockPath,'/'];
    relevantLibInfos={};
    lengthOfMatchingBlockNames=[];




    for i=1:length(libraryInfo)
        if contains(blockPath,[libraryInfo(i).Block,'/'])
            relevantLibInfos{end+1}=libraryInfo(i);%#ok<AGROW>
            lengthOfMatchingBlockNames(end+1)=length(libraryInfo(i).Block);%#ok<AGROW>
        end
    end

    [~,ordering]=sort(lengthOfMatchingBlockNames,'descend');
    sortedBlockNamesCA=relevantLibInfos(ordering);


    for i=1:length(sortedBlockNamesCA)
        blockPath=strrep(blockPath,[sortedBlockNamesCA{i}.Block,'/'],[sortedBlockNamesCA{i}.ReferenceBlock,'/']);
    end


    if isequal(blockPath(end),'/')
        blockPath(end)=[];
    end
end



