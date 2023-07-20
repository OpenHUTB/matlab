function v=baseValidateFramesInputProc(this,hC)




















    v=hdlvalidatestruct;

    if isa(hC,'hdlcoder.sysobj_comp')
        ipmode='frame';
        errorMessage=['HDL support is available when the input is'...
        ,' scalar or a row vector.'];
    else
        ipmode=get_param(hC.SimulinkHandle,'InputProcessing');
        errorMessage=['HDL support is not available for the'...
        ,' frame based processing mode.'...
        ,' Set the ''Input processing'' setting to '...
        ,'''Elements as channels (sample based)'''];
    end
    if~isempty(strfind(ipmode,'frame'))


        ports=this.getAllPirInputPorts(hC);


        for ii=1:length(ports)

            if(~hdlissignaltype(ports(ii).Signal,'row_vector')&&...
                ~hdlissignaltype(ports(ii).Signal,'scalar'))
                v=hdlvalidatestruct(1,...
                message('hdlcoder:validate:frameprocnotsupported',errorMessage));
                break;

            end
        end
    end


