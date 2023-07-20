classdef Result<DataTypeWorkflow.Single.AbstractResult





    properties
        SpecifiedDT=''
        CompiledDT=''
        ProposedDT=''
        Accepted=false;



        ErrorMsgs={}
    end


    methods(Access=public)

        function res=Result(ID)

            res@DataTypeWorkflow.Single.AbstractResult(ID);
        end
    end


    methods
        function set.SpecifiedDT(res,dType)

            DataTypeWorkflow.Single.Result.validateDT(dType);
            res.SpecifiedDT=dType;
        end

        function set.CompiledDT(res,dType)

            DataTypeWorkflow.Single.Result.validateDT(dType);
            res.CompiledDT=dType;
        end

        function set.ProposedDT(res,dType)

            DataTypeWorkflow.Single.Result.validateDT(dType);
            res.ProposedDT=dType;
        end

        function set.ErrorMsgs(res,dType)


            assert(iscell(dType)&&(isempty(dType)||isrow(dType)));



            for i=1:numel(dType)
                DataTypeWorkflow.Single.Result.validateDT(dType{i});
            end
            res.ErrorMsgs=dType;
        end

        function res=updateResult(res,data)

            validateattributes(data,{'struct'},{'scalar','nonempty'});
            if(isfield(data,'SpecifiedDT'))
                res.SpecifiedDT=data.SpecifiedDT;
            end
            if(isfield(data,'CompiledDT'))
                res.CompiledDT=data.CompiledDT;
            end
            if(isfield(data,'ProposedDT'))
                res.ProposedDT=data.ProposedDT;
            end
            if(isfield(data,'ErrorMsgs'))
                res.ErrorMsgs=data.ErrorMsgs;
            end
        end

        function autoscaler=getAutoscaler(res,asExtension)
            autoscaler=asExtension.getAutoscaler(res.ID.getObject());
        end
    end


    methods(Static)
        function validateDT(dType)

            validateattributes(dType,{'char'},{'row','nonempty'});
        end
    end
end


