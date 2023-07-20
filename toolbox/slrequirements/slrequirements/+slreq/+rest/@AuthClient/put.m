




function result=put(this,url,inData,eTag)

    serverName=this.getHostUrl(url);
    if~contains(this.server,serverName)
        error(message('Slvnv:oslc:WrongServerName',serverName));
    end

    method=matlab.net.http.RequestMethod.PUT;
    body=matlab.net.http.MessageBody(inData);
    contentTypeField=matlab.net.http.field.ContentTypeField('application/rdf+xml');
    if isempty(this.HttpHeader)

        header=[contentTypeField,...
        matlab.net.http.HeaderField('Accept','application/rdf+xml'),...
        matlab.net.http.HeaderField('OSLC-Core-Version','2.0'),...
        matlab.net.http.HeaderField('If-Match',eTag),...
        this.cookies];
    else
        header=[this.HttpHeader,this.cookies];
    end

    if~isempty(this.AdditionalHttpHeader)
        header=[header,this.AdditionalHttpHeader];
    end

    request=matlab.net.http.RequestMessage(method,header,body);

    options=this.getOptionsWithCredentials();
    response=request.send(url,options);

    result=response.StatusCode;
    if response.StatusCode~=matlab.net.http.StatusCode.OK

        me=MException('slreq:oslc:PUTMethodError',sprintf('%s\nURL: %s\n',response.StatusLine.string,url));

        secMex=MException('Slvnv:oslc:DataError',inData);
        responseData=char((response.Body.Data));
        if~isempty(responseData)


            responseData=reshape(responseData,1,numel(responseData));


            slreq.datamodel.RequirementData.StaticMetaClass;
            trdMex=MException('Slvnv:oslc:ServerError',slreq.cpputils.htmlToText(responseData));
            secMex=secMex.addCause(trdMex);
        end
        me=me.addCause(secMex);
        throwAsCaller(me);
    end
end

