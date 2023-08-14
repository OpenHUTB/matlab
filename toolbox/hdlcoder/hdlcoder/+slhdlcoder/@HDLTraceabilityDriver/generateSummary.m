function generateSummary(~,summary_file,title,model,JavaScriptBody,hasWebview)




    w=hdlhtml.reportingWizard(summary_file,title);
    w.setHeader(MSG('hdlcoder:report:traceability_title',model));
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end

    w.addBreak(3);


    generateBasicSummary(w,model,hasWebview);

    w.addBreak(2);


    generateNondefaultParamSettings(w,model);

    w.addBreak(2);


    hDrv=hdlcurrentdriver;
    if hDrv.mdlIdx==numel(hDrv.AllModels)
        if hDrv.DUTMdlRefHandle>0
            topSubsystem=hDrv.ModelName;
        else
            topSubsystem=hDrv.getStartNodeName;
        end
    else
        topSubsystem=model;
    end


    section=w.createSectionTitle(MSG('hdlcoder:report:traceability_prop'));
    w.commitSection(section);

    w.addBreak(2);


    status=generateNondefaultBlockParamSettings(w,topSubsystem);

    if~status
        w.addText(MSG('hdlcoder:report:traceability_block_prop'));
    end
    w.addBreak;

    w.dumpHTML;
end


function generateBasicSummary(w,model,hasWebview)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:summary'));
    w.commitSection(section);
    w.addBreak(2);
    table=w.createTable(7,2);

    table.createEntry(1,1,MSG('hdlcoder:report:traceability_model'));
    table.createEntry(2,1,MSG('hdlcoder:report:traceability_modver'));
    table.createEntry(3,1,MSG('hdlcoder:report:traceability_hdlver'));
    table.createEntry(4,1,MSG('hdlcoder:report:traceability_hdlgen'));
    table.createEntry(5,1,MSG('hdlcoder:report:traceability_hdlgenfor'));
    table.createEntry(6,1,MSG('hdlcoder:report:traceability_tgtlang'));
    table.createEntry(7,1,MSG('hdlcoder:report:traceability_tgtdir'));
    hdlCoderVerInfo=ver('hdlcoder');
    version=hdlCoderVerInfo.Version;
    hdlcoderObj=hdlmodeldriver(model);

    if hasWebview&&~strcmp(hdlcoderObj.getStartNodeName,model)
        table.createEntry(1,2,...
        model,'right');
    else
        table.createEntry(1,2,...
        hdlhtml.reportingWizard.generateSystemLink(model),'right');
    end
    table.createEntry(2,2,get_param(model,'ModelVersion'),'right');
    table.createEntry(3,2,version,'right');
    table.createEntry(4,2,datestr(now,31),'right');
    dut=hdlcoderObj.getStartNodeName;
    cli=hdlcoderObj.getCLI;
    targetLanguage=cli.TargetLanguage;
    targetDirectory=cli.TargetDirectory;
    table.createEntry(5,2,...
    hdlhtml.reportingWizard.generateSystemLink(dut),'right');
    table.createEntry(6,2,targetLanguage,'right');
    table.createEntry(7,2,targetDirectory,'right');
    w.commitTable(table);
end


function generateNondefaultParamSettings(w,model)%#ok<INUSD>
    hD=hdlcurrentdriver;
    cli=hD.getCLI;

    if strcmp(cli.SynthesisTool,'Intel Quartus Pro')
        cli.Backannotation='off';
    end

    nondefPropsNameList=cli.getNonDefaultHDLCoderProps;
    nondefProps=cell(1,2*length(nondefPropsNameList));
    for i=1:length(nondefPropsNameList)
        propName=nondefPropsNameList{i};
        nondefProps{i*2-1}=propName;
        nondefProps{i*2}=cli.(propName);
    end
    if~isempty(nondefProps)
        section=w.createSectionTitle(MSG('hdlcoder:report:traceability_nondefprop'));
        w.commitSection(section);
    else
        return;
    end
    w.addBreak(2);

    table=w.createTable(length(nondefProps)/2,2);
    for i=1:2:length(nondefProps)
        prop=nondefProps{i};
        val=nondefProps{i+1};
        row=(i+1)/2;
        table.createEntry(row,1,prop);
        if iscell(val)
            str='';
            for j=1:length(val)
                str=sprintf('%s ''%s''',str,convert2str(val{j}));
            end
            table.createEntry(row,2,str,'right');
        else
            table.createEntry(row,2,convert2str(val),'right');
        end
    end
    w.commitTable(table);
end


function status=generateNondefaultBlockParamSettings(w,subsystemPath)

    blocks=find_system(subsystemPath,'SearchDepth',1,...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'LookUnderMasks','all','FollowLinks','on');

    status=false;
    for i=1:length(blocks)
        currBlkPath=blocks{i};
        t=get_param(currBlkPath,'Type');
        if~strcmpi(t,'block')
            continue;
        end
        blkType=get_param(currBlkPath,'BlockType');
        if strcmpi(blkType,'SubSystem')...
            &&~strcmpi(currBlkPath,subsystemPath)

            status1=generateNondefaultBlockParamSettings(w,currBlkPath);
        else
            status1=emitAllBlkParams(w,currBlkPath);
        end
        status=status||status1;
    end
end

function status=emitAllBlkParams(w,blkPath)
    status=false;
    pvPairs=get_param(blkPath,'HDLData');
    if~isempty(pvPairs)


        currArch=pvPairs.getCurrentArch;


        w.addFormattedText([MSG('hdlcoder:report:traceability_blkparam'),...
        hdlhtml.reportingWizard.generateSystemLink(blkPath)],'b');
        w.addFormattedText(MSG('hdlcoder:report:traceability_currArch',currArch),'bi');
        w.addBreak(2);
        status=true;


        currImplParams=pvPairs.getCurrentArchImplParams;
        if isempty(currImplParams)
            return;
        end

        if length(currImplParams)==1
            error(message('hdlcoder:engine:IllegalParams',blkPath));
        end
        table=w.createTable(length(currImplParams)/2,2);
        for i=1:2:length(currImplParams)
            param=currImplParams{i};
            value=currImplParams{i+1};
            row=(i+1)/2;
            table.createEntry(row,1,param);
            table.createEntry(row,2,convert2str(value),'right');
        end
        w.commitTable(table);
        w.addBreak(2);
    end
end

function str=convert2str(value)
    str=value;
    if isnumeric(value)
        if isscalar(value)
            str=num2str(value);
        else
            str=sprintf('%d ',value);
        end
    elseif isa(value,'hdlcodingstd.BaseCustomizations')
        str=['<pre>',value.toString(),'</pre>'];
    elseif iscell(value)

        str=hdlCellArray2Str(value);
    elseif~ischar(value)
        str=value.toString();
    end
end


function str=MSG(varargin)
    obj=message(varargin{:});
    str=obj.getString();
end



