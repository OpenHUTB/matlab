classdef AuthenticationAuthorizationClient<handle




    properties(Access=private)

AccessKeyId


AccessKeySecret
    end

    properties(Constant,Hidden)

        TokenEndpointUrl=driving.internal.heremaps.marketplace.Constants.TokenEndpointURL


        RequestBody=matlab.net.QueryParameter('grant_type','client_credentials')


        SignatureMethod='HMAC-SHA256'
    end

    methods(Hidden)

        function this=AuthenticationAuthorizationClient(keyId,keySecret)

            this.AccessKeyId=keyId;
            this.AccessKeySecret=keySecret;
        end

        function[token,expiration]=requestToken(this)

            header=this.generateHeader();
            data=makeRequest(this,header);



            token=data.access_token;
            expiration=posixtime(datetime('now')-minutes(10))+data.expires_in;
        end

        function response=makeRequest(this,authHeader)

            opts=weboptions(...
            'KeyName','Authorization',...
            'KeyValue',authHeader,...
            'MediaType','application/x-www-form-urlencoded',...
            'Timeout',driving.internal.heremaps.marketplace.Constants.WebRequestTimeout);

            response=webwrite(this.TokenEndpointUrl,string(this.RequestBody),opts);
        end

        function header=generateHeader(this)


            params=struct;



            params.oauth_version='1.0';


            params.oauth_signature_method=this.SignatureMethod;


            params.oauth_nonce=replace([num2str(now),num2str(rand)],'.','');



            timestamp=posixtime(datetime('now','TimeZone','UTC'));
            params.oauth_timestamp=int2str(timestamp);


            params.oauth_consumer_key=this.AccessKeyId;


            qp=matlab.net.QueryParameter(orderfields(params));
            sig=matlab.net.QueryParameter('oauth_signature',this.generateSignature(qp));
            qp=sortQueryParameters([qp,sig]);


            keys=string({qp.Name}');
            values=string({qp.Value}');
            header=keys+'="'+values+'", ';
            header='OAuth '+join(header(:),'');
            header{1}(end-1:end)=[];
        end

        function sig=generateSignature(this,params)








            params=[this.RequestBody,params];
            paramStr=urlencode(string(params));






            baseUrl=urlencode(this.TokenEndpointUrl);
            baseStr=char(join(["POST",baseUrl,paramStr],'&'));




            signingKey=[urlencode(this.AccessKeySecret),'&'];


            try

                hmacDigester=matlab.internal.crypto.SecureDigester(...
                this.SignatureMethod,uint8(signingKey));
                digestBytes=hmacDigester.computeDigest(baseStr);
            catch




                digestBytes=uint8.empty;
            end
            sig=matlab.internal.crypto.base64Encode(digestBytes);
            sig=urlencode(sig);
        end

    end
end

function params=sortQueryParameters(params)
    fields=[params.Name];
    [~,sorted]=sort(fields);
    params=params(sorted);
end