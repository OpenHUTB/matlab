classdef(Sealed)DirectLUDBUnit<FunctionApproximation.internal.database.LUTDBUnit





    methods
        function stringValue=tostring(this,options)
            gridSizeString=mat2str(this.GridSize);
            breakpointWLs=mat2str(this.StorageWordLengths(1:end-1));
            tableDataWLs=num2str(this.StorageWordLengths(end),'%.0f');
            stringValue=sprintf(...
            getFormatSpec(this),...
            num2str(this.ID,'%.0f'),...
            num2str(getObjectiveValue(this,options),getMemoryFormatSpec(this,options)),...
            num2str(this.ConstraintMet,'%.0f'),...
            gridSizeString,...
            breakpointWLs,...
            tableDataWLs,...
            sprintf('%.6e, %.6e',this.ConstraintValueMustBeLessThan(1),this.ConstraintValue(1)));
        end

        function header=getHeader(this,options)
            header=sprintf(getFormatSpec(this),'ID',getMemoryHeader(this,options),'Feasible','Table Size','Intermediate WLs','TableData WL','Error(Max,Current)');
        end

        function tableFormatSpec=getFormatSpec(~)
            tableFormatSpec='| %+3s | %+14s | %+8s | %+12s | %+16s | %+12s | %+30s |';
        end
    end
end


