classdef CrlCache<handle






    properties(Constant,Access=private)

        instance=autosar.routines.CrlCache();
    end

    properties(Access=private)
        CrlName;
        CrlFunctionNames;
    end

    methods(Static)

        function obj=getInstance()
            obj=autosar.routines.CrlCache.instance;
        end
    end

    methods
        function isInCRL=isFuncInCRL(self,model,targetedRoutine)
            if self.crlNeedsUpdate(model)
                self.refreshFunctionNames(model);
            end


            isInCRL=any(startsWith(self.CrlFunctionNames,targetedRoutine));
        end

        function isInCRL=isBlockFuncInCRL(self,model,block)
            targetedRoutine=get_param(block,'TargetedRoutine');
            isInCRL=self.isFuncInCRL(model,targetedRoutine);
        end
    end

    methods(Access=private)
        function self=CrlCache()
            self.CrlName='None';
            self.CrlFunctionNames={};
        end

        function refreshFunctionNames(self,model)
            tflControl=get_param(model,'RtwTargetFcnLibHandle');
            functionNames=arrayfun(@(x)self.getFunctionNamesFromTflTable(x),tflControl.TflTables,'UniformOutput',false);

            self.CrlFunctionNames=unique(vertcat(functionNames{:}));
            self.CrlName=tflControl.LoadedLibrary;
        end

        function needsUpdate=crlNeedsUpdate(self,model)
            tflControl=get_param(model,'RtwTargetFcnLibHandle');
            needsUpdate=~strcmp(tflControl.LoadedLibrary,self.CrlName);
        end
    end

    methods(Static,Access=private)
        function functionNames=getFunctionNamesFromTflTable(tflTable)
            functionNames=[];

            allEntries=tflTable.AllEntries;
            if numel(allEntries)<1
                return;
            end



            hasImpl=~isempty(allEntries(1).Implementation);
            if hasImpl
                functionNames=arrayfun(@(x)x.Implementation.Name,allEntries,'UniformOutput',false);
            end
        end
    end
end


