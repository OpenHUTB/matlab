function[startIndices,endIndices]=styleguide_jmaab_0737(codeStringToSearch,language)
    startIndices=[];endIndices=[];
    if isempty(codeStringToSearch)
        return;
    end
    expressionsArray=[];
    expressionsArrayUnary=[];







    useRegex=true;

    switch(language)
    case 'MATLAB'
        tr=mtree(codeStringToSearch);

        if~tr.isempty&&Advisor.Utils.isValidMtree(tr)
            useRegex=false;

            binaryOps={'PLUS','MINUS','MUL','DIV','LDIV','EXP',...
            'DOT','AND','OR','LT','GT','EQUALS',...
            'DOTMUL','DOTDIV','DOTLDIV','DOTLP',...
            'ANDAND','OROR','LE','GE','EQ','NE'};

            binaryOpsTree=mtfind(tr,'Kind',binaryOps);
            if~binaryOpsTree.isempty&&...
                Advisor.Utils.isValidMtree(binaryOpsTree)
                [violationStart,violationEnd]=findViolationMtree(...
                codeStringToSearch,binaryOpsTree,binaryOpsTree,false);
                startIndices=[startIndices,violationStart];
                endIndices=[endIndices,violationEnd];
            end






            dotexpTree=mtfind(tr,'Kind','DOTEXP');
            if~dotexpTree.isempty&&Advisor.Utils.isValidMtree(dotexpTree)
                operatorsDotexpTree=[];
                if~dotexpTree.isempty
                    operatorsDotexpTree=mtfind(dotexpTree,'Right.Kind',...
                    {'UMINUS','UPLUS','NOT'});
                end
                if~operatorsDotexpTree.isempty&&...
                    Advisor.Utils.isValidMtree(operatorsDotexpTree)
                    [violationStart,violationEnd]=findViolationMtree(...
                    codeStringToSearch,operatorsDotexpTree,...
                    Right(operatorsDotexpTree),false);
                    startIndices=[startIndices,violationStart];
                    endIndices=[endIndices,violationEnd];
                end

                dotexpTree=dotexpTree.select(...
                setdiff(dotexpTree.indices,operatorsDotexpTree.indices));
                [violationStart,violationEnd]=findViolationMtree(...
                codeStringToSearch,dotexpTree,dotexpTree,false);
                startIndices=[startIndices,violationStart];
                endIndices=[endIndices,violationEnd];
            end



            unaryOps={'TRANS','DOTTRANS','NOT','UMINUS','UPLUS','PARENS'};
            unaryOpsTree=mtfind(tr,'Kind',unaryOps);
            if~unaryOpsTree.isempty&&Advisor.Utils.isValidMtree(unaryOpsTree)
                indices=unaryOpsTree.indices;
                for idx=indices
                    t=unaryOpsTree.select(idx);
                    if~t.isempty&&Advisor.Utils.isValidMtree(t)
                        if any(ismember({'UMINUS','UPLUS','NOT'},kind(t)))&&...
                            ~strcmp(kind(Parent(t)),'DOTEXP')
                            [violationStart,violationEnd]=findViolationMtree(...
                            codeStringToSearch,unaryOpsTree,unaryOpsTree,true);
                            startIndices=[startIndices,violationStart];%#ok<AGROW>
                            endIndices=[endIndices,violationEnd];%#ok<AGROW>
                        end
                    end
                end
            end

        else



            expressionsArray={

'(?<=[\w\)\]])(\s*[\^\*\/\+\-><=\|&]|[\^\*\/\+\-><=\|&]\s*)(?=[\w\(\[])'

'(?<!\s)([&\|><]{2}|([<>=~^&\/\|])=|(\.[\*\/\\])|\+-)'
'([&\|><]{2}|([<>=~^&\/\|])=|(\.[\*\/\\])|\+-)(?!\s)'
            };

            expressionsArrayUnary={
'[=,(;]\s*([-~!\+]\s+)'
'^\s*([-~!\+]\s+)'
'[a-zA-Z](\s+[({\[])'
            };
        end

    case 'C'

        expressionsArray={

'(?<=[\w\)\]])(\s*[\^\*\/\+\-><=\|&%]|[\^\*\/\+\-><=\|&%]\s*)(?=[\w\(\[])'



'(?<!\s)([&\|><]{2}|([!<>=\+\-%^&\/\*\|])=|\+-|\.[\*\/])'
'([&\|><]{2}|([!<>=\+\-%^&\/\*\|])=|\+-|\.[\*\/])(?!\s)'


'(?<!\s)(\.\^)|(\.\^)(?![\s\+\-~])'
'(?<!\s)(\.\^\s*[\+\-~])|(\.\^\s*[\+\-~])(?!\s)'
        };

        expressionsArrayUnary={

'[=,(]\s*(&\s+)'
'[=,(]\s*(\*\s+)'
'[=,({]\s*(-\s+)'
'[=,(]\s*(~\s+)'
'[=,(]\s*(!\s+)'
'[a-zA-Z](\s+\[)'
'[a-zA-Z](\s+\+{2})'
'(\+{2}\s+)[a-zA-Z]'
'[a-zA-Z](\s+\-{2})'
'(\-{2}\s+)[a-zA-Z]'
'(\[\s+)'
'(\s+\])'
        };
    end

    if useRegex
        for idx=1:length(expressionsArray)
            expr=expressionsArray{idx};
            [s,e]=regexp(codeStringToSearch,expr);
            startIndices=[startIndices,s];%#ok<AGROW>
            endIndices=[endIndices,e];%#ok<AGROW>
        end

        for idx=1:length(expressionsArrayUnary)
            expr=expressionsArrayUnary{idx};
            t=regexp(codeStringToSearch,expr,'tokenExtents');
            if~isempty(t)
                t=t{1};
                startIndices=[startIndices,t(1)];%#ok<AGROW>
                endIndices=[endIndices,t(2)];%#ok<AGROW>
            end
        end
    end

end

function[violationStart,violationEnd]=findViolationMtree(...
    codeStringToSearch,leftTree,rightTree,isUnary)

    violationStart=[];violationEnd=[];

    if~isempty(codeStringToSearch)&&~leftTree.isempty&&~rightTree.isempty
        startIndices=abs(position(leftTree));
        endIndices=abs(endposition(rightTree));
        if~isempty(startIndices)||~isempty(endIndices)||...
            length(startIndices)~=length(endIndices)
            for ii=1:length(startIndices)
                hasViolation=false;
                if isUnary
                    if isspace(codeStringToSearch(endIndices(ii)+1))
                        hasViolation=true;
                    end
                else
                    if~isspace(codeStringToSearch(startIndices(ii)-1))||...
                        ~isspace(codeStringToSearch(endIndices(ii)+1))
                        hasViolation=true;
                    end
                end
                if hasViolation
                    violationStart=[violationStart,startIndices(ii)];%#ok<AGROW>
                    violationEnd=[violationEnd,endIndices(ii)];%#ok<AGROW>
                end
            end
        end
    end
end