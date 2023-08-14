classdef Model<matlab.mixin.SetGet






    properties(Dependent=true)
Name
    end
    properties(SetAccess=private)
Architecture
SimulinkHandle
Views
    end
    properties(SetAccess=private,Dependent=true)
Profiles
InterfaceDictionary
    end

    properties(Access=private)
        zcModelImpl;
        isProtectedModel;
    end

    methods(Static)
        function mdl=current()
            try
                mdl=systemcomposer.arch.Model(bdroot);
            catch
                mdl=systemcomposer.arch.Model.empty;
            end
        end
    end

    methods
        function obj=Model(modelNameOrHandleOrImpl)



            narginchk(1,1);
            modelName=modelNameOrHandleOrImpl;
            obj.isProtectedModel=false;
            try
                if(isa(modelNameOrHandleOrImpl,'systemcomposer.architecture.model.SystemComposerModel'))
                    obj.SimulinkHandle=-1;
                    mfModel=mf.zero.getModel(modelNameOrHandleOrImpl);
                    modelName=modelNameOrHandleOrImpl.getName;

                    if(~modelNameOrHandleOrImpl.isProtectedModel&&bdIsLoaded(modelName))
                        obj.SimulinkHandle=get_param(modelName,'Handle');
                    elseif(modelNameOrHandleOrImpl.isProtectedModel)
                        obj.isProtectedModel=true;
                    end
                else
                    obj.SimulinkHandle=get_param(modelNameOrHandleOrImpl,'Handle');
                    mfModel=get_param(modelNameOrHandleOrImpl,'SystemComposerMf0Model');
                    modelName=get_param(modelNameOrHandleOrImpl,'Name');
                end


                if isempty(mfModel)
                    error(message('SystemArchitecture:API:NotAnArchitectureModel',modelName));
                end

                obj.zcModelImpl=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mfModel);
            catch causeEx
                ex=MException(...
                'systemcomposer:API:ModelError',...
                message('SystemArchitecture:API:ModelError',modelName).getString());
                ex=ex.addCause(causeEx);
                throw(ex);
            end
        end

        function b=isequal(this,other)

            b=isequal(this.getImpl,other.getImpl);
        end

        function n=get.Name(obj)
            if(obj.isProtectedModel)
                n=obj.zcModelImpl.getName;
            else
                n=get_param(obj.SimulinkHandle,'Name');
            end
        end
        function set.Name(obj,n)
            set_param(obj.SimulinkHandle,'Name',n);
        end

        function arch=get.Architecture(obj)
            compArch=obj.zcModelImpl.getRootArchitecture;
            if isempty(compArch.cachedWrapper)||~isvalid(compArch.cachedWrapper)
                arch=systemcomposer.arch.Architecture(compArch);
            else
                arch=compArch.cachedWrapper;
            end
        end

        function deleteView(obj,viewName)



            view=obj.getView(viewName);
            if~isempty(view)
                view.destroy;
            end
        end

        function view=getView(obj,viewName)

            viewImpl=obj.getImpl.getView(viewName);
            view=systemcomposer.internal.getWrapperForImpl(viewImpl);
        end

        function views=get.Views(obj)
            impls=obj.getImpl.getViews;
            views=systemcomposer.view.View.empty(numel(impls),0);
            for i=1:numel(impls)
                views(i)=systemcomposer.internal.getWrapperForImpl(impls(i));
            end
        end

        function profArray=get.Profiles(obj)
            profimplArray=obj.Architecture.getImpl.p_Model.getProfiles;
            profArray=systemcomposer.profile.Profile.empty;
            for i=1:numel(profimplArray)
                profArray(i)=systemcomposer.profile.Profile.wrapper(profimplArray(i));
            end
        end

        function interfaceDictionary=get.InterfaceDictionary(obj)
            if(obj.isProtectedModel)
                interfaceDictionary=systemcomposer.interface.Dictionary.empty;
                return;
            end

            ddName=get_param(obj.SimulinkHandle,'DataDictionary');
            if isempty(ddName)
                idictImplMF0Model=get_param(obj.SimulinkHandle,'SystemComposerMF0Model');
            else
                ddConn=Simulink.data.dictionary.open(ddName);
                idictImplMF0Model=...
                Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(...
                ddConn.filepath());
            end
            idictImpl=...
            systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(...
            idictImplMF0Model);
            interfaceDictionary=systemcomposer.interface.Element.getObjFromImpl(idictImpl);
        end

        function linkDictionary(obj,dictionaryName)


            persistent p
            if isempty(p)
                p=inputParser;
                addRequired(p,'dictionaryName',@(x)~isempty(x)&&(ischar(x)||(isstring(x)&&(numel(x)==1))));
            end
            parse(p,dictionaryName);


            ddConn=Simulink.data.dictionary.open(dictionaryName);


            currentDD=get_param(obj.SimulinkHandle,'DataDictionary');
            if(~isempty(currentDD))
                try
                    currentDDConn=Simulink.data.dictionary.open(currentDD);
                    if strcmp(currentDDConn.filepath(),ddConn.filepath())

                        return;
                    end
                catch


                end
            end


            if(ischar(dictionaryName))
                dictionaryName=string(dictionaryName);
            end
            if(~endsWith(dictionaryName,".sldd"))
                dictionaryName=dictionaryName+".sldd";
            end
            systemcomposer.InterfaceEditor.linkToDD(get_param(obj.SimulinkHandle,'Name'),'Model',dictionaryName);
        end

        function unlinkDictionary(obj)

            set_param(obj.SimulinkHandle,'DataDictionary','');
        end

        function saveToDictionary(obj,dictionaryName,varargin)



            obj.InterfaceDictionary.saveToDictionary(dictionaryName,varargin{:});
        end

        function open(obj)

            open_system(obj.SimulinkHandle);
        end
        function openViews(obj)

            app=systemcomposer.internal.arch.load(obj.Name);
            archViewsApp=app.getArchViewsAppMgr;
            if(archViewsApp.isStudioOpen)
                archViewsApp.getStudioMgr.show;
            else
                app.getArchViewsAppMgr.open(false);
            end
        end

        function save(obj)

            save_system(obj.Name,'','SaveDirtyReferencedModels',true);
        end

        function close(obj,optCloseArg)




            if nargin==1
                close_system(obj.SimulinkHandle);
            elseif strcmpi(optCloseArg,"force")
                close_system(obj.SimulinkHandle,0);
            else
                close_system(obj.SimulinkHandle);
            end
        end
        function applyProfile(obj,pHdl)

            try
                systemcomposer.profile.Profile.load(pHdl);
            catch ex
                throw(ex);
            end
            obj.Architecture.getImpl.p_Model.addProfile(pHdl);
        end
        function removeProfile(obj,pHdl)

            obj.Architecture.getImpl.p_Model.removeProfile(pHdl);
        end

        function renameProfile(obj,oldProfileName,newProfileName)







            newProfile=systemcomposer.loadProfile(newProfileName);
            profNamespace=obj.getImpl.getProfileNamespace;
            profNamespace.renameProfile(newProfile.getImpl,oldProfileName);
        end


        function iterate(this,iterType,iterFunc,varargin)



            this.Architecture.iterate(iterType,iterFunc,varargin{:});
        end

        elem=lookup(obj,type,val);

        [varargout]=find(this,varargin);

        view=createView(obj,varargin);
    end

    methods(Hidden)
        viewArch=createViewArchitecture(obj,varargin);

        function impl=getImpl(obj)
            impl=obj.zcModelImpl;
        end
    end

end



