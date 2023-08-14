classdef ConfigsetProperty
































    properties(Constant,Hidden)
        BaseMsgId='physmod:pm_sli:configsetproperty';
    end

    properties
        Name='';
        Label='';
        DataType='';
        DefaultValue='';
        DisplayStrings={};
        Group='';
        GroupDesc='';
        Visible=true;
        Enabled=true;
        RowWithButton=false;
        MatlabMethod='';
        Listener=pm.sli.internal.PropertyListener();
        SetFcn=@(a,b)(b);
        IgnoreCompare=false;
        IsPrototype=false;
    end

    methods

        function obj=ConfigsetProperty(varargin)


            for idx=1:2:(nargin-1)
                if~isvarname(varargin{idx})||mod(nargin,2)
                    ME=lGetException('InvalidOptionalArguments');
                    ME.throw()
                else
                    try
                        obj.(varargin{idx})=varargin{idx+1};
                    catch ME
                        ME.throwAsCaller();
                    end
                end
            end

        end

        function obj=set.Name(obj,name)
            if isvarname(name)
                obj.Name=name;
            else
                ME=MException(message('MATLAB:class:IllegalPropertyName'));
                ME.throw();
            end
        end

        function obj=set.IgnoreCompare(obj,enabled)
            if islogical(enabled)
                obj.IgnoreCompare=enabled;
            else
                ME=lGetException(...
                'InvalidPropertyValue','IgnoreCompare','logical');
                ME.throw();
            end
        end

        function obj=set.Label(obj,aLabel)
            if ischar(aLabel)
                obj.Label=aLabel;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Label','string');
                ME.throw();
            end
        end

        function obj=set.DataType(obj,aType)
            if ischar(aType)
                obj.DataType=aType;
            else
                ME=lGetException(...
                'InvalidPropertyValue','DataType','string');
                ME.throw();
            end
        end

        function obj=set.RowWithButton(obj,enabled)
            if islogical(enabled)
                obj.RowWithButton=enabled;
            else
                ME=lGetException(...
                'InvalidPropertyValue','RowWithButton','logical');
                ME.throw();
            end
        end

        function obj=set.DisplayStrings(obj,aCellOfStrings)
            if iscell(aCellOfStrings)&&(isempty(aCellOfStrings)||all(cellfun(@(theCell)ischar(theCell),aCellOfStrings)))
                obj.DisplayStrings=aCellOfStrings;
            else
                ME=lGetException(...
                'InvalidArrayOfStrings','DisplayStrings');
                ME.throw();
            end
        end

        function obj=set.Group(obj,aGroup)
            if ischar(aGroup)
                obj.Group=aGroup;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Group','string');
                ME.throw();
            end
        end

        function obj=set.GroupDesc(obj,aDescription)
            if ischar(aDescription)
                obj.GroupDesc=aDescription;
            else
                ME=lGetException(...
                'InvalidPropertyValue','GroupDesc','string');
                ME.throw();
            end
        end

        function obj=set.Visible(obj,visible)
            if islogical(visible)
                obj.Visible=visible;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Visible','logical');
                ME.throw();
            end
        end

        function obj=set.Enabled(obj,enabled)
            if islogical(enabled)||isa(enabled,'function_handle')
                obj.Enabled=enabled;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Enabled','logical||function_handle');
                ME.throw();
            end
        end

        function obj=set.MatlabMethod(obj,m)
            if ischar(m)
                obj.MatlabMethod=m;
            else
                ME=lGetException(...
                'InvalidPropertyValue','MatlabMethod','string');
                ME.throw();
            end
        end

        function obj=set.Listener(obj,aListener)
            if(isa(aListener,'pm.sli.internal.PropertyListener'))
                obj.Listener=aListener;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Listener','pm.sli.internal.PropertyListener');
                ME.throw();
            end
        end

        function obj=set.SetFcn(obj,aFcn)
            if isa(aFcn,'function_handle')
                obj.SetFcn=aFcn;
            else
                ME=lGetException(...
                'InvalidPropertyValue','SetFcn','function_handle');
                ME.throw();
            end
        end

        function obj=set.IsPrototype(obj,isProto)
            if islogical(isProto)
                obj.IsPrototype=isProto;
            else
                ME=lGetException(...
                'InvalidPropertyValue','IsPrototype','logical');
                ME.throw();
            end
        end
    end
end

function ME=lGetException(id,varargin)
    ME=MException(message(...
    [pm.sli.internal.ConfigsetProperty.BaseMsgId,':',id],...
    varargin{:}));
end
