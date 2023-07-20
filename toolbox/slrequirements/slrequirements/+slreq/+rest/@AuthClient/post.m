function response=post(this,url,inData,eTag)



    method=matlab.net.http.RequestMethod.POST;
    body=matlab.net.http.MessageBody(inData);
    if isempty(this.HttpHeader)
        contentTypeField=matlab.net.http.field.ContentTypeField('application/rdf+xml');

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
    if response.StatusCode~=matlab.net.http.StatusCode.Created

        me=MException('slreq:oslc:POSTMethodError',sprintf('%s\nURL: %s\n',response.StatusLine.string,url));

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

