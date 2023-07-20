function generateObfuscationReport(~,summary_file,title,model,~,JavaScriptBody)





    w=hdlhtml.reportingWizard(summary_file,title);
    w.setHeader(MSG('hdlcoder:report:ObfuscationTitle',model));
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end


    w.addBreak(3);


    w.addText(MSG('hdlcoder:report:ObfuscationStatusMsg'));


    generateIgnrNonDefParamSettingsReport(w,model);


    generateUnsupportedBlkReport(w,model);


    w.addBreak(2);


    w.addText(MSG('hdlcoder:report:ObfuscationHelpLink'));


    w.dumpHTML;
end


function generateIgnrNonDefParamSettingsReport(w,model)


    hD=hdlcurrentdriver;
    cli=hD.getCLI;
    nondefPropsNameList=cli.getNonDefaultHDLCoderProps;


    ingrPropsNameList={
    'BlockGenerateLabel',...
    'ClockProcessPostfix',...
    'ComplexImagPostfix',...
    'ComplexRealPostfix',...
    'CustomFileFooterComment',...
    'CustomFileHeaderComment',...
    'EnablePrefix',...
    'EntityConflictPostfix',...
    'HDLCodingStandard',...
    'InstanceGenerateLabel',...
    'InstancePostfix',...
    'InstancePrefix',...
    'ModulePrefix',...
    'OutputGenerateLabel',...
    'PackagePostfix',...
    'PipelinePostfix',...
    'ReservedWordPostfix',...
    'TimingControllerPostfix',...
    'Traceability',...
    'VectorPrefix'};


    ignrNonDefPropForObfu={};
    for i=1:length(nondefPropsNameList)
        propName=nondefPropsNameList{i};
        if contains(propName,ingrPropsNameList)
            ignrNonDefPropForObfu{end+1}=['<a href="matlab:configset.internal.open(''',...
            model,''',''',propName,''')">',propName,'</a>'];%#ok<AGROW>
        end
    end


    if~isempty(ignrNonDefPropForObfu)
        w.addBreak(2);
        section=w.createSectionTitle(MSG('hdlcoder:report:ObfuscationIgnrNonDefParam'));
        w.commitSection(section);
    else
        return;
    end

    w.addBreak(2);


    table=w.createTable(length(ignrNonDefPropForObfu),1);
    for i=1:length(ignrNonDefPropForObfu)
        table.createEntry(i,1,ignrNonDefPropForObfu{i});
    end
    w.commitTable(table);
end


function generateUnsupportedBlkReport(w,model)

    unSuppBlksForObfus={
    ['dspmlti4/CIC',newline,'Decimation'],...
    ['dspmlti4/CIC',newline,'Interpolation'],...
    ['dspmlti4/FIR',newline,'Decimation'],...
    ['dspmlti4/FIR',newline,'Interpolation']};


    ignrBlkListInModel={};
    for i=1:length(unSuppBlksForObfus)


        blkList=find_system(model,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'ReferenceBlock',unSuppBlksForObfus{i});
        for j=1:length(blkList)
            ignrBlkListInModel{end+1}=blkList{j};%#ok<AGROW>
        end
    end


    if~isempty(ignrBlkListInModel)
        w.addBreak(2);
        section=w.createSectionTitle(MSG('hdlcoder:report:ObfuscationUnSuppBlk'));
        w.commitSection(section);
    else
        return;
    end

    w.addBreak(2);


    table=w.createTable(length(ignrBlkListInModel),2);
    for i=1:length(ignrBlkListInModel)

        table.createEntry(i,1,hdlhtml.reportingWizard.generateSystemLink(ignrBlkListInModel{i}));
        table.createEntry(i,2,getfullname(ignrBlkListInModel{i}));
    end
    w.commitTable(table);
end


function str=MSG(varargin)
    obj=message(varargin{:});
    str=obj.getString();
end
