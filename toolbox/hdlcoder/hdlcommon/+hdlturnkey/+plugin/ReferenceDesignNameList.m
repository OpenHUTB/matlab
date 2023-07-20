


classdef ReferenceDesignNameList<hdlturnkey.plugin.ListBase


    methods

        function obj=ReferenceDesignNameList()

            obj.initList;
        end

        function defaultRDName=getDefaultRDName(obj,currentToolVersion)


            rdList=obj.getNameList;
            if isempty(rdList)
                defaultRDName='';
                return;
            end


            if isempty(currentToolVersion)
                defaultRDName=rdList{1};
                return;
            end


            for ii=1:length(rdList)
                rdName=rdList{ii};
                supportedVerList=obj.getAllSupportedVersion(rdName);
                isMatch=downstream.tool.detectToolVersionMatch(currentToolVersion,supportedVerList);
                if isMatch
                    defaultRDName=rdName;
                    return;
                end
            end


            defaultRDName=rdList{1};
        end

        function verList=getAllSupportedVersion(obj,rdName)

            verList={};
            if obj.isListEmpty
                return;
            end

            [~,hVerList]=obj.isInList(rdName);
            if isempty(hVerList)||hVerList.isListEmpty
                return;
            end

            verList=hVerList.getNameList;
        end

    end

    methods(Access=protected)

        function insertPluginObject(obj,hRD)



            rdName=hRD.ReferenceDesignName;


            if obj.PluginObjList.isKey(rdName)
                hVerList=obj.PluginObjList(rdName);
            else
                hVerList=hdlturnkey.plugin.ReferenceDesignVersionList;
                obj.PluginObjList(rdName)=hVerList;
            end


            hVerList.insertPluginObject(hRD);
        end

    end

end



