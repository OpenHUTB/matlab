classdef PositionStoreMediator<handle






    properties(SetAccess=private,GetAccess=public)
PositionSuppliers
    end

    methods(Access=public,Static)
        function toReturn=getInstance()
            mlock;
            persistent instance
            if isempty(instance)
                instance=slxmlcomp.internal.highlight.PositionStoreMediator();
            end
            toReturn=instance;
        end
    end

    methods(Access=public)

        function cleanup=addPositionSupplier(obj,positionId,supplier)


            cleanup=[];
            if any(positionId==["Left","Right","Report"])
                obj.PositionSuppliers.(positionId)=supplier;
                cleanup=onCleanup(@()obj.removePositionSupplier(positionId,supplier));
            end
        end

        function removePositionSupplier(obj,positionId,supplier)
            if isequal(obj.PositionSuppliers.(positionId),supplier)
                obj.PositionSuppliers.(positionId)=@returnEmpty;
            end
        end

        function registerWithStoreWindowPositions(obj)
            import slxmlcomp.internal.highlight.CurrentWindowPositionSupplier;

            function positions=supplyPositions()
                positions=struct(...
                "Left",obj.PositionSuppliers.Left(),...
                "Right",obj.PositionSuppliers.Right(),...
                "Report",obj.PositionSuppliers.Report()...
                );
            end

            CurrentWindowPositionSupplier.setInstance(@supplyPositions);
        end

    end


    methods(Access=private)
        function obj=PositionStoreMediator()
            obj.PositionSuppliers=createEmptySuppliers();
        end
    end
end

function empty=returnEmpty()
    empty=[];
end

function suppliers=createEmptySuppliers()

    suppliers=struct(...
    "Left",@returnEmpty,...
    "Right",@returnEmpty,...
    "Report",@returnEmpty...
    );
end
