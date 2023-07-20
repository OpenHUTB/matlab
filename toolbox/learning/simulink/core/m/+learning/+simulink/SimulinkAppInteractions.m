classdef SimulinkAppInteractions<handle

    methods(Static)

        function[course_struct,content_path]=getCourseStructFromRemote(courseCode)

            content_path=learning.simulink.SimulinkAppInteractions.getContentPath();
            course_toc_filename=['course_',courseCode,'.json'];
            course_struct_txt=fileread(fullfile(content_path,course_toc_filename));
            course_struct=jsondecode(course_struct_txt);

        end

        function[chapter_idx,concept_idx]=indicesFromConceptSequence(courseCode,conceptSequence)
            course_struct=learning.simulink.SimulinkAppInteractions.getCourseStructFromRemote(courseCode);

            chapter_tmp=cellfun(@(x)contains(x,conceptSequence),...
            {course_struct.chapters.conceptSequence},'UniformOutput',false);

            if iscell(chapter_tmp)
                chapter_logical=cellfun(@any,chapter_tmp);
                if numel({course_struct.chapters(chapter_logical).conceptSequence{:}})>1
                    concept_logical=cellfun(@(x)contains(x,conceptSequence),...
                    {course_struct.chapters(chapter_logical).conceptSequence{:}});
                else
                    concept_logical=true;
                end
            else
                chapter_logical=chapter_tmp;
                concept_logical=true;
            end

            chapter_idx=find(chapter_logical);
            concept_idx=find(concept_logical);

        end

        function courseObject=courseFromURL(url)

            query_string=strsplit(url,'?');
            query_string=query_string{end};



            courseObject=struct('course',{},'chapter',{},'lesson',{},'section',{});

            query_params=strsplit(query_string,{'#','&'});

            for idx=1:numel(query_params)
                currentParam=strsplit(query_params{idx},'=');
                if~strcmp(currentParam{1},'course')
                    currentParam{2}=str2double(currentParam{2});
                end
                if~strcmp(currentParam{1},'time')&&~strcmp(currentParam{1},'snc')
                    courseObject(1).(currentParam{1})=currentParam{2};
                end
            end

        end

        function conceptSequence=conceptSequenceFromIndices(courseCode,chapter_idx,concept_idx)

            course_struct=learning.simulink.SimulinkAppInteractions.getCourseStructFromRemote(courseCode);

            conceptSequence=course_struct.chapters(chapter_idx).conceptSequence{concept_idx};

        end

        function[interaction_num,interaction_file]=sectionToInteraction(courseCode,conceptSequence,section)

            [courseContent,content_path]=learning.simulink.SimulinkAppInteractions.getCourseStructFromRemote(courseCode);
            [chapter_idx,concept_idx]=learning.simulink.SimulinkAppInteractions.indicesFromConceptSequence(courseCode,conceptSequence);


            content_unit_txt=fileread(fullfile(content_path,...
            courseContent.chapters(chapter_idx).conceptSequence{concept_idx},'contentUnit.json'));

            contentUnit=jsondecode(content_unit_txt);

            variant=cellfun(@(x)contains(x,courseCode),{contentUnit.variants.name});

            interaction_file=contentUnit.variants(variant).srcList{section};

            interaction_num=sscanf(interaction_file,'interaction%d.json');

        end

        function section=interactionToSection(courseCode,conceptSequence,interactionFile)

            [courseContent,content_path]=learning.simulink.SimulinkAppInteractions.getCourseStructFromRemote(courseCode);
            [chapter_idx,concept_idx]=learning.simulink.SimulinkAppInteractions.indicesFromConceptSequence(courseCode,conceptSequence);


            content_unit_txt=fileread(fullfile(content_path,...
            courseContent.chapters(chapter_idx).conceptSequence{concept_idx},'contentUnit.json'));
            contentUnit=jsondecode(content_unit_txt);

            variant=cellfun(@(x)contains(x,courseCode),{contentUnit.variants.name});

            section=find(cellfun(@(x)contains(x,interactionFile),...
            contentUnit.variants(variant).srcList));
        end

        function[status_file_location,status_file_name]=statusFileForConceptSequence(courseCode,conceptSequence,section)

            userCoursePath=learning.simulink.SimulinkAppInteractions.getUserContentPath(courseCode);

            status_file_location=fullfile(userCoursePath,conceptSequence);
            status_file_name=['section',num2str(section),'progress.mat'];
        end

        function courseName=getCourseNameFromCode(courseCode)
            courseName=learning.simulink.preferences.slacademyprefs.CourseMap(courseCode).CourseName;
        end

        function modelName=getModelNameFromCourseCode(courseCode)
            courseName=learning.simulink.SimulinkAppInteractions.getCourseNameFromCode(courseCode);
            modelName=strrep(courseName,' ','');
        end

        function modelName=getModelToOpenFromCourseCode(courseCode)
            modelName=learning.simulink.SimulinkAppInteractions.getModelNameFromCourseCode(courseCode);
            if contains(modelName,'Stateflow')
                modelName=[modelName,'/Chart'];
            end
        end

        function contentPath=getContentPath()
            app=learning.simulink.Application.getInstance();
            if app.getTestMode&&~isempty(app.getTestContentDir())
                contentPath=app.getTestContentDir();
                return
            end
            contentPath=learning.simulink.preferences.slacademyprefs.Paths.CoursePath;
        end

        function srcPath=getSLTrainingPath()

            srcPath=learning.simulink.preferences.slacademyprefs.Paths.SrcPath;

        end

        function userCoursePath=getUserContentPath(courseCode)

            userCoursePath=fullfile(learning.simulink.preferences.slacademyprefs.Paths.UserPath,...
            learning.simulink.preferences.slacademyprefs.CourseMap(courseCode).CourseName);

            if exist(userCoursePath,'dir')~=7
                try
                    mkdir(userCoursePath);
                catch ME
                    causeException=MException('',...
                    ['Directory ',userCoursePath,' could not be created.']);
                    ME=addCause(ME,causeException);
                    rethrow(ME)
                end
            end
        end

        function assessment_block_params=getAssessmentParams(contentsRoot,courseObject,task)

            courseCode=courseObject.course;
            section=courseObject.section;
            conceptSequence=learning.simulink.SimulinkAppInteractions.conceptSequenceFromIndices(courseCode,...
            courseObject.chapter,courseObject.lesson);
            interaction=learning.simulink.SimulinkAppInteractions.sectionToInteraction(courseCode,conceptSequence,section);
            interactionFile=fullfile(contentsRoot,conceptSequence,['interaction',num2str(interaction),'.json']);
            interactionStruct=learning.simulink.internal.readInteractionFile(interactionFile);
            question=interactionStruct.simulinkInteraction.questions(task);
            assessment_block_params=struct('grader',question.tasksToKeep,...
            'graderType',question.assessmentType,...
            'graderParams',question.maskParameters);
        end
    end
end
