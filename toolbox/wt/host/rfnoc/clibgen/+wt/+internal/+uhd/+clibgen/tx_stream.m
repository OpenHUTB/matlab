classdef tx_stream<wt.internal.uhd.clibgen.stream




    methods(Sealed,Access={?handle})

        function make(obj,graph,num_ports,cpu,otw,varargin)
            make@wt.internal.uhd.clibgen.stream(obj,'tx',graph,num_ports,cpu,otw,varargin{:});
        end

    end

    methods

        function num_samps=send(obj,data,timeout)
            switch(lower(obj.cpu_data_type))
            case{'uc16','uc8','sc8','u16','s16','s8','f32','f64'}
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            case{'fc32'}
                num_samps=sendFC32(obj,data,timeout);
            case{'fc64'}
                num_samps=sendFC64(obj,data,timeout);
            case{'sc16'}
                num_samps=sendSC16(obj,data,timeout);
            case{'u8'}
                num_samps=sendU8(obj,data,timeout);
            otherwise
                error(message("wt:rfnoc:host:InvalidDataFormat"));
            end
        end
    end

    methods(Access=protected)
        function num_samps=sendU8(obj,data,timeout)

            len=size(data,1);
            data=data(:).';
            num_samps=clib.wt_uhd.mw.helper.stream.send(obj.stream_handle,data,len,obj.md,timeout);
        end

        function num_samps=sendSC16(obj,data,timeout)

            len=size(data,1);
            data=data(:).';
            rbuff=clibConvertArray('clib.wt_uhd.Short',real(data));
            ibuff=clibConvertArray('clib.wt_uhd.Short',imag(data));


            num_samps=clib.wt_uhd.mw.helper.stream.send_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
        end
        function num_samps=sendFC32(obj,data,timeout)

            len=size(data,1);
            data=data(:).';
            rbuff=clibConvertArray('clib.wt_uhd.Float',real(data));
            ibuff=clibConvertArray('clib.wt_uhd.Float',imag(data));


            num_samps=clib.wt_uhd.mw.helper.stream.send_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
        end
        function num_samps=sendFC64(obj,data,timeout)

            len=size(data,1);
            data=data(:).';
            rbuff=clibConvertArray('clib.wt_uhd.Double',real(data));
            ibuff=clibConvertArray('clib.wt_uhd.Double',imag(data));


            num_samps=clib.wt_uhd.mw.helper.stream.send_complex(obj.stream_handle,rbuff,ibuff,len,obj.md,timeout);
        end
    end
end


