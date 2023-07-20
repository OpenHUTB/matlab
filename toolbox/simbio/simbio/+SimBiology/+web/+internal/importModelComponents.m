function msgs=importModelComponents(model,filename,header,singleVariant,singleDose,overwrite,prefs,varargin)


    oldWarnState=warning('off');
    cleanup=onCleanup(@()warning(oldWarnState));

    pvpairs=varargin;
    msgs.errors={};
    msgs.warnings={};

    for i=1:3:length(pvpairs)
        name=pvpairs{i};
        props=pvpairs{i+1};
        sheetName=pvpairs{i+2};

        try
            if strcmp(name,'Variants')
                msgs=updateVariants(model,filename,header,singleVariant,overwrite,sheetName,msgs);
            elseif strcmp(name,'ScheduleDoses')
                msgs=updateScheduleDoses(model,props,filename,header,singleDose,overwrite,sheetName,msgs);
            elseif strcmp(name,'RepeatDoses')




                values=readcell(filename,'Sheet',sheetName{1});
                msgs=updateRepeatDoses(model,props,values,overwrite,prefs,msgs);
            else


                values=readtable(filename,'ReadVariableNames',header,'Sheet',sheetName{1});

                switch(name)
                case 'Compartments'
                    msgs=updateCompartments(model,props,values,overwrite,msgs);
                case 'Events'
                    msgs=updateEvents(model,props,values,overwrite,msgs);
                case 'Parameters'
                    msgs=updateParameters(model,props,values,overwrite,msgs);
                case 'Reactions'
                    msgs=updateReactions(model,props,values,overwrite,prefs,msgs);
                case 'Rules'
                    msgs=updateRules(model,props,values,overwrite,msgs);
                case 'Species'
                    msgs=updateSpecies(model,props,values,overwrite,msgs);
                case 'Observables'
                    msgs=updateObservables(model,props,values,overwrite,msgs);
                end
            end
        catch
        end
    end

    msgs.warnings=unique(msgs.warnings);
    msgs.errors=unique(msgs.errors);

end

