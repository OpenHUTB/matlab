


classdef ProjectContainer

    methods(Abstract=true,Access=public)
        javaProjectManager=getJavaProjectManager(obj);
        projectControlSetRef=getJavaProjectControlSet(obj);
        manager=getMatlabAPIProjectManager(obj);
    end

end
