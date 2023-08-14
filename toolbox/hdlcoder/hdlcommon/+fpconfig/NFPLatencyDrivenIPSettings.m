


classdef NFPLatencyDrivenIPSettings<fpconfig.IPSettings

    properties(Constant)
        LatencyDefault=-1;
    end

    properties
        Name;
        DataType;
        MaxLatency;
        MinLatency;

        CustomLatency;

    end

    methods(Static)
        function fds=ReadWriteFields
            fds={'CustomLatency'};
        end

        function fds=ReadOnlyFields
            fds={'MaxLatency','MinLatency'};
        end

        function fds=ValueFields


            fds={'MaxLatency','MinLatency','CustomLatency'};
        end

        function fds=KeyFields
            fds={'Name','DataType'};
        end

        function type=getFieldType(field)
            switch(field)
            case{'Name','DataType'}
                type='char';
            case{'MaxLatency','MinLatency','CustomLatency'}
                type='double';
            otherwise
                assertion(false);
            end
        end
    end

    methods
        function obj=NFPLatencyDrivenIPSettings(varargin)
            if(nargin==2)
                keyElements=fpconfig.IPSettings.parseKey(varargin{1});
            elseif(nargin==0)
                return;
            else
                error(message('hdlcommon:targetcodegen:IPSettingsWrongUsage'));
            end

            for i=1:length(obj.KeyFields)
                obj.(obj.KeyFields{i})=keyElements{i};
            end


            numFields=numel(varargin{2});
            for i=1:length(obj.ValueFields)
                if i>numFields
                    val=fpconfig.NFPLatencyDrivenIPSettings.LatencyDefault;
                else
                    val=varargin{2}{i};
                end
                obj.(obj.ValueFields{i})=val;

            end
        end

        function obj=set.Name(obj,val)
            fpconfig.NFPLatencyDrivenIPSettings.validateName(val);
            obj.Name=val;
        end

        function obj=set.DataType(obj,val)
            fpconfig.NFPLatencyDrivenIPSettings.validateDataType(val);
            obj.DataType=val;
        end

        function obj=set.CustomLatency(obj,val)
            fpconfig.NFPLatencyDrivenIPSettings.validateLatency(val);
            obj.CustomLatency=int32(val);
        end

        function obj=set.MaxLatency(obj,val)
            fpconfig.NFPLatencyDrivenIPSettings.validateLatency(val);
            obj.MaxLatency=int32(val);
        end

        function obj=set.MinLatency(obj,val)
            fpconfig.NFPLatencyDrivenIPSettings.validateLatency(val);
            obj.MinLatency=int32(val);
        end

        function disp(obj)
            s=obj.toStruct();
            t=struct2table(s);
            disp(t);
        end

        function fromInternalStruct(obj,lEntry)
            obj.Name=lEntry.name;
            obj.DataType=lEntry.dataType;
            obj.CustomLatency=fpconfig.NFPLatencyDrivenIPSettings.LatencyDefault;
            obj.MaxLatency=lEntry.maxLatency;
            obj.MinLatency=lEntry.minLatency;
        end

        function result=isDefault(this)

            result=isequal(this.CustomLatency,fpconfig.NFPLatencyDrivenIPSettings.LatencyDefault);
        end

        function result=isToRemove(this)

            result=false;
        end
    end

    methods(Static)
        function obj=constructFromVisualStruct(lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings();
            obj.fromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings();
            obj.fromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings();
            obj.fromInternalStruct(lEntry);
        end

        function validateName(val)
            if(~ischar(val))
                error(message('hdlcommon:targetcodegen:InvalidIPName'));
            end
        end

        function validateDataType(val)
            if(~ischar(val))
                error(message('hdlcommon:targetcodegen:InvalidFPTypeString'));
            end
            if(isempty(regexprep(val,'\s','')))
                return;
            end

            if(strcmpi(val,'single'))
                return;
            end
        end

        function validateLatency(val)
            if(~isnumeric(val)||val<-1)
                error(message('hdlcommon:targetcodegen:InvalidLatency'));
            end
        end

        function validateCustomLatency(obj,val)
            if(isnumeric(val)&&(val>obj.MaxLatency))
                error(message('hdlcommon:nativefloatingpoint:NFPCustomizedLatencyError',...
                val,lower(obj.DataType),obj.Name,obj.MaxLatency));
            end
            if~any(contains({'ADDSUB','MUL','DIV','CONVERT','RELOP','RECIP','SQRT','RSQRT',...
                'ROUNDING','FIX','GAINPOW2'},upper(obj.Name)))
                error(message('hdlcommon:nativefloatingpoint:NFPCustomizedLatencyIPError',...
                lower(obj.DataType),obj.Name));
            end
        end

        function obj=constructDefault()
            obj=fpconfig.NFPLatencyDrivenIPSettings();
        end

        function[key,validNewKey,value]=fromVisualPV(varargin)%#ok<*STOUT>


            p=inputParser;
            p.addRequired('Name',@fpconfig.NFPLatencyDrivenIPSettings.validateName);
            p.addRequired('DataType',@fpconfig.NFPLatencyDrivenIPSettings.validateDataType);
            p.addParameter('CustomLatency',-2,@fpconfig.NFPLatencyDrivenIPSettings.validateLatency);
            p.parse(varargin{:});


            validNewKey=fpconfig.NFPLatencyDrivenIPSettings.validateNewKey(p.Results.Name,p.Results.DataType);
            key=fpconfig.IPSettings.formKey(p.Results.Name,p.Results.DataType);
            value=p.Results;
            if(value.CustomLatency==-2)
                value=rmfield(value,'CustomLatency');
            end
        end


        function valid=validateNewKey(name,dataTypeStr)
            if(~strcmpi(name,'CONVERT'))
                if(strcmpi(dataTypeStr,'double')||strcmpi(dataTypeStr,'single'))
                    valid=false;
                else
                    error(message('hdlcommon:nativefloatingpoint:InvalidFPTypeString',name,dataTypeStr));
                end
            else
                if strcmpi(dataTypeStr,'SINGLE_TO_NUMERICTYPE')||...
                    strcmpi(dataTypeStr,'NUMERICTYPE_TO_SINGLE')||...
                    strcmpi(dataTypeStr,'DOUBLE_TO_NUMERICTYPE')||...
                    strcmpi(dataTypeStr,'NUMERICTYPE_TO_DOUBLE')||...
                    strcmpi(dataTypeStr,'DOUBLE_TO_SINGLE')||...
                    strcmpi(dataTypeStr,'SINGLE_TO_DOUBLE')
                    valid=false;
                else
                    error(message('hdlcommon:nativefloatingpoint:InvalidFPTypeString',name,dataTypeStr));
                end
            end
        end


        function getBaseKey(key)


        end
    end

    methods(Access=public,Hidden=true)
        function obj=construct(~)
            obj=fpconfig.NFPLatencyDrivenIPSettings();
        end
    end

    methods
        function applyVisualStruct(obj,lEntry)
            fds=fields(lEntry);
            for i=1:length(fds)
                field=fds{i};
                if(~isempty(find(strcmp(obj.ReadWriteFields,field),1)))
                    val=lEntry.(field);
                    obj.(field)=val;
                    if strcmpi(field,'CustomLatency')
                        obj.validateCustomLatency(obj,val);
                    end
                end
            end
        end
    end
end

