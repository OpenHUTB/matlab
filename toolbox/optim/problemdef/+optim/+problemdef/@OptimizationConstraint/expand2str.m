function[constrStr,isNZ,hasHTML]=expand2str(con,showDocLink)




























    if isempty(con)||isempty(con.Relation)
        NoConstraintDefinedId="optim_problemdef:"+con.className+":NoConstraintDefined";
        constrStr=string(getString(message(NoConstraintDefinedId)));
        isNZ=[];
        hasHTML=false;
        return;
    end

    if nargin<2
        showDocLink=true;
    end


    varInfo=optim.problemdef.OptimizationVariable.getVariableInfo(getVariables(con));


    [constrStr,isNZ,hasHTML]=displayLinearConstraint(con,showDocLink,varInfo);

    function[constrStr,isNZ,hasHTML]=displayLinearConstraint(con,showDocLink,varInfo)


        [A,b,idxNumericLhs]=extractDisplayCoefficients(con,varInfo.NumVars);





        showZero=true;
        [~,AStr,bStr,bNeg]=optim.internal.problemdef.display.getDisplayStr([],A,b,varInfo,showZero);



        leadingPlus=startsWith(AStr,"+ ");
        AStr(leadingPlus)=extractAfter(AStr(leadingPlus),2);

        leadingMinus=startsWith(AStr,"- ");
        AStr(leadingMinus)="-"+extractAfter(AStr(leadingMinus),2);

        bStr(bNeg)="-"+bStr(bNeg);


        constrStr=strings(numel(con),1);


        relation=con.Relation;



        bdefined=(strlength(bStr)>0);

        infOrNaN=any(~isfinite(A))'|~isfinite(b);

        isNZ=infOrNaN|bdefined;



        displayCoeff=~infOrNaN&bdefined;
        idxExprLhs=displayCoeff&~idxNumericLhs;
        idxExprRhs=displayCoeff&idxNumericLhs;
        constrStr(idxExprLhs)=AStr(idxExprLhs)+" "+relation+" "+bStr(idxExprLhs);
        constrStr(idxExprRhs)=bStr(idxExprRhs)+" "+relation+" "+AStr(idxExprRhs);


        constrStr(infOrNaN)=InfOrNaNMessage(showDocLink,con.className);


        AllZeroConstraintId="optim_problemdef:"+con.className+":AllZeroConstraint";
        constrStr(~isNZ)=getString(message(AllZeroConstraintId));



        hasHTML=infOrNaN;

        function str=InfOrNaNMessage(showDocLink,className)

            if showDocLink

                [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
                'doc','optim_ug_naninfexpr','normal',true);
            else
                startTag='';
                endTag='';
            end


            InfOrNaNConstrId="optim_problemdef:"+className+":InfOrNaNConstr";
            str=getString(message(InfOrNaNConstrId,startTag,endTag));

