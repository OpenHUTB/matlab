












classdef STARCrules


    methods(Static,Access=public)

        function name=STARC_toplevel_fixupName(name_in)

            if(~strcmp(name_in,lower(name_in))&&~strcmp(name_in,upper(name_in)))
                name=lower(name_in);
            else
                name=name_in;
            end


            if(length(name)>14)
                name=name(1:14);
            elseif(length(name)<2)
                name=[name,name];
            end
            return
        end


        function checks=multiplier_wl_check_2o10o6o5(hC,mulWidth)
            if(nargin<2)
                mulWidth=16;
            end
            checks=[];
            if(~strcmpi(hC.BlockTag,'built-in/Product'))
                return;
            end

            outType=hC.PirOutputSignals(1).Type;


            if(outType.isArrayType||outType.isComplexType)
                outType=outType.getLeafType;
            end

            if(outType.isWordType&&outType.WordLength>=mulWidth)
                mname=hC.Name;
                checks=hdlcodingstd.STARCrules.ml_make_check_struct(getfullname(hC.SimulinkHandle),'','multiplier','Error',[' ''',mname,''''],'Industry','LargeMultiplierWarning','2.10.6.5',num2str(mulWidth));
            end
            return
        end

        function chk=checkMLTopLevelNetwork(topScriptFullPath,minNtwkL,maxNtwkL)

            chk=[];
            mt=mtree(topScriptFullPath,'-file');
            list_of_fns=strings(Fname(mt));
            assert(length(list_of_fns)>=1);
            top_fun=mtfind(mt,'Fun',list_of_fns{1});
            top_fun_name=strings(top_fun);
            top_fun_name=top_fun_name{1};
            [input_args,output_args]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(topScriptFullPath,mt.root);
            pos=lineno(mt.root);


            if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(top_fun_name,minNtwkL,maxNtwkL))
                chk=cat(2,chk,...
                hdlcodingstd.STARCrules.ml_make_check_struct(topScriptFullPath,pos,'function','Warning',[' ',message('hdlcommon:IndustryStandard:toplevelName').getString,' ''',top_fun_name,''''],'Industry','KeywordNameWarning','1.1.1.9'));
            end

            for itr=1:length(input_args)
                pName=input_args{itr};
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName,minNtwkL,maxNtwkL))
                    chk=cat(2,chk,...
                    hdlcodingstd.STARCrules.ml_make_check_struct(topScriptFullPath,pos,'function','Warning',[' ',message('hdlcommon:IndustryStandard:toplevelFName').getString,' ''',pName,''''],'Industry','KeywordNameWarning','1.1.1.9'));
                end
            end


            for itr=1:length(output_args)
                pName=output_args{itr};
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName,minNtwkL,maxNtwkL))
                    chk=cat(2,chk,...
                    hdlcodingstd.STARCrules.ml_make_check_struct(topScriptFullPath,pos,'function','Warning',[' ',message('hdlcommon:IndustryStandard:toplevelFopName').getString,' ''',pName,''''],'Industry','KeywordNameWarning','1.1.1.9'));
                end
            end
            return
        end




        function fixupSimulinkTopLevelNetwork(topNwObj,isMLHDLC)
            if(nargin<2),isMLHDLC=false;end
            if(~islogical(isMLHDLC)),isMLHDLC=strcmpi(isMLHDLC,'MLHDLC');end %#ok<NASGU>



            assert(isa(topNwObj,'hdlcoder.network'))



            pos=strfind(topNwObj.Name,'/');
            if(~isempty(pos))
                pos=pos(end);
                blockName=topNwObj.Name(pos+1:end);%#ok<NASGU>
            else
                blockName=topNwObj.Name;%#ok<NASGU>
            end



            nameService=coder.internal.lib.DistinctNameService();


            for itr=1:numel(topNwObj.PirInputPorts)
                pName=topNwObj.PirInputPorts(itr).Name;
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName))
                    newName=hdlcodingstd.STARCrules.STARC_toplevel_fixupName(pName);
                else
                    newName=pName;
                end
                topNwObj.PirInputPorts(itr).Name=nameService.distinguishName(lower(newName));
            end

            for itr=1:numel(topNwObj.PirOutputPorts)
                pName=topNwObj.PirOutputPorts(itr).Name;
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName))
                    newName=hdlcodingstd.STARCrules.STARC_toplevel_fixupName(pName);
                else
                    newName=pName;
                end
                topNwObj.PirOutputPorts(itr).Name=nameService.distinguishName(lower(newName));
            end

            return;
        end


        function flag=STARC_real_signal_checks(hN)
            flag=false;
            for itr=1:length(hN.PirInputSignals)
                flag=flag|(hN.PirInputSignals(itr).Type.isFloatType);
            end
            for itr=1:length(hN.PirOutputSignals)
                flag=flag|(hN.PirOutputSignals(itr).Type.isFloatType);
            end
            flag=~flag;
            return
        end

        function flag=STARC_real_constant_checks_SL(block_path)


            flag=false;
            r=get_param(block_path,'Object');s=r.RuntimeObject;
            if(strcmpi(s.RuntimePrm(1).Name,'Value'))
                if(isfloat(s.RuntimePrm(1).Data))
                    flag=false;
                elseif(isfi(s.RuntimePrm(1).Data)&&~strcmpi(s.RuntimePrm(1).Data.DataType,'Fixed'))
                    flag=false;
                else

                    flag=true;
                end
            end
            return
        end

        function flag=STARC_real_constant_checks_ML(val)


            flag=isfi(val)&&~strcmpi(val.DataType,'Fixed');
            return
        end

        function flag=STARC_ckt_words_check(name)


            name=lower(name);
            p=pir();
            flag=p.isReservedWordInLang(name,'CKT');
            return
        end

        function flag=STARC_alnum_reserved_word_check(name)




            alpha=['A':'Z','a':'z'];numeric=['0':'9'];%#ok<NBRAK>
            allowed=[alpha,numeric,'_'];
            flag=~any(name(1)==alpha);
            flag=flag||name(end)=='_';
            flag=flag||~isempty(setdiff(name,allowed));
            flag=flag||hdlcodingstd.HDLKeywords.check_ReservedWord(name);


            return;
        end


        function validate=STARC_module_name_check_1o1o2o1(name)


            validate=false;
            nl=length(name);
            if(nl>=2&&nl<=32),validate=true;end
            return
        end


        function validate=STARC_netlistelem_name_check_1o1o3o3(name)


            validate=false;
            nl=length(name);
            if(nl>=2&&nl<=40),validate=true;end
            return
        end

        function flag=STARC_toplevel_name_check_1o1o1o9(blockName,minNtwkL,maxNtwkL)
            if(nargin<2)
                minNtwkL=2;
            end
            if(nargin<3)
                maxNtwkL=16;
            end


            flag=(strcmp(blockName,lower(blockName)))||(strcmp(blockName,upper(blockName)));

            flag=flag&&(length(blockName)<=maxNtwkL)&&(length(blockName)>=minNtwkL);
            return;
        end

        function s=ml_make_check_struct(path,pos,type,level,msgstr,CodingStd,catalogID,RuleID,varargin)%#ok<INUSL>
            args={['hdlcommon:hdlcommon:',catalogID],strrep(CodingStd,'STARC','Industry'),msgstr};
            args={args{:},varargin{:}};%#ok<CCAT>
            msg=message(args{:});

            s=struct('path',path,'type',type,'message',msg.getString(),...
            'level',level,'MessageID',msg.Identifier,'RuleID',RuleID);
            return;
        end

        function s=make_check_struct(path,type,level,msgstr,CodingStd,catalogID,RuleID)

            if(nargin<6)
                catalogID='KeywordNameWarning';
            end
            if(nargin<7)
                RuleID='0.0.0.0';
            end
            msg=message(['hdlcommon:hdlcommon:',catalogID],strrep(CodingStd,'STARC','Industry'),msgstr);
            s=struct('path',path,'type',type,'message',msg.getString(),...
            'level',level,'MessageID',msg.Identifier,'RuleID',RuleID);
            return;
        end


        function flag=checkAnnotation(hC)
            obj=get_param(hC.SimulinkHandle,'object');

            flag=isprop(obj,'Type')&&strcmpi(obj.Type,'annotation');
            return
        end



        function severity=getRuleSeverity(ruleID)
            origRuleID=strrep(ruleID,'-','_');
            origRuleID=strrep(origRuleID,'.','_');

            severity=message(['hdlcommon:IndustryStandard:severity_',origRuleID]).getString();

            severity=lower(severity);
            return
        end

        function rules=getCategoryRules()
            rules=hdlcodingstd.RuleHierarchy.getCategoryRules();
        end



        function rules=getUnconditionalRules(target_lang,codingStdOptions)
            rules=hdlcodingstd.RuleHierarchy.getUnconditionalRules(target_lang,codingStdOptions);
            return
        end








        function rules=getCheckedSTARCruleStruct()
            rules=hdlcodingstd.RuleHierarchy.getCheckedSTARCruleStruct();
            return
        end




        function chk=find_and_flag_while_break_cont_ret_parfor_stmts(ml_script,blkPath_or_scriptname,fromMLHDLC)

            if(nargin<3)
                fromMLHDLC=false;
            elseif(~islogical(fromMLHDLC))
                fromMLHDLC=any(strcmpi('MLHDLC',fromMLHDLC));
            end

            chk=[];
            mt=mtree(ml_script);

            function mtfind_and_addcheck(kw_type)
                q.(kw_type)=mt.find('Kind',kw_type);
                if(~isempty(q.(kw_type)))
                    p=q.(kw_type).indices();
                    for itr=1:length(p)
                        r=mt.select(p(itr));
                        [line_no,col_no]=r.pos2lc(r.position());
                        msg=message('hdlcommon:hdlcommon:GOTOLikeKeyWordsFound',regexprep(r.tree2str(),'(\n)+$',''),num2str(line_no),num2str(col_no),blkPath_or_scriptname).getString();
                        if(fromMLHDLC)
                            message_level=0;
                            chk_kw=struct('message',msg,'MessageID','hdlcommon:hdlcommon:GOTOLikeKeyWordsFound',...
                            'lineNum',line_no,'colNum',col_no,'fileName',blkPath_or_scriptname,'level',message_level);
                        else

                            chk_kw=struct('path',blkPath_or_scriptname,'level','Message','type','model',...
                            'message',msg,...
                            'MessageID','hdlcommon:hdlcommon:hdlcommon:GOTOLikeKeyWordsFound');

                        end
                        chk=cat(2,chk,chk_kw);
                    end
                end
            end
            cellfun(@mtfind_and_addcheck,{'WHILE','BREAK','CONTINUE','RETURN','PARFOR'});
        end





        function displayOnBrowser(nameforuser)


            import matlab.internal.lang.capability.Capability;
            if Capability.isSupported(Capability.LocalClient)

                web(['file://',nameforuser],'-browser');
            else

                hdlcoder.report.openDdg(['file://',nameforuser]);
            end
            return
        end
    end
end
