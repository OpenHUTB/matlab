function[splitWarnings,func]=getIndexServerRootAndModifyWarnings(funcName,...
    result,serverroot,splitWarnings,func)

    index=find(strncmp(serverroot,result,length(serverroot)),1);


    if(~isempty(index))
        allPos=find(ismember(func,funcName));
        onlyByMATLABOnline=allPos(index:end);
        splitWarnings(onlyByMATLABOnline)=[];
        func(onlyByMATLABOnline)=[];
    end