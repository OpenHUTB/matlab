classdef EntitlementUtils
    methods(Static)






        function enrolledCourses=getCourseEnrollment(courses,courseCodes)
            enrolledCourses={};
            enrollmentCount=size(courses.ListSelfPacedEnrollmentsResponse.selfPacedEnrollments,1);

            for k=1:enrollmentCount
                course=courses.ListSelfPacedEnrollmentsResponse.selfPacedEnrollments(k);
                if ismember(course.selfPacedCourseId.code,courseCodes)


                    if isbetween(datetime('today','TimeZone','UTC'),course.timeSpan.startDate,course.timeSpan.endDate)
                        enrolledCourses=[enrolledCourses,course];
                    end
                end
            end


            isEntitled=learning.simulink.preferences.CourseFeature.hasFeature(learning.simulink.preferences.CourseFeature.Entitlement);
            if isempty(enrolledCourses)&&~isEntitled
                enrolledCourses={struct('selfPacedCourseId',struct('code',courseCodes{1}))};
            end
        end





        function courseProgresses=getCourseProgress(serviceCourses,lookupCourseCodes)
            lang=learning.simulink.internal.locale();
            if learning.simulink.internal.util.EntitlementUtils.isDesktopApp()

                serverRelease=learning.simulink.internal.PortalUrlBuilder.serverRelease;

                courseProgresses=learning.simulink.internal.util.EntitlementUtils.getDesktopReleaseProgress(serviceCourses,lookupCourseCodes,lang,serverRelease);
            else

                versionStruct=learning.simulink.internal.util.EntitlementUtils.getPinnedLrsMap();
                courseProgresses=learning.simulink.internal.util.EntitlementUtils.getOnlineReleaseProgress(serviceCourses,versionStruct,lookupCourseCodes,lang);
            end
        end


        function versionStruct=getPinnedLrsMap()
            versionContent=fileread(fullfile(matlabroot,'toolbox',...
            'learning','simulink','core','m','+learning','+simulink','data','course_release.json'));
            versionStruct=jsondecode(versionContent);
        end

        function courseProgresses=getOnlineReleaseProgress(courses,versionStruct,lookupCourseCodes,language)
            releaseMap={};
            defaultLanguage='en';
            serverReleasePrefix='simulinkR';

            for n=1:length(lookupCourseCodes)
                code=lookupCourseCodes{n};
                lanList=versionStruct.(code);
                releaseLookup=lanList.(language);
                if~isempty(releaseLookup)
                    releaseMap.(code)=[serverReleasePrefix,releaseLookup];
                else
                    releaseMap.(code)=[serverReleasePrefix,lanList.(defaultLanguage)];
                end
            end

            courseProgresses={};
            progressCount=size(courses.ListSelfPacedCourseProgressResponse.selfPacedCourseProgressList,1);
            for k=1:progressCount
                course=courses.ListSelfPacedCourseProgressResponse.selfPacedCourseProgressList(k);
                if(course.percentComplete>0)
                    if ismember(course.selfPacedCourseId.code,lookupCourseCodes)
                        release=releaseMap.(course.selfPacedCourseId.code);
                        if learning.simulink.internal.util.EntitlementUtils.matchDesktopReleaseVersion(course.selfPacedCourseInstanceId.uri,language,release)
                            courseProgresses=[courseProgresses,course];
                        end
                    end
                end
            end
        end

        function courseProgresses=getDesktopReleaseProgress(courses,lookupCourseCodes,language,serverRelease)
            courseProgresses={};
            progressCount=size(courses.ListSelfPacedCourseProgressResponse.selfPacedCourseProgressList,1);
            for k=1:progressCount
                course=courses.ListSelfPacedCourseProgressResponse.selfPacedCourseProgressList(k);
                if(course.percentComplete>0)
                    if ismember(course.selfPacedCourseId.code,lookupCourseCodes)
                        if learning.simulink.internal.util.EntitlementUtils.matchDesktopReleaseVersion(course.selfPacedCourseInstanceId.uri,language,serverRelease)
                            courseProgresses=[courseProgresses,course];
                        end
                    end
                end
            end
        end






        function matchRelease=matchDesktopReleaseVersion(url,lang,releaseVersion)
            matchRelease=false;
            uri=matlab.net.URI(url);
            lan='en';

            if(length(uri.Path{3})==2)
                lan=uri.Path{3};
            end
            if strcmp(uri.Path{2},releaseVersion)&&strcmp(lan,lang)
                matchRelease=true;
            end
        end

        function isDesktop=isDesktopApp()
            import matlab.internal.lang.capability.Capability;
            isDesktop=false;
            if Capability.isSupported(Capability.LocalClient)
                isDesktop=true;
            end
        end
    end
end
