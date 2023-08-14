classdef(Sealed,Hidden)Environment






    properties(Access=private)
        OpenedBDsAtStart={};
        DirtyBDsAtStart={};
        OpenedDDsAtStart={};
        DirtyDDsAtStart={};
    end

    methods

        function obj=Environment()
            [obj.OpenedBDsAtStart,obj.DirtyBDsAtStart]=Simulink.variant.utils.getOpenAndDirtyModels();
            [obj.OpenedDDsAtStart,obj.DirtyDDsAtStart]=Simulink.variant.utils.getOpenAndDirtyDataDictionaryFiles();
        end


        function delete(obj)

            [openedBDsAtEnd,~]=Simulink.variant.utils.getOpenAndDirtyModels();
            bdsToBeClosed=setdiff(openedBDsAtEnd,obj.OpenedBDsAtStart);
            close_system(bdsToBeClosed,0);

            [openedDDsAtEnd,~]=Simulink.variant.utils.getOpenAndDirtyDataDictionaryFiles();
            ddsToBeClosed=setdiff(openedDDsAtEnd,obj.OpenedDDsAtStart);
            for i=1:numel(ddsToBeClosed)
                [~,ddName,ddExt]=fileparts(ddsToBeClosed{i});
                Simulink.data.dictionary.closeAll([ddName,ddExt],'-discard');
            end
        end
    end
end

