classdef PreferenceManager<handle




    properties(Constant)

        prefGroupName='rootinportmapper';
        cellPrefNames={...
'version'...
        ,'mappingmode'...
        ,'custommapfile'...
        ,'updatemodel'...
        ,'allowpartialbus'...
        ,'strongdatatype'...
        ,'strictmode'};

        cellPrefValues={...
'0.1'...
        ,'blockname'...
        ,''...
        ,false...
        ,true...
        ,false...
        ,true};

    end

    methods(Static)


        function createFactoryDefaults()

            addpref(Simulink.sta.PreferenceManager.prefGroupName,...
            Simulink.sta.PreferenceManager.cellPrefNames,...
            Simulink.sta.PreferenceManager.cellPrefValues);
        end


        function restoreFactoryDefaults()

            for k=1:length(Simulink.sta.PreferenceManager.cellPrefNames)
                setpref(Simulink.sta.PreferenceManager.prefGroupName,...
                Simulink.sta.PreferenceManager.cellPrefNames,Simulink.sta.PreferenceManager.cellPrefValues);
            end

        end


        function currentVersion=getCurrentVersion()
            currentVersion=Simulink.sta.PreferenceManager.cellPrefValues{1};
        end


        function appendToExistingPreferences()




            DOES_PREF_EXIST=~ispref(Simulink.sta.PreferenceManager.prefGroupName,Simulink.sta.PreferenceManager.cellPrefNames);

            if any(DOES_PREF_EXIST)

                addpref(Simulink.sta.PreferenceManager.prefGroupName,...
                Simulink.sta.PreferenceManager.cellPrefNames(DOES_PREF_EXIST),Simulink.sta.PreferenceManager.cellPrefValues(DOES_PREF_EXIST));

                setpref(Simulink.sta.PreferenceManager.prefGroupName,'version',Simulink.sta.PreferenceManager.cellPrefValues{1});
            end

        end


        function prefVals=getRootInportMappingPrefs()
            prefVals=getpref('rootinportmapper',Simulink.sta.PreferenceManager.cellPrefNames);
        end


        function preferenceStruct=getRootInportMappingPrefsStruct()
            prefVals=Simulink.sta.PreferenceManager.getRootInportMappingPrefs();
            preferenceStruct.version=prefVals{1};
            preferenceStruct.mappingmode=prefVals{2};
            preferenceStruct.custommapfile=prefVals{3};
            preferenceStruct.updatemodel=prefVals{4};
            preferenceStruct.allowpartialbus=prefVals{5};
            preferenceStruct.strongdatatype=prefVals{6};
            preferenceStruct.strictmode=prefVals{7};
        end


        function setRootInportMappingPref(nameOfPref,valueOfPref)

            if~iscell(nameOfPref)
                if Simulink.sta.PreferenceManager.qualifyPrefValue(nameOfPref,valueOfPref)

                    setpref(Simulink.sta.PreferenceManager.prefGroupName,nameOfPref,valueOfPref);
                end
            else
                for k=1:length(nameOfPref)
                    if Simulink.sta.PreferenceManager.qualifyPrefValue(nameOfPref{k},valueOfPref{k})

                        setpref(Simulink.sta.PreferenceManager.prefGroupName,nameOfPref{k},valueOfPref{k});
                    end
                end
            end


        end


        function isPropValueValid=qualifyPrefValue(nameOfPref,valueOfPref)
            isPropValueValid=true;

            switch nameOfPref
            case 'mappingmode'
                isPropValueValid=any(strcmpi({'blockname','portorder','signalname','blockpath','custom'},valueOfPref));
            case 'updatemodel'
                isPropValueValid=islogical(valueOfPref);
            case 'allowpartialbus'

                isPropValueValid=islogical(valueOfPref);
            case 'strongdatatype'
                isPropValueValid=islogical(valueOfPref);
            case 'strictmode'
                isPropValueValid=islogical(valueOfPref);
            end

        end

    end
end

