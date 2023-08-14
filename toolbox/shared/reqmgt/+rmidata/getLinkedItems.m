function[docs,items,reqsys]=getLinkedItems(linkSource,doFilter)





    if nargin<2
        doFilter=false;
    end

    if nargout==1

        docs=slreq.getLinkedItems(linkSource,doFilter);
    else

        [docs,items,reqsys]=slreq.getLinkedItems(linkSource,doFilter);
    end


    if nargout>2&&~isempty(docs)&&rmisl.isSidString(linkSource)
        isSlLink=strcmp(reqsys,'linktype_rmi_simulink');
        if any(isSlLink)
            modelName=strtok(linkSource,':');
            for i=find(isSlLink)
                if strncmp(docs{i},'$ModelName$',length('$ModelName$'))
                    docs{i}=strrep(docs{i},'$ModelName$',modelName);
                end
            end
        end
    end

end

