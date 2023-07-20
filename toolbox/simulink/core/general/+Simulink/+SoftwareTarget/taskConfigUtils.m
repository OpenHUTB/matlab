function ret=taskConfigUtils(varargin)




    ret=[];
    assert(nargin>0);

    switch varargin{1}

    case 'CreateTaskConfigurationAndGetMEObject'
        assert(nargin==2);
        bd=varargin{2};
        activeCS=getActiveConfigSet(bd);
        if isa(activeCS,'Simulink.ConfigSetRef')




            try
                activeCS=activeCS.getRefConfigSet;
            catch me
                activeCS=getActiveConfigSet(0);
            end
        end
        newCS=activeCS.copy;
        Simulink.SoftwareTarget.checkSetDeploymentConfigSet(newCS,'set','model');
        attachConfigSet(bd,newCS,1);
        extendConfigurationSet(newCS,false);
        ret=newCS;

    case 'EnableAddTaskConfiguration'
        assert(nargin==2);
        ret=enableAddTaskConfiguration(varargin{2});

    case 'ContainsTaskConfiguration'
        assert(nargin==2);
        ret=containsTaskConfiguration(varargin{2});

    case 'ExtendConfigSet'
        assert(nargin==2);
        extendConfigurationSet(varargin{2},false);

    case 'ExtendSelectedTreeConfigSet'
        assert(nargin==1);
        me=daexplr;
        im=DAStudio.imExplorer(me);
        extendSelectedConfigSet(im,im.getCurrentTreeNode,true);

    case 'CheckValidExpression'
        assert(nargin==3)
        str=varargin{2};
        pattern=varargin{3};
        ret=checkRegularExpression(str,pattern);

    case 'ExtendSelectedListConfigSet'
        assert(nargin==1);
        me=daexplr;
        im=DAStudio.imExplorer(me);
        extendSelectedConfigSet(im,im.getSelectedListNodes,true);

    case 'GetTaskConfigForMulticore'
        assert(nargin==2);
        bd=varargin{2};
        ret=getTaskConfigurationForMulticoreMapping(bd);
    case 'PrettyPrintDouble'
        assert(nargin==2);
        dblVal=varargin{2};
        ret=PrettyPrintDouble(dblVal);

    otherwise
        assert(false,'Invalid argument passed to taskConfigUtils');
    end

    function extendSelectedConfigSet(im,csObj,isToggle)

        extendConfigurationSet(csObj,isToggle);
        im.selectListViewNode(csObj.Components(1));
        if~isempty(im.getDialogHandle)
            im.getDialogHandle.refresh;
        end

        function ret=extendConfigurationSet(csObj,isToggle)

            assert(isa(csObj,'Simulink.ConfigSetRoot'));
            ret=showHideConcurrentExecution(csObj,isToggle);








            function ret=showHideConcurrentExecution(cs,isToggle)

                ret=[];


                if isa(cs,'Simulink.ConfigSetRef')
                    return;
                end
                if(isToggle)
                    if(strcmp(get_param(cs,'ConcurrentTasks'),'off'))
                        set_param(cs,'ConcurrentTasks','on');
                    else
                        set_param(cs,'ConcurrentTasks','off');
                    end
                else
                    set_param(cs,'EnableConcurrentExecution','on');
                    set_param(cs,'ConcurrentTasks','on');


                end

                ret=cs.Components(1);


                function ret=enableAddTaskConfiguration(obj)

                    isCS=isa(obj,'Simulink.ConfigSetRoot');
                    isCSR=isa(obj,'Simulink.ConfigSetRef');
                    isBD=isa(obj,'Simulink.BlockDiagram');

                    assert(isCS||isBD);

                    if isBD
                        ret=true;
                    else
                        if(~isCSR&&...
                            strcmp(obj.get_param('ConcurrentTasks'),'on'))
                            ret=false;
                        else
                            ret=true;
                        end

                    end

                    function ret=containsTaskConfiguration(csObj)

                        assert(isa(csObj,'Simulink.ConfigSetRoot'));

                        ret=~isempty(csObj.concurrentExecutionComponents);

                        function ret=checkRegularExpression(str,pattern)
                            res=regexp(str,pattern);

                            ok1=~isempty(res)&&isscalar(res)&&(res==1);


                            res=regexp(str,pattern,'end');
                            ok2=~isempty(res)&&isscalar(res)&&(res==length(str));

                            ret=ok1&&ok2;

                            function tc=getTaskConfigurationForMulticoreMapping(bd)
                                mapMgr=get_param(bd,'MappingManager');
                                dtms=mapMgr.getMappingsFor('DistributedTarget');
                                tc=[];
                                if~isempty(dtms)
                                    acm=mapMgr.getActiveMappingFor('DistributedTarget');
                                    nodes=acm.Architecture.Nodes;
                                    for i=1:length(nodes)
                                        if(isa(nodes(i),'Simulink.DistributedTarget.SoftwareNode'))
                                            tc=nodes(i).TaskConfiguration;
                                            break;
                                        end
                                    end
                                end


                                function retVal=PrettyPrintDouble(val)







                                    [num,den]=rat(val);
                                    numStr=sprintf('%d',num);
                                    denStr=sprintf('%d',den);

                                    ratioStr=sprintf('%d/%d',num,den);


                                    len=1;

                                    while(len<=17)
                                        formatStr=sprintf('%s%dg','%.',len);
                                        floatStr=sprintf(formatStr,val);
                                        floatVal=str2double(floatStr);
                                        if abs(floatVal-val)<=eps*abs(val)
                                            break;
                                        end
                                        len=len+1;
                                    end

                                    if length(ratioStr)<length(floatStr)&&...
                                        ~contains(ratioStr,'e')&&...
                                        den~=1
                                        retVal=ratioStr;
                                    else
                                        retVal=floatStr;
                                    end
