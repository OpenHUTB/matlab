classdef RequirementsViewerDataExporter<slreportgen.webview.DataExporter





    properties(SetAccess=private)
        AncestorColorMap;
    end

    properties(Constant,Access=private)
        m_strokeStyle=[...
'stroke: orange;'...
        ,'stroke-opacity: 1;'...
        ,'stroke-width: 4;'...
        ,'stroke-linejoin: miter;'...
        ,'stroke-dasharray: none;'];
    end

    methods
        function h=RequirementsViewerDataExporter()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.Object',@exportRequirements);
            bind(h,'Simulink.Line',@noExport);
            bind(h,'Stateflow.Object',@exportRequirements);
            bind(h,'Stateflow.Transition',@exportRequirementsTransition);
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.DataExporter(h,varargin{:});
            h.AncestorColorMap=getAncestorColoring(h);
        end

        function postExport(h)
            h.AncestorColorMap=[];
            postExport@slreportgen.webview.DataExporter(h);
        end
    end

    methods(Access=private)
        function ret=exportRequirements(h,obj)
            ret=[];
            sid=Simulink.ID.getSID(obj);
            if~isempty(sid)
                reqFile=rmi.Informer.cache(sid);
                if exist(reqFile,'file')
                    ret=struct('color','orange');
                elseif isKey(h.AncestorColorMap,sid)
                    ret=struct('style',h.m_strokeStyle);
                end
            end
        end

        function ret=exportRequirementsTransition(h,obj)
            ret=[];
            sid=Simulink.ID.getSID(obj);
            if~isempty(sid)
                reqFile=rmi.Informer.cache(sid);
                if exist(reqFile,'file')
                    ret=struct('style',h.m_strokeStyle);
                end
            end
        end

        function ancestorColoringMap=getAncestorColoring(h)
            ancestorColoringMap=containers.Map();
            [rsl,rsf]=rmisl.getHandlesWithRequirements(h.ViewExporter.Model);

            nSl=length(rsl);
            for i=1:nSl
                p=get_param(rsl(i),'Parent');
                if isempty(p)
                    continue
                end
                sid=Simulink.ID.getSID(p);
                while~isempty(p)&&~isKey(ancestorColoringMap,sid)
                    ancestorColoringMap(Simulink.ID.getSID(p))=true;
                    p=get_param(p,'Parent');
                end
            end

            nSf=length(rsf);
            for i=1:nSf
                o=slreportgen.utils.getSlSfHandle(rsf(i));
                p=getParent(o);
                if isempty(p)
                    continue
                end
                sid=Simulink.ID.getSID(p);
                while~isempty(p)...
                    &&~isa(p,'Simulink.Root')...
                    &&~isKey(ancestorColoringMap,sid)
                    if(isa(p,'Simulink.Object')||isa(p,'Stateflow.Chart'))
                        sid=Simulink.ID.getSID(p);
                        ancestorColoringMap(sid)=true;
                    end
                    p=getParent(p);
                end
            end
        end
    end
end

