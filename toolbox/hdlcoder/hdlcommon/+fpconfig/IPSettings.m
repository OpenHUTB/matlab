


classdef IPSettings<hgsetget&fpconfig.DeepCopiable

    properties
    end

    methods(Static=true,Abstract=true)
        fds=ReadWriteFields
        fds=ReadOnlyFields
        fds=ValueFields
        fds=KeyFields
        type=getFieldType(field)
    end

    methods
        function obj=IPSettings(varargin)
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
            for i=1:length(obj.ValueFields)
                obj.(obj.ValueFields{i})=varargin{2}{i};
            end
        end

        function key=getKey(obj)
            assert(~isempty(obj.KeyFields));
            field=obj.KeyFields{1};
            key=obj.(field);
            for i=2:length(obj.KeyFields)
                field=obj.KeyFields{i};
                key=fpconfig.IPSettings.formKey(key,obj.(field));
            end
        end

        function val=getValue(obj)
            val={};
            for i=1:length(obj.ValueFields)
                val={val{:},obj.(obj.ValueFields{i})};%#ok<CCAT>
            end
        end

        function lEntry=toStruct(obj)
            fds=obj.getAllFields(obj);
            for i=1:length(fds)
                lEntry.(fds{i})=obj.(fds{i});
            end
        end

        function lEntry=toStructInString(obj)
            fds=obj.getAllFields(obj);
            for i=1:length(fds)
                f=fds{i};
                v=obj.(f);
                if(strcmpi(obj.getFieldType(f),'double'))
                    v=num2str(v);
                else
                    assert(ischar(v));
                end
                lEntry.(fds{i})=v;
            end
        end

        function fromVisualStruct(obj,lEntry)
            fds=obj.getAllFields(obj);
            for i=1:length(fds)
                obj.(fds{i})=lEntry.(fds{i});
            end
        end

        function fromVisualStructInString(obj,lEntry)
            fds=obj.getAllFields(obj);
            for i=1:length(fds)
                f=fds{i};
                v=lEntry.(f);
                t=obj.getFieldType(f);
                if(strcmpi(t,'double'))
                    v=str2double(v);
                else
                    assert(ischar(v));
                end
                obj.(f)=v;
            end
        end

        function applyVisualStruct(obj,lEntry)
            fds=fields(lEntry);
            for i=1:length(fds)
                field=fds{i};
                if(~isempty(find(strcmp(obj.ReadWriteFields,field),1)))
                    val=lEntry.(field);
                    obj.(field)=val;
                end
            end
        end
    end

    methods(Abstract=true)
        disp(obj)
        fromInternalStruct(obj,lEntry)
        isToRemove(obj)
        isDefault(obj)
    end

    methods(Static=true,Access=private)
        function fds=getAllFields(obj)
            fds=[obj.KeyFields,obj.ValueFields];
        end
    end

    methods(Static)

        function keyElements=parseKey(key)

            pivot=strfind(key,'#');
            assert(~isempty(pivot));
            start=1;
            keyElements=cell(1,length(pivot)+1);
            for i=1:length(pivot)
                keyElements{i}=key(start:pivot(i)-1);
                start=pivot(i)+1;
            end
            keyElements{end}=key(start:end);
        end

        function key=formKey(key,part)
            key=sprintf('%s#%s',upper(regexprep(key,'\s','')),upper(regexprep(part,'\s','')));
        end
    end

    methods(Static=true,Abstract=true)
        obj=constructFromVisualStruct(lEntry)
        obj=constructFromVisualStructInString(lEntry)
        obj=constructFromInternalStruct(lEntry)
        [key,validNewKey,value]=fromVisualPV(varargin)
        valid=validateNewKey(name,dataTypeStr)
        baseKey=getBaseKey(key)
    end
end

