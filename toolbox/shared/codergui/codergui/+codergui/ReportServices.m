

classdef(Sealed)ReportServices<coder.internal.gui.Serviceable
    enumeration
        Generator([],@codergui.ReportServices.defaultReportGenerator)
        WebClientFactory([],@codergui.ReportServices.webWindowClientFactory)
        ViewerFactory([],@codergui.ReportServices.defaultReportViewer)
        TypeEditorFactory([],@codergui.ReportServices.defaultTypeEditor)
    end

    properties(Hidden,Constant)
        MANIFEST_FILENAME='manifest.json'
        BUILD_INFO_FILE='buildInfo.mat'
        REPORT_INFO_FILE='reportInfo.mat'
        GENERATED_CODE_INFO_FILE='generatedCodeInfo.mat'
        EXPORTED_VALUES_FILE='exported_values.mat'
        SIMULINK_SID_PROPERTY='blockSid'
    end

    methods(Static,Hidden)
        function varargout=defaultReportGenerator(reportContext,varargin)
            if nargout>0
                [varargout{1:nargout}]=codergui.evalprivate('genReportData',reportContext,varargin{:});
            else
                codergui.evalprivate('genReportData',reportContext,varargin{:});
            end
        end

        function viewer=defaultReportViewer(varargin)
            viewer=codergui.ReportViewer(varargin{:});
        end

        function editor=defaultTypeEditor(varargin)
            editor=codergui.internal.typedialog.WorkspaceTypeEditor(varargin{:});
        end

        function client=webWindowClientFactory(clientRoot,varargin)
            client=codergui.internal.WebWindowWebClient(clientRoot,varargin{:});
        end

        function client=headlessClientFactory(clientRoot,varargin)
            client=coderqe.report.HeadlessWebClient(clientRoot,varargin{:});
        end

        function client=externalClientFactory(clientRoot,varargin)
            client=codergui.dev.ExternalWebClient(clientRoot,varargin{:});
        end

        function client=embeddedClientFactory(clientRoot,varargin)
            client=codergui.internal.EmbeddedWebClient(clientRoot,varargin{:});
        end

        function setWebClientType(type,varargin)
            if nargin==0||isempty(type)
                type='webwindow';
            elseif ischar(type)
                type=validatestring(type,{'webwindow','external','headless'});
            else
                assert(isa(type,'function_handle'),...
                'Custom WebClient factories should be function handles');
                type=[];
                func=type;
            end
            if~isempty(type)
                func=codergui.ReportServices.webClientTypeToFunc(type);
            end
            if~isempty(varargin)
                partialArgs=varargin;
                partialFunc=@(varargin)func(varargin{:},partialArgs{:});
                codergui.ReportServices.WebClientFactory.bind(partialFunc);
            else
                codergui.ReportServices.WebClientFactory.bind(func);
            end
            coderapp.internal.gc.ConfigurationFacade.refreshWebClientType();
        end

        function type=getWebClientType()
            resolved=codergui.ReportServices.WebClientFactory.resolve();
            if isequal(resolved,@codergui.ReportServices.webWindowClientFactory)
                type='webwindow';
            elseif isequal(resolved,@codergui.ReportServices.externalClientFactory)
                type='external';
            elseif isequal(resolved,@codergui.ReportServices.headlessClientFactory)
                type='headless';
            else
                type='custom';
            end
        end

        function[filename,filePath]=getReportFilename(folder)
            [filename,filePath]=codergui.internal.fs.ReportFileSystem.getReportFilename(folder);
        end

        function reportTypes=getAllReportTypes()
            persistent cachedReportTypes;
            if isempty(cachedReportTypes)
                cachedReportTypes=codergui.internal.findServiceProviders('codergui.internal.reporttype',...
                'Invoke',true,'Validator',@codergui.ReportServices.validateReportType);
                rows=cell(numel(cachedReportTypes),2);
                rows(:,1)=num2cell(cellfun(@(rt)rt.Priority,cachedReportTypes));
                rows(:,2)=cachedReportTypes;
                rows=sortrows(rows,1,'descend');
                cachedReportTypes=rows(:,2);
            end
            reportTypes=cachedReportTypes;
        end

        function reportType=getReportTypeFromContext(reportContext)
            reportType=[];
            allTypes=codergui.ReportServices.getAllReportTypes();
            for i=1:numel(allTypes)
                if allTypes{i}.isType(reportContext)
                    reportType=allTypes{i};
                    break;
                end
            end
        end

        function valid=validateReportType(reportType)
            if~strcmp(reportType.ClientTypeValue,lower(reportType.ClientTypeValue))
                error('ClientTypeValue must be all lowercase: "%s"',reportType.ClientTypeValue);
            end
            if isempty(which(['matlabshared.mldatx.internal.open_in.',reportType.FileCategory]))||...
                isempty(which(['matlabshared.mldatx.internal.run_in.',reportType.FileCategory]))
                error('Must have MLDATX open hooks named %s.%s.%s and %s.%s.%s on path',...
                'matlabshared.mldatx.internal','open_in',reportType.FileCategory,...
                'matlabshared.mldatx.internal','run_in',reportType.FileCategory);
            end
            valid=true;
        end

        function reportType=getReportType(clientType)
            if isa(clientType,'coder.report.Manifest')
                clientType=clientType.ClientType;
            end
            reportType=[];
            if~isempty(clientType)
                reportTypes=codergui.ReportServices.getAllReportTypes();
                for i=1:numel(reportTypes)
                    if strcmpi(clientType,reportTypes{i}.ClientTypeValue)
                        reportType=reportTypes{i};
                        break;
                    end
                end
            end
            if isempty(reportType)
                reportType=codergui.internal.reporttype.GenericReportType();
            end
        end
    end

    methods(Static,Access=?coderapp.internal.gc.GlobalConfigController)
        function gcSetWebClientType(type)
            if type~="custom"
                codergui.ReportServices.WebClientFactory.bind(codergui.ReportServices.webClientTypeToFunc(type));
            end
        end
    end

    methods(Static,Access=private)
        function func=webClientTypeToFunc(type)
            switch type
            case 'external'

                assert(~isempty(which('codergui.dev.ExternalWebClient')),...
                'External web client use requires coder_web_testtools component');
                func=@codergui.ReportServices.externalClientFactory;
            case 'headless'
                func=@codergui.ReportServices.headlessClientFactory;
            otherwise
                func=@codergui.ReportServices.webWindowClientFactory;
            end
        end
    end
end


