function outval=validateName(obj,iname)



    if~(ischar(iname))

        DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidSyntaxAPName',class(iname));
    end


    iname=strtrim(iname);


    apnames=properties(obj);
    for i=1:length(apnames)
        ap=obj.(apnames{i});

        if(strcmp(iname,ap.Name))
            outval=ap.Name;
            return;
        end


        matchIdx=find(strcmp(iname,ap.AliasNames),1);
        if~isempty(matchIdx)
            outval=ap.Name;
            return;
        end
    end



    opts=['{',strjoin(apnames,', '),'}'];
    DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidAPName',iname,class(obj),opts);

end
