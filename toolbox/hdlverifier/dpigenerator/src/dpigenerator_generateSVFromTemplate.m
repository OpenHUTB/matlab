function dpigenerator_generateSVFromTemplate(dpiModuleName,CodeGenObj,TemplateFileName,NumberOfParameters)
    try

        svFile=fullfile(pwd,[dpiModuleName,'.sv']);
        genSV=dpig.internal.GenSVCode(svFile);

        if isempty(TemplateFileName)
            error(message('HDLLink:DPIG:TemplateNotFound',dpig_config.DPISystemVerilogTemplate));
        end
        dpigenerator_disp(['Generating SystemVerilog module ',dpigenerator_getfilelink(svFile),' using template ',TemplateFileName]);

        [fid,msg]=fopen(TemplateFileName,'r');
        if fid==-1
            error(msg);
        end
        context=fread(fid,inf,'uint8=>char')';
        fclose(fid);

        context=l_removeComments(context);
        context=strrep(context,'%<FileName>',dpiModuleName);
        context=strrep(context,'%<PortList>',CodeGenObj.getPortDeclList(false,true));
        context=strrep(context,'%<SVDPITBPortList>',CodeGenObj.getPortDeclList(true,true));

        context=strrep(context,'%<EnumDataTypeDefinitions>',CodeGenObj.getEnumDeclarations());


        context=strrep(context,'%<ObjHandle>','chandle objhandle;');
        context=strrep(context,'%<SVDPITBObjHandleAndTempVars>',CodeGenObj.getSVDPITBObjHandleAndTempVars());

        context=strrep(context,'%<ImportInitFunction>',CodeGenObj.getImportInitializeFcn());
        context=strrep(context,'%<ImportResetFunction>',CodeGenObj.getImportResetFcn());


        context=strrep(context,'%<ImportOutputFunction>',CodeGenObj.getImportOutputFcn());
        context=strrep(context,'%<SVDPITBImportOutputFunction>',CodeGenObj.getImportOutputFcn(true));

        context=strrep(context,'%<ImportUpdateFunction>',CodeGenObj.getImportUpdateFcn());



        context=strrep(context,'%<ImportTerminateFunction>',CodeGenObj.getImportTerminateFcn());

        context=strrep(context,'%<SVDPITBTempVarsAssignment>',CodeGenObj.getSVDPITBTempVarsAssignment());

        ImportSetParamFcn='';
        for idxParam=1:NumberOfParameters
            ImportSetParamFcn=[ImportSetParamFcn,newline,CodeGenObj.getImportSetParamFcn(idxParam)];%#ok<AGROW>
        end

        context=strrep(context,'%<ImportSetParamFunction>',ImportSetParamFcn);

        context=strrep(context,'%<CallInitFunction>',CodeGenObj.getInitializeFcnCall());
        context=strrep(context,'%<CallResetFunction>',CodeGenObj.getResetFcnCall(false,true,false));
        context=strrep(context,'%<CallOutputFunction>',CodeGenObj.getOutputFcnCall(false,true,false));
        context=strrep(context,'%<SVDPITBCallOutputFunction>',CodeGenObj.getOutputFcnCall(true,true,true));
        context=strrep(context,'%<CallUpdateFunction>',CodeGenObj.getUpdateFcnCall());
        context=strrep(context,'%<CallTerminateFunction>',CodeGenObj.getTerminateFcnCall());

        context=strrep(context,'%<IsLibContinuous>',CodeGenObj.getIsLibContinuous);

        genSV.appendCode(context);
    catch ME
        baseME=MException(message('HDLLink:DPIG:SVWrapperGenerationFailed'));
        newME=addCause(baseME,ME);
        throw(newME);
    end
end

function result=l_removeComments(content)
    result='';
    lines=regexp(content,'[\f\n\r]','split');
    if~isempty(lines)
        nonEmptyIndex=ones(1,numel(lines));
        for m=1:numel(lines)
            trimmedLine=strtrim(lines{m});

            if length(trimmedLine)>=2&&strcmp(trimmedLine(1:2),'%%')
                nonEmptyIndex(m)=0;
            end
        end
        nonEmptyIndex=find(nonEmptyIndex);
        result=sprintf('%s\n',lines{nonEmptyIndex});%#ok<FNDSB>
    end

end
