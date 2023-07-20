classdef DecoupledSubsystemListDisplayStrategy<handle






    properties(Constant)
        DisplayFormatSpec='%s'
    end

    properties(SetAccess=private)
        DisplayCell cell
        List cell
    end

    methods
        function this=DecoupledSubsystemListDisplayStrategy(tableData)
            if~(isa(tableData,'table')&&any(ismember(tableData.Properties.VariableNames,'BlockPath')))
                diagnostic=MException(message('SimulinkFixedPoint:autoscaling:invalidTableForDecoupledSubsystemDisplay'));
                diagnostic.throw();
            end

            if feature('hotlinks')

                linkText=@(x)FunctionApproximation.internal.ui.Utils.getHyperLinkToLaunchLUTO(x);
            else

                linkText=@(x)x;
            end



            this.List=tableData.BlockPath;
            prefixFunction=@(x)[num2str(x),'. '];
            for k=1:numel(this.List)
                this.List{k}=[prefixFunction(k),linkText(this.List{k})];
            end
        end

        function constructDisplayList(this)

            this.DisplayCell=cell(1,numel(this.List)+1);
            this.DisplayCell{1}=newline;
            for k=1:numel(this.List)
                this.DisplayCell{k+1}=sprintf('\t%s\n',this.List{k});
            end
        end

        function displayList(this)

            for k=1:numel(this.DisplayCell)
                fprintf(this.DisplayFormatSpec,this.DisplayCell{k});
            end
        end
    end
end
