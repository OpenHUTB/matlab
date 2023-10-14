classdef SchemaConverter < handle

    properties ( SetAccess = private )
        ConfigName string;
        Config = [  ];
        Model = [  ];
        Editor = [  ];
    end

    methods
        function converter = SchemaConverter( configName )
            converter.ConfigName = configName;
            converter.Config = dig.Configuration.getOrCreate( configName, "" );
            if ~converter.Config.UseConfigModel

                return ;
            end

            converter.Model = dig.config.Model.get( configName );

            converter.Editor = converter.Model.openEditor(  );
        end

        function delete( converter )
            converter.Model.closeEditor(  );
            converter.Editor = [  ];
        end

        function convertToTab( converter, id, generator, context, options )
            arguments
                converter;
                id{ mustBeTextScalar } = "";
                generator( 1, 1 ) = [  ];
                context( 1, 1 ) = [  ];
                options.CompName{ mustBeTextScalar } = "custom";
                options.CompFolder{ mustBeTextScalar, mustBeFolder } = pwd;
                options.Replace{ mustBeNumericOrLogical, mustBeScalarOrEmpty } = [  ];
                options.File{ mustBeTextScalar } = fullfile( strcat( id, ".json" ) );
                options.ActionFile{ mustBeTextScalar } = fullfile( strcat( id, "_actions.json" ) );
                options.PopupFile{ mustBeTextScalar } = fullfile( strcat( id, "_popups.json" ) );
                options.IconFile{ mustBeTextScalar } = fullfile( strcat( id, "_icons.json" ) );
            end




            try
                component = converter.createComponent( CompName = options.CompName, CompFolder = options.CompFolder, Replace = options.Replace );

                if ~isempty( component )
                    tagMap = containers.Map(  );
                    [ tab, icons ] = converter.createTab( id,  ...
                        component,  ...
                        generator,  ...
                        context,  ...
                        File = options.File,  ...
                        ActionFile = options.ActionFile,  ...
                        PopupFile = options.PopupFile,  ...
                        IconFile = options.IconFile,  ...
                        TagMap = tagMap );

                    if ~isempty( tab )



                        iconFolder = fullfile( component.Path, 'resources', 'icons' );
                        if exist( iconFolder, 'dir' ) ~= 7
                            mkdir( iconFolder );
                        end
                        icons = unique( icons );
                        for ii = 1:length( icons )
                            sourceIcon = icons{ ii };
                            [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                            targetIcon = fullfile( iconFolder, [ sourceFile, sourceExt ] );
                            copyfile( sourceIcon, targetIcon, 'f' );
                        end

                        converter.Editor.updateModel(  );
                        converter.Editor.save(  );
                        converter.Model.Preferences.rememberPath( options.CompFolder );
                        converter.Model.savePreferences(  );
                    else

                        converter.Editor.revertAndSave(  );
                    end
                end
            catch ME
                converter.Editor.revertAndSave(  );
                rethrow( ME );
            end
        end

        function convertToPopupList( converter, id, generator, context, options )
            arguments
                converter;
                id{ mustBeTextScalar } = "";
                generator( 1, 1 ) = [  ];
                context( 1, 1 ) = [  ];
                options.CompName{ mustBeTextScalar } = "custom";
                options.CompFolder{ mustBeTextScalar, mustBeFolder } = pwd;
                options.Replace{ mustBeNumericOrLogical, mustBeScalarOrEmpty } = [  ];
                options.File{ mustBeTextScalar } = fullfile( strcat( id, ".json" ) );
                options.ActionFile{ mustBeTextScalar } = fullfile( strcat( id, "_actions.json" ) );
                options.PopupFile{ mustBeTextScalar } = fullfile( strcat( id, "_popups.json" ) );
                options.IconFile{ mustBeTextScalar } = fullfile( strcat( id, "_icons.json" ) );
            end

            try
                component = converter.createComponent( CompName = options.CompName, CompFolder = options.CompFolder, Replace = options.Replace );

                if ~isempty( component )
                    [ popup, icons ] = converter.createPopupList( id,  ...
                        component,  ...
                        generator,  ...
                        context,  ...
                        File = options.File,  ...
                        ActionFile = options.ActionFile,  ...
                        PopupFile = options.PopupFile,  ...
                        IconFile = options.IconFile );
                    if ~isempty( popup )



                        iconFolder = fullfile( component.Path, 'resources', 'icons' );
                        if exist( iconFolder, 'dir' ) ~= 7
                            mkdir( iconFolder );
                        end
                        icons = unique( icons );
                        for ii = 1:length( icons )
                            sourceIcon = icons{ ii };
                            [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                            targetIcon = fullfile( iconFolder, [ sourceFile, sourceExt ] );
                            copyfile( sourceIcon, targetIcon, 'f' );
                        end

                        converter.Editor.updateModel(  );
                        converter.Editor.save(  );
                        converter.Model.Preferences.rememberPath( options.CompFolder );
                        converter.Model.savePreferences(  );
                    else

                        converter.Editor.revertAndSave(  );
                    end
                end
            catch ME
                converter.Editor.revertAndSave(  );
                rethrow( ME );
            end
        end
    end

    methods ( Static )
        function id = tagToId( tag, options )
            arguments
                tag{ mustBeTextScalar } = '';
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
                options.Suffix{ mustBeTextScalar } = "";
            end
            tagNoColon = strrep( tag, ":", "_" );
            id = strcat( tagNoColon, options.Suffix );
            if isKey( options.TagMap, id )
                index = options.TagMap( id ) + 1;
                options.TagMap( id ) = index;
                id = strcat( id, num2str( index ) );
            else
                options.TagMap( id ) = 1;
                id = strcat( id, num2str( 1 ) );
            end
        end

        function schemas = generateChildrenFcns( ~, inschema )
            schemas = inschema.childrenFcns;
        end

        function generateFcn = getGenerateFcn( schema )
            arguments
                schema( 1, 1 ){ mustBeA( schema, "DAStudio.ContainerSchema" ) };
            end
            if isempty( schema.generateFcn )
                generateFcn = @( cbinfo )dig.config.SchemaConverter.generateChildrenFcns( cbinfo, schema );
            else
                generateFcn = schema.generateFcn;
            end
        end

        function warnOnErrorSchema( ex )
            id = 'dig:config:resources:ErrorSchemaWarning';
            msg = ex.message;
            frame = ex.stack( 1 );
            [ ~, loc ] = fileparts( frame.file );
            loc = strcat( loc, filesep, frame.name );

            line = num2str( frame.line );
            wmsg = message( id, msg, loc, frame.file, line );
            warning( wmsg );
        end
    end

    methods ( Access = private )
        function component = createComponent( converter, options )
            arguments
                converter;
                options.CompName{ mustBeTextScalar } = "custom";
                options.CompFolder{ mustBeTextScalar, mustBeFolder } = pwd;
                options.Replace{ mustBeNumericOrLogical, mustBeScalarOrEmpty } = [  ];
            end










            component = converter.Editor.getComponent( options.CompName );
            if ~isempty( component )
                replace = options.Replace;
                if isempty( replace )

                    msgstr = message( 'dig:config:resources:ReplaceExistingComponent', options.CompName ).getString(  );
                    in = input( msgstr, 's' );
                    if strcmpi( in, 'y' ) || strcmpi( in, 'yes' )
                        replace = true;
                    end
                end

                if replace
                    if isempty( options.CompFolder ) || strcmp( options.CompFolder, pwd )
                        options.CompFolder = component.Path;
                    end
                    try
                        converter.Editor.destroyComponent( component.Name );
                    catch ME

                        converter.Editor.revertAndSave(  );
                        rethrow( ME );
                    end
                else

                    component = [  ];
                    return ;
                end
            end

            component = converter.Editor.createComponent( options.CompName, options.CompFolder );
        end

        function [ tab, icons ] = createTab( converter, id, component, generator, context, options )
            arguments
                converter;
                id{ mustBeTextScalar } = "";
                component( 1, 1 ){ mustBeA( component, "dig.config.Component" ) } = [  ];
                generator( 1, 1 ) = [  ];
                context( 1, 1 ) = [  ];
                options.File{ mustBeTextScalar } = fullfile( strcat( id, ".json" ) );
                options.ActionFile{ mustBeTextScalar } = fullfile( strcat( id, "_actions.json" ) );
                options.PopupFile{ mustBeTextScalar } = fullfile( strcat( id, "_popups.json" ) );
                options.IconFile{ mustBeTextScalar } = fullfile( strcat( id, "_icons.json" ) );
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
            end

            icons = {  };



            [ children, childrenIcons ] = converter.generateTabChildren( component,  ...
                generator,  ...
                context,  ...
                File = options.File,  ...
                ActionFile = options.ActionFile,  ...
                PopupFile = options.PopupFile,  ...
                IconFile = options.IconFile,  ...
                TagMap = options.TagMap );



            if ~isempty( children )
                tab = component.createTab( id, options.File );
                tab.Title = "dig:config:resources:DefaultCustomTabTitle";
                for ii = 1:length( children )
                    child = children{ ii };
                    if isa( child, "dig.config.Section" ) || isa( child, "dig.config.Placeholder" )
                        tab.addChild( child );
                    end
                end

                icons = [ icons, childrenIcons ];
            else
                tab = [  ];
            end
        end

        function [ sections, icons ] = generateTabChildren( converter, component, generator, context, options )
            arguments
                converter;
                component( 1, 1 ){ mustBeA( component, "dig.config.Component" ) } = [  ];
                generator( 1, 1 ){ mustBeA( generator, "function_handle" ) } = [  ];
                context( 1, 1 ) = [  ];
                options.File{ mustBeTextScalar } = "";
                options.ActionFile{ mustBeTextScalar } = "";
                options.PopupFile{ mustBeTextScalar } = "";
                options.IconFile{ mustBeTextScalar } = "";
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
            end


            cbinfo = context.getCallbackInfo(  );
            childGenerators = generator( cbinfo );

            childSchemas = dasprivate( "dig_get_menu", childGenerators, cbinfo );


            sections = {  };
            icons = {  };


            sectionTags = containers.Map(  );
            for ii = 1:length( childSchemas )
                schema = childSchemas{ ii };


                if isa( schema, "DAStudio.ActionSchema" ) &&  ...
                        strcmp( schema.tag, 'DIG:ErrorItem' )
                    dig.config.SchemaConverter.warnOnErrorSchema( schema.userdata );
                    continue ;
                end

                if isa( schema, "DAStudio.ContainerSchema" )
                    sectionId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Section", TagMap = sectionTags );

                    generateFcn = dig.config.SchemaConverter.getGenerateFcn( schema );
                    [ children, childrenIcons ] = converter.generateSectionChildren( component,  ...
                        generateFcn,  ...
                        context,  ...
                        File = options.File,  ...
                        ActionFile = options.ActionFile,  ...
                        PopupFile = options.PopupFile,  ...
                        IconFile = options.IconFile,  ...
                        TagMap = options.TagMap );


                    if ~isempty( children )
                        section = component.createWidget( "Section", sectionId, options.File );
                        section.Title = schema.label;
                        for jj = 1:length( children )
                            child = children{ jj };
                            if isa( child, "dig.config.Column" ) || isa( child, "dig.config.Placeholder" )
                                section.addChild( child );
                            end
                        end

                        icons = [ icons, childrenIcons ];%#ok<AGROW>


                        if isempty( sections )
                            sections = { section };
                        else
                            sections = [ sections, { section } ];%#ok<AGROW>
                        end
                    end
                end
            end
        end

        function [ columns, icons ] = generateSectionChildren( converter, component, generator, context, options )
            arguments
                converter;
                component( 1, 1 ){ mustBeA( component, "dig.config.Component" ) } = [  ];
                generator( 1, 1 ){ mustBeA( generator, "function_handle" ) } = [  ];
                context( 1, 1 ) = [  ];
                options.File{ mustBeTextScalar } = "";
                options.ActionFile{ mustBeTextScalar } = "";
                options.PopupFile{ mustBeTextScalar } = "";
                options.IconFile{ mustBeTextScalar } = "";
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
            end



            cbinfo = context.getCallbackInfo(  );
            childGenerators = generator( cbinfo );

            childSchemas = dasprivate( "dig_get_menu", childGenerators, cbinfo );


            columns = {  };
            icons = {  };



            childrenTags = containers.Map(  );
            for ii = 1:length( childSchemas )
                schema = childSchemas{ ii };



                if isa( schema, "DAStudio.ActionSchema" ) || isa( schema, "DAStudio.ContainerSchema" )
                    if strcmp( schema.tag, 'DIG:ErrorItem' )
                        dig.config.SchemaConverter.warnOnErrorSchema( schema.userdata );
                        continue ;
                    end


                    actionId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Action", TagMap = options.TagMap );
                    action = component.createAction( actionId, options.ActionFile );
                    action.Text = schema.label;
                    action.Description = schema.tooltip;

                    action.IconReference = "simulink";
                    if ~isempty( schema.icon )
                        icon = component.getIcon( schema.icon );
                        if isempty( icon )

                            im = DAStudio.IconManager;


                            hasIcon16 = im.hasIconFile( schema.icon, 16 );
                            icon16 = '';
                            if hasIcon16

                                sourceIcon = im.getIconFile( schema.icon, 16 );
                                if exist( sourceIcon, 'file' ) == 2
                                    [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                                    icons = [ icons, { sourceIcon } ];%#ok<AGROW>
                                    icon16 = [ sourceFile, sourceExt ];
                                end
                            end

                            hasIcon24 = im.hasIconFile( schema.icon, 24 );
                            icon24 = '';
                            if hasIcon24

                                sourceIcon = im.getIconFile( schema.icon, 24 );
                                if exist( sourceIcon, 'file' ) == 2
                                    [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                                    icons = [ icons, { sourceIcon } ];%#ok<AGROW>
                                    icon24 = [ sourceFile, sourceExt ];
                                end
                            end

                            if ~isempty( icon16 ) || ~isempty( icon24 )

                                icon = component.createIcon( schema.icon, options.IconFile );
                                icon.Icon16 = icon16;
                                icon.Icon24 = icon24;
                                action.IconReference = icon.Name;
                            end
                        else
                            action.IconReference = icon.Name;
                        end
                    end




                    buttonId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Button", TagMap = childrenTags );
                    if isa( schema, "DAStudio.ActionSchema" )

                        button = component.createWidget( "PushButton", buttonId, options.File );
                        button.ActionReference = action.Name;


                        if ischar( schema.callback ) || isStringScalar( schema.callback )

                            action.CommandType = dig.config.CommandType.Script;
                            action.Command = schema.callback;
                        else

                            action.CommandType = dig.config.CommandType.Callback;

                            if ~isempty( schema.callback )
                                finfo = functions( schema.callback );
                                if strcmpi( finfo.type, 'simple' )
                                    action.Command = finfo.function;
                                else
                                    action.Command = "dig.config.internal.conversionFailedCallback";
                                end
                            end
                        end
                    else

                        button = component.createWidget( "DropDownButton", buttonId, options.File );
                        button.ActionReference = action.Name;


                        popupId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Popup", TagMap = options.TagMap );
                        popupName = strcat( component.Name, ":", popupId );



                        generateFcn = dig.config.SchemaConverter.getGenerateFcn( schema );

                        popupIcons = converter.createPopupList( popupId,  ...
                            component,  ...
                            generateFcn,  ...
                            context,  ...
                            File = options.PopupFile,  ...
                            ActionFile = options.ActionFile,  ...
                            PopupFile = options.PopupFile,  ...
                            IconFile = options.IconFile,  ...
                            TagMap = options.TagMap );

                        button.PopupName = popupName;

                        icons = [ icons, popupIcons ];%#ok<AGROW>
                    end

                    if ~isempty( button )

                        columnId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Column", TagMap = childrenTags );
                        column = component.createWidget( "Column", columnId, options.File );
                        column.addChild( button );
                        if isempty( columns )
                            columns = { column };
                        else
                            columns = [ columns, { column } ];%#ok<AGROW>
                        end
                    else

                        component.destroyIcon( schema.icon );
                        component.destroyAction( actionId );
                    end
                end
            end
        end

        function icons = createPopupList( converter, id, component, generator, context, options )
            arguments
                converter;
                id{ mustBeTextScalar } = "";
                component( 1, 1 ){ mustBeA( component, "dig.config.Component" ) } = [  ];
                generator( 1, 1 ) = [  ];
                context( 1, 1 ) = [  ];
                options.File{ mustBeTextScalar } = fullfile( strcat( id, ".json" ) );
                options.ActionFile{ mustBeTextScalar } = fullfile( strcat( id, "_actions.json" ) );
                options.PopupFile{ mustBeTextScalar } = fullfile( strcat( id, "_popups.json" ) );
                options.IconFile{ mustBeTextScalar } = fullfile( strcat( id, "_icons.json" ) );
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
            end

            icons = {  };



            [ children, childrenIcons ] = converter.generatePopupListChildren( component,  ...
                generator,  ...
                context,  ...
                File = options.File,  ...
                ActionFile = options.ActionFile,  ...
                PopupFile = options.PopupFile,  ...
                IconFile = options.IconFile,  ...
                TagMap = options.TagMap );



            if ~isempty( children )
                popup = component.createPopupList( id, options.File );
                for ii = 1:length( children )
                    child = children{ ii };
                    if isa( child, "dig.config.ListItem" ) ||  ...
                            isa( child, "dig.config.ListItemWithPopup" ) ||  ...
                            isa( child, "dig.config.ListItemWithCheckBox" ) ||  ...
                            isa( child, "dig.config.ListHeader" ) ||  ...
                            isa( child, "dig.config.ListSeparator" ) ||  ...
                            isa( child, "dig.config.Placeholder" )
                        popup.addChild( child );
                    end
                end

                icons = [ icons, childrenIcons ];
            end
        end

        function [ items, icons ] = generatePopupListChildren( converter, component, generator, context, options )
            arguments
                converter;
                component( 1, 1 ){ mustBeA( component, "dig.config.Component" ) } = [  ];
                generator( 1, 1 ){ mustBeA( generator, "function_handle" ) } = [  ];
                context( 1, 1 ){ mustBeA( context, "dig.Context" ) } = [  ];
                options.File{ mustBeTextScalar } = "";
                options.ActionFile{ mustBeTextScalar } = "";
                options.PopupFile{ mustBeTextScalar } = "";
                options.IconFile{ mustBeTextScalar } = "";
                options.TagMap{ mustBeA( options.TagMap, 'containers.Map' ) } = containers.Map(  );
            end

            icons = {  };



            cbinfo = context.getCallbackInfo(  );
            childGenerators = generator( cbinfo );

            childSchemas = dasprivate( "dig_get_menu", childGenerators, cbinfo );


            items = {  };



            separatorIndex = 0;
            previousItemIsSeparator = false;
            childrenTags = containers.Map(  );
            for ii = 1:length( childSchemas )
                schema = childSchemas{ ii };

                if ischar( schema ) || isStringScalar( schema )


                    if strcmp( schema, "separator" ) && ~previousItemIsSeparator

                        separatorIndex = separatorIndex + 1;
                        separatorId = strcat( "separator", num2str( separatorIndex ) );
                        separator = component.createWidget( "ListSeparator", separatorId, options.File );
                        if isempty( items )
                            items = { separator };
                        else
                            items = [ items, { separator } ];%#ok<AGROW>
                        end
                        previousItemIsSeparator = true;
                    end
                elseif isa( schema, "DAStudio.ActionSchema" ) || isa( schema, "DAStudio.ContainerSchema" )
                    if strcmp( schema.tag, 'DIG:ErrorItem' )
                        dig.config.SchemaConverter.warnOnErrorSchema( schema.userdata );
                        continue ;
                    end


                    actionId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Action", TagMap = options.TagMap );
                    actionName = strcat( component.Name, ":", actionId );
                    action = component.createAction( actionId, options.ActionFile );
                    action.Text = schema.label;
                    action.Description = schema.tooltip;



                    action.IconReference = 'simulink';
                    if ~isempty( schema.icon )
                        icon = component.getIcon( schema.icon );
                        if isempty( icon )

                            im = DAStudio.IconManager;


                            hasIcon16 = im.hasIconFile( schema.icon, 16 );
                            icon16 = '';
                            if hasIcon16

                                sourceIcon = im.getIconFile( schema.icon, 16 );
                                if exist( sourceIcon, 'file' ) == 2
                                    [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                                    icons = [ icons, { sourceIcon } ];%#ok<AGROW>
                                    icon16 = [ sourceFile, sourceExt ];
                                end
                            end

                            hasIcon24 = im.hasIconFile( schema.icon, 24 );
                            icon24 = '';
                            if hasIcon24

                                sourceIcon = im.getIconFile( schema.icon, 24 );
                                if exist( sourceIcon, 'file' ) == 2
                                    [ ~, sourceFile, sourceExt ] = fileparts( sourceIcon );
                                    icons = [ icons, { sourceIcon } ];%#ok<AGROW>
                                    icon24 = [ sourceFile, sourceExt ];
                                end
                            end

                            if ~isempty( icon16 ) || ~isempty( icon24 )

                                icon = component.createIcon( schema.icon, options.IconFile );
                                icon.Icon16 = icon16;
                                icon.Icon24 = icon24;
                                action.IconReference = icon.Name;
                            end
                        else
                            action.IconReference = icon.Name;
                        end
                    end




                    itemId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Item", TagMap = childrenTags );
                    if isa( schema, "DAStudio.ActionSchema" )

                        item = component.createWidget( "ListItem", itemId, options.File );
                        item.ActionReference = actionName;


                        if ischar( schema.callback ) || isStringScalar( schema.callback )

                            action.CommandType = dig.config.CommandType.Script;
                            action.Command = schema.callback;
                        else

                            action.CommandType = dig.config.CommandType.Callback;

                            if ~isempty( schema.callback )
                                finfo = functions( schema.callback );
                                if strcmpi( finfo.type, 'simple' )
                                    action.Command = finfo.function;
                                else
                                    action.Command = "dig.config.internal.conversionFailedCallback";
                                end
                            end
                        end
                    else

                        item = component.createWidget( "ListItemWithPopup", itemId, options.File );
                        item.ActionReference = actionName;


                        popupId = dig.config.SchemaConverter.tagToId( schema.tag, Suffix = "Popup", TagMap = options.TagMap );
                        popupName = strcat( component.Name, ":", popupId );



                        generateFcn = dig.config.SchemaConverter.getGenerateFcn( schema );

                        popupIcons = converter.createPopupList( popupId,  ...
                            component,  ...
                            generateFcn,  ...
                            context,  ...
                            File = options.PopupFile,  ...
                            ActionFile = options.ActionFile,  ...
                            PopupFile = options.PopupFile,  ...
                            IconFile = options.IconFile,  ...
                            TagMap = options.TagMap );

                        icons = [ icons, popupIcons ];%#ok<AGROW>

                        item.PopupName = popupName;
                    end

                    if ~isempty( item )

                        if isempty( items )
                            items = { item };
                        else
                            items = [ items, { item } ];%#ok<AGROW>
                        end
                        previousItemIsSeparator = false;
                    else

                        component.destroyAction( actionId );
                    end
                end
            end
        end
    end
end


