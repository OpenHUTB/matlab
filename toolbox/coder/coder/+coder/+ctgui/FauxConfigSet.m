classdef(Sealed)FauxConfigSet<handle
    properties(Access=private)


javaDataView
    end

    properties(Hidden,SetAccess=private)
dataStructView
    end

    methods
        function this=FauxConfigSet(javaData)
            this.javaDataView=javaData;
            this.dataStructView=coder.ctgui.StructToJavaAdapter(javaData.getRootNode(),[]);
            this.dataStructView.UseCoderTarget=true;
        end

        function this=getConfigSet(this)

        end

        function data=get_param(this,key)
            assert(strcmp(key,'CoderTargetData'));
            data=this.dataStructView;
        end

        function set_param(this,key,~)
            assert(strcmp(key,'CoderTargetData'));
            this.javaDataView.commit();
        end

        function valid=isValidParam(~,key)
            valid=strcmp(key,'CoderTargetData');
        end

        function active=getActiveConfigSet(this)
            active=this.getConfigSet();
        end
    end

    methods(Access={?coder.ctgui.CallbackInterface})
        function setTransientMode(this,useTransientMode)
            this.javaDataView.setTransientMode(useTransientMode);
        end
    end
end