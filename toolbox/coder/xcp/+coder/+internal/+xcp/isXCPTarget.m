function ret=isXCPTarget(src)











    ret=false;

    assert(~isempty(src)&&(isa(src,'Simulink.ConfigSet')||...
    isa(src,'Simulink.ConfigSetRef')||isa(src,'Simulink.TargetCC')),...
    'isXCPTarget: invalid input');






    if~src.isValidParam('ExtMode')||...
        strcmp(get_param(src,'ExtMode'),'off')||...
        ~src.isValidParam('ExtModeMexFile')
        return;
    end


    mexFile=get_param(src,'ExtModeMexFile');

    ret=strcmp(mexFile,'ext_xcp');

end
