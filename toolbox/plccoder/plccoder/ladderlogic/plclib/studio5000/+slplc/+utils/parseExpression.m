function[varNames,mExpression,isDSMExp,elementList]=parseExpression(ldExpression,varargin)




    p=inputParser;
    p.addRequired('DataTagExp');
    p.addParameter('ArrayIndexIncrement',false);
    p.addParameter('ParseElementList',false);
    p.addParameter('IsLHSExpression',true);
    p.addParameter('WithFunctionParsing',false);

    p.parse(ldExpression,varargin{:});
    inputsArgs=p.Results;

    ldExpression=formulize(inputsArgs.DataTagExp);

    elementList={};
    if isvarname(ldExpression)

        varNames={ldExpression};
        mExpression=ldExpression;
        isDSMExp=true;
        return
    elseif~isnan(str2double(ldExpression))

        error('plccoder:plccore:InvalidOperandTag',gcb,ldExpression);
    end

    if~inputsArgs.WithFunctionParsing
        if contains(ldExpression,'(')||contains(ldExpression,')')
            error('slplc:invalidIndexing',...
            'The expression %s used "( )" for array element indexing that is not allowed for ladder logic operand expression.',...
            ldExpression);
        end
    end

    isLHSExp=false;
    if~contains(ldExpression,'(')
        RHSCharExp='[^.\w\d\[\],{}]';
        isLHSExp=isempty(regexp(ldExpression,RHSCharExp,'once'));
    end

    if inputsArgs.IsLHSExpression
        if~isLHSExp
            error('slplc:invalidLHSExpression','Invalid Left Hand Side expression %s',ldExpression);
        end
    end


    ldExpression=strrep(ldExpression,'[','{');
    ldExpression=strrep(ldExpression,']','}');
    ldExpression=strrep(ldExpression,'**','^');
    ldExpression=strrep(ldExpression,'&#60','<');
    ldExpression=strrep(ldExpression,'&#62','>');
    ldExpression=strrep(ldExpression,'<>','~=');


    equExpr=regexp(ldExpression,'[=<>~]+','match');
    if~isempty(equExpr)
        for i=1:numel(equExpr)
            if~contains(equExpr{i},{'<','>','~'})
                ldExpression=strrep(ldExpression,equExpr{i},'==');
            end
        end
    end


    bitExp='\.\d+';
    noBitAccess=isempty(regexp(ldExpression,bitExp,'once'));

    parsedBitExp='\.xxx__BIT\d+';
    noParsedBitPattern=isempty(regexp(ldExpression,parsedBitExp,'once'));

    if~noBitAccess
        ldExpression=regexprep(ldExpression,'[a-zA-Z][a-zA-Z0-9_.]+|(?:\}){1}\.(\d+)','${plccore.util.replaceBitIndexWithBITTxt($0)}');
    end

    out=plccore.util.mtreeGenerateMLOperand(ldExpression,inputsArgs.ArrayIndexIncrement,inputsArgs.ParseElementList);
    isDSMExp=((numel(out.globalsList)==1)&&noBitAccess&&noParsedBitPattern&&isLHSExp);

    varNames=unique(out.globalsList,'stable');
    mExpression=formulize(out.MFBScript);
    elementList=out.elementList;
end

function expStr=formulize(inputStr)



    braceExp=regexp(inputStr,'[\[\{](.*?)[\]\}]','match');
    if~isempty(braceExp)
        for i=1:numel(braceExp)

            newExp=regexprep(braceExp{i},'\s+','');
            inputStr=strrep(inputStr,braceExp{i},newExp);
        end
    end
    expStr=inputStr;
end


