function success=loginUsingFormAuth(this)





    success=false;

    url_1=[this.server,'/jts/auth/authrequired'];
    url_2=[this.server,'/jts/auth/j_security_check'];
    method=matlab.net.http.RequestMethod.GET;
    header=matlab.net.http.HeaderField('User-Agent','Mozilla/4.0');
    request=matlab.net.http.RequestMessage(method,header);
    options=matlab.net.http.HTTPOptions(...
    'VerifyServerName',false,...
    'CertificateFilename','');

    [loginResponse,~,this.history]=request.send(url_1,options);
    if loginResponse.StatusCode~=matlab.net.http.StatusCode.OK
        this.status=loginResponse.StatusLine.ReasonPhrase.char;
        rmiut.warnNoBacktrace('Slvnv:oslc:FailedLoginPleaseVerify');
        success=false;

        return;
    end

    setCookieFields=loginResponse.getFields('Set-Cookie');
    if isempty(setCookieFields)
        this.status='Cookies not received';
        rmiut.warnNoBacktrace('Slvnv:oslc:FailedLoginPleaseVerify');
        success=false;

        return;
    end
    cookieInfos=setCookieFields.convert;
    cookieField=matlab.net.http.field.CookieField([cookieInfos.Cookie]);


    method=matlab.net.http.RequestMethod.POST;
    request=matlab.net.http.RequestMessage(method,header);


    request=request.addFields('Accept','*/*');
    request=request.addFields('X-Requested-With','XMLHttpRequest');
    request=request.addFields('Content-Type','application/x-www-form-urlencoded; charset=utf-8');
    request=request.addFields('OSLC-Core-Version','2.0');

    request=request.addFields(cookieField);


    request=request.addFields('Referer',url_1);


    credentials=sprintf('j_username=%s&j_password=%s',this.user,this.formEncode(this.passwrapper(this.passcode,this.user)));
    request.Body=matlab.net.http.MessageBody(credentials);


    [loginResponse,this.headers,this.history]=request.send(url_2,options);
    this.cookies=this.headers.getFields('Cookie');
    this.status=loginResponse.StatusCode;



    if this.status==matlab.net.http.StatusCode.OK
        authMessageField=loginResponse.Header.getFields('X-com-ibm-team-repository-web-auth-msg');
        if isempty(authMessageField)
            success=true;
        else
            success=~contains(authMessageField.Value,'authfailed')...
            &&~contains(authMessageField.Value,'authrequired');
        end
    end

    if~success



        whoamiURL=sprintf('%s/%s/whoami',this.server,this.serviceRoot);
        try
            result=this.get(whoamiURL);
            success=endsWith(result,this.user);
            this.status=matlab.net.http.StatusCode.OK;
        catch


            success=false;
        end
    end
end
