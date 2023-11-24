classdef DataTypeConstraintsWrapper<handle

    properties(SetAccess=private)
originalConstraint
isSigned

    end

    methods
        function this=DataTypeConstraintsWrapper(constraint)

            this.originalConstraint=constraint;
        end

        function signed=get.isSigned(this)

            signed=this.originalConstraint.isSigned;
        end

        function[wl,fl]=getAllowableWordLengths(this)


            switch(this.originalConstraint.Index)




            case{SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.HardwareConstraint,...
                SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.SpecificConstraint}
                wl=this.originalConstraint.SpecificWL';


                if isempty(this.originalConstraint.SpecificFL)



                    fl=cell(numel(wl),1);
                else

                    fl=arrayfun(@(x)(x),repmat(this.originalConstraint.SpecificFL,numel(wl),1),'UniformOutput',false);
                end

            case SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.MonotonicityConstraint



                wl=zeros(numel(this.originalConstraint.ChildConstraint),1);
                fl=cell(numel(this.originalConstraint.ChildConstraint),1);
                for cIndex=1:numel(this.originalConstraint.ChildConstraint)
                    wl(cIndex)=this.originalConstraint.ChildConstraint(cIndex).SpecificWL;
                    fl{cIndex}=this.originalConstraint.ChildConstraint(cIndex).SpecificFL;
                end
            end

        end
    end

end