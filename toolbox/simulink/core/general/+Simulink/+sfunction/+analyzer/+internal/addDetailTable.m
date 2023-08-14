function detailTable=addDetailTable(details,category,description,result,compiler,varargin)
    isTestharness=false;
    srcBlock='';
    if(nargin>5)
        isTestharness=true;
        srcBlock=varargin{1};
    end

    import mlreportgen.dom.*;
    if iscell(details{1})
        numOfCols=numel(details{1});
    else
        numOfCols=1;
    end
    detailTable=Table(numOfCols);
    detailTable.StyleName='AdvTableNoBorder';
    detailTable.Width='100%';
    detailTable.TableEntriesVAlign='middle';
    detailTable.TableEntriesHAlign='left';
    if(strcmp(category,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.SOURCE_CODE_CHECK)))
        if isequal(description,'Polyspace Code Prover Check')
            for xx=1:numel(details)-1
                st=TableRow;
                if xx==1
                    for yy=1:numOfCols
                        tex=TableHeaderEntry(details{xx}{yy});
                        append(st,tex);
                    end
                else
                    for yy=1:numOfCols
                        tex=TableEntry(details{xx}{yy});
                        if yy==3
                            tex.Style={Color('green')};
                        elseif yy==4
                            tex.Style={Color('red')};
                        elseif yy==5
                            tex.Style={Color('gray')};
                        elseif yy==6
                            tex.Style={Color('orange')};
                        end
                        append(st,tex);
                    end
                end
                append(detailTable,st);
            end

            if~isequal(details{end},Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NO_SOURCE_OR_COMPILER))
                st=TableRow;
                te=TableEntry();
                te.Style={HAlign('left')};
                te.ColSpan=numel(details{1});
                tss1=['matlab:polyspaceCodeProver(''-results-dir'','''];
                tss2=[tss1,details{end}];
                tss=[tss2,''');'];
                append(te,ExternalLink(tss,details{end}));
                append(st,te);
                append(detailTable,st);
            else
                st=TableRow;
                te=TableEntry(Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NO_SOURCE_OR_COMPILER));
                append(st,te);
                append(detailTable,st);
            end
        else
            for dd=1:numel(details)
                issue=details{dd};
                if strcmp(result,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN))
                    te=TableEntry(issue);
                    st2=TableRow;
                    append(st2,te);
                    append(detailTable,st2);
                else
                    switch compiler
                    case{'gcc','Clang'}
                        tokens=strsplit(issue,':');
                        if~isempty(tokens)&&numel(tokens)>=2
                            file=tokens{1};
                            lineNumber=tokens{2};
                            tss1='matlab:opentoline(''';
                            tss2=[''',',lineNumber,')'];
                            tss=[tss1,file,tss2];
                            para=Paragraph();
                            append(para,ExternalLink(tss,file));
                            append(para,Text(issue(numel(tokens{1})+1:end)));
                            te=TableEntry();
                            append(te,para);
                        else
                            te=TableEntry();
                            append(te,issue);
                        end
                    case 'mingw64'
                        tokens=strsplit(issue,':');
                        if~isempty(tokens)&&numel(tokens)>=3
                            file=[tokens{1},':',tokens{2}];
                            lineNumber=tokens{3};
                            tss1='matlab:opentoline(''';
                            tss2=[''',',lineNumber,')'];
                            tss=[tss1,file,tss2];
                            para=Paragraph();
                            append(para,ExternalLink(tss,file));
                            append(para,Text(issue(numel(file)+1:end)));
                            te=TableEntry();
                            append(te,para);
                        else
                            te=TableEntry();
                            append(te,issue);
                        end
                    case{'MSVC140','MSVC120'}
                        [~,~,c]=regexp(issue,'(\(\d+\))','match','tokens','tokenExtents');
                        if~isempty(c)
                            startindex=c{1}(1);
                            endindex=c{1}(2);
                            file=issue(1:startindex-1);
                            lineNumber=issue(startindex+1:endindex-1);
                            tss1='matlab:opentoline(''';
                            tss2=[''',',lineNumber,')'];
                            tss=[tss1,file,tss2];
                            para=Paragraph();
                            append(para,ExternalLink(tss,file));
                            append(para,Text(issue(numel(file)+1:end)));
                            te=TableEntry();
                            append(te,para);
                        else
                            te=TableEntry();
                            append(te,issue);
                        end
                    otherwise
                        te=TableEntry();
                        append(te,issue);
                    end

                    st2=TableRow;
                    append(st2,te);
                    append(detailTable,st2);
                end
            end
        end
    elseif(strcmp(category,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK)))
        for dd=1:numel(details)
            msld=details{dd};
            te=TableEntry();
            tr=TableRow;
            append(te,HTML(msld.message));
            append(tr,te);
            append(detailTable,tr);
        end
    elseif(strcmp(category,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.ENVIRONMENT_CHECK))...
        ||isequal(category,Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.ROBUSTNESS_CHECK)))
        st=TableRow;
        te=TableEntry(details{1});
        append(st,te);
        append(detailTable,st);

    end

end

