classdef(CaseInsensitiveProperties)AbstractEditor<matlab.mixin.SetGet...
    &matlab.mixin.Copyable...
    &dynamicprops...
    &handle















    properties(AbortSet,SetObservable,GetObservable)

        ActiveTab=0;

        FixedPoint=[];
    end

    events
DialogApplied
    end

    methods
        function set.ActiveTab(obj,value)

            validateattributes(value,{'int32','double'},{'scalar'},'','ActiveTab')
            obj.ActiveTab=value;
        end

    end

    methods

        function disp(this)


            disp(get(this));


        end


        function[b,str]=postApply(this)


            b=true;
            str='';

            notify(this,'DialogApplied',event.EventData);


        end

    end


    methods(Hidden)

        function[b,str]=preApply(~,~)


            b=true;
            str='';





        end

    end

end

