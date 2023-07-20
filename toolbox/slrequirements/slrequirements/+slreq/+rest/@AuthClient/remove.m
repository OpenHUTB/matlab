function result=remove(this,url)



    method=matlab.net.http.RequestMethod.DELETE;
    contentTypeField=matlab.net.http.field.ContentTypeField('application/rdf+xml');
    if isempty(this.HttpHeader)

        header=[contentTypeField,...
        matlab.net.http.HeaderField('Accept','application/rdf+xml'),...
        matlab.net.http.HeaderField('OSLC-Core-Version','2.0'),...
        matlab.net.http.HeaderField('If-Match',''),...
        this.cookies];
    else
        header=[this.HttpHeader,this.cookies];
    end

    if~isempty(this.AdditionalHttpHeader)
        header=[header,this.AdditionalHttpHeader];
    end
    request=matlab.net.http.RequestMessage(method,header,'');

    options=this.getOptionsWithCredentials();
    response=request.send(url,options);
    result=response.StatusCode;

    if response.StatusCode~=matlab.net.http.StatusCode.OK

        me=MException('slreq:oslc:DELETEMethodError',sprintf('%s\nURL: %s\n',response.StatusLine.string,url));
        responseData=char((response.Body.Data));
        if~isempty(responseData)


            responseData=reshape(responseData,1,numel(responseData));


            slreq.datamodel.RequirementData.StaticMetaClass;
            secMex=MException('Slvnv:oslc:ServerError',slreq.cpputils.htmlToText(responseData));
            me=me.addCause(secMex);
        end
        throwAsCaller(me);
    end
end