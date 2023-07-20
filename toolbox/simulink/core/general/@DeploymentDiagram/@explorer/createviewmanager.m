function createviewmanager(h)







    vm=h.getViewManager;
    if isempty(vm)
        vm=DeploymentDiagram.MappingViewManager(h);
        vm.install(h,false);
    end


