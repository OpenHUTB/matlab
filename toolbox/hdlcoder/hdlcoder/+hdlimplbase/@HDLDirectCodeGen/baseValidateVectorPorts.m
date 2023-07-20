function v=baseValidateVectorPorts(this,ports,varargin)




















    v=hdlvalidatestruct;


    msg='Unhandled vector ports for block';

    msg_in=this.baseValidateGetPropValue(varargin,'message');
    if~isempty(msg_in)
        msg=msg_in;
    end

    if~isempty(ports)
        is_vector=false;

        for ii=1:length(ports)
            sig=ports(ii).Signal;
            if~isempty(sig)&&hdlissignalvector(sig)
                is_vector=true;
                break;
            end
        end

        if(is_vector)
            v=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unhandledvectorport',msg));
        end
    end


