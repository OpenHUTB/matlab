function res=syncWithModel(hSrc)





    res=[];
    dataArray=hSrc.data;

    hModel=hSrc.ModelHandle;

    if~ishandle(hModel)
        DAStudio.error('RTW:fcnClass:invalidMdlHdl');
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                DAStudio.error('RTW:fcnClass:invalidMdlHdl');
            end
        catch %#ok<CTCH>
            DAStudio.error('RTW:fcnClass:invalidMdlHdl');
        end
    end

    if strcmpi(get_param(hModel,'IsERTTarget'),'off')
        hSrc.setDefaultClassName();
        hSrc.setDefaultNamespace();
        hSrc.setDefaultStepMethodName();
    end

    [inpH,outpH]=hSrc.getPortHandles(hSrc.ModelHandle);

    inpNames=get_param(inpH,'Name');
    outpNames=get_param(outpH,'Name');

    if ischar(inpNames)
        inpNames={inpNames};
    end

    if ischar(outpNames)
        outpNames={outpNames};
    end





    posInArgs=1;
    outportValue={};
    for i=1:length(dataArray)
        name=dataArray(i).SLObjectName;

        [~,pos]=intersect(inpNames,{name});
        if~isempty(pos)
            dataArray(i).SLObjectType='Inport';
            portType=get_param(inpH(pos),'BlockType');

            if coder.mapping.internal.StepFunctionMapping.isControlPort(portType)
                dataArray(i).PortNum=pos-1;
            else
                dataArray(i).PortNum=str2double(get_param(inpH(pos),'Port'))-1;
            end
            if~strcmp(dataArray(i).Category,'None')
                dataArray(i).Position=posInArgs;
                posInArgs=posInArgs+1;
            end
            res=[res;dataArray(i)];%#ok<AGROW>
            continue;
        end

        [~,pos]=intersect(outpNames,{name});
        if~isempty(pos)
            dataArray(i).SLObjectType='Outport';
            dataArray(i).PortNum=str2double(get_param(outpH(pos),'Port'))-1;
            if~strcmp(dataArray(i).Category,'None')
                dataArray(i).Position=posInArgs;
                posInArgs=posInArgs+1;
                if strcmp(dataArray(i).Category,'Value')
                    outportValue=[dataArray(i).SLObjectName;outportValue];%#ok<AGROW>
                end
            end
            res=[res;dataArray(i)];%#ok<AGROW>
        else
            if hSrc.isprop('selRow')
                hSrc.selRow=0;
            end
        end
    end


    local_temp=RTW.ModelSpecificCPrototype;
    local_temp.Data=res;
    for index=1:length(outportValue)
        local_temp.setArgPosition(outportValue{index},1);
    end
    res=local_temp.Data;

    namesInArgSpec=get(dataArray,'SLObjectName');
    if isempty(namesInArgSpec)
        namesInArgSpec={};
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end


    [~,IDX]=setdiff(inpNames,namesInArgSpec);
    IDX=sort(IDX);
    for i=1:length(IDX)
        arg=hSrc.getPortDefaultConf(inpH(IDX(i)),IDX(i)-1,posInArgs);
        posInArgs=posInArgs+1;
        res=[res;arg];%#ok<AGROW>
    end


    [~,IDX]=setdiff(outpNames,namesInArgSpec);
    IDX=sort(IDX);
    for i=1:length(IDX)
        arg=hSrc.getPortDefaultConf(outpH(IDX(i)),IDX(i)-1,posInArgs);
        posInArgs=posInArgs+1;
        res=[res;arg];%#ok<AGROW>
    end

