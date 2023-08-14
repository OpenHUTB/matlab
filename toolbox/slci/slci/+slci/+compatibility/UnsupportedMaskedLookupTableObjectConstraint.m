




classdef UnsupportedMaskedLookupTableObjectConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok<MANU>
            out='Do not pass a Simulink.LookupTable to a masked SubSystem or Reference block.';
        end


        function obj=UnsupportedMaskedLookupTableObjectConstraint()
            obj.setEnum('UnsupportedMaskedLookupTableObject');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end


        function out=check(aObj)
            out=[];
            blk=aObj.ParentBlock;
            if any(strcmp(blk.getParam('BlockType'),{'SubSystem','ModelReference'}))...
                &&strcmp(blk.getParam('Mask'),'on')



                maskParams=slci.internal.getBlockParamInfoFromMask(blk.getHandle,false);
                if isempty(maskParams)
                    return;
                else
                    assert(numel(maskParams)==2);
                end
                maskParamValues=maskParams{2};
                for i=1:numel(maskParamValues)
                    if iscell(maskParamValues)
                        maskParamValue=maskParamValues{i};
                    else
                        maskParamValue=maskParamValues;
                    end
                    try
                        lutObj=slResolve(maskParamValue,blk.getSID);
                    catch
                        continue;
                    end
                    if isa(lutObj,'Simulink.LookupTable')
                        out=slci.compatibility.Incompatibility(...
                        aObj,...
                        'UnsupportedMaskedLookupTableObject');
                        return;
                    end
                end
            end
        end

    end

end
