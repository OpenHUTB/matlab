classdef(Hidden)LCTGlobalIO<handle






    properties(SetAccess=private)
        Inputs=legacycode.lct.spec.GlobalSigOrParam.empty
        Outputs=legacycode.lct.spec.GlobalSigOrParam.empty
        DataStores=legacycode.lct.spec.GlobalSigOrParam.empty
        Parameters=legacycode.lct.spec.GlobalSigOrParam.empty
    end

    properties(Dependent,SetAccess=private)
        HasPointerIO;
        HasDSMs;
        HasGlobalOutputs;
    end

    methods(Access=public)
        function obj=LCTGlobalIO(globalIOCell,getsetIOCell)

















            if nargin==0


                return;
            end


            assert(iscellstr(globalIOCell)||isstring(globalIOCell)||isempty(globalIOCell));
            globalVarParser=legacycode.lct.spec.GlobalVarParser;
            for kCell=1:numel(globalIOCell)
                currGlobalVar=globalVarParser.parse(globalIOCell{kCell},kCell);
                obj.registerGlobal(globalVarParser,currGlobalVar);
            end


            assert(iscellstr(getsetIOCell)||isstring(getsetIOCell)||isempty(getsetIOCell));
            getsetParser=legacycode.lct.spec.GetSetParser;
            for kCell=1:numel(getsetIOCell)
                currGetSetVar=getsetParser.parse(getsetIOCell{kCell},kCell);
                obj.registerGlobal(getsetParser,currGetSetVar);
            end
        end


        function[isGlobal,idx]=ParamIsGlobal(obj,id)



            globalParams=arrayfun(@(x)x.VarSpec.Data.Id,obj.Parameters);
            flags=(uint32(id)==globalParams);
            idx=find(flags);
            isGlobal=~isempty(idx);
        end

    end

    methods(Access=private)
        function registerGlobal(obj,lParser,currGlobalVar)

            switch lParser.DataKind
            case legacycode.lct.spec.DataKind.Input
                obj.Inputs(end+1)=currGlobalVar;
            case legacycode.lct.spec.DataKind.Output
                obj.Outputs(end+1)=currGlobalVar;
            case legacycode.lct.spec.DataKind.DSM
                obj.DataStores(end+1)=currGlobalVar;
            case legacycode.lct.spec.DataKind.Parameter
                obj.Parameters(end+1)=currGlobalVar;
            end
        end
    end

    methods
        function hasPointerIO=get.HasPointerIO(obj)


            hasPointerIO=~isempty([obj.Inputs,obj.Outputs]);
        end

        function hasDSMs=get.HasDSMs(obj)
            hasDSMs=~isempty(obj.DataStores);
        end

        function hasGlobalOutputs=get.HasGlobalOutputs(obj)

            hasGlobalOutputs=~isempty(obj.Outputs);
        end
    end
end
