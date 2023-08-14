classdef ModelMappingMatcher<handle











    properties(Constant)
        mark_delete_fcn=@(blkPath)autosar.mm.mm2sl.SLModelBuilder.markBlkDeletion(blkPath);

        delete_fcn=@(blkPath)delete_block(blkPath);




        no_mark_fcn=@(~)[];
    end

    properties(Access=protected)
ModelName
    end

    methods(Abstract)
        markAsUnmatched(this)
        [isMapped,varargout]=isMapped(this,varargin)
        logDeletions(this,changeLogger,autoDelete)
    end

    methods
        function this=ModelMappingMatcher(modelName)
            this.ModelName=modelName;
        end
    end

    methods(Access=protected)
        function logManualBlkDeletions(this,unmatchedElements,blockTypeStr,markMode,changeLogger)
            if isempty(unmatchedElements)
                return;
            end
            if iscell(unmatchedElements)
                blkPaths=unmatchedElements;
            else
                blkPaths=unmatchedElements.getKeys();
            end
            for ii=1:length(blkPaths)
                blkPath=blkPaths{ii};

                switch markMode
                case 'MarkBlockForDeleteAndComment'
                    autosar.updater.ModelMappingMatcher.mark_delete_fcn(blkPath);
                    set_param(blkPath,'Commented','on');
                    changeLogger.logDeletion('Manual',blockTypeStr,autosar.updater.Report.getBlkHyperlink(blkPath),this.ModelName);
                case 'MarkBlockForDelete'
                    autosar.updater.ModelMappingMatcher.mark_delete_fcn(blkPath);
                    changeLogger.logDeletion('Manual',blockTypeStr,autosar.updater.Report.getBlkHyperlink(blkPath),this.ModelName);
                case 'MarkForDelete'
                    autosar.updater.ModelMappingMatcher.no_mark_fcn(blkPath);
                    changeLogger.logDeletion('Manual',blockTypeStr,blkPath,this.ModelName);
                case 'AutoDelete'
                    autosar.updater.ModelMappingMatcher.delete_fcn(blkPath);
                    changeLogger.logDeletion('Automatic',blockTypeStr,blkPath);
                case 'DeleteBlockAndLeafs'
                    autosar.updater.SLCompositionMatcher.deleteBlockAndLeafElements(blkPath);
                    changeLogger.logDeletion('Automatic',blockTypeStr,blkPath);
                case 'NoMark'
                    autosar.updater.ModelMappingMatcher.no_mark_fcn(blkPath);
                    changeLogger.logDeletion('Manual',blockTypeStr,blkPath,this.ModelName);
                otherwise
                    assert(false,'Unexpected marking mode');
                end
            end
        end
    end
end
