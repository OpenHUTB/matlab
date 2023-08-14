


classdef MinMaxLoggingConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fFailureType=-1;
    end

    methods

        function out=getDescription(aObj)%#ok
            out='If BlockReduction is set to ''on'', then you should disable fixed-point instrumentation for the entire model to eliminate a potential incompatibility';
        end

        function obj=MinMaxLoggingConstraint(varargin)
            obj.setEnum('MinMaxLogging');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            bred=get_param(aObj.ParentModel().getHandle(),'BlockReduction');
            logging=get_param(aObj.ParentModel().getHandle(),'MinMaxOverflowLogging');
            if strcmpi(bred,'on')
                switch logging
                case 'ForceOff'

                case{'MinMaxAndOverflow','OverflowOnly'}

                    out=slci.compatibility.Incompatibility(...
                    aObj,'MinMaxLoggingModel',...
                    aObj.ParentModel().getName(),logging);
                    aObj.fFailureType=0;

                case 'UseLocalSettings'

                    ssBlocks=aObj.ParentModel().getBlockType('SubSystem');
                    set=slci.compatibility.UniqueBlockSet;


                    for blkidx=1:numel(ssBlocks)
                        blockObj=ssBlocks{blkidx};
                        blkH=blockObj.getParam('Handle');
                        blkLogging=get_param(...
                        blkH,'MinMaxOverflowLogging_Compiled');
                        switch blkLogging
                        case{'ForceOff','UseLocalSettings'}

                        case{'MinMaxAndOverflow','OverflowOnly'}

                            set.AddBlock(blkH);
                            aObj.fFailureType=1;

                        end
                    end


                    if set.GetLength()>0
                        out=[out,slci.compatibility.Incompatibility(...
                        aObj,...
                        'MinMaxLoggingBlocks',...
                        aObj.ParentModel().getName(),set.GetBlockStr())];
                        out.setObjectsInvolved(set.GetBlockCell());
                    end
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:MinMaxLoggingConstraintRecAction');
            SubTitle=DAStudio.message('Slci:compatibility:MinMaxLoggingConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:MinMaxLoggingConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:MinMaxLoggingConstraintPass');
            else
                if aObj.fFailureType==0
                    logging=get_param(aObj.ParentModel().getHandle(),'MinMaxOverflowLogging');
                    StatusText=DAStudio.message('Slci:compatibility:MinMaxLoggingModelConstraintWarn',logging);
                else
                    StatusText=DAStudio.message('Slci:compatibility:MinMaxLoggingBlockConstraintWarn');
                end
            end
        end

    end
end
