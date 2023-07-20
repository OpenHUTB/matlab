function signature=getPreview(hSrc,varargin)



    if~isempty(hSrc.cache)
        targetObj=hSrc.cache;
    else
        targetObj=hSrc;
    end

    argSpec=targetObj.codeConstruction();
    signature='';
    if nargin==1
        whichFunctionCode=0;
    else
        whichFunction=varargin{1};
        if strcmp(whichFunction,'step')==1
            whichFunctionCode=0;
        elseif strcmp(whichFunction,'init')==1
            whichFunctionCode=1;
        else
            DAStudio.message('RTW:fcnClass:invalidGetPreviewFunctionType');
            return;
        end
    end

    data=argSpec.ArgSpec;
    argSpec.FunctionName=getFunctionName(targetObj,'step');
    argSpec.InitFunctionName=getFunctionName(targetObj,'init');

    if whichFunctionCode==0
        functionName=argSpec.FunctionName;
    else
        functionName=argSpec.InitFunctionName;
    end

    notConfigured=~hSrc.PreConfigFlag&&isempty(hSrc.Data)&&...
    ~isempty(hSrc.FunctionName);

    if notConfigured||isempty(data)||length(data)==0||whichFunctionCode==1 %#ok
        signature=[functionName,' ( )'];
    else
        signature=[functionName,' ( '];

        for i=1:length(data)
            arg=data(i);



            if i>1&&strcmp(arg.ArgName,data(i-1).ArgName)
                continue;
            end

            if strcmp(arg.SLObjectType,'Outport')&&strcmp(arg.Category,'Value')
                signature=[arg.ArgName,' = ',signature];%#ok

            elseif~strcmp(arg.Category,'None')

                if strcmp(arg.Category,'Pointer')
                    signature=[signature,'* ',arg.ArgName];%#ok
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
