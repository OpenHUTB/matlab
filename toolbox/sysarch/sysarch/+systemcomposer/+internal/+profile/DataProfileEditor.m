classdef DataProfileEditor<systemcomposer.internal.profile.Designer





    methods(Access=private)
        function this=DataProfileEditor()


            this.resetUIState();
            this.TreeIDMap=systemcomposer.internal.profile.internal.TreeNodeIDMap;
            this.checkoutLicense();
        end
    end

    methods(Static)
        function obj=instance()


            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=systemcomposer.internal.profile.DataProfileEditor;
            end
            obj=instance;
        end

        function launch(varargin)


            instance=systemcomposer.internal.profile.DataProfileEditor.instance();


            profileFocus='';
            if~isempty(varargin)
                v1=varargin{1};
                if ischar(v1)
                    profileFocus=v1;
                elseif isa(v1,'systemcomposer.profile.Profile')
                    profileFocus=v1.Name;
                else
                    error('Invalid input argument');
                end

                if length(varargin)>1
                    v2=varargin{2};
                    if islogical(v2)
                        instance.ShowBuiltInDataProfiles=v2;
                    end
                end
            end

            if isempty(instance.DialogInstance)||~ishandle(instance.DialogInstance)
                instance.DialogInstance=DAStudio.Dialog(instance);
            else
                instance.DialogInstance.show();
                instance.DialogInstance.refresh();
            end

            if~isempty(profileFocus)
                instance.handleClickProfileBrowserNode(instance.DialogInstance,profileFocus);
                instance.DialogInstance.refresh();
            end
        end

        function unload()


            systemcomposer.internal.profile.Profile.unload;
            instance=systemcomposer.internal.profile.DataProfileEditor.instance();

            if isa(instance.DialogInstance,'DAStudio.Dialog')
                delete(instance.DialogInstance);
            end
            delete(instance);
        end

        function id=getID(fqn)






            instance=systemcomposer.internal.profile.DataProfileEditor.instance();
            id=instance.TreeIDMap.get(fqn);
        end
    end

    methods
        function title=getTitle(this)
            title=message('SLDD:ProfileEditor:EditorTitle').getString;
        end

        function descTitle=getDescTitle(this)
            descTitle=message('SLDD:ProfileEditor:EditorDescTitle').getString;
        end
        function descText=getDescText(this)
            descText=message('SLDD:ProfileEditor:EditorDescText').getString;
        end

        function profMdls=doGetProfileModels(this)
            profMdls=[];
            profs=systemcomposer.internal.profile.Profile.getProfilesInCatalog();
            for prof=profs
                if~isa(prof,'sl.data.annotation.profile.DataProfile')

                    continue;
                end
                model=mf.zero.getModel(prof);
                profMdls=cat(1,profMdls,model);
            end
        end

        function handleClickNewProfile(this)

            newName=this.generateNewProfileName();
            m=mf.zero.Model();
            profile=sl.data.annotation.profile.DataProfile.createProfile(m,newName);%#ok<NASGU>


            if this.isFilteringProfilesByModelOrDD()
                msg=DAStudio.message('SystemArchitecture:ProfileDesigner:CreatedProfileButFiltered',newName);
            else
                msg=DAStudio.message('SystemArchitecture:ProfileDesigner:CreatedProfile',newName);
            end
            this.setStatus(msg);
        end

    end

    methods(Access=protected)

        function entries=getMetaclassEntries(~)

            entries={...
            '<All>',...
            '<All-Signals>',...
            '<All-Parameters>',...
            'ModelParameters',...
            'ModelParameterArguments',...
            'LocalParameters',...
            'ExternalParameterObjects',...
            'GlobalParameters',...
            'Inports',...
            'Outports',...
            'SharedLocalDataStores',...
            'InternalData',...
'Constants'
            };
        end

    end

end