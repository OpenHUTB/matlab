function[starc_checks,starc_rules]=runCheckhdlOnModel(this,mdlName,...
    slFrontEnd,wantChecksInM,htmlReport,createNewTab)




    if~this.ChecksCatalog.isKey(mdlName)
        this.updateChecksCatalog(mdlName,[]);
    end

    checks=[];




    annotChecks=checkAnnotationFori18nText(this,mdlName);
    checks=cat(2,checks,annotChecks);




    blockChecks=this.blockCompatibilityCheck(slFrontEnd);
    checks=cat(2,checks,blockChecks);




    realsChecks=this.EMLChecks(slFrontEnd.hPir);
    checks=cat(2,checks,realsChecks);

    level=this.getNonAsciiMessageLevel;





    if this.isIndustryStandardMode()
        codingStdEnum=this.getParameter('HDLCodingStandard');
        codingStdOptions=this.getParameter('HDLCodingStandardCustomizations');
        targetL=this.getParameter('Target_Language');
        validator=hdlcodingstd.Checker(slFrontEnd.hPir,codingStdEnum,codingStdOptions,...
        targetL,this.CalledFromMakehdl);
        codingstdChecks=validator.checkCodingStandard();
        hdlcodingstd.Report.add(mdlName,codingstdChecks);

        indMsgString='';
        comaString='';



        if~strcmpi('_pac',hdlget_param(this.ModelName,'PackagePostfix'))
            comaString=', ';
            indMsgString=[indMsgString,'PackagePostfix'];
        end
        if~strcmpi('on',this.getParameter('MinimizeClockEnables'))
            indMsgString=[indMsgString,comaString,'MinimizeClockEnables'];
            comaString=', ';
        end
        if~strcmpi('on',this.getParameter('MinimizeGlobalResets'))
            indMsgString=[indMsgString,comaString,'MinimizeGlobalResets'];
            comaString=', ';
        end
        if~strcmpi('u_',this.getParameter('instance_prefix'))
            indMsgString=[indMsgString,comaString,'InstancePrefix'];
            comaString=', ';
        end
        if~strcmpi('',this.getParameter('instance_postfix'))
            indMsgString=[indMsgString,comaString,'InstancePostfix'];
        end


        if~isempty(indMsgString)
            msg=message('hdlcoder:validate:IgnoreParamsOnSettingCodingStandardsToIndustry',indMsgString,mdlName);
            checks(end+1).path=mdlName;
            checks(end).type='model';
            checks(end).message=msg.getString();
            checks(end).level=level;
            checks(end).MessageID=msg.Identifier;
        end
    end




    this.updateChecksCatalog(mdlName,checks);





    if~wantChecksInM||htmlReport


        if~this.CalledFromMakehdl
            this.NeedToGenerateHTMLReport=false;
            this.makehdlcheckreport(mdlName,this.ChecksCatalog(mdlName),createNewTab);
        end
        if this.isIndustryStandardMode()&&~this.CalledFromMakehdl

            showReport=this.getParameter('ErrorCheckReport');
            codingStdOptions=this.getParameter('HDLCodingStandardCustomizations');
            hdlcodingstd.Report.generateIndustryStandardReport(mdlName,showReport,codingStdOptions);
        end
    end


    if wantChecksInM
        if~this.CalledFromMakehdl
            for ii=1:numel(checks)

                if strcmpi(checks(ii).level,'message')
                    checks(ii).message=hdlRemoveHtmlonlyTags(checks(ii).message);
                end
            end
        end
    end


    if this.isIndustryStandardMode()&&~this.CalledFromMakehdl&&wantChecksInM
        [starc_checks,starc_rules]=hdlcodingstd.Report.getValidationInfo(mdlName,codingStdOptions);
    else
        starc_checks=[];
        starc_rules=[];
    end

    if~this.CalledFromMakehdl

        this.displayStatusChecksCount(mdlName,false);
    end

    if this.isIndustryStandardMode()&&~this.CalledFromMakehdl

        hdldisp(hdlcodingstd.Report.getSummary(mdlName));
    end
end

function checks=checkAnnotationFori18nText(this,mdlName)
    dut=this.getStartNodeName;



    dut_strsplit=strsplit(dut,'/');
    dut_mdlName=dut_strsplit{1};
    if~strcmp(dut_mdlName,mdlName)
        dut=mdlName;
    end
    checks=[];
    try
        annot.handle=find_system(dut,'LookUnderMasks','All','FindAll','On',...
        'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
        'Type','Annotation');

        annot.text=get_param(annot.handle,'PlainText');









        annot.names=strcat(get_param(annot.handle,'Parent'),'/',annot.text);
    catch mEx %#ok<NASGU>

        return
    end

    level=this.getNonAsciiMessageLevel;

    modelDescriptionText=get_param(mdlName,'Description');

    if any(modelDescriptionText>=256)
        msg=message('hdlcoder:validate:ModelDescriptionI18N',mdlName);

        checks(end+1).path=mdlName;
        checks(end).type='model';
        checks(end).message=msg.getString();
        checks(end).level=level;
        checks(end).MessageID=msg.Identifier;
    end


    if~isa(annot.text,'cell')
        annot.text={annot.text};
        annot.names={annot.names};
    end

    for itr=1:length(annot.names)
        if any(annot.text{itr}>=256)
            msg=message('hdlcoder:validate:AnnotationTextI18N',annot.names{itr},mdlName);

            checks(end+1).path=annot.names{itr};%#ok<AGROW>
            checks(end).type='block';
            checks(end).message=msg.getString();
            checks(end).level=level;
            checks(end).MessageID=msg.Identifier;
        end
    end


    mask_handles=find_system(get_param(dut,'Handle'),'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'BlockType','SubSystem','Mask','on');

    modelinfo.handles=[];
    modelinfo.names={};
    modelinfo.maskdisplaystring={};
    if~isempty(mask_handles)
        for itr=1:length(mask_handles)
            obj=Simulink.Mask.get(mask_handles(itr));
            if~isempty(obj.getParameter('DisplayStringWithTags'))
                modelinfo.handles(end+1)=mask_handles(itr);
                modelinfo.names{end+1}=getfullname(mask_handles(itr));
                modelinfo.maskdisplaystring{end+1}=get_param(mask_handles(itr),'MaskDisplayString');
            end
        end
    end

    for itr=1:length(modelinfo.handles)
        if any(modelinfo.maskdisplaystring{itr}>=256)
            msg=message('hdlcoder:validate:ModelInfoI18N',modelinfo.names{itr},mdlName);

            checks(end+1).path=modelinfo.names{itr};%#ok<AGROW>
            checks(end).type='model';
            checks(end).message=msg.getString();
            checks(end).level=level;
            checks(end).MessageID=msg.Identifier;
        end
    end
end

