classdef BaseRegisterCGIRInspectors<handle





    properties(Access='protected')
        registeredInspectors={};



        checkIdToAlgorithmIdMap=containers.Map('KeyType','char','ValueType','any');
    end


    methods(Access='protected')



        function obj=BaseRegisterCGIRInspectors()
            obj.setupIDMap();
        end
    end

    methods(Access='public')

        function addInspectors(obj,ID)
            if iscell(ID)
                for i=1:length(ID)
                    obj.registeredInspectors{end+1}=ID{i};
                end
            else
                obj.registeredInspectors{end+1}=ID;
            end
        end


        function out=verifyRun(obj,ID)
            out=false;
            for i=1:length(obj.registeredInspectors)
                val=obj.getIDFromMap(obj.registeredInspectors{i});
                if~isempty(val)
                    for j=1:length(val)
                        if strcmpi(val{j},ID)
                            out=true;
                            return;
                        end
                    end
                end
                if strcmp(obj.registeredInspectors{i},...
                    ID)
                    out=true;
                    return;
                end
            end
        end

        function out=anyInspectorsRegistered(obj)
            out=~isempty(obj.registeredInspectors);
        end

        function clearInspectors(obj)
            obj.registeredInspectors={};
        end


        function delete(~)
        end

        function value=getIDFromMap(obj,ID)
            value=[];
            if isKey(obj.checkIdToAlgorithmIdMap,ID)
                value=obj.checkIdToAlgorithmIdMap(ID);
            end

        end

        function setupIDMap(obj)
            checkID='mathworks.codegen.ExpensiveSaturationRoundingCode';
            inspectors={'NODE_PRODUCT_ROUNDING';...
            'NODE_LOOKUP_ROUNDING';...
            'NODE_DTC_ROUNDING'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.codegen.QuestionableFxptOperations';
            inspectors={'NODE_CUMBERSOME_MULTIPLY';...
            'NODE_CUMBERSOME_DIVIDE';...
            'NODE_MULTIWORD_OPS';...
            'NODE_BOOLEAN_COUNT';...
            'NODE_LOOKUP_SPACING';...
            'NODE_PRELOOKUP_DIVISION';...
            'NODE_DATATYPE_CONVERSION';...
            'NODE_FIXPT_BINARY_RELOP';...
            'NODE_FIXPT_MINMAX';...
            'NODE_FIXPT_SUM_DATATYPE_MISMATCH';...
            'NODE_FIXPT_CMP_TO_CONST';...
            'LISTENER_FIXPT_RELOP';...
            'NODE_EMULATED_WORDLENGTH';};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;






            checkID='mathworks.misra.IntegerWordLengths';
            inspectors={'NODE_EMULATED_WORDLENGTH'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;



            checkID='mathworks.misra.CompliantCGIRConstructions';
            inspectors={'NODE_SIGNED_BITOPS'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.misra.RecursionCompliance';
            inspectors={'NODE_FCN_RECURSION'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.hism.hisf_0004';
            inspectors={'NODE_FCN_RECURSION'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.misra.CompareFloatEquality';
            inspectors={'NODE_FLOAT_EQUALITY'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.design.StowawayDoubles';
            inspectors={'NODE_STOWAWAY_DOUBLE'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;






            checkID='mathworks.security.CompareFloatEquality';
            inspectors={'NODE_FLOAT_EQUALITY'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.security.SignedBitwiseOperators';
            inspectors={'NODE_SIGNED_BITOPS'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

            checkID='mathworks.security.IntegerWordLengths';
            inspectors={'NODE_EMULATED_WORDLENGTH'};
            obj.checkIdToAlgorithmIdMap(checkID)=inspectors;

        end
    end

end
