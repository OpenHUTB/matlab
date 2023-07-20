



function emitPWorkAllocation(this,codeWriter,forDynArray)

    if nargin<3
        forDynArray=false;
    end


    if this.LctSpecInfo.DWorksForBus.Numel<1
        return
    end


    argList=cell(2*this.LctSpecInfo.DWorksForBus.Numel,1);

    for ii=this.LctSpecInfo.DWorksForBus.Ids

        insertIdx=2*(ii-1)+1;


        dWork=this.LctSpecInfo.DWorksForBus.Items(ii);



        specData=dWork.BusInfo.Data;
        isDynamicArray=specData.IsDynamicArray;
        if(forDynArray&&~isDynamicArray)||(~forDynArray&&isDynamicArray)
            continue
        end


        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dWork.BusInfo.Data,'tlc');


        varName=sprintf('%s_addr',apiInfo.WBusName);
        varIdx=this.LctSpecInfo.DWorksInfo.NumPWorks+ii-1;
        codeWriter.wLine('%%assign %s = "&" + LibBlockPWork("", "", "", %d)',varName,varIdx);


        argList{insertIdx}=sprintf('%%<%s>',varName);


        if isDynamicArray
            argList{insertIdx+1}=apiInfo.Width;
        else
            argList{insertIdx+1}=sprintf('%%<%s>',apiInfo.Width);
        end
    end


    argList(cellfun(@isempty,argList))=[];


    codeWriter.wLine('%assign blockPath = STRING(LibGetBlockPath(block))');

    errMsg='%<LibSetRTModelErrorStatus("\"Memory allocation failure for %<blockPath>\"")>';

    fcnSuffix='';
    if forDynArray
        fcnSuffix='_dynamic_array';
    end
    codeWriter.wLine('if (%s_wrapper_allocmem%s(%s)!=0) %s;',...
    this.LctSpecInfo.Specs.SFunctionName,fcnSuffix,strjoin(argList,', '),errMsg);