function msgs=updateReactions(model,props,values,overwrite,prefs,msgs)

    if~any(contains(values.Properties.VariableNames,'Name'))||~any(contains(values.Properties.VariableNames,'Reaction'))
        msgs.errors{end+1}='No reactions were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    nameValues=values.('Name');
    reactionValues=values.('Reaction');

    try
        for i=1:count
            obj=sbioselect(model,'Name',nameValues{i},'Type','reaction','depth',1);
            objectExists=~isempty(obj);


            if~objectExists
                obj=addreaction(model,reactionValues{i});
            end


            if~objectExists||overwrite
                for j=1:numel(obj)
                    msgs=configureProperties(obj(j),props,values,i,msgs,prefs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateRepeatDoses(model,props,values,overwrite,prefs,msgs)


    headings=values(1,:);
    values=values(2:end,:);
    values=cell2table(values);
    values.Properties.VariableNames=headings;


    count=size(values,1);
    nameValues=values.('Name');

    try
        for i=1:count
            obj=sbioselect(getdose(model),'Name',nameValues{i});
            objectExists=~isempty(obj);


            if~objectExists
                obj=adddose(model,nameValues{i},'repeat');
            end


            if~objectExists||overwrite
                msgs=configureProperties(obj,props,values,i,msgs,prefs);
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateRules(models,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Rule'))
        msgs.errors{end+1}='No rules were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    ruleValues=values.('Rule');

    try
        for i=1:count
            obj=sbioselect(models,'Rule',ruleValues{i},'Type','rule','depth',1);
            objectExists=~isempty(obj);


            if~objectExists
                obj=addrule(models,ruleValues{i});
            end


            if~objectExists||overwrite
                for j=1:numel(obj)
                    msgs=configureProperties(obj(j),props,values,i,msgs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateEvents(models,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Trigger'))
        msgs.errors{end+1}='No events were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    triggerValues=values.('Trigger');

    try
        for i=1:count
            obj=sbioselect(models,'Trigger',triggerValues{i},'Type','event','depth',1);
            objectExists=~isempty(obj);


            if~objectExists
                obj=addevent(models,triggerValues{i},{});
            end


            if~objectExists||overwrite
                for j=1:numel(obj)
                    msgs=configureProperties(obj(j),props,values,i,msgs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateObservables(model,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Name'))
        msgs.errors{end+1}='No observables were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    nameValues=values.('Name');

    try
        for i=1:count
            obj=sbioselect(model,'Name',nameValues{i},'Type','observable');
            objectExists=~isempty(obj);


            if~objectExists
                obj=addobservable(model,nameValues{i},'');
            end


            if~objectExists||overwrite
                for j=1:numel(obj)
                    msgs=configureProperties(obj(j),props,values,i,msgs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateCompartments(model,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Name'))
        msgs.errors{end+1}='No compartments were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    nameValues=values.('Name');
    newComps={};

    try
        for i=1:count
            obj=sbioselect(model,'Name',nameValues{i},'Type','compartment');
            objectExists=~isempty(obj);

            if~objectExists
                obj=addcompartment(model,nameValues{i});
                newComps{end+1}=nameValues{i};
            end

            if~objectExists||overwrite
                msgs=configureProperties(obj,props,values,i,msgs);
            end
        end


        ownerIdx=find(strcmp(props,'Owner'),1);
        if~isempty(ownerIdx)
            ownerValues=values.('Owner');
            for i=1:count


                if overwrite||~objectExists
                    if iscell(ownerValues)
                        nextOwnerValue=ownerValues{i};
                    else
                        nextOwnerValue=ownerValues(i);
                    end

                    obj=sbioselect(model,'Name',nameValues{i},'Type','compartment');
                    msgs=configureCompartmentOwner(model,obj,nextOwnerValue,msgs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateSpecies(model,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Name'))
        msgs.errors{end+1}='No species were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    nameValues=values.('Name');




    if any(strcmp('Scope',props))
        scopeValues=values.('Scope');
    else
        scopeValues=cell(1,count);
    end

    try
        for i=1:count
            parent=[];
            if iscell(scopeValues)
                scope=scopeValues{i};
            else
                scope=scopeValues(i);
            end

            if isempty(scope)||isnumeric(scope)
                compartments=get(model,'Compartments');
                if isempty(compartments)
                    msgs.errors{end+1}=(['The species ',nameValues{i},' was not created because the Scope was not specified.']);%#ok<*AGROW>
                elseif length(compartments)>1
                    msgs.errors{end+1}=(['The species ',nameValues{i},' was not created because the Scope was not specified.']);
                else
                    parent=compartments;
                end
            else

                parent=sbioselect(model,'Type','compartment','Name',scope);
                if isempty(parent)
                    parent=addcompartment(model,scope);
                end
            end

            if~isempty(parent)
                obj=sbioselect(parent,'Name',nameValues{i},'Type','species','depth',1);
                objectExists=~isempty(obj);

                if~objectExists
                    obj=addspecies(parent,nameValues{i});
                end

                if~objectExists||overwrite
                    msgs=configureProperties(obj,props,values,i,msgs);
                end
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateParameters(model,props,values,overwrite,msgs)

    if~any(contains(values.Properties.VariableNames,'Name'))
        msgs.errors{end+1}='No parameters were created. An invalid sheet was specified.';
        return;
    end

    count=size(values,1);
    nameValues=values.('Name');


    if any(strcmp('Scope',props))
        scopeValues=values.('Scope');
    else
        scopeValues=cell(1,count);
    end

    try
        for i=1:count

            parent=getObjectToAddParameterTo(model,scopeValues{i},nameValues{i});

            if ischar(parent)
                msgs.errors{end+1}=parent;
            elseif~isempty(parent)

                obj=sbioselect(parent,'Name',nameValues{i},'Type','parameter','depth',1);
                objectExists=~isempty(obj);

                if~objectExists
                    obj=addparameter(parent,nameValues{i});
                end

                if~objectExists||overwrite
                    msgs=configureProperties(obj,props,values,i,msgs);
                end
            else
                msgs.errors{end+1}=['The parameter ',nameValues{i},' was not created because the parent does not exist as defined by the Scope.'];
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function msgs=updateScheduleDoses(model,props,filename,header,singleDose,overwrite,sheetNames,msgs)

    if singleDose
        msgs=readOneSheetForScheduleDose(model,props,filename,header,overwrite,sheetNames,msgs);
    else
        msgs=readSheetForEachScheduleDose(model,props,filename,header,overwrite,sheetNames,msgs);
    end

end

function msgs=readOneSheetForScheduleDose(model,props,filename,header,overwrite,sheetNames,msgs)

    values=readtable(filename,'ReadVariableNames',header,'Sheet',sheetNames{1});

    if~any(contains(values.Properties.VariableNames,'Name'))
        msgs.errors{end+1}='No schedule doses were created. An invalid sheet was specified.';
        return;
    end

    names=values.Name;
    uniqueNames=unique(names);

    for i=1:numel(uniqueNames)
        try
            name=uniqueNames{i};
            idx=strcmp(name,names);

            obj=sbioselect(getdose(model),'Name',name);
            objectExists=~isempty(obj);


            if~objectExists
                obj=adddose(model,name,'schedule');
            end


            if~objectExists||overwrite
                for j=1:numel(props)
                    try
                        prop=props{j};
                        propValue=values.(prop);
                        propValue=propValue(idx);

                        if~any(strcmp(prop,{'Time','Amount','Rate'}))
                            if iscell(propValue)
                                firstValue=propValue{1};
                            else
                                firstValue=propValue(1);
                            end

                            if numel(unique(propValue))~=1




                                if~(isnumeric(firstValue)&&isnan(firstValue))
                                    msgs.warnings{end+1}=['Dose with name ',name,' has different ',prop,' values. The first value was used.'];
                                end
                            end

                            propValue=firstValue;
                        else



                            idx1=isnan(propValue);
                            propValue(idx1)=0;
                        end

                        if~isnan(propValue)
                            set(obj,prop,propValue);
                        end
                    catch ex
                        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
                    end
                end
            end
        catch ex
            msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
        end
    end

end

function msgs=readSheetForEachScheduleDose(model,props,filename,header,overwrite,sheetNames,msgs)

    for i=1:numel(sheetNames)
        try
            name=sheetNames{i};
            values=readtable(filename,'ReadVariableNames',header,'Sheet',name);
            valueProps=values.Properties.VariableNames;

            if any(strcmp('Name',valueProps))
                name=values.('Name');
                name=name{1};
            end

            obj=sbioselect(getdose(model),'Name',name);
            objectExists=~isempty(obj);


            if~objectExists
                obj=adddose(model,name,'schedule');
            end


            if~objectExists||overwrite
                for j=1:numel(props)
                    try
                        prop=props{j};
                        propValue=values.(prop);

                        if~any(strcmp(prop,{'Time','Amount','Rate'}))
                            if iscell(propValue)
                                firstValue=propValue{1};
                            else
                                firstValue=propValue(1);
                            end

                            if numel(unique(propValue))~=1
                                if~(isnumeric(firstValue)&&isnan(firstValue))
                                    msgs.warnings{end+1}=['Dose with name ',name,' has different ',prop,' values. The first value was used.'];
                                end
                            end

                            propValue=firstValue;
                        else



                            idx=isnan(propValue);
                            propValue(idx)=0;
                        end

                        if~isnan(propValue)
                            set(obj,prop,propValue);
                        end
                    catch ex
                        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
                    end
                end
            end
        catch ex
            msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
        end
    end

end

function msgs=updateVariants(model,filename,header,singleVariant,overwrite,sheetNames,msgs)

    if singleVariant
        msgs=readOneSheetForVariant(model,filename,header,overwrite,sheetNames,msgs);
    else
        msgs=readSheetForEachVariant(model,filename,header,overwrite,sheetNames,msgs);
    end

end

function msgs=readOneSheetForVariant(model,filename,header,overwrite,sheetNames,msgs)





    values=readtable(filename,'ReadVariableNames',header,'Sheet',sheetNames{1});
    headers=values.Properties.VariableNames;
    descriptions=values.Properties.VariableDescriptions;

    if~any(contains(values.Properties.VariableNames,'Name'))||~any(contains(values.Properties.VariableNames,'Type'))
        msgs.errors{end+1}='No variants were created. An invalid sheet was specified.';
        return;
    end

    names=values.Name;
    types=values.Type;

    if isempty(descriptions)
        descriptions=headers;
    end

    headers(strcmp('Name',headers))=[];
    headers(strcmp('Type',headers))=[];
    descriptions(strcmp('Name',descriptions))=[];
    descriptions(strcmp('Type',descriptions))=[];

    for i=1:numel(headers)
        try
            header=headers{i};
            name=descriptions{i};
            obj=sbioselect(getvariant(model),'Name',name);
            objectExists=~isempty(obj);


            if~objectExists
                obj=addvariant(model,name);
            end


            if~objectExists||overwrite
                next=values.(header);
                [content,msgs]=createContentMultipleVariantsPerSheet(obj,names,types,next,msgs);
                set(obj,'Content',content);
            end
        catch ex
            msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
        end
    end

end

function msgs=readSheetForEachVariant(model,filename,header,overwrite,sheetNames,msgs)

    for i=1:numel(sheetNames)
        try
            name=sheetNames{i};
            values=readtable(filename,'ReadVariableNames',header,'Sheet',name);
            valueProps=values.Properties.VariableNames;

            if any(strcmp('VariantName',valueProps))
                name=values.('VariantName');
                if numel(unique(name))~=1
                    msgs.warnings{end+1}=['Variant with name ',name{1},' has different VariantName values. The first value was used.'];
                end

                name=name{1};
            end

            obj=sbioselect(getvariant(model),'Name',name);
            objectExists=~isempty(obj);


            if~objectExists
                obj=addvariant(model,name);
            end


            if~objectExists||overwrite
                [content,msgs]=createContentOneVariantPerSheet(obj,values,msgs);
                set(obj,'Content',content);
            end
        catch ex
            msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
        end
    end
end


function out=getObjectToAddParameterTo(model,scope,name)

    if isempty(scope)
        out=model;
    elseif isequal(model.Name,scope)
        out=model;
    else
        out=sbioselect(model,'Type','reaction','Name',scope);
        if isempty(out)
            out=sprintf('The parameter %s was not created because the reaction does not exist as defined by the Scope %s.',name,scope);
        elseif length(out)==1
            out=out.KineticLaw;
            if isempty(out)
                out=sprintf('The parameter %s was not created because the reaction defined by the Scope %s does not have a kinetic law.',name,scope);
            end
        else
            out=sprintf('The parameter %s was not created because two or more reactions exist as defined by the Scope %s.',name,scope);
        end
    end

end

function[content,msgs]=createContentOneVariantPerSheet(obj,values,msgs)

    name=values.('Name');
    type=values.('Type');
    value=values.('Value');
    content={};

    for i=1:length(name)
        if~any(strcmpi(type{i},{'parameter','compartment','species'}))
            msgs.warnings{end+1}=['Content for variant ',obj.Name,' referenced an unsupported type ''',type{i},'''. It was ignored. Only parameter, compartment and species Types are supported.'];
        elseif isnan(value(i))
            msgs.warnings{end+1}=['Content for variant ',obj.Name,' had an invalid value for ',name{i},'. It was ignored.'];
        else
            next={type{i},name{i},'Value',value(i)};
            content{end+1}=next;
        end
    end

end

function[content,msgs]=createContentMultipleVariantsPerSheet(obj,names,types,values,msgs)

    content={};

    for i=1:length(values)
        if~isnan(values(i))
            if~any(strcmpi(types{i},{'parameter','compartment','species'}))
                msgs.warnings{end+1}=['Content for variant ',obj.Name,' referenced an unsupported type ''',types{i},'''. It was ignored. Only parameter, compartment and species Types are supported.'];
            else
                next={types{i},names{i},'Value',values(i)};
                content{end+1}=next;
            end
        end
    end

end

function msgs=configureProperties(obj,props,values,count,msgs,varargin)

    for i=1:length(props)
        prop=props{i};

        switch prop
        case 'Value'
            next=getValue(obj,values);
        case 'Units'
            next=getUnits(obj,values);
        case 'Constant'
            next=getConstant(obj,values);
        otherwise
            if~any(contains(values.Properties.VariableNames,prop))
                next=missing;
                msgs.warnings{end+1}=['The column ''',prop,''' does not exist and was not configured.'];
            else
                next=values.(prop);
            end
        end


        if iscell(next)
            value=next{count};
        elseif ismissing(next)
            value=next;
        else
            value=next(count);
        end

        if ismissing(value)


        elseif~isnan(value)
            try
                switch prop
                case 'Scope'

                case 'Owner'

                case 'KineticLaw'
                    input=struct('value',value,'prefs',varargin{1});
                    SimBiology.web.modelhandler('configureKineticLaw',obj,input);
                case 'EventFcns'
                    value=strsplit(value,';');
                    set(obj,prop,value);
                otherwise
                    set(obj,prop,value);
                end
            catch ex
                msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
            end
        end
    end
end

function msgs=configureCompartmentOwner(model,obj,owner,msgs)

    try
        if isempty(owner)
            set(obj,'Owner',[]);
        elseif ischar(owner)
            p=sbioselect(model,'Name',owner,'Type','compartment');
            if~isempty(p)
                set(obj,'Owner',p);
            else
                msgs.errors{end+1}=['The owner, ',owner,', could not be found.'];
            end
        end
    catch ex
        msgs.errors{end+1}=SimBiology.web.internal.errortranslator(ex);
    end

end

function next=getValue(obj,values)

    prop='Value';
    if isa(obj,'SimBiology.Compartment')
        prop='Capacity';
    elseif isa(obj,'SimBiology.Species')
        prop='InitialAmount';
    end

    variableNames=values.Properties.VariableNames;
    if any(strcmp('Value',variableNames))
        next=values.Value;
    elseif any(strcmp(prop,variableNames))
        next=values.(prop);
    else
        next='';
    end

end

function next=getUnits(obj,values)

    prop='Units';
    if isa(obj,'SimBiology.Compartment')
        prop='CapacityUnits';
    elseif isa(obj,'SimBiology.Species')
        prop='InitialAmountUnits';
    elseif isa(obj,'SimBiology.Parameter')
        prop='ValueUnits';
    end

    variableNames=values.Properties.VariableNames;
    if any(strcmp('Units',variableNames))
        next=values.Units;
    elseif any(strcmp(prop,variableNames))
        next=values.(prop);
    else
        next='';
    end

end

function next=getConstant(obj,values)

    prop='Constant';
    if isa(obj,'SimBiology.Compartment')
        prop='ConstantCapacity';
    elseif isa(obj,'SimBiology.Species')
        prop='ConstantAmount';
    elseif isa(obj,'SimBiology.Parameter')
        prop='ConstantValue';
    end

    variableNames=values.Properties.VariableNames;
    if any(strcmp('Constant',variableNames))
        next=values.Constant;
    elseif any(strcmp(prop,variableNames))
        next=values.(prop);
    else
        next='';
    end
end
