classdef ConfigSetHighlightWindow<slxmlcomp.internal.highlight.HighlightWindow




    properties(Access=private)
ConfigSet
Disposables
WindowInfo
BDInfo
        ConfigSetTypes=["ConfigSet"];
        PendingPosition=[]
    end

    methods(Access=public)

        function obj=ConfigSetHighlightWindow(location)
            obj.WindowInfo=obj.getWindowInfo(location);
            obj.BDInfo=location.BDInfo;
            obj.BDInfo.ensureLoaded();
            obj.ConfigSet=obj.resolveConfigSet(location);
        end

        function zoomToShow(obj,location)
            obj.ensureSystemLoaded();

            configsetInfo=obj.parseConfigSetLocation(location);

            try


                layout=configset.layout.MetaConfigLayout.getInstance;
                if~isempty(find(cellfun(@(x)strcmp(message(x.Key).getString(),strrep(configsetInfo.ConfigSetLocation,'//','/')),layout.TopLevelPanes),1))
                    slCfgPrmDlg(obj.ConfigSet,'TurnToPage',configsetInfo.ConfigSetLocation);
                end
            catch E %#ok<NASGU>

            end

        end

        function show(obj)
            obj.ensureSystemLoaded();
            slCfgPrmDlg(obj.ConfigSet,'Open');



            if~isempty(obj.PendingPosition)
                obj.setPosition(obj.PendingPosition);
                obj.PendingPosition=[];
            end
        end

        function hide(obj)
            obj.ConfigSet.hideDialog();
        end

        function bool=canDisplay(obj,location)
            if~any(obj.ConfigSetTypes==location.Type)
                bool=false;
                return
            end

            windowInfo=obj.getWindowInfo(location);
            bool=isequal(windowInfo,obj.WindowInfo);
        end

        function setPosition(obj,coords)





            pos=zeros(1,4);
            pos(1)=coords(1);
            pos(2)=coords(2);
            pos(3)=coords(3)-coords(1);
            pos(4)=coords(4)-coords(2);

            dialog=obj.ConfigSet.getDialogHandle();
            if~isempty(dialog)
                dialog.position=pos;
                obj.PendingPosition=[];
            else
                obj.PendingPosition=coords;
            end
        end

        function clearDiffStyles(~)

        end

        function applyDiffStyles(~,~)

        end

        function applyAttentionStyle(~,~,~)

        end

        function clearAttentionStyle(~)

        end

        function delete(obj)
            if~isempty(obj.ConfigSet)
                obj.ConfigSet.closeDialog();
            end
        end

    end

    methods(Access=private)
        function info=parseConfigSetLocation(~,location)



            parts=regexp(location.Location,'(?<!/)/(?!/)','split');

            model=parts{1};
            configset=parts{2};
            if numel(parts)<3
                cfg_location="";
            else
                cfg_location=parts{3};
            end

            info=struct(...
            'ModelName',model,...
            'ConfigSetName',configset,...
            'ConfigSetLocation',cfg_location...
            );

        end

        function configSet=resolveConfigSet(obj,location)
            info=obj.parseConfigSetLocation(location);
            configSet=getConfigSet(info.ModelName,info.ConfigSetName);
        end

        function windowInfo=getWindowInfo(~,location)
            resolver=slxmlcomp.internal.highlight.window.ConfigSetWindowResolver();
            windowInfo=resolver.getInfo(location);
        end

        function ensureSystemLoaded(obj)
            obj.BDInfo.ensureLoaded();
        end
    end

end
