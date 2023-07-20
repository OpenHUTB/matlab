function ret=isXCPTransport(src)













    ret=false;

    assert(~isempty(src)&&(isa(src,'Simulink.ConfigSet')||...
    isa(src,'Simulink.ConfigSetRef')||isa(src,'Simulink.TargetCC')),...
    'isXCPTransport: invalid input');






    if~src.isValidParam('ExtMode')||...
        ~src.isValidParam('ExtModeMexFile')
        return;
    end


    mexFile=get_param(src,'ExtModeMexFile');

    ret=strcmp(mexFile,'ext_xcp');

end
