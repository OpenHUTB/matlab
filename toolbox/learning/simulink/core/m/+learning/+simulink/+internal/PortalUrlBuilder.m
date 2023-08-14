classdef PortalUrlBuilder<handle


    properties(Access=public,Hidden)
        basePath='';
        fullUrl='';
        connectorBaseUrl=connector.getBaseUrl;
        connectorPath='';
        matlabLoginFrameworkEndpointUrl='';
        queryParameters=struct('parameter',{},'value',{});
        courseCode='';
    end

    properties(Access=public,Hidden,Constant)
        portalPage='slPortal.html';
        release='R2022b';
        serverRelease='simulinkR2022b';
    end

    methods(Access=public)

        function obj=PortalUrlBuilder(varargin)
            narginchk(0,2);
            obj.basePath=obj.createBasePath();
            obj.matlabLoginFrameworkEndpointUrl=obj.createMatlabLoginFrameworkEndpointUrl();
            inputParams=char(varargin);
            obj.addParamsToUrl(inputParams);

        end

        function obj=resetUrl(obj)
            obj.queryParameters=struct('parameter',{},'value',{});
            obj.addParamsToUrl();
        end

        function obj=addParamsToUrl(obj,varargin)



            if numel(varargin)==1


                inputParam=char(varargin);
                if~isKey(learning.simulink.preferences.slacademyprefs.CourseMap,inputParam)&&~isempty(inputParam)
                    validCourseCodes=strcat('"',learning.simulink.preferences.slacademyprefs.CourseMap.keys,'"');
                    validCourseCodes=strjoin(validCourseCodes,', ');
                    error(message('learning:simulink:resources:InvalidArgs',validCourseCodes));
                end
                if~isempty(inputParam)
                    obj.courseCode=inputParam;
                end
            end

            if isempty(obj.courseCode)

                obj.courseCode=learning.simulink.preferences.slacademyprefs.SimulinkOnrampCourseCode;
            end

            if numel(varargin)==2
                paramValuePair=struct('parameter',varargin{1},...
                'value',varargin{2});

                obj.queryParameters(end+1)=paramValuePair;
            end

            [lang,locale]=learning.simulink.internal.locale();
            environment=learning.simulink.internal.getEnvironment();

            obj.fullUrl=[obj.createBasePath(),...
            '?','course=',obj.courseCode,...
            '&','matlabLoginFrameworkEndpoint=',obj.matlabLoginFrameworkEndpointUrl,...
            '&','release=',obj.serverRelease,...
            '&','language=',lang];
            if~strcmp(environment,'production')
                obj.fullUrl=[obj.fullUrl,...
                '&','matlabLoginTrack=',environment];
            end
            if~strcmpi(lang,'en')




                obj.fullUrl=[obj.fullUrl,...
                '&','locale=',locale];
            end

            if~isempty(obj.queryParameters)
                for idx=1:length(obj.queryParameters)
                    obj.fullUrl=[obj.fullUrl,...
                    '&',obj.queryParameters(idx).parameter,'=',...
                    obj.queryParameters(idx).value];
                end
            end
            obj.fullUrl=connector.applyNonce(obj.fullUrl);
        end

        function fullUrl=getFullUrl(obj)
            fullUrl=obj.fullUrl;
        end

        function setCourseCode(obj,courseCode)
            obj.courseCode=courseCode;
            obj.addParamsToUrl();
        end

        function setLocationHash(obj,chapter,lesson,section)
            obj.fullUrl=[obj.fullUrl,...
            '#','chapter=',num2str(chapter),...
            '&','lesson=',num2str(lesson),...
            '&','section=',num2str(section)];
        end

        function connectorPath=getConnectorPath(obj)
            connectorPath=obj.connectorPath;
        end

        function setConnectorPath(obj,connectorPath)
            obj.connectorPath=connectorPath;
            obj.addParamsToUrl();
        end
    end

    methods(Access=private)
        function basePath=createBasePath(obj)
            basePath=[obj.connectorBaseUrl,...
            obj.getConnectorPath(),...
            'learning_content/',...
            'application/',...
            obj.portalPage];
        end

        function matlabLoginFrameworkEndpointUrl=createMatlabLoginFrameworkEndpointUrl(obj)
            matlabLoginFrameworkEndpointUrl=[obj.connectorBaseUrl,'toolbox/matlab/matlab_login_framework/web/index.html'];
        end
    end
end
