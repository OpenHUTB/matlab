classdef CoderDataEntry<handle




    methods(Static,Abstract)


        allprops=getAllProps(entry)


        allowedVals=getAllowedPropVals(entry,propName)


        out=isValidPropertyForSection(propName,entry)


        checkValidProperty(entry,propName,type)


        checkValidPropertyForSection(propName,entry)

    end
    methods(Static)


        function value=getProp(entry,currentP,varargin)
            import coder.dictionary.internal.StorageClass.*;
            convertNumeric=true;
            if nargin==3
                convertNumeric=varargin{1};
            end
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            if strcmp(currentP,'MemorySection')
                value=hlp.getProp(entry,currentP);
                if~isempty(value)
                    value=hlp.getProp(value,'Name');
                else
                    value='None';
                end
            elseif strcmp(currentP,'Name')
                if entry.isBuiltin
                    value=hlp.getProp(entry,'Name');
                elseif isa(entry,'coderdictionary.data.LegacyStorageClass')||...
                    isa(entry,'coderdictionary.data.LegacyMemorySection')
                    value=hlp.getProp(entry,'ClassName');
                else
                    value=hlp.getProp(entry,'Name');
                end
            else
                value=hlp.getProp(entry,currentP);
            end
            if isenum(value)
                value=char(value);
            elseif(convertNumeric&&isnumeric(value))
                value=num2str(value);
            end
        end


        function setProp(entry,name,value)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if strcmp(name,'MemorySection')


                if ischar(value)
                    if strcmp(value,'None')
                        value=coderdictionary.data.MemorySection.empty;
                    else
                        value=hlp.findEntry(entry.owner,'MemorySection',value);
                        if isempty(value)
                            DAStudio.error('SimulinkCoderApp:data:CannotResolveNamedEntry',value);
                        end
                    end
                elseif isa(value,'coder.dictionary.Entry')
                    value=value.sourceEntry;
                else
                    DAStudio.error('SimulinkCoderApp:data:InvalidValue',value,name);
                end
            end
            hlp.setProp(entry,name,value);
        end


        function matches=findMatches(entries,args)
            matches=findobj(entries,args);
            if isempty(matches)
                matches={};
            elseif~iscell(matches)
                matches={matches};
            end
        end

        function fc=copy(entry,dest)
            fc=entry.copyTo(dest.CDefinitions);
        end
    end
end
