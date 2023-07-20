function dpigenerator_MATLAB_generateCWrapper(CWrapperName,dpig_codeinfo,buildInfo)



    CFile=fullfile(pwd,[CWrapperName,'.c']);

    HFile=fullfile(pwd,[CWrapperName,'.h']);


    genC=dpig.internal.GenCWrap(CFile);
    fcnObj=dpig.internal.GetCFcn_ML(dpig_codeinfo);


    genH=dpig.internal.GenCWrap(HFile);

    dpigenerator_disp(['Generating DPI-C Wrapper ',dpigenerator_getfilelink(CFile)]);
    dpigenerator_disp(['Generating DPI-C Wrapper header file ',dpigenerator_getfilelink(HFile)]);
    genC.getUniqueName(CWrapperName);
    genH.getUniqueName(CWrapperName);





    genC.appendCode('/*');
    genC.addNewLine;
    genC.addGeneratedBy('*');
    genC.appendCode('*/');

    genH.appendCode('/*');
    genH.addNewLine;
    genH.addGeneratedBy('*');
    genH.appendCode('*/');


    genC.addNewLine;
    genH.addNewLine;


    genC.appendCode(['#include ','"',CWrapperName(1:length(CWrapperName)-4),'.h"']);
    genC.appendCode(['#include ','"',CWrapperName,'.h"']);


    genC.appendCode('#include <string.h>');
    genC.appendCode(fcnObj.getEmxAPIHeader());
    genC.appendCode(fcnObj.getStaticVarDelForVarSizeVar());
    genC.addNewLine;


    genH.appendCode(['#ifndef RTW_HEADER_',CWrapperName,'_h_']);
    genH.appendCode(['#define RTW_HEADER_',CWrapperName,'_h_']);
    genH.addNewLine;
    genH.appendCode('#ifdef __cplusplus');
    genH.appendCode('#define DPI_LINK_DECL extern "C"');
    genH.appendCode('#else');
    genH.appendCode('#define DPI_LINK_DECL');
    genH.appendCode('#endif');
    genH.addNewLine;
    genH.appendCode('#ifndef DPI_DLL_EXPORT');
    genH.appendCode('#ifdef _MSC_VER');
    genH.appendCode('#define DPI_DLL_EXPORT __declspec(dllexport)');
    genH.appendCode('#else');
    genH.appendCode('#define DPI_DLL_EXPORT ');
    genH.appendCode('#endif');
    genH.appendCode('#endif');
    genH.appendCode(fcnObj.getCanonicalBitInterfaceRepresentation());
    genH.appendCode(fcnObj.getSVDPIHeader());
    genH.addNewLine;


    genC.addNewLine;
    genC.appendCode(fcnObj.getBitInterfaceFcnDef());
    genC.addNewLine;


    Temp_str=fcnObj.getImportFcn('Init');
    genC.addNewLine;


    genH.appendCode('DPI_LINK_DECL');
    genH.appendCode(Temp_str);


    genC.appendCode(Temp_str(1:end-1));
    genC.appendCode('{');
    genC.addIndent;
    genC.appendCode(fcnObj.getFcnCall('Init'));
    genC.reduceIndent;
    genC.appendCode('}');


    if strcmpi(fcnObj.mCodeInfo.ComponentTemplateType,'sequential')


        Temp_str=fcnObj.getImportFcn('Reset');
        genC.addNewLine;


        genH.appendCode('DPI_LINK_DECL');
        genH.appendCode(Temp_str);


        genC.appendCode(Temp_str(1:end-1));
        genC.appendCode('{');
        genC.addIndent;
        genC.appendCode(fcnObj.getFcnCall('Reset'));
        genC.reduceIndent;
        genC.appendCode('}');
    end



    if fcnObj.mCodeInfo.VarSizeInfo.containVarSizeOutput

        Temp_str=fcnObj.getImportFcn('Output1');
        genC.addNewLine;


        genH.appendCode('DPI_LINK_DECL');
        genH.appendCode(Temp_str);


        genC.appendCode(Temp_str(1:end-1));
        genC.appendCode('{');
        genC.addIndent;
        genC.appendCode(fcnObj.getFcnCall('Output1'));
        genC.reduceIndent;
        genC.appendCode('}');


        Temp_str=fcnObj.getImportFcn('Output2');
        genC.addNewLine;


        genH.appendCode('DPI_LINK_DECL');
        genH.appendCode(Temp_str);


        genC.appendCode(Temp_str(1:end-1));
        genC.appendCode('{');
        genC.addIndent;
        genC.appendCode(fcnObj.getFcnCall('Output2'));
        genC.reduceIndent;
        genC.appendCode('}');

    else

        Temp_str=fcnObj.getImportFcn('Output');
        genC.addNewLine;


        genH.appendCode('DPI_LINK_DECL');
        genH.appendCode(Temp_str);


        genC.appendCode(Temp_str(1:end-1));
        genC.appendCode('{');
        genC.addIndent;
        genC.appendCode(fcnObj.getFcnCall('Output'));
        genC.reduceIndent;
        genC.appendCode('}');
    end

    Temp_str=fcnObj.getImportFcn('Terminate');
    genC.addNewLine;



    genH.appendCode('DPI_LINK_DECL');
    genH.appendCode(Temp_str);
    genH.appendCode('#endif');


    genC.appendCode(Temp_str(1:end-1));
    genC.appendCode('{');
    genC.addIndent;
    genC.appendCode(fcnObj.getFcnCall('Terminate'));
    genC.reduceIndent;
    genC.appendCode('}');



    buildInfo.addSourceFiles([CWrapperName,'.c']);
    buildInfo.addIncludeFiles([CWrapperName,'.h']);





