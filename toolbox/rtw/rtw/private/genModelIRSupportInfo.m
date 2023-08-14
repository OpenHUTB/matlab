function ret=genModelIRSupportInfo(model)











    load_system(model);

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok<NASGU>
    mdlObj=get_param(model,'Object');

    ret=mdlObj.getBlockIRSupport;

    for i=1:length(ret)
        if~isempty(ret(i).FullPathForSynthesizedBlock)
            ret(i).Message=strrep(ret(i).Message,'$PATH$',ret(i).FullPathForSynthesizedBlock);
        else
            ret(i).Message=strrep(ret(i).Message,'$PATH$',getfullname(ret(i).Block));
        end
        ret(i).Message=strrep(ret(i).Message,sprintf('\n'),' ');
        ret(i).Message=strrep(ret(i).Message,'$PRODUCT$','CGIR based code generation');
    end
