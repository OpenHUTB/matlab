


classdef StructuredControlFlowConstraint<slci.compatibility.Constraint

    properties
        fIdToJunctions=[];
        fStacksMapMap=[];
    end

    methods


        function out=getDescription(aObj)%#ok
            out='Unstructured control flow is not supported';
        end


        function obj=StructuredControlFlowConstraint
            obj.setEnum('StructuredControlFlow');
            obj.setCompileNeeded(0);
            if(slcifeature('SfLoopSupport')==0)
                obj.setFatal(true);
            else
                obj.setFatal(false);
            end

            obj.fIdToJunctions=containers.Map('KeyType','double','ValueType','any');
            obj.fStacksMapMap=containers.Map('KeyType','double','ValueType','any');
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end


        function combinedStacks=CombineStacksHelper(aObj,aJunction)
            stacksMap=aObj.fStacksMapMap(aJunction.getSfId());
            combinedStacks=false;
            keys=stacksMap.keys();

            for i=1:numel(keys)
                key=keys(i);
                stacks=stacksMap.value(key);




                expectedStacks=numel(aObj.fIdToJunctions(key).getOutgoingTransitions);


                if numel(stacks)==expectedStacks
                    combineable=true;
                    for j=2:numel(stacks)
                        if~isequal(stacks{j},stacks{1})
                            combineable=false;
                            break;
                        end
                    end
                    if combineable
                        aJunction.AddEndsRegionFor(key);
                        combinedStacks=true;
                        newStack=stacks{1}(1:end-1);
                        aJunction.setFlag(newStack);
                        if isempty(newStack)
                            stacksMap.remove(key);
                        else
                            newKey=newStack(end);
                            stacksMap.replace(key,newKey,newStack);
                        end
                        return;
                    end
                end
            end
        end


        function unstructured=CombineStacks(aObj,aJunction)

            combinedStacks=true;
            while combinedStacks
                combinedStacks=aObj.CombineStacksHelper(aJunction);
            end



            stacksMap=aObj.fStacksMapMap(aJunction.getSfId());
            values=stacksMap.values;
            unstructured=~isempty(values)&&...
            (numel(values)>1||numel(values{1})>1);
        end


        function unstructured=TraverseFlow(aObj,aJunction,aTransition)
            unstructured=false;
            incoming=aJunction.getIncomingTransitions();
            numIn=numel(incoming);
            outgoing=aJunction.getOutgoingTransitions();
            numOut=numel(outgoing);
            junctionSid=aJunction.getSfId();
            aObj.fIdToJunctions(junctionSid)=aJunction;











            if numIn==1
                aJunction.setFlag(incoming(1).getFlag());


            elseif numIn>1


                if~isempty(aTransition)
                    stacksMap=aObj.fStacksMapMap(aJunction.getSfId());
                    stack=aTransition.getFlag();
                    key=stack(end);
                    AddEntryToMap(stacksMap,key,stack);
                end


                if TraversedAllIncoming(aJunction)
                    unstructured=aObj.CombineStacks(aJunction);

                    if unstructured
                        return
                    end

                else
                    return
                end
            end


            if numOut>0
                stack=aJunction.getFlag();

                if numOut>1
                    stack=[stack,junctionSid];
                end
                for i=1:numOut


                    if~isempty(outgoing(i).getFlag())
                        unstructured=true;
                    else
                        outgoing(i).setFlag(stack);
                        dstJunction=outgoing(i).getDst();

                        if~isempty(dstJunction)
                            unstructured=aObj.TraverseFlow(dstJunction,outgoing(i));
                        end
                    end

                    if unstructured
                        return
                    end
                end
            end

        end



        function out=check(aObj)
            out=[];
            if(slcifeature('SfLoopSupport')==0)
                cfgs=aObj.getOwner.NonEmptyCfgs();
                for cfgIdx=1:numel(cfgs)
                    cfg=cfgs{cfgIdx};
                    cfg.SetFlags([]);
                    junctions=cfg.getJunctions();
                    for idx=1:numel(junctions)
                        aObj.fStacksMapMap(junctions(idx).getSfId())=...
                        slci.internal.OrderedMap();
                    end
                    initialJunction=cfg.getInitialJunction();
                    unstructured=aObj.TraverseFlow(initialJunction,[]);
                    if unstructured
                        cfg.SetFlags(0);
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'StructuredControlFlow',...
                        aObj.ParentBlock().getName(),...
                        aObj.getOwner().getClassNames());
                        return
                    end
                    cfg.SetFlags(0);
                end
            else
                if aObj.getOwner().isUnstructured()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'StructuredControlFlow',...
                    aObj.ParentBlock().getName(),...
                    aObj.getOwner().getClassNames());
                    return
                end
            end
        end

    end
end


function out=TraversedAllIncoming(aObj)
    out=1;
    incoming=aObj.getIncomingTransitions();
    numIn=numel(incoming);
    for i=1:numIn
        if isempty(incoming(i).getFlag())
            out=0;
            return
        end
    end
end


