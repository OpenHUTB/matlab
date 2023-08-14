function out=execute(this,d,varargin)







    out=[];
    adSL=rptgen_sl.appdata_sl;
    currContext=getContextType(adSL,this,false);
    switch lower(currContext)
    case 'model'
        startSys=adSL.CurrentModel;
        followNonVirtual=true;


    case 'system'
        startSys=adSL.CurrentSystem;
        followNonVirtual=false;
    otherwise
        this.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_sort_list:componentRequiresModelOrSystemLabel')),this.getName),2);
        return;
    end

    if isempty(startSys)
        this.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_sort_list:noCurrentModelForBlockLabel')),currContext),2);
        return;

    elseif strcmp(get_param(startSys,'SystemType'),'Virtual')
        this.status(sprintf(getString(message('RptgenSL:rsl_csl_blk_sort_list:componentRequiresConcreteSystemLabel')),this.getName),3);
        return;
    end

    if strcmp(this.FollowNonVirtual,'on')
        followNonVirtual=true;
    elseif strcmp(this.FollowNonVirtual,'off')
        followNonVirtual=false;
    end


    listItems=locSortBlocks(...
    startSys,...
    followNonVirtual,...
    this.isBlockType,...
    d,...
    rptgen_sl.propsrc_sl_sys);

    if isempty(listItems)
        this.status(getString(message('RptgenSL:rsl_csl_blk_sort_list:sortedListNotFound')),2);
        return;
    end

    if rptgen.use_java
        lm=com.mathworks.toolbox.rptgencore.docbook.ListMaker(listItems);
    else
        lm=mlreportgen.re.internal.db.ListMaker(listItems);
    end

    if strcmp(this.ListTitleMode,'auto')
        lTitle=getString(message('RptgenSL:rsl_csl_blk_sort_list:sortedListForLabel',startSys));
    else
        lTitle=rptgen.parseExpressionText(this.ListTitle);
    end

    lm.setTitle(lTitle);



    setListStyleName(lm,'"rgBlockExecOrderList"');
    setTitleStyleName(lm,'"rgBlockExecOrderListTitle"');

    out=createList(lm,d.Document);


    function listItems=locSortBlocks(sysName,isFollowNV,isBlockType,d,psSL)


        try
            bList=rptgen_sl.getSystemBlockSortedList(sysName);
        catch me %#ok
            bList=[];
        end


        if isempty(bList)
            listItems=[];
            return
        end

        bCount=length(bList);
        if(bCount>0)
            if rptgen.use_java
                listItems=javaArray('java.lang.Object',bCount);
            else
                listItems=cell(1,bCount);
            end
            bType=rptgen.safeGet(bList,'BlockType','get_param');
            sysIdx=find(strcmp(bType,'SubSystem'));

            itemIndex=1;
            for i=1:length(bList)
                if~isempty(sysIdx)&&any(sysIdx==i)
                    isSys=1;
                    oType='System';
                else
                    isSys=0;
                    oType='Block';
                end
                if isBlockType&&~isSys
                    btInfo={sprintf(' (%s)',bType{i})};
                else
                    btInfo={};
                end

                blkLinked=psSL.makeLink(bList(i),oType,'link',d);
                if isSys
                    blkLinked=createElement(d,'emphasis',blkLinked);
                end

                if rptgen.use_java
                    listItems(itemIndex)=createElement(d,...
                    'para',...
                    blkLinked,...
                    btInfo{:});
                else
                    listItems{itemIndex}=createElement(d,...
                    'para',...
                    blkLinked,...
                    btInfo{:});
                end
                if(isSys&&isFollowNV)
                    subItems=locSortBlocks(...
                    bList(i),...
                    isFollowNV,...
                    isBlockType,...
                    d,...
                    psSL);
                    if~isempty(subItems)
                        itemIndex=itemIndex+1;
                        if rptgen.use_java
                            listItems(itemIndex)=subItems;
                        else
                            listItems{itemIndex}=subItems{1};
                        end
                    end
                end
                itemIndex=itemIndex+1;
            end
        else
            listItems=[];
        end

