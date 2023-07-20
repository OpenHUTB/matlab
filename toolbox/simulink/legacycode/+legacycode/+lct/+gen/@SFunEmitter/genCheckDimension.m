




function stmts=genCheckDimension(dataSpec,checkForDynSize,dimExpr,dimVar,dimIdx)


    persistent dynDimExpr
    if isempty(dynDimExpr)
        dynDimExpr=[...
        'ssGetInputPortDimensions|ssGetInputPortNumDimensions|ssGetInputPortWidth|',...
'mxGetScalar|mxGetDimensions|mxGetNumberOfElements'...
        ];
    end


    persistent widthDescMsg rowColDescMsg dimDescMsgFcn dynSizeCheckFcn checkStmtFcn
    if isempty(widthDescMsg)

        widthDescMsg='the current width is < 1';
        rowColDescMsg={'the current number of rows is < 1';'the current number of columns is < 1'};
        dimDescMsgFcn=@(dim)sprintf('the current dimension %d is < 1',dim);


        dynSizeCheckFcn=@(dimVal)sprintf('%s!=DYNAMICALLY_SIZED && ',dimVal);


        checkStmtFcn=@(extraCheck,dimVal,dataRole,dataId,descMsg)...
        sprintf('if (%s%s < 1) { ssSetErrorStatus(S, "%s %d: %s"); return; }',...
        extraCheck,dimVal,dataRole,dataId,descMsg);
    end

    if nargin<5
        dimIdx=[];
    end


    dimExpr=cellstr(dimExpr);


    if ischar(dimVar)||(isstring(dimVar)&&isscalar(dimVar))
        dimVar=char(dimVar);
        if~isempty(dimIdx)

            dimVal={sprintf('%s[%d]',dimVar,dimIdx-1)};
            descMsg={dimDescMsgFcn(dimIdx)};
        else

            dimVal={dimVar};
            descMsg={widthDescMsg};
        end
    elseif(iscellstr(dimVar)||isstring(dimVar))&&(numel(dimVar)==2)

        dimVal=cellstr(dimVar);
        descMsg=rowColDescMsg;
    else

        assert(false);
    end


    stmts={};

    for ii=1:numel(dimVal)



        if strcmp(dimExpr{ii},'DYNAMICALLY_SIZED')||isempty(regexp(dimExpr{ii},dynDimExpr,'start','once'))
            continue
        end


        extraStr='';
        if checkForDynSize
            extraStr=dynSizeCheckFcn(dimVal{ii});
        end


        stmts{end+1}=checkStmtFcn(extraStr,dimVal{ii},char(dataSpec.Kind),dataSpec.Id,descMsg{ii});%#ok<AGROW>
    end
