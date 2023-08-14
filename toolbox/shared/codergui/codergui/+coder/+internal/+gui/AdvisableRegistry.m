classdef(Sealed)AdvisableRegistry<handle











    properties(Constant,Hidden)
        SINGLETON=coder.internal.gui.AdvisableRegistry()
    end

    properties(GetAccess=public,SetAccess=private)
        RegistryEnabled=false
    end

    properties(Access=private)
        InstanceMap;
        RegistrationCallbacks=cell(0,2)
    end

    methods(Static)
        function advisable=findByClass(className,predicate)

            if nargin>1
                advisables=coder.internal.gui.AdvisableRegistry.findAllByClass(className,predicate);
            else
                advisables=coder.internal.gui.AdvisableRegistry.findAllByClass(className);
            end
            if~isempty(advisables)
                advisable=advisables{1};
            else
                advisable=[];
            end
        end

        function advisables=findAllByClass(className,predicate)

            map=coder.internal.gui.AdvisableRegistry.SINGLETON.InstanceMap;
            if~map.isKey(className)
                advisables={};
                return;
            end
            advisables=map(className);
            if nargin>1&&~isempty(predicate)
                advisables=advisables(cellfun(predicate,advisables));
            end
        end

        function toggleAdvisablesEnabled(enabled,className)

            map=coder.internal.gui.AdvisableRegistry.SINGLETON.InstanceMap;
            if nargin>1
                if map.isKey(className)
                    allValues=map(className);
                else
                    allValues={};
                end
            else
                allValues=map.values();
                allValues=[allValues{:}];
            end

            for i=1:numel(allValues)
                allValues{i}.EnableAdvising=enabled;
            end
        end

        function releaseAdvisables(className)

            if nargin>0
                coder.internal.gui.AdvisableRegistry.SINGLETON.doReleaseAdvisables(className);
            else
                coder.internal.gui.AdvisableRegistry.SINGLETON.doReleaseAdvisables();
            end
        end

        function setRegistryEnabled(enabled)


            coder.internal.gui.AdvisableRegistry.SINGLETON.doSetRegistryEnabled(enabled);
        end

        function callbackDisposer=addRegistrationCallback(callbackFunc,varargin)



            validateattributes(callbackFunc,{'function_handle'},{});
            assert(iscellstr(varargin));%#ok<ISCLSTR> 
            coder.internal.gui.AdvisableRegistry.SINGLETON.doAddCallback(callbackFunc,varargin);

            if nargout>0
                callbackDisposer=onCleanup(@()...
                coder.internal.gui.AdvisableRegistry.SINGLETON.doRemoveCallback(callbackFunc));
            else
                callbackDisposer=[];
            end
        end

        function enabled=isRegistryEnabled()
            enabled=coder.internal.gui.AdvisableRegistry.SINGLETON.RegistryEnabled;
        end
    end

    methods(Access=private)
        function this=AdvisableRegistry()
            this.InstanceMap=containers.Map();
        end

        function doSetRegistryEnabled(this,enabled)
            validateattributes(enabled,{'logical'},{'scalar'});
            this.RegistryEnabled=enabled;
            if~enabled
                this.doReleaseAdvisables();
                this.RegistrationCallbacks=cell(0,2);
            end
        end

        function doReleaseAdvisables(this,className)
            map=this.InstanceMap;
            if nargin>1
                if map.isKey(className)
                    toRelease=className;
                    map.remove(className);
                else
                    toRelease={};
                end
            else
                toRelease=map.values();
                toRelease=[toRelease{:}];
                map.remove(map.keys());
            end
            for i=1:numel(toRelease)
                try
                    toRelease{i}.EnableAdvising=false;
                catch
                end
            end
        end

        function doAddCallback(this,callbackFunc,whitelist)
            this.RegistrationCallbacks(end+1,:)={callbackFunc,whitelist};
        end

        function doRemoveCallback(this,callbackFunc)
            if~isempty(this.RegistrationCallbacks)
                this.RegistrationCallbacks=this.RegistrationCallbacks(this.RegistrationCallbacks(:,1)~=callbackFunc);
            end
        end

        function fireCallbacks(this,advisee)
            adviseeClass=class(advisee);
            for i=1:size(this.RegistrationCallbacks,1)
                whitelist=this.RegistrationCallbacks{i,2};
                if isempty(whitelist)||ismember(adviseeClass,whitelist)||any(cellfun(@(v)isa(advisee,v),whitelist))
                    this.RegistrationCallbacks{i,1}(advisee);
                end
            end
        end
    end

    methods(Access=?coder.internal.gui.Advisable)
        function accepted=register(this,advisable)
            accepted=false;
            if~this.RegistryEnabled
                return;
            end

            accepted=true;
            className=class(advisable);
            if this.InstanceMap.isKey(className)
                existing=this.InstanceMap(className);
                this.InstanceMap(className)={existing{:},advisable};%#ok<CCAT>
            else
                this.InstanceMap(className)={advisable};
            end
            mlock;
            this.fireCallbacks(advisable);
        end

        function unregister(this,advisable)
            if~this.RegistryEnabled
                return;
            end

            className=class(advisable);
            if this.InstanceMap.isKey(className)
                registered=this.InstanceMap(className);
                this.InstanceMap(className)=registered(registered~=advisable);
            end
            if isempty(this.InstanceMap)
                munlock;
            end
        end
    end
end