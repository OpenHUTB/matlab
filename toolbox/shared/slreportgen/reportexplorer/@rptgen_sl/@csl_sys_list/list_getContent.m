function systemList=list_getContent(this,d,varargin)






    currentSystem=locGetCurrentSystemHandle(this);

    if isempty(currentSystem)
        systemList={};

    else
        psSL=rptgen_sl.propsrc_sl();


        ancestorList=locCreateAncenstorList(currentSystem,this.ParentDepth,d,psSL);


        descendentList=locCreateDescendentList(currentSystem,this.ChildDepth,d,psSL);


        [siblingList,siblingIndex]=locCreateSiblingList(currentSystem,this.isPeers,d,psSL);


        if this.HighlightStartSys
            siblingList{siblingIndex}=createElement(d,...
            'emphasis',siblingList{siblingIndex});
        end


        ancestorSubList=[...
        siblingList(1:siblingIndex-1)...
        ,siblingList(siblingIndex),{descendentList}...
        ,siblingList(siblingIndex+1:end)...
        ];


        ancestorSubList=ancestorSubList(~cellfun('isempty',ancestorSubList));


        systemList=[ancestorList,ancestorSubList];


        systemList=systemList(~cellfun('isempty',systemList));
    end


    function currentSystemHandle=locGetCurrentSystemHandle(this)

        adSL=rptgen_sl.appdata_sl;
        if strcmp(this.StartSys,'fromloop')
            currentSystem=adSL.CurrentSystem;
        else
            currentSystem=adSL.CurrentModel;
        end

        try
            currentSystemHandle=get_param(currentSystem,'Handle');
        catch ME
            this.status(sprintf(getString(message('RptgenSL:rsl_csl_sys_list:invalidCurrentSystemLabel')),ME.message),2);
            currentSystemHandle=[];
        end


        function ancenstorList=locCreateAncenstorList(system,parentDepth,d,psSL)

            parentSystem=locGetParentHandle(system);
            ancenstorList={};


            while(~isempty(parentSystem)&&(parentDepth~=0))
                if~isempty(ancenstorList)

                    ancenstorList={...
                    makeTreeNode(parentSystem,d,psSL),...
ancenstorList...
                    };%#ok - no way of knowing how many parents before hand
                else

                    ancenstorList={makeTreeNode(parentSystem,d,psSL)};
                end
                parentSystem=locGetParentHandle(system);
                parentDepth=parentDepth-1;
            end


            function descendentList=locCreateDescendentList(system,depth,d,psSL)

                descendentList=cell(1,0);
                if(~isempty(system)&&(depth>0))

                    depth=depth-1;

                    systemChildren=locGetSystemChildren(system);
                    systemChildren=systemChildren(systemChildren~=system);
                    systemChildren=rptgen_sl.filterNonReportableSystem(systemChildren);
                    numChildren=length(systemChildren);

                    descendentList=cell(1,2*numChildren);
                    for i=1:numChildren

                        descendentList{2*i-1}=makeTreeNode(systemChildren(i),d,psSL);


                        descendentList{2*i}=locCreateDescendentList(systemChildren(i),depth,d,psSL);
                    end


                    descendentList=descendentList(~cellfun('isempty',descendentList));
                end


                function[siblingList,siblingIndex]=locCreateSiblingList(system,isPeers,d,psSL)

                    parentSystem=locGetParentHandle(system);
                    if(~isPeers||isempty(parentSystem))
                        siblings=system;
                        siblingIndex=1;
                    else
                        siblings=locGetSystemChildren(parentSystem);
                        siblingIndex=find(siblings==system);
                    end

                    nSiblings=length(siblings);
                    siblingList=cell(1,nSiblings);
                    for i=1:nSiblings
                        siblingList{i}=makeTreeNode(siblings(i),d,psSL);
                    end


                    function systemChildren=locGetSystemChildren(system)

                        systemChildren=find_system(system,...
                        'SearchDepth',1,...
                        'FollowLinks','on',...
                        'LookUnderMasks','all',...
                        'BlockType','SubSystem',...
                        'MaskType','');

                        mdlref=find_system(system,...
                        'SearchDepth',1,...
                        'BlockType','ModelReference');

                        systemChildren=[systemChildren;mdlref];

                        if(length(systemChildren)>1)
                            [~,idx]=sort(get_param(systemChildren,'Name'));
                            systemChildren=systemChildren(idx);
                        end


                        function parentHandle=locGetParentHandle(system)

                            parent=get_param(system,'Parent');
                            parentHandle=[];
                            if~isempty(parent)
                                parentHandle=get_param(parent,'Handle');
                            end


                            function treeNode=makeTreeNode(obj,d,psSL)
                                treeNode=psSL.makeLinkScalar(obj,'','link',d);
