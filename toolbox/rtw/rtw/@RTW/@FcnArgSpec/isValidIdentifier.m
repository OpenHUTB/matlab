function flag=isValidIdentifier(hSrc)





    flag=true;

    if strcmp(hSrc.Category,'None')
        return;
    end

    argName=hSrc.ArgName;

    if isempty(argName)||~ischar(argName)
        flag=false;
        return;
    end

    if~((argName(1)>='a'&&argName(1)<='z')||...
        (argName(1)>='A'&&argName(1)<='Z')||...
        (argName(1)=='_'))
        flag=false;
        return;
    end

    reservedChars={'auto','break','case','char','const','continue',...
    'default','do','double','else','enum','extern',...
    'float','for','goto','if','int','long','register',...
    'return','short','signed','sizeof','static','struct',...
    'switch','typedef','union','unsigned','void','volatile',...
    'while'};

    allowedChars=['_'];

    temp=ismember(reservedChars,argName);
    pos=find(temp);
    if~isempty(pos)
        flag=false;
        return;
    end

    for i=2:length(argName)
        if(argName(i)>='a'&&argName(i)<='z')||...
            (argName(i)>='A'&&argName(i)<='Z')||...
            (argName(i)>='0'&&argName(i)<='9')
            continue;
        end

        temp=ismember(allowedChars,argName(i));
        pos=find(temp);
        if isempty(pos)
            flag=false;
            return;
        end
    end



