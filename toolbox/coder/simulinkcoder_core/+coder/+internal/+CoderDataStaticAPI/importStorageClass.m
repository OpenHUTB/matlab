function importStorageClass(sourceDD,pkg,csc)













    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    cls=csc.Name;
    dd=hlp.openDD(sourceDD);



    entryName=[pkg,'_',cls];
    if strcmp(pkg,'SimulinkBuiltin')
        entryName=strrep(cls,'Builtin','');
        simpleName=entryName;
    else
        simpleName=csc.Name;
    end


    if strcmp(cls,'Default')
        return;
    end
    cgEntry=hlp.findEntry(dd,'StorageClass',entryName);
    if isempty(cgEntry)
        cgEntry=hlp.createEntry(dd,'LegacyStorageClass',entryName);
    end
    hlp.setProp(cgEntry,'Package',pkg);
    if strcmp(hlp.getProp(cgEntry,'Package'),'SimulinkBuiltin')
        hlp.setProp(cgEntry,'isBuiltin',true);
    end
    hlp.setProp(cgEntry,'ClassName',cls);
    [result,instSpecificPropNames]=locGetPerInstanceProperties(pkg,cls);
    hlp.setProp(cgEntry,'CSCAttributesSchema',strrep(jsonencode(result),'UNDEFINED',''));

    locSetProperties(cgEntry,pkg,cls,instSpecificPropNames);
    locInitializeDescriptions(cgEntry,simpleName);


    swcEntry=coder.internal.CoderDataStaticAPI.getSWCT(dd);

    while isa(csc,'Simulink.CSCRefDefn')
        csc=processcsc('GetCSCDefn',csc.RefPackageName,csc.RefDefnName);
    end

    if csc.DataUsage.IsSignal
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','Inports',cgEntry,true);
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','Outports',cgEntry,true);
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','InternalData',cgEntry,true);
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','SharedLocalDataStores',cgEntry,true);
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','GlobalDataStores',cgEntry,true);





    end
    if csc.DataUsage.IsParameter
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','LocalParameters',cgEntry,true);
        hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','GlobalParameters',cgEntry,true);






    end
end

function locInitializeDescriptions(cgEntry,simpleName)
    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    if(strcmp(hlp.getProp(cgEntry,'Package'),'Simulink')||...
        strcmp(hlp.getProp(cgEntry,'Package'),'SimulinkBuiltin'))
        hlp.setProp(cgEntry,'Description',DAStudio.message(['SimulinkCoderApp:data:',simpleName]));
    end
end

function out=locGetCSCDefns(pkg,cls)
    tmpAll=processcsc('GetCSCDefns',pkg);
    out=find(tmpAll,'Name',cls);
end

function results=locSetProperties(entry,pkg,cls,instSpecificPropNames)


    results=[];
    obj=locGetCSCDefns(pkg,cls);
    if isempty(obj)
        return;
    end
    cscTypeProps={};
    if~isempty(obj)&&~isempty(obj.CSCTypeAttributes)
        cscTypeProps=fieldnames(obj.CSCTypeAttributes);
    end
    if~isempty(obj)
        names=fieldnames(obj)';
        names=[names,cscTypeProps'];





        names=setdiff(names,{'ConcurrentAccess','Name','CSCTypeAttributes'},'stable');
        numProps=numel(names);

        for ii=1:numProps
            prop=names{ii};


            if~isempty(regexp(prop,'Is(\w+)InstanceSpecific','once'))
                continue;
            end


            if any(ismember(instSpecificPropNames,prop))
                value='<Instance specific>';
            elseif any(ismember(cscTypeProps,prop))
                value=obj.CSCTypeAttributes.(prop);
            else
                value=obj.(prop);
            end


            if isa(value,'Simulink.DataUsage')

                if value.IsParameter&&value.IsSignal
                    value='SignalOrParameter';
                elseif value.IsParameter
                    value='Parameter';
                elseif value.IsSignal
                    value='Signal';
                else
                    value='---';
                end
            elseif strcmp(prop,'MemorySection')&&(isempty(value)||strcmp(value,'Default'))
                value='None';
            elseif strcmp(prop,'CSCType')
                prop='StorageClass_Packaging';
            elseif strcmp(prop,'DataScope')
                prop='Scope';
            elseif isempty(value)

                value='---';
            elseif islogical(value)

                if value
                    value='true';
                else
                    value='false';
                end
            elseif isnumeric(value)

                value=num2str(value);
            end
            if ischar(value)
                entry.addNonInstanceSpecificProp(prop,value);
            end
        end



        requiredProps={'StorageClass_Packaging','MemorySection','Scope','DataInit','HeaderFile','DefinitionFile'};
        currentProps=keys(entry.LegacyProps);
        missingProps=setdiff(requiredProps,currentProps,'stable');
        for i=1:length(missingProps)
            entry.addNonInstanceSpecificProp(missingProps{i},'---');
        end
    end
end

function[results,instSpecificPropNames]=locGetPerInstanceProperties(pkg,cls)


    results=[];
    instSpecificPropNames={};
    obj=locGetCSCDefns(pkg,cls);
    if isempty(obj)
        return;
    end
    cscTypeAttribProps={};
    if~isempty(obj)&&~isempty(obj.CSCTypeAttributes)
        cscTypeAttribProps=obj.CSCTypeAttributes.getInstanceSpecificProps();
    end
    attribObj=processcsc('CreateAttributesObject',pkg,cls);
    if~isempty(attribObj)
        switch Simulink.data.getScalarObjectLevel(attribObj)
        case 1
            isUDD=true;
        case 2
            isUDD=false;
        otherwise
            assert(false);
        end
        names=fieldnames(attribObj)';
        names=setdiff(names,{'ConcurrentAccess'},'stable');
        numProps=numel(names);
        for ii=1:numProps
            value='';
            type='string';
            allowedValues={};



            if~isempty(cscTypeAttribProps)&&~isempty(cscTypeAttribProps.findobj('Name',names{ii}))
                prop=cscTypeAttribProps.findobj('Name',names{ii});
                if prop.HasDefault
                    value=prop.DefaultValue;
                else
                    value='';
                end
                type=obj.CSCTypeAttributes.getPropDataType(prop.Name);
                allowedValues=obj.CSCTypeAttributes.getPropAllowedValues(prop.Name)';
            else



                propList=Simulink.data.getPropList(attribObj,'GetAccess','public','Hidden',false);
                if~isempty(propList)
                    prop=propList.findobj('Name',names{ii});
                    value=attribObj.(prop.Name);
                    if isempty(value)
                        value='';
                    end
                    if isUDD
                        allowedValues=set(attribObj,prop.Name);
                    else
                        allowedValues=getPropAllowedValues(attribObj,prop.Name);
                    end
                    if~isempty(allowedValues)&&numel(allowedValues)>1
                        type='enum';
                    end
                    if isequal(prop.Name,'PreserveDimensions')
                        type='bool';
                    end
                    if isequal(prop.Name,'MemorySection')

                        value=regexprep(value,'^Default$',...
                        DAStudio.message('coderdictionary:mapping:MappingNone'));
                        allowedValues=regexprep(allowedValues,'^Default$',...
                        DAStudio.message('coderdictionary:mapping:MappingNone'));
                    end
                end
            end



            if iscell(value)
                value={value};
            end
            results=[results,struct('Name',names{ii},'Value',value,'DisplayValue','<Instance specific>','Type',type,'AllowedValues',{allowedValues})];%#ok<AGROW>
            instSpecificPropNames=[instSpecificPropNames,names{ii}];%#ok<AGROW>
        end
    end
end

