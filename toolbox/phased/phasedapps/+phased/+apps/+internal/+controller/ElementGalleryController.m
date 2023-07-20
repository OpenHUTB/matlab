classdef ElementGalleryController<handle






    properties(Access=private)
pToolStrip
pApp
pParams
    end

    methods(Access=public)

        function obj=ElementGalleryController(varargin)
            obj.pApp=varargin{1};
            obj.pToolStrip=varargin{1}.ToolStripDisplay;
            obj.pParams=varargin{1}.ParametersPanel;
        end

        function execute(obj,src,~)

            setAppStatus(obj.pApp,true);


            selectElementItem(obj.pToolStrip,src.Tag);

            if~isempty(obj.pParams.ElementDialog)
                obj.pParams.ElementType='';
            end

            obj.pParams.ElementType=src.Tag;


            updateElementObject(obj.pParams.ElementDialog)
            if~obj.pApp.IsSubarray
                obj.pApp.CurrentArray.Element=obj.pApp.CurrentElement;
            else
                if isa(obj.pApp.CurrentArray,'phased.ReplicatedSubarray')
                    obj.pApp.CurrentArray.Subarray.Element=obj.pApp.CurrentElement;
                else
                    obj.pApp.CurrentArray.Array.Element=obj.pApp.CurrentElement;
                end
            end

            adjustLayout(obj.pApp)


            updateArrayCharTable(obj.pApp)


            updateOpenPlots(obj.pApp);

            obj.pApp.IsChanged=true;
            setAppTitle(obj.pApp,obj.pApp.DefaultSessionName)


            setAppStatus(obj.pApp,false);
        end
    end
end