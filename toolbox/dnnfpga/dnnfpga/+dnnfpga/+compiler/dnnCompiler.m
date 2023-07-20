classdef dnnCompiler<handle



    properties(Access=private)
m_processor
m_frontend
m_transformChain
m_backend
        m_verbose=false
    end

    methods(Access=public,Hidden=true)
        function obj=dnnCompiler(processor,fe,tc,be)
            obj.m_processor=processor;
            obj.m_frontend=fe;
            obj.m_transformChain=tc;
            obj.m_backend=be;
        end
    end

    methods(Access=public)
        function output=compile(this,input,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'verbose',1)
            parse(p,varargin{:});
            verbose=p.Results.verbose;

            try
                log.IR=input;log.processor=this.m_processor;
                this.takeLog('PreFrontend',log);
                temp=this.m_frontend.doit(input,this.m_processor,varargin{:});

                log.IR=temp;log.processor=this.m_processor;
                this.takeLog('PreTransform',log);
                temp=this.m_transformChain.doit(temp,this.m_processor,varargin{:});

                log.IR=temp;log.processor=this.m_processor;
                this.takeLog('PreBackend',log);
                output=this.m_backend.doit(temp,this.m_processor,varargin{:});

                log.IR=output;log.processor=this.m_processor;
                this.takeLog('PostBackend',log);

            catch ME






                if verbose>1






                    rethrow(ME);
                else


                    throwAsCaller(ME);
                end
            end
        end


        function[deployableNW,connections]=compileDAG(this,input,varargin)

            p=inputParser;
            addParameter(p,'LegLevel',false,@(x)islogical(x));
            addParameter(p,'ProcessorConfig',[]);
            parse(p,varargin{:});
            legLevel=p.Results.LegLevel;

            if(~legLevel)
                log.IR=input;log.processor=this.m_processor;
                this.takeLog('PreFrontend',log);


                [temp,connections]=this.m_frontend.doit(input,this.m_processor,varargin{:});



                log.IR=temp;log.processor=this.m_processor;
                this.takeLog('PreBackend',log);
                [deployableNWArray,connections]=this.m_backend.doit(temp,input,connections,this.m_processor,'LegLevel',false);
                deployableNW=deployableNWArray;
                log.IR=deployableNWArray;log.processor=this.m_processor;
            end
            this.takeLog('PostBackend',log);
        end

        function setVerbose(this,verbose)
            this.m_verbose=verbose;
        end
    end

    methods(Access=protected)
        function takeLog(this,name,log)%#ok<INUSD>
            if(this.m_verbose)
                save([name,'.mat'],'-struct','log');
            end
        end
    end
end
