




classdef ReferenceDesignListSimple<hdlturnkey.plugin.ReferenceDesignList
























    methods

        function obj=ReferenceDesignListSimple()



            hIP=[];
            obj=obj@hdlturnkey.plugin.ReferenceDesignList(hIP);
        end

        function buildRDList(obj,hBoard,boardName,toolName)






            obj.initList;




            plugins=obj.searchRDCustomizationFile(hBoard,boardName);
            if isempty(plugins)

                error(message('hdlcommon:workflow:NoReferenceDesignsForBoard',boardName));
            end


            for ii=1:length(plugins)
                plugin=plugins{ii};


                try

                    hRD=obj.loadRDPlugin(plugin,hBoard);


                    if~hRD.isSupported
                        continue;
                    end


                    obj.insertPluginObject(hRD);

                catch ME

                    obj.reportInvalidPlugin(plugin,ME.message);
                    continue;
                end

            end




            currentToolVersion='';

            obj.updateRDChoiceTool(toolName,currentToolVersion,boardName);
        end


        function hRD=getRDPlugin(obj,rdName)
            hRD=obj.getRDObject(rdName);
        end

    end
end
