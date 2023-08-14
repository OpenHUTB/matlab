




classdef ModelRefAdvisorData<handle
    properties(Transient,SetAccess=public,GetAccess=public)
Systems
SIDs
ModelRefCheckFactory
CheckResults


        Snapshots={}
        SnapshotDir={}
        SnapshotInfoMat={}
    end


    methods(Access=public)
        function this=ModelRefAdvisorData(mdladvObj,subsys)
            this.Systems=subsys;
            this.SIDs=Simulink.ModelReference.Conversion.Utilities.cellify(...
            arrayfun(@(ss)Simulink.ID.getSID(ss),this.Systems,'UniformOutput',false));
            this.ModelRefCheckFactory=Simulink.ModelReference.Conversion.AdvisorCheckFactory(mdladvObj,subsys);
            this.CheckResults=[];
        end
    end
end
