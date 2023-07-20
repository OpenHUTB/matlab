function[initOut,maskObj]=getInitialValueFromSimState(sysH,refMdlToMdlBlk,simState)







    oldVal=slsvTestingHook('SimStateSnapshot',2);
    testHookCleanup=onCleanup(@()slsvTestingHook('SimStateSnapshot',oldVal));

    initOut={};
    maskObj={};
    if strcmp(get(sysH,'type'),'block_diagram')
        if~isempty(refMdlToMdlBlk)&&refMdlToMdlBlk.isKey(sysH)
            sysH=refMdlToMdlBlk(sysH);
            sysObj=get(sysH,'Object');
            if sysObj.isSynthesized


                sysH=sysObj.getTrueOriginalBlock;
            end
        else
            return;
        end
    end

    ssPH=get_param(sysH,'PortHandles');
    initOut=cell(1,length(ssPH.Outport));
    maskObj=cell(1,length(ssPH.Outport));
    nOutport=length(ssPH.Outport);

    for i=1:nOutport
        outBH=Transform.getOutportBlock(sysH,i);
        outPH=get_param(outBH,'PortHandles');
        pObj=get(outPH.Inport(1),'Object');

        if strcmp(pObj.CompiledBusType,'VIRTUAL_BUS')




            vbusMap=pObj.getActualSrcForVirtualBus;
            vbutPH2InitValueMap=containers.Map('KeyType','double','ValueType','Any');
            initOut{i}=getVirtualBusInitValueMap(vbutPH2InitValueMap,vbusMap,simState);
        else















            aSrc=pObj.getActualSrc;
            aSrc=lookForNextSourceBlock(aSrc);
            stateVal=findStateForBlockPath([],simState,get(aSrc(1),'Parent'));
            thisPortVal=stateVal;
            if~isstruct(stateVal)

                thisPortVal=stateVal;
            else
                try
                    sigHie=get(pObj.getGraphicalSrc,'SignalHierarchy');
                    leafSigName=sigHie.SignalName;
                    fieldVal=extractStructField(stateVal,leafSigName,'');
                catch
                    fieldVal=[];
                end
                if isempty(fieldVal)

                elseif numel(fieldVal)==1


                    thisPortVal=fieldVal.Value;
                else




                    busPathStr=getFullBusStructName(pObj.Handle);
                    for k=1:length(fieldVal)
                        if strcmp(busPathStr,fieldVal(k).pathStr);
                            thisPortVal=fieldVal(k).Value;
                        end
                    end
                end
            end


            initOut{i}=Transform.SliceTransformer.convValue2Str(thisPortVal);
        end
    end

    function out=getVirtualBusInitValueMap(out,vbusMap,simState)

        ks=vbusMap.keys;
        for n=1:length(ks)
            t=struct('origData',[],'value',[]);
            v=vbusMap(ks{n});
            if isa(v,'containers.Map')


                out=getVirtualBusInitValueMap(out,v,simState);
            else
                v=lookForNextSourceBlock(v);
                t.origData=v;

                t.value=findStateForBlockPath([],simState,get(v(1),'Parent'));
                out(v(1))=t;
            end
        end
    end
    function out=lookForNextSourceBlock(v)


        thisPH=v(1);
        thisPObj=get(thisPH,'Object');
        if strcmp(get(thisPObj.ParentHandle,'BlockType'),'SignalConversion')
            sigCPH=get(thisPObj.ParentHandle,'PortHandle');
            nextPObj=get(sigCPH.Inport(1),'Object');
            nextV=nextPObj.getActualSrc;
            out=lookForNextSourceBlock(nextV);
        else
            out=v;
        end
    end
    function out=extractStructField(strVal,fldName,pathStr)








        out=[];
        if~isempty(pathStr)
            pathStr=[pathStr,'.'];
        end
        flds=fieldnames(strVal);
        for j=1:length(flds)
            thisFieldVal=strVal.(flds{j});
            if strcmp(flds{j},fldName)
                t=struct('pathStr',[pathStr,fldName],'Value',thisFieldVal);
                if isempty(out)
                    out=t;
                else
                    out(end+1)=t;%#ok<AGROW>
                end
            end
            if isstruct(thisFieldVal)
                out=[out...
                ,extractStructField(thisFieldVal,fldName,[pathStr,flds{j}])];%#ok<AGROW>
            end
        end
    end
    function out=getFullBusStructName(ph)
        ppObj=get(ph.Inport(1),'Object');
        out=ppObj.SignalHierarchy.SignalName;

        prevBlkObj=get(get(ppObj.getGraphicalSrc,'ParentHandle'),'Object');
        if strcmp(prevBlkObj.BlockType,'BusSelector')
            out=[out,'.',getFullBusStructName(prevBlkObj.PortHandles.Inport(1))];
        end
    end
end

function out=findStateForBlockPath(out,partSimState,bPath)

    if isa(partSimState,'Simulink.SimState.ModelSimState')
        nStates=numel(partSimState.blockSimStates);
        for n=1:nStates
            out=findStateForBlockPath(out,partSimState.blockSimStates(n),bPath);
        end

    elseif isa(partSimState,'Simulink.SimState.BlockSimState')
        try
            blockExecData=partSimState.blockExecData;
            if isa(blockExecData,'Simulink.SimState.SystemExecData')
                nStates=numel(blockExecData.blockSimStates);
                for n=1:nStates
                    out=findStateForBlockPath(out,blockExecData.blockSimStates(n),bPath);
                end
            elseif isa(blockExecData,'Simulink.SimState.BlockDefaultExecData')
                if strcmp(bPath,partSimState.blockPath)
                    out=partSimState.blockExecData.persistentOutputs.value;
                end
            end
        catch mex %#ok<NASGU>

        end
    end

end