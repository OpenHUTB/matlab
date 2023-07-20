


classdef VVSubSystemNameConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Void void subsystems cannot use the same function name';
        end


        function obj=VVSubSystemNameConstraint(varargin)
            obj.setEnum('VVSubSystemName');
            obj.setCompileNeeded(1);
            obj.setFatal(true);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner;
            assert(isa(owner,'slci.simulink.Model'));
            subsystems=owner.getBlockType('SubSystem');

            sysFuncHdls=containers.Map;

            blkHdls=containers.Map;
            for i=1:numel(subsystems)
                blkH=subsystems{i}.getHandle();


                if slci.internal.isSupportedNonReusableSubsystem(blkH)

                    fName=get_param(blkH,'RTWFcnName');
                    sysName=get_param(blkH,'Name');
                    if isKey(sysFuncHdls,fName)
                        if~isKey(blkHdls,fName)

                            blkHdls(fName)={sysFuncHdls(fName)};
                            blkStr=[get_param(sysFuncHdls(fName),'Name'),', '];
                        end

                        blkHdls(fName)=[blkHdls(fName),{blkH}];
                        blkStr=[blkStr,sysName];%#ok;
                    else
                        sysFuncHdls(fName)=blkH;
                    end
                end
            end

            if~isempty(blkHdls)
                badBlks={};

                keyStr=keys(blkHdls);
                for i=1:numel(keyStr)
                    badBlks=[badBlks,blkHdls(keyStr{i})];%#ok
                end
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),aObj.ParentModel().getName(),blkStr);
                out.setObjectsInvolved(badBlks);
            end
        end
    end
end
