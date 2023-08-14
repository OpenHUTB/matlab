classdef AnalysisViewer<handle


    properties
        ArchitectureInstance=[];
        Channel;
        Window=[];
        IsLoaded=false;
        FnHandle;
        Args;
        Mode;
        Architecture;
        AutoUpdate=false;
        ContinuousAnalysis=false;
        Overwrite=false;
    end

    properties(Hidden)
        URL;
    end

    methods(Access='private')
        function sendWindowCommand(this,command,args)
            message.publish(this.Channel,{command,args});
        end

        function sendInstanceList(this)
            list=systemcomposer.internal.analysis.AnalysisService.getInstanceList();
            this.sendWindowCommand('models',{list});
        end

    end
    methods(Hidden)
        function url=getURL(this)
            url=this.URL;
        end

        function instanceDeletionAlert(this,instanceUUID)
            this.sendWindowCommand("modelDeleted",instanceUUID);
        end

        function res=inContinuousMode(this)
            res=this.ContinuousAnalysis;
        end

        function handleChanges(this,report)
            if~isempty(report)

                viewedInstance=this.getInstance();























                if~isempty(viewedInstance)&&~isempty(report(1).InstanceUUID)


                    this.reportChangedInstances(report);
                end

            end
        end

        function setOverwrite(this,setting)
            this.Overwrite=setting;
        end

        function setUpdate(this,setting)
            this.AutoUpdate=setting;
            viewedInstance=this.getInstance();
            if~isempty(viewedInstance)
                viewedInstance.ImmediateUpdate=setting;

                if setting


                    viewedInstance.refresh(false);
                end
            end
        end

        function response=setContinuousMode(this,setting)
            this.ContinuousAnalysis=setting;
            viewedInstance=this.getInstance();
            if setting&&~isempty(viewedInstance)


                response=this.invokeVisit(this.getArgs(),this.getIterationMode());
            end
            response=struct('isError',false);
        end

        function reportChangedInstances(this,changedInstances)
            this.sendWindowCommand("changes",changedInstances);
        end

        function reportError(this,response)
            this.sendWindowCommand("analysisError",response);
        end
        function highlightInComposer(this,instanceUUID)
            if~isempty(this.ArchitectureInstance)
                this.ArchitectureInstance.highlightInComposer(instanceUUID);
            end
        end

        function model=getModel(this,instanceUUID)
            if isempty(this.ArchitectureInstance)
                model=[];
            else
                model=this.ArchitectureInstance.getModel;
            end
        end

        function name=getInstanceName(this)
            if isempty(this.ArchitectureInstance)
                name='';
            else
                name=this.ArchitectureInstance.getInstanceName;
            end
        end

        function instance=getInstance(this)
            i=this.ArchitectureInstance;
            if isempty(i)
                instance=[];
            else
                instance=i.getInstance();
            end
        end

        function UUID=getUUID(this)
            if isempty(this.ArchitectureInstance)
                UUID='';
            else
                UUID=this.ArchitectureInstance.getUUID;
            end
        end

        function args=getArgs(this)
            if isempty(this.ArchitectureInstance)
                args=this.Args;
            else
                args=this.ArchitectureInstance.getArgs;
            end
        end

        function name=getFunctionName(this)
            if isempty(this.ArchitectureInstance)
                if isempty(this.FnHandle)
                    name='';
                else
                    name=func2str(this.FnHandle);
                end
            else
                name=this.ArchitectureInstance.getFunctionName;
            end
        end

        function mode=getIterationMode(this)
            if isempty(this.ArchitectureInstance)
                mode=this.Mode;
            else
                mode=this.ArchitectureInstance.getIterationMode;
            end
        end

        function a=getArchitecture(this)
            if isempty(this.ArchitectureInstance)
                a=this.Architecture;
            else
                a=this.ArchitectureInstance.getInstance().Specification;
            end
        end
        function loaded(this)
            if(~isempty(this.ArchitectureInstance))
                this.ArchitectureInstance.loaded();
            end
            this.IsLoaded=true;
        end

        function status=getStatus(this)
            status=this.IsLoaded;
        end

        function bringToFront(this)
            this.Window.show;
        end

        function response=invokeVisit(this,arg,direction)
            mod=this.getModel;

            if~isempty(mod)
                t=mod.beginTransaction;
                response=this.invokeVisitInternal(arg,direction);
                if~response.isError
                    t.commit;
                end
            else
                response=struct('isError',false);
            end
        end

        function response=invokeVisitInternal(this,arg,direction)
            i=this.ArchitectureInstance;
            if~isempty(i)
                try
                    top=i.getInstance.getImpl;
                    top.analysisCount=top.analysisCount+1;
                    i.visit(arg,direction);
                catch ex
                    response=struct(...
                    'isError',true,...
                    'message',ex.message,...
                    'instanceUUID',ex.cause{1}.message);
                    return;
                end
            end
            response=struct('isError',false);
        end

        function detailStruct=getPropertyTypeDetails(this)
            i=this.ArchitectureInstance;
            if~isempty(i)
                detailStruct=i.getPropertyTypeDetails;
            else
                detailStruct=[];
            end
        end

    end

    methods(Access='public')

        function setInstance(this,instance,fn,args,mode)
            if~isempty(this.ArchitectureInstance)&&isvalid(this.ArchitectureInstance)

                this.setFunction(this.getFunctionName());
                this.Architecture=this.getArchitecture();
                this.Mode=this.getIterationMode();
                this.Args=this.getArgs();
                delete(this.ArchitectureInstance);
                this.ArchitectureInstance=[];
            end

            if nargin>1

                this.addNewInstance(instance,fn,args,mode);
            end
        end

        function setFunction(this,name)
            if~isempty(name)&&~strcmp(name,'')
                i=this.ArchitectureInstance;
                try
                    if~isempty(i)
                        i.setFunction(name);
                    else
                        this.FnHandle=eval(['@',name]);
                    end
                catch
                end
            end
        end

        function i=addNewInstance(this,as,fnHandle,args,mode)
            i=systemcomposer.internal.analysis.AnalysisInstanceView(as,fnHandle,args,mode);
            i.setUpdateMode(this.AutoUpdate);
            this.sendWindowCommand('newInstance',{...
            ['/systemcomposer_analysis_ui/',i.getUUID,'/'],...
            i.getUUID,...
            i.getSpecificationUUID,...
            i.getSpecificationName,...
            i.getFunctionName(),...
            i.getArgs,...
            num2str(i.getIterationMode)}...
            );
            this.ArchitectureInstance=i;
            this.Mode=mode;
            this.sendInstanceList();
        end

        function close(this)
            if~isempty(this.ArchitectureInstance)
                delete(this.ArchitectureInstance);
            end
            delete(this.Window);
            systemcomposer.internal.analysis.AnalysisService.removeViewer(this);
        end

        function url=buildUrl(this,debug)
            if nargin>1&&debug>0
                urlbase='toolbox/systemcomposer/analysis/editor/web/index-debug.html';
            else
                urlbase='toolbox/systemcomposer/analysis/editor/web/index.html';
            end

            fnName=this.getFunctionName;
            if(~isempty(fnName))
                funcData=['&functionName=',fnName...
                ,'&args=',this.getArgs];
            else
                funcData='';
            end

            a=this.getArchitecture;
            if(isempty(a))
                specUUID='';
                specName='';
            else
                specUUID=a.getImpl().UUID;
                specName=a.Name;
            end

            this.Channel='/systemcomposer_analysis_ui/window';
            activeMdlStr=jsonencode(systemcomposer.internal.analysis.AnalysisService.getInstanceList());
            activeMdlStr=regexprep(activeMdlStr,'[','');
            activeMdlStr=regexprep(activeMdlStr,']','');
            activeMdlStr=regexprep(activeMdlStr,'{','%7B');
            activeMdlStr=regexprep(activeMdlStr,'}','%7D');
            fullUrl=[urlbase,'?instance=',this.getUUID()...
            ,'&channel=/systemcomposer_analysis_ui/',this.getUUID,'/'...
            ,'&windowChannel=',this.Channel,funcData...
            ,'&specificationUUID=',specUUID...
            ,'&specificationName=',specName...
            ,'&iterationMode=',num2str(this.getIterationMode)...
            ,'&activeModels=',activeMdlStr];

            url=connector.getUrl(fullUrl);
        end

        function open(this,debug)





            if isempty(this.Window)

                url=this.buildUrl(debug);

                this.URL=url;
                if nargin>1&&abs(debug)==1
                    web(url,'-browser');
                else
                    currentWindowSettings=[100,100,1500,700];
                    this.Window=Simulink.HMI.BrowserDlg(url,message('SystemArchitecture:Analysis:InstanceViewerTitle').getString,currentWindowSettings,[],true,false);
                    this.Window.CustomCloseCB=@this.close;
                    this.Window.show();
                end

                if nargin>1&&debug~=0
                    clipboard('copy',url);
                end
            else
                if nargin>1&&abs(debug)==1
                    url=this.buildUrl(debug);
                    web(url,'-browser');
                else
                    this.Window.show();
                    this.Window.bringToFront;
                end
            end
        end

        function this=AnalysisViewer(as,fnHandle,args,mode,architecture)
            if isempty(as)
                this.FnHandle=fnHandle;
                this.Args=args;
                this.Mode=mode;
                this.Architecture=architecture;
            else
                this.ArchitectureInstance=systemcomposer.internal.analysis.AnalysisInstanceView(as,fnHandle,args,mode);
            end
        end
    end

end

