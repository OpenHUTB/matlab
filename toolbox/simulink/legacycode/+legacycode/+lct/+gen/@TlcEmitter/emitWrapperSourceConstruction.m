




function emitWrapperSourceConstruction(this,codeWriter)



    if this.LctSpecInfo.isCPP==false
        fExt='c';
    else
        fExt='cpp';
    end

    codeWriter.wLine(sprintf('%%assign cFileName = FcnGenerateUniqueFileName("%s_wrapper", "source")',...
    this.LctSpecInfo.Specs.SFunctionName));


    codeWriter.wLine(sprintf('%%openfile cFile = "%%<cFileName>.%s"',fExt));
    codeWriter.wLine('%selectfile cFile');


    if this.LctSpecInfo.DWorksForBus.Numel>0
        codeWriter.wLine('#include <stdlib.h>');
    end

    codeWriter.wLine('#include <string.h>');

    txt={...
    '#ifdef MATLAB_MEX_FILE',...
    '#include "tmwtypes.h"',...
    '#else',...
    '#include "rtwtypes.h"',...
'#endif'...
    };
    cellfun(@(aLine)codeWriter.wLine(aLine),txt);


    emitIncludedHeader(codeWriter,this.HeaderFileInfo.GlobalHeaderFiles);
    emitIncludedHeader(codeWriter,this.HeaderFileInfo.SlObjHeaderFiles);

    codeWriter.wNewLine;


    [externCStartStmt,externCEndStmt]=genExternCStmts(this);



    defStmts=this.genPWorkAllocFreeFuns(true);
    if~isempty(defStmts)
        cellfun(@(aLine)codeWriter.wLine(aLine),externCStartStmt);
        cellfun(@(aLine)codeWriter.wLine(aLine),defStmts);
        cellfun(@(aLine)codeWriter.wLine(aLine),externCEndStmt);
        codeWriter.wNewLine;
    end


    this.LctSpecInfo.forEachFunction(@(o,k,f)genFunDef(f,k));


    codeWriter.wLine('%closefile cFile');
    codeWriter.wNewLine;

    function genFunDef(funSpec,funKind)
        if funSpec.IsSpecified

            cellfun(@(aLine)codeWriter.wLine(aLine),externCStartStmt);


            [lhs,fcnName,argList]=this.genWrapperPrototype(funSpec,funKind);
            codeWriter.wLine('%s %s(%s) {',lhs,fcnName,argList);


            codeWriter.incIndent;


            this.emitLocalsForNDMarshaling(codeWriter,funSpec,true);


            this.emitStructConversion(codeWriter,funSpec,true);
            this.emitNDArrayConversion(codeWriter,funSpec,true);


            this.emitFunCallInWrapper(codeWriter,funSpec);


            this.emitNDArrayConversion(codeWriter,funSpec,false);
            this.emitStructConversion(codeWriter,funSpec,false);


            codeWriter.decIndent;
            codeWriter.wLine('}');


            cellfun(@(aLine)codeWriter.wLine(aLine),externCEndStmt);
            codeWriter.wNewLine;
        end
    end

end


function emitIncludedHeader(codeWriter,hdrs)


    if~isempty(hdrs)
        codeWriter.wNewLine;
        for ii=1:length(hdrs)
            thisHeaderFile=hdrs{ii};
            dblQuote='"';
            if thisHeaderFile(1)=='<'||thisHeaderFile(1)=='"'
                dblQuote='';
            end
            codeWriter.wLine('#include %s%s%s',dblQuote,thisHeaderFile,dblQuote);
        end
    end

end


function[externCStartStmt,externCEndStmt]=genExternCStmts(this)

    externCStartTxt='extern "C" {';
    externCEndTxt='}';
    externCStartStmt={};
    externCEndStmt={};
    if this.LctSpecInfo.isCPP==true




        if this.LctSpecInfo.hasWrapper
            ifStmt='%if IsModelReferenceSimTarget()';



            if slfeature('ModelReferenceHonorsSimTargetLang')>0
                ifStmt=[ifStmt,' && !::GenCPP'];
            end
            externCStartStmt={...
            ifStmt,...
            externCStartTxt,...
            '%endif',...
            };
            externCEndStmt={...
            ifStmt,...
            externCEndTxt,...
            '%endif',...
            };
        else
            externCStartStmt{1}=externCStartTxt;
            externCEndStmt{1}=externCEndTxt;
        end
    end

end


