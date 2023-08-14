function dpigenerator_generateSVComponent(dpiModuleName,CodeGenObj)

    try

        svFile=fullfile(pwd,[dpiModuleName,'.sv']);

        genSV=dpig.internal.GenSVCode(svFile);

        dpigenerator_disp(['Generating SystemVerilog module ',dpigenerator_getfilelink(svFile)]);
        if hdlverifierfeature('IS_CODEGEN_FOR_UVM')


            genSV.appendCode('//%FL_BANNER%');
        else
            genSV.addGeneratedBy('// ');
            genSV.appendCode('`timescale 1ns / 1ns');
        end
        genSV.addNewLine;

        genSV.appendCode(dpig.internal.GetSVFcn.getPackageCode('Import',...
        [dpiModuleName,dpig.internal.GetSVFcn.getPackageFileSuffix()]));


        if hdlverifierfeature('IS_CODEGEN_FOR_UVM')
            genSV.appendCode(CodeGenObj.getImportCommonTypesPkg());
        end

        genSV.addNewLine;

        genSV.appendMultiLineCode(CodeGenObj.DeclarePortsInterface);

        genSV.addNewLine;

        genSV.appendCode(['module ',dpiModuleName,'(']);
        genSV.addIndent;
        genSV.appendMultiLineCode(CodeGenObj.getPortDeclList);

        if strcmpi(genSV.mText(end),',')
            genSV.mText(end)=[];
        end
        genSV.reduceIndent;
        genSV.appendCode(');')
        genSV.addNewLine;

        genSV.addIndent;
        genSV.appendCode('chandle objhandle=null;');

        genSV.appendCode(CodeGenObj.getAssertionInfoStructDeclaration());

        genSV.appendCode(CodeGenObj.getOutputTempVarDecl());

        genSV.appendCode(CodeGenObj.getTSVerifyInfoStructDeclaration());
        if~isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')

            genSV.appendCode(CodeGenObj.getTestPointVarDecl())
        end


        genSV.addNewLine;

        genSV.appendCode('initial begin');
        genSV.addIndent;

        genSV.appendCode(CodeGenObj.getInitializeFcnCall());
        genSV.appendCode(CodeGenObj.getTSVerifyInfoInstantiation('ModuleName',dpiModuleName));
        if strcmpi(CodeGenObj.mCodeInfo.ComponentTemplateType,'combinational')

            genSV.appendCode(CodeGenObj.getOutputFcnCall());
            genSV.appendCode(CodeGenObj.getNBVarAssignmentFromTmpToActual());

            genSV.appendCode(CodeGenObj.getAssertionQueryingSVCode());
            genSV.appendCode(CodeGenObj.getTSVerifyQueryingSVCode());
            genSV.appendCode(CodeGenObj.getAccessTestPointFcnCall());
        end
        genSV.reduceIndent;
        genSV.appendCode('end');
        genSV.addNewLine;

        genSV.appendCode('final begin');
        genSV.addIndent;
        genSV.appendCode(CodeGenObj.getTSVerifyInfoReporting());

        genSV.appendCode(CodeGenObj.getTerminateFcnCall());
        if isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')
            genSV.appendCode(CodeGenObj.destroySVOpenArrOutput());
        end
        genSV.reduceIndent;
        genSV.appendCode('end');
        genSV.addNewLine;


        genSV.appendCode(CodeGenObj.getAlwaysEventExpressionDecl());
        genSV.addIndent;

        if~hdlverifierfeature('IS_CODEGEN_FOR_UVM')&&strcmpi(CodeGenObj.mCodeInfo.ComponentTemplateType,'sequential')
            genSV.appendCode(sprintf('if(%s== 1''b1) begin',CodeGenObj.getResetId));
            genSV.addIndent;

            if isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')




                genSV.appendCode(CodeGenObj.upperBoundCheckForVarSizeInput());
                genSV.appendCode(CodeGenObj.getOutput1FcnCall());
                genSV.appendCode(CodeGenObj.allocateMemForVarSizeOutput());
            end
            genSV.appendCode(CodeGenObj.getResetFcnCall());
            genSV.appendCode(CodeGenObj.getTSVerifyInfoSetNewDPIObjHandle('ModuleName',dpiModuleName));
            genSV.appendCode(CodeGenObj.getNBVarAssignmentFromTmpToActual());


            if~isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')
                genSV.appendCode(CodeGenObj.getReportRunTimeErrFcnCall());
            end
            genSV.reduceIndent;
            genSV.appendCode('end');
        end
        if hdlverifierfeature('IS_CODEGEN_FOR_UVM')
            genSV.appendCode(sprintf('if(%s) begin',CodeGenObj.getClockEnId));
        elseif strcmpi(CodeGenObj.mCodeInfo.ComponentTemplateType,'sequential')
            genSV.appendCode(sprintf('else if(%s) begin',CodeGenObj.getClockEnId));
        end
        genSV.addIndent;

        genSV.appendCode(CodeGenObj.getOutputFcnCall());
        genSV.appendCode(CodeGenObj.getUpdateFcnCall());
        genSV.appendCode(CodeGenObj.getNBVarAssignmentFromTmpToActual());

        if~(isa(CodeGenObj,'dpig.internal.GetSVFcn_ML')||hdlverifierfeature('IS_CODEGEN_FOR_UVM'))...
            ||hdlverifierfeature('IS_CODEGEN_FOR_UVMDUT')
            genSV.appendCode(CodeGenObj.getReportRunTimeErrFcnCall());
        end

        genSV.appendCode(CodeGenObj.getAssertionQueryingSVCode());
        genSV.appendCode(CodeGenObj.getTSVerifyQueryingSVCode());
        genSV.appendCode(CodeGenObj.getAccessTestPointFcnCall());


        genSV.reduceIndent;
        if strcmpi(CodeGenObj.mCodeInfo.ComponentTemplateType,'sequential')
            genSV.appendCode('end');
        end
        genSV.reduceIndent;
        genSV.appendCode('end');
        genSV.reduceIndent;
        genSV.appendCode('endmodule')

    catch ME
        baseME=MException(message('HDLLink:DPIG:SVWrapperGenerationFailed'));
        newME=addCause(baseME,ME);
        throw(newME);
    end


end
