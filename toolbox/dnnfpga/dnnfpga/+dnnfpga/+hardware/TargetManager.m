classdef TargetManager<handle




    properties(Access=protected)
        TargetMap=[];
    end

    methods(Access=public,Static)
        function hTargetManager=getInstance()
            persistent hTM
            if isempty(hTM)
                hTM=dnnfpga.hardware.TargetManager();
            end
            hTargetManager=hTM;
        end

        function targetID=getNewTargetID(vendor)
            obj=dnnfpga.hardware.TargetManager.getInstance();
            targetIDList=obj.getTargetIDList;
            numList=str2double(extractAfter(targetIDList,vendor));
            maxNum=max(numList);
            if isempty(maxNum)||isnan(maxNum)
                maxNum=0;
            end
            targetID=[vendor,num2str(maxNum+1)];
        end

        function targetIDList=getAllTargetIDs()
            obj=dnnfpga.hardware.TargetManager.getInstance();
            targetIDList=obj.getTargetIDList();
        end

        function addTargetStatic(hTarget)
            obj=dnnfpga.hardware.TargetManager.getInstance();
            obj.addTarget(hTarget);
        end

        function removeTargetStatic(hTarget)
            obj=dnnfpga.hardware.TargetManager.getInstance();
            obj.removeTarget(hTarget);
        end

        function releaseAllTargets()
            obj=dnnfpga.hardware.TargetManager.getInstance();
            obj.releaseTarget();
        end
    end

    methods(Access=protected)
        function obj=TargetManager()

            obj.clearTargetMap;
        end

        function clearTargetMap(obj)
            obj.TargetMap=containers.Map();
        end

        function targetIDList=getTargetIDList(obj)
            targetIDList=obj.TargetMap.keys;
        end

        function addTarget(obj,hTarget)

            targetID=hTarget.TargetID;
            if~obj.TargetMap.isKey(targetID)
                obj.TargetMap(targetID)=hTarget;
            else
                error(message('hdlcommon:plugin:DuplicateInterfaceID',targetID));
            end
        end

        function removeTarget(obj,hTarget)

            targetID=hTarget.TargetID;
            if obj.TargetMap.isKey(targetID)
                obj.TargetMap.remove(targetID);
            end
        end

        function hTarget=getTarget(obj,targetID)
            if obj.TargetMap.isKey(targetID)
                hTarget=obj.TargetMap(targetID);
            else
                error(message('hdlcommon:plugin:InvalidInterfaceID',targetID));
            end
        end

        function releaseTarget(obj,targetIDList)

            if nargin<2
                targetIDList=obj.getTargetIDList;
            end


            if~iscell(targetIDList)
                targetIDList={targetIDList};
            end

            for ii=1:length(targetIDList)
                release(obj.getTarget(targetIDList{ii}));
            end
        end
    end
end
