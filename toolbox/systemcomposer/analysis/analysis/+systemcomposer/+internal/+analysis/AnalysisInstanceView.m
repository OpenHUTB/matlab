classdef AnalysisInstanceView<handle
    properties(Access='private')
        Sync;
        Channel;
        Model;
        FnHandle;
        Arguments;
        Instance;
        IsLoaded=false;
        IterationMode=0;
        highlightedElement=[];
    end


    methods
        function delete(this)
            this.stop();
        end

        function loaded(this)
            this.IsLoaded=true;
        end

        function status=getStatus(this)
            status=this.IsLoaded;
        end

        function highlightInComposer(this,uuid)
            mdlName=get_param(this.Instance.Specification.SimulinkModelHandle,'Name');
            editor=GLUE2.Util.findAllEditors(mdlName);

            if(~isempty(editor))

                if~isempty(this.highlightedElement)&&ishandle(this.highlightedElement)
                    highlightedObject=get_param(this.highlightedElement,'Object');
                    if isa(highlightedObject,'Simulink.Port')
                        slm3iPort=SLM3I.SLDomain.handle2DiagramElement(this.highlightedElement);
                        editor.deselect(slm3iPort);
                    else
                        set_param(this.highlightedElement,'Selected','off');
                    end
                end


                studio=editor.getStudio();
                if(~isempty(studio))

                    instance=this.Model.findElement(uuid);

                    if isa(instance,'systemcomposer.internal.analysis.NodeInstance')
                        wrapper=systemcomposer.analysis.ComponentInstance(instance);
                        handle=wrapper.Specification.SimulinkHandle;

                        if~isempty(handle)&&isa(handle,'double')
                            object=diagram.resolver.resolve(handle);


                            if~isempty(object)

                                studio.App.hiliteAndFadeObject(object);
                            end
                            set_param(handle,'Selected','on');
                            this.highlightedElement=handle;
                        end
                    elseif isa(instance,'systemcomposer.internal.analysis.PortInstance')
                        wrapper=systemcomposer.analysis.PortInstance(instance);
                        handle=wrapper.Specification.SimulinkHandle;

                        if~isempty(handle)&&isa(handle,'double')
                            object=diagram.resolver.resolve(handle);


                            if~isempty(object)

                                studio.App.hiliteAndFadeObject(object);
                            end
                            slm3iPort=SLM3I.SLDomain.handle2DiagramElement(handle);
                            editor.select(slm3iPort);
                            this.highlightedElement=handle;
                        end
                    elseif isa(instance,'systemcomposer.internal.analysis.ConnectorInstance')
                        wrapper=systemcomposer.analysis.ConnectorInstance(instance);
                        handle=wrapper.Specification.SimulinkHandle;

                        if~isempty(handle)&&isa(handle,'double')
                            object=diagram.resolver.resolve(handle);


                            if~isempty(object)

                                studio.App.hiliteAndFadeObject(object);
                            end
                            set_param(handle,'Selected','on');
                            this.highlightedElement=handle;
                        end
                    end
                    studio.show();
                end
            end
        end

        function setupModel(this,instance,fnHandle,args,mode)
            if isa(instance,'systemcomposer.internal.analysis.ArchitectureInstance')
                this.Instance=systemcomposer.analysis.ArchitectureInstance.getWrapperForImpl(instance);

            else
                this.Instance=instance;

            end



            if mode==-1
                mode=this.Instance.getImpl.direction;
            end

            if isempty(fnHandle)
                fnName=this.Instance.getImpl.analysisFunctionName;
                if~isempty(fnName)
                    try
                        fnHandle=eval(['@',fnName]);
                    catch
                        fnHandle=[];
                    end
                end
            end

            this.Model=this.Instance.getModel;
            this.Channel=mf.zero.io.ConnectorChannelMS(['/systemcomposer_analysis_ui/',this.Instance.getUUID,'/server'],...
            ['/systemcomposer_analysis_ui/',this.Instance.getUUID,'/client']);

            this.Sync=mf.zero.io.ModelSynchronizer(this.Model,this.Channel);
            this.Sync.start();
            this.Arguments=args;
            if~isempty(fnHandle)
                if ischar(fnHandle)
                    this.setFunction(fnHandle);
                else
                    this.FnHandle=fnHandle;
                end
            end
            this.IterationMode=mode;
        end

        function name=getFunctionName(this)
            if isempty(this.FnHandle)
                name='';
            else
                name=func2str(this.FnHandle);
            end
        end

        function setFunction(this,name)
            this.FnHandle=eval(['@',name]);
        end

        function model=getModel(this)
            model=this.Model;
        end

        function name=getInstanceName(this)
            name=this.Instance.Name;
        end

        function name=getIterationMode(this)
            name=this.IterationMode;
        end

        function setUpdateMode(this,setting)
            this.Instance.ImmediateUpdate=setting;
        end

        function name=getInstance(this)
            name=this.Instance;
        end

        function UUID=getUUID(this)
            UUID=this.Instance.getUUID;
        end

        function args=getArgs(this)
            args=this.Arguments;
        end

        function UUID=getSpecificationUUID(this)
            UUID=this.Instance.getImpl.specification.UUID;
        end

        function UUID=getSpecificationName(this)
            UUID=this.Instance.getImpl.specification.getName;
        end

        function this=AnalysisInstanceView(as,fnHandle,args,mode)
            this.setupModel(as,fnHandle,args,mode);
        end

        function res=visit(this,arg,direction)
            if isempty(arg)
                arg={};
            end
            res=false;
            if(~isempty(this.FnHandle))

                this.Instance.iterate(direction,this.FnHandle,...
                'IncludePorts',true,...
                'IncludeConnectors',true,arg{:});

                res=true;
            end
        end

        function detailStruct=getPropertyTypeDetails(this)
            detailStruct=this.Instance.getImpl.getPropertyTypeDetails;
        end

        function stop(this)
            if~isempty(this.Sync)&&isvalid(this.Sync)
                this.Sync.stop;
            end
            if~isempty(this.Instance)

            end
        end

    end

end

