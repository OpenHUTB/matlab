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
            dataArray(i).PortNum=pos-1;
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
            dataArray(i).PortNum=pos-1;
            if~strcmp(dataArray(i).Category,'None')
                dataArray(i).Position=posInArgs;
                posInArgs=posInArgs+1;
                if strcmp(dataArray(i).Category,'Value')
                    outportValue=[dataArray(i).SLObjectName;outportValue];%#ok<AGROW>
                end
            end
            res=[res;dataArray(i)];%#ok<AGROW>
        else
            hSrc.selRow=0;
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

        [argName,cat,qualifier]=hSrc.getPortDefaultConf(inpH(IDX(i)));
        arg=RTW.FcnArgSpec(inpNames{IDX(i)},'Inport',cat,argName,...
        posInArgs,qualifier,IDX(i)-1,posInArgs);
        posInArgs=posInArgs+1;
        res=[res;arg];%#ok<AGROW>
    end


    [~,IDX]=setdiff(outpNames,namesInArgSpec);
    IDX=sort(IDX);
    for i=1:length(IDX)
        [argName,cat,qualifier]=hSrc.getPortDefaultConf(outpH(IDX(i)));
        arg=RTW.FcnArgSpec(outpNames{IDX(i)},'Outport',cat,argName,...
        posInArgs,qualifier,IDX(i)-1,posInArgs);
        posInArgs=posInArgs+1;
        res=[res;arg];%#ok<AGROW>
    end

