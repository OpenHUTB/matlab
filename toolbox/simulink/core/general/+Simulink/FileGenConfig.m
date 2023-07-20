classdef FileGenConfig<hgsetget




    properties
        CacheFolder='';
        CodeGenFolder='';
        CodeGenFolderStructure Simulink.filegen.CodeGenFolderStructure=Simulink.filegen.CodeGenFolderStructure.getDefault();
    end
    properties(Transient=true,Hidden=true)
        ReadOnly=false;
    end
    properties(Hidden=true)
        UseConfigSetNameForTgtFolder=false;
        ForceParallelModelReferenceBuildsForTesting=false;
    end
    methods(Hidden=true,Static=true)



        function data=getPropListsForInputParser()


            persistent cachedData
            if isempty(cachedData)
                cachedData={{'CacheFolder','',@ischar},...
                {'CodeGenFolder','',@ischar},...
                {'UseConfigSetNameForTgtFolder',false,@islogical},...
                {'ForceParallelModelReferenceBuildsForTesting',...
                false,@islogical},...
                {'CodeGenFolderStructure',...
                Simulink.filegen.CodeGenFolderStructure.getDefault(),...
                @(v)isa(v,'Simulink.filegen.FolderSet')}};
            end
            data=cachedData;
        end
    end
    methods
        function obj=FileGenConfig()




            mlock;
        end



        function set.ReadOnly(obj,val)
            if~islogical(val)
                DAStudio.error('RTW:utility:invalidArgType','logical');
            end
            obj.ReadOnly=val;
        end




        function data=get.ReadOnly(obj)
            data=obj.ReadOnly;
        end




        function val=isReadOnly(obj)
            val=obj.ReadOnly;
        end




        function newObj=copy(obj)
            newObj=Simulink.FileGenConfig;
            newObj.CacheFolder=obj.CacheFolder;
            newObj.CodeGenFolder=obj.CodeGenFolder;
            newObj.UseConfigSetNameForTgtFolder=...
            obj.UseConfigSetNameForTgtFolder;
            newObj.ForceParallelModelReferenceBuildsForTesting=...
            obj.ForceParallelModelReferenceBuildsForTesting;
            newObj.CodeGenFolderStructure=...
            obj.CodeGenFolderStructure;
        end



        function set.CacheFolder(obj,val)
            if isReadOnly(obj)
                return;
            end
            if~ischar(val)
                DAStudio.error('RTW:utility:invalidArgType','char array');
            end


            obj.CacheFolder=val;
        end



        function set.CodeGenFolder(obj,val)
            if isReadOnly(obj)
                return;
            end
            if~ischar(val)
                DAStudio.error('RTW:utility:invalidArgType','char array');
            end


            obj.CodeGenFolder=val;
        end




        function set.UseConfigSetNameForTgtFolder(obj,val)
            if isReadOnly(obj)
                return;
            end
            if~islogical(val)
                DAStudio.error('RTW:utility:invalidArgType','logical');
            end
            obj.UseConfigSetNameForTgtFolder=val;
        end



        function data=get.UseConfigSetNameForTgtFolder(obj)
            data=obj.UseConfigSetNameForTgtFolder;
        end




        function set.ForceParallelModelReferenceBuildsForTesting(obj,val)
            if isReadOnly(obj)
                return;
            end
            if~islogical(val)
                DAStudio.error('RTW:utility:invalidArgType','logical');
            end
            obj.ForceParallelModelReferenceBuildsForTesting=val;
        end



        function data=get.ForceParallelModelReferenceBuildsForTesting(obj)
            data=obj.ForceParallelModelReferenceBuildsForTesting;
        end




        function set.CodeGenFolderStructure(obj,val)
            if isReadOnly(obj)
                return;
            end

            expectedType='Simulink.filegen.FolderSet';
            if~isa(val,expectedType)
                DAStudio.error('RTW:utility:invalidArgType',expectedType);
            end
            obj.CodeGenFolderStructure=val;
        end



        function data=get.CodeGenFolderStructure(obj)
            data=obj.CodeGenFolderStructure;
        end
    end
end

