function stmt=sldvPickMcdcForPort(blkH,portNo)




    stmt=[];
    blkSid=Simulink.ID.getSID(blkH);
    portHs=get_param(blkH,'PortHandles');
    vecLen=get_param(portHs.Outport,'CompiledPortWidth');
    numInp=length(portHs.Inport);

    for i=1:vecLen
        portWidth=get_param(portHs.Inport(portNo),'CompiledPortWidth');
        if vecLen>1&&portWidth>1
            elem(1).elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
            'vectorId',i,'portId',portNo,'outcome','true');
            elem(2).elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
            'vectorId',i,'portId',portNo,'outcome','false');
        else
            elem(1).elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
            'portId',portNo,'outcome','true');
            elem(2).elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
            'portId',portNo,'outcome','false');
        end


        elem(1).pathList=struct('sid',blkSid,'port',portNo,'inValues',[],'outValues',[]);
        elem(1).value='true';
        elem(2).pathList=struct('sid',blkSid,'port',portNo,'inValues',[],'outValues',[]);
        elem(2).value='false';


        nonMask=Sldv.ComputeObservable.logicNonMaskingValue(blkH);
        elem(1).pathList.inValues(portNo)=1;
        elem(2).pathList.inValues(portNo)=0;
        for j=1:numInp
            if j~=portNo
                elem(1).pathList.inValues(j)=nonMask;
                elem(2).pathList.inValues(j)=nonMask;
            end
        end


        for idx=1:2
            outValue(idx)=Sldv.ComputeObservable.computeLogicOutputValue(mod(idx,2),blkH);
            elem(idx).pathList.outValues(1)=outValue(idx);
            elem(idx).outValue=outValue(idx);
        end

        if isempty(stmt)
            stmt=Sldv.ObjectiveSelection.sldvCompose(elem(1));
        else
            stmt(end+1)=Sldv.ObjectiveSelection.sldvCompose(elem(1));%#ok<*AGROW>
        end
        stmt(end+1)=Sldv.ObjectiveSelection.sldvCompose(elem(2));
        elem=[];

        for j=1:numInp
            if j==portNo
                continue;
            end
            portWidth=get_param(portHs.Inport(j),'CompiledPortWidth');
            if vecLen>1&&portWidth>1
                elem.elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
                'vectorId',i,'portId',j,'outcome',nonMask);
            else
                elem.elem=Sldv.ObjectiveSelection.sldvPickObjectives(blkH,'covtype','condition',...
                'portId',j,'outcome',nonMask);
            end
            stmt(end-1)=Sldv.ObjectiveSelection.sldvCompose(stmt(end-1),elem);
            stmt(end)=Sldv.ObjectiveSelection.sldvCompose(stmt(end),elem);
        end
    end
end
