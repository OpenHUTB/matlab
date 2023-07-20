function hList=loop_getLoopObjects(this,varargin)








    if builtin('_license_checkout','Simulink_Requirements','quiet')
        hList={};
        return;
    end



    hList=getLoopBlocks(this);

    adSL=rptgen_sl.appdata_sl;




    includeAll=false;
    includeSigbuilders=false;
    if~isempty(varargin)
        if strcmp(varargin(1),'include_all')
            includeAll=true;
        elseif strcmp(varargin(1),'include_signal_builders')
            includeSigbuilders=true;
        end
    end


    reportedLibSubsystems={};
    if~includeAll



        allSubsystems=adSL.ReportedSystemList;
        isLibRef=false(size(allSubsystems));
        for i=2:length(allSubsystems)
            if strcmp(get_param(allSubsystems{i},'StaticLinkStatus'),'resolved')
                isLibRef(i)=true;
            end
        end
        if any(isLibRef)
            reportedLibSubsystems=allSubsystems(isLibRef);
            allSubsystems(isLibRef)=[];
        end
        [~,idx]=setdiff(hList,allSubsystems);
        hList=hList(sort(idx));
    end

    hList=hList(:);


    anList={};
    if~isempty(adSL.CurrentModel)&&strcmp(get_param(adSL.CurrentModel,'hasReqInfo'),'off')
        anObjs=find(get_param(adSL.CurrentSystem,'Object'),'-isa','Simulink.Annotation','-depth',1);%#ok<GTARG>
        if~isempty(anObjs)
            anNames=get(anObjs,'Name');
            if ischar(anNames)
                anNames={anNames};
            end
            anNamesEscaped=strrep(anNames,'/','//');
            anList=strcat([adSL.CurrentSystem,'/'],anNamesEscaped);
            hList=[anList;hList];
        end
    end




    keepIdx=true(length(hList),1);
    filters=rmi.settings_mgr('get','filterSettings');
    for idx=1:length(hList)
        item=hList{idx};

        if idx<=length(anList)
            isAnnotation=true;
            itemH=anObjs(idx).Handle;
            isSf=false;
        else
            isAnnotation=false;
            [isSf,itemH]=rmi.resolveobj(item);
        end
        if~rmi('hasrequirements',itemH,filters)



            if~includeAll&&any(strcmp(item,reportedLibSubsystems))
                keepIdx(idx)=false;

            elseif rmidata.isExternal(strtok(hList{1},'/'))&&~isSf&&...
                ~isAnnotation&&slprivate('is_stateflow_based_block',item)


                sid=Simulink.ID.getSID(itemH);
                keepIdx(idx)=rmiml.hasLinks(sid);
            else

                keepIdx(idx)=false;
            end
            continue
        end


        if~includeSigbuilders&&~includeAll&&rmisl.is_signal_builder_block(item)
            keepIdx(idx)=false;
        end
    end
    hList=hList(keepIdx);
end

