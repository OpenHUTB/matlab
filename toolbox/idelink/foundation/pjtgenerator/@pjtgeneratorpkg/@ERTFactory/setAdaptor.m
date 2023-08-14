function setAdaptor(h,varargin)




    AdaptorRegistry=h.ProjectMgr.mAdaptorRegistry;

    if nargin==2&&~isempty(varargin{1})
        AdaptorName=varargin{1};
    else
        AdaptorName=linkfoundation.pjtgenerator.getUninitializedAdaptorName();
    end

    set(h,'AdaptorName',AdaptorName);

    cs=h.getConfigSet;

    if~isempty(cs)
        mdl=get_param(cs.getModel,'Name');
        curname=linkfoundation.util.manageAdaptorName('get',mdl);
        if isempty(curname)...
            ||(AdaptorRegistry.isValidAdaptorName(AdaptorName)&&~isequal(curname,AdaptorName))
            linkfoundation.util.manageAdaptorName('set',mdl,AdaptorName);
        end
    end


    if(AdaptorRegistry.isValidAdaptorName(AdaptorName))

        opts=h.ProjectMgr.getDefaultBuildOptions(AdaptorName);
        set(h,'debugCompilerOptions',opts.compiler.debug);
        set(h,'releaseCompilerOptions',opts.compiler.release);
        set(h,'customCompilerOptions',opts.compiler.custom);
        set(h,'debugLinkerOptions',opts.linker.debug);
        set(h,'releaseLinkerOptions',opts.linker.release);
        set(h,'customLinkerOptions',opts.linker.custom);

        set(h,'compilerOptionsStr',opts.compiler.custom);
        set(h,'linkerOptionsStr',opts.linker.custom);

        set(h,'buildFormat',h.ProjectMgr.getAdaptorSpecificInfo(AdaptorName,'getDefaultBuildFormat'));

        set(h,'buildAction',h.ProjectMgr.getDefaultBuildAction(AdaptorName,get(h,'buildFormat')));
    end
end