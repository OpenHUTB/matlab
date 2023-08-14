function result=dsmElimDispCandidate(m2m_obj,model,freeze)



    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft,{DAStudio.message('sl_pir_cpp:creator:DSMCandidate')});

    hasCand=false;
    for mIdx=1:length(m2m_obj.fCandidateIndex)
        if m2m_obj.hasIdentifiedCandidates
            hasCand=true;
            setSubTitle(ft,{DAStudio.message('sl_pir_cpp:creator:DSMCandidate')});
            break
        end
    end
    if~hasCand
        setSubTitle(ft,{DAStudio.message('sl_pir_cpp:creator:NoDSMElimCandidate')});
    else
        ft.setColTitles({'','Data store memory block','Data store access blocks','Sorted execution order'});
        for ii=1:length(m2m_obj.fDefaultCandIndex)
            curr=checkCandidateIsIncluded(m2m_obj.fDefaultCandIndex(ii),m2m_obj.fFinalCandidateIndex);
            operation=insertCheckboxHtml(model,'dsm',curr,ii,m2m_obj.fDefaultCandIndex(ii),freeze);
            blockList=m2m_obj.fByNameList{m2m_obj.fDefaultCandIndex(ii)};
            if strcmp(get_param(blockList(1),'blocktype'),'DataStoreMemory')
                blockPath=getfullname(blockList(1));
                ft.addRow({operation,blockPath,'',''});
                blockList(1)=[];
            end
            for jj=1:length(blockList)
                blockPath=getfullname(blockList(1));
                sortedOrderStr=getGlobalSortedOrder(blockPath);
                ft.addRow({'','',blockPath,sortedOrderStr});
                blockList(1)=[];
            end
        end
    end
    result=ft;
end

function reasonStr=genReasonStr(reasonInteger)










    switch reasonInteger
    case 1
        reasonStr='cross function call subsystem, iterator subsystem or enabled subsystem boundary';
    case 2
        reasonStr='have at least one data store write block falling into an If Action Subsystem whose control block connects to a terminator block';
    case 3
        reasonStr='is global data store';
    case 4
        reasonStr='has stateflow access';
    case 5
        reasonStr='have different execution rate';
    case 6
        reasonStr='have been used in variants';
    case 7
        reasonStr='have at least one multi-port access block';
    case 8
        reasonStr='have at least one partial array access block';
    case 9
        reasonStr='have different relative sorted execution orders than other instances of the same library';
    otherwise
        reasonStr='';
    end

end

function result=checkCandidateIsIncluded(idx,finalCandIdx)
    result=false;
    for i=1:length(finalCandIdx)
        if~isempty(find(finalCandIdx{i}==idx))
            result=true;
        end
    end
end

function str=getGlobalSortedOrder(blockPath)
    str='';
    if strcmp(bdroot(blockPath),get_param(blockPath,'parent'))
        str=get_param(blockPath,'SortedOrderDisplay');
    else
        while~strcmp(bdroot(blockPath),get_param(blockPath,'parent'))
            str=[':',str];
            s=get_param(blockPath,'SortedOrderDisplay');
            idx=find(s==':');
            s(1:idx)=[];
            str=[s,str];
            blockPath=get_param(blockPath,'parent');
        end
        str=[get_param(blockPath,'SortedOrderDisplay'),':',str];
        str(end)=[];
    end

end
