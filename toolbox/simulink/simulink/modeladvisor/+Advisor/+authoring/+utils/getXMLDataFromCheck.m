function output=getXMLDataFromCheck(checkid,xmlFileName)




    if~isempty(xmlFileName)
        output=convertBlockConstraintCheckXMLData(checkid,xmlFileName);
    else
        output=convertBlockConstraintCheckXMLData_newStyle(checkid);
    end
end

function output=convertBlockConstraintCheckXMLData(checkid,xmlFileName)
    output='';
    xmlContents=fileread(xmlFileName);
    startPos=strfind(xmlContents,'<checkdata>')+length('<checkdata>');
    endPos=strfind(xmlContents,'</checkdata>')-1;
    contents=strtrim(xmlContents(startPos:endPos));
    if(startPos>0)&&(endPos>startPos)
        output=[output,'<Check>',newline];
        output=[output,'  <ID checkType="BlockConstraintCheck">',checkid,'</ID>',newline];
        output=[output,'  <Selected>true</Selected>',newline];
        output=[output,'  <Author>External</Author>',newline];
        output=[output,'  <messages>',newline];
        output=[output,'    <Title type="string">',getTitleForCheckID(checkid),'</Title>',newline];
        output=[output,'  </messages>',newline];
        output=[output,'  <InputParameters>',newline];
        output=[output,'    <InputParameter Name="Data File" Type="BlockConstraint">',newline];
        output=[output,'      <BlockConstraints>',newline];
        output=[output,'      ',contents,newline];
        output=[output,'      </BlockConstraints>',newline];
        output=[output,'    </InputParameter>',newline];
        output=[output,'  </InputParameters>',newline];
        output=[output,'</Check>',newline];
    end
end

function output=convertBlockConstraintCheckXMLData_newStyle(checkid)
    output='';

    output=[output,'<Check>',newline];
    output=[output,'  <ID checkType="BlockConstraintCheck">',checkid,'</ID>',newline];
    output=[output,'  <Selected>true</Selected>',newline];
    output=[output,'  <Author>External</Author>',newline];
    output=[output,'  <messages>',newline];
    output=[output,'    <Title type="string">',getTitleForCheckID(checkid),'</Title>',newline];
    output=[output,'  </messages>',newline];
    output=[output,'  <InputParameters>',newline];
    output=[output,'    <InputParameter Name="Data File" Type="BlockConstraint">',newline];
    output=[output,'      <BlockConstraints>',newline];
    output=[output,'      ',getConstraintContentForCheckID(checkid),newline];
    output=[output,'      </BlockConstraints>',newline];
    output=[output,'    </InputParameter>',newline];
    output=[output,'  </InputParameters>',newline];
    output=[output,'</Check>',newline];

end

function title=getTitleForCheckID(checkID)

    checkObj=getCheckObjFromAdvisorManager(checkID);

    if isempty(checkObj)
        title=checkID;
        return;
    end

    title=checkObj.Title;

    if isempty(title)
        title=checkID;
    end
end

function content=getConstraintContentForCheckID(checkID)

    checkObj=getCheckObjFromAdvisorManager(checkID);
    content="";

    if isempty(checkObj)
        msld=MSLDiagnostic('edittimecheck:engine:MissingConstraintInfo',checkID);
        msld.reportAsError;
        return;
    end
    constraintString=checkObj.getConstraintString;
    startPos=strfind(constraintString,'<checkdata>')+length('<checkdata>');
    endPos=strfind(constraintString,'</checkdata>')-1;
    content=strtrim(constraintString(startPos:endPos));
end

function checkObj=getCheckObjFromAdvisorManager(checkID)
    checkObj=[];
    am=Advisor.Manager.getInstance;
    if~isempty(am.slCustomizationDataStructure)&&isa(am.slCustomizationDataStructure.CheckIDMap,'containers.Map')
        if(am.slCustomizationDataStructure.CheckIDMap.isKey(checkID))
            checkObj=am.slCustomizationDataStructure.checkCellArray{am.slCustomizationDataStructure.CheckIDMap(checkID)};
        end
    end
end











































