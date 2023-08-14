function exportModelComponents(model,filename,header,singleVariant,singleDose,varargin)

    cleanupAfterFile=true;
    pvpairs=varargin;
    sheetNames={};


    warnState=warning('off','MATLAB:xlswrite:AddSheet');
    cleanup=onCleanup(@()warning(warnState));

    for i=1:2:length(pvpairs)
        name=pvpairs{i};
        type=getType(name);


        properties=pvpairs{i+1};
        obj=sbioselect(model,'Type',type);

        if~isempty(obj)&&~isempty(properties)
            if cleanupAfterFile
                cleanupAfterFile=false;
                deleteFile(filename);
            end

            if isa(obj(1),'SimBiology.Variant')
                sheetNames=writeVariants(filename,obj,properties,header,singleVariant,sheetNames);
            elseif strcmp(type,'scheduledose')
                sheetNames=writeScheduleDoses(filename,obj,properties,header,singleDose,sheetNames);
            else
                sheetNames=writeComponents(filename,obj,properties,header,name,sheetNames);
            end
        end
    end

end

function sheetNames=writeComponents(filename,obj,properties,header,name,sheetNames)

    values=getPropertyValues(obj,properties);

    if iscell(values)
        valuesTable=cell2table(values);
    else
        valuesTable=array2table(values);
    end

    valuesTable.Properties.VariableNames=properties;


    sheetNames=writeData(filename,valuesTable,header,name,name,sheetNames);

end

function sheetNames=writeVariants(filename,obj,properties,header,singleVariant,sheetNames)

    if singleVariant
        sheetNames=writeOneSheetForVariant(filename,obj,properties,header,sheetNames);
    else
        sheetNames=writeSheetForEachVariant(filename,obj,properties,header,sheetNames);
    end

end

function sheetNames=writeOneSheetForVariant(filename,obj,properties,header,sheetNames)

    names={};
    types={};
    values={};
    vnames=get(obj,{'Name'});

    for i=1:numel(obj)
        content=obj(i).Content;
        for j=1:numel(content)
            next=content{j};
            name=next{2};
            type=next{1};
            idx=findVariantRow(type,name,types,names);

            if isempty(idx)
                nextValue=repmat({''},1,numel(obj));
                nextValue{i}=next{4};
                values{end+1}=nextValue;%#ok<*AGROW> 
                names{end+1}=name;
                types{end+1}=type;
            else
                nextValue=values{idx};
                nextValue{i}=next{4};
                values{idx}=nextValue;
            end
        end
    end

    if size(vnames,1)~=1
        vnames=vnames';
    end

    values=reshape([values{:}],numel(vnames),numel(names));
    data=[];
    headers={};


    for i=1:length(properties)
        if strcmp(properties{i},'Name')
            data=vertcat(data,names);
            headers=horzcat(headers,'Name');
        elseif strcmp(properties{i},'Value')
            data=vertcat(data,values);
            headers=horzcat(headers,vnames);
        elseif strcmp(properties{i},'Type')
            data=vertcat(data,types);
            headers=horzcat(headers,'Type');
        end
    end

    data=data';
    valuesTable=cell2table(data);
    valuesTable.Properties.VariableNames=headers;


    sheetNames=writeData(filename,valuesTable,header,'Variants','Variants',sheetNames);

end

function sheetNames=writeSheetForEachVariant(filename,obj,properties,header,sheetNames)

    for i=1:numel(obj)
        v=obj(i);


        content=v.Content;
        types=cell(numel(content),1);
        names=cell(numel(content),1);
        values=cell(numel(content),1);

        for j=1:numel(content)
            next=content{j};
            types{j}=next{1};
            names{j}=next{2};
            values{j}=next{4};
        end


        allValues=cell(1,numel(properties));
        for j=1:numel(properties)
            switch(properties{j})
            case 'VariantName'
                name=repmat({v.Name},numel(content),1);
                allValues{j}=name;
            case 'Type'
                allValues{j}=types;
            case 'Name'
                allValues{j}=names;
            case 'Value'
                allValues{j}=values;
            end
        end


        valuesTable=table(allValues{:});
        valuesTable.Properties.VariableNames=properties;


        sheetNames=writeData(filename,valuesTable,header,v.Name,'Variants',sheetNames);
    end

end

function sheetNames=writeScheduleDoses(filename,obj,properties,header,singleDose,sheetNames)

    if singleDose
        sheetNames=writeOneSheetForScheduleDoses(filename,obj,properties,header,sheetNames);
    else
        sheetNames=writeSheetForEachScheduleDose(filename,obj,properties,header,sheetNames);
    end

end

function sheetNames=writeOneSheetForScheduleDoses(filename,obj,properties,header,sheetNames)

    allValues=cell(1,numel(properties));

    for i=1:numel(obj)
        d=obj(i);
        values=getPropertyValues(d,properties);
        maxCount=max([numel(d.Time),numel(d.Amount),numel(d.Rate)]);

        for j=1:numel(properties)
            if iscell(values)
                nextValue=values{j};
            else
                nextValue=values(j);
            end

            if any(strcmp(properties{j},{'Time','Amount','Rate'}))
                nextArray=cell(maxCount,1);
                for k=1:numel(nextValue)
                    nextArray{k}=nextValue(k);
                end
            else
                nextArray=repmat({nextValue},maxCount,1);
            end

            if isempty(allValues{j})
                allValues{j}=nextArray;
            else
                allValues{j}=vertcat(allValues{j},nextArray);
            end
        end
    end


    valuesTable=table(allValues{:});
    valuesTable.Properties.VariableNames=properties;


    sheetNames=writeData(filename,valuesTable,header,'ScheduleDoses','ScheduleDoses',sheetNames);

