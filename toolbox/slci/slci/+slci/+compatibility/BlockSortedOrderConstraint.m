


classdef BlockSortedOrderConstraint<slci.compatibility.Constraint


    properties(Access=private)
        fBlocksInvolved;


        fProcessedSortedOrders={};


        fProcessedBlocks=[];

    end

    methods

        function obj=BlockSortedOrderConstraint()
            obj.setEnum('BlockSortedOrder');
            obj.setFatal(false);
            obj.setCompileNeeded(true);
        end


        function out=getDescription(aObj)%#ok
            out='Block sorted list ordering should match graphically displayed sorted order.';
        end


        function out=check(this)
            out=[];
            rootSysHandle=this.ParentModel().getHandle();
            listOfSys=[rootSysHandle,this.getSubsystemHandles(rootSysHandle)];

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            isCorrectOrder=this.checkSortedOrder(listOfSys);

            if(~isCorrectOrder)

                out=slci.compatibility.Incompatibility(...
                this,...
                this.getEnum(),...
                this.ParentModel().getName());

                out.setObjectsInvolved(this.fBlocksInvolved);
            end
        end

    end


    methods(Access=private)


        function sysList=getSubsystemHandles(~,rootSysHandle)


            tSysList=find_system(rootSysHandle,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'AllBlocks','on',...
            'LookUnderMasks','all',...
            'FollowLinks',false,...
            'LookUnderReadProtectedSubsystems','on',...
            'Type','block',...
            'BlockType','SubSystem');
            sysList=[];
            for i=1:numel(tSysList)
                sysObj=get_param(tSysList(i),'Object');
                if strcmpi(slci.internal.getSubsystemType(sysObj),'Virtual')
                    continue;
                end
                sysList(end+1)=tSysList(i);%#ok
            end
        end


        function out=checkSortedOrder(this,listOfSys)
            out=true;
            for iSys=1:numel(listOfSys)
                sys=listOfSys(iSys);
                sysObj=get_param(sys,'Object');

                if strcmpi(sysObj.Type,'block')...
                    &&(strcmpi(slci.internal.getSubsystemType(sysObj),'Variant')...
                    ||slci.internal.isMatlabFunctionBlock(sysObj)...
                    ||slci.internal.isStateflowBasedBlock(sys)...
                    ||strcmpi(sysObj.IsSubsystemVirtual,'on'))

                    continue;
                end

                sortedBlkList=sysObj.SortedList();
                nElements=numel(sortedBlkList);
                if(nElements>1)
                    sysOut=true;
                    i=1;
                    startIndex=i;
                    while(startIndex<nElements)
                        [currBlk,i]=this.getBlock(sortedBlkList,startIndex);

                        if isempty(currBlk)||(i==nElements)

                            break;
                        end

                        [nextBlk,j]=this.getBlock(sortedBlkList,i+1);

                        if isempty(nextBlk)

                            break;
                        end


                        [tf,isPartial]=this.compareSortedOrder(currBlk,nextBlk);

                        if~tf
                            this.fBlocksInvolved{end+1}=Simulink.ID.getSID(nextBlk);
                        end
                        sysOut=sysOut&&tf;

                        if isPartial
                            this.fProcessedBlocks(end+1)=nextBlk;
                        else
                            startIndex=j;
                            this.fProcessedBlocks(end+1)=currBlk;
                            this.fProcessedBlocks(end+1)=nextBlk;
                        end

                    end

                    out=out&&sysOut;

                end

            end

        end





        function out=parseSortedOrderString(~,aStr)

            pat='(?<taskindex>\w+)[()](?<subsystem>\d+)[:](?<block>\d+|[G])(?<kind>\{?\[?)(?<index>\d*)\}?\]?';
            aMatch=regexp(aStr,pat,'names');



            out=aMatch;
        end


        function[blkH,index]=getBlock(this,aSortedBlkList,aStart)
            nElements=numel(aSortedBlkList);
            blkH=[];
            index=[];

            i=aStart;
            while(i<=nElements)
                aBlk=aSortedBlkList(i);
                sortedOrderDispStr=strtrim(get_param(aBlk,'SortedOrderDisplay'));
                if isempty(sortedOrderDispStr)...
                    ||(sortedOrderDispStr(1)=='F')...
                    ||(sortedOrderDispStr(1)=='E')...
                    ||(this.isVisited(aBlk))
                    i=i+1;
                else
                    blkH=aBlk;
                    index=i;
                    break;
                end
            end
        end


        function[tf,isPartial]=compareSortedOrder(this,blkH1,blkH2)
            sortedOrder1=strtrim(get_param(blkH1,'SortedOrderDisplay'));
            sortedOrder2=strtrim(get_param(blkH2,'SortedOrderDisplay'));



            s=this.parseSortedOrderString(sortedOrder1);


            t=this.parseSortedOrderString(sortedOrder2);

            nElements1=numel(s);
            nElements2=numel(t);

            isPartial=false;





            sampleTime1=get_param(blkH1,'CompiledSampleTime');
            sampleTime2=get_param(blkH2,'CompiledSampleTime');
            if~iscell(sampleTime1)
                blkSampleTime1=slci.internal.SampleTime(sampleTime1);
                if(blkSampleTime1.isParameter()||blkSampleTime1.isConstant())
                    if iscell(sampleTime2)
                        tf=true;
                        return;
                    end
                    blkSampleTime2=slci.internal.SampleTime(sampleTime2);
                    if~(blkSampleTime2.isParameter()||blkSampleTime2.isConstant())
                        tf=true;
                        return;
                    end
                end
            end




            if(nElements1==0)||(nElements2==0)
                tf=false;
            elseif(nElements1==1)&&(nElements2==1)
                tf=this.compareOneToOne(s,t);
            elseif(nElements1>1)&&(nElements2==1)
                tf=this.compareManyToOne(s,t);
            elseif(nElements1==1)&&(nElements2>1)
                tf=this.compareOneToMany(s,t);



                isPartial=true;
            else

                tf=this.compareManyToMany(s,t);
            end

            if~tf
                tf=this.hasFasterSampleTime(s,t);
            end


            for i=1:nElements1
                this.addProcessed(s(i));
            end

            for i=1:nElements2
                this.addProcessed(t(i));
            end


            this.fProcessedSortedOrders=unique(this.fProcessedSortedOrders);

        end


        function tf=compareOneToOne(~,s,t)
            if(str2double(s.subsystem)==str2double(t.subsystem))
                if(strcmpi(s.block,'G')...
                    ||strcmpi(t.block,'G'))
                    tf=true;
                elseif(str2double(s.block)<=str2double(t.block))

                    tf=true;
                elseif(str2double(s.taskindex)~=str2double(t.taskindex))
                    tf=true;
                else
                    tf=false;
                end
            elseif(str2double(s.subsystem)<str2double(t.subsystem))
                tf=true;
            else
                tf=false;
            end
        end


        function tf=compareManyToOne(this,s,t)
            tf=true;
            for i=1:numel(s)
                if strcmpi(s(i).taskindex,t.taskindex)
                    tf=tf&this.compareOneToOne(s(i),t);
                    if tf
                        break;
                    end
                end
            end
        end





        function tf=compareOneToMany(this,s,t)
            res=true;

            nElements=numel(t);

            for i=1:nElements
                if strcmpi(s.taskindex,t(i).taskindex)
                    res=res...
                    &(this.isProcessed(t(i))...
                    ||strcmpi(this.toSortedOrderString(t(i)),this.toSortedOrderString(s))...
                    ||this.compareOneToOne(s,t(i)));
                    if~res
                        break;
                    end
                end
            end

            tf=res;
        end


        function tf=compareManyToMany(this,s,t)
            nElementS=numel(s);
            nElementT=numel(t);

            tf=true;

            if(nElementS<=nElementT)
                nElement=nElementS;
            else
                nElement=nElementT;
            end


            for i=1:nElement
                if(strcmpi(s(i).taskindex,t(i).taskindex))
                    if(str2double(s(i).subsystem)==str2double(t(i).subsystem))
                        tf=tf&this.compareOneToOne(s(i),t(i));
                        if tf
                            break;
                        end
                    end
                end
            end
        end


        function out=isProcessed(this,aSortedOrder)
            str=this.toSortedOrderString(aSortedOrder);
            out=any(cellfun(@(x)(strcmpi(x,str)),this.fProcessedSortedOrders));
        end


        function addProcessed(this,aSortedOrder)
            this.fProcessedSortedOrders{end+1}=this.toSortedOrderString(aSortedOrder);
        end


        function str=toSortedOrderString(~,s)
            str=strcat(s.subsystem,':',s.block,':',s.index);
        end


        function out=isVisited(this,aBlk)
            out=any(this.fProcessedBlocks==aBlk);
        end


        function tf=hasFasterSampleTime(this,first,second)
            tf=false;

            minFirst=min(arrayfun(@(x)(x.taskindex),first));
            minSecond=min(arrayfun(@(x)(x.taskindex),second));

            if(minFirst<minSecond)
                tf=true;
            end
        end
    end
end
