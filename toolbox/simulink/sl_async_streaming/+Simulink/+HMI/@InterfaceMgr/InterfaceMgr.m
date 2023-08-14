



classdef InterfaceMgr<handle


    methods


        function mi=getModelInterface(this,mdl)



            narginchk(2,2);
            if~ischar(mdl)
                DAStudio.error('SimulinkHMI:errors:InterMgrMdlNameArg');
            end


            if this.MdlInterfaceMap_.isKey(mdl)
                mi=this.MdlInterfaceMap_(mdl);
            else
                mi=Simulink.HMI.ModelInterface(mdl);
                this.MdlInterfaceMap_(mdl)=mi;
            end

        end

    end


    methods(Static=true)


        function mgr=getInterfaceMgr(bReset)

            persistent hmiMgr;
            mlock;


            if isempty(hmiMgr)||(nargin>0&&bReset)||~isvalid(hmiMgr)
                hmiMgr=Simulink.HMI.InterfaceMgr;
            end


            mgr=hmiMgr;
        end


        function reset()

            Simulink.HMI.InterfaceMgr.getInterfaceMgr(true);
        end
    end


    methods(Hidden=true)


        function obj=InterfaceMgr()
            obj.MdlInterfaceMap_=containers.Map;
        end


        function delete(this)
            if~isempty(this.Listeners_)
                delete(this.Listeners_);
            end
        end


        function registerListeners(this)
            if isempty(this.Listeners_)
                eng=Simulink.sdi.Instance.engine;
                this.Listeners_=event.listener(...
                eng,...
                'runMetaDataUpdated',...
                @(x,data)onRunMetaDataUpdated(this,data));
            end
        end


        function removeModel(this,mdl)

            this.clearStaleModelInterface(mdl);
        end


        function clearStaleModelInterface(this,mdl)

            try
                mi=this.MdlInterfaceMap_(mdl);
                this.MdlInterfaceMap_.remove(mdl);
                delete(mi);
            catch me %#ok<NASGU>



            end
        end


        function renameModel(this,priorName,newName)





            if this.MdlInterfaceMap_.isKey(priorName)
                mi=this.MdlInterfaceMap_(priorName);
                this.MdlInterfaceMap_.remove(priorName);
                if~this.MdlInterfaceMap_.isKey(newName)
                    this.MdlInterfaceMap_(newName)=mi;
                else
                    mi=this.MdlInterfaceMap_(newName);
                end
                mi.renameModel(priorName,newName);
            end
        end


        function setGetWebHMIMethod(this,fcnHandle)
            this.GetWebHMI=fcnHandle;
        end

        function webhmi=getWebHMI(this,modelHandle)
            if~isempty(this.GetWebHMI)
                webhmi=this.GetWebHMI(modelHandle);
            else
                webhmi=[];
            end
        end


        function onRunMetaDataUpdated(~,data)
            try
                if bdIsLoaded(data.modelName)
                    Simulink.HMI.WebHMI.fitToViewScopes(get_param(data.modelName,'Handle'))
                end
            catch me %#ok<NASGU>

            end
        end
    end


    properties(Hidden=true)
MdlInterfaceMap_
GetWebHMI
Listeners_
    end

end


