


classdef FirstInitICPropagationConstraint<slci.compatibility.Constraint

    properties

        fDestMap;
    end

    methods

        function out=getDescription(aObj)%#ok
            out=['Propagation of initial condition during first time initialization is not supported. '...
            ,'This checks runs on Signal Conversion, Mux, Demux, Bus Creator and Bus Selector blocks '];
        end

        function obj=FirstInitICPropagationConstraint()
            obj.setEnum('FirstInitICPropagation');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.fDestMap=containers.Map('KeyType','Double','ValueType','any');
        end

        function out=check(aObj)

            out=[];
        end

        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id='FirstInitICPropagationConstraint';
            if status
                status='Pass';
            else
                status='Warn';
            end
            StatusText=DAStudio.message(['Slci:compatibility:',id,status]);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
            RecAction=aObj.prepareRecAction();
        end

    end

    methods(Static)


        function[flag,dsts]=propagatesInFirstInit(blkH)

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

            processedBlks=[];
            [flag,dsts]=...
            slci.compatibility.FirstInitICPropagationConstraint.propagates(...
            blkH,...
            processedBlks);

        end


    end

    methods(Static=true,Access=private)





        function[flag,dsts]=propagates(blkH,processedBlks)

            flag=false;
            dsts=[];

            if isempty(find(processedBlks==blkH,1))

                processedBlks(end+1)=blkH;

                if strcmpi(get_param(blkH,'Virtual'),'on')


                    portHandles=get_param(blkH,'PortHandles');
                    outports=portHandles.Outport;
                    for k=1:numel(outports)
                        portObj=get_param(outports(k),'Object');
                        dstBlks=...
                        slci.compatibility.FirstInitICPropagationConstraint.getDstBlks(...
                        portObj);
                        for idx=1:numel(dstBlks)
                            [thisFlag,thisDsts]=...
                            slci.compatibility.FirstInitICPropagationConstraint.propagates(...
                            dstBlks(idx),processedBlks);
                            dsts=[dsts,thisDsts];%#ok
                            flag=flag||thisFlag;
                        end
                    end
                else


                    blkType=get_param(blkH,'BlockType');
                    if any(strcmpi(blkType,{'Mux',...
                        'Demux',...
                        'BusSelector',...
                        'BusCreator',...
                        'SignalConversion'}))
                        portHandles=get_param(blkH,'PortHandles');
                        outports=portHandles.Outport;
                        for k=1:numel(outports)
                            portObj=get_param(outports(k),'Object');
                            if portObj.getICAttribsComputeInFirstInit()
                                flag=true;
                                dsts=[dsts...
                                ,slci.compatibility.FirstInitICPropagationConstraint.getDstBlks(...
                                portObj)];%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end


        function dsts=getDstBlks(portObj)
            dstPorts=portObj.getGraphicalDst;
            numDsts=numel(dstPorts);
            dsts=ones(1,numDsts);
            for idx=1:numDsts
                dsts(idx)=get_param(dstPorts(idx),'ParentHandle');
            end
        end

    end

    methods(Access=private)

        function recActionStr=prepareRecAction(aObj)

            [emptyICBlks,incompatibleBlks]=aObj.getIncompatibleBlks;
            if isempty(emptyICBlks)&&isempty(incompatibleBlks)
                assert(true,'Failure in First Init IC propagation constraint');
            end



            recActionList=ModelAdvisor.List();
            if~isempty(emptyICBlks)

                blkStr=aObj.getHTMLForBlock(emptyICBlks(1));
                for k=2:numel(emptyICBlks)
                    blkStr=[blkStr,' , ',aObj.getHTMLForBlock(emptyICBlks(k))];%#ok
                end

                emptyICStr=DAStudio.message(...
                'Slci:compatibility:FirstInitICPropagationConstraintRecActionEmptyIC',blkStr);
                emptyICObj=ModelAdvisor.Text(emptyICStr);
                recActionList.addItem(emptyICObj);
            end



            if~isempty(incompatibleBlks)

                blkStr=aObj.getHTMLForBlock(incompatibleBlks(1));
                for k=2:numel(incompatibleBlks)
                    blkStr=[blkStr,' , ',aObj.getHTMLForBlock(incompatibleBlks(k))];%#ok
                end

                incompatBlkStr=DAStudio.message(...
                'Slci:compatibility:FirstInitICPropagationConstraintRecActionIncompatible',blkStr);
                incompatBlkObj=ModelAdvisor.Text(incompatBlkStr);
                recActionList.addItem(incompatBlkObj);
            end


            recAction=DAStudio.message(...
            'Slci:compatibility:FirstInitICPropagationConstraintRecAction');
            lineBreak=ModelAdvisor.LineBreak;
            recActionStr=[recAction,lineBreak.emitHTML()...
            ,recActionList.emitHTML()];
        end


        function htmlString=getHTMLForBlock(~,blkH)
            htmlObj=ModelAdvisor.Text(getfullname(blkH));
            slCB=ModelAdvisor.getSimulinkCallback('hilite_system',blkH);
            htmlObj.setHyperlink(slCB);
            htmlString=htmlObj.emitHTML;
        end





        function[emptyICBlks,incompatibleBlks]=getIncompatibleBlks(aObj)

            emptyICBlks=[];
            incompatibleBlks=[];

            blks=keys(aObj.fDestMap);
            for idx=1:numel(blks)
                blk=blks{idx};
                dsts=aObj.fDestMap(blk);
                emptyICDests=[];
                for k=1:numel(dsts)
                    dst=dsts(k);




                    if(aObj.isConditionalSubsystemOutport(dst)...
                        ||strcmpi(get_param(dst,'BlockType'),'Merge'))...
                        &&strcmpi(get_param(dst,'InitialOutput'),'[]')
                        emptyICDests=[emptyICDests;dst];%#ok<AGROW>
                    end
                end
                if~isempty(emptyICDests)
                    emptyICBlks=[emptyICBlks;emptyICDests];%#ok<AGROW>
                else
                    incompatibleBlks=[incompatibleBlks;blk];%#ok<AGROW>  
                end
            end
            emptyICBlks=unique(emptyICBlks);

        end


        function isCondOp=isConditionalSubsystemOutport(~,blkH)
            if strcmpi(get_param(blkH,'BlockType'),'Outport')
                parent=get_param(get_param(blkH,'Parent'),'Handle');
                parentObj=get_param(parent,'Object');
                if strcmpi(get_param(parent,'Type'),'Block')...
                    &&strcmpi(get_param(parent,'BlockType'),'SubSystem')...
                    &&any(strcmpi(slci.internal.getSubsystemType(parentObj),...
                    {'Enable','Function-call','Action','Trigger'}))
                    isCondOp=true;
                    return;
                end
            end
            isCondOp=false;
        end

    end

end

