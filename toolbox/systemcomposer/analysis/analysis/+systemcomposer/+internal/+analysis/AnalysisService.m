classdef AnalysisService<handle




    properties(Access='private')
        Viewers={};
        Models={};
    end

    methods(Static,Access='private')
        function def=getDefinition(instance,setName,propertyName)
            vs=instance.propertyValues.toArray;
            ps=vs.values.getByKey(setName);
            val=ps.values.getByKey(propertyName);
            def=val.usage.propertyDef;
        end
    end

    methods(Static)
        function instanceDeleted(modelUUID)
            try
                i=systemcomposer.internal.analysis.AnalysisService.getInstance();
                uuid=[];
                v=i.getViewer();
                if~isempty(v)
                    uuid=v.getUUID;
                end
                didIt=i.removeInstanceWithModelUUID(modelUUID,false);
                if didIt
                    if~isempty(v)
                        v.instanceDeletionAlert(uuid);
                    end
                end
            catch ex
            end
        end

        function makeReport(architectureInstanceUUID,report)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            if~isempty(i)

                v=i.getViewer();
                if~isempty(v)
                    instanceUUID=v.getUUID();
                    if strcmp(instanceUUID,architectureInstanceUUID)

                        v.handleChanges(report);
                    end
                end
            end
        end


        function newInstanceModel(varargin)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();


            spec=v.getArchitecture();
            internal.systemcomposer.Instantiator.launch(spec,varargin{:});
        end

        function loadExistingModel(architectureInstanceUUID,fn,args,mode)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            instance=i.findInstanceFromUUID(architectureInstanceUUID);
            v=i.getViewer();
            v.setInstance(instance,fn,args,mode);
        end

        function instance=loadInstanceModelAPI(filename,overwrite)
            load(filename,'str');
            parser=mf.zero.io.XmlParser;
            elements=parser.parseString(str);
            m=mf.zero.getModel(elements(1));


            tl=m.topLevelElements;
            instance=[];
            for e=tl
                if isa(e,'systemcomposer.internal.analysis.ArchitectureInstance')
                    instance=e;
                    break;
                end
            end

            if isempty(instance)
                return;
            end


            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            openInstances=i.getInstanceList;
            currentInstanceOpen=false;
            for oi=1:length(openInstances)
                if strcmp(openInstances{oi}.uuid,instance.UUID)
                    currentInstanceOpen=true;
                    foundInstance=i.findInstanceFromUUID(openInstances{oi}.uuid);
                    break;
                end
            end

            try
                if currentInstanceOpen

                    if overwrite

                        i.removeInstanceWithUUID(instance.UUID);


                        i.addListenersForInstance(instance);
                        v=i.getViewer();
                        if~isempty(v)

                            currentInstance=v.getInstance;
                            if~isempty(currentInstance)&&strcmp(currentInstance.getUUID,instance.UUID)
                                v.setInstance(instance,instance.analysisFunctionName,instance.arguments,instance.direction);
                            end
                        else
                            i.addInstanceModelInternal(instance);
                        end
                    else

                        instance=foundInstance;
                    end
                else
                    i.addListenersForInstance(instance);
                    i.addInstanceModelInternal(instance);
                end
            catch ex
                msgObj=message('SystemArchitecture:Analysis:CantLoadWithoutArchitecture');
                error('systemcomposer:analysis:cantLoadWithoutArchitecture',msgObj.getString);
            end
        end

        function loadInstanceModel(fn,args,mode)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            [filename,pathname]=uigetfile(...
            {'*.mat','Instance Models (*.mat)'},...
            'Choose an Instance Model');
            if ischar(filename)


                load(filename,'str');
                parser=mf.zero.io.XmlParser;
                elements=parser.parseString(str);
                m=mf.zero.getModel(elements(1));

                tl=m.topLevelElements;
                instance=[];
                for e=tl
                    if isa(e,'systemcomposer.internal.analysis.ArchitectureInstance')
                        instance=e;
                        break;
                    end
                end


                openInstances=i.getInstanceList;
                currentInstanceOpen=false;
                for oi=1:length(openInstances)
                    if strcmp(openInstances{oi}.uuid,instance.UUID)
                        currentInstanceOpen=true;
                        break;
                    end
                end

                if currentInstanceOpen
                    okMsg=DAStudio.message('SystemArchitecture:Instantiator:OK');
                    response=questdlg(...
                    DAStudio.message('SystemArchitecture:Analysis:OverwriteInstanceModel'),...
                    DAStudio.message('SystemArchitecture:Instantiator:Confirm'),...
                    okMsg,...
                    DAStudio.message('SystemArchitecture:Instantiator:Cancel'),...
                    DAStudio.message('SystemArchitecture:Instantiator:Cancel'));
                    if strcmp(response,okMsg)
                        i.registerInstance(instance);
                        i.addListenersForInstance(instance);
                        v.setInstance(instance,fn,args,mode);
                    end
                else

                    i.registerInstance(instance);
                    i.addListenersForInstance(instance);
                    v.setInstance(instance,fn,args,mode);
                end
            end
            v.bringToFront();
        end

        function saveInstanceModel(architectureInstanceUUID)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            m=v.getModel(architectureInstanceUUID);
            [file,path,indx]=uiputfile([v.getInstanceName(),'.mat']);

            if ischar(file)
                s=mf.zero.io.XmlSerializer;
                str=s.serializeToString(m);
                fileName=fullfile(path,file);
                save(fileName,'str');
            end

            v.bringToFront();
        end

        function result=deleteInstanceModel(architectureInstanceUUID)
            okMsg=DAStudio.message('SystemArchitecture:Instantiator:OK');
            response=questdlg(...
            DAStudio.message('SystemArchitecture:Analysis:ConfirmDelete'),...
            DAStudio.message('SystemArchitecture:Instantiator:Confirm'),...
            okMsg,...
            DAStudio.message('SystemArchitecture:Instantiator:Cancel'),...
            DAStudio.message('SystemArchitecture:Instantiator:Cancel'));
            if strcmp(response,okMsg)
                systemcomposer.internal.analysis.AnalysisService.deleteInstance(architectureInstanceUUID);
                result=true;
            else
                result=false;
            end
        end

        function deleteInstance(architectureInstanceUUID)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            if~isempty(v)
                v.setInstance();
            end
            i.removeInstanceWithUUID(architectureInstanceUUID);
        end

        function highlightInComposer(instanceUUID)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            v.highlightInComposer(instanceUUID);
        end

        function functionName=chooseFunction(architectureInstanceUUID)
            functionName='';
            [fname,pathname]=uigetfile('*.m',...
            DAStudio.message('SystemArchitecture:Instantiator:SelectAnalysisFunction'));
            if isempty(fname)||~ischar(fname)
                return;
            end
            fcn=strrep(fname,'.m','');


            p=which(fcn);
            if~strcmp(p,fullfile(pathname,fname))
                error(DAStudio.message('SystemArchitecture:Instantiator:FunctionNotVisible',fname));
            end

            functionName=fcn;

            if nargin>0

                i=systemcomposer.internal.analysis.AnalysisService.getInstance();
                v=i.getViewer();
                v.setFunction(functionName);
            end

            v.bringToFront();
        end

        function openHelp(helpTopic)
            helpview(fullfile(docroot,"systemcomposer","helptargets.map"),helpTopic);
        end
    end

    methods(Static)

        function instanceModelLoaded(architectureInstanceUUID)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            v.loaded();
        end

        function updateInstance(architectureInstanceUUID,reset)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            instance=v.getInstance();
            instance.refresh(reset);
        end

        function promoteInstanceProperties(architectureInstanceUUID,itemUUID,propertyName,updateHierarchy)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            instance=v.getInstance();
            if~isempty(propertyName)
                instance.update(itemUUID,propertyName);
            else
                instance.update(itemUUID,updateHierarchy);
            end
        end


        function setUpdate(architectureInstanceUUID,setting)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            v.setUpdate(setting);
        end

        function response=setContinuousMode(setting)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            response=v.setContinuousMode(setting);
        end

        function setOverwriteMode(setting)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            v.setOverwrite(setting);
        end

        function[architectureInstanceUUID,details]=getPropertyTypeDetails(architectureInstanceUUID)


            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            details=v.getPropertyTypeDetails();
        end

        function response=invokeVisit(architectureInstanceUUID,arg,direction)

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            response=v.invokeVisit(arg,direction);
        end

        function propertyValueChange(prop,value)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            if~isempty(v)
                m=v.getModel();
                if~isempty(m)
                    txn=m.beginTransaction;
                    prop.setAsMxArray(value);
                    if v.inContinuousMode()
                        response=v.invokeVisit(arg,direction);
                        if~response.isError
                            v.reportError(response);
                        else
                            t.commit;
                        end
                    else
                        t.commit;
                    end
                end
            end
        end

        function instancePropertyChange(architectureInstanceUUID,instanceUUID,valuesJSON,continuousMode,arg,direction)


            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            values=jsondecode(valuesJSON);

            m=v.getModel(architectureInstanceUUID);
            ai=m.findElement(instanceUUID);
            if~isempty(ai)
                t=m.beginTransaction;

                for n=1:length(values)
                    value=values(n);
                    def=systemcomposer.internal.analysis.AnalysisService.getDefinition(ai,value.set,value.property);
                    if(isa(def.type,'systemcomposer.property.FloatType')||...
                        isa(def.type,'systemcomposer.property.IntegerType'))
                        if ischar(value.value)
                            newValue=eval(value.value);
                        else
                            newValue=value.value;
                        end
                    elseif isa(def.type,'systemcomposer.property.BooleanType')
                        if ischar(value.value)
                            newValue=eval(value.value);
                        else
                            newValue=value.value;
                        end
                    elseif isa(def.type,'systemcomposer.property.Enumeration')
                        if ischar(value.value)
                            newValue=eval(def.type.MATLABEnumName+"("+value.value+")");
                        else
                            newValue=value.value;
                        end
                    else
                        newValue=eval(value.value);
                    end
                    name=[value.set,'.',values.property];
                    if isfield(values,'index')
                        ai.setValue(name,newValue,values.index);
                    else
                        ai.setValue(name,newValue);
                    end
                end



                if v.inContinuousMode()
                    response=v.invokeVisit(arg,direction);
                    if response.isError
                        v.reportError(response);
                    else
                        t.commit;
                    end
                else
                    t.commit;
                end
            end
        end

    end

    methods(Static)
        function instances=findInstances(name)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            instances=i.findInstancesFromName(name);
        end

        function v=viewInstance(instance,fn,args,mode,architecture,debug)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=i.getViewer();
            if isempty(v)
                v=systemcomposer.internal.analysis.AnalysisViewer(instance,fn,args,mode,architecture);
                i.addAnalysisViewerInternal(v);
                if nargin==5||~debug
                    v.open(0);
                elseif debug~=0
                    v.open(debug);
                end
            else
                if~isempty(instance)

                    v.setInstance(instance,fn,args,mode);
                end
                if nargin==5
                    v.open(0);
                else
                    v.open(debug);
                end
                if~isempty(v.Window)
                    v.bringToFront();
                end
            end
        end

        function url=debugInstance(instance,fn,args,mode)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            v=systemcomposer.internal.analysis.AnalysisViewer(instance,fn,args,mode,[]);
            i.addAnalysisViewerInternal(v);
            debug=1;
            url=v.buildUrl(debug);
        end

        function list=getInstanceList()
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            list=i.getInstanceListInternal();
        end

        function impl=addInstanceModel(modelHandle,architecture,name)
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
            mfModel=app.addInstanceModel;
            txn=mfModel.beginTransaction;


            id=systemcomposer.services.proxy.ModelIdentifier(mfModel);
            id.modelType=systemcomposer.services.proxy.ModelType.ANALYSIS_INSTANCE_MODEL;
            id.URI='';


            impl=systemcomposer.internal.analysis.ArchitectureInstance.newArchitectureInstance(architecture,mfModel,name);

            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            i.addInstanceModelInternal(impl);
            txn.commit;
        end
    end

    methods(Static)

        function removeViewer(viewer)
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            i.removeViewerInternal(viewer);
        end

        function cleanUp()
            i=systemcomposer.internal.analysis.AnalysisService.getInstance();
            i.cleanUpInternal;
        end
    end

    methods(Static,Access=private)
        function registry=getInstance()
            persistent persistentRegistry;
            if isempty(persistentRegistry)
                persistentRegistry=systemcomposer.internal.analysis.AnalysisService();
            end
            registry=persistentRegistry;
        end
    end

    methods(Static,Hidden)
        function viewerInstance=getViewerForTesting()
            serviceInstance=systemcomposer.internal.analysis.AnalysisService.getInstance();
            viewerInstance=serviceInstance.getViewer;
        end
    end

    methods

        function addListenersForInstance(this,instance)
            specification=instance.specification;

            instance.createListener(specification);

            for inst=instance.instances.toArray
                try
                    spec=inst.specification;
                catch
                    spec=[];
                end
                if~isempty(spec)
                    if isa(spec,'systemcomposer.architecture.model.design.Component')
                        actualSpec=spec.getArchitecture();
                        if isempty(actualSpec.getParentComponent)


                            instance.createListener(actualSpec);
                            instance.startListener(actualSpec);
                        end
                    elseif isa(spec,'systemcomposer.architecture.model.design.Port')
                        if isa(spec,'systemcomposer.architecture.model.design.ComponentPort')
                            actualSpec=spec.getArchitecturePort();
                        else
                            actualSpec=spec;
                        end
                    elseif isa(spec,'systemcomposer.architecture.model.design.BaseConnector')
                        actualSpec=spec;
                    elseif isa(spec,'systemcomposer.architecture.model.design.Architecture')
                        actualSpec=spec;
                    end
                    instance.addInstanceToMap(inst,actualSpec);
                else
                    instance.addInstanceToMap(inst,specification);
                end
            end
            instance.startListener(specification);
        end

        function registerInstance(this,instance)
            this.addInstanceModelInternal(instance);
        end

        function removeInstanceWithUUID(this,architectureInstanceUUID)
            i=this.findInstanceFromUUID(architectureInstanceUUID);
            if~isempty(i)
                this.removeInstanceInternal(i);
            end
        end


        function didIt=removeInstanceWithModelUUID(this,modelUUID,destroy)
            if nargin<3
                destroy=true;
            end
            didIt=false;
            i=this.findInstanceFromModelUUID(modelUUID);
            if~isempty(i)
                this.removeInstanceInternal(i,destroy);
                didIt=true;
            end
        end

        function instance=findInstanceFromModelUUID(this,UUID)
            instance=[];
            for si=1:length(this.Models)
                v=this.Models{si};
                if strcmp(mf.zero.getModel(v).UUID,UUID)
                    instance=v;
                    return;
                end
            end
        end

        function instance=findInstanceFromUUID(this,UUID)
            instance=[];
            for si=1:length(this.Models)
                v=this.Models{si};
                if strcmp(v.UUID,UUID)
                    instance=v;
                    return;
                end
            end
        end
    end
    methods(Access=private)
        function viewer=getViewer(this)
            if~isempty(this.Viewers)
                viewer=this.Viewers{1};
            else
                viewer=[];
            end
        end

        function viewer=findViewerFromUUID(this,UUID)
            if~isempty(this.Viewers)
                viewer=this.Viewers{1};
            else
                viewer=[];
            end







        end


        function instances=findInstancesFromName(this,name)
            instances=systemcomposer.analysis.ArchitectureInstance.empty;
            for si=1:length(this.Models)
                v=this.Models{si};
                if strcmp(v.getName,name)
                    instances(end+1)=systemcomposer.analysis.ArchitectureInstance(v);
                    return;
                end
            end
        end

        function list=getInstanceListInternal(this)
            list={};
            for si=1:length(this.Models)
                v=this.Models{si};
                try
                    s=v.specification.getName;
                catch
                    s="";
                end
                list{end+1}=struct('uuid',v.UUID,...
                'name',v.root.getName,...
                'specName',s);
            end
        end

        function addAnalysisViewerInternal(this,viewer)
            this.Viewers{end+1}=viewer;
        end

        function addInstanceModelInternal(this,instance)
            this.Models{end+1}=instance;
            model=mf.zero.getModel(instance);
            try
                spec=systemcomposer.internal.getWrapperForImpl(instance.specification);
                modelHandle=spec.SimulinkHandle;
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
                app.registerInstanceModel(model);
            catch ex
                rethrow(ex);
            end
        end

        function removeViewerInternal(this,viewer)
            for si=1:length(this.Viewers)
                v=this.Viewers{si};
                if viewer==v
                    this.Viewers(si)=[];
                    break;
                end
            end
        end

        function removeInstanceInternal(this,instance,destroy)
            if nargin<3
                destroy=true;
            end
            for si=1:length(this.Models)
                v=this.Models{si};
                if instance==v
                    this.Models(si)=[];
                    spec=instance.specification;
                    UUID=mf.zero.getModel(instance).UUID;

                    if destroy
                        v.destroy();
                    end
                    try
                        if~isempty(spec)
                            modelHandle=get_param(spec.getName,'Handle');
                            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
                            app.removeInstanceModel(UUID);
                        end
                    catch
                    end
                    break;
                end
            end
        end

        function cleanUpInternal(this)
            currentViewerList=this.Viewers;
            for si=1:length(currentViewerList)
                v=currentViewerList{si};
                if~isempty(v)&&isvalid(v)
                    v.close();
                    v.delete();
                end
            end
            this.Viewers={};
            currentModelList=this.Models;
            for si=1:length(currentModelList)
                v=currentModelList{si};
                if~isempty(v)&&isvalid(v)
                    v.destroy();
                end
            end
            this.Models={};
        end

    end
end

