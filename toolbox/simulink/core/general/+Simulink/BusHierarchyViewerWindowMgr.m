




classdef BusHierarchyViewerWindowMgr<handle




    properties(Access=private)


HierWindowList
    end

    methods(Access=protected)


        function this=BusHierarchyViewerWindowMgr()
        end


        function[dlg,window]=findWindow(this,model)


            ind=false;
            if~isempty(this.HierWindowList)

                this.HierWindowList=this.HierWindowList(ishandle(this.HierWindowList));
                if~isempty(this.HierWindowList)
                    allM=arrayfun(@getModel,this.HierWindowList,'UniformOutput',false);
                    ind=strcmp(model,allM);
                end
            end
            if any(ind)
                window=this.HierWindowList(ind);
                dlg=window.fDlg;
            else
                window=Simulink.BusHierarchyViewer(model);
                this.HierWindowList=[this.HierWindowList;window];
                dlg=DAStudio.Dialog(window);
                window.fDlg=dlg;
            end
        end
    end

    methods(Static=true)
        function mgr=getWindowManager()
            persistent WindowMgr;

mlock
            if isempty(WindowMgr)
                WindowMgr=Simulink.BusHierarchyViewerWindowMgr();
            end
            mgr=WindowMgr;
        end


        function dlg=getDialog(model)
            WindowMgr=Simulink.BusHierarchyViewerWindowMgr.getWindowManager;

            [dlg,~]=WindowMgr.findWindow(model);
        end

        function window=getWindow(model)
            WindowMgr=Simulink.BusHierarchyViewerWindowMgr.getWindowManager;

            [~,window]=WindowMgr.findWindow(model);
        end


        function updateCurrentPorts(model,ports)

            if Simulink.BusHierarchyViewerWindowMgr.isWindowOpenForModel(model)
                window=Simulink.BusHierarchyViewerWindowMgr.getWindow(model);
                window.setPorts(ports);
            end
        end


        function ports=getCurrentPorts(model)

            assert(Simulink.BusHierarchyViewerWindowMgr.isWindowOpenForModel(model));
            window=Simulink.BusHierarchyViewerWindowMgr.getWindow(model);
            ports=window.getPorts;
        end


        function isOpen=isWindowOpenForModel(model)
            isOpen=false;
            WindowMgr=Simulink.BusHierarchyViewerWindowMgr.getWindowManager;
            if~isempty(WindowMgr.HierWindowList)

                WindowMgr.HierWindowList=WindowMgr.HierWindowList(ishandle(WindowMgr.HierWindowList));
                if~isempty(WindowMgr.HierWindowList)
                    allM=arrayfun(@getModel,WindowMgr.HierWindowList,'UniformOutput',false);
                    ind=strcmp(model,allM);
                    isOpen=any(ind);
                end
            end
        end
    end
end
