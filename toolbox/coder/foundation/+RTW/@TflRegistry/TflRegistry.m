


classdef TflRegistry<RTW.RegistryObject


















    properties(AbortSet,SetObservable,GetObservable)

        Name='';

        Alias={};

        Description='';

        BaseTfl='';

        TableList={};

        TargetCharacteristics=[];

        IsVisible=true;

        OverrideLangStdTfls=false;

        LanguageConstraint={};

        GenerateSharedUtilsError=false;
    end

    properties(Dependent,AbortSet,SetObservable,GetObservable)

        TargetHWDeviceType;
    end

    properties(Access=private)
        PrivTargetHWDeviceType={'*'};
    end

    properties(SetAccess=protected,AbortSet,SetObservable,GetObservable)

        IsSimTfl=false;

        IsLangStdTfl=false;

        IsERTOnly=true;
    end

    properties(Hidden)



        TargetToolchain={};
    end

    methods
        function h=TflRegistry(varargin)























            mlock;

            h.TargetCharacteristics=RTW.TargetCharacteristics;


            if nargin==1
                mode=varargin{1};
                if strcmp(mode,'SIM')
                    h.IsSimTfl=true;
                    h.IsVisible=false;
                    h.IsERTOnly=false;
                elseif strcmp(mode,'RTW')
                    h.IsERTOnly=false;
                elseif strcmp(mode,'LANGSTD')
                    h.IsERTOnly=false;
                    h.IsLangStdTfl=true;
                    h.IsVisible=false;
                end
            end







        end

    end

    methods
        function set.Name(obj,value)

            validateattributes(value,{'char','string'},{'row'},'','Name')
            value=convertStringsToChars(value);
            obj.Name=value;
        end

        function set.Alias(obj,value)



            if isstring(value)
                value=cellstr(value);
            end

            value=reshape(value,length(value),1);
            obj.Alias=value;
        end

        function set.Description(obj,value)

            validateattributes(value,{'char','string'},{'row'},'','Description')
            value=convertStringsToChars(value);
            obj.Description=value;
        end

        function set.BaseTfl(obj,value)

            validateattributes(value,{'char','string'},{'row'},'','BaseTfl')
            value=convertStringsToChars(value);
            obj.BaseTfl=value;
        end

        function val=get.TargetHWDeviceType(obj)
            val=obj.PrivTargetHWDeviceType;
        end

        function set.TargetHWDeviceType(obj,value)

            if isstring(value)
                value=cellstr(value);
            end

            if(obj.IsLangStdTfl&&...
                (~ischar(value{:})||~strcmpi(value{:},'*')))
                error('TargetHWDeviceType should only be set to {''*''} for language standard CRLs.');
            else


                value=reshape(value,length(value),1);
                obj.PrivTargetHWDeviceType=value;
            end
        end

        function set.TableList(obj,value)



            if isstring(value)
                value=cellstr(value);
            end

            value=reshape(value,length(value),1);
            obj.TableList=value;

        end

        function set.TargetCharacteristics(obj,value)

            validateattributes(value,{'RTW.TargetCharacteristics'},{'scalar'},'','TargetCharacteristics')
            obj.TargetCharacteristics=value;
        end

        function set.IsSimTfl(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','IsSimTfl')
            obj.IsSimTfl=value;
        end

        function set.IsERTOnly(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','IsERTOnly')
            obj.IsERTOnly=value;
        end

        function set.OverrideLangStdTfls(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','OverrideLangStdTfls')
            obj.OverrideLangStdTfls=value;
        end

        function set.IsVisible(obj,value)

            validateattributes(value,{'logical'},{'scalar'},'','IsVisible')
            obj.IsVisible=value;
        end

        function set.LanguageConstraint(obj,value)



            if isstring(value)
                value=cellstr(value);
            end

            value=reshape(value,length(value),1);
            obj.LanguageConstraint=value;
        end

    end

    methods
        cpy=getcopy(h)
    end


    methods(Hidden)
        [ret,langConstraint]=isCompliantWithTargetLang(h,hTarget,varargin)
    end

end

