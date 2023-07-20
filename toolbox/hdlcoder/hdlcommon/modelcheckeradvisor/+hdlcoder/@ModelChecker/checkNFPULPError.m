function flag=checkNFPULPError(this)




    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;


    toleranceValue=hdlget_param(gcs,'FPToleranceValue');


    targetConfig=hdlget_param(model,'FloatingPointTargetConfig');
    if~isempty(targetConfig)
        if strcmpi('NativeFloatingPoint',targetConfig.Library)
            blocks=hdlcoder.ModelChecker.find_system_MAWrapper(dut,'RegExp','On','Type','Block');
            for i=1:numel(blocks)

                try
                    type=get_param(blocks{i},'Operator');
                catch
                    type=get_param(blocks{i},'BlockType');
                    if strcmpi(type,'Product')
                        inputs=get_param(blocks{i},'Inputs');
                        if strcmpi(inputs,'/')
                            type='reciprocal';
                        else
                            if contains(inputs,'/')
                                type='div';
                            end
                        end
                    end
                end
                nfpType=hdlcoder.ModelChecker.getNFPBlockTypeBySlType(type);
                [~,outputDataType]=hdlcoder.ModelChecker.getNFPBlockDataType(blocks{i});

                ulp=targetcodegen.targetCodeGenerationUtils.getOperatorULP(nfpType,outputDataType);
                if(ulp>toleranceValue)
                    this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:NFPULPErrorChecksReportSummary'),blocks{i},0,DAStudio.message('HDLShared:hdlmodelchecker:desc_NFP_ULP_error',ulp));
                    flag=false;
                end
            end
        end
    end
end