end

function sheetNames=writeSheetForEachScheduleDose(filename,obj,properties,header,sheetNames)

    for i=1:numel(obj)
        d=obj(i);
        values=getPropertyValues(d,properties);
        maxCount=max([numel(d.Time),numel(d.Amount),numel(d.Rate)]);
        allValues=cell(1,numel(properties));

        for j=1:numel(properties)
            if iscell(values)
                nextValue=values{j};
            else
                nextValue=values(j);
            end

            if any(strcmp(properties{j},{'Time','Amount','Rate'}))
                nextArray=cell(maxCount,1);
                for k=1:numel(nextValue)
                    nextArray{k}=nextValue(k);
                end
            else
                nextArray=repmat({nextValue},maxCount,1);
            end

            allValues{j}=nextArray;
        end


        valuesTable=table(allValues{:});
        valuesTable.Properties.VariableNames=properties;


        sheetNames=writeData(filename,valuesTable,header,d.Name,'ScheduleDoses',sheetNames);
    end

end

function values=getPropertyValues(obj,properties)

    index=find(strcmp(properties,'Scope'));
    if~isempty(index)
        properties{index}='Parent';
    end


    values=get(obj,properties);


    values=kineticLawCleanup(values,properties);
    values=ownerCleanup(values,properties);
    values=scopeCleanup(values,properties);



    values=eventFunctionCleanup(values,properties);

end



function values=kineticLawCleanup(values,properties)

    index=find(strcmp(properties,'KineticLaw'));
    if~isempty(index)
        for i=1:size(values,1)

            next=values{i,index};
            values{i,index}=get(next,'KineticLawName');
        end
    end

end



function values=ownerCleanup(values,properties)

    index=find(strcmp(properties,'Owner'));

    if~isempty(index)
        for i=1:size(values,1)

            next=values{i,index};
            values{i,index}=get(next,'Name');
        end
    end
end



function values=scopeCleanup(values,properties)

    index=find(strcmp(properties,'Parent'));

    if~isempty(index)
        for i=1:size(values,1)
            parent=values{i,index};
            if isa(parent,'SimBiology.Model')
                values{i,index}=get(parent,'Name');
            elseif isa(parent,'SimBiology.KineticLaw')
                reaction=get(parent,'Parent');
                values{i,index}=get(reaction,'Name');
            elseif isa(parent,'SimBiology.Compartment')
                values{i,index}=get(parent,'Name');
            end
        end
    end

end


function values=eventFunctionCleanup(values,props)

    index=find(strcmp(props,'EventFcns'));
    if~isempty(index)

        for i=1:size(values,1)


            next=values{i,index};
            val=sprintf('%s;',next{:});
            values{i,index}=val(1:end-1);
        end
    end

end

function out=findVariantRow(type,name,types,names)

    out=[];
    idx=find(strcmp(name,names));
    for i=1:length(idx)
        if strcmp(types{idx(i)},type)
            out=idx(i);
            break;
        end
    end

end

function out=getType(name)

    switch(name)
    case 'Compartments'
        out='compartment';
    case 'Events'
        out='event';
    case 'Parameters'
        out='parameter';
    case 'Reactions'
        out='reaction';
    case 'RepeatDoses'
        out='repeatdose';
    case 'Rules'
        out='rule';
    case 'ScheduleDoses'
        out='scheduledose';
    case 'Species'
        out='species';
    case 'Observables'
        out='observable';
    case 'Variants'
        out='variant';
    end

end

function sheetNames=writeData(filename,valuesTable,header,sheetName,newName,sheetNames)

    if any(strcmp(sheetName,sheetNames))

        sheetName=findUniqueNameUsingDelimiter(sheetNames,newName);
    end

    try
        writetable(valuesTable,filename,'WriteVariableNames',header,'Sheet',sheetName);
        sheetNames{end+1}=sheetName;
    catch

        sheetName=findUniqueNameUsingDelimiter(sheetNames,newName);
        writetable(valuesTable,filename,'WriteVariableNames',header,'Sheet',sheetName);
        sheetNames{end+1}=sheetName;
    end

end

function name=findUniqueNameUsingDelimiter(allNames,nameIn)

    name=SimBiology.web.codegenerationutil('findUniqueNameUsingDelimiter',allNames,nameIn,'_',true);

end

function message=deleteFile(fileName)

    message='';

    if exist(fileName,'file')>0


        [fid,~]=fopen(fileName,'a');
        if fid==-1
            message=sprintf("Cannot access file %s. File is already open in another program",fileName);
        else
            fclose(fid);
            oldState=recycle;
            recycle('off');
            delete(fileName)
            recycle(oldState);
        end
    end
end
