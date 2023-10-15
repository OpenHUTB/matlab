classdef DiagramBuilder < handle









































    properties

        Name string


        Parent slreportgen.webview.internal.Diagram


        ClassName string


        HID GLUE2.HierarchyId


        SID string


        RSID string


        Handle


        EHID


        ESID string


        EHandle


        DisplayIcon string


        DisplayLabel string


        IsModelReference logical


        IsSubsystemReference logical


        IsMaskedSubsystem logical


        IsVariantSubsystem logical


        IsUserLink logical


        IsMathworksLink logical


        IsCommented logical


        ActiveVariant slreportgen.webview.internal.Diagram


        ActiveVariantPlusCode slreportgen.webview.internal.Diagram
    end

    properties ( Access = private )
        Model slreportgen.webview.internal.Model

        IsBuilt = false;
        Cache
    end

    properties ( Constant, Access = private )
        TOOLBOXDIR = toolboxdir( "" );
    end

    methods
        function [ diagram, cache ] = build( this )






            assert( ~this.IsBuilt );

            model = this.Model;
            diagram = slreportgen.webview.internal.Diagram( model );

            if ~isempty( this.Parent )
                diagram.setParent( this.Parent );
            end

            if ~isempty( this.HID )
                diagram.setHID( this.HID );
            end

            if ~isempty( this.Handle )
                diagram.setHandle( this.Handle )
            end

            if ~isempty( this.EHID )
                diagram.setEHID( this.EHID );
            end

            if ~isempty( this.EHandle )
                diagram.setEHandle( this.EHandle )
            end

            this.setSID( diagram );
            this.setESID( diagram );
            this.setName( diagram );
            this.setRSID( diagram );

            this.setIsModelReference( diagram );
            this.setIsSubsystemReference( diagram );
            this.setIsVariantSubsystem( diagram );
            this.setIsMaskedSubsystem( diagram );
            this.setIsUserLinkAndIsMathworksLink( diagram );

            this.setDisplayIcon( diagram );
            this.setDisplayLabel( diagram );


            this.setClassName( diagram );

            this.setParentActiveVariants( diagram );
            this.setIsCommented( diagram );



            this.IsBuilt = true;
            cache = this.Cache;
        end
    end

    methods ( Access = ?slreportgen.webview.internal.ModelBuilder )
        function this = DiagramBuilder( model, cache )
            arguments
                model
                cache = [  ]
            end

            this.Model = model;
            if isempty( cache )
                this.Cache = struct(  ...
                    "MayNeedToLoadSimulink", ~model.isBuiltWithLibrariesLoaded(  ) && isempty( find_system( "flat", "Name", "simulink" ) ) ...
                    );
            else
                this.Cache = cache;
            end
        end
    end

    methods ( Access = private )
        function setSID( this, diagram )
            if isempty( this.SID )
                if isempty( this.Handle )
                    hnd = slreportgen.utils.getSlSfHandle( this.HID );
                    setHandle( diagram, hnd );
                else
                    hnd = this.Handle;
                end





                slpobj = slreportgen.webview.SlProxyObject( hnd );
                diagram.setSlProxyObject( slpobj );
                sid = slpobj.SID;
            else
                sid = this.SID;
            end
            setSID( diagram, sid )
        end

        function setESID( this, diagram )
            if isempty( this.ESID )
                if isempty( diagram.Parent )
                    esid = string.empty(  );
                else
                    if isempty( this.EHandle )
                        if isempty( this.EHID )
                            ehid = slreportgen.utils.getElementHID( this.HID );
                            diagram.setEHID( ehid );
                        else
                            ehid = this.EHID;
                        end

                        ehnd = slreportgen.utils.getSlSfHandle( ehid );
                        diagram.setEHandle( ehnd );
                    else
                        ehnd = this.EHandle;
                    end

                    esid = Simulink.ID.getSID( ehnd );
                end
            else
                esid = this.ESID;
            end

            if ~isempty( esid )
                diagram.setESID( esid );
            end
        end

        function setRSID( this, diagram )
            assert( ~isempty( diagram.SID ) )
            if isempty( this.RSID )
                rsid = diagram.SID;
            else
                rsid = this.RSID;
            end
            diagram.setRSID( rsid );
        end

        function setName( this, diagram )
            if isempty( this.Name )
                ehnd = diagram.ehandle(  );
                if ~isempty( ehnd )
                    if isnumeric( ehnd )
                        ename = get_param( ehnd, 'Name' );
                        type = get_param( ehnd, 'Type' );
                        name = ename;

                        if strcmp( type, 'block' )
                            switch get_param( ehnd, 'BlockType' )
                                case 'SubSystem'
                                    if ~isempty( get_param( ehnd, 'BlockChoice' ) )
                                        name = sprintf( '%s (%s)', get_param( ehnd, 'BlockChoice' ), ename );
                                    end
                                case 'ModelReference'
                                    name = sprintf( '%s (%s)', ename, get_param( ehnd, 'ModelName' ) );
                            end
                        end
                    else
                        name = ehnd.Name;
                    end
                else
                    hnd = diagram.handle(  );
                    if isnumeric( hnd )
                        name = get_param( hnd, 'Name' );
                    else
                        name = hnd.Name;
                    end
                end
            else
                name = this.Name;
            end

            diagram.setName( name );
        end

        function setClassName( this, diagram )
            if isempty( this.ClassName )
                if diagram.IsModelReference
                    diagram.setClassName( "Simulink.ModelReference" );
                else
                    diagram.setClassName( diagram.slproxyobject(  ).ClassName );
                end
            end
        end

        function setIsModelReference( this, diagram )
            if ~isempty( this.IsModelReference )
                tf = this.IsModelReference;
            else
                elemH = diagram.ehandle(  );
                tf = slreportgen.utils.isModelReferenceBlock( elemH, Resolve = false );
            end
            diagram.setIsModelReference( tf );
        end

        function setIsSubsystemReference( this, diagram )
            if ~isempty( this.IsSubsystemReference )
                tf = this.IsSubsystemReference;
            else
                elemH = diagram.ehandle(  );
                tf = slreportgen.utils.isSubsystemReferenceBlock( elemH, Resolve = false );
            end
            diagram.setIsSubsystemReference( tf );
        end

        function setIsMaskedSubsystem( this, diagram )
            if ~isempty( this.IsMaskedSubsystem )
                tf = this.IsMaskedSubsystem;
            else
                elemH = diagram.ehandle(  );

                if ~isempty( elemH ) && isnumeric( elemH )
                    if ~isempty( get_param( elemH, "BlockChoice" ) )

                        elemH = diagram.handle(  );
                    end

                    tf = strcmpi( get_param( elemH, "Mask" ), "on" ) ...
                        && (  ...
                        ~isempty( get_param( elemH, "MaskHelp" ) ) ...
                        || ~isempty( get_param( elemH, "MaskDescription" ) ) ...
                        || ~isempty( get_param( elemH, "MaskNames" ) ) ...
                        || ~isempty( get_param( elemH, "OpenFcn" ) ) ...
                        );
                else
                    tf = false;
                end
            end
            diagram.setIsMaskedSubsystem( tf );
        end

        function setIsVariantSubsystem( this, diagram )
            if ~isempty( this.IsVariantSubsystem )
                tf = this.IsVariantSubsystem;
            else
                diagH = diagram.handle(  );
                tf = isnumeric( diagH ) ...
                    && strcmp( get_param( diagH, "Type" ), "block" ) ...
                    && strcmp( get_param( diagH, "BlockType" ), "SubSystem" ) ...
                    && strcmp( get_param( diagH, "Variant" ), "on" );
            end
            diagram.setIsVariantSubsystem( tf );
        end

        function setParentActiveVariants( ~, diagram )
            parent = diagram.Parent;
            if ( ~isempty( parent ) && parent.IsVariantSubsystem && isempty( parent.activeVariant(  ) ) )
                parentH = parent.handle(  );
                activeVariant = get_param( parentH, "ActiveVariant" );
                if ~isempty( activeVariant )



                    activeVariantBlock = get_param( parentH, "ActiveVariantBlock" );
                    if strcmp( get_param( activeVariantBlock, "Name" ), diagram.Name )
                        parent.setActiveVariant( diagram );
                        if strcmp( get_param( parentH, "VariantActivationTime" ), "update diagram" )
                            parent.setActiveVariantPlusCode( diagram );
                        end
                    end
                end
            end
        end

        function setIsUserLinkAndIsMathworksLink( this, diagram )
            userLink = this.IsUserLink;
            mwLink = this.IsMathworksLink;

            if isempty( userLink ) || isempty( mwLink )
                userLink = false;
                mwLink = false;


                elemH = diagram.ehandle(  );
                if ~isempty( elemH ) && isnumeric( elemH )
                    if strcmp( get_param( elemH, "StaticLinkStatus" ), "resolved" )
                        libblock = get_param( elemH, "ReferenceBlock" );
                    else
                        libblock = get_param( elemH, "TemplateBlock" );
                    end
                    if ~isempty( libblock )
                        if this.Cache.MayNeedToLoadSimulink && startsWith( libblock, "simulink" )
                            load_system( "simulink" );
                            this.Cache.MayNeedToLoadSimulink = false;
                        end
                        libname = bdroot( libblock );
                        mwLink = strcmp( libname, "simulink" ) ...
                            || startsWith(  ...
                            mlreportgen.utils.internal.canonicalPath( get_param( libname, "FileName" ) ),  ...
                            this.TOOLBOXDIR );
                        userLink = ~mwLink;
                    end
                end
            end

            diagram.setIsUserLink( userLink );
            diagram.setIsMathworksLink( mwLink );
        end

        function setDisplayIcon( this, diagram )
            persistent PAT

            if isempty( PAT )
                PAT = "^" + regexptranslate( "escape", matlabroot(  ) );
            end

            if isempty( this.DisplayIcon )
                if diagram.IsModelReference
                    objH = slreportgen.utils.getSlSfObject( diagram.ehandle(  ) );
                else



                    objH = diagram.slproxyobject(  ).Handle;
                end
                icon = slreportgen.utils.getDisplayIcon( objH );
            else
                icon = this.DisplayIcon;
            end
            icon = regexprep( icon, PAT, '$matlabroot' );

            diagram.setDisplayIcon( icon );
        end

        function setDisplayLabel( this, diagram )
            if isempty( this.DisplayLabel )
                label = diagram.normalizedName(  );
            else
                label = this.DisplayLabel;
            end

            if endsWith( label, '*' )
                label = label( 1:end  - 1 );
            end
            diagram.setDisplayLabel( label );
        end

        function setIsCommented( this, diagram )
            if ~isempty( this.IsCommented )
                tf = this.IsCommented;
            else
                objH = diagram.ehandle(  );
                if ~isempty( objH )
                    if isnumeric( objH )
                        commented = get_param( objH, "Commented" );
                        tf = strcmp( commented, "on" ) || strcmp( commented, "through" );
                    else
                        tf = objH.isCommented(  );
                    end
                else
                    tf = false;
                end
            end
            diagram.setIsCommented( tf );
        end
    end
end
