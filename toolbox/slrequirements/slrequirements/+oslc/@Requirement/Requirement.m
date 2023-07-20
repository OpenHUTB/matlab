

classdef Requirement<handle

    properties(SetAccess=private)
identifier
title
projectName
queryBase
resource
label
    end

    properties(Constant,Hidden)

        dummyTitle='SLREQ_DUMMY_REQ';
        dummyResourceBase='https://SLREQ.DUMMY.RESOURCE';
    end

    methods

        function obj=Requirement(req,projectName,queryBase)
            obj.identifier=req.identifier;
            obj.resource=req.resource;
            obj.title=req.title;
            obj.projectName=projectName;
            obj.queryBase=queryBase;
            obj.label=oslc.makeLabel(req.identifier,req.title,projectName);
        end

        function updateQueryBase(this,newQueryBase)
            this.queryBase=newQueryBase;
        end

    end

    methods(Static)

        function varargout=registry(req)
            persistent requirements ids
            if isempty(requirements)
                requirements=containers.Map('KeyType','char','ValueType','any');
                requirements('ID')='MCOS Object';
                ids=containers.Map('KeyType','char','ValueType','char');
                ids('url')='ID';
            end
            if nargin>0
                if isnumeric(req)
                    id=num2str(req);
                elseif ischar(req)
                    if strcmp(req,'_clear_')

                        varargout{1}=requirements.Count-1;
                        requirements=[];
                        return;
                    else
                        id=req;
                    end
                else

                    if isKey(requirements,req.identifier)
                        requirements([req.identifier,'.'])=req;
                    else
                        requirements(req.identifier)=req;
                    end
                    ids(req.resource)=req.identifier;
                    return;
                end
                if all(id>47&id<59)
                    if isKey(requirements,id)
                        varargout{1}=requirements(id);
                    else
                        varargout{1}=[];
                    end
                else
                    if isKey(ids,id)
                        varargout{1}=ids(id);
                    else
                        varargout{1}='';
                    end
                end
            else
                varargout{1}=keys(requirements);
            end
        end

        function reqData=getRequirements(connection,reqURIs,projName,projBase,progressOption)

            if nargin==5
                if islogical(progressOption)
                    showProgress=progressOption;
                    isUI=false;
                else
                    showProgress=true;
                    isUI=true;
                    progressBarInfo=progressOption;
                end
            else
                isUI=false;
                showProgress=false;
            end
            if showProgress&&isUI
                rmiut.progressBarFcn('set',progressBarInfo.range(1),progressBarInfo.text);
            end

            totalURIs=length(reqURIs);

            reqData=struct(...
            'resource',cell(totalURIs,1),...
            'identifier',cell(totalURIs,1),...
            'title',cell(totalURIs,1));

            skip=false(size(reqURIs));

            for i=1:totalURIs
                oneURI=reqURIs{i};
                if isempty(oneURI)
                    skip(i)=true;
                else
                    reqData(i)=oslc.Requirement.parseReqData(oneURI,connection);
                    oslc.Requirement.register(reqData(i),projName,projBase);
                end
                if showProgress&&mod(i,5)==0
                    if isUI
                        if rmiut.progressBarFcn('isCanceled')
                            break;
                        end
                        progressValue=progressBarInfo.range(1)+(progressBarInfo.range(2)-progressBarInfo.range(1))*double(i)/totalURIs;
                        rmiut.progressBarFcn('set',progressValue,progressBarInfo.text);
                    elseif mod(i,100)==0
                        fprintf('\n');
                    else
                        fprintf('.');
                    end
                end
            end

            if any(skip)
                reqData(skip)=[];
            end
        end

        function reqData=parseReqData(data,myConnection)
            if contains(data,'oslc_rm:Requirement')

                rdf=data;









                memberTag=strfind(rdf,'</rdfs:member>');
                if length(memberTag)>1
                    rdf=rdf(1:memberTag(1)+length('</rdfs:member'));
                end
                reqData.resource=oslc.parseValue(rdf,'oslc_rm:Requirement rdf:about=');
                if isempty(reqData.resource)

                    reqData.resource=oslc.parseValue(rdf,'oslc_rm:RequirementCollection rdf:about=');
                end
            else

                reqData.resource=data;
                urlWithConfig=oslc.matlab.DngClient.appendContextParam(reqData.resource);
                rdf=char(myConnection.get(urlWithConfig));
                if isempty(rdf)

                    reqData=[];
                    return;
                end
            end
            reqData.identifier=oslc.Requirement.parseIdentifier(rdf);
            reqData.title=oslc.getTitle(rdf,'dcterms');
        end

        function reqData=getCachedItems(numericIDs)

            stringIDs=num2str(numericIDs(:));
            cellIDs=strtrim(cellstr(stringIDs));
            reqData=struct('identifier',cellIDs,'title','','resource','');

            for i=1:length(numericIDs)
                id=numericIDs(i);
                reqObj=oslc.Requirement.registry(num2str(id));
                if isempty(reqObj)



                    error('Requirement.getCachedItems(): mismatched ID requested: %d',id);
                else
                    reqData(i).title=reqObj.title;
                    reqData(i).resource=reqObj.resource;
                end
            end
        end

        function result=updateDetails(id)
            req=oslc.Requirement.registry(id);
            if isempty(req)
                result='';
            else
                connection=oslc.connection();
                rdf=char(connection.get(req.resource));
                if~isempty(rdf)


                    req.title=oslc.Requirement.parseRequirementDetails(rdf);
                end
                req.label=oslc.makeLabel(req.identifier,req.title,req.projectName);
                result=[req.identifier,' (',req.title,')'];
            end
        end

        function id=resourceUrlToId(userUrl)
            matched=regexp(userUrl,'artifactURI=([^&]+)','tokens');
            if~isempty(matched)
                req.resource=urldecode(matched{1}{1});
                myConnection=oslc.connection();
                rdf=char(myConnection.get(req.resource));
                req.identifier=oslc.Requirement.parseIdentifier(rdf);
                req.title=oslc.Requirement.parseRequirementDetails(rdf);
                [projName,projBase]=oslc.Project.currentProject();
                if isempty(projBase)
                    rmiut.warnNoBacktrace('Slvnv:oslc:CurrentProjectNotSet');
                    beep;
                    id='';
                else
                    oslc.Requirement.register(req,projName,projBase);
                    id=req.identifier;
                end
            else
                rmiut.warnNoBacktrace('Slvnv:oslc:FailedToParseUrl',userUrl);
                beep;
                id='';
            end
        end

        function reqObj=register(req,projectName,queryBase)
            if nargin<3
                proj=oslc.Project.get(projectName);
                queryBase=proj.queryBase;
            end
            reqObj=oslc.Requirement(req,projectName,queryBase);
            oslc.Requirement.registry(reqObj);
        end
    end

    methods(Static,Access='private')

        function uri=parseResourceURI(rdf)
            uri=oslc.parseValue(rdf,'rdf:Description rdf:about=');
            if isempty(uri)
                uri='PARSE ERROR: resource URI not known';
            end
        end

        function uri=parseProviderURI(rdf)
            uri=oslc.parseValue(rdf,'oslc:serviceProvider rdf:resource=');
            if isempty(uri)
                uri='PARSE ERROR: provider URI not known';
            end
        end

        function id=parseIdentifier(rdf)
            id=oslc.parseValue(rdf,'dcterms:identifier');
            if isempty(id)

                id=oslc.parseValue(rdf,'dc:identifier');
            end
            if isempty(id)
                id='PARSE ERROR: Identifier not known';
            end
        end

        function[title]=parseRequirementDetails(rdf)
            title=oslc.getTitle(rdf);








        end

    end

end

