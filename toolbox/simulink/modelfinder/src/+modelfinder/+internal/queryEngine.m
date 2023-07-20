classdef(Hidden)queryEngine




    properties
        m_dbconnection;
    end
    properties(Constant,Hidden)
        toolboxDBFilePath=fullfile(matlabroot,'toolbox','simulink',...
        'modelfinder_indexing','db','modelfinder.db');
        prefdirDBFilePath=fullfile(prefdir,'__mw_resources_mw__','mf_db',...
        'modelfinder.db');
        derivedDBFilePath=fullfile(matlabroot,'derived','toolbox',...
        'simulink','modelfinder','db','modelfinder.db');
        cur_ver_val="3.1.3";
    end
    methods
        function version=getSchemaVersion(obj)
            version=obj.cur_ver_val;
        end
        function resultStruct=searchImplementation(this,keyword,keyword_blocks)

            this.prepareModelFinderDBForSearch();

            if isempty(keyword)
                resultStruct=[];
                return;
            end

            query=this.createMainSQLSearchQuery(keyword,keyword_blocks);
            this.m_dbconnection.doSql(query);
            SQLResult=this.m_dbconnection.fetchRows;


            if isempty(SQLResult)
                resultStruct=[];
                return;
            end


            numResults=size(SQLResult,2);
            columnNames={'COMPONENT','EXAMPLENAME','PRODUCT','MODELNAME','PATH','DESCRIPTION','ANNOTATION','OFFSETS','SNIPPET','ISDUPLICATEMODEL'};
            resultStruct=cell2struct(reshape([SQLResult{:}]',[length(columnNames),numResults]),columnNames,1);


            resultStruct=modelfinder.internal.queryEngine.validateFiles(resultStruct);
        end
    end
    methods(Access='protected')

        function obj=queryEngine(~)

            aDBFilePath=modelfinder.internal.queryEngine.getActiveDBFilePath();
            obj.m_dbconnection=matlab.depfun.internal.database.SqlDbConnector();
            obj.prepareModelFinderDBForTransaction(aDBFilePath);
            obj.m_dbconnection.connect(aDBFilePath);
            obj.prepareModelFinderDBForSearch();
        end

        function delete(obj)
            obj.m_dbconnection.disconnect;
        end
        function markForReset(this)
            update_old_ver_qry='UPDATE SCHEMA_MASTER SET VERSION="0.0.0"';
            this.m_dbconnection.doSql(update_old_ver_qry);
        end


        function prepareModelFinderDBForSearch(this)
            query=modelfinder.internal.dataStore.SQLSelectExistsSQLITEMASTERFtsjoined();
            this.m_dbconnection.doSql(query);
            isModelFinderDBReady=this.m_dbconnection.fetchRows{1}{1};
            if~isModelFinderDBReady
                query=modelfinder.internal.dataStore.SQLCreateFTSJOINED();
                this.m_dbconnection.doSql(query);
                query=modelfinder.internal.dataStore.SQLInsertFTSJOINEDAll();
                this.m_dbconnection.doSql(query);
            end
        end
        function version_mismatch=isVersionMisMatch(this)


















            version_mismatch=true;
            try
                version_query='SELECT VERSION FROM SCHEMA_MASTER';
                this.m_dbconnection.doSql(version_query);
                result=this.m_dbconnection.fetchRows;
                version_val=result{1}{1};
                if(strcmp(version_val,this.getSchemaVersion())==1)
                    version_mismatch=false;
                end
            catch
                version_mismatch=true;
            end
        end






        function prepareModelFinderDBForTransaction(obj,aDBFilePath)
            if exist(aDBFilePath,'file')~=2
                db_needs_reset=true;
            else
                obj.grantWritePermissionToModelFinderDB(aDBFilePath);
                try
                    obj.m_dbconnection.connect(aDBFilePath);
                    db_needs_reset=obj.isVersionMisMatch();
                    obj.m_dbconnection.disconnect();
                catch
                    db_needs_reset=true;
                end
            end

            if db_needs_reset

                sourceDBFilePath=modelfinder.internal.queryEngine.toolboxDBFilePath;
                if~isfolder(fileparts(aDBFilePath))
                    mkdir(fileparts(aDBFilePath));
                end
                copy_status=copyfile(sourceDBFilePath,aDBFilePath,'f');
                if(copy_status==0)
                    error(['Error copying database to ',aDBFilePath,'.']);
                end

            end



            obj.grantWritePermissionToModelFinderDB(aDBFilePath);
        end

        function grantWritePermissionToModelFinderDB(~,aDBFilePath)
            if exist(aDBFilePath,'file')~=2

                return;
            end
            [status,values]=fileattrib(aDBFilePath);


            user_permission=[values.UserRead,values.UserExecute,values.UserWrite];
            if all(user_permission)

                return;
            end



            if status==1


                [~,~,~]=fileattrib(aDBFilePath,'+w');
                if~ispc
                    [~,~,~]=fileattrib(aDBFilePath,'+x');
                end
            end
        end
    end

    methods(Static,Hidden)
        function resultStruct=search(keyword,keyword_blocks)
            resultStruct=modelfinder.internal.queryEngine.instance().searchImplementation(keyword,keyword_blocks);
        end
        function[resultsToDisplay,resultsMetadata,numDisplayedResults]=processResults(resultStruct)
            resultsIdx=1;
            resultsToDisplay=struct;
            resultsMetadata=struct;
            numResults=length(resultStruct);
            allExampleNames={resultStruct.EXAMPLENAME}';
            allComponents={resultStruct.COMPONENT}';
            allLinks=append(allComponents,'/',allExampleNames);

            counts=grouptransform(allLinks,allLinks,@numel);
            resultStructIdx=1;
            while resultStructIdx<=numResults
                numModelsInExample=counts(resultStructIdx);
                if strcmp(allLinks(resultStructIdx),'EMPTY_COMPONENT/EMPTY_EXAMPLENAME')

                    resultsToDisplay(resultsIdx).matchedIn=modelfinder.internal.queryEngine.findMatchedIn(resultStruct(resultStructIdx).OFFSETS);
                    resultsToDisplay(resultsIdx).matchedPart=resultStruct(resultStructIdx).SNIPPET;
                    resultsToDisplay(resultsIdx).isExample=false;
                    resultsToDisplay(resultsIdx).isProject=false;
                    resultsToDisplay(resultsIdx).projectPath='';
                    resultsToDisplay(resultsIdx).linkedModelPath='';
                    resultsToDisplay(resultsIdx).product='';
                    resultsToDisplay(resultsIdx).name=resultStruct(resultStructIdx).MODELNAME;
                    resultsToDisplay(resultsIdx).link=resultStruct(resultStructIdx).PATH;
                    resultsToDisplay(resultsIdx).isIndependent=true;
                    resultsToDisplay(resultsIdx).isDuplicateFlag=resultStruct(resultStructIdx).ISDUPLICATEMODEL;

                    resultsMetadata(resultsIdx).examplename=resultStruct(resultStructIdx).EXAMPLENAME;
                    resultsMetadata(resultsIdx).modelname=resultStruct(resultStructIdx).MODELNAME;
                    resultsMetadata(resultsIdx).description=resultStruct(resultStructIdx).DESCRIPTION;
                    resultsMetadata(resultsIdx).annotation=resultStruct(resultStructIdx).ANNOTATION;

                    resultsIdx=resultsIdx+1;
                    resultStructIdx=resultStructIdx+1;
                elseif numModelsInExample==1

                    resultsToDisplay(resultsIdx).matchedIn=modelfinder.internal.queryEngine.findMatchedIn(resultStruct(resultStructIdx).OFFSETS);
                    resultsToDisplay(resultsIdx).matchedPart=resultStruct(resultStructIdx).SNIPPET;
                    resultsToDisplay(resultsIdx).projectPath=resultStruct(resultStructIdx).COMPONENT;
                    resultsToDisplay(resultsIdx).isProject=modelfinder.internal.queryEngine.isProject(resultsToDisplay(resultsIdx).projectPath);
                    resultsToDisplay(resultsIdx).isExample=~resultsToDisplay(resultsIdx).isProject;
                    resultsToDisplay(resultsIdx).linkedModelPath=resultStruct(resultStructIdx).PATH;
                    resultsToDisplay(resultsIdx).product=resultStruct(resultStructIdx).PRODUCT;
                    resultsToDisplay(resultsIdx).name=resultStruct(resultStructIdx).EXAMPLENAME;
                    resultsToDisplay(resultsIdx).link=allLinks{resultStructIdx};
                    resultsToDisplay(resultsIdx).isIndependent=false;
                    resultsToDisplay(resultsIdx).isDuplicateFlag=0;

                    resultsMetadata(resultsIdx).examplename=resultStruct(resultStructIdx).EXAMPLENAME;
                    resultsMetadata(resultsIdx).modelname=resultStruct(resultStructIdx).MODELNAME;
                    resultsMetadata(resultsIdx).description=resultStruct(resultStructIdx).DESCRIPTION;
                    resultsMetadata(resultsIdx).annotation=resultStruct(resultStructIdx).ANNOTATION;

                    resultsIdx=resultsIdx+1;
                    resultStructIdx=resultStructIdx+1;
                else

                    resultsToDisplay(resultsIdx).matchedIn=modelfinder.internal.queryEngine.findMatchedIn(resultStruct(resultStructIdx).OFFSETS);
                    resultsToDisplay(resultsIdx).matchedPart=resultStruct(resultStructIdx).SNIPPET;
                    resultsToDisplay(resultsIdx).projectPath=resultStruct(resultStructIdx).COMPONENT;
                    resultsToDisplay(resultsIdx).isProject=modelfinder.internal.queryEngine.isProject(resultsToDisplay(resultsIdx).projectPath);
                    resultsToDisplay(resultsIdx).isExample=~resultsToDisplay(resultsIdx).isProject;
                    resultsToDisplay(resultsIdx).linkedModelPath='';
                    resultsToDisplay(resultsIdx).product=resultStruct(resultStructIdx).PRODUCT;
                    resultsToDisplay(resultsIdx).name=resultStruct(resultStructIdx).EXAMPLENAME;
                    resultsToDisplay(resultsIdx).link=allLinks{resultStructIdx};
                    resultsToDisplay(resultsIdx).isIndependent=false;
                    resultsToDisplay(resultsIdx).isDuplicateFlag=0;
                    resultsIdx=resultsIdx+1;

                    for j=1:numModelsInExample

                        resultsToDisplay(resultsIdx).matchedIn=modelfinder.internal.queryEngine.findMatchedIn(resultStruct(resultStructIdx+j-1).OFFSETS);
                        resultsToDisplay(resultsIdx).matchedPart=resultStruct(resultStructIdx+j-1).SNIPPET;
                        resultsToDisplay(resultsIdx).isExample=false;
                        resultsToDisplay(resultsIdx).projectPath=resultStruct(resultStructIdx).COMPONENT;
                        resultsToDisplay(resultsIdx).isProject=false;
                        resultsToDisplay(resultsIdx).linkedModelPath=resultStruct(resultStructIdx+j-1).EXAMPLENAME;
                        resultsToDisplay(resultsIdx).product='';
                        resultsToDisplay(resultsIdx).name=resultStruct(resultStructIdx+j-1).MODELNAME;
                        resultsToDisplay(resultsIdx).link=resultStruct(resultStructIdx+j-1).PATH;
                        resultsToDisplay(resultsIdx).isIndependent=false;
                        resultsToDisplay(resultsIdx).isDuplicateFlag=0;

                        resultsMetadata(resultsIdx).examplename=resultStruct(resultStructIdx+j-1).EXAMPLENAME;
                        resultsMetadata(resultsIdx).modelname=resultStruct(resultStructIdx+j-1).MODELNAME;
                        resultsMetadata(resultsIdx).description=resultStruct(resultStructIdx+j-1).DESCRIPTION;
                        resultsMetadata(resultsIdx).annotation=resultStruct(resultStructIdx+j-1).ANNOTATION;

                        resultsIdx=resultsIdx+1;
                    end
                    resultStructIdx=resultStructIdx+numModelsInExample;
                end
            end
            numDisplayedResults=resultsIdx-1;
        end
        function query=createMainSQLSearchQuery(keyword,keyword_blocks)
            [SQLMatchPhrase,SQLBlockMatchPhrase]=modelfinder.internal.queryEngine.prepareKeywordsForSearch(keyword,keyword_blocks);

            if isempty(SQLBlockMatchPhrase)
                if strcmp(SQLMatchPhrase,'*')
                    queryWhere='';
                else
                    queryWhere=append('WHERE FTSJOINED MATCH ''',SQLMatchPhrase,'''');
                end
            elseif strcmp(SQLMatchPhrase,'*')
                queryWhere=append('WHERE FTSJOINED MATCH ''',SQLBlockMatchPhrase,'''');
            else
                queryWhere=append('WHERE FTSJOINED MATCH ''',SQLMatchPhrase,' AND ',SQLBlockMatchPhrase,'''');
            end






            query=['SELECT COMPONENT,EXAMPLENAME,PRODUCT,MODELNAME,PATH,DESCRIPTION,ANNOTATION,OFFSET,SNIPPET,CASE WHEN MIN(PATH) OVER (PARTITION BY MODELNAME) = MAX(PATH) OVER (PARTITION BY MODELNAME) THEN 0 ELSE 1 END '...
            ,'FROM (SELECT COMPONENT,EXAMPLENAME,PRODUCT,MODELNAME,PATH,DESCRIPTION,ANNOTATION,OFFSETS(FTSJOINED) AS OFFSET,SNIPPET(FTSJOINED,"<strong>","</strong>","...",-1,11) AS SNIPPET '...
            ,'FROM FTSJOINED ',queryWhere,') '...
            ,'ORDER BY CASE WHEN EXAMPLENAME IS "EMPTY_EXAMPLENAME" THEN 1 ELSE 0 END,EXAMPLENAME;'];
        end
        function[SQLMatchPhrase,SQLBlockMatchPhrase]=prepareKeywordsForSearch(keyword,keyword_blocks)


            keyword=regexprep(lower(keyword),'"','');
            keyword=regexprep(keyword,'*+','*');
            SQLMatchPhrase=regexprep(keyword,'@.+? ','${upper($0(2:end))}');
            if isempty(keyword_blocks)
                SQLBlockMatchPhrase='';
                return;
            end

            blocks=regexprep(keyword_blocks,{'"','\d+$'},'');
            blocks=regexprep(strip(blocks),'\s+',' ');
            blockWords=append('BLOCK:',strsplit(strjoin(blocks)));
            blockTypes=append('BLOCK:',regexprep(blocks,'\s+',''));
            SQLBlockMatchPhrase=append('((',strjoin(blockWords),') OR (',strjoin(blockTypes,' AND '),'))');


        end
        function open_system_smart(displayItem,keyword)
            projectPath=char(modelfinder.internal.queryEngine.getAbsolutePath(displayItem.projectPath));
            if displayItem.isExample
                exampleLink=displayItem.link;
                fprintf("openExample('%s')\n",exampleLink);
                try
                    openExample(exampleLink);
                catch exampleException
                    throw(exampleException);
                end
            elseif displayItem.isProject
                try
                    if endsWith(projectPath,'.prj')
                        openProject(projectPath);
                        fprintf("openProject('%s')\n",projectPath);
                    else
                        modelfinder.internal.queryEngine.openZippedProject(...
                        projectPath,extractAfter(displayItem.name,';'),'');
                    end
                catch projectException
                    throw(projectException);
                end
            elseif endsWith(projectPath,'.zip')

                helperCmd=extractAfter(displayItem.linkedModelPath,';');

                projectZIP=projectPath;
                modelfinder.internal.queryEngine.openZippedProject(projectZIP,helperCmd,displayItem.name);
            elseif endsWith(projectPath,'.prj')

                openProject(projectPath);

                linkedMdl=modelfinder.internal.queryEngine.getAbsolutePath(displayItem.link);
                open_system(linkedMdl);
            else

                modelPath=modelfinder.internal.queryEngine.getAbsolutePath(displayItem.link);
                fprintf("open_system('%s')\n",modelPath);
                try
                    open_system(modelPath);
                catch openModelException
                    throw(openModelException);
                end

                try

                    if(contains(model.matchedIn,'ANNOTATION'))
                        keyword=regexprep(char(keyword),'*','.*');
                        annotations=find_system(model.name,'FindAll','on','Type','annotation');
                        annotation_matches=regexpi(get_param(annotations,'Name'),keyword,'once');
                        annotation_matches_idx=find(~cellfun('isempty',annotation_matches));

                        if(~isempty(annotation_matches_idx))
                            hilite_system(annotations(annotation_matches_idx(1)));
                        end
                    end
                catch
                end
            end
        end
        function openZippedProject(projectZIP,helperCmd,modelName)
            try
                if isempty(helperCmd)
                    modelfinder.internal.queryEngine.defaultHelperCmd(projectZIP);
                else
                    eval(helperCmd);
                    fprintf('%s\n',helperCmd);
                end
            catch
                modelfinder.internal.queryEngine.defaultHelperCmd(projectZIP);
            end
            if~isempty(modelName)
                open_system(modelName);
            end
        end
        function defaultHelperCmd(projectZIP)
            [~,~,projectRoot]=...
            matlab.internal.project.example.projectDemoSetUp(...
            projectZIP,[],false);
            fprintf('openProject(''%s'')\n',projectRoot);
            openProject(projectRoot);
        end
        function[absolutePath,isPathValid]=getAbsolutePath(normalizedPath)
            isPathValid=true;
            modifiedPath=fullfile(matlabroot,normalizedPath);

            if(isfile(normalizedPath))
                absolutePath=normalizedPath;
            elseif(isfile(modifiedPath))
                absolutePath=modifiedPath;
            else
                isPathValid=false;
                absolutePath=[];
            end
        end
        function matchedIn=findMatchedIn(offsets)
            fieldNames={'modelID','MODELNAME','MODELPATH','DESCRIPTION','ANNOTATION','BLOCK','exampleID','COMPONENT','EXAMPLENAME','PRODUCT','DOC'};
            offsets=str2num(offsets)+1;%#ok<ST2NM> % SQL Columns indexed from 0
            uniqueColumns=unique(offsets(1:4:end));
            matchedIn=strjoin(fieldNames(uniqueColumns),' ');
        end
        function projectFlag=isProject(projectPath)
            projectFlag=endsWith(projectPath,{'.prj','.zip'});
        end
        function validResultStruct=validateFiles(resultStruct)
            allPaths={resultStruct.PATH};
            allPathsAbs=fullfile(matlabroot,allPaths);
            validPathsIdx=isfile(allPaths);
            validPathsAbsIdx=isfile(allPathsAbs);
            allProjectPaths={resultStruct.COMPONENT};
            allProjectPathsAbs=fullfile(matlabroot,allProjectPaths);
            validProjectPathsIdx=isfile(allProjectPaths);
            validProjectPathsAbsIdx=isfile(allProjectPathsAbs);

            notPathOrProject=~(validPathsAbsIdx|validPathsIdx|validProjectPathsIdx|validProjectPathsAbsIdx);


            resultStruct(notPathOrProject)=[];
            validResultStruct=resultStruct;
        end
        function reset()
            modelfinder.internal.queryEngine.instance().markForReset();
            modelfinder.internal.queryEngine.instance('Clear');
            modelfinder.internal.queryEngine.instance();
        end
        function obj=instance(varargin)
            persistent finder_instance;
            arg={''};
            arg(1:nargin)=varargin;

            if strcmp(arg{1},'Clear')==1
                finder_instance=[];
                obj=finder_instance;
                return;
            end

            if isempty(finder_instance)
                finder_instance=modelfinder.internal.queryEngine();
            end

            obj=finder_instance;
        end

        function[aEnvironment]=activeDBEnvironment(aAction,varargin)
            persistent sEnvironment;

            if strcmp(aAction,'Set')
                sEnvironment=varargin{1};
            end

            aEnvironment=sEnvironment;
        end

        function aDBFilePath=getActiveDBFilePath()
            aEnvironment=modelfinder.internal.queryEngine.activeDBEnvironment('Get');
            if strcmp(aEnvironment,'BaT')

                aDBFilePath=modelfinder.internal.queryEngine.derivedDBFilePath;
            else

                aDBFilePath=modelfinder.internal.queryEngine.prefdirDBFilePath;
            end
        end
    end
end
