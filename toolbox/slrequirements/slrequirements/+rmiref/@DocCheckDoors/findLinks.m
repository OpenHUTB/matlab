

function total_links=findLinks(this)
    links=[];
    skip={};


    refObjects=rmidoors.getModuleAttribute(this.docname,'slrefobjects');
    for i=1:size(refObjects,1)


        link=rmiref.SLRefDoors(this.modulename);
        link.docname=this.docname;
        link.itemname=refObjects{i,1};


        link.assignRefData(this.sessionId);

        if strcmp(link.cmd,'rmicodenavigate')
            disp(['Skipping MATLAB code liink "',link.details,'"']);
            skip{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedCodeLink'));
        elseif rmiref.SLReference.isDDLink(link)
            disp(['Skipping Data Dictionary link "',link.details,'"']);
            skip{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedDataLink'));
        else
            skip{end+1}='';
        end


        if isempty(links)
            link.idx=1;
            links=link;
        else
            link.idx=links(end).idx+1;
            links(end+1)=link;%#ok<*AGROW>
        end
    end


    refLinks=rmidoors.getModuleAttribute(this.docname,'slreflinks');
    for i=1:size(refLinks,1)


        link=rmiref.SLRefDoors(this.modulename);
        link.isLink=true;
        link.docname=this.docname;
        link.itemname=refLinks{i,1};


        link.assignRefData(this.sessionId,refLinks{i,2:end});

        if strcmp(link.cmd,'rmicodenavigate')
            disp(['Skipping MATLAB code liink "',link.details,'"']);
            skip{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedCodeLink'));
        elseif rmiref.SLReference.isDDLink(link)
            disp(['Skipping Data Dictionary liink "',link.details,'"']);
            skip{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedDataLink'));
        elseif rmiref.SLReference.isMultilink(link)
            disp(['Skipping External link to multiple items "',link.details,'"']);
            skip{end+1}=getString(message('Slvnv:rmiref:Check:writeReport:UnsupportedMultilink'));
        else
            skip{end+1}='';
        end


        if isempty(links)
            link.idx=1;
            links=link;
        else
            link.idx=links(end).idx+1;
            links(end+1)=link;%#ok<*AGROW>
        end
    end

    this.links=links;
    total_links=length(links);
    this.skipped=skip;
end
