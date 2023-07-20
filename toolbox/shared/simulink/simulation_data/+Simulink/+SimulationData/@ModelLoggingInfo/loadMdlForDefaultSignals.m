function varargout=loadMdlForDefaultSignals(mdlBlock,...
    topModelName,...
    obj,...
    variantOpt)












    try
        if nargout>1
            varargout{2}=obj.supportsTestPointSignals();
        end


        if nargin<4
            bAllVariants=false;
        else
            bAllVariants=~strcmpi(variantOpt,'ActiveVariants');
        end


        if bAllVariants&&strcmp(get_param(mdlBlock,'Variant'),'on')
            vars=get_param(mdlBlock,'Variants');
            mdls={vars.ModelName};
        else
            mdls={get_param(mdlBlock,'Modelname')};
        end


        if bAllVariants
            varargout{1}=mdls;
        else
            varargout{1}=mdls{1};
        end


        for idx=1:length(mdls)
            load_system(mdls{idx});
        end

    catch me
        id='Simulink:Logging:MdlLogInfoGetDefaultsOpenFailure';
        err=MException(id,DAStudio.message(id,topModelName));
        err=err.addCause(me);
        throw(err);
    end

end
