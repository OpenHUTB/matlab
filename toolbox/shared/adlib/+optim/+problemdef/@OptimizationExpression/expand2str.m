function[exprStr,isNZ,hasHTML]=expand2str(expr,showDocLink,varInfo)


























    if isempty(expr)
        exprStr=string(getString(message('shared_adlib:OptimizationExpression:NoExpressionDefined')));
        isNZ=[];
        hasHTML=false;
        return;
    end

    if nargin<2
        showDocLink=true;
    end

    if nargin<3

        varInfo=optim.problemdef.OptimizationVariable.getVariableInfo(getVariables(expr));
    end

    if getExprType(expr)<=optim.internal.problemdef.ImplType.Linear

        [A,b]=extractLinearCoefficients(expr,varInfo.NumVars);
        H=[];
        b=b(:);
    else

        [H,A,b]=extractQuadraticCoefficients(expr,varInfo.NumVars);
    end






    [HStr,AStr,bStr,bNeg]=optim.internal.problemdef.display.getDisplayStr(H,A,b,varInfo);


    exprStr=strings(numel(expr),1);


    Hdefined=(strlength(HStr)>0);

    Adefined=(strlength(AStr)>0);

    bdefined=(strlength(bStr)>0);

    infOrNaN=any(~isfinite(A))'|~isfinite(b);

    isNZ=infOrNaN|Hdefined|Adefined|bdefined;



    exprStr(Hdefined)=HStr(Hdefined);



    HandA=Hdefined&Adefined;
    exprStr(HandA)=exprStr(HandA)+" "+AStr(HandA);

    AnotH=~Hdefined&Adefined;
    exprStr(AnotH)=AStr(AnotH);



    HorA_andb=(Hdefined|Adefined)&bdefined;

    subtractB=HorA_andb&bNeg;
    exprStr(subtractB)=exprStr(subtractB)+" - "+bStr(subtractB);

    addB=HorA_andb&~bNeg;
    exprStr(addB)=exprStr(addB)+" + "+bStr(addB);

    onlyB=~Hdefined&~Adefined&bdefined;

    subtractB=onlyB&bNeg;
    exprStr(subtractB)="-"+bStr(subtractB);

    addB=onlyB&~bNeg;
    exprStr(addB)=bStr(addB);



    leadingPlus=startsWith(exprStr,"+ ");
    exprStr(leadingPlus)=extractAfter(exprStr(leadingPlus),2);

    leadingMinus=startsWith(exprStr,"- ");
    exprStr(leadingMinus)="-"+extractAfter(exprStr(leadingMinus),2);


    exprStr(infOrNaN)=InfOrNaNMessage(showDocLink);

    exprStr(~isNZ)=getString(message('shared_adlib:OptimizationExpression:AllZeroExpr'));



    hasHTML=infOrNaN;

    function str=InfOrNaNMessage(showDocLink)

        if showDocLink

            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            'doc','optim_ug_naninfexpr','normal',true);
        else
            startTag='';
            endTag='';
        end


        str=getString(message('shared_adlib:OptimizationExpression:InfOrNaNExpr',startTag,endTag));
