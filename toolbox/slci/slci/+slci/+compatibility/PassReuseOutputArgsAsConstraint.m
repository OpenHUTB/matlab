


classdef PassReuseOutputArgsAsConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Root outports may not be of non-auto storage class unless the parameter "PassReuseOutputArgsAs" is set to "Structure reference"';
        end

        function obj=PassReuseOutputArgsAsConstraint(varargin)
            obj.setEnum('PassReuseOutputArgsAs');
            obj.setCompileNeeded(1);
            obj.setFatal(0);


            obj.addPreRequisiteConstraint(slci.compatibility.HiddenBufferBlockConstraint);
            obj.addPreRequisiteConstraint(slci.compatibility.BusExpansionConstraint);
        end

        function out=check(aObj)
            out=[];
            badBlkStr='';
            badBlks={};
            if~strcmpi(get_param(aObj.ParentModel().getHandle(),...
                'ModelReferenceNumInstancesAllowed'),'Zero')&&...
                ~strcmpi(get_param(aObj.ParentModel().getHandle(),...
                'PassReuseOutputArgsAs'),'Structure reference')
                mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');
                outBlks=find_system(mdlHdl,'SearchDepth',1,'BlockType','Outport');
                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                for i=1:numel(outBlks)
                    if BlockSrcNonAutoSC(outBlks(i))
                        blkName=slci.compatibility.getFullBlockName(outBlks(i));
                        if~isempty(badBlkStr)
                            badBlkStr=[badBlkStr,', '];%#ok
                        end
                        badBlkStr=[badBlkStr,blkName];%#ok
                        badBlks{end+1}=outBlks(i);%#ok
                    end
                end
                delete(sess);
                if~isempty(badBlks)
                    out=slci.compatibility.Incompatibility(...
                    aObj,'PassReuseOutputArgsAs',aObj.ParentModel().getName(),badBlkStr);
                    out.setObjectsInvolved(badBlks);
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            RecAction=DAStudio.message('Slci:compatibility:PassReuseOutputArgsAsConstraintRecAction',aObj.ParentModel.getName);
            SubTitle=DAStudio.message('Slci:compatibility:PassReuseOutputArgsAsConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:PassReuseOutputArgsAsConstraintInfo');
            if status
                StatusText=DAStudio.message('Slci:compatibility:PassReuseOutputArgsAsConstraintPass');
            else
                StatusText=DAStudio.message('Slci:compatibility:PassReuseOutputArgsAsConstraintWarn');
            end
        end

    end
end


function result=BlockSrcNonAutoSC(blkH)
    result=0;
    pHArray=get_param(blkH,'PortHandles');
    pH=pHArray.Inport(1);
    inObj=get_param(pH,'Object');
    asObj=inObj.getActualSrc;
    numSrcs=size(asObj,1);
    if numSrcs==1
        srcPortHdl=asObj(1,1);
        if~strcmpi(get_param(srcPortHdl,'CompiledRTWStorageClass'),'auto')
            result=1;
            return;
        end
    end
end
