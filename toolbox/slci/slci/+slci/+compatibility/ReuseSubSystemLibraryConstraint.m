




classdef ReuseSubSystemLibraryConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['Reusable subsystems must be from library, '...
            ,'and reuse subsystems with same function interface'...
            ,'must be from same library'];
        end


        function aObj=ReuseSubSystemLibraryConstraint()
            aObj.setEnum('ReuseSubSystemLibrary');
            aObj.setCompileNeeded(0);
            aObj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            mdl=aObj.getOwner;
            assert(isa(mdl,'slci.simulink.Model'));
            subsystems=mdl.getBlockType('SubSystem');

            subLibSIDs=containers.Map;
            failedFNames={};

            blkHdls=containers.Map;
            for i=1:numel(subsystems)
                sub=subsystems{i};
                blkH=sub.getHandle();
                RTWSystemCode=get_param(blkH,'RTWSystemCode');
                if strcmpi(RTWSystemCode,'Reusable function')...
                    &&strcmpi(get_param(blkH,'RTWFcnNameOpts'),'User specified')

                    fName=get_param(blkH,'RTWFcnName');

                    if aObj.isFromLib(blkH)


                        blkObj=get_param(blkH,'Object');
                        libSID=slci.internal.getLibSID(blkObj);
                        if isKey(subLibSIDs,fName)
                            if~strcmpi(libSID,subLibSIDs(fName))

                                if isempty(failedFNames)...
                                    ||~ismember(failedFNames,fName)

                                    failedFNames{end+1}=fName;%#ok
                                end
                            end
                        else
                            subLibSIDs(fName)=libSID;
                        end


                        if isKey(blkHdls,fName)
                            blkHdls(fName)=[blkHdls(fName),{blkH}];
                        else
                            blkHdls(fName)={blkH};
                        end
                    end
                end
            end

            if~isempty(failedFNames)
                keyStr=keys(subLibSIDs);
                badBlks={};
                for i=1:numel(keyStr)
                    fName=keyStr{i};
                    if any(ismember(failedFNames,fName))
                        badBlks=[badBlks,blkHdls(fName)];%#ok
                    end
                end
                out=slci.compatibility.Incompatibility(aObj,...
                aObj.getEnum(),aObj.ParentModel().getName());
                out.setObjectsInvolved(badBlks);
            end
        end
    end

    methods(Access=private)

        function out=isFromLib(~,blkHdl)
            linkStatus=get_param(blkHdl,'LinkStatus');
            out=(strcmpi(linkStatus,'implicit')...
            ||strcmpi(linkStatus,'resolved'));
        end
    end
end
