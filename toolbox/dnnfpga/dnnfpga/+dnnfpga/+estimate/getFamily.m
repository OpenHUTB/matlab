function[found,familyName]=getFamily(tool,device)








    import matlab.io.xml.dom.*

    xmlFile=(fullfile(matlabroot,...
    'toolbox','hdlcoder','hdlcommon','+downstreamtools',tool,'device_list.xml'));
    xDoc=parseFile(Parser,xmlFile);


    allListitems=xDoc.getElementsByTagName('Device');
    familyName='';
    found=0;
    for i=0:allListitems.getLength-1
        p=allListitems.item(i);
        myName=p.getAttribute("name");
        if(strcmpi(myName,device))
            family=p.getParentNode();
            familyName=family.getAttribute('id');
            found=1;
            break;
        end
    end
end
