




function[result,eTag,responseStatusCode]=get(this,url)
    eTag='';
    serverName=this.getHostUrl(url);
    if~contains(this.server,serverName)
        error(message('Slvnv:oslc:WrongServerName',serverName));
    end
    method=matlab.net.http.RequestMethod.GET;
    if isempty(this.HttpHeader)
        header=[this.cookies,...
        matlab.net.http.HeaderField('Accept','application/rdf+xml'),...
        matlab.net.http.HeaderField('OSLC-Core-Version','2.0'),...
        ];
    else
        header=[this.HttpHeader,this.cookies];
    end
    if~isempty(this.AdditionalHttpHeader)
        header=[header,this.AdditionalHttpHeader];
    end









    request=matlab.net.http.RequestMessage(method,header);
    options=this.getOptionsWithCredentials();




    response=request.send(url,options);
    responseStatusCode=response.StatusCode;
    if response.StatusCode==matlab.net.http.StatusCode.Unauthorized...
        ||response.StatusCode==matlab.net.http.StatusCode.Gone
        this.resetAuth();

        me=MException('slreq:oslc:GETMethodError',sprintf('%s\nURL: %s\n',response.StatusLine.string,url));

        responseData=getReadableText((response.Body.Data)');
        if~isempty(responseData)

            slreq.datamodel.RequirementData.StaticMetaClass;
            jazzMex=MException('Slvnv:oslc:ServerError',slreq.cpputils.htmlToText(responseData));
        else
            jazzMex=MException(message('Slvnv:oslc:FailedGetPleaseLogin'));
        end
        me=me.addCause(jazzMex);
        throwAsCaller(me);
    end


    jassAuth=response.Header.getFields('X-com-ibm-team-repository-web-auth-msg');
    if~isempty(jassAuth)&&strcmp(jassAuth.Value,'authrequired')
        if~this.loginInProgress()
            this.resetAuth();
            me=MException(message('Slvnv:oslc:FailedGetPleaseLogin'));
            jazzMex=MException('slreq:oslc:GETMethodError','X-com-ibm-team-repository-web-auth-msg: authrequired');
            me=me.addCause(jazzMex);
            throwAsCaller(me);
        end
    end

    if isempty(response.Body.ContentType)
        result=getReadableText((response.Body.Data)');
        eTag=getETagIfPresent(response);
    elseif response.Body.ContentType.Subtype=="json"
        result=response.Body.Data;
    elseif response.Body.ContentType.Subtype=="xml"



        result=string(response.Body);
        eTag=getETagIfPresent(response);
    else
        result=getReadableText((response.Body.Data)');
        eTag=getETagIfPresent(response);
    end

    if isempty(result)
        error(['No data recieved for %s,',newline,'StatusLine: %s'],url,response.StatusLine.ReasonPhrase);
    end

end

function text=getReadableText(data)
    text=char(native2unicode(data,'UTF-8'));
end

function eTag=getETagIfPresent(response)
    etagField=response.Header.getFields(oslc.matlab.Constants.ETAG);
    if~isempty(etagField)
        eTag=char(etagField.Value);
    else
        eTag='';
    end
end
