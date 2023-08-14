function FMUCreateBusObject(blockhandle,busVector,inputBusName,outputBusName)

    overWrite=false;
    missingBus={};
    missingBusNames={};
    missingBusStr='{';
    overWriteBus={};
    overWriteBusNames={};
    overWriteBusStr='{';


    firstTime=get_param(blockhandle,'FMUCreateBusObject');
    if isequal(firstTime,'off')
        return;
    end

    if~isempty(get_param(blockhandle,'FMUInputBusObjectName'))||...
        ~isempty(get_param(blockhandle,'FMUOutputBusObjectName'))
        return;
    end
    for i=1:size(busVector,1)
        structStr=busVector(i,:);
        busStruct=eval(structStr);
        busobj=createBusObjectFromStruct(busStruct);
        [exist,ow]=isBusInWorkSpace(blockhandle,busStruct(1).Name,busobj);
        overWrite=overWrite||ow;
        if ow
            overWriteBus{end+1}=busobj;
            overWriteBusNames{end+1}=busStruct(1).Name;
            overWriteBusStr=[overWriteBusStr,' ',busStruct(1).Name,','];
        end
        if~exist
            missingBus{end+1}=busobj;
            missingBusNames{end+1}=busStruct(1).Name;
            missingBusStr=[missingBusStr,' ',busStruct(1).Name,','];
        end
    end
    overWriteBusStr(end)='}';
    missingBusStr(end)='}';


    if~isempty(missingBus)
        options={'Yes','No'};
        if overWrite
            questionMessage=DAStudio.message('FMUBlock:Tools:CreateBusObjectOverwrite',overWriteBusStr);
        else
            questionMessage=DAStudio.message('FMUBlock:Tools:CreateBusObject',missingBusStr);
        end
        answer=questdlg(questionMessage,'Bus',...
        options{1},options{2},options{2});
        if strcmp(answer,options{1})
            for i=1:length(missingBus)
                assignin('base',missingBusNames{i},missingBus{i});
            end
        end
    end


    inputBusNameCell={};
    outputBusNameCell={};
    for i=1:size(inputBusName,1)
        name=deblank(inputBusName(i,:));
        if~isempty(name)
            inputBusNameCell{end+1}=name;
        end
    end
    for i=1:size(outputBusName,1)
        name=deblank(outputBusName(i,:));
        if~isempty(name)
            outputBusNameCell{end+1}=name;
        end
    end

    if~isempty(inputBusNameCell)
        set_param(blockhandle,'FMUInputBusObjectName',inputBusNameCell);
    end
    if~isempty(outputBusNameCell)
        set_param(blockhandle,'FMUOutputBusObjectName',outputBusNameCell);
    end
    set_param(blockhandle,'FMUCreateBusObject','off');
end

function busobj=createBusObjectFromStruct(busStruct)
    clear elems;
    scalarField={'Min','Max','Dimensions'};
    for k=1:numel(busStruct)
        eleStruct=busStruct(k).value;
        fn=fieldnames(eleStruct);
        elems(k)=Simulink.BusElement;
        for i=1:numel(fn)
            if~isempty(eleStruct.(fn{i}))
                if~isempty(find(strcmp(scalarField,fn{i}),1))
                    elems(k).(fn{i})=str2num(eleStruct.(fn{i}));
                else
                    elems(k).(fn{i})=eleStruct.(fn{i});
                end
            end
        end
    end
    busobj=Simulink.Bus;
    busobj.Description=busStruct(1).Description;
    busobj.HeaderFile=busStruct(1).HeaderFile;
    busobj.DataScope=busStruct(1).DataScope;
    busobj.Alignment=str2double(busStruct(1).Alignment);
    busobj.Elements=elems;
end

function[exist,overWrite]=isBusInWorkSpace(blockhandle,name,bus)
    overWrite=false;

    modelname=get_param(bdroot(blockhandle),'Name');


    exist=Simulink.data.existsInGlobal(modelname,name);
    if exist

        local=Simulink.data.evalinGlobal(modelname,name);
        exist=isequal(local,bus);


        overWrite=~exist;
    end
end