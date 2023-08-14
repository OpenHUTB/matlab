function[paths,labels]=transPaths(trans)
    [labels,srcs,dests]=sf('get',trans,'.labelString','.src.id','.dst.id');
    labels=deblank(cellstr(labels));
    srcCell=sf_full_name(srcs);
    destCell=sf_full_name(dests);
    paths=strcat(labels,{' from "'},srcCell,{'" to "'},destCell,{'"'});
end

function names=sf_full_name(ids)
    names=cell(length(ids),1);
    for objIdx=1:length(ids)
        if(ids(objIdx)~=0)
            name=sf('FullNameOf',ids(objIdx),'/');

            names{objIdx}=rmisf.junctionNameIdToSid(name);
        else
            names{objIdx}='';
        end
    end
end
