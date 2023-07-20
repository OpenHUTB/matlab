classdef PropertyListener
















    properties
        Event={};
        Callback=[];
        CallbackTarget=[];
    end

    properties(Constant,Hidden)
        BaseMsgId='physmod:pm_sli:configsetproperty';
    end

    methods

        function obj=PropertyListener(varargin)

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

        function obj=set.Event(obj,anEventList)
            if iscell(anEventList)&&all(cellfun(@(event)ischar(event),anEventList))
                obj.Event=anEventList;
            else
                ME=lGetException(...
                'InvalidArrayOfStrings','Event');
                ME.throw();
            end
        end

        function obj=set.Callback(obj,callback)
            if isa(callback,'function_handle')
                obj.Callback=callback;
            else
                ME=lGetException(...
                'InvalidPropertyValue','Callback','function_handle');
                ME.throw();
            end
        end

        function obj=set.CallbackTarget(obj,target)

            obj.CallbackTarget=target;
        end

    end
end

function ME=lGetException(id,varargin)
    ME=MException(message(...
    [pm.sli.internal.PropertyListener.BaseMsgId,':',id],...
    varargin{:}));
end
