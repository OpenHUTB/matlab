classdef Symbols<handle













    properties(SetAccess=private,Hidden=true)













        InputSymbolsMap;


        SymbolsMap;

    end

    methods(Static=true,Hidden=true)


        function symbol=makesymbol(name,typerestriction,depth,type,reg,reg2,shapeinfo)

            symbol=struct(...
            'name',name,...
            'use',typerestriction,...
            'depth',depth,...
            'type',type,...
            'reg',reg,...
            'reg2',reg2,...
            'shapeinfo',shapeinfo...
            );

        end


        function symbol=makeemptysymbol(name,typerestriction)
            ashapeinfo=parallel.internal.gpu.Symbols.makeshapeinfo(0,0,[],[]);
            symbol=parallel.internal.gpu.Symbols.makesymbol(name,typerestriction,'','','','',ashapeinfo);
        end


        function shapeinfo=makeshapeinfo(numel,def,dims,deps)
            shapeinfo=struct('numel',numel,'def',def,'dims',dims,'deps',deps);
        end


        function shapeinfo=makescalarshapeinfo()
            shapeinfo=parallel.internal.gpu.Symbols.makeshapeinfo(1,-1,1,uint8(0));
        end


        function szo=updateshapeinfo(internalState,sz1,sz2,op)

            if 1==sz1.numel
                szo=sz2;
                szo.deps=or(szo.deps,sz1.deps);
            elseif 1==sz2.numel
                szo=sz1;
                szo.deps=or(szo.deps,sz2.deps);
            else

                if~all(sz1.dims==sz2.dims)
                    encounteredError(internalState,message('parallel:gpu:compiler:ShapeMismatch',op));
                end

                szo=sz1;
                szo.deps=or(szo.deps,sz2.deps);

            end

        end


        function checkInputType(internalState,variable)

            clv=parallel.internal.types.Atomic.enumerate(variable);

            if~isSupported(clv)
                encounteredError(internalState,message('parallel:gpu:compiler:UnsupportedTypeShort',mType(coerceScalar(clv))));
            end

        end


        function checkInputTypes(internalState,arglist)

            nin=numel(arglist);

            for ist=1:nin
                v=arglist{ist};
                parallel.internal.gpu.Symbols.checkInputType(internalState,v);
            end

        end


        function symbol=makeNullTypedSymbol(name,id,numVars)

            clv=parallel.internal.types.Atomic.Null;
            tt=zeros(1,numVars,'uint8');

            tt(id)=1;

            ashapeinfo=parallel.internal.gpu.Symbols.makeshapeinfo(0,id,[],tt);
            symbol=parallel.internal.gpu.Symbols.makesymbol(name,'static',0,clv,'','',ashapeinfo);

        end


        function symbol=makeTypedSymbol(name,v,id,numVars,internalState)


            clv=parallel.internal.types.Atomic.enumerate(v);

            [reg,reg2]=tGet(internalState,clv);

            nv=numel(v);
            tt=zeros(1,numVars,'uint8');
            tt(id)=uint8(1);

            ashapeinfo=parallel.internal.gpu.Symbols.makeshapeinfo(nv,id,size(v),tt);
            symbol=parallel.internal.gpu.Symbols.makesymbol(name,'static',0,clv,reg,reg2,ashapeinfo);

        end


        function symbol=makeUplevelSymbol(name,v,internalState)

            if numel(v)==1


                symbol=parallel.internal.gpu.Symbols.makeTypedSymbol(name,v,uint8(1),uint8(1),internalState);
            else

                clv=parallel.internal.types.Atomic.enumerate(v);

                ptrdata=ptrGet(internalState);
                ptrshape=ptrGet(internalState);

                nv=numel(v);
                ashapeinfo=parallel.internal.gpu.Symbols.makeshapeinfo(nv,uint8(1),size(v),uint8(1));

                symbol=parallel.internal.gpu.Symbols.makesymbol(name,'static',0,clv,ptrdata,ptrshape,ashapeinfo);

            end

        end


    end

    methods(Hidden=true,Access=private)





        function obj=addNullTypedSymbols(obj,names)

            nentry=numel(names);
            for kk=1:nentry
                symbolName=names{kk};
                symbol=obj.makeNullTypedSymbol(symbolName,kk,nentry);
                obj.InputSymbolsMap(symbolName)=symbol;
            end

        end

    end

    methods(Hidden=true)




        function obj=Symbols(internalState,inputs,arglist)

            nin=numel(inputs);

            obj.InputSymbolsMap=containers.Map('KeyType','char','ValueType','any');
            inputSymbolsMap=obj.InputSymbolsMap;


            for ist=1:nin
                symbolName=inputs{ist};
                assert(~isempty(symbolName),'analysis phase is broken.');
                v=arglist{ist};

                symbol=parallel.internal.gpu.Symbols.makeTypedSymbol(symbolName,v,ist,nin,internalState);
                inputSymbolsMap(symbolName)=symbol;

            end


            if isempty(inputSymbolsMap)


                obj.SymbolsMap=containers.Map('KeyType','char','ValueType','any');
            else


                obj.SymbolsMap=containers.Map(inputSymbolsMap.keys(),inputSymbolsMap.values(),'uniformValues',true);
            end

        end


        function obj=populateWorkspaceFromMATLAB(obj,workspace)

            N=numel(workspace);

            for kk=1:N

                workspaceEntry=workspace{kk};
                assert(isstruct(workspaceEntry));

                entryFields=fieldnames(workspaceEntry);
                obj=addNullTypedSymbols(obj,entryFields);

            end

            if isempty(obj.InputSymbolsMap)
                obj.SymbolsMap=containers.Map('KeyType','char','ValueType','any');
            else
                obj.SymbolsMap=containers.Map(obj.InputSymbolsMap.keys(),...
                obj.InputSymbolsMap.values(),'uniformValues',true);
            end

        end

        function obj=populateWorkspaceInternally(obj,names)

            obj=addNullTypedSymbols(obj,names);

            if isempty(obj.InputSymbolsMap)
                obj.SymbolsMap=containers.Map('KeyType','char','ValueType','any');
            else
                obj.SymbolsMap=containers.Map(obj.InputSymbolsMap.keys(),...
                obj.InputSymbolsMap.values(),'uniformValues',true);
            end

        end


        function obj=addUplevelVariableToSymbolTable(obj,name,variable,internalState)
            obj.checkInputType(internalState,variable);
            obj.SymbolsMap(name)=obj.makeUplevelSymbol(name,variable,internalState);
        end


        function obj=populateSymbols(obj,inputs,arglist)

            nin=numel(inputs);
            narglist=numel(arglist);
            assert(nin==narglist);

            for ist=1:nin
                symbolName=inputs{ist};
                assert(~isempty(symbolName),'analysis phase is broken.');
                v=arglist{ist};

                symbol=obj.makesymbol(v.name,'static',0,v.type,v.reg,v.reg2,v.shapeinfo);
                obj.InputSymbolsMap(symbolName)=symbol;

            end

            if isempty(obj.InputSymbolsMap)
                obj.SymbolsMap=containers.Map('KeyType','char','ValueType','any');
            else
                obj.SymbolsMap=containers.Map(obj.InputSymbolsMap.keys(),...
                obj.InputSymbolsMap.values(),'uniformValues',true);
            end

        end





        function scalarizeSymbols(obj,inputs)


            assert(isequal(obj.InputSymbolsMap,obj.SymbolsMap),'Cannot scalarize after additional symbols are added');


            symbolsMap=obj.SymbolsMap;

            for idx=1:numel(inputs)
                symbolName=inputs{idx};
                symbol=symbolsMap(symbolName);
                symbol.type=coerceScalar(symbol.type);
                shapeinfo=symbol.shapeinfo;
                symbol.shapeinfo=obj.makeshapeinfo(1,shapeinfo.def,1,shapeinfo.deps);
                symbolsMap(symbolName)=symbol;
            end

        end


        function existp=symbolPresent(obj,name)
            existp=isKey(obj.SymbolsMap,name);
        end


        function declareSymbolsFixed(obj,names)

            N=numel(names);

            for kk=1:N
                name=names{kk};
                symbol=obj.SymbolsMap(name);
                symbol.depth=-1;
                obj.SymbolsMap(name)=symbol;
            end

        end



        function declareSymbolsStatic(obj,names,depth)

            N=numel(names);

            for kk=1:N
                name=names{kk};

                if~isKey(obj.SymbolsMap,name)
                    symbol=obj.makeemptysymbol(name,'static');
                    symbol.depth=depth;
                    obj.SymbolsMap(name)=symbol;
                else
                    symbol=obj.SymbolsMap(name);
                    symbol.use='static';
                    obj.SymbolsMap(name)=symbol;
                end

            end

        end


        function removeSymbols(obj,names,depth)
            if nargin<3




                depth=-1;
            end

            N=numel(names);

            for kk=1:N

                name=names{kk};
                assert(isKey(obj.SymbolsMap,name),'Unknown variable: ''%s'' ',name);

                symbol=obj.SymbolsMap(name);

                if symbol.depth>depth
                    remove(obj.SymbolsMap,name);
                end

            end

        end



        function symbol=getSymbolIns(obj,name)

            if isKey(obj.InputSymbolsMap,name)
                symbol=obj.InputSymbolsMap(name);
            else
                assert(false,'Unknown variable ''%s''.',name);
            end

        end


        function names=getAllSymbolInsNames(obj)
            names=keys(obj.InputSymbolsMap);
        end


        function names=getCurrentSymbolNames(obj)
            names=keys(obj.SymbolsMap);
        end



        function symbol=getSymbol(obj,name)

            if isKey(obj.SymbolsMap,name)
                symbol=obj.SymbolsMap(name);
            else
                assert(false,'Unknown variable ''%s''.',name);
            end

        end




        function instr=updateSymbol(obj,emitter,internalState,name,typeOut,shapeInfo,regReal,regImag,depth)






















            if isKey(obj.SymbolsMap,name)
                symbol=obj.SymbolsMap(name);
            else
                symbol=obj.makeemptysymbol(name,'dynamic');
                symbol.depth=depth;
            end





            if isempty(symbol.type)

                [instr,reg,reg2]=copyreg(emitter,internalState,typeOut,regReal,regImag);


                symbol.type=typeOut;


                symbol.shapeinfo.numel=shapeInfo.numel;
                symbol.shapeinfo.def=shapeInfo.def;
                symbol.shapeinfo.dims=shapeInfo.dims;
                symbol.shapeinfo.deps=shapeInfo.deps;


                symbol.reg=reg;
                symbol.reg2=reg2;

            else




                if strcmp(symbol.use,'static')&&(symbol.depth<depth)

                    if strcmp(getRuleset(internalState),'vector')





                        if symbol.shapeinfo.numel~=shapeInfo.numel
                            encounteredError(internalState,message('parallel:gpu:compiler:DynamicResize',name));
                        end


                        if-1~=shapeInfo.def&&-1~=symbol.shapeinfo.def&&...
                            ~all(shapeInfo.dims==symbol.shapeinfo.dims)
                            encounteredError(internalState,message('parallel:gpu:compiler:DynamicReshape',name));
                        end


                    end


                    if(isComplex(symbol.type)~=isComplex(typeOut))
                        encounteredError(internalState,message('parallel:gpu:compiler:DynamicComplexity',name));
                    end


                    if symbol.type~=typeOut
                        encounteredError(internalState,message('parallel:gpu:compiler:DynamicType',name));
                    end

                end


                if symbol.type==typeOut
                    [instr,reg,reg2]=movereg(emitter,internalState,typeOut,symbol.reg,symbol.reg2,regReal,regImag);
                else
                    [instr,reg,reg2]=copyreg(emitter,internalState,typeOut,regReal,regImag);
                end

                symbol.type=typeOut;
                symbol.reg=reg;
                symbol.reg2=reg2;

            end


            obj.SymbolsMap(name)=symbol;

        end

        function propagateSymbol(obj,name,symbol)


            obj.SymbolsMap(name)=symbol;

        end

    end


end




