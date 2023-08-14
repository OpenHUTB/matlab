function ConvEncoderInit(blk)




%#codegen

    if coder.target('MATLAB')
        if~(builtin('license','checkout','LTE_HDL_Toolbox'))
            error(message('whdl:whdl:NoLicenseAvailable'));
        end
    else
        coder.license('checkout','LTE_HDL_Toolbox');
    end
    registersamplecontrolbus;
    Simulink.suppressDiagnostic([blk,'/GeneratorMatrix'],'Stateflow:Runtime:DataOverflowErrorMSLD');

    [buffer,status]=str2num(get_param(blk,'BuffSize'));

    if status==true
        coder.internal.errorIf(buffer<6||buffer>2^16,'whdl:ConvolutionalCode:InvalidBufferSize');
    end
end