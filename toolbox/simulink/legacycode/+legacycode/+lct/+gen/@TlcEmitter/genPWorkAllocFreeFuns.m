



function stmts=genPWorkAllocFreeFuns(this,forDef)

    if nargin<1
        forDef=true;
    end

    stmtsRegular=genPWorkAllocFreeFunsCore(this,forDef,false);
    stmtsDynArray=genPWorkAllocFreeFunsCore(this,forDef,true);
    stmts=[stmtsRegular,{''},stmtsDynArray];

    function stmts=genPWorkAllocFreeFunsCore(this,forDef,forDynArray)

        stmts={};

        if this.LctSpecInfo.DWorksForBus.Numel<1

            return
        end


        fcnSuffix='';
        if forDynArray
            fcnSuffix='_dynamic_array';
        end
        allocProto=sprintf('int %s_wrapper_allocmem%s(',this.LctSpecInfo.Specs.SFunctionName,fcnSuffix);
        freeProto=sprintf('int %s_wrapper_freemem%s(',this.LctSpecInfo.Specs.SFunctionName,fcnSuffix);


        if forDef
            allocBody=cell(1,2*this.LctSpecInfo.DWorksForBus.Numel);
            freeBody=cell(1,2*this.LctSpecInfo.DWorksForBus.Numel);
        end

        sep='';

        numArgs=0;
        for ii=1:this.LctSpecInfo.DWorksForBus.Numel

            dWork=this.LctSpecInfo.DWorksForBus.Items(ii);
            dataType=this.LctSpecInfo.DataTypes.Items(dWork.DataTypeId);



            specData=dWork.BusInfo.Data;
            isDynamicArray=specData.IsDynamicArray;
            if(forDynArray&&~isDynamicArray)||(~forDynArray&&isDynamicArray)
                continue
            end


            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dWork.BusInfo.Data,'sfun');


            allocProto=sprintf('%s%svoid** %s, int_T %sWidth',allocProto,sep,...
            apiInfo.WBusName,apiInfo.WBusName);

            freeProto=sprintf('%s%svoid** %s',freeProto,sep,apiInfo.WBusName);

            if forDef

                idx=2*(ii-1)+1;
                allocBody{idx}=sprintf('    *%s = calloc(sizeof(%s), %sWidth);',...
                apiInfo.WBusName,dataType.DTName,apiInfo.WBusName);

                allocBody{idx+1}=sprintf('    if (*%s==NULL) return -1;',apiInfo.WBusName);

                freeBody{idx}=sprintf('    if (*%s!=NULL) free(*%s);',...
                apiInfo.WBusName,apiInfo.WBusName);

                freeBody{idx+1}=sprintf('    *%s = NULL;',apiInfo.WBusName);
            end

            sep=', ';
            numArgs=numArgs+1;
        end

        if numArgs<1
            allocProto=[allocProto,'void'];
            freeProto=[freeProto,'void'];
        end

        if forDef

            allocBody(cellfun(@isempty,allocBody))=[];
            freeBody(cellfun(@isempty,freeBody))=[];


            allocFun=[...
            {[allocProto,') {']},...
            allocBody,...
            {'    return 0;'},...
            {'}'},...
            {''}...
            ];


            freeFun=[...
            {[freeProto,') {']},...
            freeBody,...
            {'    return 0;'},...
            {'}'}...
            ];


            stmts=[...
            allocFun,...
freeFun...
            ];
        else

            stmts={...
            ['extern ',allocProto,');'],...
            ['extern ',freeProto,');'],...
            };
        end


