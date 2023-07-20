


classdef ReferenceDesignVersionList<hdlturnkey.plugin.ListBase


    properties(Access=protected)

    end

    methods

        function obj=ReferenceDesignVersionList()

            obj.initList;
        end

        function initList(obj)

            initList@hdlturnkey.plugin.ListBase(obj);
        end



        function rdToolVersion=getDefaultRDToolVersion(obj,currentToolVersion)


            supportedVerList=obj.getNameList;

            rdToolVersion=obj.getDefaultRDToolVersionStatic(supportedVerList,currentToolVersion);

        end

    end

    methods(Static)



        function rdToolVersion=getDefaultRDToolVersionStatic(RDToolVersion,currentToolVersion)
            supportedVerList=sort(RDToolVersion);


            if isempty(currentToolVersion)
                rdToolVersion=supportedVerList{end};
                return;
            end


            [isMatch,matchedVer]=downstream.tool.detectToolVersionMatch(currentToolVersion,supportedVerList);
            if isMatch
                rdToolVersion=matchedVer;
                return;
            end


            rdToolVersion=supportedVerList{end};
        end

    end

    methods(Access=protected)

        function insertPluginObject(obj,hRD)



            supportToolVersions=hRD.SupportedToolVersion;
            for ii=1:length(supportToolVersions)
                toolVersion=supportToolVersions{ii};

                if~obj.PluginObjList.isKey(toolVersion)
                    obj.PluginObjList(toolVersion)=hRD;
                else
                    hPDup=obj.PluginObjList(toolVersion);

                    error(message('hdlcommon:workflow:DuplicateToolVersion',toolVersion,hPDup.PluginPath,hRD.PluginPath));
                end
            end
        end


    end

end



