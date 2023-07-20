











classdef InitialConditionsConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fInitialConditionName='';
    end

    methods

        function out=getDescription(aObj)%#ok
            out=['The block initial conditions'...
            ,' must be zero, non-zero scalar or structure with the'...
            ,' same type of output data'];
        end


        function obj=InitialConditionsConstraint(aICName)
            obj.setEnum('InitialConditions');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.fInitialConditionName=aICName;
        end


        function out=check(aObj)
            out=[];
            blk=aObj.ParentBlock();

            ic=blk.getParam(aObj.fInitialConditionName);
            try
                ic_val=slResolve(ic,blk.getSID());
            catch
                ic_val=[];
            end



            if~isstruct(ic_val)
                return;
            end



            pt_dt=blk.getParam('CompiledPortDataTypes');
            assert(~isempty(pt_dt));
            out_dt=pt_dt.Outport{1};

            try
                out_val=slResolve(out_dt,aObj.ParentBlock.getSID);
            catch
                out_val=[];
            end

            parentModel=blk.ParentModel;

            same_struct=false;
            if isa(out_val,'Simulink.Bus')||isstruct(out_val)
                if isa(out_val,'Simulink.Bus')
                    dataAccessor=Simulink.data.DataAccessor.create(parentModel.getName);
                    out_val=Simulink.Bus.createMATLABStruct(out_dt,[],[1,1],dataAccessor);
                end

                same_struct=aObj.isSameStruct(out_val,ic_val);

            end
            if~same_struct
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end

    end

    methods(Access=private)

        function out=isSameStruct(aObj,out_struct,ic_struct)
            out=true;

            out_fn=fieldnames(out_struct);
            ic_fn=fieldnames(ic_struct);

            if numel(out_fn)~=numel(ic_fn)
                out=false;
                return
            end

            for i=1:numel(out_fn)
                out_field=out_struct.(out_fn{i});
                ic_field=ic_struct.(ic_fn{i});
                if isstruct(out_field)&&isstruct(ic_field)
                    out=aObj.isSameStruct(out_field,ic_field);
                elseif isstruct(out_field)||isstruct(ic_field)

                    out=false;
                else

                    out=strcmpi(out_fn(i),ic_fn(i));
                end

                if~out
                    return;
                end
            end

        end

    end
end
