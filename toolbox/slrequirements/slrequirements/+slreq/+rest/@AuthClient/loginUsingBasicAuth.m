function success=loginUsingBasicAuth(this)



    success=false;

    tryUrl=[this.server,'/',this.serviceRoot,'/whoami'];
    method=matlab.net.http.RequestMethod.GET;
    header=matlab.net.http.HeaderField('Content-Type','text/plain');
    request=matlab.net.http.RequestMessage(method,header);
    options=this.getOptionsWithCredentials();

    [loginResponse,~,this.history]=request.send(tryUrl,options);
    if loginResponse.StatusCode~=matlab.net.http.StatusCode.OK
        rmiut.warnNoBacktrace('Slvnv:oslc:LoginFailed',[tryUrl,' ',loginResponse.StatusLine.ReasonPhrase.char]);
        return;
    end


    setCookieFields=loginResponse.getFields('Set-Cookie');
    if isempty(setCookieFields)
        rmiut.warnNoBacktrace('Slvnv:oslc:LoginFailed',[tryUrl,' No Cookie']);
        return;
    end

    cookieInfos=setCookieFields.convert;
    cookieField=matlab.net.http.field.CookieField([cookieInfos.Cookie]);
    request=request.addFields(cookieField);
    [loginResponse,this.headers,this.history]=request.send(tryUrl,options);
    result=char(loginResponse.Body.Data);
    success=endsWith(result,this.user);
    this.status=loginResponse.StatusCode;
    if success
        this.cookies=this.headers.getFields('Cookie');
    end
end



