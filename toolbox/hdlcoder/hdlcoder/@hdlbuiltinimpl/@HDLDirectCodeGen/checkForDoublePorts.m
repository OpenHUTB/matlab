function[noports,any_real,all_real,any_double,all_double,any_single,all_single]=checkForDoublePorts(~,ports)









    if~isempty(ports)
        noports=false;
        any_real=false;
        all_real=true;
        any_double=false;
        all_double=true;
        any_single=false;
        all_single=true;

        for ii=1:length(ports)
            sig=ports(ii).Signal;
            sltype=hdlsignalsltype(sig);
            if local_is_real(sltype)
                any_real=true;
                if local_is_double(sltype)
                    any_double=true;
                elseif local_is_single(sltype)
                    any_single=true;
                else
                    assert(any_single,'Real but neither double nor single!');
                end


            elseif local_is_bus(sltype)&&ports(ii).getBustoVectorFlag
                continue;
            else
                all_real=false;
                all_double=false;
                all_single=false;
            end
        end
    else
        noports=true;
        any_real=false;
        all_real=false;
        any_double=false;
        all_double=false;
        any_single=false;
        all_single=false;
    end


    function result=local_is_double(sltype)

        switch sltype
        case{'double'}
            result=true;
        otherwise
            result=false;
        end



        function result=local_is_single(sltype)

            switch sltype
            case{'single'}
                result=true;
            otherwise
                result=false;
            end



            function result=local_is_real(sltype)

                result=local_is_double(sltype)||local_is_single(sltype);



                function result=local_is_bus(sltype)

                    switch sltype
                    case{'bus'}
                        result=true;
                    otherwise
                        result=false;
                    end






