function fullPath=getFullPathFromSID(sid,textSizeLimit)








    if nargin==1
        textSizeLimit=0;
    end

    try
        object=Simulink.ID.getHandle(sid);
        if isa(object,'Stateflow.Chart')||isa(object,'Stateflow.EMChart')||...
            contains(class(object),'Stateflow')
            fullPath=object.getFullName;
        else
            fullPath=getfullname(object);
        end

        if textSizeLimit>0
            fullPath=getTruncatedPath(fullPath,textSizeLimit);
        end

    catch ME


        fullPath=sid;
    end

end



function truncatedPath=getTruncatedPath(fullPath,textLimit)
    if(length(fullPath)>textLimit)



        slashIndex=strfind(fullPath,'/');

        if isempty(slashIndex)
            truncatedPath=['...',fullPath(end-textLimit+1:end)];
        else
            truncatedPath='';
            for i=1:length(slashIndex)
                if length(fullPath)-slashIndex(i)<=textLimit
                    truncatedPath=fullPath(slashIndex(i)+1:end);
                    break
                end
            end
            if isempty(truncatedPath)
                truncatedPath=['...',fullPath(end-textLimit+1:end)];
            else
                truncatedPath=['.../',truncatedPath];
            end
        end
    else
        truncatedPath=fullPath;
    end
end