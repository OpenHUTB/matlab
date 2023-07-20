classdef viewerContext<dig.CustomContext



    properties(SetAccess=public)
        ModelHandle=[];
        DataModelId=[];
        ColumnToFilterMap;
        VisibleColumns={};
    end

    properties(SetAccess=public,SetObservable=true)
        FlatView=true;
        ViewerInSync=false;
    end

    methods(Hidden)
        function obj=viewerContext()
            app=struct;
            app.name='viewerContext';
            app.defaultContextType='';
            app.defaultTabName='';
            app.priority=0;
            obj=obj@dig.CustomContext(app);
        end
    end

    methods(Static)
        function callSetApp(obj,aApp,timestamp,id,updateViewType)
            obj.ModelHandle=aApp;
            obj.DataModelId=id;
            obj.ColumnToFilterMap=containers.Map();
            if isequal(str2double(timestamp),-1)
                obj.TypeChain={'ModelOutOfSync'};
            else
                obj.TypeChain={'ModelInSync'};
            end

            if updateViewType

                s=settings;
                pm_assert(s.hasGroup('simscape'));
                ssc=s.simscape;
                pm_assert(ssc.hasGroup('variableviewer'));
                vv=ssc.variableviewer;
                pm_assert(vv.hasSetting('ViewType'));
                try
                    activeVal=ssc.variableviewer.ViewType.ActiveValue;
                    if~isempty(activeVal)
                        viewType=jsondecode(activeVal);
                        if isfield(viewType,'view')&&strcmpi(viewType.view,'tree')
                            obj.FlatView=false;
                        else
                            obj.FlatView=true;
                        end
                    end
                catch ME %#ok<NASGU> 

                end
            end
        end

        function setFlatView(obj,flag)
            obj.FlatView=flag;
        end

        function ret=isModelModified(obj,ts)
            timestamp=str2double(ts);
            if isequal(timestamp,-1)

                obj.ViewerInSync=false;
                obj.TypeChain={'ModelOutOfSync'};
            else
                if strcmpi(ds.gui.internal.modelModified(obj.ModelHandle,timestamp),'true')
                    obj.ViewerInSync=false;
                    obj.TypeChain={'ModelOutOfSync'};
                else
                    obj.ViewerInSync=true;
                    obj.TypeChain={'ModelInSync'};
                end
            end
            ret=obj.ViewerInSync;
        end
    end
end
