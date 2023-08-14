function mcosObj=convertMCOS(nodeObj)

    if isempty(nodeObj)
        mcosObj=[];
    else
        for i=1:length(nodeObj)
            if isa(nodeObj(i),'DAStudio.DAObjectProxy')
                mcosObj(i)=nodeObj(i).getMCOSObjectReference;%#ok<AGROW>
            else
                mcosObj(i)=nodeObj(i);%#ok<AGROW>
            end
        end
    end
end