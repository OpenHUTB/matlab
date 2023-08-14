



function projectType=findCoderProjectType()
    import com.mathworks.project.impl.plugin.PluginManager;
    import com.mathworks.toolbox.coder.app.CoderApp;

    PluginManager.allowMatlabThreadUse();
    targets=PluginManager.getLicensedTargets();
    targetIterator=targets.iterator();


    if CoderApp.isUsingUnifiedUIForC()
        activeProjectType='plugin.coder';
    else
        activeProjectType='plugin.matlabcoder';
    end

    while targetIterator.hasNext()
        target=targetIterator.next();
        key=target.getPlugin().getKey();
        if strcmp(key,activeProjectType)
            projectType=target;
            return;
        end
    end
end