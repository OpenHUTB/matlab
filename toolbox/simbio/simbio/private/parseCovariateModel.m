function out=parseCovariateModel(expr)












    ruleRow=1;
    startIndexRow=2;
    endIndexRow=3;

    parser=getParserForCovariateExpressions();

    out=SimBiology.internal.Covariate.ParsedCovariateModel;


    columnNumber=numel(expr)+1;
    for i=1:numel(expr)
        str=expr{i};
        tree=parser.parse(str);
        rulemap=parser.rulemap;




        if isempty(tree)
            error(message('SimBiology:CovariateModel:InvalidExpressionSyntax1',str));
        end


        columns.ValidLHS=tree(ruleRow,:)==rulemap.ValidLHS;
        columns.Formula=tree(ruleRow,:)==rulemap.Formula;
        columns.Transform=tree(ruleRow,:)==rulemap.Transform;
        columns.Intercept=tree(ruleRow,:)==rulemap.Intercept;
        columns.RandomEffect=tree(ruleRow,:)==rulemap.RandomEffect;

        rel=SimBiology.internal.Covariate.ParametersCovariateRelationship;
        rel.Expression=str;


        rel.Name=str(tree(startIndexRow,columns.ValidLHS):tree(endIndexRow,columns.ValidLHS));


        rel.Transform=str(tree(startIndexRow,columns.Transform):tree(endIndexRow,columns.Transform));

        rel.InterceptName=str(tree(startIndexRow,columns.Intercept):tree(endIndexRow,columns.Intercept));
        rel.HasRandomEffect=any(columns.RandomEffect);
        rel.RandomEffectName=str(tree(startIndexRow,columns.RandomEffect):tree(endIndexRow,columns.RandomEffect));
        rel.RowNumber=i;


        CovTermsIndices=find(tree(ruleRow,:)==rulemap.Product|tree(ruleRow,:)==rulemap.PowerTerm);
        CovTerms=SimBiology.internal.Covariate.CovariateTerm.empty;
        for j=1:numel(CovTermsIndices)


            stree=subtree(tree,CovTermsIndices(j));
            covFunColumn=find(stree(ruleRow,:)==rulemap.CovFun);
            slopeNameColumn=stree(ruleRow,:)==rulemap.FixedEffect;
            covariateNameColumn=find(stree(ruleRow,:)==rulemap.CovariateName);



            covariateNameColumn=covariateNameColumn(1);
            covFunColumn=covFunColumn(1);

            CovTerms(j)=SimBiology.internal.Covariate.CovariateTerm;


            if tree(ruleRow,CovTermsIndices(j))==rulemap.PowerTerm
                CovTerms(j).Expression=['log(',str(stree(startIndexRow,covFunColumn):stree(endIndexRow,covFunColumn)),')'];
            else
                CovTerms(j).Expression=strtrim(str(stree(startIndexRow,covFunColumn):stree(endIndexRow,covFunColumn)));
            end
            CovTerms(j).SlopeName=str(stree(startIndexRow,slopeNameColumn):stree(endIndexRow,slopeNameColumn));
            rawCovariateName=str(stree(startIndexRow,covariateNameColumn):stree(endIndexRow,covariateNameColumn));
            CovTerms(j).CovariateName=removeBrackets(rawCovariateName);

            if isvarname(CovTerms(j).CovariateName)
                safeCovariateName=CovTerms(j).CovariateName;
            else
                safeCovariateName=['[',CovTerms(j).CovariateName,']'];
            end
            CovTerms(j).SlopeDescription=[rel.Name,'/',safeCovariateName];
            CovTerms(j).ColumnNumber=columnNumber;
            columnNumber=columnNumber+1;




            for k=1:numel(covariateNameColumn)
                nextOccurrence=str(stree(startIndexRow,covariateNameColumn(k)):stree(endIndexRow,covariateNameColumn(k)));
                nextOccurrence=removeBrackets(nextOccurrence);
                if~strcmp(CovTerms(j).CovariateName,nextOccurrence)
                    error(message('SimBiology:CovariateModel:InvalidExpressionSyntax2',nextOccurrence,CovTerms(j).CovariateName,CovTerms(j).Expression));
                end
            end
        end
        rel.CovariateTerms=CovTerms(:);
        out.ParameterCovariateRelationships(i)=rel;
        validateParsedCovariateModel(out);
    end

