function res=getAssessmentsDefinitionHelper(assessmentsJSON,assessmentID)



    if nargin<2
        assessmentID=[];
    end
    res={};
    if(assessmentsJSON=="")
        return;
    end

    data=jsondecode(assessmentsJSON);

    symbolsInfo=sltest.assessments.internal.AssessmentsEvaluator.tableToTree(data.MappingInfo,'label');

    res.symbolsDefinition=arrayfun(@(x)symbolFormatter(x),symbolsInfo,'UniformOutput',false);


    if isfield(data,'MappingInfo2')&&~isempty(data.MappingInfo2)
        symbolsInfo2=sltest.assessments.internal.AssessmentsEvaluator.tableToTree(data.MappingInfo2,'label');
        res.SymbolInfo2=arrayfun(@(x)symbolFormatter(x),symbolsInfo2,'UniformOutput',false);
    end

    symbolList=[];
    unresolved=[];
    if(~isempty(symbolsInfo))

        symbolList=arrayfun(@(x)x.value,symbolsInfo,'UniformOutput',false);

        unresolved=symbolList(cellfun(@(x)isequal(x,'Unresolved'),{symbolsInfo.scope}));
    end

    for idx=1:numel(data.AssessmentsInfo)
        if strcmp(data.AssessmentsInfo{idx}.type,'expression')
            if(data.AssessmentsInfo{idx}.label~="")
                s=sltest.assessments.internal.parseExpression({data.AssessmentsInfo{idx}.label},{data.AssessmentsInfo{idx}.dataType},symbolList,unresolved);
                assert(numel(s)==1);
                s=s{1};

                f=fieldnames(s);
                for k=1:numel(f)
                    data.AssessmentsInfo{idx}.(f{k})=s.(f{k});
                end
            end
        end
    end

    assessmentsInfo=sltest.assessments.internal.AssessmentsEvaluator.tableToTree(data.AssessmentsInfo,'placeHolder');

    if isempty(assessmentID)
        res.assessmentsDefinition=arrayfun(@(x)assessmentFormatter(x),assessmentsInfo);
    else
        x=assessmentsInfo([assessmentsInfo.id]==assessmentID);
        if~isempty(x)
            res.assessmentsDefinition=assessmentFormatter(x);
        end
    end
end

function res=symbolFormatter(symbolInfo)
    res=struct("Name",symbolInfo.value,"Scope","","Value",[]);
    res.Scope=string(symbolInfo.scope);
    res.ID=symbolInfo.id;
    switch res.Scope
    case "Expression"
        res.Value.Expression=string(symbolInfo.children.Expression.value);
    case "Unresolved"
    case "Signal"
        res.Value.Name=symbolInfo.children.Name.value;
        res.Value.Path=symbolInfo.children.Path.value;
        res.Value.PortIndex=symbolInfo.children.PortIndex.value;
        res.Value.FieldElement=symbolInfo.children.FieldElement.value;
    case "Parameter"
        res.Value.Name=symbolInfo.children.Name.value;
        res.Value.Path=symbolInfo.children.Path.value;
        res.Value.FieldElement=symbolInfo.children.FieldElement.value;
    case "Variable"
        res.Value.Name=symbolInfo.children.Name.value;
        res.Value.Workspace=symbolInfo.children.Workspace.value;
        res.Value.Path=symbolInfo.children.Path.value;
        res.Value.FieldElement=symbolInfo.children.FieldElement.value;
    case "Enumeration"

        assert(false);
    case "Constant"

        assert(false);
    case "UseMapping1"
        res.Value.Mapping=symbolInfo.children.Mapping.value;
    otherwise
        assert(false)
    end
end

function res=assessmentFormatter(assessmentInfo)
    res=struct("assessmentName",assessmentInfo.assessmentName,"formattedLabel","","hasError","","enabled",assessmentInfo.enabled,"requirements","");


    res.id=assessmentInfo.id;
    if isfield(assessmentInfo,"requirementsString")
        res.requirements=assessmentInfo.requirementsString;
    end
    if assessmentInfo.type=="operator"
        template=renderTemplate(assessmentInfo);
        res.formattedLabel=template.template;
        res.textLabel=getTextFromHtml(res.formattedLabel);
        res.hasError=template.hasError;
    else

        assert(false);
    end
end

function res=getTextFromHtml(str)
    txt=regexprep(str,'<.*?>','');
    res=txt.replace("&amp;","&").replace("&lt;","<").replace("&gt;",">").replace("&#8209;","-");
end

function res=escapeHtml(str)
    str=string(str);
    res=str.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
end

function res=getIntervalLabel(str)
    intervalBounds=regexp(str,'\d+','match');
    res=intervalBounds(1)+" to "+intervalBounds(2)+" seconds";
end

function res=getTimeLabel(str)
    res=str+" seconds";
end

function template=renderTemplate(item)

    template=struct("template","","hasError",false);
    if item.type~="operator"
        if item.label==""

            placeHolderText=replace(string(item.placeHolder),"-","&#8209;");
            template.template="<span class=""assessment-empty-placeholder"">&lt;"+placeHolderText+"&gt;</span>";
        else
            if item.type=="expression"
                if(strlength(item.FormattedExpr)>0)
                    template.template=item.FormattedExpr;
                else
                    template.template=escapeHtml(item.label);
                end
                if item.dataType=="interval"
                    template.template=getIntervalLabel(template.template);
                else
                    if item.dataType=="time"
                        template.template=getTimeLabel(template.template);
                    end
                end
            else
                template.template=string(item.label);
            end
        end
        template.hasError=template.hasError||(isfield(item,"HasError")&&item.HasError);
        if(~template.hasError)
            if isempty(strfind(template.template,"assessment-empty-placeholder"))||isempty(strfind(template.template,"comment-style"))
                template.template="<span class=""assessment-expression-link-text"">"+template.template+"</span>";
            end
        end
    else
        template.template=string(item.template);
        if isfield(item,"children")
            children=fields(item.children);
            for idx=1:numel(children)
                childtemplate=renderTemplate(item.children.(children{idx}));
                template.hasError=template.hasError||childtemplate.hasError;
                template.template=template.template.replace("{"+(idx-1)+"}",childtemplate.template);
            end
        end

    end
end