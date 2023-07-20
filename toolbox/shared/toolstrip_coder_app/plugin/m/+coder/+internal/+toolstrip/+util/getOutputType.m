function type=getOutputType(mdl)

    target=get_param(mdl,'SystemTargetFile');
    type=target(1:end-4);

    if Simulink.CodeMapping.isAutosarAdaptiveSTF(mdl)
        type='autosar_adaptive';
    elseif Simulink.CodeMapping.isAutosarCompliant(mdl)
        type='autosar';
    elseif isCpp(mdl)&&strcmp(get_param(mdl,'IsERTTarget'),'on')
        type='cpp';
    elseif~strcmp(get_param(mdl,'IsERTTarget'),'on')&&isCpp(mdl)
        type='grt_cpp';
    end

end

function cpp=isCpp(mdl)
    cpp=strcmp(get_param(mdl,'TargetLang'),'C++')&&Simulink.CodeMapping.isCppClassInterface(mdl);
end