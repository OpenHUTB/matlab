function code=compileOperator(self,operatorInfo)
    context=sprintf('context%d',operatorInfo.id);
    code=compileOperator(operatorInfo,self.namespaces.output);

    function code=compileOperator(operatorInfo,var)
        assert(strcmp(operatorInfo.type,'operator'));
        templateInfo=sltest.assessments.internal.AssessmentsEvaluator.operatorTemplates(operatorInfo.operator);
        template=templateInfo.code;


        aliasArgs=templateInfo.text;
        if operatorInfo.parent==-1

            name=strrep(strrep(operatorInfo.assessmentName,'''',''''''),newline,' ');
            aliasArgs=sprintf('%s: %s',name,aliasArgs);
        end
        aliasArgs=sprintf('''%s''',strrep(aliasArgs,'''',''''''));

        argFields=fieldnames(operatorInfo.children);
        code={};

        for k=1:numel(argFields)
            hole=sprintf('{%d}',k-1);
            argField=argFields{k};
            arg=operatorInfo.children.(argField);

            if isempty(arg.operator)&&endsWith(arg.dataType,'clause')
                self.addError('sltest:assessments:EmptyOperatorError',arg.placeHolder);
                argCode='<missing>';
                argText='<missing>';
            else
                switch arg.type
                case 'expression'
                    switch arg.dataType
                    case 'time'
                        argCode=self.compileTime(arg,operatorInfo.placeHolder);
                        argText=sprintf('%s seconds',strtrim(arg.label));
                    case{'boolean','numeric','signal'}
                        argCode=self.makeTempVar(argField);
                        code{end+1}=sprintf('%s = %s;',argCode,self.compileExpression(arg,operatorInfo.placeHolder));%#ok<AGROW>
                        code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternFlag'',''%s'');',argCode,context,argField);%#ok<AGROW>
                        argText=sprintf(''', %s, ''',argCode);
                    otherwise
                        assert(false,'unexpected data type %s',arg.dataType);
                    end
                case 'operator'
                    if~isfield(arg,'children')

                        argTemplate=sltest.assessments.internal.AssessmentsEvaluator.operatorTemplates(arg.operator);
                        argCode=argTemplate.code;
                        argText=sprintf(''', ''%s'', ''',arg.template);
                    else
                        argCode=self.makeTempVar(argField);
                        code{end+1}=compileOperator(arg,argCode);%#ok<AGROW>
                        code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternFlag'',''%s'');',argCode,context,argField);%#ok<AGROW>
                        code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternOperator'',''%s'');',argCode,context,arg.operator);%#ok<AGROW>
                        argText=sprintf(''', %s, ''',argCode);
                    end
                otherwise
                    assert(false,'unexpected type %s',arg.type);
                end
            end
            template=strrep(template,hole,argCode);
            aliasArgs=strrep(aliasArgs,hole,argText);
        end

        aliasArgs=erase(aliasArgs,{''''', ',', '''''});
        code{end+1}=sprintf('%s = sltest.assessments.Alias(%s, %s);',var,template,aliasArgs);
        if operatorInfo.parent==-1&&~isempty(argFields)
            code{end+1}=sprintf('%s.internal.setMetadata(''patternType'',''%s'');',var,argFields{1});
        end
        code=strjoin(code,newline);
    end
end