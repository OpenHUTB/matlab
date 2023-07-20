function[expression,systemConstants]=extractSystemConstantExpressionFromM3I(xmlexpression)















    systemConstants={};

    xmlexpression=['<dummytag>',xmlexpression,'</dummytag>'];
    parser=matlab.io.xml.dom.Parser();
    xmlDocument=parser.parseString(xmlexpression);

    expression='';
    for ii=0:xmlDocument.getDocumentElement.getLength-1
        ele=xmlDocument.getDocumentElement.item(ii);
        if strcmp(ele.getNodeName,'#text')
            textcontent=char(ele.getTextContent);


            expression=[expression,' ',textcontent];%#ok<AGROW>
        elseif strcmp(ele.getNodeName,'SYSC-REF')
            syscfull=char(ele.getTextContent);
            parts=strsplit(syscfull,'/');
            sysc=parts{end};
            systemConstants{end+1}=sysc;%#ok<AGROW>
            expression=[expression,' ',sysc];%#ok<AGROW>
        end
    end

    expression(isspace(expression))=' ';
    expression=regexprep(expression,' +',' ');
    expression=strtrim(expression);
end
