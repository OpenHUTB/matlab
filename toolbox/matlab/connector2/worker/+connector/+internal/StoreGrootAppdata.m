classdef StoreGrootAppdata<handle

    properties(Constant)
        This=connector.internal.StoreGrootAppdata;
    end

    properties
        AppData=struct;
    end

    methods(Static)
        function clear()
            connector.internal.StoreGrootAppdata.This.doClear();
        end

        function saveAppdata()
            connector.internal.StoreGrootAppdata.This.doSave();
        end

        function originalAppData=loadAppdata()
            originalAppData=connector.internal.StoreGrootAppdata.This.doLoad;
        end
    end

    methods(Access=private)
        function obj=StoreGrootAppdata
            mlock;
        end

        function doClear(obj)
            munlock;
            obj.AppData=struct;
        end

        function doSave(obj)
            obj.AppData=getappdata(groot);
        end

        function originalAppData=doLoad(obj)
            originalAppData=obj.AppData;
            newAppData=getappdata(groot);

            if~isequal(originalAppData,newAppData)

                if~isempty(originalAppData)

                    originalAppDataNames=fieldnames(originalAppData);
                    for k=1:length(originalAppDataNames)
                        setappdata(groot,originalAppDataNames{k},originalAppData.(originalAppDataNames{k}))
                    end
                end

                if~isempty(newAppData)

                    toRemoveNames=fieldnames(newAppData);


                    if~isempty(originalAppDataNames)
                        toRemoveNames=setdiff(toRemoveNames,originalAppDataNames);
                    end

                    for k=1:length(toRemoveNames)
                        rmappdata(groot,toRemoveNames{k})
                    end
                end

            end
        end
    end
end
