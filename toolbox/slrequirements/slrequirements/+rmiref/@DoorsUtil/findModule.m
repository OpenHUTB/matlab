function resolved=findModule(doc)




    doc=strtrim(doc);






    all_modules_info=rmidoors.listModules();




    if any(strcmp(all_modules_info(:,1),doc))
        resolved=doc;
    else
        count_separators=length(strfind(doc,'/'));
        if count_separators==0

            match=strcmp(all_modules_info(:,2),doc);
            if~any(match)
                error(message('Slvnv:rmiref:DocCheckDoors:FailResolveModule',doc));
            elseif length(find(match))==1
                resolved=all_modules_info{match,1};
            else
                error(message('Slvnv:rmiref:DocCheckDoors:MoreThanOneMatch',doc));
            end
        else





            if doc(1)~='/'
                doc=['/',doc];
            end
            tokens=regexp(doc,'^/([^/]+).*/([^/]+)$','tokens');
            project=tokens{1,1}(1);
            module=tokens{1,1}(2);

            rough_matches={};
            for i=1:size(all_modules_info,1)
                myPath=[all_modules_info{i,3},'/',all_modules_info{i,2}];
                if strcmp(myPath,doc)
                    resolved=all_modules_info{i,1};
                    return;
                end
                if strcmp(all_modules_info{i,4},project)&&strcmp(all_modules_info{i,2},module)
                    rough_matches{end+1}=all_modules_info{i,1};%#ok<AGROW>
                end
            end
            if isempty(rough_matches)
                error(message('Slvnv:reqmgt:rmiref:FailResolveModule',doc));
            elseif length(rough_matches)==1
                resolved=rough_matches{1};
            else
                error(message('Slvnv:reqmgt:rmiref:MoreThanOneMatch',doc));
            end
        end
    end
end
