function addlegend(h,hlines,names)




    l=get(gca,'Legend');
    if isempty(l)
        legend(hlines,{names{1:end}},'Location','NorthEast','AutoUpdate','off');
    else
        string=get(l,'String');
        exist_legend=numel(string);
        new_legend=numel(names);
        for ii=1:new_legend
            string{exist_legend+ii}=names{ii};
        end
        legend({string{1:end}},'Location','NorthEast','AutoUpdate','off');
    end

    hobjs=findobj(gca,'Type','patch');
    if~isempty(hobjs)
        hasbehavior(findobj(gca,'Type','patch'),'legend',false);
    end