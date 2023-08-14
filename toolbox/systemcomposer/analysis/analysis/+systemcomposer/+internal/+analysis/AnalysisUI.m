classdef AnalysisUI<handle
    properties
        model=[];
        sync=[];
        analysisSet=[];
        url='';
        channel=[];
        async=[];
        achannel=[];
        ssync=[];
        schannel=[];
        dirtyList={};
        updateTimer=[];
        channelName='';
    end

    methods
        function onModelChangeListener(this,added,modified,destroyed)


            disp(['Added: ',obj2str(added)]);
            disp(['Modified: ',obj2str(modified)]);
            disp(['Destroyed: ',obj2str(destroyed)]);

            function str=obj2str(obj)
                str=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(obj);
            end
        end

        function setupInstanceModelSynchroniser(this,model)
            this.channel=mf.zero.io.ConnectorChannelMS(['/systemcomposer_analysis_ui/',this.channelName,'server'],...
            ['/systemcomposer_analysis_ui/',this.channelName,'client']);


            this.sync=mf.zero.io.ModelSynchronizer(model,this.channel);


            this.sync.start();
        end

        function setupSpecificationModelSynchroniser(this,model)

            this.achannel=mf.zero.io.ConnectorChannelMS(['/systemcomposer_analysis_ui/s',this.channelName,'server'],...
            ['/systemcomposer_analysis_ui/s',this.channelName,'client']);

            this.async=mf.zero.io.ModelSynchronizer(model,this.achannel);
            this.async.start();

        end

        function url=getURL(this)
            url=connector.getUrl(this.url);
        end
        function open(this,debug)
            url=this.getURL();
            if nargin>1&&debug
                web(url,'-browser');
            else
                currentWindowSettings=[100,100,1500,700];
                Simulink.HMI.BrowserDlg(url,'Systems Architecture Editor',currentWindowSettings,[],true,false);
            end
        end

        function this=AnalysisUI(app)
            this.analysisSet=app.currentSession;
            this.channelName='';


            instanceMFModel=mf.zero.getModel(app.getCurrentInstanceModel());
            this.setupInstanceModelSynchroniser(instanceMFModel);
            spec=app.getCurrentInstanceModel().specification;
            if(~isempty(spec))
                specificationMFModel=mf.zero.getModel(spec);
                this.setupSpecificationModelSynchroniser(specificationMFModel);
            end


            this.url='toolbox/systemcomposer/analysis/editor/web/index-debug.html';
        end

        function stop(this)
            this.async.stop;
            this.sync.stop;
            delete(this.async);
            delete(this.sync);
        end

    end

end

