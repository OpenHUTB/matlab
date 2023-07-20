






classdef Checker<handle








    properties(SetAccess=private)
        fromMakeHDL=true;
        CodingStd='';
        targetLang='';
        checks=[];
        hPir=-1;
codingStdOptions
        nameCache=containers.Map('KeyType','char','ValueType','any');
    end

    methods
        function this=set.codingStdOptions(this,value)%#ok<MCHV2>
            assert(isa(value,'hdlcodingstd.IndustryCustomizations'),'codingStdOptions property should be of type hdlcodingstd.IndustryCustomizations')
            this.codingStdOptions=value;
        end
    end

    methods(Access=private)

        function flag=STARC_real_constant_checks(this,block_path)%#ok<INUSL>




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

        function flag=STARC_alnum_reserved_word_check(this,name)




            alpha=['A':'Z','a':'z'];numeric=['0':'9'];%#ok<NBRAK>
            allowed=[alpha,numeric,'_'];
            flag=~any(name(1)==alpha);
            flag=flag||name(end)=='_';
            flag=flag||~isempty(setdiff(name,allowed));
            flag=flag||this.hPir.isReservedWord(name);
            flag=flag||hdlcodingstd.STARCrules.STARC_ckt_words_check(name);

            return;
        end

        function validate=STARC_duplicate_name_check_1o1o1o5(this,blk_name,path_to_sl_block)







            if(~this.codingStdOptions.DetectDuplicateNamesCheck.enable)
                validate=true;
                return
            end

            path_to_parent=path_to_sl_block;
            idx=strfind(path_to_sl_block,'/');
            if(isempty(idx))
                path_to_parent='';
            else
                path_to_parent(idx(end):end)=[];
            end



            full_blk_name=[path_to_parent,'/',lower(blk_name)];





            if(this.nameCache.isKey(full_blk_name))


                validate=false;
            else

                validate=true;
            end



            if(validate)



                if(~this.nameCache.isKey(full_blk_name))
                    this.nameCache(full_blk_name)={path_to_parent};
                    return
                end
            end



            tmp=this.nameCache(full_blk_name);
            this.nameCache(full_blk_name)={path_to_parent,tmp{:}};%#ok<CCAT>
            return
        end


        function chk=ComponentLevelChecks(this,hC)


            if(hdlcodingstd.Checker.checkAnnotation(hC))
                chk=[];
                return;
            end
            nameStr=message('hdlcommon:IndustryStandard:name').getString();
            blockStr=message('hdlcommon:IndustryStandard:block').getString();
            hCname=get_param(hC.SimulinkHandle,'Name');
            comptype=message('hdlcommon:IndustryStandard:block').getString();
            rto=get_param(hC.SimulinkHandle,'Object');
            if(isprop(rto,'BlockType')),comptype=[rto.BlockType,' block'];end

            if(this.codingStdOptions.HDLKeywords.enable&&...
                this.STARC_alnum_reserved_word_check(lower(hCname)))
                checkStruct=this.make_check_struct(getfullname(hC.SimulinkHandle),...
                blockStr,'Warning',[comptype,' ',nameStr,' ''',hCname,''' '],...
                this.CodingStd,'KeywordNameWarning','1.1.1.2-3');
                this.checks=cat(2,this.checks,checkStruct);
            end

            if(strcmpi(this.CodingStd,'STARC'))


                if(this.codingStdOptions.DetectDuplicateNamesCheck.enable&&...
                    ~this.STARC_duplicate_name_check_1o1o1o5((hCname),getfullname(hC.SimulinkHandle)))

                    if(~isprop(hC,'BlockTag')||~strcmpi(hC.BlockTag,'eml_lib/MATLAB Function'))
                        msg=message('hdlcommon:IndustryStandard:nameDup');
                        checkStruct=this.make_check_struct(getfullname(hC.SimulinkHandle),...
                        blockStr,'Warning',[comptype,' ',nameStr,' ''',hCname,''' ',msg.getString()],...
                        this.CodingStd,'DuplicateNameWarning','1.1.1.5');
                        this.checks=cat(2,this.checks,checkStruct);
                    end
                end

                if(strncmpi(comptype,'SubSys',6))

                    min_max=this.codingStdOptions.ModuleInstanceEntityNameLength.length;
                    if(this.codingStdOptions.ModuleInstanceEntityNameLength.enable&&...
                        ~this.STARC_module_name_check_1o1o2o1(lower(hCname),min_max(1),min_max(2)))
                        msg=message('hdlcommon:IndustryStandard:charsLimitNtwkName',num2str(min_max(1)),num2str(min_max(2)));
                        checkStruct=this.make_check_struct(getfullname(hC.SimulinkHandle),...
                        blockStr,'Warning',[comptype,' ',nameStr,' ''',hCname,''' ',msg.getString()],...
                        this.CodingStd,'LengthNameWarning','1.1.2.1');
                        this.checks=cat(2,this.checks,checkStruct);
                    end
                else

                    min_max=this.codingStdOptions.SignalPortParamNameLength.length;
                    if(this.codingStdOptions.SignalPortParamNameLength.enable&&...
                        ~this.STARC_netlistelem_name_check_1o1o3o3(lower(hCname),min_max(1),min_max(2)))
                        msg=message('hdlcommon:IndustryStandard:charsLimitName',num2str(min_max(1)),num2str(min_max(2)));
                        checkStruct=this.make_check_struct(getfullname(hC.SimulinkHandle),...
                        blockStr,'Warning',[comptype,' ',nameStr,' ''',hCname,''' ',msg.getString()],...
                        this.CodingStd,'LengthNameWarning','1.1.3.3');
                        this.checks=cat(2,this.checks,checkStruct);
                    end
                end
            end


            if(isa(hC,'hdlcoder.block_comp'))
                compFullPath=getfullname(hC.SimulinkHandle);











                checksOPports=this.flag_and_check(hC.PirOutputPorts,'Output_Ports',compFullPath,this.CodingStd);
                checksIPports=this.flag_and_check(hC.PirInputPorts,'Input_Ports',compFullPath,this.CodingStd);


                mChecks=[];
                if(strcmpi(hC.BlockTag,'built-in/Product'))
                    if(this.codingStdOptions.MultiplierBitWidth.enable)
                        mulWidth=this.codingStdOptions.MultiplierBitWidth.width;
                        mChecks=hdlcodingstd.STARCrules.multiplier_wl_check_2o10o6o5(hC,mulWidth);
                    end
                end



                if(~this.fromMakeHDL&&this.codingStdOptions.InitialStatements.enable)


                    if(~isempty(regexpi(hC.BlockTag,'Port RAM','match')))
                        origInitializeBlockRAM=hdlgetparameter('initializeBlockRAM');
                        if strcmpi(origInitializeBlockRAM,'on')

                            msg=message('hdlcommon:IndustryStandard:initBlockRAM');
                            msgRAM=struct('path',compFullPath,'type',hCname,'message',msg.getString(),...
                            'level','Error','MessageID','STARCDominantModeWarning','RuleID','2.3.4.1');
                            mChecks=cat(2,mChecks,msgRAM);
                        end
                    end
                end




                if(strcmpi(hC.getImplementationName(),'hdldefaults.ConstantSpecialHDLEmission'))
                    value=hdlget_param(compFullPath,'Value');
                    value=upper(value);
                    if(strcmpi(this.targetLang,'VHDL'))
                        flag=any([strfind(value,'Z'),strfind(value,'X'),strfind(value,'U'),strfind(value,'-'),strfind(value,'W'),strfind(value,'H'),strfind(value,'L')]);
                    else
                        flag=any([strfind(value,'Z'),strfind(value,'X')]);
                    end

                    if flag
                        msg=message('hdlcommon:IndustryStandard:X_or_Z_value');
                        msgRAM=struct('path',compFullPath,'type',hCname,'message',msg.getString(),...
                        'level','Error','MessageID','STARCDominantModeWarning','RuleID','2.10.1.6');
                        mChecks=cat(2,mChecks,msgRAM);
                    end
                end

                this.checks=cat(2,this.checks,checksOPports,checksIPports,mChecks);
            end
            chk=this.checks;
        end


        function chk=STARC_real_signal_checks(this,hN)
            chk=[];




            if(~this.codingStdOptions.NonIntegerTypes.enable||...
                isNativeFloatingPointMode||isTargetFloatingPointMode)
                return;
            end

            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();
            nwName=getfullname(hN.SimulinkHandle);
            if(~hdlcodingstd.STARCrules.STARC_real_signal_checks(hN))
                msg=message('hdlcommon:IndustryStandard:nonSynthFloat');
                chk=this.make_check_struct(nwName,subsysStr,'Error',...
                [msg.getString(),' ''',nwName,''''],this.CodingStd,'FloatingPointWarning','3.2.4.1');
            end
            return
        end

        function chk=STARC_real_constant_filter(this,top_level)
            chk=[];




            if(~this.codingStdOptions.NonIntegerTypes.enable||...
                isNativeFloatingPointMode||isTargetFloatingPointMode)
                return;
            end

            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();



            const_blocks=find_system(top_level,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'blockType','Constant');
            for itr=1:length(const_blocks)
                if(~this.STARC_real_constant_checks(const_blocks{itr}))
                    block_name=get_param(const_blocks{itr},'Name');
                    msg=message('hdlcommon:IndustryStandard:nonSynthFloat');
                    checkStruct=this.make_check_struct(const_blocks{itr},subsysStr,'Error',...
                    [msg.getString(),' ''',block_name,''' '],this.CodingStd,'FloatingPointWarning','3.2.4.1');
                    chk=cat(2,chk,checkStruct);
                end
            end
            return
        end



        function chk=STARC_generic_param_filter(this,hN)
            nwSLhandle=hN.SimulinkHandle;
            chk=[];
            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();
            if(hN.NumberOfPirGenericPorts>0)
                for itr=0:(hN.NumberOfPirGenericPorts-1)
                    gName=hN.getGenericPortName(itr);
                    if(~this.STARC_netlistelem_name_check_1o1o3o3(gName))
                        msg=message('hdlcommon:IndustryStandard:longMaskedParam');
                        checkStruct=this.make_check_struct(getfullname(nwSLhandle),...
                        subsysStr,'Warning',[msg.getString(),', ''',gName,''' '],...
                        this.CodingStd,'LengthNameWarning','1.1.3.3');
                        chk=cat(2,chk,checkStruct);
                    end
                end
            end
        end


        function chk=STARC_entity_architecture_split(this,hN)
            chk=[];
            if hdlgetparameter('split_entity_arch')&&strcmpi(this.targetLang,'VHDL')
                nwSLhandle=hN.SimulinkHandle;

                subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();
                splitmsg=message('hdlcommon:IndustryStandard:splitEntityArchitecture');
                msgSplit=struct('path',getfullname(nwSLhandle),'type',subsysStr,...
                'message',splitmsg.getString(),'level','Warning','MessageID',splitmsg.Identifier,...
                'RuleID','1.1.6.4');
                chk=cat(2,chk,msgSplit);
            end
        end

        function chk=ModelLevelChecks(this,hN)


            realChecks=this.STARC_real_constant_filter(getfullname(hN.SimulinkHandle));
            this.checks=cat(2,this.checks,realChecks);

            realChecks=this.STARC_real_signal_checks(hN);
            this.checks=cat(2,this.checks,realChecks);

            maskChecks=this.STARC_generic_param_filter(hN);
            this.checks=cat(2,this.checks,maskChecks);

            splitChecks=this.STARC_entity_architecture_split(hN);
            this.checks=cat(2,this.checks,splitChecks);

            chk=this.checks;
        end



        function hdl_params_check(this)
            mdlName=this.hPir.ModelName;
            if isempty(mdlName)
                return;
            end
            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();


            if strcmpi(this.targetLang,'VHDL')
                ext=hdlget_param(mdlName,'VHDLFileExtension');


                if~strcmpi(ext,'.vhdl')&&~strcmpi(ext,'.vhd')
                    extmsg=message('hdlcommon:IndustryStandard:fileNameExtension',ext);
                    msgExtension=struct('path',mdlName,'type',subsysStr,...
                    'message',extmsg.getString(),'level','Warning','MessageID',extmsg.Identifier,...
                    'RuleID','1.1.1.1');
                    this.checks=cat(2,this.checks,msgExtension);
                end
            end


            if strcmpi(this.targetLang,'VHDL')
                if strcmpi(hdlget_param(mdlName,'UseRisingEdge'),'on')
                    risingmsg=message('hdlcommon:IndustryStandard:risingEdgeUsage');
                    msgRising=struct('path',mdlName,'type',subsysStr,...
                    'message',risingmsg.getString(),'level','Error','MessageID',risingmsg.Identifier,...
                    'RuleID','2.3.1.9');
                    this.checks=cat(2,this.checks,msgRising);
                end
            end


            if strcmpi(hdlget_param(mdlName,'TriggerAsClock'),'on')
                trasclkmsg=message('hdlcommon:IndustryStandard:triggerasclkUsage');
                msgTriggerAsClk=struct('path',mdlName,'type',subsysStr,...
                'message',trasclkmsg.getString(),'level','Error','MessageID',trasclkmsg.Identifier,...
                'RuleID','3.3.1.1');
                this.checks=cat(2,this.checks,msgTriggerAsClk);
            end
        end

        function chk=TopLevelChecks(this,topNwObj)

            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();

            chk=this.checks;

            if(topNwObj.SimulinkHandle<0)
                return;
            end


            this.hdl_params_check();


            blockName=get_param(topNwObj.SimulinkHandle,'Name');

            if(~this.codingStdOptions.HDLKeywords.enable)
                return;
            end

            if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(blockName))
                msg=message('hdlcommon:IndustryStandard:topPort');
                checkStruct=this.make_check_struct(getfullname(topNwObj.SimulinkHandle),...
                subsysStr,'Warning',[msg.getString(),' ''',blockName,''' '],...
                this.CodingStd,'KeywordNameWarning','1.1.1.9');
                this.checks=cat(2,this.checks,checkStruct);
            end


            for itr=1:numel(topNwObj.PirInputPorts)
                pName=topNwObj.PirInputPorts(itr).Name;
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName))
                    msg=message('hdlcommon:IndustryStandard:topIpPort');
                    checkStruct=this.make_check_struct(getfullname(topNwObj.SimulinkHandle),...
                    subsysStr,'Warning',[msg.getString(),' ''',pName,''' '],...
                    this.CodingStd,'KeywordNameWarning','1.1.1.9');
                    this.checks=cat(2,this.checks,checkStruct);
                end
            end

            for itr=1:numel(topNwObj.PirOutputPorts)
                pName=topNwObj.PirOutputPorts(itr).Name;
                if(~hdlcodingstd.STARCrules.STARC_toplevel_name_check_1o1o1o9(pName))
                    msg=message('hdlcommon:IndustryStandard:topOpPort');
                    checkStruct=this.make_check_struct(getfullname(topNwObj.SimulinkHandle),...
                    subsysStr,'Warning',[msg.getString(),' ''',pName,''''],...
                    this.CodingStd,'KeywordNameWarning','1.1.1.9');
                    this.checks=cat(2,this.checks,checkStruct);
                end
            end

        end


        function chk=NetworkLevelChecks(this,hN)

            hNname=get_param(hN.SimulinkHandle,'Name');
            subsysStr=message('hdlcommon:IndustryStandard:subsystem').getString();
            nameStr=message('hdlcommon:IndustryStandard:subsys').getString();

            if(this.codingStdOptions.HDLKeywords.enable)
                if(this.STARC_alnum_reserved_word_check(lower(hNname)))
                    checkStruct=this.make_check_struct(getfullname(hN.SimulinkHandle),...
                    subsysStr,'Warning',[nameStr,' ''',hNname,''''],...
                    this.CodingStd,'KeywordNameWarning','1.1.1.2-3');
                    this.checks=cat(2,this.checks,checkStruct);
                end
            end

            if(strcmpi(this.CodingStd,'STARC')&&...
                this.codingStdOptions.ModuleInstanceEntityNameLength.enable)


                minNtwkL=this.codingStdOptions.ModuleInstanceEntityNameLength.length(1);
                maxNtwkL=this.codingStdOptions.ModuleInstanceEntityNameLength.length(2);
                if(~this.STARC_module_name_check_1o1o2o1(lower(hNname),minNtwkL,maxNtwkL))
                    msg=message('hdlcommon:IndustryStandard:charsLimitNtwkName',num2str(minNtwkL),num2str(maxNtwkL));
                    checkStruct=this.make_check_struct(getfullname(hN.SimulinkHandle),...
                    subsysStr,'Warning',[nameStr,' ''',hNname,''' ',msg.getString()],...
                    this.CodingStd,'LengthNameWarning','1.1.2.1');
                    this.checks=cat(2,this.checks,checkStruct);
                end
            end


            compFullPath=getfullname(hN.SimulinkHandle);


            nchecksOPports=this.flag_and_check(hN.PirOutputPorts,'Output_Ports',compFullPath,this.CodingStd,subsysStr);
            nchecksIPports=this.flag_and_check(hN.PirInputPorts,'Input_Ports',compFullPath,this.CodingStd,subsysStr);


            nchecksOPsig=this.flag_and_check(hN.PirOutputSignals,'output signal',compFullPath,this.CodingStd,subsysStr);
            nchecksIPsig=this.flag_and_check(hN.PirInputSignals,'input signal',compFullPath,this.CodingStd,subsysStr);
            this.checks=cat(2,this.checks,nchecksOPsig,nchecksIPsig,nchecksOPports,nchecksIPports);

            chk=this.checks;
        end



        function checkIOobjs=flag_and_check(this,PirIOobjs,desc,compFullPath,CodingStd,elem)
            if(nargin<6)
                elem='block';
            end
            checkIOobjs=[];
            if(isempty(PirIOobjs))
                return;
            end

            usableObjs=arrayfun(@(x)isprop(x,'Name'),PirIOobjs,'UniformOutput',false);
            if(isempty(usableObjs))
                return;
            else
                PirIOobjs=PirIOobjs([usableObjs{:}]);
            end




            if(strcmpi(this.CodingStd,'STARC')&&...
                this.codingStdOptions.HDLKeywords.enable)

                flaggedObjs=arrayfun(@(x)this.STARC_alnum_reserved_word_check(lower(x.Name)),...
                PirIOobjs,'UniformOutput',false);
                if(~isempty(flaggedObjs))
                    checkIOobjs=arrayfun(@(x)(this.make_check_struct(compFullPath,[elem,' ''',desc,','''],...
                    'Warning',[desc,' name ''',x.Name,''''],CodingStd,'KeywordNameWarning','1.1.1.2-3')),...
                    PirIOobjs([flaggedObjs{:}]).');
                end
            end

            if(strcmpi(this.CodingStd,'STARC')&&...
                this.codingStdOptions.DetectDuplicateNamesCheck.enable)





                flaggedObjs=arrayfun(@(x)(~this.STARC_duplicate_name_check_1o1o1o5([compFullPath,'/',x.Name,'/',desc],compFullPath)),...
                PirIOobjs,'UniformOutput',false);
                if(~isempty(flaggedObjs))
                    checkIOobjs2=arrayfun(@(x)(this.make_check_struct(compFullPath,[elem,' ''',desc,','''],...
                    'Warning',[desc,' name ''',x.Name,...
                    ''' ',message('hdlcommon:IndustryStandard:nameDup').getString(),' '],...
                    CodingStd,'DuplicateNameWarning','1.1.1.5')),...
                    PirIOobjs(find([flaggedObjs{:}])).');%#ok<FNDSB> %transpose to concat correctly
                    checkIOobjs=cat(2,checkIOobjs2,checkIOobjs);
                end
            end

            if(strcmpi(this.CodingStd,'STARC')&&...
                this.codingStdOptions.SignalPortParamNameLength.enable)

                min_max=this.codingStdOptions.SignalPortParamNameLength.length;
                flaggedObjs=arrayfun(@(x)(~this.STARC_netlistelem_name_check_1o1o3o3(lower(x.Name),min_max(1),min_max(2))),...
                PirIOobjs,'UniformOutput',false);
                if(~isempty(flaggedObjs))
                    checkIOobjs2=arrayfun(@(x)(this.make_check_struct(compFullPath,[elem,' ''',desc,','''],...
                    'Warning',[desc,' name ''',x.Name,''' ',message('hdlcommon:IndustryStandard:charsLimitName',num2str(min_max(1)),num2str(min_max(2))).getString()],...
                    CodingStd,'LengthNameWarning','1.1.3.3')),...
                    PirIOobjs([flaggedObjs{:}]).');
                    checkIOobjs=cat(2,checkIOobjs2,checkIOobjs);
                end
            end

        end
    end


    methods

        function obj=Checker(hPir,codingStdEnum,codingStdOptions,targetLang,calledFromMakeHDL)
            if(nargin<5)
                calledFromMakeHDL=true;
            end






            if(ischar(codingStdEnum))
                assert(strcmpi(codingStdEnum,'INDUSTRY'));
            else
                assert(codingStdEnum==2);
            end

            obj.targetLang=targetLang;
            obj.nameCache=containers.Map('KeyType','char','ValueType','any');




            if(ischar(codingStdEnum))
                langStd=codingStdEnum;
            else
                CodingStandardNames={targetLang,'STARC'};
                langStd=CodingStandardNames{codingStdEnum};
            end
            obj.CodingStd=langStd;
            obj.codingStdOptions=codingStdOptions;
            obj.fromMakeHDL=calledFromMakeHDL;
            obj.hPir=hPir;
            obj.checks=[];
        end

        function mChecks=checkMultiplierFromMATLAB(this,script_path)
            mChecks=[];
            if(this.codingStdOptions.MultiplierBitWidth.enable)
                mulWidth=this.codingStdOptions.MultiplierBitWidth.width;

                topNet=this.hPir.getTopNetwork();
                L=length(topNet.Components());

                for itr=1:L
                    hC=topNet.Components(itr);


                    if(~isa(hC,'hdlcoder.eml_comp'))
                        continue;
                    end
                    if(~strcmp(hC.IpFileName,'hdleml_product'))
                        continue;
                    end

                    outType=hC.PirOutputSignals(1).Type;


                    if(outType.isArrayType||outType.isComplexType)
                        outType=outType.getLeafType;
                    end

                    if(outType.isWordType&&outType.WordLength>=mulWidth)
                        mname=hC.Name;
                        mChecks=[mChecks,hdlcodingstd.STARCrules.ml_make_check_struct(script_path,'','multiplier','Error',...
                        [' ''',mname,''''],'Industry','LargeMultiplierWarning','2.10.6.5',num2str(mulWidth))];%#ok<AGROW>
                    end
                end
            end
        end


        function rval=checkCodingStandardFromMATLAB(this,script_path)
            rval=this.checkCodingStandard();
            mChecks=this.checkMultiplierFromMATLAB(script_path);
            rval=[rval,mChecks];
            return;
        end


        function rval=checkCodingStandard(this)

            this.checks=[];
            rval=[];

            if(this.codingStdOptions.ModuleInstanceEntityNameLength.enable)

                this.TopLevelChecks(this.hPir.getTopNetwork);
            end

            try
                vNetworks=this.hPir.Networks;
            catch

                return;
            end
            numNetworks=length(vNetworks);
            for ii=1:numNetworks
                hN=vNetworks(ii);

                if hN.SimulinkHandle>0


                    this.NetworkLevelChecks(hN);


                    this.ModelLevelChecks(hN);

                    vComps=hN.Components;
                    numComps=length(vComps);
                    for jj=1:numComps
                        hC=vComps(jj);

                        if hC.SimulinkHandle>0

                            this.ComponentLevelChecks(hC);
                        end
                    end
                end
            end
            rval=this.checks;
        end
    end

    methods(Static)


        function validate=STARC_module_name_check_1o1o2o1(name,minLen,maxLen)



            if(nargin<3)
                maxLen=32;
            end
            if(nargin<2)
                minLen=2;
            end

            assert(maxLen>minLen,'Maximum is less-or-equal-to than minimum')
            assert(minLen>0,'Minimum Length is not positive')

            validate=false;
            nl=length(name);
            if(nl>=minLen&&nl<=maxLen),validate=true;end
            return
        end

        function validate=STARC_netlistelem_name_check_1o1o3o3(name,minLen,maxLen)



            if(nargin<3)
                maxLen=40;
            end
            if(nargin<2)
                minLen=2;
            end
            assert(maxLen>minLen,'Maximum is less-or-equal-to than minimum')
            assert(minLen>0,'Minimum Length is not positive')

            validate=false;
            nl=length(name);
            if(nl>=minLen&&nl<=maxLen),validate=true;end
            return
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
    end

end




