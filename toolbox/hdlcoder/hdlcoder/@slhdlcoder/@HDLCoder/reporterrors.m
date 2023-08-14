function reporterrors(this,v)









    dataId=matlab.ddux.internal.DataIdentification("HD","HD_HDLCODER","HD_HDLCODER_MAKEHDL");

    cli=this.getCLI;
    params=cli.getNonDefaultHDLCoderProps;


    [LoggedProps,NonDefaultCheckOnlyProps]=cli.getPropertiesForLogging();

    ddux=struct(blockType="",parameter="",value="",errorType="",...
    errorLevel="",errorMessageID="",errorBlockType="");

    if~isempty(params)
        valueParams=intersect(params,LoggedProps);

        vals=cellfun(@(param)getValForParam(cli,param),valueParams,'UniformOutput',false);



        nonDefaultFlagParams=intersect(params,NonDefaultCheckOnlyProps);

        nonDefaultFlagParamVals=repmat("",1,numel(nonDefaultFlagParams));

        if numel(valueParams)+numel(nonDefaultFlagParams)>0
            ddux.blockType=repmat("model",1,numel(valueParams)+numel(nonDefaultFlagParams));
            ddux.parameter=[string(valueParams),string(nonDefaultFlagParams)];
            ddux.value=[vals{:},nonDefaultFlagParamVals];
        end
    end

    if~isempty(v)

        warns=struct([]);errs=struct([]);msgs=struct([]);
        for i=1:numel(v)
            switch lower(v(i).level)
            case 'error'
                if isempty(errs)
                    errs=v(i);
                else
                    errs(end+1)=v(i);%#ok<AGROW> % copy message over
                end
            case 'warning'
                if isempty(warns)
                    warns=v(i);
                else
                    warns(end+1)=v(i);%#ok<AGROW> % copy message over
                end
            case 'message'
                if isempty(msgs)
                    msgs=v(i);
                else
                    msgs(end+1)=v(i);%#ok<AGROW> % copy message over
                end


            end
        end


        if~isempty(errs)
            if this.getParameter('debug')>=1&&~isempty(which('hdldebugcallback'))
                hdldebugcallback(this);
            end

            this.displayStatusChecksCount(this.ModelName,false);

            err=errs(end);

            errPath=err.path;
            errMessage=err.message;

            msg=message('hdlcoder:makehdl:ForTheBlock',...
            hdlMsgWithLink(errPath,errMessage));
            msgText=msg.getString;


            modelErrs=errs(strcmp({errs.path},bdroot));
            blockErrs=errs(~strcmp({errs.path},bdroot));




            for i=1:numel(blockErrs)
                if(getSimulinkBlockHandle(blockErrs(i).path)<0)
                    parentPath=extractParentFromBlock(blockErrs(i).path);
                    blockErrs(i).path=parentPath;
                end
            end

            blockTypes=cellfun(@hdlgetblocklibpath,{blockErrs.path},'UniformOutput',false);


            ddux.errorType=string({modelErrs.type,blockErrs.type});
            ddux.errorLevel=string({modelErrs.level,blockErrs.level});
            ddux.errorMessageID=string({modelErrs.MessageID,blockErrs.MessageID});
            ddux.errorBlockType=string([repmat({'model'},1,length(modelErrs)),blockTypes]);
            matlab.ddux.internal.logData(dataId,ddux);

            error(errs(end).MessageID,'\n%s',msgText);

        end
    end


    matlab.ddux.internal.logData(dataId,ddux);

end


function parentPath=extractParentFromBlock(str)
    if contains(str,'/')
        parentPath=regexp(str,'.+(?=\/[^\/]*$)','once','match');
        if(getSimulinkBlockHandle(parentPath)<0)
            parentPath=extractParentFromBlock(parentPath);
        end
    else
        parentPath=str;
    end
end

function val=getValForParam(cli,param)
    val=cli.(param);
    if strcmp(param,'FloatingPointTargetConfiguration')
        val=serializeOutMScripts(val);
        val=strrep(val,[' ...',newline],'');
    elseif strcmp(param,'HDLCodingStandardCustomizations')
        val=toString(val);
    end

    try
        val=string(val);
    catch
        val="";
    end
end


