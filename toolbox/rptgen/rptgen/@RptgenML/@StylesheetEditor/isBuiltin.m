function tf=isBuiltin(this)




    tf=isempty(this.Registry)||...
    stringEndsWith(this.Registry,'rptstylesheets.xml');

end

function tf=stringEndsWith(strMain,strEnd)
    strEndLen=length(strEnd);
    if length(strMain)>=strEndLen
        tf=strcmp(strMain(end-strEndLen+1:end),strEnd);
    else
        tf=false;
    end
end




