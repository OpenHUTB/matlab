function updateCopyright(bdname,productKey,productName,startYear)









    productXml=fullfile(matlabroot,'config','products',[productKey,'.xml']);
    parser=matlab.io.xml.dom.Parser;
    xDoc=parser.parseFile(productXml);
    verNode=xDoc.getElementsByTagName('productVersion').item(0);
    productVersion=char(verNode.getChildNodes.item(0).getData);


    currentYear=datetime('now','format','yyyy');
    annotation=find_system(bdname,'SearchDepth',1,'FindAll','on','type','annotation');
    copyright=sprintf('Copyright %s The MathWorks, Inc.',startYear);
    if str2double(startYear)>currentYear.Year
        error('Start year cannot be greater than current year');
    end
    if currentYear.Year~=str2double(startYear)
        copyright=sprintf('Copyright %s-%s The MathWorks, Inc.',startYear,currentYear);
    end

    set_param(bdname,'Lock','off');
    switch numel(annotation)
    case 1
        set_param(annotation,'Name',...
        sprintf('%s %s\n%s',productName,productVersion,copyright));
        set_param(annotation,'HorizontalAlignment','center');
    case 2

        if contains(get_param(annotation(1),'Name'),'Copyright')
            cIdx=1;
            tIdx=2;
        else
            cIdx=2;
            tIdx=1;
        end

        set_param(annotation(cIdx),'Name',sprintf('%s',copyright));
        set_param(annotation(cIdx),'FontSize',10);
        set_param(annotation(cIdx),'HorizontalAlignment','center');

        set_param(annotation(tIdx),'FontSize',14);
        set_param(annotation(tIdx),'HorizontalAlignment','center');
    otherwise
        error('Invalid number of annotations in the root system.');
    end
    set_param(bdname,'Lock','on');
end