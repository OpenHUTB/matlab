










































classdef IPConfig<hgsetget&fpconfig.DeepCopiable&fpconfig.ReadableMScriptsSerializable

    properties(Access=public,Hidden=true)
m_entries
m_strategy
    end

    methods(Access=public,Hidden=true)
        function obj=IPConfig(varargin)

            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            if(nargin==2)
                strategy=varargin{1};
                lib=varargin{2};
                obj.m_entries=fpconfig.DeepCopiableMap('KeyType','char','ValueType','any');
                obj.m_strategy=strategy;
                obj.populateDefaultSettings(lib);
            else
                obj.m_entries=fpconfig.DeepCopiableMap('KeyType','char','ValueType','any');
                obj.m_strategy=[];
            end
        end





        function populateDefaultSettings(obj,lib)
            lTable=targetcodegen.targetCodeGenerationUtils.getLatencyTable(lib);
            for i=1:length(lTable)
                lEntry=lTable(i);
                ips=obj.m_strategy.constructFromInternalStruct(lEntry);
                obj.m_entries.m_map(ips.getKey())=ips.getValue();
            end
        end

        function customizeWithIPSettings(obj,ipSettings)
            key=ipSettings.getKey();
            if(~obj.m_entries.m_map.isKey(key))
                error('Not a valid key');
            end
            obj.m_entries.m_map(key)=ipSettings.getValue();
        end

        function ipSettings=getIPSettings(obj,varargin)
            key=fpconfig.IPSettings.formKey(varargin{:});
            if(~obj.m_entries.m_map.isKey(key))
                ipSettings=[];
                assert(~isempty(strfind(key,'CONVERT')));
            else
                entry=obj.m_entries.m_map(key);
                ipSettings=obj.m_strategy.constructFromFields(key,entry);
            end
        end






        function customizeOrInsert(obj,varargin)
            [key,isValidNewKey,value]=obj.m_strategy.fromVisualPV(varargin{:});
            if(~obj.m_entries.m_map.isKey(key))
                if(isValidNewKey)


                    baseKey=obj.m_strategy.getBaseKey(key);
                    ips=obj.m_strategy.constructFromFields(key,obj.m_entries.m_map(baseKey));
                else
                    error(message('hdlcommon:targetcodegen:InvalidIPNameDataType'));
                end
            else
                ips=obj.m_strategy.constructFromFields(key,obj.m_entries.m_map(key));




            end
            ips.applyVisualStruct(value);
            obj.m_entries.m_map(key)=ips.getValue();
        end

        function consolidate(obj)
            keys=obj.m_entries.m_map.keys;
            for i=1:length(keys)
                key=keys{i};
                entry=obj.m_entries.m_map(key);
                ips=obj.m_strategy.constructFromFields(key,entry);
                if(ips.isToRemove())
                    obj.m_entries.m_map.remove(key);
                end
            end
        end

        function nonDefaultKeys=getNondefaultIPSettings(obj)
            nonDefaultKeys={};
            keys=obj.m_entries.m_map.keys;
            for i=1:length(keys)
                key=keys{i};
                entry=obj.m_entries.m_map(key);
                ips=obj.m_strategy.constructFromFields(key,entry);
                if(~ips.isDefault())
                    nonDefaultKeys{end+1}=key;%#ok<AGROW>
                end
            end
        end

        function scripts=serializeOutMScripts(obj)
            scripts='';
            nonDefaultKeys=obj.getNondefaultIPSettings();
            for i=1:length(nonDefaultKeys)
                key=nonDefaultKeys{i};
                entry=obj.m_entries.m_map(key);
                ips=obj.m_strategy.constructFromFields(key,entry);
                entryStruct=ips.toStruct();
                argStr='';
                fds=fields(entryStruct);
                for j=1:length(fds)
                    if(j~=1)
                        delimiter=', ';
                    else
                        delimiter='';
                    end
                    field=fds{j};
                    val=entryStruct.(field);
                    if(find(strcmpi(ips.ReadOnlyFields,field)==1))
                        continue;
                    end
                    if(find(strcmpi(ips.KeyFields,field)==1))
                        assert(ischar(val));
                        argStr=sprintf('%s%s ''%s''',argStr,delimiter,val);
                    else
                        if(isempty(val))
                            argStr=sprintf('%s%s''%s'', ''''',argStr,delimiter,field);
                        elseif(isnumeric(val))
                            argStr=sprintf('%s%s''%s'', %d',argStr,delimiter,field,val);
                        else
                            assert(ischar(val));
                            argStr=sprintf('%s%s''%s'', ''%s''',argStr,delimiter,field,val);
                        end
                    end
                end

                if(i~=1)
                    delimiter=', ';
                else
                    delimiter='';
                end
                scripts=sprintf('%s%s{%s} ...\n',scripts,delimiter,argStr);
            end
            scripts=sprintf('{%s}',scripts);
        end

        function disp(obj)







            table=obj.output();
            disp(table);
        end
    end

    methods(Access=public,Hidden=false)
        function customize(obj,varargin)
            assert(iscell(varargin));
            if(ischar(varargin{1}))

                inputs={varargin};
            else

                inputs=varargin{:};
            end
            for i=1:length(inputs)
                obj.customizeOrInsert(inputs{i}{:});
            end
            obj.consolidate();
        end

        function table=output(obj)
            table=obj.outputPrivate(false);
        end

        function table=outputInString(obj)
            table=obj.outputPrivate(true);
        end

        function input(obj,table)
            for i=1:height(table)
                lEntry=table2struct(table(i,:));
                ips=obj.m_strategy.constructFromVisualStruct(lEntry);
                obj.customizeWithIPSettings(ips)
            end
        end

        function inputInString(obj,table)
            for i=1:height(table)
                lEntry=table2struct(table(i,:));
                ips=obj.m_strategy.constructFromVisualStructInString(lEntry);
                obj.customizeWithIPSettings(ips)
            end
        end

        function populateDefaultLibSettings(obj,lib,strategy)
            obj.m_strategy=strategy;
            obj.populateDefaultSettings('NATIVEFLOATINGPOINT');
        end
    end

    methods(Access=private)
        function table=outputPrivate(obj,inString)
            keys=obj.m_entries.m_map.keys;
            if(isempty(keys))
                table=[];
                return;
            else
                for i=1:length(keys)
                    key=keys{i};
                    entry=obj.m_entries.m_map(key);
                    try
                        ips=obj.m_strategy.constructFromFields(key,entry);
                    catch me
                    end
                    if(inString)
                        lEntry=ips.toStructInString();
                    else
                        lEntry=ips.toStruct();
                    end
                    if(i==1)
                        lTable=lEntry;
                    else
                        lTable(end+1)=lEntry;%#ok<AGROW>
                    end
                end
                table=struct2table(lTable);
            end
        end
    end
end

