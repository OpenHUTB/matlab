
function compAttrStruct=CRCSGetCompiledPortsInfo(mdlName,blkPath)
    compAttrStruct=struct('Inport',[],'Outport',[],'receiveExecutesFirst',0,'isError',false,'errorMsg','');
    try
        simStatus=get_param(mdlName,'SimulationStatus');
        if strcmp(simStatus,'stopped')

            cleanup=onCleanup(@()feval(mdlName,[],[],[],'term'));
            feval(mdlName,[],[],[],'compile');
        end
        hPorts=get_param(blkPath,'PortHandles');
        rto=get_param(blkPath,'RuntimeObject');


        for hPort=hPorts.Inport
            portAttribStruct=getCompiledPortAttributes(hPort);
            compAttrStruct.Inport=[compAttrStruct.Inport,portAttribStruct];
        end
        for hPort=hPorts.Outport
            portAttribStruct=getCompiledPortAttributes(hPort);
            compAttrStruct.Outport=[compAttrStruct.Outport,portAttribStruct];
        end

        addedPorts=0;
        for i=1:length(hPorts.Inport)
            frame=compAttrStruct.Inport(i).frame;
            for j=1:length(frame)
                compAttrStruct.Inport(i).datatype{j}=rto.InputPort(i+j+addedPorts-1).datatype;
                st=rto.InputPort(i+j+addedPorts-1).sampleTime;
                if isempty(st)
                    compAttrStruct.Inport(i).sampletime{j}='0,0';
                else
                    compAttrStruct.Inport(i).sampletime{j}=char(string(st(1))+","+string(st(2)));
                end
                if~rto.InputPort(i+j+addedPorts-1).isBus
                    compAttrStruct.Inport(i).complexity(j)=logicStrToNum(rto.InputPort(i+j+addedPorts-1).complex);
                end
                compAttrStruct.Inport(i).directfeedthrough(j)=rto.InputPort(i+j+addedPorts-1).DirectFeedThrough;
            end
            addedPorts=addedPorts+length(frame)-1;
        end

        addedPorts=0;
        for i=1:length(hPorts.Outport)
            frame=compAttrStruct.Outport(i).frame;
            for j=1:length(frame)
                compAttrStruct.Outport(i).datatype{j}=rto.OutputPort(i+j+addedPorts-1).datatype;
                st=rto.OutputPort(i+j+addedPorts-1).sampleTime;
                if isempty(st)
                    compAttrStruct.Outport(i).sampletime{j}='0,0';
                else
                    compAttrStruct.Outport(i).sampletime{j}=char(string(st(1))+","+string(st(2)));
                end
                if~rto.OutputPort(i+j+addedPorts-1).isBus
                    compAttrStruct.Outport(i).complexity(j)=logicStrToNum(rto.OutputPort(i+j+addedPorts-1).complex);
                end
            end
            addedPorts=addedPorts+length(frame)-1;
        end

        hSFcnRec=get_param([mdlName,'/sfcnRec'],'Handle');
        hSFcnTrans=get_param([mdlName,'/sfcnTrans'],'Handle');
        hSorted=get_param(mdlName,'SortedList');
        mskRec=hSorted==hSFcnRec;
        mskTrans=hSorted==hSFcnTrans;
        compAttrStruct.receiveExecutesFirst=find(mskRec,1)<find(mskTrans,1);
    catch eCause
        compAttrStruct.isError=true;
        if ismethod(eCause,'json')
            compAttrStruct.errorMsg=eCause.json;
        else
            compAttrStruct.errorMsg=jsonencode(eCause);
        end
    end





end

function portAttribStruct=getCompiledPortAttributes(hPort)

    portAttribStruct.dims=get_param(hPort,'CompiledPortDimensions');

    portAttribStruct.datatype={''};
    portAttribStruct.complexity=get_param(hPort,'CompiledPortComplexSignal');
    portAttribStruct.frame=get_param(hPort,'CompiledPortFrameData');
    portAttribStruct.unit=get_param(hPort,'CompiledPortUnit');
    portAttribStruct.bustype=get_param(hPort,'CompiledBusType');
    portAttribStruct.directfeedthrough=false;
    portAttribStruct.sampletime={''};
end

function num=logicStrToNum(logic)
    if strcmp(logic,'Real')
        num=0;
    else
        num=1;
    end
end
