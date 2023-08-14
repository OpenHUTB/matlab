classdef StorageClass<coder.dictionary.internal.CoderDataEntry




    methods(Static)


        function allprops=getAllProps(entry)
            allprops={'Name','Description','DataSource'};

            if isa(entry,'coderdictionary.data.StorageClass')
                allprops=[allprops,{'StorageType','DataScope','DataInit','DataAccess','HeaderFile','DefinitionFile',...
                'MemorySection','Const','Volatile','OtherQualifier','AccessibleByParameters',...
                'AccessibleBySignals','PreserveDimensions','DifferentInstanceDataSettings'}];

                if strcmp(entry.StorageType,'Structured')
                    allprops=[allprops,{'StructureTypeName','StructureInstanceName'}];
                elseif strcmp(entry.StorageType,'Mixed')
                    allprops=[allprops,{'SingleInstanceStorageType','SingleInstanceStructureTypeName','SingleInstanceStructureInstanceName',...
                    'MultiInstanceStorageType','MultiInstanceStructureTypeName','MultiInstanceStructureInstanceName'}];

                end

                if~isempty(entry.AccessMethod)
                    allprops=[allprops,{'AccessMode','AllowedAccess','GetFunctionName','SetFunctionName'}];
                end
            end

        end
        function allowedVals=getAllowedPropVals(entry,propName)
            if isenum(entry.(propName))
                enumArray=enumeration(entry.(propName));
                allowedVals=cellstr(enumArray(:));
                if(strcmp(propName,'DataAccess')&&slfeature('SupportMacroAccess')==0)


                    allowedVals(ismember(allowedVals,'Macro'))=[];
                end
            elseif strcmp(propName,'StorageType')
                allowedVals={'Structured','Unstructured'};
            elseif strcmp(propName,'MultiInstanceStorageType')
                allowedVals={'Structured','Unstructured'};
            else
                allowedVals='';
            end
        end

        function setProp(entry,name,value)
            if isa(entry,'coderdictionary.data.StorageClass')
                if strcmp(name,'StorageType')&&strcmp(value,'Mixed')
                    DAStudio.error('SimulinkCoderApp:data:InvalidValue',value,name);
                end
            end

            coder.dictionary.internal.CoderDataEntry.setProp(entry,name,value);
        end



        function out=isValidPropertyForSection(propName,entry)
            props=coder.dictionary.internal.StorageClass.getAllProps(entry);
            out=any(ismember(props,propName));
        end



        function checkValidPropertyForSection(propName,entry)
            if~coder.dictionary.internal.StorageClass.isValidPropertyForSection(propName,entry)
                DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
            end
        end


        function checkValidProperty(entry,propName,type)
            if~isa(entry,'coderdictionary.data.LegacyStorageClass')
                props=[{'Name','Description'},coder.dictionary.internal.StorageClass.getAllProps(...
                entry)];
                if~any(ismember(props,propName))
                    DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
                end
            else

                if strcmp(type,'set')
                    DAStudio.error('SimulinkCoderApp:data:CannotSetLegacyProperties');
                else
                    if~any(ismember({'Name','Description','DataSource'},propName))
                        DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
                    end
                end
            end
        end




        function matches=findMatches(entries,args)
            import coder.dictionary.internal.StorageClass.*;
            currentEntries=entries;
            matches={};
            for j=1:length(currentEntries)
                entry=currentEntries(j);
                isMatch=true;
                for i=1:2:length(args)
                    name=convertStringsToChars(args{i});
                    value=convertStringsToChars(args{i+1});
                    if isValidPropertyForSection(name,entry)
                        propValue=getProp(entry,name);
                        isMatch=isMatch&&isequal(propValue,value);
                    else
                        isMatch=false;
                        break;
                    end
                end
                if isMatch
                    matches{end+1}=entry;%#ok<AGROW>
                end
            end
        end
    end
end


