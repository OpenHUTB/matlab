function linkElement=makeLink(d,linkID,linkText,linkType)







    if isempty(linkID)
        if((nargin<3)||isempty(linkText))
            linkElement='';
        else
            linkElement=d.createTextNode(linkText);
        end
        return;
    end

    if(nargin<3)
        linkText='';
    end

    if(nargin<4)
        if(nargin>2)
            linkType='link';
        else
            linkType='anchor';
        end
    else
        linkType=lower(linkType);
    end

    fileref='';

    adRG=rptgen.appdata_rg;

    switch linkType
    case{'link','xref'}
        attType='linkend';
        linkID=tokenizeLinkID(linkID);
    case 'anchor'
        attType='id';

        linkID=tokenizeLinkID(linkID);
        if(d.AnchorTable.isKey(linkID))


            rptgen.displayMessage(getString(message('rptgen:rx_document:dupAnchorMsg',linkID)),5);
            linkID='';
        else
            d.AnchorTable(linkID)=true;
        end
    case 'matlab'
        attType='url';
        linkType='ulink';
    case 'ulink'
        attType='url';

        if isempty(findstr(linkID,':/'))&&isempty(findstr(linkID,'./'))&&~strncmp(linkID,'matlab:',7)
            if(exist(linkID,'file')>0)
                linkIdFound=which(linkID);
                if~isempty(linkIdFound)
                    linkID=linkIdFound;
                end

                [linkPath,linkFile,linkExt]=fileparts(linkID);
                reportDirectory=fileparts(adRG.RootComponent.Output.SrcFileName);
                if isempty(reportDirectory)
                    reportDirectory=pwd;
                end
                if strcmpi(linkPath,reportDirectory)
                    linkID=['./',linkFile,linkExt];
                else
                    linkID=rptgen.file2urn(fullfile(linkPath,[linkFile,linkExt]));
                    fileref=strrep(fullfile(linkPath,[linkFile,linkExt]),'\','/');
                end

                if isempty(linkText)
                    linkText=linkFile;
                end

            else
                linkID=['http://',linkID];
            end
        end
    otherwise
        error(message('rptgen:rx_document:unsupportedLinkType'));
    end

    if isempty(linkID)
        linkID='about:blank';
    end

    if contains(linkID,':')

        schemeSpecificPart=extractAfter(linkID,':');
        if isempty(strrep(schemeSpecificPart,'/',''))
            linkID='about:blank';
        end
    end


    linkElement=d.createElement(linkType);
    linkElement.setAttribute(attType,linkID);

    if~isempty(fileref)
        linkElement.setAttribute('fileref',fileref);
    end

    if~isempty(linkText)
        linkText=d.createTextNode(linkText);

        if strcmp(linkType,'anchor')
            linkElement=d.createDocumentFragment(linkElement,linkText);
        else
            linkElement.appendChild(linkText);
        end
    end


    function linkID=tokenizeLinkID(linkID)


        spaceIdx=find(isspace(linkID));
        if~isempty(spaceIdx)
            linkID(spaceIdx)='_';
        end
        linkID=strrep(linkID,' ','_');


