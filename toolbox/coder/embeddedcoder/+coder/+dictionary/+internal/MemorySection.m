classdef MemorySection<coder.dictionary.internal.CoderDataEntry




    methods(Static)


        function allprops=getAllProps(entry)
            allprops={'Name','Description','DataSource'};
            if~isa(entry,'coderdictionary.data.LegacyMemorySection')
                allprops=[allprops,{'Comment','PreStatement','PostStatement','StatementsSurround'}];
            end
        end
        function allowedVals=getAllowedPropVals(~,~)
            allowedVals='';
        end
        function setProp(entry,name,value)
            import coder.dictionary.internal.MemorySection.*;
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            hlp.setProp(entry,name,value);
        end

        function out=isValidPropertyForSection(propName,entry)
            props=[{'Name','Description'},coder.dictionary.internal.MemorySection.getAllProps(entry)];
            out=any(ismember(props,propName));
        end



        function checkValidPropertyForSection(propName,entry)
            if~coder.dictionary.internal.MemorySection.isValidPropertyForSection(propName,entry)
                DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
            end
        end


        function checkValidProperty(entry,propName,type)
            props=coder.dictionary.internal.MemorySection.getAllProps(entry);
            if~isa(entry,'coderdictionary.data.LegacyMemorySection')
                if~any(ismember(props,propName))
                    DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
                end
            else

                if strcmp(type,'set')
                    DAStudio.error('SimulinkCoderApp:data:CannotSetLegacyProperties');
                else
                    if~any(ismember(props,propName))
                        DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
                    end
                end
            end
        end



        function matches=findMatches(entries,args)
            import coder.dictionary.internal.MemorySection.*;
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


