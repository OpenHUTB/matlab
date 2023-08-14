



function emitPWorkDeallocation(this,codeWriter,forDynArray)

    if nargin<3
        forDynArray=false;
    end


    if this.LctSpecInfo.DWorksForBus.Numel<1
        return
    end


    argList=cell(this.LctSpecInfo.DWorksForBus.Numel,1);

    for ii=this.LctSpecInfo.DWorksForBus.Ids

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


        argList{ii}=sprintf('%%<%s>',varName);
    end


    argList(cellfun(@isempty,argList))=[];


    codeWriter.wLine('%assign blockPath = STRING(LibGetBlockPath(block))');

    errMsg='%<LibSetRTModelErrorStatus("\"Memory free failure for %<blockPath>\"")>';

    fcnSuffix='';
    if forDynArray
        fcnSuffix='_dynamic_array';
    end
    codeWriter.wLine('if (%s_wrapper_freemem%s(%s)!=0) %s;',...
    this.LctSpecInfo.Specs.SFunctionName,fcnSuffix,strjoin(argList,', '),errMsg);


