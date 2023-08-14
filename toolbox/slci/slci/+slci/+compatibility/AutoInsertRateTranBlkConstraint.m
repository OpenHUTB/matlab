
classdef AutoInsertRateTranBlkConstraint<slci.compatibility.PositiveModelParameterConstraint




    methods

        function this=AutoInsertRateTranBlkConstraint(aFatal,aParameterName,varargin)
            this=this@slci.compatibility.PositiveModelParameterConstraint(aFatal,aParameterName,varargin{:});
            this.setEnum('AutoInsertRateTranBlk');
        end


        function out=check(this)
            out=[];


isUnconstrained...
            =strcmpi(this.ParentModel().getParam('SampleTimeConstraint'),'Unconstrained');
            if isUnconstrained

                out=check@slci.compatibility.PositiveModelParameterConstraint(this);
            end
        end
    end
end
