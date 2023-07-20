function flag=isValidCPPIdentifier(hSrc)





    flag=true;

    if~hSrc.isValidIdentifier()
        flag=false;
        return;
    end

    argName=hSrc.ArgName;

    reservedChars={'asm','bool','catch','class','const_cast','delete'...
    ,'dynamic_cast','explicit','export','false','friend'...
    ,'inline','mutable','namespace','new','operator'...
    ,'private','protected','public','reinterpret_cast'...
    ,'static_cast','template','this','throw','true'...
    ,'try','typeid','typename','using','virtual'...
    ,'wchar_t'};

    temp=ismember(reservedChars,argName);
    pos=find(temp,1);
    if~isempty(pos)
        flag=false;
        return;
    end



