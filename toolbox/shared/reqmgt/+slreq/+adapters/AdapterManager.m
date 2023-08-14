classdef AdapterManager<handle



    properties(Access=public)
        adapterMap=containers.Map('KeyType','char','ValueType','Any');
    end

    methods(Access=private)
        function this=AdapterManager()
        end
    end

    methods(Access=public)
        function adapter=getAdapterByDomain(this,domain)

            if isKey(this.adapterMap,domain)
                adapter=this.adapterMap(domain);
                return;
            end

            switch domain
            case 'linktype_rmi_slreq'
                adapter=slreq.adapters.SLReqAdapter();
            case 'linktype_rmi_simulink'
                adapter=slreq.adapters.SLAdapter();
            case 'linktype_rmi_testmgr'
                adapter=slreq.adapters.TestManagerAdapter();
            case 'linktype_rmi_data'
                adapter=slreq.adapters.SLDDAdapter();
            case 'linktype_rmi_matlab'
                if slreq.internal.isSharedSlreqInstalled()
                    adapter=slreq.adapters.MATLABAdapter();
                else
                    adapter=[];
                end
            case 'linktype_rmi_url'
                adapter=slreq.adapters.URLAdapter();
            case 'linktype_rmi_text'
                adapter=slreq.adapters.TextAdapter();
            case 'linktype_rmi_html'
                adapter=slreq.adapters.HTMLAdapter();
            case 'linktype_rmi_oslc'
                adapter=slreq.adapters.OSLCAdapter();
            case 'linktype_rmi_safetymanager'
                adapter=slreq.adapters.SafetyManagerAdapter();
            otherwise


                adapter=slreq.adapters.ExternalDomainAdapter(domain);
            end
            if~isempty(adapter)
                this.adapterMap(domain)=adapter;
            end
        end

        function reset(this)
            this.adapterMap=containers.Map('KeyType','char','ValueType','Any');
        end
    end

    methods(Static)
        function this=getInstance()
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=slreq.adapters.AdapterManager();
            end
            this=instance;
        end
    end
end
