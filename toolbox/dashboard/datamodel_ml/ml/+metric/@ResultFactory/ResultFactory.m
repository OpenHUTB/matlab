classdef ResultFactory < handle
    properties ( Hidden, Access = private )
        mf_model;
        resultFactory;
    end

    methods ( Access = public )
        function obj = ResultFactory( varargin )
            if ( nargin == 0 )
                obj.mf_model = mf.zero.Model;
            else
                obj.mf_model = varargin{ 1 };
            end
            obj.resultFactory = metric.internal.ResultFactory.get( obj.mf_model );
        end

        function result = createResult( obj, metricID, artifacts )
            arguments
                obj metric.ResultFactory
                metricID char
                artifacts alm.Artifact
            end


            mfResult = obj.resultFactory.createResult( metricID, artifacts );
            result = metric.Result( obj.mf_model );
            result.setMfResult( mfResult );
        end

    end
end


