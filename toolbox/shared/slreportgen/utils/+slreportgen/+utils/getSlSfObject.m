function obj=getSlSfObject(in)

















    if(isa(in,'Simulink.Object')||isa(in,'Stateflow.Object')||isa(in,'Simulink.DABaseObject'))
        obj=in;
    else
        objH=slreportgen.utils.getSlSfHandle(in);
        if(isa(objH,'Stateflow.Object')||isa(objH,'Simulink.Line'))
            obj=objH;
        else
            obj=get_param(objH,'Object');
        end
    end
end