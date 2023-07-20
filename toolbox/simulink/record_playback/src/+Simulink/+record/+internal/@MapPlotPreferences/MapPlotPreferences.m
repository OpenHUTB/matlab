classdef MapPlotPreferences




    properties


Type

    end


    methods


        function obj=MapPlotPreferences()
            obj.Type='Street';
        end


        function viewOptions=MapTypeOptions(obj)
            viewOptions=obj.MAP_VIEWS;
        end
    end


    properties(Constant,Access=private)

        MAP_VIEWS={DAStudio.message('record_playback:params:Street'),...
        DAStudio.message('record_playback:params:Satellite')}

    end
end


