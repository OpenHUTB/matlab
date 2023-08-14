classdef XSGBBoxDriver<handle



    properties(Access=protected)
        hHDLDriver;
        hTopFunctionName;
        hTopScriptName;
        hEMLHDLConfig;
    end

    methods(Abstract)
        checkLicense(~);
        transferSettings(~,xsgMdl,hdlCfg,varargin)
    end


    methods

        function sanityCheck(~,cgInfo)

            if(~strcmpi(cgInfo.codegenSettings.ClockInputPort,'clk')||...
                ~strcmpi(cgInfo.codegenSettings.ClockEnableInputPort,'ce'))
                error(message('hdlcoder:matlabhdlcoder:clkcenameforXSG'));
            end

            if(~strcmpi(cgInfo.codegenSettings.EnableRate,'DutBaseRate'))
                error(message('hdlcoder:matlabhdlcoder:dutbaserateforXSG'));
            end
        end


        function doIt(this,cgInfo)

            if(~this.checkLicense)
                return;
            end

            this.sanityCheck(cgInfo);

            topName=cgInfo.topName;
            xsgFcnName=[topName,'_xsgbbxcfg'];
            xsgMdlName=[topName,'_xsgbbx'];

            [inDataPortInfo,outDataPortInfo,clkPortInfo,cePortInfo]=this.getDataPortInfo(cgInfo);
            this.genXSGBBoxConfig(cgInfo,inDataPortInfo,outDataPortInfo,clkPortInfo,cePortInfo,xsgFcnName,this.hHDLDriver.cgInfo.baseRateScaling);

            this.genXSGBBoxModel(xsgFcnName,xsgMdlName,cgInfo,inDataPortInfo,outDataPortInfo,this.hHDLDriver.cgInfo.baseRateScaling);
        end


        function[inDataPortInfo,outDataPortInfo,clkPortInfo,cePortInfo]=getDataPortInfo(~,codeGenInfo)
            inportIdx=find(strcmpi({codeGenInfo.hdlDutPortInfo.Direction},'input'));
            inportKind={codeGenInfo.hdlDutPortInfo(inportIdx).Kind};
            clkIdx=find(strcmpi(inportKind,'clock'));
            assert(length(clkIdx)<=1);

            clkIdx=inportIdx(clkIdx);

            ceIdx=find(strcmpi(inportKind,'clock_enable'));
            assert(length(ceIdx)<=1);

            ceIdx=inportIdx(ceIdx);

            inportIdx=setdiff(inportIdx,clkIdx);
            inportIdx=setdiff(inportIdx,ceIdx);

            inDataPortInfo=codeGenInfo.hdlDutPortInfo(inportIdx);
            clkPortInfo=codeGenInfo.hdlDutPortInfo(clkIdx);
            cePortInfo=codeGenInfo.hdlDutPortInfo(ceIdx);

            outportIdx=strcmpi({codeGenInfo.hdlDutPortInfo.Direction},'output');
            outDataPortInfo=codeGenInfo.hdlDutPortInfo(outportIdx);
        end


        function genXSGBBoxModel(this,xsgFcnName,xsgMdlName,cgInfo,inDataPortInfo,outDataPortInfo,baseRateScalingFactor)
            try
                new_system(xsgMdlName);
            catch me
                if(isequal(me.identifier,'Simulink:Commands:NewSysAlreadyExists'))
                    error(message('hdlcoder:matlabhdlcoder:mdlopenforXSG',xsgMdlName));
                else
                    rethrow(me);
                end
            end
            curPath=pwd;
            cd(this.hHDLDriver.hdlGetCodegendir);
            open_system(xsgMdlName);

            gatewayinHandles=zeros(size(inDataPortInfo));
            for i=1:length(inDataPortInfo)
                [status,~,pv]=this.sl2xlType(inDataPortInfo(i).TypeInfo);
                if(~isempty(status))
                    error(message('hdlcoder:matlabhdlcoder:porttypeforXSG',inDataPortInfo(i).Name,status.getString()));
                end
                slHandle=add_block('xbsIndex_r4/Gateway In',[xsgMdlName,'/',inDataPortInfo(i).Name],pv{:},'period',num2str(baseRateScalingFactor));
                gatewayinHandles(i)=slHandle;
            end

            gatewayoutHandles=zeros(size(outDataPortInfo));
            for i=1:length(outDataPortInfo)
                slHandle=add_block('xbsIndex_r4/Gateway Out',[xsgMdlName,'/',outDataPortInfo(i).Name],'inherit_from_input','on');
                gatewayoutHandles(i)=slHandle;
            end

            inPortHandles=zeros(size(inDataPortInfo));
            for i=1:length(inDataPortInfo)
                nt=numerictype(inDataPortInfo(i).TypeInfo.sltype);
                slHandle=add_block('built-in/Inport',[xsgMdlName,'/in',num2str(i)],'MakeNameUnique','on','OutDataTypeStr',nt.tostring());
                inPortHandles(i)=slHandle;
            end

            outPortHandles=zeros(size(outDataPortInfo));
            for i=1:length(outDataPortInfo)
                slHandle=add_block('built-in/Outport',[xsgMdlName,'/out',num2str(i)],'MakeNameUnique','on');
                outPortHandles(i)=slHandle;
            end

            bbxHandle=add_block('xbsIndex_r4/Black Box',[xsgMdlName,'/Black Box'],'init_code',xsgFcnName);
            emlhdlcoder.Driver.SimulinkUtilDriver.formatBlockWithPorts(gatewayinHandles,gatewayoutHandles,bbxHandle);
            pos=get_param(bbxHandle,'Position');
            left=pos(1);top=pos(4)+30;
            pos1=[left,top,left+50,top+50];
            xsgTokenHandle=add_block('xbsIndex_r4/ System Generator',[xsgMdlName,'/ System Generator'],'position',pos1);
            xlSetupGUI(xsgTokenHandle);
            fighdl=xlfindsysgenfig(xsgTokenHandle);
            xlSaveBlockInfo(xsgTokenHandle,fighdl);
            close(fighdl);

            sysGenSubsysPath=emlhdlcoder.Driver.SimulinkUtilDriver.ctrl_G(xsgMdlName,[bbxHandle,gatewayinHandles,gatewayoutHandles,xsgTokenHandle]);
            emlhdlcoder.Driver.SimulinkUtilDriver.formatBlockWithPorts(inPortHandles,outPortHandles,get_param(sysGenSubsysPath,'Handle'));
            sysGenSubsysHandle=get_param(sysGenSubsysPath,'Handle');
            set_param(sysGenSubsysPath,'Name','SysGenSubSystem');
            topDutPath=emlhdlcoder.Driver.SimulinkUtilDriver.ctrl_G(xsgMdlName,sysGenSubsysHandle);
            set_param(topDutPath,'Name','DUT');
            hdlsetup(xsgMdlName);

            this.transferSettings(xsgMdlName,cgInfo.codegenSettings,xsgTokenHandle);

            save_system(xsgMdlName);
            cd(curPath);

        end


        function genXSGBBoxConfig(this,codeGenInfo,inDataPortInfo,outDataPortInfo,clkPortInfo,cePortInfo,xsgFcnName,baseRateScalingFactor)

            tDir=this.hHDLDriver.hdlGetCodegendir;
            confFileName=fullfile(tDir,xsgFcnName);

            fstr=sprintf('\n function %s(this_block)',xsgFcnName);
            fstr=sprintf('%s\n %% Set target language',fstr);
            fstr=sprintf('%s\n this_block.setTopLevelLanguage(''%s'');',fstr,codeGenInfo.codegenSettings.TargetLanguage);
            fstr=sprintf('%s\n %% Set top entity name',fstr);
            fstr=sprintf('%s\n this_block.setEntityName(''%s'');',fstr,codeGenInfo.topName);


            fstr=sprintf('%s\n %% Set the combinational flag',fstr);
            fstr=sprintf('%s\n this_block.tagAsCombinational;',fstr);



            fstr=sprintf('%s\n %% Set inport names',fstr);
            for i=1:length(inDataPortInfo)
                portName=inDataPortInfo(i).Name;
                fstr=sprintf('%s\n this_block.addSimulinkInport(''%s'');',fstr,portName);
            end



            fstr=sprintf('%s\n %% Set outport names and types',fstr);
            for i=1:length(outDataPortInfo)
                port=outDataPortInfo(i);
                portName=port.Name;
                fstr=sprintf('%s\n this_block.addSimulinkOutport(''%s'');',fstr,portName);
                portObjName=[portName,'_obj'];
                fstr=sprintf('%s\n %s = this_block.port(''%s'');',fstr,portObjName,portName);


                [status,portType]=this.sl2xlType(port.TypeInfo);
                if(~isempty(status))
                    error(message('hdlcoder:matlabhdlcoder:porttypeforXSG',portName,status.getString()));
                end
                fstr=sprintf('%s\n %s.setType(''%s'');',fstr,portObjName,portType);
                portWidth=port.TypeInfo.wordsize;
                if(portWidth==1)
                    fstr=sprintf('%s\n this_block.port(''%s'').useHDLVector(false);',fstr,portName);
                end
            end


            fstr=sprintf('%s\n %% Set inport types and types are known',fstr);
            fstr=sprintf('%s\n if (this_block.inputTypesKnown)',fstr);
            for i=1:length(inDataPortInfo)
                port=inDataPortInfo(i);
                portName=port.Name;
                portWidth=port.TypeInfo.wordsize;
                fstr=sprintf('%s\n\t if(this_block.port(''%s'').width ~= %d)',fstr,portName,portWidth);
                fstr=sprintf('%s\n\t\t this_block.setError(''Input data type for port "%s" must have width = %d.'');',fstr,portName,portWidth);
                fstr=sprintf('%s\n\t end',fstr);

                if(portWidth==1)
                    fstr=sprintf('%s\n\t this_block.port(''%s'').useHDLVector(false);',fstr,portName);
                end
            end
            fstr=sprintf('%s\n end',fstr);


            if(~isempty(clkPortInfo)&&~isempty(cePortInfo))
                fstr=sprintf('%s\n % Set the single rate flag',fstr);
                fstr=sprintf('%s\n if (this_block.inputRatesKnown)',fstr);
                fstr=sprintf('%s\n\t setup_rates(this_block,''%s'',''%s'', %d);',fstr,clkPortInfo.Name,cePortInfo.Name,baseRateScalingFactor);
                fstr=sprintf('%s\n end',fstr);
            end


            fstr=sprintf('%s\n %%s Add HDL files',fstr);
            for i=1:length(codeGenInfo.listOfGeneratedFiles)
                fstr=sprintf('%s\n this_block.addFile(''%s'');',fstr,fullfile(codeGenInfo.targetDir,codeGenInfo.listOfGeneratedFiles{i}));
            end


            setup_rates=['% ------------------------------------------------------------',10,...
            'function setup_rates(block,clkname,cename,upsamplerate) ',10,...
            'inputRates = block.inputRates; ',10,...
            'uniqueInputRates = unique(inputRates); ',10,...
            'if (length(uniqueInputRates)==1 & uniqueInputRates(1)==Inf) ',10,...
            '    block.addError(''The inputs to this block cannot all be constant.''); ',10,...
            '    return; ',10,...
            'end ',10,...
            'if (uniqueInputRates(end) == Inf) ',10,...
            '    hasConstantInput = true; ',10,...
            '    uniqueInputRates = uniqueInputRates(1:end-1); ',10,...
            'end ',10,...
            'if (length(uniqueInputRates) ~= 1) ',10,...
            '    block.addError(''The inputs to this block must run at a single rate.''); ',10,...
            '    return; ',10,...
            'end ',10,...
            'theInputRate = uniqueInputRates(1); ',10,...
            'for i = 1:block.numSimulinkOutports ',10,...
            '    block.outport(i).setRate(theInputRate); ',10,...
            'end ',10,...
            'block.addClkCEPair(clkname,cename,theInputRate/upsamplerate); ',10,...
            'return; ',10,...
            10,...
            '% ------------------------------------------------------------',10,...
            ];

            fstr=sprintf('%s\n%s',fstr,setup_rates);
            this.str2file(fstr,[confFileName,'.m']);
        end


        function str2file(~,str,filename)
            fid=fopen(filename,'w+');

            if fid==-1
                error(message('hdlcoder:matlabhdlcoder:configfileopenerrorforXSG',filename));
            end
            fprintf(fid,'%s',str);
            fclose(fid);
        end


        function[status,xlType,pv]=sl2xlType(~,typeInfo)

            status='';
            xlType='';
            pv={};



            if(~typeInfo.isscalar)
                status=message('hdlcoder:matlabhdlcoder:porttypeforXSG1');
                return;
            end

            if(typeInfo.issingle||typeInfo.isdouble)
                status=message('hdlcoder:matlabhdlcoder:porttypeforXSG2');
                return;
            end

            if(strcmpi(typeInfo.sltype,'boolean'))
                xlType='UFix_1_0';
                pv={'arith_type','Boolean'};
                return;
            end

            if(typeInfo.binarypoint>0)
                status=message('hdlcoder:matlabhdlcoder:porttypeforXSG3',typeInfo.sltype);
                return;
            else
                if(typeInfo.wordsize<-typeInfo.binarypoint)
                    status=message('hdlcoder:matlabhdlcoder:porttypeforXSG4',num2str(-typeInfo.binarypoint),num2str(typeInfo.wordsize),typeInfo.sltype);
                    return;
                end
                if(typeInfo.issigned)
                    xlType=sprintf('Fix_%d_%d',typeInfo.wordsize,-typeInfo.binarypoint);
                    pv={'arith_type','Signed  (2''s comp)'};
                else
                    xlType=sprintf('UFix_%d_%d',typeInfo.wordsize,-typeInfo.binarypoint);
                    pv={'arith_type','Unsigned'};
                end

                pv={pv{:},'n_bits',num2str(typeInfo.wordsize),'bin_pt',num2str(-typeInfo.binarypoint)};
            end
        end
    end
end





