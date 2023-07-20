function result=blockTable(obj,method,varargin)






    if strcmp(method,'clear')
        set_param(obj,'reqMAdvTable',[]);
        result=true;
        return;
    end



    modelH=rmisl.getmodelh(obj);
    hBlocks=get_param(modelH,'reqMAdvTable');
    switch(lower(method))
    case 'get'
        if isempty(hBlocks)
            hBlocks=allHandlesWithReqLinks(modelH,varargin{:});
            set_param(modelH,'reqMAdvTable',hBlocks);
        end
        result=filterBlocks(modelH,obj,hBlocks,varargin{:});
    case 'idx'
        if isempty(hBlocks)
            errordlg(...
            getString(message('Slvnv:rmisl:blockTable:StaleTableNeedsRerun')),...
            getString(message('Slvnv:rmisl:blockTable:RequirementsStaleBlockTable')),'modal');
        end



        result=find(hBlocks==varargin{1});
    case 'handle'
        if isempty(hBlocks)
            errordlg(...
            getString(message('Slvnv:rmisl:blockTable:StaleTableNeedsRerun')),...
            getString(message('Slvnv:rmisl:blockTable:RequirementsStaleBlockTable')),'modal');
        end

        result=hBlocks(varargin{1});
    end
end

function filteredBlocks=filterBlocks(modelH,obj,hBlocks,varargin)
    persistent isRecall
    if isempty(isRecall)
        isRecall=false;
    end
    filteredBlocks=[];
    modelPath=get_param(modelH,'Name');
    objName=getfullname(obj);
    for i=1:length(hBlocks)
        blockH=hBlocks(i);
        try
            if floor(blockH)==blockH
                if(sf('get',blockH,'.isa')==1)
                    chart=blockH;
                else
                    chart=sf('get',blockH,'.chart');
                end
                chartName=sf('get',chart,'.name');
                blockPath=[modelPath,'/',chartName];
            else
                blockPath=getfullname(blockH);
            end
        catch mexception
            if strcmp(mexception.identifier,'Simulink:Commands:InvSimulinkObjHandle')





                if isRecall
                    isRecall=false;
                    rethrow(mexception);
                else
                    isRecall=true;%#ok<NASGU>
                    set_param(modelH,'reqMAdvTable',[]);
                    filteredBlocks=rmisl.blockTable(obj,'get',varargin{:});
                    isRecall=false;
                    return;
                end
            else
                rethrow(mexception);
            end
        end
        if~isempty(strfind(blockPath,objName))
            filteredBlocks=[filteredBlocks,blockH];%#ok
        end
    end
    isRecall=false;
end

function handles=allHandlesWithReqLinks(modelH,includeLibRefs)
    handles=rmi('getobjwithreqs',modelH,[]);
    if nargin==1
        includeLibRefs=false;
    end
    if includeLibRefs




        filters=[];


        refHandles=find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','type','block','StaticLinkStatus','resolved');
        if isempty(refHandles)
            return;
        end
        allRefBlocks=get(refHandles,'Object');
        if iscell(allRefBlocks)
            allRefBlocks=[allRefBlocks{:}]';
        end
        for i=1:length(refHandles)
            refBlockPath=allRefBlocks(i).ReferenceBlock;
            libName=strtok(refBlockPath,'/');
            if rmiut.isBuiltinNoRmi(libName)
                continue;
            end
            if~any(handles==refHandles(i))&&rmi.objHasReqs(refBlockPath,filters)
                handles=[handles;refHandles(i)];%#ok<AGROW>
            end
            myImplicitBlocks=find(allRefBlocks(i),'-isa','Simulink.Block','-and','StaticLinkStatus','implicit');%#ok<GTARG>
            implicitBlockHandles=get(myImplicitBlocks,'Handle');
            if iscell(implicitBlockHandles)
                implicitBlockHandles=cell2mat(implicitBlockHandles);
            end
            for j=1:length(implicitBlockHandles)
                if rmi.objHasReqs(myImplicitBlocks(j).ReferenceBlock,filters)
                    handles=[handles;implicitBlockHandles(j)];%#ok<AGROW>
                end
            end
        end
    end
end
