function[compiledFun,compiledGrad,extraParams]=writeQPConstrGradientBlock(objects,...
    numVars,numNonlinObjects,idxNonlinObjects,outName,gradName,...
    inputVariables,extraParams,extraParamsName,...
    HessName,HessTimesX,FName,RHSName,HessTimeXcell)










    if(numNonlinObjects==0)
        compiledFun=outName+" = [];"+newline;
        compiledGrad=gradName+" = [];"+newline;
    elseif numNonlinObjects==1






        extraParamsIdx=numel(extraParams)+1;




        VarAll=inputVariables+"(:)";

        [H,A,b]=extractQuadraticCoefficients(objects{idxNonlinObjects(1)},numVars);


        if~issymmetric(H)
            H=(H+H.');
        else
            H=2.*H;
        end


        extraParams=[extraParams,{H,A(:),b(:)}];


        compiledFun=...
        HessName+" = "+extraParamsName+"{"+extraParamsIdx+"};"+newline+...
        FName+" = "+extraParamsName+"{"+(extraParamsIdx+1)+"};"+newline+...
        RHSName+" = "+extraParamsName+"{"+(extraParamsIdx+2)+"};"+newline+...
        HessTimesX+" = "+HessName+"*"+VarAll+";"+newline+...
        outName+sprintf(" = 0.5*dot(%s, %s) + dot(%s, %s) + %s;",VarAll,HessTimesX,FName,VarAll,RHSName)+newline+newline;

        compiledGrad=gradName+" = "+HessTimesX+" + "+FName+";"+newline;
    else





        VarAll=inputVariables+"(:)";



        compiledFun=outName+" = zeros("+numNonlinObjects+", "+1+");"+newline;
        compiledFun=compiledFun+HessTimeXcell+" = cell("+numNonlinObjects+", "+1+");"+newline+newline;
        compiledGrad=gradName+" = zeros(numel("+VarAll+"), "+numNonlinObjects+");"+newline;



        extraParamsIdxInit=numel(extraParams)+1;
        extraParamsIdx=extraParamsIdxInit;



        extraParams=[extraParams,cell(1,3*numNonlinObjects)];



        for idx=1:numel(idxNonlinObjects)



            [Hall,Aall,ball]=extractQuadraticCoefficients(objects{idxNonlinObjects(idx)},numVars);





            numQuadraticConstr=size(Hall,1)/size(Hall,2);



            for qConstrIdx=1:numQuadraticConstr

                rowStart=1+numVars*(qConstrIdx-1);
                rowEnd=numVars*qConstrIdx;
                H=Hall(rowStart:rowEnd,1:numVars);
                A=Aall(:,qConstrIdx);
                b=ball(qConstrIdx);

                if~issymmetric(H)
                    H=(H+H.');
                else
                    H=2.*H;
                end

                extraParams{extraParamsIdx}=H;
                extraParams{extraParamsIdx+1}=A;
                extraParams{extraParamsIdx+2}=b;

                extraParamsIdx=extraParamsIdx+3;
            end
        end


        helpFourSpaces="    ";


        HessTimesX=HessName+"mvec";


        outNameSubAssign=outName+"(i+1)";
        gradNameSubAssign=gradName+"(:,i+1)";


        compiledFun=compiledFun+...
        "for i = 0:"+(numNonlinObjects-1)+newline+...
        helpFourSpaces+HessName+" = "+extraParamsName+"{3*i+"+extraParamsIdxInit+"};"+newline+...
        helpFourSpaces+FName+" = "+extraParamsName+"{3*i+"+(extraParamsIdxInit+1)+"}(:);"+newline+...
        helpFourSpaces+RHSName+" = "+extraParamsName+"{3*i+"+(extraParamsIdxInit+2)+"}(:);"+newline+...
        helpFourSpaces+HessTimesX+" = "+HessName+" * "+VarAll+";"+newline+...
        helpFourSpaces+HessTimeXcell+"{i+1} = "+HessTimesX+";"+newline+...
        helpFourSpaces+outNameSubAssign+...
        sprintf(" = 0.5*dot(%s, %s) + dot(%s, %s) + %s;",VarAll,HessTimesX,FName,VarAll,RHSName)+newline+...
        "end"+newline+newline;


        compiledGrad=compiledGrad+...
        "for i = 0:"+(numNonlinObjects-1)+newline+...
        helpFourSpaces+FName+" = "+extraParamsName+"{3*i+"+(extraParamsIdxInit+1)+"}(:);"+newline+...
        helpFourSpaces+HessTimesX+" = "+HessTimeXcell+"{i+1};"+newline+...
        helpFourSpaces+gradNameSubAssign+" = "+HessTimesX+" + "+FName+";"+newline+...
        "end"+newline+newline;
    end

