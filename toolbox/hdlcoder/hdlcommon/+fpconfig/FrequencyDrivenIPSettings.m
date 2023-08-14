


classdef FrequencyDrivenIPSettings<fpconfig.IPSettings
    properties(Constant)
        LatencyDefault=-1;
        ExtraArgsDefault='';
    end

    properties
        Name;
        DataType;
        Latency;
        ExtraArgs;
    end

    methods(Static)
        function fds=ReadWriteFields
            fds={'Latency','ExtraArgs'};
        end

        function fds=ReadOnlyFields
            fds={};
        end

        function fds=ValueFields
            fds={'Latency','ExtraArgs'};
        end

        function fds=KeyFields
            fds={'Name','DataType'};
        end

        function type=getFieldType(field)
            switch(field)
            case{'Name','DataType','ExtraArgs'}
                type='char';
            case{'Latency'}
                type='double';
            otherwise
                assertion(false);
            end
        end
    end

    methods

        function obj=FrequencyDrivenIPSettings(varargin)
            obj@fpconfig.IPSettings(varargin{:});
        end

        function obj=set.Name(obj,val)
            fpconfig.FrequencyDrivenIPSettings.validateName(val);
            obj.Name=val;
        end

        function obj=set.DataType(obj,val)
            fpconfig.FrequencyDrivenIPSettings.validateDataType(val);
            obj.DataType=val;
        end

        function obj=set.Latency(obj,val)
            fpconfig.FrequencyDrivenIPSettings.validateLatency(val);
            obj.Latency=int32(val);
        end

        function obj=set.ExtraArgs(obj,val)
            fpconfig.FrequencyDrivenIPSettings.validateExtraArgs(val);
            obj.ExtraArgs=val;
        end

        function disp(obj)
            s=obj.toStruct();
            if(isempty(s.ExtraArgs)&&~isempty(s.Name))
                s.ExtraArgs={''};
            end
            t=struct2table(s);
            disp(t);
        end

        function fromInternalStruct(obj,lEntry)
            obj.Name=lEntry.name;
            obj.DataType=lEntry.dataType;
            obj.Latency=-1;
            obj.ExtraArgs='';
        end

        function result=isDefault(this)
            result=isequal(this.Latency,fpconfig.FrequencyDrivenIPSettings.LatencyDefault)...
            &&isequal(this.ExtraArgs,fpconfig.FrequencyDrivenIPSettings.ExtraArgsDefault);
        end

        function result=isToRemove(this)
            result=false;
            if(strcmpi(this.Name,'CONVERT')&&...
                ~strcmpi(this.DataType,'DOUBLE_TO_NUMERICTYPE')&&...
                ~strcmpi(this.DataType,'SINGLE_TO_NUMERICTYPE')&&...
                ~strcmpi(this.DataType,'NUMERICTYPE_TO_DOUBLE')&&...
                ~strcmpi(this.DataType,'NUMERICTYPE_TO_SINGLE'))
                if(this.Latency==-1&&isempty(this.ExtraArgs))
                    result=true;
                end
            end
        end
    end

    methods(Static)
        function obj=constructFromVisualStruct(lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings();
            obj.fromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings();
            obj.fromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings();
            obj.fromInternalStruct(lEntry);
        end

        function obj=constructDefault()
            obj=fpconfig.FrequencyDrivenIPSettings();
        end

        function[key,validNewKey,value]=fromVisualPV(varargin)
            p=inputParser;
            p.addRequired('Name',@fpconfig.FrequencyDrivenIPSettings.validateName);
            p.addRequired('DataType',@fpconfig.FrequencyDrivenIPSettings.validateDataType);
            p.addParameter('Latency',-2,@fpconfig.FrequencyDrivenIPSettings.validateLatency);
            p.addParameter('ExtraArgs','N/A',@fpconfig.FrequencyDrivenIPSettings.validateExtraArgs);
            p.parse(varargin{:});


            validNewKey=fpconfig.FrequencyDrivenIPSettings.validateNewKey(p.Results.Name,p.Results.DataType);
            key=fpconfig.IPSettings.formKey(p.Results.Name,p.Results.DataType);
            value=p.Results;
            if(value.Latency==-2)
                value=rmfield(value,'Latency');
            end
            if(strcmpi(value.ExtraArgs,'N/A'))
                value=rmfield(value,'ExtraArgs');
            end
        end

        function valid=validateNewKey(name,dataTypeStr)
            if(~strcmpi(name,'CONVERT'))
                if(strcmpi(dataTypeStr,'double')||strcmpi(dataTypeStr,'single'))
                    valid=false;
                else
                    error(message('hdlcommon:targetcodegen:InvalidFPTypeString'));
                end
            else
                valid=true;
            end
        end

        function baseKey=getBaseKey(key)
            keyElements=fpconfig.IPSettings.parseKey(key);
            name=keyElements{1};
            dataType=keyElements{2};
            assert(strcmpi(name,'CONVERT'));
            [from,to]=fpconfig.FrequencyDrivenIPSettings.parseConvDataTypeString(dataType);
            if(strcmpi(from,'double')||strcmpi(from,'single'))
                baseType=[from,'_TO_NUMERICTYPE'];
            else
                assert((strcmpi(to,'double')||strcmpi(to,'single')));
                baseType=['NUMERICTYPE_TO_',to];
            end
            baseKey=fpconfig.IPSettings.formKey(name,baseType);
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
            if(strcmpi(val,'double')||strcmpi(val,'single'))
                return;
            end
            [from,to]=fpconfig.FrequencyDrivenIPSettings.parseConvDataTypeString(val);
            if(isempty(from)||isempty(to))
                error(message('hdlcommon:targetcodegen:InvalidFPTypeString'));
            end
        end

        function validateLatency(val)
            if(~isnumeric(val)||val<-1)
                error(message('hdlcommon:targetcodegen:InvalidLatency'));
            end
        end

        function validateExtraArgs(val)
            if(~ischar(val))
                error(message('hdlcommon:targetcodegen:InvalidExtraArgs'));
            end
        end

        function[from,to]=parseConvDataTypeString(str)
            from=[];
            to=[];
            str=regexprep(str,'\s','');
            pat='^(numerictype(?:\(\d+,\d+,-*\d+\))?)_to_(double|single)$';
            results=regexpi(str,pat,'tokens','once');
            if(~isempty(results))
                from=results{1};
                if(length(results)>1)
                    to=results{2};
                end
                return;
            end
            pat='^(double|single)_to_(numerictype(?:\(\d+,\d+,-*\d+\))?)$';
            results=regexpi(str,pat,'tokens','once');
            if(~isempty(results))
                from=results{1};
                if(length(results)>1)
                    to=results{2};
                end
                return;
            end
        end
    end
end

