function out=getPerModelInstances(obj,mdl)



    if ischar(mdl)
        mdl=get_param(mdl,'handle');
    end

    list=get_param(mdl,'CodePerspectiveFlags');
    if~iscell(list)
        list={};
    end

    out={};
    for i=1:length(list)
        f=list{i};
        st=f.studio;
        if st.App.blockDiagramHandle==mdl
            out{end+1}=f;%#ok<AGROW>
        end
    end




