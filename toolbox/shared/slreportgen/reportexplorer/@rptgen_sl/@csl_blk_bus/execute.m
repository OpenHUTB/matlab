function out=execute(c,d,varargin)




    busList=findContextBlocks(rptgen_sl.appdata_sl,'BlockType','\<BusSelector\>');

    if c.isHierarchy&&length(busList)>1
        busList=LocFindRootBusses(busList);
    end

    out=createDocumentFragment(d);

    anchorTypes={'link','anchor'};

    for i=length(busList):-1:1
        listCells=LocMakeList(busList(i),...
        c.isHierarchy,...
        anchorTypes{c.BusAnchor+1},...
        anchorTypes{c.SignalAnchor+1},...
        d);

        if rptgen.use_java
            m=com.mathworks.toolbox.rptgencore.docbook.ListMaker(listCells);
        else
            m=mlreportgen.re.internal.db.ListMaker(listCells);
        end

        setTitle(m,rptgen.parseExpressionText(c.ListTitle));

        if rptgen.use_java
            myList=m.createList(java(d));
        else
            myList=createList(m,d.Document);
        end
        if~isempty(myList)
            out.appendChild(myList);
        end
    end


    function out=LocMakeList(busBlocks,...
        isHierarchy,...
        BusAnchor,...
        SignalAnchor,...
        d)

        psSL=rptgen_sl.propsrc_sl;

        out={};
        for i=1:length(busBlocks)
            if iscell(busBlocks)
                currObj=busBlocks{i};
            else
                currObj=busBlocks(i);
            end

            out{end+1}=createElement(d,...
            'emphasis',...
            psSL.makeLink(currObj,'Block',BusAnchor,d));%#ok<AGROW>

            kids={};
            allPorts=get_param(currObj,'PortHandles');
            sigList=allPorts.Outport(:);
            for i=1:length(sigList)
                kids{end+1}=createElement(d,...
                'para',...
                psSL.makeLink(sigList(i),'Signal',SignalAnchor,d));

                if isHierarchy
                    childBusses=LocChildBusses(sigList(i));
                    connectedBusses=LocMakeList(childBusses,...
                    isHierarchy,...
                    BusAnchor,...
                    SignalAnchor,...
                    d);
                    if~isempty(connectedBusses)
                        kids{end+1}=connectedBusses;%#ok<AGROW>
                    end
                end
            end
            if~isempty(kids)
                out{end+1}=kids;%#ok<AGROW>
            end
        end


        function rootList=LocFindRootBusses(busList)

            rootList={};

            for i=1:length(busList)
                try
                    allPorts=get_param(busList{i},'PortHandles');
                    inPort=allPorts.Inport(:);
                catch
                    inPort=[];
                end

                isRoot=1;
                if length(inPort)==1&&ishandle(inPort)
                    try
                        lineHandle=get_param(inPort,'Line');
                    catch
                        lineHandle=-1;
                    end

                    srcBlock=[];
                    if ishandle(lineHandle)
                        srcBlock=get_param(lineHandle,'SrcBlockHandle');
                    end

                    if length(srcBlock)==1&&ishandle(srcBlock)
                        isRoot=~strcmp(get_param(srcBlock,'BlockType'),'BusSelector');
                    end
                end

                if isRoot
                    rootList{end+1}=busList{i};%#ok<AGROW>
                end
            end


            function bList=LocChildBusses(currSig)

                bHandles=[];
                if~isempty(currSig)
                    try
                        lineHandle=get_param(currSig,'Line');
                    catch
                        lineHandle=-1;
                    end

                    if ishandle(lineHandle)
                        try %#ok<TRYNC>
                            bHandles=get_param(lineHandle,'DstBlockHandle');
                            bHandles=bHandles(ishandle(bHandles));
                        end
                    end
                end

                bList=find_system(bHandles,...
                'SearchDepth',0,...
                'BlockType','BusSelector');
