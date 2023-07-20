function comments=hdlannotationcomments(node)




    if hdlismatlabmode
        comments='';
        return;
    end

    comment_char=hdlgetparameter('comment_char');

    fp=get(node,'FullPath');


    annos=find_system(fp,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','annotation');

    if~isempty(annos)

        ypos=zeros(1,length(annos));
        for n=1:length(annos)
            xypos=get(annos(n),'Position');
            ypos(n)=xypos(2);
        end
        [~,indx]=sort(ypos);
        annos=annos(indx);

        comments='\n\n';
        separatorline=[comment_char,' ','-'*ones(1,63-length(comment_char)),'\n'];
        comments=[comments,...
        separatorline,...
        comment_char,' Model Comments: \n',...
        comment_char,'\n'];
        for n=1:length(annos)
            cstr=get(annos(n),'Name');
            cstr=[comment_char,' ',strrep(cstr,char(10),[char(10),comment_char,' '])];
            comments=[comments,cstr,'\n',comment_char,'\n'];%#ok
        end
        comments=[comments,separatorline,'\n'];
    else
        comments='';
    end
end