end



function validateParsedCovariateModel(parsedCovariateModel)


    A=parsedCovariateModel.FixedEffectNames;
    [B,I]=unique(parsedCovariateModel.FixedEffectNames);

    repeatedFENames=A(setdiff(1:numel(A),I));
    if numel(A)~=numel(B)
        error(message('SimBiology:CovariateModel:InvalidExpressionSyntax3',cell2csv(repeatedFENames)));
    end


    A=parsedCovariateModel.RandomEffectNames;
    [B,I]=unique(parsedCovariateModel.RandomEffectNames);
    repeatedRENames=A(setdiff(1:numel(A),I));
    if numel(A)~=numel(B)
        error(message('SimBiology:CovariateModel:InvalidExpressionSyntax4',cell2csv(repeatedRENames)));
    end


    A=parsedCovariateModel.ParameterNames;
    [B,I,~]=unique(parsedCovariateModel.ParameterNames);
    repeatedPNames=A(setdiff(1:numel(A),I));
    if numel(A)~=numel(B)
        error(message('SimBiology:CovariateModel:InvalidExpressionSyntax5',cell2csv(repeatedPNames)));
    end


    for i=1:numel(parsedCovariateModel.ParameterCovariateRelationships)
        A=parsedCovariateModel.ParameterCovariateRelationships(i).CovariateNames;
        [B,I,~]=unique(A);
        repeatedCNames=A(setdiff(1:numel(A),I));
        if numel(A)~=numel(B)
            error(message('SimBiology:CovariateModel:InvalidExpressionSyntax6',cell2csv(repeatedCNames)));
        end
    end
end

function out=getParserForCovariateExpressions()
    rules={
'Formula         = ValidLHS s "=" s Transform s "(" s Expr  s ")" $ / ValidLHS s "="  s Expr $'
'+ Transform     = "exp" / "probitinv" / "logitinv"'
'Expr            = Sum (s "+" s RandomEffect)?'
'Sum             = Intercept (s "+" s Product)*'
'+ Intercept     = FixedEffect'
'Product         = FixedEffect s "*" s CovFun'
'+ ExpTerm       = "exp" s "(" s Product s ")" s'
'+ PowerTerm     = CovFun s "^" s FixedEffect s'
'+ FixedEffect   = "theta" [A-Za-z0-9_]+'
'+ ExpedRE       = "exp" s "(" s RandomEffect s ")"'
'+ RandomEffect  = "eta" [A-Za-z0-9_]+'
'+ CovFun        =  "log" s CovFunNum s / "log" s "(" s CovFunNum s ("/" s CovFunDenom)? s ")" / CovFunNum s ("/" s CovFunDenom)? / "(" s CovFun s")"'
'-CovFunNum      = "(" CovariateName s "-" s CenterByFun s "(" s CovariateName s ")" s ")" s  /  "(" s CovariateName s "-" s Double s ")" / "(" s CovFunNum s ")" / CovariateName'
'-CovFunDenom    = ScaleByFun s "(" s CovariateName s ")" s / Double / "(" s CovFunDenom s ")"'
'ScaleByFun      = "max" / "mean" / "median" / "std"'
'CenterByFun     = "mean" / "median"'
'+ CovariateName = Name / BracketedName'
'Name            = [A-Za-z_] [A-Za-z0-9_]*'
'-Integer        = [0-9]+'
'+ ValidLHS      = ValidName ( "." ValidName)?'
'-ValidName      = Name / BracketedName'
'-BracketedName  = "[" [^#x005B#x005D]+ "]"'
'-s              = [ #x9]*'
'-Double          = Integer ("." [0-9]+)?'
    };
    out=matlab.internal.pegparser.PEG(rules);
end

function out=cell2csv(covNames)
    out=cell(numel(covNames,1));
    for i=1:numel(covNames)
        if i<numel(covNames)
            out{i}=[covNames{i},','];
        else
            out{i}=[covNames{i}];
        end
    end
    out=[out{:}];
end


function t=subtree(tree,columnNumber)

    t=tree(:,columnNumber:columnNumber+tree(5,columnNumber)-1);
end

function name=removeBrackets(name)
    if numel(name)>1&&name(1)=='['&&name(end)==']'
        name=name(2:end-1);
    end
end
