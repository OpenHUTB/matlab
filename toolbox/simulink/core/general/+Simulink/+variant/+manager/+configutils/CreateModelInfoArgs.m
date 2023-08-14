classdef(Sealed)CreateModelInfoArgs<handle






    methods

        function obj=CreateModelInfoArgs(rootPathPrefix,useTempWS,ignoreErrors,hotlinkErrors,calledFromTool,blocksPathsInModel,configuration)

            obj.FullNameToRowMap=containers.Map();
            obj.MdlRefBlocksData=[];
            obj.BlocksPathsInModel=blocksPathsInModel;

            obj.RootPathPrefix=rootPathPrefix;
            obj.UseTempWS=useTempWS;
            obj.IgnoreErrors=ignoreErrors;
            obj.HotlinkErrors=hotlinkErrors;
            obj.CalledFromTool=calledFromTool;
            obj.Configuration=configuration;
        end

        function errors=getLoggedErrors(obj)



            nErrors=numel(obj.ErrorLog);
            errors=cell(1,nErrors);
            for idx=1:nErrors
                tmpErr=obj.ErrorLog(idx);
                errors{idx}=struct('PathInModel',tmpErr.PathInModel,...
                'PathInHierarchy',tmpErr.PathInHierarchy,...
                'Exception',tmpErr.Exception);
            end
        end

    end

    properties


        ErrorLog(1,:)Simulink.variant.manager.errorutils.ValidationError

FullNameToRowMap

MdlRefBlocksData

BlocksPathsInModel

RootPathPrefix

UseTempWS

IgnoreErrors

HotlinkErrors

CalledFromTool

Configuration

    end

end
