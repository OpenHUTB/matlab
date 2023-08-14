classdef rx_stream<wt.internal.uhd.clibgen.stream




    properties(Access=protected)

stream_cmd
        started_continuous=false
    end

    methods(Sealed,Access={?handle})

        function make(obj,graph,num_ports,cpu,otw,varargin)
            make@wt.internal.uhd.clibgen.stream(obj,'rx',graph,num_ports,cpu,otw,varargin{:});
        end

    end
    methods

        function configure(obj,stream_mode,num_samples,varargin)
            obj.stream_cmd=configureStreamCommand(obj,stream_mode,num_samples,varargin{:});
        end

        function onfnexitarray=parseStreamCmds(obj,upstreamBlockConfig,time)
            onfnexitarray={};
            ts=getTimeSpec(obj,time);
            for n=1:length(upstreamBlockConfig)
                block=upstreamBlockConfig(n).block;


                if length(upstreamBlockConfig)>1
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel,ts);
                else
                    block.issueStreamCommand(upstreamBlockConfig(n).mode,upstreamBlockConfig(n).len,upstreamBlockConfig(n).channel);
                    time=0;
                end
                fh=[];
                if strcmp(upstreamBlockConfig(n).mode,"continuous")
                    fh=@()(block.issueStreamCommand("stop",0,upstreamBlockConfig(n).channel));
                end
                onfnexitarray{end+1}=fh;%#ok
            end
            pause(time);
        end

        function[data,num_samps,overflow]=receive(obj,len,timeout,varargin)
            import clib.wt_uhd.uhd.stream_cmd_t.*



            timeOffset=0.2;
            onexit_fn={};

            if~isempty(varargin)&&isstruct(varargin{1})
                onexit_fn=obj.parseStreamCmds(varargin{1},timeOffset);
                varargin(1)=[];
            end



            if~isempty(obj.stream_cmd)
                if(isequal(obj.stream_cmd.stream_mode,stream_mode_t.STREAM_MODE_START_CONTINUOUS))
                    if~obj.started_continuous
                        obj.stream_handle.issue_stream_cmd(obj.stream_cmd);
                        obj.started_continuous=true;
                    end
                else
                    obj.stream_handle.issue_stream_cmd(obj.stream_cmd);
                end
            end


            switch(lower(obj.cpu_data_type))
            case{'uc16','uc8','sc8','u16','s16','s8','f32','f64'}
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            case{'fc64'}
                [data,num_samps]=receiveFC64(obj,len,timeout,varargin{:});
            case{'fc32'}
                [data,num_samps]=receiveFC32(obj,len,timeout,varargin{:});
            case{'sc16'}
                [data,num_samps]=receiveSC16(obj,len,timeout,varargin{:});
            case{'u8'}
                [data,num_samps]=receiveU8(obj,len,timeout,varargin{:});
            otherwise
                cellfun(@(c)c(),onexit_fn,'UniformOutput',false);
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            end
            overflow=obj.md.error_code==clib.wt_uhd.uhd.rx_metadata_t.error_code_t.ERROR_CODE_OVERFLOW;

            cellfun(@(c)c(),onexit_fn,'UniformOutput',false);
        end

        function stop(obj)
            if~isempty(obj.stream_handle)
                cmd=obj.configureStreamCommand('stop',0);
                obj.stream_handle.issue_stream_cmd(cmd);
            end
            obj.started_continuous=false;
        end
    end

    methods(Access=protected)
        function[data,num_samps]=receiveU8(obj,len,timeout,varargin)
            buff=clibArray('clib.wt_uhd.UnsignedChar',0);

            if nargin>3
                num_samps=clib.wt_uhd.mw.helper.stream.recv(obj.stream_handle,buff,len,obj.md,timeout,varargin{1});
            else
                num_samps=clib.wt_uhd.mw.helper.stream.recv(obj.stream_handle,buff,len,obj.md,timeout);
            end

            data=reshape(buff.uint8,len,getInCount(obj));
        end

        function[data,num_samps]=receiveSC16(obj,len,timeout,varargin)
            rbuff=clibArray('clib.wt_uhd.Short',0);
            ibuff=clibArray('clib.wt_uhd.Short',0);

            if nargin>3
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout,varargin{1});
            else
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
            end

            data=reshape(complex(rbuff.int16,ibuff.int16),len,getInCount(obj));
        end
        function[data,num_samps]=receiveFC32(obj,len,timeout,varargin)
            rbuff=clibArray('clib.wt_uhd.Float',0);
            ibuff=clibArray('clib.wt_uhd.Float',0);

            if nargin>3
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout,varargin{1});
            else
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
            end

            data=reshape(complex(rbuff.single,ibuff.single),len,getInCount(obj));
        end
        function[data,num_samps]=receiveFC64(obj,len,timeout,varargin)
            rbuff=clibArray('clib.wt_uhd.Double',0);
            ibuff=clibArray('clib.wt_uhd.Double',0);

            if nargin>3
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout,varargin{1});
            else
                num_samps=clib.wt_uhd.mw.helper.stream.recv_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
            end

            data=reshape(complex(rbuff.double,ibuff.double),len,getInCount(obj));
        end
    end
end


