classdef MulticoreDockableComponent<handle




    properties
ComponentTitle
ComponentName
Component
Studio
ModelH
Data
    end

    methods(Abstract)

        getComponentType(obj);


        update(obj);


        comp=createDockableComponent(obj);


    end

    methods
        function obj=MulticoreDockableComponent(uiObj,compName,varargin)
            obj.ModelH=getModelHandle(uiObj);
            obj.ComponentName=char(obj.Studio.getStudioTag+string(compName));
            obj.Component=findMulticoreDockableComponent(obj);
            if nargin>2
                obj.Data=varargin{1};
            end
            if isempty(obj.Component)||~isvalid(obj.Component)
                obj.Component=createDockableComponent(obj);
                registerComponent(obj.Studio,obj.Component);
                obj.Component.ExplicitShow=true;
            end
        end

        function close(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                obj.hide();
            end
        end

        function delete(obj)

            if~isempty(obj.Data)&&isvalid(obj.Data)
                delete(obj.Data);
            end

            obj.Data=[];
        end


        function cmp=findMulticoreDockableComponent(obj)
            cmp=getComponent(obj.Studio,obj.getComponentType(),obj.ComponentName);
        end



        function setTitle(obj,title)
            obj.ComponentTitle=title;
        end

        function placeComponent(obj,location,mode)
            moveComponentToDock(obj.Studio,obj.Component,obj.ComponentTitle,location,mode);
            update(obj);
        end

        function show(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                showComponent(obj.Studio,obj.Component)
                update(obj);
            end
        end

        function hide(obj)
            if~isempty(obj.Component)&&isvalid(obj.Component)
                hideComponent(obj.Studio,obj.Component);
            end
        end

        function studio=get.Studio(obj)
            studio=[];
            if isempty(obj.Studio)
                if~isempty(obj.Component)&&isvalid(obj.Component)
                    studio=getStudio(obj.Component);
                else
                    modelName=get(obj.ModelH,'Name');
                    editor=GLUE2.Util.findAllEditors(modelName);
                    if~isempty(editor)
                        for i=1:length(editor)
                            da=editor(i).getStudio;
                            if da.App.blockDiagramHandle==obj.ModelH
                                studio=da;
                                break;
                            end
                        end
                    else
                        das=DAS.Studio.getAllStudios();
                        for i=1:length(das)
                            da=das{i};
                            sa=da.App;
                            if sa.blockDiagramHandle==obj.ModelH
                                studio=da;
                                break;
                            end
                        end
                    end
                end
                obj.Studio=studio;
            else
                studio=obj.Studio;
            end
        end
    end
end


