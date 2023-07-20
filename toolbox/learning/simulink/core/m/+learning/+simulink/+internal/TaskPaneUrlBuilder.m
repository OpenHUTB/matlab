

classdef TaskPaneUrlBuilder<learning.simulink.internal.PortalUrlBuilder

    properties(Access=public,Hidden)
        taskPanePage='slTaskPane.html';
    end

    methods(Access=public)

        function obj=TaskPaneUrlBuilder(varargin)

            narginchk(0,2);
            obj.basePath=obj.createBasePath();
            inputParams=char(varargin);
            obj.addParamsToUrl(inputParams);

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


            obj.fullUrl=[obj.createBasePath(),...
            '?','course=',obj.courseCode,...
            '&','release=',obj.serverRelease,...
            '&','language=',lang];

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

        end
    end

    methods(Access=private)
        function basePath=createBasePath(obj)
            basePath=[obj.connectorBaseUrl,...
            obj.getConnectorPath(),...
            'learning_content/',...
            'application/',...
            obj.taskPanePage];
        end

    end

end
