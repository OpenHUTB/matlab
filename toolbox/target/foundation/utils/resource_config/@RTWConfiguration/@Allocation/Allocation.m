function h=Allocation(host,required_value,callback)




















    h=RTWConfiguration.Allocation;



    switch nargin

    case 0

    case[3]

        if~(ishandle(host)|ischar(host))
            TargetCommon.ProductInfo.error('resourceConfiguration','HostInputArgFormat');
        end

        if ishandle(host)
            h.host_type='handle';
        else
            h.host_type='char';
        end

        h.host_object=host;




        if~xor(isempty(required_value),isempty(callback))
            TargetCommon.ProductInfo.error('resourceConfiguration','ValueCallbackInputArgValidity');
        end

        if ischar(required_value)
            required_value={required_value};
        end
        h.value=required_value;
        h.realloc_callback=callback;


        if~isempty(h.realloc_callback)
            switch class(h.realloc_callback)
            case 'function_handle'

            case 'cell'
                if~isa(h.realloc_callback{1},'function_handle')
                    i_second_arg_errfcn;
                end
            otherwise
                i_second_arg_errfcn;
            end
        end

    otherwise
        TargetCommon.ProductInfo.error('common','NInputArgsRequired',3);
    end


    function i_second_arg_errfcn
        TargetCommon.ProductInfo.error('resourceConfiguration','CallbackInputArgFormat');

