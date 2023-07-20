














































function result=find(arg1,slreqType,varargin)
    result=[];
    disjunctions=breakDisjunctions(arg1,slreqType,varargin{:});
    for i=1:length(disjunctions)
        disjunction=disjunctions{i};
        result=[result,realfind(disjunction{:})];
    end
end

function disjunctions=breakDisjunctions(arg1,slreqType,varargin)
    disjunctions={};
    query={arg1,slreqType};
    compatibleTypes={{'ReqSet'},{'LinkSet'},{'Link'},{'Requirement','Reference','Justification'}};
    curTypeIdx=cellfun(@(e)any(strcmpi(e,slreqType)),compatibleTypes);
    i=1;
    while i<=numel(varargin)
        if strcmpi(varargin{i},'-or')
            disjunctions{end+1}=query;
            if i+2<=numel(varargin)&&strcmpi(varargin{i+1},'type')&&...
                any(strcmpi(varargin{i+2},["requirement","link","Reqset","Reference","Justification","linkset"]))
                nxtType=varargin{i+2};
                query={varargin{i+1},nxtType};
                i=i+2;
                if~any(strcmpi(compatibleTypes{curTypeIdx},nxtType))
                    error(message('Slvnv:slreq:APIErrorIncompatibleTypes'));
                end
            else
                query={arg1,slreqType};
            end
        else
            query{end+1}=varargin{i};
        end
        i=i+1;
    end
    disjunctions{end+1}=query;
end

