function dpigenerator_generateCWrapper(dpiModuleName,dpig_config,dpig_codeinfo,dpig_assertioninfo,buildInfo)


    try
        fcnObj=dpig.internal.GetCFcn(dpig_codeinfo,dpig_assertioninfo,dpig_config);


        hFileName=[dpiModuleName,'.h'];
        hFilePath=pwd;
        hFile=fullfile(hFilePath,hFileName);


        buildInfo.addIncludeFiles(hFileName,hFilePath);

        dpigenerator_disp(['Generating DPI H Wrapper ',dpigenerator_getfilelink(hFile)]);
        genH=dpig.internal.GenSVCode(hFile);

        genH.appendCode('/*');
        genH.addNewLine;
        genH.addGeneratedBy(' ');
        genH.appendCode('*/');
        genH.addNewLine;

        genH.appendCode(['#ifndef RTW_HEADER_',dpiModuleName,'_h_']);
        genH.appendCode(['#define RTW_HEADER_',dpiModuleName,'_h_']);
        genH.addNewLine;

        genH.appendCode('#ifdef __cplusplus');
        genH.appendCode('#define DPI_LINK_DECL extern "C"');
        genH.appendCode('#else');
        genH.appendCode('#define DPI_LINK_DECL');
        genH.appendCode('#endif');
        genH.addNewLine;

        genH.appendCode('#ifndef DPI_DLL_EXPORT');
        genH.appendCode('#if defined(_MSC_VER) || defined(__LCC__)');
        genH.appendCode('#define DPI_DLL_EXPORT __declspec(dllexport)');
        genH.appendCode('#else');
        genH.appendCode('#define DPI_DLL_EXPORT ');
        genH.appendCode('#endif');
        genH.appendCode('#endif');
        genH.addNewLine;


        genH.appendCode(fcnObj.getSVDPI_VerifyHeader());

        genH.appendCode(fcnObj.getCanonicalBitInterfaceRepresentation());
        genH.appendCode(fcnObj.getAssertionCDeclarations());
        genH.appendCode(fcnObj.getExtendedObjectHandleTypeDef());
        genH.appendCode(fcnObj.getInitializeFcnDecl());
        genH.appendCode(fcnObj.getResetFcnDecl());
        genH.appendCode(fcnObj.getOutputFcnDecl());
        genH.appendCode(fcnObj.getUpdateFcnDecl());
        genH.appendCode(fcnObj.getTerminateFcnDecl());
        genH.appendCode(fcnObj.getRunTimeErrorFcnDecl());
        genH.appendCode(fcnObj.getStopSimFcnDecl());
        genH.appendCode(fcnObj.getTSVerifyFcnDecl());

        genH.appendCode(fcnObj.getTestPointAccessFcnDecl());

        for idx=1:dpig_codeinfo.ParamStruct.NumPorts
            genH.appendCode(fcnObj.getSetParamFcnDecl(idx));
        end


        genH.addNewLine;

        genH.appendCode(['#endif /*RTW_HEADER_',dpiModuleName,'_h_*/']);
        genH.addNewLine;


        cFileName=[dpiModuleName,'.c'];
        cFilePath=pwd;
        cFile=fullfile(pwd,cFileName);


        buildInfo.addSourceFiles(cFileName,cFilePath);

        if dpig_config.NeedToCpyTSVerifyCHeader
            copyfile(fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','src','TSVerify','svdpi_verify.h'),cFilePath);
            buildInfo.addIncludeFiles('svdpi_verify.h',hFilePath);
            buildInfo.addIncludePaths(fullfile(matlabroot,'simulink','include','sf_runtime'),'Standard');
        end

        if dpig_config.NeedToCpyTSVerifyCCode
            copyfile(fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','src','TSVerify','svdpi_verify.c'),cFilePath);
            buildInfo.addSourceFiles('svdpi_verify.c',cFilePath);
        end
        dpigenerator_disp(['Generating DPI C Wrapper ',dpigenerator_getfilelink(cFile)]);
        genC=dpig.internal.GenSVCode(cFile);


        genC.appendCode('/*');
        genC.addNewLine;
        genC.addGeneratedBy(' ');
        genC.appendCode('*/');
        genC.addNewLine;

        genC.appendCode(['#include "',dpig_codeinfo.Name,'.h"']);
        genC.appendCode(['#include "',hFileName,'"']);
        genC.addNewLine;

        rtmVarName=dpig_codeinfo.AllocateFcn.ReturnType(1:end-2);
        genC.appendCode('#ifndef RT_MEMORY_ALLOCATION_ERROR_DEF');
        genC.appendCode('#define RT_MEMORY_ALLOCATION_ERROR_DEF');
        genC.appendCode('const char *RT_MEMORY_ALLOCATION_ERROR = "memory allocation error";');
        genC.appendCode('#endif');
        genC.appendCode(['static ',dpig_codeinfo.AllocateFcn.ReturnType,'* ',rtmVarName,' = NULL;']);
        genC.appendCode(fcnObj.TSGlobalVarDecl());
        genC.addNewLine;

        objhandle='objhandle';
        objhandlecast=['((',dpig_codeinfo.AllocateFcn.ReturnType,'*)',objhandle,')'];

        genC.addNewLine;
        genC.appendCode(fcnObj.getBitInterfaceFcnDef());
        genC.addNewLine;


        genC.addNewLine;
        genC.appendCode(fcnObj.getAssertionCDefinitions());
        genC.addNewLine;

        if~isempty(dpig_codeinfo.InitializeFcn)
            genC.appendCode(fcnObj.getInitializeFcnImpl());
            genC.appendCode('{');
            genC.appendCode(fcnObj.getInitializeFcnDefinition());
            genC.appendCode('}');
            genC.addNewLine;
        end

        if~isempty(dpig_codeinfo.ResetFcn)&&strcmpi(dpig_config.DPIComponentTemplateType,'sequential')

            genC.appendCode(fcnObj.getOutputFcnImpl('ResetFcn'));
            genC.appendCode('{');
            genC.addIndent;
            genC.appendCode(fcnObj.getResetFcnDefinition());
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end

        if~isempty(dpig_codeinfo.OutputFcn)
            genC.appendCode(fcnObj.getOutputFcnImpl('OutputFcn'));
            genC.appendCode('{');
            genC.addIndent;

            genC.appendCode(fcnObj.getActiveRTWObjHandle());

            genC.appendCode(fcnObj.getDeclarations());

            genC.appendCode(fcnObj.getInputPtr());

            genC.appendCode(fcnObj.getOutputPtr());

            genC.appendCode(fcnObj.getInputToRTW());

            genC.appendCode(fcnObj.getNativeOutputCFcnCall());

            genC.appendCode(fcnObj.getOutputFromRTW());
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end

        if~isempty(dpig_codeinfo.UpdateFcn)&&strcmpi(dpig_config.DPIComponentTemplateType,'sequential')

            genC.appendCode(fcnObj.getUpdateFcnImpl());
            genC.appendCode('{');
            genC.addIndent;

            genC.appendCode(fcnObj.getActiveRTWObjHandle());

            if dpig_codeinfo.InStruct.NumPorts~=0

                genC.appendCode(fcnObj.getDeclarations());
            end

            genC.appendCode(fcnObj.getInputPtr());

            genC.appendCode(fcnObj.getInputToRTW());

            genC.appendCode(fcnObj.getNativeUpdateCFcnCall());

            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end


        if fcnObj.mCodeInfo.TestPointStruct.NumTestPoints~=0
            testPointKeys=keys(fcnObj.mCodeInfo.TestPointStruct.TestPointContainer);
            if strcmp(fcnObj.mCodeInfo.TestPointStruct.AccessFcnInterface,'One function per Test Point')

                for idx=testPointKeys
                    keyval=idx{1};
                    genC.appendCode(fcnObj.TestPointFcnSignatureMap(keyval));
                    genC.appendCode('{');
                    genC.addIndent;
                    genC.appendCode(fcnObj.getTestPointFcnDef(keyval));
                    genC.reduceIndent;
                    genC.appendCode('}');
                    genC.addNewLine;
                end
            elseif strcmp(fcnObj.mCodeInfo.TestPointStruct.AccessFcnInterface,'One function for all Test Points')

                genC.appendCode(fcnObj.TestPointFcnSignatureMap(testPointKeys{1}));
                genC.appendCode('{');
                genC.addIndent;
                genC.appendCode(fcnObj.getTestPointFcnDef());
                genC.reduceIndent;
                genC.appendCode('}');
                genC.addNewLine;
            end
        end

        if~isempty(dpig_codeinfo.TerminateFcn)
            genC.appendCode(fcnObj.getTerminateFcnImpl());
            genC.appendCode('{');
            genC.addIndent;

            genC.appendCode(fcnObj.getActiveRTWObjHandle());

            genC.appendCode([dpig_codeinfo.TerminateFcn.Name,'(',objhandlecast,');']);

            genC.appendCode(fcnObj.FreeActiveObjHandle());
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end


        if~isempty(dpig_codeinfo.RunTimeErrorFcn)
            genC.appendCode(fcnObj.getRunTimeErrorFcnImpl());
            genC.appendCode('{');
            genC.addIndent;
            genC.appendCode(fcnObj.getActiveRTWObjHandle());
            genC.appendCode(fcnObj.getRunTimeErrorFcnDefinition());
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end

        if~isempty(dpig_codeinfo.StopSimFcn)
            genC.appendCode(fcnObj.getStopSimFcnImpl());
            genC.appendCode('{');
            genC.addIndent;
            genC.appendCode(fcnObj.getActiveRTWObjHandle());
            genC.appendCode(fcnObj.getStopSimFcnDefinition());
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end


        genC.appendCode(fcnObj.getTSVerifyFcnDef());



        for idx=1:dpig_codeinfo.ParamStruct.NumPorts
            genC.appendCode(fcnObj.getSetParamFcnImpl(idx));
            genC.appendCode('{');
            genC.addIndent;

            genC.appendCode(fcnObj.getActiveRTWObjHandle());

            genC.appendCode(fcnObj.getParamDeclarations(idx));

            genC.appendCode(fcnObj.getParamPtr(idx));

            genC.appendCode(fcnObj.getParamToRTW(idx));
            genC.reduceIndent;
            genC.appendCode('}');
            genC.addNewLine;
        end
        genC.addNewLine;


    catch ME
        baseME=MException(message('HDLLink:DPIG:WrapperGenerationFailed'));
        newME=addCause(baseME,ME);
        throw(newME);
    end

end


