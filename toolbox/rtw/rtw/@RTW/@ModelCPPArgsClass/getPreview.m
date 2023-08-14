function signature=getPreview(hSrc,varargin)



    if~isempty(hSrc.cache)
        targetObj=hSrc.cache;
    else
        targetObj=hSrc;
    end

    argSpec=targetObj.codeConstruction();
    signature='';%#ok
    data=argSpec.ArgSpecData;
    argSpec.FunctionName=getStepMethodName(targetObj);

    notConfigured=~hSrc.PreConfigFlag&&isempty(hSrc.Data)&&...
    ~isempty(hSrc.FunctionName);

    if notConfigured||isempty(data)||length(data)==0 %#ok
        signature=[argSpec.ModelClassName,' :: ',argSpec.FunctionName,' ( )'];
    else
        signature=[argSpec.ModelClassName,' :: ',argSpec.FunctionName,' ( '];

        for i=1:length(data)
            arg=data(i);



            if i>1&&strcmp(arg.ArgName,data(i-1).ArgName)
                continue;
            end

            if strcmp(arg.SLObjectType,'Outport')&&strcmp(arg.Category,'Value')
                signature=[arg.ArgName,' = ',signature];%#ok               
            else
                if strcmp(arg.Category,'Pointer')
                    signature=[signature,'* ',arg.ArgName];%#ok
                elseif strcmp(arg.Category,'Reference')
                    signature=[signature,'& ',arg.ArgName];%#ok
                else
                    signature=[signature,arg.ArgName];%#ok
                end

                if i~=length(data)&&...
                    ~(i==length(data)-1&&strcmp(arg.ArgName,data(i+1).ArgName))


                    signature=[signature,', '];%#ok
                end
            end
        end

        signature=[signature,' )'];
    end
