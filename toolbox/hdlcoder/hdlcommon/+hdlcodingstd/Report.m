
classdef Report<handle














    properties(Access=private)
        Checks='';
        StartNode='';
        ModelName='';
        report=struct('complete',false,'path','','name','');
        TargetLanguage='';
codingStdOptions
STARCrules
    end

    properties(Access=public)
        ruleMap=containers.Map('KeyType','char','ValueType','any');
        MLHDLC=struct('topFcnName','','scriptName','');
        file_id=[];
        ICON_PATH=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','icons',filesep);
        inMLHDLCmode=false;
    end



    methods(Static,Access=public)


        function new_rule=mungeRule(tag_prefix,rule_in)
            q=regexp((rule_in),'\.','split');
            for itr=2:min(3,length(q))
                q{itr}=char(str2num(q{itr})-1+'A');%#ok<ST2NM>
            end
            rule='';
            for itr=1:length(q)
                rule=[rule,q{itr},'.'];
            end
            new_rule=[tag_prefix,rule(1:end-1)];
            new_rule=regexprep(new_rule,'\.+$','');
        end

        function r=initReport(StartNode,ModelName,fromMLHDLC)
            if(nargin<3)
                fromMLHDLC=false;
            end


            r=hdlcodingstd.Report.getReport(ModelName);
            r.Clear();
            if(nargin==2)
                r.Reset([],StartNode,ModelName);
            end

            if(fromMLHDLC)
                r=hdlcodingstd.Report.getReport(StartNode);
                r.Clear();
                r.Reset([],StartNode,ModelName);
            end
            return
        end


        function r=getReport(ModelName)

            persistent reportMap;
            if isempty(reportMap)

                reportMap=containers.Map(ModelName,hdlcodingstd.Report());
            end
            if~reportMap.isKey(ModelName)

                reportMap(ModelName)=hdlcodingstd.Report;
            end

            r=reportMap(ModelName);
        end

        function r=add(modelName,checks)

            r=hdlcodingstd.Report.getReport(modelName);
            r.Add(checks);
        end






        function addCGIRcheck(mdlName,path,type,messageID,message,level,ruleID)
            r=hdlcodingstd.Report.getReport(mdlName);
            check=struct('path',path,'type',type,'message',message,'MessageID',...
            messageID,'level',level,'RuleID',ruleID);
            r.Add(check);
        end


        function r=generateIndustryStandardReportMLHDLC(topFcnName,scriptName,showReport,codingStdOptions)
            q=hdlcodingstd.Report.getReport('MLHDLC');
            r=hdlcodingstd.Report.getReport(topFcnName);
            r.codingStdOptions=codingStdOptions;

            r.Add(q.Checks);
            r.MLHDLC.topFcnName=topFcnName;
            r.MLHDLC.scriptName=scriptName;
            r.inMLHDLCmode=true;
            r.TargetLanguage=hdlgetparameter('Target_Language');
            r.GenerateListBasedSTARCreport(showReport);
        end

        function r=generateIndustryStandardReport(modelName,showReport,codingStdOptions)


            if nargin<2
                showReport=true;
            end

            r=hdlcodingstd.Report.getReport(modelName);
            if(isempty(r.TargetLanguage))
                r.TargetLanguage=hdlgetparameter('Target_Language');
            end

            if nargin>=3
                r.codingStdOptions=codingStdOptions;
            end
            r.inMLHDLCmode=false;
            r.GenerateListBasedSTARCreport(showReport);
        end

        function[checks_out,rules]=getValidationInfo(modelName,codingStdOptions)

            r=hdlcodingstd.Report.getReport(modelName);
            r.setCodingStdOptions(codingStdOptions);

            [checks_out,rules]=r.SortByRule();
        end


        function[str,nerr,nwarn,nmsg]=getSummary(mdlName)
            r=hdlcodingstd.Report.getReport(mdlName);
            [str,nerr,nwarn,nmsg]=r.GetSummary;
        end


        function flag=isIndustryStandardMode()
            flag=false;
            targetL=hdlgetparameter('Target_Language');
            codingStdEnum=hdlgetparameter('HDLCodingStandard');
            CodingStandardNames={targetL,'Industry'};
            if(strcmpi(CodingStandardNames(codingStdEnum),'Industry'))
                flag=true;
            end
        end



        function flag=genDefaultScript(subsysName,hdlFiles,prjFullName,isMLHDLC,hdlCfg)




            if nargin<4
                isMLHDLC=false;
                hdlCfg=[];
            end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end

            fp=fopen(prjFullName,'w','n','utf-8');
            if fp<0
                flag=false;
                return;
            end

            p=pir();
            target_language=p.getParamValue('target_language');

            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>
            link=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            link_str=['Generating default Lint tool script file ',link];
            hdldisp(link_str);

            if(~isMLHDLC)
                HDLLintInit=hdlgetparameter('HDLLintInit');
                HDLLintTerm=hdlgetparameter('HDLLintTerm');
                HDLLintCmd=hdlgetparameter('HDLLintCmd');
            else
                HDLLintInit=hdlCfg.HDLLintInit;
                HDLLintTerm=hdlCfg.HDLLintTerm;
                HDLLintCmd=hdlCfg.HDLLintCmd;
            end







            hdlcodingstd.LintToolScripts.Lint_Default(fp,HDLLintCmd,HDLLintInit,HDLLintTerm,hdlFiles,subsysName,target_language);

            flag=1+fclose(fp);
        end

        function reportForTestpointsInIndustryStandardMode(mdlName)




            p=pir(mdlName);
            if hdlcodingstd.Report.isIndustryStandardMode()
                warning(message('hdlcommon:IndustryStandard:testpointconflictsindustrystd'));
            end
        end


        function flag=genHDLDesignerScript(subsysName,hdlFiles,prjFullName,isMLHDLC,hdlCfg)




            if nargin<4
                isMLHDLC=false;
                hdlCfg=[];
            end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end

            p=pir();
            target_language=p.getParamValue('target_language');
            target_language=lower(target_language);
            if(~any(strcmp({'verilog','vhdl'},target_language)))
                error(message('hdlcommon:IndustryStandard:UnknownTargetLang'))
            end

            fp=fopen(prjFullName,'w','n','utf-8');
            if fp<0
                flag=false;
                return;
            end
            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>
            link=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            link_str=['Generating HDLDesigner Lint script file ',link];
            hdldisp(link_str);

            if(~isMLHDLC)
                HDLLintInit=hdlgetparameter('HDLLintInit');
                HDLLintTerm=hdlgetparameter('HDLLintTerm');
                HDLLintCmd=hdlgetparameter('HDLLintCmd');
            else
                HDLLintInit=hdlCfg.HDLLintInit;
                HDLLintTerm=hdlCfg.HDLLintTerm;
                HDLLintCmd=hdlCfg.HDLLintCmd;
            end

            hDrv=hdlcurrentdriver();
            if(isempty(hDrv))
                error(message('hdlcommon:IndustryStandard:DriverNotFound'))
            end

            work_dir=hDrv.getCLI.VHDLLibraryName;

            hdlcodingstd.LintToolScripts.Lint_hdldesigner(fp,HDLLintCmd,HDLLintInit,HDLLintTerm,hdlFiles,subsysName,target_language,work_dir);
            flag=1+fclose(fp);
        end

        function flag=genLEDAScript(subsysName,hdlFiles,prjFullName,isMLHDLC,hdlCfg)




            if nargin<4
                isMLHDLC=false;
                hdlCfg=[];
            end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end

            p=pir();
            target_language=p.getParamValue('target_language');
            if(length(target_language)>3)
                target_language=target_language(1:3);
            end
            target_language=lower(target_language);


            if(~isMLHDLC)
                HDLLintInit=hdlgetparameter('HDLLintInit');
                HDLLintTerm=hdlgetparameter('HDLLintTerm');
                HDLLintCmd=hdlgetparameter('HDLLintCmd');
            else
                HDLLintInit=hdlCfg.HDLLintInit;
                HDLLintTerm=hdlCfg.HDLLintTerm;
                HDLLintCmd=hdlCfg.HDLLintCmd;
            end
            if(isempty(HDLLintCmd))
                HDLLintCmd='%s \n';
            end

            [path,~,~]=fileparts(prjFullName);
            ancillary_file=fullfile(path,['LEDA_',lower(target_language),'.lst']);
            fp=fopen(ancillary_file,'w','n','utf-8');
            for itr=1:length(hdlFiles)
                fprintf(fp,HDLLintCmd,hdlFiles{itr});
            end
            flag=1+fclose(fp);
            fp=fopen(prjFullName,'w','n','utf-8');
            if fp<0
                flag=false;
                return;
            end
            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>

            link_A=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            link_str_A=['Generating LEDA Lint script file ',link_A];
            link_B=['<a href="matlab:edit(''',ancillary_file,''')">',['LEDA_',lower(target_language),'.lst'],'</a>'];
            link_str_B=['Generating LEDA Lint ancillary file ',link_B];
            hdldisp(link_str_A);
            hdldisp(link_str_B);






            hdlcodingstd.LintToolScripts.Lint_LEDA(fp,HDLLintInit,HDLLintTerm,subsysName,target_language);

            flag=flag&&(1+fclose(fp));%#ok<BDLOG> % 0 -> true, -1 -> false.
            return
        end

        function flag=genAscentLintScript(subsysName,hdlFiles,prjFullName,isMLHDLC,hdlCfg)




            if nargin<4
                isMLHDLC=false;
                hdlCfg=[];
            end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end

            p=pir();
            target_language=p.getParamValue('target_language');
            target_language=lower(target_language);
            if(~any(strcmp({'verilog','vhdl'},target_language)))
                error(message('hdlcommon:IndustryStandard:UnknownTargetLang'))
            end

            fp=fopen(prjFullName,'w','n','utf-8');
            if fp<0
                flag=false;
                return;
            end
            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>
            link=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            link_str=['Generating Ascent Lint script file ',link];
            hdldisp(link_str);

            if(~isMLHDLC)
                HDLLintInit=hdlgetparameter('HDLLintInit');
                HDLLintTerm=hdlgetparameter('HDLLintTerm');
                HDLLintCmd=hdlgetparameter('HDLLintCmd');
            else
                HDLLintInit=hdlCfg.HDLLintInit;
                HDLLintTerm=hdlCfg.HDLLintTerm;
                HDLLintCmd=hdlCfg.HDLLintCmd;
            end

            hDrv=hdlcurrentdriver();
            if(isempty(hDrv))
                error(message('hdlcommon:IndustryStandard:DriverNotFound'))
            end
            work_dir=hDrv.getCLI.VHDLLibraryName;

            hdlcodingstd.LintToolScripts.Lint_ascentlint(fp,HDLLintCmd,HDLLintInit,HDLLintTerm,hdlFiles,subsysName,target_language,work_dir);
            flag=1+fclose(fp);
        end

        function flag=genSpyGlassScript(subsysName,hdlFiles,prjFullName,isMLHDLC,hdlCfg)




            if nargin<4
                isMLHDLC=false;
                hdlCfg=[];
            end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end

            fp=fopen(prjFullName,'w','n','utf-8');
            if fp<0
                flag=false;
                return;
            end
            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>
            link=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            link_str=['Generating SpyGlass Lint script file ',link];
            hdldisp(link_str);

            if(~isMLHDLC)
                HDLLintInit=hdlgetparameter('HDLLintInit');
                HDLLintTerm=hdlgetparameter('HDLLintTerm');
                HDLLintCmd=hdlgetparameter('HDLLintCmd');
            else
                HDLLintInit=hdlCfg.HDLLintInit;
                HDLLintTerm=hdlCfg.HDLLintTerm;
                HDLLintCmd=hdlCfg.HDLLintCmd;
            end






            hdlcodingstd.LintToolScripts.Lint_spyglass(fp,HDLLintCmd,HDLLintInit,HDLLintTerm,hdlFiles,subsysName);
            flag=1+fclose(fp);
        end
    end



    methods
        function obj=Report()
            obj.codingStdOptions=hdlcoder.CodingStandard('INDUSTRY');
            obj.STARCrules=containers.Map('KeyType','char','ValueType','char');
        end


        function setCodingStdOptions(obj,val)

            obj.codingStdOptions=val;
        end

        function val=getCodingStdOptions(obj)

            val=obj.codingStdOptions;
        end

        function disp(this)
            disp(this.Checks)
            disp(this.StartNode)
            disp(this.ModelName)
            disp(this.MLHDLC)
            disp(this.codingStdOptions)
            disp(this.STARCrules)
        end


        function Clear(this)
            this.file_id=[];
            this.Checks=[];
            this.StartNode='';
            this.ModelName='';
            this.MLHDLC;
            this.inMLHDLCmode=false;
            this.report=struct('complete',false,'path','','name','');
            this.MLHDLC=struct('topFcnName','','scriptName','');
            this.ruleMap.remove(this.ruleMap.keys);
            this.TargetLanguage='';
            this.codingStdOptions=hdlcoder.CodingStandard('None');
            this.STARCrules.remove(this.STARCrules.keys);
        end



        function Reset(this,checks,startNode,modelN)
            if nargin<2
                this.Clear();
            else
                this.file_id=[];
                this.Checks=cat(2,this.Checks,checks);
                this.StartNode=startNode;
                this.ModelName=modelN;
                this.inMLHDLCmode=false;
                this.report=struct('complete',false,'path','','name','');
                this.MLHDLC=struct('topFcnName','','scriptName','');
                this.ruleMap.remove(this.ruleMap.keys);
                this.TargetLanguage=hdlgetparameter('Target_Language');
                this.codingStdOptions=hdlcoder.CodingStandard('None');
            end
        end


        function Add(this,checks)
            this.Checks=cat(2,this.Checks,checks);
        end



        function shrewmsg=sanitizeXlanguageMsg(this,msg)



            dual=regexpi(msg,'\(Verilog\);','split');
            isdual=false;
            newmsg=msg;
            if(length(dual)==2)
                dual{1}=strtrim(dual{1});
                dual{2}=regexprep(dual{2},'\(VHDL\)','');
                isdual=true;
            end

            switch(upper(this.TargetLanguage))
            case{'VERILOG'}
                if(~isdual)
                    newmsg=regexprep(msg,'\(Verilog\)','');
                else
                    newmsg=dual{1};
                end
            case{'VHDL'}
                if(~isdual)
                    newmsg=regexprep(msg,'\(VHDL\)','');
                else
                    newmsg=dual{2};
                end
            end

            shrewmsg=regexprep(newmsg,'[\.\s]+$','.');
        end

        function flag=isXlanguageRule(this,msg)%#ok<INUSL>
            flag=false;

            if(~isempty(regexpi(msg,'^Invalid rule for','match')))
                flag=true;
            end
            return
        end


        function[checks,nerr,nwarn,nmsg]=SortByType(this)

            errs=[];
            warns=[];
            messg=[];
            checks=this.Checks;
            for n=1:length(checks)
                switch lower(checks(n).level)
                case 'error'
                    errs=[errs,checks(n)];%#ok<*AGROW>
                case 'warning'
                    warns=[warns,checks(n)];
                case 'message'
                    messg=[messg,checks(n)];
                otherwise
                    errs=[errs,checks(n)];
                end
            end

            checks=[];

            if~isempty(errs)
                checks=[checks,errs];
            end
            if~isempty(warns)
                checks=[checks,warns];
            end
            if~isempty(messg)
                checks=[checks,messg];
            end

            nerr=numel(errs);
            nwarn=numel(warns);
            nmsg=numel(messg);
            return;
        end


        function[str,nerr,nwarn,nmsg]=GetSummary(this)
            [~,nerr,nwarn,nmsg]=this.SortByType;
            if this.report.complete
                filePath=this.report.path;
                fileName=this.report.name;
                str=[message('hdlcommon:IndustryStandard:summary',num2str(nerr),num2str(nwarn),num2str(nmsg)).getString,newline];
                linkA=['<a href="matlab:web(''',filePath,''')">',fileName,'</a>'];
                link_str=['### ',message('hdlcommon:IndustryStandard:generatingReport').getString,' ',linkA];

                str=[str,link_str];
            else
                str=message('hdlcommon:IndustryStandard:summary',num2str(nerr),num2str(nwarn),num2str(nmsg)).getString;
            end
        end



        function[rule_checks,rules,maxlevel]=SortByRule(this)
            violated_rules=containers.Map('KeyType','char','ValueType','any');
            rule_checks=struct('path',{},'type',{},'message',{},...
            'level',{},'MessageID',{},'RuleID',{});
            rules=struct('RuleID',{},'Compliance',{},'MaxLevel',{});
            checks=this.Checks;


            this.ruleMap.remove(this.ruleMap.keys);

            for n=1:length(checks)

                if(~this.ruleMap.isKey(checks(n).RuleID))
                    this.ruleMap(checks(n).RuleID)={checks(n)};
                else
                    val=this.ruleMap(checks(n).RuleID);
                    this.ruleMap(checks(n).RuleID)={val{:},checks(n)};%#ok<CCAT>
                end
            end

            ruleMapKeys=this.ruleMap.keys;
            for key_itr=1:numel(ruleMapKeys)
                key=ruleMapKeys{key_itr};
                val=this.ruleMap(key);


                compliant=~(numel(val)>0);
                if(~compliant)
                    maxlevel='Message';
                    msgs=val{:};
                    if(any(cellfun(@(x)strcmpi(x,'Error'),{msgs.level})))
                        maxlevel='Error';
                    elseif(any(cellfun(@(x)strcmpi(x,'Warning'),{msgs.level})))
                        maxlevel='Warning';
                    end
                else
                    maxlevel='';
                end
                rules(key_itr)=struct('RuleID',key,'Compliance',compliant,'MaxLevel',maxlevel);
                violated_rules(key)=compliant;
                rule_checks=cat(2,rule_checks,val{:});
            end


            allCheckedSTARCrules=this.getCheckedSTARCrules();
            rule_map=allCheckedSTARCrules.keys();
            for itr=1:allCheckedSTARCrules.Count
                ruleID=rule_map{itr};
                if(~violated_rules.isKey(ruleID))
                    rules=cat(2,rules,struct('RuleID',ruleID,'Compliance',true,'MaxLevel',''));
                end
            end
        end


        function serializeCodingStdOptions(this,Fid,useHTML)
            if(nargin<3)
                useHTML=false;
            elseif(~islogical(useHTML))
                useHTML=strncmpi('HTML',useHTML,length(useHTML));
            end

            if(useHTML)
                fprintf(Fid,'<div class="expandableContent">\n');
                fprintf(Fid,'<span><strong>Show <a onClick="javascript:$(''#codingstdoptions'').toggle();">HDL Coding Standard Customizations</a></strong></span>');
                fprintf(Fid,'<pre id="codingstdoptions" style="display:none;">\n');
            end

            fprintf(Fid,'#  -------------------------------------------------------------------\n');
            fprintf(Fid,'Report was generated with following customizations\n');
            fprintf(Fid,'%s\n',this.codingStdOptions.toString());
            fprintf(Fid,'#  -------------------------------------------------------------------\n');

            if(useHTML)
                fprintf(Fid,'</pre>\n');
                fprintf(Fid,'</div>\n');
                fprintf(Fid,'<HR />\n');
            end

        end





        function GenerateListBasedSTARCreport(this,showReport)
            checks=this.Checks;

            if~this.inMLHDLCmode
                nname=this.StartNode;
                modelName=this.ModelName;
                [~,bname]=getmodelnodename(modelName,nname);

                nname=strrep(nname,newline,' ');
                if isempty(bname)
                    bname=nname;
                end
            else
                bname=this.MLHDLC.topFcnName;
                nname=this.MLHDLC.topFcnName;
                modelName=this.MLHDLC.scriptName;
            end


            codegendir=hdlGetCodegendir;
            if~isdir(codegendir)
                hdlmakecodegendir;
            end


            Checks=rmfield(checks,'type');
            save(fullfile(hdlGetCodegendir,[hdllegalname(bname),'_Industry_report']),'Checks');



            this.STARCrules.remove(this.STARCrules.keys);


            fileName=[hdllegalname(bname),'_Industry_report.html'];
            fopenName=fullfile(codegendir,fileName);

            txtFileName=fullfile(codegendir,[hdllegalname(bname),'_Industry_report.txt']);

            fid=fopen(fopenName,'w','n','utf-8');

            txtFID=fopen(txtFileName,'w','n','utf-8');

            if(fid==-1||txtFID==-1),error(message('hdlcoder:engine:cannotopenfile',fileName));end
            this.file_id=fid;


            hdlcodingstd.HTMLReporter.writeJQueryHTMLheader(fid,nname);

            fprintf(fid,'<div class="content_container">\n');
            fprintf(fid,['<div class="expandableContent"><div class="content_header"><h3>',message('hdlcommon:IndustryStandard:reportTitle').getString]);

            if(this.inMLHDLCmode)

                fprintf(fid,[' ',message('hdlcommon:IndustryStandard:forML').getString,' ']);
                genMLfileLinks(this,modelName);
            else

                fprintf(fid,[' ',message('hdlcommon:IndustryStandard:forSL').getString,' ','<a href="matlab:open_system(''%s'');">%s</a>\n'],nname,nname);
            end
            fprintf(fid,'</h3></div></div></div></div></div>\n');

            hasAnError=false;

            if isempty(checks)
                fprintf(fid,['<p>',message('hdlcommon:IndustryStandard:noMsg').getString,'<BR>\n']);
                rules=[];
            else


                [~,rules,maxlevel]=this.SortByRule();

                hasAnError=strcmpi(maxlevel,'Error');



                fprintf(fid,'<div class="content_header"><section><div>\n');
                fprintf(fid,['<div class="expandableContent"><div class="content_header"><h4>',message('hdlcommon:IndustryStandard:ruleSummary').getString,'</h4></div>\n']);
                fprintf(fid,['<div class="switch"><a class="expandAllLink" href="javascript:void(0);">',message('hdlcommon:IndustryStandard:expandAll').getString,'</a></div>\n']);
                fprintf(fid,'<div class="collapse">\n');
                fprintf(fid,'<div itemprop="content"><h4>%s <BR /><BR />',this.GetSummary());
                fprintf(fid,'Generated by HDL Coder v.%s, on %s.</h4></div><div itemprop="content">\n',getfield(ver('HDLCoder'),'Version'),datestr(now,0));
                fprintf(fid,'<TABLE class="content_table">\n');

                fprintf(fid,['<TR><TD><B>',message('hdlcommon:IndustryStandard:Rule').getString,'</B></TD>']);
                fprintf(fid,['<TD >&nbsp;<B>',message('hdlcommon:IndustryStandard:Level').getString,'</B>&nbsp;</TD>']);
                fprintf(fid,['<TD >&nbsp;&nbsp; <B>',this.sanitizeXlanguageMsg(message('hdlcommon:IndustryStandard:Description').getString()),'</B></TD></TR>']);
                for itr=1:numel(rules)
                    generic_desc=this.getRuleDesc(rules(itr).RuleID);
                    desc=this.sanitizeXlanguageMsg(generic_desc);

                    if(~rules(itr).Compliance)

                        image=[lower(rules(itr).MaxLevel),'.png'];
                        compliance_str=['&nbsp;&nbsp;<IMG src="',this.ICON_PATH,image,'" ALT="',strrep(image,'.png',''),'" />'];
                        desc=sprintf(['%s <a href=''#%s''>',message('hdlcommon:IndustryStandard:Violations').getString,'</a>'],desc,this.mungeRuleDesc(rules(itr).RuleID));
                    else

                        continue;
                    end
                    fprintf(fid,'<TR><TD><B>%s</B></TD><TD>%s</TD><TD>&nbsp;&nbsp; %s</TD></TR>\n',this.mungeRuleDesc(rules(itr).RuleID),compliance_str,desc);
                end
                fprintf(fid,'</TABLE>\n');
                fprintf(fid,'</div></div></div></div></section><HR />\n');


                [checks,rules]=this.SortByRule();%#ok<ASGLU>
            end


            this.serializeCodingStdOptions(fid,'HTML');


            this.TextReport(txtFID,rules);


            this.GenerateOrderedList();


            hdlcodingstd.HTMLReporter.writeJQueryHTMLcloser(fid);

            fclose(fid);
            fclose(txtFID);


            this.report.complete=true;
            this.report.name=fileName;
            this.report.path=fopenName;

            if~isempty(dir(fullfile(pwd,codegendir,fileName)))
                nameforuser=fullfile(pwd,codegendir,fileName);
            elseif~isempty(dir(fullfile(codegendir,fileName)))
                nameforuser=fullfile(codegendir,fileName);
            else
                error(message('hdlcoder:engine:fullfilenamenotfound'))
            end

            if(showReport&&hasAnError)
                hdlcodingstd.STARCrules.displayOnBrowser(nameforuser);

                if(this.inMLHDLCmode)
                    emlhdlcoder.WorkFlow.Manager.AddWebBrowser(nameforuser);
                else
                    hDrv=hdlcurrentdriver();
                    hDrv.addWebBrowser(nameforuser);
                end
            end
        end


        function genMLfileLinks(this,prjFullName)
            [path,filename,ext]=fileparts(prjFullName);%#ok<ASGLU>
            link=['<a href="matlab:edit(''',prjFullName,''')">',[filename,ext],'</a>'];
            fprintf(this.file_id,'%s',link);
        end


        function genSLblockLinks(this,cblk,chktype)
            fid=this.file_id;
            hilitename=['''',cblk,''''];

            hilitename=strrep(hilitename,newline,' ');


            switch lower(chktype)
            case 'synthetic'
                sep=strfind(hilitename,'/');
                if~isempty(sep)%#ok<STREMP> results of strfind needed below
                    hilitename=[hilitename(1:sep(end)-1),''''];
                end
                fprintf(fid,['<a href="matlab:hilite(get_param(''%s'',''object''),''none'');',...
                'open_system(%s)">%s (synthetic)</a>\n'],...
                get_param(bdroot,'Name'),hilitename,cblk);

            case{'model'}
                fprintf(fid,['<a href="matlab:hilite(get_param(''%s'',''object''),''none'');',...
                'open_system(''%s'')">%s</a>\n'],...
                get_param(bdroot,'Name'),get_param(bdroot,'Name'),cblk);
            otherwise
                fprintf(fid,['<a href="matlab:hilite(get_param(''%s'',''object''),''none'');',...
                'hilite_system(%s)">%s</a>\n'],...
                get_param(bdroot,'Name'),hilitename,cblk);
            end
        end


        function GenerateOrderedList(this)
            rstruct=hdlcodingstd.STARCrules.getCheckedSTARCruleStruct();
            fid=this.file_id;
            fprintf(fid,'<div class="content_container" id="content_container">\n<section><div >\n');
            this.RuleStruct2HTML(rstruct);
            fprintf(fid,'</div></section>\n');
        end


        function RuleStruct2BasicHTML(this,top,depth,tag)
            if(nargin<3),depth=0;end
            if(nargin<4),tag='';end

            fprintf(this.file_id,'%s<UL> %s\n',[repmat('    ',1,depth)],strrep(tag,'a',''));
            remaining=fields(top);
            for itr=1:length(remaining)
                level=remaining{itr};
                a=top.(level);
                if(~isstruct(a))
                    rule=a;
                    desc=this.getRuleDesc(rule);
                    if(this.ruleMap.isKey(rule))
                        fprintf(this.file_id,'%s<LI><B>%s</B> %s</LI>\n',[repmat('    ',1,depth)],rule,desc);%#ok<*NBRAK>
                        fprintf(this.file_id,'<OL>\n');
                        msgs=this.ruleMap(rule);
                        for ind=1:length(msgs)
                            msg=msgs{ind};
                            image=[lower(msg.level),'.png'];
                            fprintf(this.file_id,'<LI><IMG SRC="%s" ALT="%s"/> %s</LI>',[this.ICON_PATH,image],msg.level,this.sanitizeXlanguageMsg(msg.message));
                        end
                        fprintf(this.file_id,'</OL>\n');
                    else
                        fprintf(this.file_id,'%s<LI><IMG SRC="%s" ALT="pass" /><B>%s</B> %s</LI>\n',[repmat('    ',1,depth)],[this.ICON_PATH,'pass.png'],rule,desc);
                    end
                else
                    fprintf(this.file_id,'\n');
                    this.RuleStruct2BasicHTML(a,depth+1,[tag,level,'.']);
                end
            end
            fprintf(this.file_id,'%s</UL>\n',repmat('    ',1,depth));
        end


        function new_rule=mungeRuleDesc(this,rule_in)
            tag_prefix=this.getTagPrefix();
            new_rule=hdlcodingstd.Report.mungeRule(tag_prefix,rule_in);
        end


        function tag_prefix=getTagPrefix(this)
            if(this.inMLHDLCmode)
                tag_prefix='CGML-';
            else
                tag_prefix='CGSL-';
            end
            return
        end

        function is_relevant=isRelevantRule(this,tag_desc_orig)


            tag_regexp=['^',strrep(tag_desc_orig,'.','\.')];

            matches=cellfun(@(x)regexp(x,tag_regexp,'match'),this.ruleMap.keys,'UniformOutput',false);

            is_relevant=any(cellfun(@(x)~isempty(x),matches));

            return;
        end




        function flag=isRelevantSubCategory(this,tag_desc_orig,depth)%#ok<INUSD>



            flag=this.codingStdOptions.isRuleReported(tag_desc_orig);
            rule_violated=this.isRelevantRule(tag_desc_orig);


            if(rule_violated)
                flag=true;
                return;
            end
            if(~this.codingStdOptions.ShowPassingRules.enable)
                flag=rule_violated;
            end



            return
        end



        function RuleStruct2HTML(this,top,depth,tag)
            if(nargin<3),depth=0;end
            if(nargin<4),tag='';end

            tag_desc_orig=strrep(tag,'a','');
            tag_desc=regexprep(tag_desc_orig,'\.+$','');

            if(depth==0)

                fprintf(this.file_id,['<div class="expandableContent"><div class="expand"><h3 itemprop="content">',message('hdlcommon:IndustryStandard:ruleHierarchy').getString,'</h3></div>\n']);
                fprintf(this.file_id,['<div class="switch"><a class="expandAllLink" href="javascript:void(0);">',message('hdlcommon:IndustryStandard:expandAll').getString,'</a></div>\n']);
                fprintf(this.file_id,'<div class="collapse"><div itemprop="content">\n');
            else




                if(~this.isRelevantSubCategory(tag_desc_orig,depth))

                    return;
                end

                msg=this.getRuleDesc(tag_desc);
                if(this.isXlanguageRule(msg))
                    return;
                end

                msg=this.sanitizeXlanguageMsg(msg);
                fprintf(this.file_id,'<div class="expandableContent"><div class="expand"><B itemprop="content">%s &nbsp; %s</B></div>\n',this.mungeRuleDesc(tag_desc_orig),msg);
                fprintf(this.file_id,'<div class="collapse"><div itemprop="content">\n');
            end

            remaining=fields(top);
            for itr=1:length(remaining)
                level=remaining{itr};
                a=top.(level);
                if(~isstruct(a))
                    rule=a;

                    desc=this.sanitizeXlanguageMsg(this.getRuleDesc(rule));
                    if this.ruleMap.isKey(rule)
                        msgs=this.ruleMap(rule);
                        image=[lower(msgs{1}.level),'.png'];
                        severity=hdlcodingstd.STARCrules.getRuleSeverity(rule);
                        fprintf(this.file_id,'<div class="expandableContent"><div class="expand"><B itemprop="content">%s </B> <I>(%s)</I> &nbsp; <a name="%s"><IMG SRC="%s" ALT="%s" /></a>&nbsp; %s</div>\n',this.mungeRuleDesc(rule),severity,this.mungeRuleDesc(rule),[this.ICON_PATH,image],msgs{1}.level,desc);
                        fprintf(this.file_id,'<div class="collapse">\n');

                        for ind=1:length(msgs)
                            msg=msgs{ind};
                            image=[lower(msg.level),'.png'];

                            if(this.inMLHDLCmode)
                                fprintf(this.file_id,'<div itemprop="content"> <IMG SRC="%s" ALT="%s"/> %s &nbsp;\n',[this.ICON_PATH,image],msg.level,msg.message);

                                this.genMLfileLinks(msg.path);
                                fprintf(this.file_id,'</div>');
                            else
                                fprintf(this.file_id,'<div itemprop="content"> <IMG SRC="%s" ALT="%s"/> %s &nbsp;\n',[this.ICON_PATH,image],msg.level,msg.message);

                                this.genSLblockLinks(msg.path,msg.type);
                                fprintf(this.file_id,'</div>');
                            end
                        end
                        fprintf(this.file_id,'</div></div>\n');
                    else

                        if(~this.codingStdOptions.ShowPassingRules.enable)
                            continue;
                        end


                        if(~this.isXlanguageRule(desc))
                            desc=this.sanitizeXlanguageMsg(desc);
                            severity=hdlcodingstd.STARCrules.getRuleSeverity(rule);
                            fprintf(this.file_id,'%s<div><B itemprop="content">%s</B>, <I>(%s)</I>, <IMG SRC="%s" ALT="pass" />&nbsp; %s</div>\n',[repmat('    ',1,depth)],this.mungeRuleDesc(rule),severity,[this.ICON_PATH,'pass.png'],desc);
                        end
                    end
                else
                    fprintf(this.file_id,'\n');
                    this.RuleStruct2HTML(a,depth+1,[tag,level,'.']);
                end
            end
            fprintf(this.file_id,'</div></div></div>\n');
        end

        function TextReport(this,txtFid,rules)

            fprintf(txtFid,'# HDL Coder Industry Standard Report. Manual changes will be over written.\n');
            fprintf(txtFid,'# (C) 2012 The Mathworks, Inc.\n');
            fprintf(txtFid,'# Generated by MATLAB ');
            fprintf(txtFid,'%s',getfield(ver('MATLAB'),'Version'));
            fprintf(txtFid,' and HDL Coder ');
            fprintf(txtFid,'%s',getfield(ver('hdlcoder'),'Version'));
            fprintf(txtFid,' on ');
            fprintf(txtFid,'%s',datestr(now()));
            fprintf(txtFid,'\n');
            fprintf(txtFid,'#\n');
            fprintf(txtFid,'#  -------------------------------------------------------------------\n');
            fprintf(txtFid,'\n');
            fprintf(txtFid,'Industry standard report for %s\n',this.ModelName);
            fprintf(txtFid,'%s\n',this.GetSummary());


            this.serializeCodingStdOptions(txtFid,'TEXT');

            for itr=1:numel(rules)
                desc=this.getRuleDesc(rules(itr).RuleID);

                if(~rules(itr).Compliance)

                    image=[lower(rules(itr).MaxLevel),'.png'];
                    compliance_str=strrep(image,'.png','');
                    desc=sprintf('%s',desc);
                else
                    continue;
                end
                fprintf(txtFid,'\n%s|%s|%s\n',this.mungeRuleDesc(rules(itr).RuleID),compliance_str,desc);

                msgs=this.ruleMap(rules(itr).RuleID);
                for ind=1:length(msgs)
                    msg=msgs{ind};

                    fprintf(txtFid,'\t%s|%s|%s|%s\n',msg.level,msg.type,msg.message,msg.path);
                end
            end
            return
        end







        function rules=getCheckedSTARCrules(this)

            target_lang=this.TargetLanguage;
            STARCruleDesc=containers.Map('KeyType','char','ValueType','char');
            Xmessage=@(x)message([x,'_',upper(target_lang)]).getString();
            Xmessage1=@(x,a)message([x,'_',upper(target_lang)],a).getString();
            Xmessage2=@(x,a,b)message([x,'_',upper(target_lang)],a,b).getString();


            STARCruleDesc('1.1.1.2-3')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_2_3');
            STARCruleDesc('1.1.1.5')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_5');

            STARCruleDesc('1.1.1.9')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_1_9');


            min_max=this.codingStdOptions.ModuleInstanceEntityNameLength.length;
            STARCruleDesc('1.1.2.1')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_2_1',num2str(min_max(1)),num2str(min_max(2)));


            min_max=this.codingStdOptions.SignalPortParamNameLength.length;
            STARCruleDesc('1.1.3.3')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_3_3',num2str(min_max(1)),num2str(min_max(2)));

            STARCruleDesc('1.1.3.3a')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_3_3a',num2str(min_max(1)),num2str(min_max(2)));
            STARCruleDesc('1.1.3.3b')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_3_3b',num2str(min_max(1)),num2str(min_max(2)));
            STARCruleDesc('1.1.3.3d')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_3_3d',num2str(min_max(1)),num2str(min_max(2)));
            STARCruleDesc('1.1.3.3e')=Xmessage2('hdlcommon:IndustryStandard:rule_1_1_3_3e',num2str(min_max(1)),num2str(min_max(2)));

            STARCruleDesc('1.1.4.1')=Xmessage('hdlcommon:IndustryStandard:rule_1_1_4_1');

            condregion_length=this.codingStdOptions.ConditionalRegionCheck.length;
            STARCruleDesc('2.6.2.1')=Xmessage1('hdlcommon:IndustryStandard:rule_2_6_2_1',condregion_length);

            STARCruleDesc('2.6.2.1a')=Xmessage('hdlcommon:IndustryStandard:rule_2_6_2_1a');

            STARCruleDesc('2.3.3.4')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_4');
            STARCruleDesc('2.3.3.5')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_5');
            STARCruleDesc('2.3.3.6')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_3_6');
            STARCruleDesc('2.3.4.1')=Xmessage('hdlcommon:IndustryStandard:rule_2_3_4_1');


            mul_width=this.codingStdOptions.MultiplierBitWidth.width;
            STARCruleDesc('2.10.6.5')=Xmessage1('hdlcommon:IndustryStandard:rule_2_10_6_5',num2str(mul_width));


            ifelse_chain_len=this.codingStdOptions.IfElseChain.length;
            STARCruleDesc('2.7.3.1c')=Xmessage1('hdlcommon:IndustryStandard:rule_2_7_3_1c',num2str(ifelse_chain_len));
            rules=STARCruleDesc;
            return
        end


        function str=getRuleDesc(this,ruleID)



            if(this.STARCrules.Count()==0)

                this.STARCrules=this.getCheckedSTARCrules();



                ucRules=hdlcodingstd.STARCrules.getUnconditionalRules(this.TargetLanguage,this.codingStdOptions);
                keys=ucRules.keys;
                for key_itr=1:ucRules.Count
                    key=keys{key_itr};
                    val=ucRules(key);
                    this.STARCrules(key)=val;
                end


                catRules=hdlcodingstd.STARCrules.getCategoryRules();
                keys=catRules.keys;
                for key_itr=1:catRules.Count
                    key=keys{key_itr};
                    val=catRules(key);
                    this.STARCrules(key)=val;
                end
            end
            ruleID=strrep(ruleID,'_','-');

            if(this.STARCrules.isKey(ruleID))

                str=this.STARCrules(ruleID);
            else
                warning(message('hdlcommon:IndustryStandard:CannotFindRuleID',ruleID));
                str='';
            end

            return
        end

    end
end



