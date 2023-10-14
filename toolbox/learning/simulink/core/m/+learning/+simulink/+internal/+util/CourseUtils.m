classdef CourseUtils
    methods ( Static )
        function course = getCourseFromUrl( url )

            arguments
                url{ mustBeTextScalar }
            end

            chapter = 0;
            lesson = 0;
            section = 0;
            courseCode = '';

            urlToParse = regexprep( url, '#|?', '&' );
            params = matlab.net.QueryParameter( urlToParse );

            for k = 1:length( params )
                a = params( k );
                if strcmp( a.Name, "course" )
                    courseCode = params( k ).Value;
                end
                if strcmp( params( k ).Name, "chapter" )
                    chapter = str2double( params( k ).Value );
                end
                if strcmp( params( k ).Name, "lesson" )
                    lesson = str2double( params( k ).Value );
                end
                if strcmp( params( k ).Name, "section" )
                    section = str2double( params( k ).Value );
                end
            end
            course = struct( 'courseCode', courseCode, 'chapter', chapter, 'lesson', lesson, 'section', section );
        end

        function isEqual = isParamValueEqual( expectedParamValue, userParamValue )

            isExpectedParamText = ischar( expectedParamValue ) || isstring( expectedParamValue );
            isUserParamText = ischar( userParamValue ) || isstring( userParamValue );
            paramsAreText = isExpectedParamText && isUserParamText;

            if iscell( expectedParamValue ) && iscell( userParamValue )



                isEqual =  ...
                    isempty( setdiff( expectedParamValue, userParamValue ) ) &&  ...
                    isempty( setdiff( userParamValue, expectedParamValue ) );
            elseif ~isequal( class( expectedParamValue ), class( userParamValue ) ) && ~paramsAreText


                isEqual = false;
            else
                isEqual = isequal( expectedParamValue, userParamValue );
            end
        end




        function subdomain = getSubdomain( uri )
            fnc = @( url )regexp( url, "(?<=https?://)(.*?)[^.]*", 'match' );
            subdomain = char( fnc( uri ) );
        end



        function addStopFcnForAssessmentBlock( modelName )
            stopFnForAll = 'learning.simulink.modelCallbacks.stopFunction(gcs);';
            fnWithPlot = 'learning.assess.stopFunction(gcs,gcb);';
            currentStopFcn = get_param( modelName, 'StopFcn' );

            currentStopFcn = removeFcn( currentStopFcn, fnWithPlot );
            currentStopFcn = addUniqueFunctionToArray( currentStopFcn, stopFnForAll );


            if ~isempty( learning.assess.getAssessmentWithPlot(  ) )
                currentStopFcn = addUniqueFunctionToArray( currentStopFcn, fnWithPlot );
            end
            set_param( modelName, 'StopFcn', currentStopFcn );

            function fcn = addUniqueFunctionToArray( fcnBase, fcnToAdd )
                fcn = fcnBase;

                if ~strcmp( fcnBase( end  ), ';' )
                    fcn = [ fcnBase, ';' ];
                end
                if ~contains( fcn, fcnToAdd )
                    fcn = [ fcn, fcnToAdd ];
                end
            end
            function fcnBase = removeFcn( fcnBase, fcnToRemove )
                if contains( fcnBase, fcnToRemove )
                    fcnBase = strrep( fcnBase, fcnToRemove, '' );
                end
            end
        end
    end
end


