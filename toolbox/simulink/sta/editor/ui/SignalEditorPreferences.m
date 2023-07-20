classdef SignalEditorPreferences<handle






    properties(Constant)
        GroupName='signaleditor_preferences';
        FigureSizePref='figuresize';
        SignalTypeForInsert='signalvariabletoinsert';
    end



    methods(Access=protected)

        function obj=SignalEditorPreferences()

            setUpFactoryDefaultsIfRequired(obj);
        end

    end



    methods(Static)


        function thisObj=getInstance()

            persistent thisInstance;


            if(isempty(thisInstance))

                thisInstance=SignalEditorPreferences();
                thisObj=thisInstance;
                return;
            end



            setUpFactoryDefaultsIfRequired(thisInstance);

            thisObj=thisInstance;
        end
    end




    methods


        function setUpFactoryDefaultsIfRequired(obj)

            if~ispref(obj.GroupName,obj.FigureSizePref)
                addpref(obj.GroupName,...
                {obj.FigureSizePref},...
                {[]});
            end


            if~ispref(obj.GroupName,obj.SignalTypeForInsert)
                addpref(obj.GroupName,...
                {obj.SignalTypeForInsert},...
                {message("sl_sta:editor:insertsigtypeloggedtimeseries").getString});
            end

        end


        function addFigureSize(obj,inSize)

            if~ispref(obj.GroupName,obj.FigureSizePref)
                addpref(obj.GroupName,...
                {obj.FigureSizePref},...
                {inSize});
            else
                setPreference(obj,obj.FigureSizePref,inSize);

            end

        end


        function figureSize=getFigureSizePreference(obj)

            figureSize=getpref(obj.GroupName,...
            obj.FigureSizePref);
        end


        function addSignalTypeForInsert(obj,inType)

            if~ispref(obj.GroupName,obj.SignalTypeForInsert)
                addpref(obj.GroupName,...
                {obj.SignalTypeForInsert},...
                {inType});
            else
                setPreference(obj,obj.SignalTypeForInsert,inType);

            end

        end


        function outType=getSignalTypeForInsertPreference(obj)

            outType=getpref(obj.GroupName,...
            obj.SignalTypeForInsert);
        end


        function restoreFactoryDefaults(obj)

            obj.addFigureSize([]);


            obj.addSignalTypeForInsert(message("sl_sta:editor:insertsigtypeloggedtimeseries").getString);
        end


        function outStruct=toStruct(obj)

            outStruct.(obj.SignalTypeForInsert)=obj.getSignalTypeForInsertPreference();
            outStruct.(obj.FigureSizePref)=obj.getFigureSizePreference();

        end


        function setPreference(obj,inPrefName,inPrefVal)
            try
                setpref(obj.GroupName,...
                inPrefName,inPrefVal);
            catch ME_pref
                throwAsCaller(ME_pref);
            end
        end
    end

end
