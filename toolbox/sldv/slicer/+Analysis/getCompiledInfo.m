function[CECTree,SortedLists,refMdlToMdlBlk]=getCompiledInfo(mdlname)







    rootsys=get_param(mdlname,'Object');
    blist=rootsys.getSortedList;

    queue=[];

    refMdlToMdlBlk=containers.Map('KeyType','double','ValueType','double');


    SortedLists=struct('SortedList',{});
    CECTree=struct('cecHandle',{});

    CECTree(1)=struct('cecHandle',rootsys.Handle);
    newBlist=processBlockList(blist);
    SortedLists(1)=struct('SortedList',newBlist);


    while~isempty(queue)
        h=dequeue();


        if refMdlToMdlBlk.isKey(h)
            CECTree(end+1)=struct('cecHandle',refMdlToMdlBlk(h));%#ok<AGROW>
        else
            CECTree(end+1)=struct('cecHandle',h);%#ok<AGROW>
        end

        obj=get(h,'Object');
        blist=obj.getSortedList;
        newBlist=processBlockList(blist);
        SortedLists(end+1)=struct('SortedList',newBlist);%#ok<AGROW>
    end

    function newBList=processBlockList(blist)
        addBlist=[];
        removeBlist=false(numel(blist),1);
        for i=1:length(blist)
            bt=get(blist(i),'BlockType');
            if strcmpi(bt,'Subsystem')
                o=get(blist(i),'Object');


                if o.isSynthesized&&~isempty(strfind(o.Name,'Alg_Loop'))


                    removeBlist(i)=true;
                    addBlist=[addBlist;o.getSortedList];%#ok<AGROW>
                else
                    enqueue(blist(i));
                end
            elseif strcmpi(bt,'ModelReference')&&...
                strcmpi(get(blist(i),'SimulationMode'),'Normal')
                refmdlName=get(blist(i),'NormalModeModelName');
                refMdlH=get_param(refmdlName,'Handle');
                o=get(blist(i),'Object');
                if~o.isSynthesized
                    mdlBlkH=blist(i);
                else




                    mdlBlkH=get_param(o.getCompiledParent,'Handle');
                    if strcmp(get_param(mdlBlkH,'virtual'),'on')



                        mdlBlkH=blist(i);
                    end
                end
                if refMdlToMdlBlk.isKey(refMdlH)

                    error(message('Sldv:se:MultiMdlrefNotSupported'));
                else
                    enqueue(refMdlH);
                    refMdlToMdlBlk(refMdlH)=mdlBlkH;
                end
            end
        end

        newBList=[blist(~removeBlist);addBlist];
    end


    function enqueue(h)
        if~any(queue==h)
            queue=[queue,h];
        end
    end

    function h=dequeue()
        h=queue(1);
        queue=queue(2:end);
    end

end
