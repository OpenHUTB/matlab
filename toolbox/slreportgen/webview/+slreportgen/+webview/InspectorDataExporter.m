classdef InspectorDataExporter<slreportgen.webview.DataExporter


    properties(Constant,Access=private)
        BlockDiagramParams={
'ModelVersion'
'LastModifiedDate'
'LibraryLinkDisplay'
'ModelBrowserVisibility'
'Dirty'
'Description'
        };

        AnnotationParams={
'Text'
'DropShadow'
'Interpreter'
'FontName'
'FontWeight'
'FontSize'
'FontAngle'
'ForegroundColor'
'BackgroundColor'
'HorizontalAlignment'
'UseDisplayTextAsClickCallback'
        };

        PortParams={
'SignalNameFromLabel'
'MustResolveToSignal'
'ShowPropagatedSignal'
'DataLogging'
'TestPoint'
'SignalObjectPackage'
'StorageClass'
'Description'
'documentLink'
        };
        PortTabs={
        getString(message('slreportgen_webview:modelinspector:ParameterAttributes'));
        getString(message('slreportgen_webview:modelinspector:LoggingAndAccessibility'))
        getString(message('slreportgen_webview:modelinspector:CodeGeneration'))
        getString(message('slreportgen_webview:modelinspector:Documentation'))
        };
        PortTabsIdx=[1,4,6,8];
    end

    properties(Access=private)
        m_DDGInfoCache;
    end

    methods
        function h=InspectorDataExporter()
            h=h@slreportgen.webview.DataExporter();
            bind(h,'Simulink.BlockDiagram',@exportSimulinkBlockDiagram);
            bind(h,'Simulink.Block',@exportSimulinkBlock);
            bind(h,'Simulink.Annotation',@exportSimulinkAnnotation);
            bind(h,'Simulink.Scope',@exportSimulinkScope);
            bind(h,'Simulink.Line',@exportSimulinkLine);
            bind(h,'Stateflow.Object',@exportStateflowObject);
            bind(h,'Stateflow.SLFunction',@exportStateflowSLFunction);
            bind(h,'Stateflow.SimulinkBasedState',@exportStateflowActionState);
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.DataExporter(h,varargin{:});
            h.m_DDGInfoCache=containers.Map();
        end

        function postExport(h)
            h.m_DDGInfoCache=[];
        end
    end

    methods(Access=protected)
        function ret=exportSimulinkBlockDiagram(h,obj)
            nParams=length(h.BlockDiagramParams);
            values=cell(1,nParams);
            for i=1:nParams
                values{i}=get(obj,h.BlockDiagramParams{i});
            end
            ret=h.createInspectorData(h.BlockDiagramParams,values,[],[]);
        end

        function ret=exportSimulinkBlock(h,obj)
            if(strcmp(obj.Mask,'on')&&isa(obj.DialogParameters,'struct'))

                params=fieldnames(obj.DialogParameters);
                nParams=length(params);
                values=cell(1,nParams);
                objH=obj.Handle;
                for i=1:nParams
                    values{i}=get_param(objH,params{i});
                end
                ret=h.createInspectorData(params,values,[],[]);

            else
                ddgInfo=getSlBlockDDGInfo(h,obj);
                ret=createInspectorDataFromDDGInfo(h,ddgInfo);
            end
        end

        function ret=exportSimulinkLine(h,obj)

            portObj=getSourcePort(obj);

            nParams=length(h.PortParams);
            values=cell(1,nParams);
            for i=1:nParams
                values{i}=get(portObj,h.PortParams{i});
            end

            ret=h.createInspectorData(h.PortParams,...
            values,h.PortTabs,h.PortTabsIdx);
        end

        function ret=exportSimulinkScope(~,~)
            ret=[];
        end

        function ret=exportSimulinkAnnotation(h,obj)
            if strcmp(obj.UseDisplayTextAsClickCallback,'off')
                params=[h.AnnotationParams;'ClickFcn'];
            else
                params=h.AnnotationParams;
            end

            nParams=length(params);
            values=cell(1,nParams);
            for i=1:nParams
                values{i}=get(obj,params{i});
            end

            ret=h.createInspectorData(params,values,[],[]);
        end

        function ret=exportStateflowObject(h,obj)
            ddgInfo=slreportgen.webview.utils.DDGInfo(obj);
            ret=createInspectorDataFromDDGInfo(h,ddgInfo);
        end

        function ret=exportStateflowSLFunction(h,obj)
            subsysObj=obj.getDialogProxy();
            ret=exportSimulinkBlock(h,subsysObj);
        end

        function ret=exportStateflowActionState(h,obj)
            subsysObj=obj.getDialogProxy();
            ret=exportSimulinkBlock(h,subsysObj);
        end
    end

    methods(Static,Access=protected)
        function inspectorData=createInspectorData(params,values,tabs,tabs_idx)

            n=numel(values);
            for i=1:n
                v=values{i};
                if(isobject(v)||isstruct(v)||iscell(v))
                    values{i}=mlreportgen.utils.toString(v);
                end
            end

            inspectorData=struct(...
            'params',{params},...
            'values',{values},...
            'tabs',{tabs},...
            'tabs_idx',tabs_idx-1);
        end
    end

    methods(Access=private)
        function inspectorData=createInspectorDataFromDDGInfo(h,ddgInfo)
            inspectorData=h.createInspectorData(...
            ddgInfo.Params,...
            ddgInfo.Values,...
            ddgInfo.Tabs,...
            ddgInfo.TabsParamStartIndex);
        end

        function ddgInfo=getSlBlockDDGInfo(h,obj)
            objClass=class(obj);
            if isKey(h.m_DDGInfoCache,objClass)
                ddgInfo=h.m_DDGInfoCache(objClass);


                reset(ddgInfo,obj);
            else
                ddgInfo=slreportgen.webview.utils.SlBlockDDGInfo(obj);
                if ddgInfo.IsCacheable
                    h.m_DDGInfoCache(class(obj))=ddgInfo;
                end
            end
        end
    end

end