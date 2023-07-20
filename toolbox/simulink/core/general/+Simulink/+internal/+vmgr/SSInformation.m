classdef(Hidden)SSInformation<handle







    properties(Access=private,Hidden)
        mBlockPathOrModelName=[];
        mIsReadOnly=false;
        mIsLinked=false;
        mIsLinkedToMasked=false;
        mReferencedSubsystemName=[];
        mReferencedSubsystemInfo=[];
    end

    methods(Access=public,Hidden)
        function obj=SSInformation(blockPathOrModelName)
            if isempty(blockPathOrModelName)||getSimulinkBlockHandle(blockPathOrModelName)==-1


                return;
            end
            obj.mBlockPathOrModelName=blockPathOrModelName;
            if strcmp(get_param(obj.mBlockPathOrModelName,'Type'),'block')&&...
                strcmp(get_param(obj.mBlockPathOrModelName,'BlockType'),'SubSystem')


                obj.mIsReadOnly=obj.getReadOnlyStatus();
                [obj.mIsLinked,obj.mIsLinkedToMasked]=obj.getLinkStatus();


                obj.mReferencedSubsystemName=get_param(blockPathOrModelName,'ReferencedSubsystem');

                if~isempty(obj.mReferencedSubsystemName)
                    try
                        load_system(obj.mReferencedSubsystemName);

                        obj.mReferencedSubsystemInfo=slInternal('getSRGraphLockInfo',get_param(obj.mReferencedSubsystemName,'handle'));

                        obj.mReferencedSubsystemInfo.GraphPathCausingLock=strrep(obj.mReferencedSubsystemInfo.GraphPathCausingLock,newline,' ');


                        isSSRefFileDirty=slInternal('isSRGraphBeingEdited',get_param(obj.mReferencedSubsystemName,'handle'));


                        obj.mReferencedSubsystemInfo.Locked=obj.mReferencedSubsystemInfo.Locked||isSSRefFileDirty;



                    catch


                        obj.mReferencedSubsystemInfo=struct('Locked',false,'GraphPathCausingLock','');
                    end
                end
            end
        end


        function javaObj=toJava(obj)
            javaObj=java.util.HashMap;
            javaObj.put('IsReadOnly',obj.mIsReadOnly);
            javaObj.put('IsLinked',obj.mIsLinked);
            javaObj.put('IsLinkedToMasked',obj.mIsLinkedToMasked);


            if isempty(obj.mReferencedSubsystemName)
                javaObj.put('ReferencedSubsystemName','');
            else
                javaObj.put('ReferencedSubsystemName',java.lang.String(obj.mReferencedSubsystemName));
            end

            if~isempty(obj.mReferencedSubsystemName)
                referencedSubsystemInfos=fieldnames(obj.mReferencedSubsystemInfo);
                for i=1:numel(referencedSubsystemInfos)
                    key=java.lang.String(['ReferencedSubsystemInfo_',referencedSubsystemInfos{i}]);
                    value=obj.mReferencedSubsystemInfo.(referencedSubsystemInfos{i});
                    javaObj.put(key,value);
                end
                javaObj.put(['ReferencedSubsystemInfo_','BlockPathRootModel'],java.lang.String(obj.mBlockPathOrModelName));
            end
        end


        function isSubsystemReference=getIsSubsystemReference(obj)
            isSubsystemReference=~isempty(obj.mReferencedSubsystemName);
        end
    end

    methods(Access=private,Hidden)


        function isReadOnly=getReadOnlyStatus(obj)
            try
                permissions=get_param(obj.mBlockPathOrModelName,'Permissions');
                isReadOnly=any(strcmp(permissions,{'ReadOnly','NoReadOrWrite'}));
            catch
                isReadOnly=false;
            end
        end



        function[isLinked,isLinkedToMasked]=getLinkStatus(obj)
            isLinked=false;
            isLinkedToMasked=false;
            linkStatus=get_param(obj.mBlockPathOrModelName,'LinkStatus');
            if strcmp(linkStatus,'resolved')
                isLinked=true;
                if strcmp(get_param(obj.mBlockPathOrModelName,'Mask'),'on')


                    [topMaskObj,canCreateMaskOnInstanceBlock]=Simulink.Mask.get(obj.mBlockPathOrModelName);
                    isLinkedToMasked=~isempty(topMaskObj)&&(canCreateMaskOnInstanceBlock||~isempty(topMaskObj.BaseMask));
                end
            end
        end
    end
end