function result=realfind(arg1,slreqType,varargin)
    arg1=convertStringsToChars(arg1);
    slreqType=convertStringsToChars(slreqType);
    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if~strcmpi(arg1,'type')
        error(message('Slvnv:slreq:NeedNameValuePair'));
    end

    if startsWith(slreqType,'slreq.')
        slreqType=strrep(slreqType,'slreq.','');
    end

    returnDataObj=false;

    sidSecondPass={};










    args={slreqType};
    for i=1:2:length(varargin)
        [prop,op]=strtok(varargin{i},':');
        if((i+1)>length(varargin))
            val='';
        else
            val=varargin{i+1};
        end

        if strcmp(prop,'_returnType')
            returnDataObj=true;
            continue;
        end


        if strcmpi(prop,'id')

            if strcmpi(slreqType,'Reference')
                prop='uniqueCustomId';
            elseif strcmpi(slreqType,'Requirement')
                sidSecondPass=constructIdSecondPass(varargin{:});
                prop='customId';
            else
                prop='sid';
            end
        elseif strcmpi(prop,'Custom ID')
            prop='customId';
        elseif strcmpi(prop,'Index')
            prop='hIdx';
            for rSet=slreq.data.ReqData.getInstance().query({'ReqSet'})
                slreq.data.ReqData.getWrappedObj(rSet).updateHIdx();
            end
        elseif strcmpi(prop,'FileRevision')
            prop='revision';
        elseif strcmpi(prop,'type')
            prop='typeName';





        elseif strcmpi(prop,'ReqType')
            prop='typeName';
        elseif strcmpi(prop,'LinkType')
            prop='typeName';
        elseif strcmpi(prop,'Filename')
            prop='filepath';
        elseif strcmpi(prop,'Artifact')
            prop='artifactUri';
        elseif strcmpi(prop,'keywords')
            prop='keywords';
        else



            if isDateTime(prop,strcmpi(slreqType,'Link'))
                if isempty(val)
                    error(message('Slvnv:slreq:APIErrorOnDatetime',prop));
                end
                try
                    localD=datetime(val);
                    utcD=slreq.utils.getDateTime(localD,'Write');
                    val=datestr(utcD,'yyyymmddTHHMMSS');
                catch
                    error(message('Slvnv:slreq:APIErrorOnDatetime',prop));
                end
            end
        end

        args{end+1}=[prop,op];

        if(isenum(val))
            val=char(val);
        elseif(isnumeric(val)||islogical(val))
            val=num2str(val);
        end


        if strcmpi(prop,'sid')&&~isempty(val)&&val(1)=='#'
            val=val(2:end);
        end


        if(strcmpi(slreqType,'LinkSet')&&strcmpi(prop,'Name'))
            if(reqmgt('rmiFeature','IncArtExtInLinkFile')&&~isempty(val)&&val(1)~='~')



                oldVal=val;
                val=['~',oldVal,'(~\w*)?$'];
            end
        end


        if~isempty(val)&&val(1)=='~'
            args{end}=strcat(args{end},':regexp');
            val=val(2:end);

            if(val(end)~='$')
                val=strcat(val,'.*');
            end
            if(val(1)~='^')
                val=strcat('^.*',val);
            end
        end



        if strcmpi(prop,'revision')&&strcmp(val,'1')
            args{end}=strcat(args{end},':<=');
        end

        args{end+1}=val;
    end

    mfObjs=slreq.data.ReqData.getInstance().query(args);


    if(isempty(mfObjs))
        if~isempty(sidSecondPass)
            result=slreq.find(arg1,slreqType,sidSecondPass{:});
            return;
        end
        if strcmpi(slreqType,'requirement')
            if returnDataObj
                result=slreq.data.Requirement.empty;
            else
                result=slreq.Requirement.empty;
            end
        elseif strcmpi(slreqType,'link')
            if returnDataObj
                result=slreq.data.Link.empty;
            else
                result=slreq.Link.empty;
            end
        elseif strcmpi(slreqType,'Reference')
            if returnDataObj
                result=slreq.data.Requirement.empty;
            else
                result=slreq.Reference.empty;
            end
        elseif strcmpi(slreqType,'ReqSet')
            if returnDataObj
                result=slreq.data.RequirementSet.empty;
            else
                result=slreq.ReqSet.empty;
            end
        elseif strcmp(slreqType,'LinkSet')
            if returnDataObj
                result=slreq.data.LinkSet.empty;
            else
                result=slreq.LinkSet.empty;
            end
        else
            result=[];
        end
        return
    end

    len=numel(mfObjs);
    objType=class(mfObjs(1));
    switch objType
    case 'slreq.datamodel.Link'
        if returnDataObj
            result=slreq.data.Link.empty(0,len);
        else
            result=slreq.Link.empty(0,len);
        end
    case{'slreq.datamodel.Requirement','slreq.datamodel.MwRequirement'}
        if returnDataObj
            result=slreq.data.Requirement.empty(0,len);
        else
            result=slreq.Requirement.empty(0,len);
        end
    case 'slreq.datamodel.ReqSet'
        if returnDataObj
            result=slreq.data.RequirementSet.empty(0,len);
        else
            result=slreq.ReqSet.empty(0,len);
        end
    case 'slreq.datamodel.LinkSet'
        if returnDataObj
            result=slreq.data.LinkSet.empty(0,len);
        else
            result=slreq.LinkSet.empty(0,len);
        end
    end

    for i=1:numel(mfObjs)
        dataObj=slreq.data.ReqData.getWrappedObj(mfObjs(i));

        if~returnDataObj
            result(i)=slreq.utils.dataToApiObject(dataObj);
        else
            result(i)=dataObj;
        end
    end

    if~isempty(sidSecondPass)
        try
            result=[result,slreq.find('type',slreqType,sidSecondPass{:})];
        catch

        end
    end
end


function params=constructIdSecondPass(varargin)
    params={};
    for i=1:2:length(varargin)
        [prop,op]=strtok(varargin{i},':');
        if((i+1)>length(varargin))
            val='';
        else
            val=varargin{i+1};
        end

        if strcmpi(prop,'id')
            params{end+1}='customId';
            params{end+1}='';
            if isempty(op)
                prop='sid';
            else
                prop=['sid',op];
            end
        end
        params{end+1}=prop;
        params{end+1}=val;
    end
end


function tf=isDateTime(prop,forLink)
    tf=false;
    switch lower(prop)
    case{'modifiedon','createdon','linkedtime','synchronizedon'}
        tf=true;
    otherwise





        if forLink
            sets=slreq.data.ReqData.getInstance().getLoadedLinkSets();
        else
            sets=slreq.data.ReqData.getInstance().getLoadedReqSets();
        end
        for i=1:length(sets)
            try
                atrb=sets(i).getCustomAttribute(prop);
                if~isempty(atrb)&&atrb.type==slreq.datamodel.AttributeRegType.DateTime
                    tf=true;
                    break;
                end
            catch
            end
        end
    end

end

