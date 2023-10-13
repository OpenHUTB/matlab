classdef getAUTOSARProperties < handle

    properties ( Access = private, Transient = true )
        IsStrict;

        M3IModelContext;
    end

    properties ( Constant, Access = private )
        UnsupportedCategories = { 'Boolean', 'Complex',  ...
            'ConstantSpecification', 'DataConstr', 'Dependency',  ...
            'Enumeration', 'FixedPoint', 'FloatingPoint',  ...
            'Integer', 'Matrix', 'Structure', 'VoidPointer',  ...
            'LookupTableType', 'SharedAxisType' };

        SupportedInterfaceDictMetaClasses = {  ...
            'Simulink.metamodel.arplatform.common.Package',  ...
            'Simulink.metamodel.arplatform.common.SwAddrMethod',  ...
            'Simulink.metamodel.arplatform.interface.ClientServerInterface',  ...
            'Simulink.metamodel.arplatform.interface.Operation',  ...
            'Simulink.metamodel.arplatform.interface.ParameterInterface',  ...
            'Simulink.metamodel.arplatform.interface.TriggerInterface',  ...
            'Simulink.metamodel.arplatform.interface.ParameterData',  ...
            'Simulink.metamodel.arplatform.interface.Trigger' };

        SupportedInterfaceDictCategories = {  ...
            'Package',  ...
            'SwAddrMethod',  ...
            'ClientServerInterface',  ...
            'ParameterInterface',  ...
            'TriggerInterface' };


        InterfaceDictMetaClassesMappedToSL = {  ...
            'Simulink.metamodel.arplatform.interface.SenderReceiverInterface',  ...
            'Simulink.metamodel.arplatform.interface.NvDataInterface',  ...
            'Simulink.metamodel.arplatform.interface.ModeSwitchInterface',  ...
            'Simulink.metamodel.arplatform.interface.FlowData',  ...
            'Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement' };
    end

    methods ( Access = public )
        function this = getAUTOSARProperties( modelOrInterfaceDictName, isStrict )










            this.M3IModelContext = autosar.api.internal.M3IModelContext.createContext(  ...
                modelOrInterfaceDictName );

            if this.M3IModelContext.isContextMappedToSubComponent(  )
                DAStudio.error( 'autosarstandard:api:subComponentNotSupported' );
            end

            m3iModel = this.M3IModelContext.getM3IModel(  );
            autosar.ui.utils.registerListenerCB( m3iModel );
            if nargin < 2
                isStrict = false;
            end
            this.IsStrict = isStrict;
        end

        function paths = find( this, rootPath, category, varargin )



















            rootPath = convertStringsToChars( rootPath );
            category = convertStringsToChars( category );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end


            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkAPIIsSupported( 'find' );

                m3iModel = this.M3IModelContext.getM3IModel(  );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            paths = this.find_impl( m3iModel, rootPath, category, this.M3IModelContext, varargin{ : } );
        end

        function paramValue = get( this, elementPath, propertyName, varargin )
















            argParser = inputParser;
            argParser.addRequired( 'ElementPath', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.addRequired( 'PropertyName', @( x )( ischar( x ) || isStringScalar( x ) ) );


            elementPath = convertStringsToChars( elementPath );
            propertyName = convertStringsToChars( propertyName );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end

            argParser.parse( elementPath, propertyName );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkAPIIsSupported( 'get', 'ElementPath', elementPath, 'PropertyName', propertyName );

                m3iModel = this.getM3IModel(  );
                if strcmp( elementPath, 'XmlOptions' )
                    if strcmp( propertyName, 'ComponentQualifiedName' )
                        [ isMapped, ~, m3iComp ] = this.M3IModelContext.hasCompMapping(  );
                        assert( isMapped, '%s must be mapped!', this.M3IModelContext.getContextName(  ) );
                        paramValue = autosar.api.Utils.getQualifiedName( m3iComp );
                        return ;
                    elseif any( strcmp( propertyName,  ...
                            autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ) )

                        [ isMapped, ~, m3iComp ] = this.M3IModelContext.hasCompMapping(  );
                        assert( isMapped, '%s must be mapped!', this.M3IModelContext.getContextName(  ) );
                        elementPath = autosar.api.Utils.getQualifiedName( m3iComp );
                    else

                        elementPath = '/';
                        m3iModel = this.getM3IModel( ForXmlOptions = true );
                    end
                end

                this.checkPath( elementPath );


                m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, elementPath );
                [ ~, ~, pathType ] = autosar.api.getAUTOSARProperties.parseInputParams( varargin{ : } );


                if strcmp( propertyName, 'Category' ) && ~m3iObj.has( 'Category' )
                    metaClass = m3iObj.getMetaClass(  ).name;
                    paramValue = metaClass;
                    return
                end


                autosar.api.getAUTOSARProperties.validProperties( m3iObj, this.M3IModelContext, propertyName, 'mixed' )

                paramValue = autosar.api.getAUTOSARProperties.getProperty( m3iObj, propertyName, pathType, this.M3IModelContext );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

        end

        function set( this, elementPath, varargin )
















            autosar.api.Utils.autosarlicensed( true );


            argParser = inputParser;
            argParser.addRequired( 'ElementPath', @( x )( ischar( x ) || isStringScalar( x ) ) );


            elementPath = convertStringsToChars( elementPath );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end

            argParser.parse( elementPath );

            if strcmp( elementPath, 'XmlOptions' )

                elementPath = '/';
                m3iModel = this.getM3IModel( ForXmlOptions = true );
            else
                m3iModel = this.getM3IModel(  );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                this.checkPath( elementPath );


                m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, elementPath );


                this.checkAPIIsSupported( 'set', 'ElementPath', elementPath,  ...
                    'M3IObj', m3iObj, 'ParameterValuePairs', varargin );


                [ propertyNames, propertyValues ] = autosar.api.getAUTOSARProperties.parseInputParams( varargin{ : } );


                autosar.api.getAUTOSARProperties.validProperties( m3iObj, this.M3IModelContext, propertyNames, 'noncomposite' )


                assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before set' );
                trans = M3I.Transaction( m3iObj.rootModel );
                autosar.api.getAUTOSARProperties.setProperties( m3iObj, propertyNames, propertyValues, this.M3IModelContext );
                trans.commit(  );
                assert( m3iObj.rootModel.unparented.isEmpty(  ), 'Unparented objects after set' );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function addPackageableElement( this, category, package, name, varargin )


























            autosar.api.Utils.autosarlicensed( true );


            this.checkAPIIsSupported( 'addPackageableElement', Category = category );


            package = convertStringsToChars( package );
            name = convertStringsToChars( name );


            qname = [ package, '/', name ];
            qname = strrep( qname, '//', '/' );
            isForSharedElement = autosar.api.getAUTOSARProperties.getIsSharedElementFromCategory( category );
            [ nodePath, nodeName ] = this.getOrAddPackage( qname, isForSharedElement );
            this.add( nodePath, 'packagedElement', nodeName,  ...
                'Category', category, varargin{ : } );
        end

        function add( this, parentPath, propertyName, name, varargin )














            autosar.api.Utils.autosarlicensed( true );


            argParser = inputParser;
            argParser.addRequired( 'ParentPath', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.addRequired( 'PropertyName', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.addRequired( 'Name', @( x )( ischar( x ) || isStringScalar( x ) ) );


            parentPath = convertStringsToChars( parentPath );
            propertyName = convertStringsToChars( propertyName );
            name = convertStringsToChars( name );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end

            argParser.parse( parentPath, propertyName, name );
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                [ childPropertyNames, childPropertyValues, ~, childCategory ] = autosar.api.getAUTOSARProperties.parseInputParams( varargin{ : } );

                m3iModel = this.M3IModelContext.getM3IModel(  );
                if strcmp( propertyName, 'packagedElement' ) &&  ...
                        autosar.api.getAUTOSARProperties.getIsSharedElementFromCategory( childCategory )
                    m3iModel = autosar.api.getAUTOSARProperties.getSharedM3IModel( m3iModel );
                end

                this.checkPath( parentPath );

                childPath = [ parentPath, '/', name ];


                autosar.api.getAUTOSARProperties.checkNoObjByPartialOrFullPath( m3iModel, childPath );


                m3iParentObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, parentPath );


                this.checkAPIIsSupported( 'add', 'M3IObj', m3iParentObj );


                autosar.api.getAUTOSARProperties.validProperties( m3iParentObj, this.M3IModelContext, propertyName, 'composite' )


                if ~strcmp( propertyName, 'packagedElement' )
                    autosar.api.getAUTOSARProperties.errorOutIfReadOnlyObject( m3iParentObj );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end

            if strcmp( propertyName, 'packagedElement' )
                childMetaClass = Simulink.metamodel.foundation.PackageableElement.MetaClass;
            else
                childMetaClass = m3iParentObj.getMetaClass(  ).getProperty( propertyName ).type;
            end
            if isempty( childCategory )
                if childMetaClass.isAbstract
                    validCategoryNames = autosar.api.getAUTOSARProperties.concreteMetaClassNames( childMetaClass );
                    validCategoryNames = setdiff( validCategoryNames, this.UnsupportedCategories );
                    DAStudio.error( 'RTW:autosar:apiNeedCategory', childPath,  ...
                        autosar.api.Utils.cell2str( validCategoryNames ) );
                end
            else

                validCategoryNames = autosar.api.getAUTOSARProperties.concreteMetaClassNames( childMetaClass );
                validCategoryNames = setdiff( validCategoryNames, this.UnsupportedCategories );
                invalidCategory = setdiff( childCategory, validCategoryNames );
                if ~isempty( invalidCategory )
                    validCategoryNames = sort( validCategoryNames );
                    DAStudio.error( 'RTW:autosar:apiInvalidCategory', invalidCategory{ 1 }, childPath,  ...
                        autosar.api.Utils.cell2str( validCategoryNames ) );
                end

                childMetaClass = autosar.api.getAUTOSARProperties.getMetaClassFromCategory( childCategory );
            end
            childMetaClassQualifiedName = childMetaClass.qualifiedName;

            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before add' );
            trans = M3I.Transaction( m3iModel );
            m3iChildObj = feval( childMetaClassQualifiedName, m3iModel );


            if this.isSequence( m3iParentObj.getMetaClass(  ).getProperty( propertyName ) )
                m3iParentObj.( propertyName ).append( m3iChildObj );
            else
                if m3iParentObj.( propertyName ).isvalid(  )


                    elemPath = [ parentPath, '/', m3iParentObj.( propertyName ).Name ];
                    DAStudio.error( 'RTW:autosar:apiElementExists', elemPath );
                end
                m3iParentObj.( propertyName ) = m3iChildObj;
            end
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                autosar.api.getAUTOSARProperties.validProperties( m3iChildObj, this.M3IModelContext, childPropertyNames, 'noncomposite' );


                autosar.api.getAUTOSARProperties.setProperty( m3iChildObj, 'Name', name, this.M3IModelContext );


                if isa( m3iChildObj,  ...
                        'Simulink.metamodel.arplatform.behavior.Runnable' )
                    autosar.api.getAUTOSARProperties.setProperty(  ...
                        m3iChildObj, 'symbol', name, this.M3IModelContext );
                end
                autosar.api.getAUTOSARProperties.setProperties( m3iChildObj, childPropertyNames, childPropertyValues, this.M3IModelContext );


                autosar.api.getAUTOSARProperties.isComplete( m3iChildObj );


                validator = autosar.validation.MetaModelCommonValidator(  ...
                    this.M3IModelContext.getContextName(  ) );
                validator.verify( m3iChildObj );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after add' );
        end

        function delete( this, elementPath )












            autosar.api.Utils.autosarlicensed( true );


            argParser = inputParser;
            argParser.addRequired( 'ElementPath', @( x )( ischar( x ) || isStringScalar( x ) ) );


            elementPath = convertStringsToChars( elementPath );

            argParser.parse( elementPath );
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                autosar.api.getAUTOSARProperties.checkIsNamedElement( 'delete', elementPath );

                this.checkPath( elementPath );


                m3iModel = this.M3IModelContext.getM3IModel(  );
                m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, elementPath );


                this.checkAPIIsSupported( 'delete', 'M3IObj', m3iObj );



                autosar.api.getAUTOSARProperties.checkObjectIsNotReferenced( m3iObj );

                if ~autosar.api.getAUTOSARProperties.isPackagedElement( m3iObj )



                    autosar.api.getAUTOSARProperties.errorOutIfReadOnlyObject( m3iObj );
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end


            m3iModel = m3iObj.rootModel;
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before delete' );
            trans = M3I.Transaction( m3iModel );
            m3iObj.destroy(  );
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after delete' );
        end

        function deleteUnmappedComponents( this )













            autosar.api.Utils.autosarlicensed( true );


            this.checkAPIIsSupported( 'deleteUnmappedComponents' );

            mappedComponent = this.get( 'XmlOptions', 'ComponentQualifiedName' );
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                m3iModel = this.M3IModelContext.getM3IModel(  );
                m3iCompositions = autosar.mm.Model.findChildByTypeName( m3iModel,  ...
                    'Simulink.metamodel.arplatform.composition.CompositionComponent' );
                m3iCompositions = autosar.composition.Utils.sortCompositionsInTopdownOrder( m3iCompositions );
                compositionNames = m3i.mapcell( @autosar.api.Utils.getQualifiedName, m3iCompositions );
                swcNames = this.find( [  ], 'AtomicComponent', 'PathType', 'FullyQualified' );
                allComps = [ compositionNames, swcNames ];
                for ii = 1:length( allComps )
                    comp = allComps{ ii };
                    if ~strcmp( mappedComponent, comp )

                        try
                            this.delete( comp );
                        catch ME
                            if strcmp( ME.identifier, 'RTW:autosar:apiDeleteReferencedElementErr' )


                            else
                                rethrow( ME );
                            end
                        end
                    end
                end



                this.deleteM3ISystemsThatReferenceM3ICompositions( m3iModel, m3iCompositions );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function createNumericType( this, name, varargin )
































            autosar.api.Utils.autosarlicensed( true );


            this.checkAPIIsSupported( 'createNumericType' );


            name = convertStringsToChars( name );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end

            narginchk( 3, 4 );
            if nargin == 3
                creatingFromAppType = true;
            else
                assert( nargin == 4, 'incorrect number of arguments passed to createNumericType.' );
                creatingFromAppType = false;
            end

            isEnumType = false;
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                [ typeM3iObj, cmM3iObj ] = this.parseArgsForCreateNumericOrEnumType(  ...
                    name, creatingFromAppType, isEnumType, varargin{ : } );
                autosar.mm.mm2sl.TypeBuilder.createNumericTypeFromCompuMethod(  ...
                    this.M3IModelContext.getContextName(  ), name, cmM3iObj, typeM3iObj );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function createEnumeration( this, name, varargin )



































            autosar.api.Utils.autosarlicensed( true );


            this.checkAPIIsSupported( 'createEnumeration' );


            name = convertStringsToChars( name );
            for ii = 1:length( varargin )
                if isstring( varargin{ ii } )
                    varargin{ ii } = convertStringsToChars( varargin{ ii } );
                end
            end

            creatingFromBfttType = false;
            narginchk( 2, 4 );
            switch nargin
                case 2

                    creatingFromBfttType = true;
                case 3


                    creatingFromAppType = true;
                case 4


                    creatingFromAppType = false;
                otherwise
                    assert( false, 'incorrect number of arguments passed to createEnumeration.' );
                    creatingFromAppType = false;
            end

            if creatingFromBfttType
                m3iModel = this.M3IModelContext.getM3IModel(  );
                dd = this.M3IModelContext.getDataDictionaryName(  );


                cmCategory = this.get( name, 'Category' );



                if strcmp( cmCategory, 'LinearAndTextTable' )
                    m3iObjSeq = autosar.mm.Model.findObjectByName( m3iModel, name );
                    assert( m3iObjSeq.size(  ) > 0 );
                    autosar.mm.mm2sl.TypeBuilder.createEnumsForBitfieldCompuMethod( m3iObjSeq.at( 1 ), dd );
                end
            else
                dd = this.M3IModelContext.getDataDictionaryName(  );
                try

                    cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                    [ typeM3iObj, cmM3iObj ] = this.parseArgsForCreateNumericOrEnumType(  ...
                        name, creatingFromAppType, true, varargin{ : } );

                    isAdaptive = this.M3IModelContext.isContextMappedToAdaptiveApplication(  );

                    autosar.mm.mm2sl.TypeBuilder.createEnumerationFromCompuMethod(  ...
                        name, cmM3iObj, typeM3iObj, dd, isAdaptive );
                catch Me

                    autosar.mm.util.MessageReporter.throwException( Me );
                end
            end
        end

        function createSystemConstants( this, elementPath )


















            autosar.api.Utils.autosarlicensed( true );


            this.checkAPIIsSupported( 'createSystemConstants' );

            argParser = inputParser;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.addRequired( 'ElementPath', @( x )( ( ischar( x ) || isStringScalar( x ) ) && ~isempty( x ) || iscell( x ) ) );


            elementPath = convertStringsToChars( elementPath );

            argParser.parse( this, elementPath );

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                m3iModel = this.M3IModelContext.getM3IModel(  );
                m3iObjs = {  };
                m3iSystemConstantValueSets = {  };
                m3iPostBuildVariantCriterionValueSets = {  };
                if iscell( argParser.Results.ElementPath )
                    for ii = 1:numel( argParser.Results.ElementPath )
                        m3iObj = this.findObjByPartialOrFullPath( m3iModel, argParser.Results.ElementPath{ ii } );
                        m3iObjs = [ m3iObjs, m3iObj ];%#ok<AGROW>
                    end
                else
                    m3iObj = this.findObjByPartialOrFullPath( m3iModel, argParser.Results.ElementPath );
                    m3iObjs = [ m3iObjs, m3iObj ];
                end
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
            for ii = 1:numel( m3iObjs )
                m3iObj = m3iObjs( ii );
                if isa( m3iObj, 'Simulink.metamodel.arplatform.variant.PredefinedVariant' )
                    m3iSystemConstantValueSets =  ...
                        autosar.api.Utils.getSystemConstValueSetsFromPredefinedVariant(  ...
                        m3iObj,  ...
                        m3iSystemConstantValueSets );
                    m3iPostBuildVariantCriterionValueSets =  ...
                        autosar.api.Utils.getPostBuildVariantCriterionValueSetsFromPredefinedVariant(  ...
                        m3iObj,  ...
                        m3iPostBuildVariantCriterionValueSets );
                elseif isa( m3iObj, 'Simulink.metamodel.arplatform.variant.SystemConstValueSet' )
                    m3iSystemConstantValueSets = [ m3iSystemConstantValueSets, m3iObj ];%#ok<AGROW>
                elseif isa( m3iObj, 'Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet' )
                    m3iPostBuildVariantCriterionValueSets = [ m3iPostBuildVariantCriterionValueSets, m3iObj ];%#ok<AGROW>
                else
                    DAStudio.error( 'autosarstandard:api:invalidElementPath', elementPath, 'PredefinedVariant|SystemConstantValueSet|PostBuildVariantCriterionValueSet', 'System Constants or Post-Build Criterions' );
                end
            end
            if numel( m3iObjs ) > 0
                autosar.api.Utils.createSystemConstantParams(  ...
                    this.M3IModelContext.getContextName(  ), m3iSystemConstantValueSets );
            end
        end

        function createManifest( this )












            this.checkAPIIsSupported( 'createManifest' );


            autosar.api.Utils.autosarlicensed( true );


            if ~this.M3IModelContext.isContextMappedToAdaptiveApplication(  )
                DAStudio.error( 'autosarstandard:api:modelNotMappedToAdaptiveAUTOSAR',  ...
                    this.M3IModelContext.getContextName(  ) );
            end
            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                autosar.internal.adaptive.manifest.createManifestJsonFiles(  ...
                    this.M3IModelContext.getContextName(  ), this );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end
    end

    methods ( Static, Access = protected )

        function attributeSeq = doFindCompositeAttributes( m3iObj )


            isComposite = true;
            attributeSeq = Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes( m3iObj, isComposite );
        end

        function attributeSeq = doFindNonCompositeAttributes( m3iObj )


            isComposite = false;
            attributeSeq = Simulink.metamodel.arplatform.ModelFinder.findViewableAttributes( m3iObj, isComposite );
        end

    end

    methods ( Access = private )
        function [ nodePath, nodeName ] = getOrAddPackage( this, qualifiedName, isForSharedElement )





            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qualifiedName, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );

            m3iModel = this.M3IModelContext.getM3IModel(  );
            if isForSharedElement
                m3iModel = autosar.api.getAUTOSARProperties.getSharedM3IModel( m3iModel );
            end

            [ nodePath, nodeName ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qualifiedName );
            autosar.mm.Model.getOrAddARPackage( m3iModel, nodePath );
        end

        function checkAPIIsSupported( this, methodName, varargin )



            argParser = inputParser;
            argParser.addParameter( 'ElementPath', '' );
            argParser.addParameter( 'PropertyName', '' );
            argParser.addParameter( 'M3IObj', [  ] );
            argParser.addParameter( 'Category', '' );
            argParser.addParameter( 'ParameterValuePairs', [  ] );
            argParser.parse( varargin{ : } );

            elementPath = argParser.Results.ElementPath;
            propertyName = argParser.Results.PropertyName;
            category = argParser.Results.Category;
            m3iObj = argParser.Results.M3IObj;
            parameterValuePairs = argParser.Results.ParameterValuePairs;

            m3iModel = this.M3IModelContext.getM3IModel(  );
            if this.M3IModelContext.isContextArchitectureModel(  )
                this.checkAPISupportForArchitectureModel( methodName,  ...
                    elementPath, propertyName, parameterValuePairs );
            else
                if any( strcmp( methodName, { 'get', 'find' } ) )




                    return ;
                end



                isRefSharedM3IModel = autosar.dictionary.Utils.hasReferencedModels( m3iModel );
                if isRefSharedM3IModel
                    [ ~, dictFullName ] = autosar.dictionary.Utils.getUniqueReferencedModel( m3iModel );
                else
                    [ isSharedM3IModel, dictFullName ] = autosar.dictionary.Utils.isSharedM3IModel( m3iModel );
                end

                if isRefSharedM3IModel || isSharedM3IModel
                    sharedM3IModel =  ...
                        Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel( dictFullName );
                    if ~isempty( m3iObj ) && sharedM3IModel ~= m3iObj.modelM3I



                        return ;
                    end
                    if autosar.dictionary.Utils.isAUTOSARInterfaceDictionary( dictFullName )
                        this.checkAPISupportForInterfaceDictionary(  ...
                            methodName, parameterValuePairs, category, m3iObj );
                    else
                        this.checkAPISupportForSharedAUTOSARDictionary(  ...
                            methodName, elementPath, m3iObj );
                    end
                end
            end
        end

        function checkAPISupportForSharedAUTOSARDictionary( this, methodName, elementPath, m3iObj )




            throwError = false;
            switch ( methodName )
                case { 'get', 'find', 'createNumericType', 'createEnumeration', 'createSystemConstants' }

                case 'set'

                    if autosar.dictionary.Utils.isSharedM3IModel( m3iObj.rootModel )
                        throwError = ~any( strcmp( elementPath, { '/', 'XmlOptions' } ) );
                    end
                case { 'addPackageableElement', 'deleteUnmappedComponents', 'createManifest' }
                    throwError = true;
                otherwise

                    throwError = autosar.dictionary.Utils.isSharedM3IModel( m3iObj.rootModel );
            end

            if throwError
                dictFile = this.M3IModelContext.getDataDictionaryName(  );
                DAStudio.error( 'autosarstandard:api:getAUTOSARPropertiesNotSupportedForSharedDict',  ...
                    methodName, dictFile );
            end
        end

        function checkAPISupportForInterfaceDictionary( this, methodName,  ...
                parameterValuePairs, category, m3iObj )



            throwError = false;
            dictName = autosar.utils.File.dropPath( this.M3IModelContext.getContextName(  ) );

            if isa( this.M3IModelContext, 'autosar.api.internal.M3IModelSLModelContext' )




                switch ( methodName )
                    case { 'get', 'find', 'deleteUnmappedComponents' }

                    case { 'set', 'add', 'delete' }
                        if ~any( strcmp( parameterValuePairs, 'ComponentQualifiedName' ) ) &&  ...
                                ~any( strcmp( parameterValuePairs, 'InternalBehaviorQualifiedName' ) ) &&  ...
                                ~any( strcmp( parameterValuePairs, 'ImplementationQualifiedName' ) )
                            assert( m3iObj.rootModel ~= this.M3IModelContext.getM3IModel,  ...
                                'should not be here if m3iObj is owned by Simulink model m3iModel' );
                            throwError = true;
                        end
                    case { 'addPackageableElement' }
                        throwError = autosar.api.getAUTOSARProperties.getIsSharedElementFromCategory( category );
                    otherwise
                        throwError = true;
                end

                if throwError

                    DAStudio.error( 'autosarstandard:dictionary:ModifyInterfaceDictArPropsThroughModel',  ...
                        dictName );
                end
            else





                switch ( methodName )
                    case { 'get', 'find' }

                    case 'set'
                        propertyNames = autosar.api.getAUTOSARProperties.parseInputParams( parameterValuePairs{ : } );
                        if any( strcmp( propertyNames, 'Name' ) ) &&  ...
                                any( cellfun( @( x )isa( m3iObj, x ), this.InterfaceDictMetaClassesMappedToSL ) )



                            throwError = true;
                        end
                    case { 'addPackageableElement' }
                        throwError = ~any( strcmp( category, this.SupportedInterfaceDictCategories ) );
                    case 'add'
                        throwError = ~any( cellfun( @( x )isa( m3iObj, x ), this.SupportedInterfaceDictMetaClasses ) );
                    case 'delete'
                        throwError = ~any( cellfun( @( x )isa( m3iObj, x ), this.SupportedInterfaceDictMetaClasses ) );
                    otherwise
                        throwError = true;
                end
            end

            if throwError
                DAStudio.error( 'autosarstandard:dictionary:getARPropsNotSupportedForInterfaceDict',  ...
                    methodName, dictName );
            end
        end

        function checkAPISupportForArchitectureModel( this, methodName,  ...
                elementPath, propertyName, parameterValuePairs )




            if ~this.M3IModelContext.isContextArchitectureModel(  ) ||  ...
                    this.IsStrict
                return
            end

            switch ( methodName )
                case 'get'

                    this.errorOutForNonXmlOptionsForArchModel( methodName, elementPath, propertyName );
                case 'set'




                    propertyNames = autosar.api.getAUTOSARProperties.parseInputParams( parameterValuePairs{ : } );
                    cellfun( @( x )this.errorOutForNonXmlOptionsForArchModel( methodName, elementPath, x ), propertyNames );
                otherwise
                    DAStudio.error( 'autosarstandard:api:getAUTOSARPropertiesNotSupportedForArchModel' );
            end
        end

        function errorOutForNonXmlOptionsForArchModel( this, methodName, elementPath, propertyName )%#ok<INUSD>
            import Simulink.interface.dictionary.internal.DictionaryClosureUtils



            if any( strcmp( elementPath, { '/', 'XmlOptions' } ) ) &&  ...
                    ~any( strcmp( propertyName, autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ) )

            else
                DAStudio.error( 'autosarstandard:api:getAUTOSARPropertiesNotSupportedForArchModel' );
            end
        end

        function checkPath( this, pathStr )


            if this.IsStrict && ~strcmp( pathStr( 1 ), '/' )

                DAStudio.error( 'autosarstandard:api:inefficientElementPath', pathStr );
            end
        end

        function [ typeM3iObj, cmM3iObj ] = parseArgsForCreateNumericOrEnumType(  ...
                this, name, creatingFromAppType, isEnumType, varargin )

            argParser = inputParser;
            argParser.addRequired( 'this', @( x )isa( x, class( x ) ) );
            argParser.addRequired( 'Name', @( x )( ischar( x ) && ~isempty( x ) ) );
            if creatingFromAppType
                argParser.addRequired( 'ApplicationDataTypePath', @( x )( ischar( x ) && ~isempty( x ) ) );
            else
                argParser.addRequired( 'CompuMethodPath', @( x )( ischar( x ) && ~isempty( x ) ) );
                argParser.addRequired( 'ImplementationDataTypePath', @( x )( ischar( x ) && ~isempty( x ) ) );
            end
            argParser.parse( this, name, varargin{ : } );


            if ( creatingFromAppType )
                dataTypePath = argParser.Results.ApplicationDataTypePath;
            else
                dataTypePath = argParser.Results.ImplementationDataTypePath;
            end

            if isEnumType
                slObjType = 'Simulink Enumeration';
            else
                slObjType = 'Simulink.NumericType';
            end


            m3iModel = this.M3IModelContext.getM3IModel(  );
            typeM3iObj = this.findObjByPartialOrFullPath( m3iModel, dataTypePath );
            if ~isa( typeM3iObj, 'Simulink.metamodel.types.PrimitiveType' ) ||  ...
                    creatingFromAppType && ~typeM3iObj.IsApplication
                if creatingFromAppType
                    typeStr = 'ApplicationDataType';
                else
                    typeStr = 'ImplementationDataType';
                end
                DAStudio.error( 'autosarstandard:api:invalidElementPath', dataTypePath, typeStr, slObjType );
            end


            if typeM3iObj.IsApplication
                cmM3iObj = typeM3iObj.CompuMethod;
                assert( ~isempty( cmM3iObj ), '%s does not reference a valid CompuMethod.', dataTypePath );
            else
                cmM3iObj = this.findObjByPartialOrFullPath( m3iModel, argParser.Results.CompuMethodPath );
                if ~isa( cmM3iObj, 'Simulink.metamodel.types.CompuMethod' )
                    DAStudio.error( 'autosarstandard:api:invalidElementPath', compuMethodPath, 'CompuMethod', slObjType );
                end
            end
        end

        function deleteM3ISystemsThatReferenceM3ICompositions( this, m3iModel, m3iCompositions )

            m3iSystems = autosar.mm.Model.findObjectByMetaClass( m3iModel,  ...
                Simulink.metamodel.arplatform.system.System.MetaClass );
            if m3iSystems.isEmpty(  )
                return
            end

            m3iSystemsReferencingCompositions = m3i.mapcell( @( x ) ...
                autosar.system.Utils.findM3iSystemAmongstSystemsForM3iComp( m3iSystems, x ), m3iCompositions );
            systemNames = m3i.mapcell( @autosar.api.Utils.getQualifiedName, m3iSystemsReferencingCompositions );
            for i = 1:length( systemNames )
                this.delete( systemNames{ i } );
            end
        end
    end

    methods ( Static, Access = private )




        function [ propertyNames, propertyValues, pathType, category, name ] = parseInputParams( varargin )

            p = inputParser;
            p.KeepUnmatched = true;
            p.PartialMatching = false;
            p.FunctionName = 'getAUTOSARProperties';
            hasCategory = false;
            if nargout > 3
                hasCategory = true;
                p.addParameter( 'Category', '' );
            end
            hasName = false;
            if nargout > 4
                hasName = true;
                p.addParameter( 'Name', '' );
            end

            p.addParameter( 'PathType', 'PartiallyQualified', @( x )any( validatestring( x, { 'FullyQualified', 'PartiallyQualified' } ) ) );
            p.parse( varargin{ : } );

            if hasCategory
                category = p.Results.Category;
            end
            if hasName
                name = p.Results.Name;
            end
            pathType = p.Results.PathType;

            params = p.Unmatched;
            propertyNames = fieldnames( params );
            propertyValues = struct2cell( params );

        end





        function setProperties( m3iOrigObj, propertyNames, propertyValues, m3iModelContext )
            cmpResult = strcmp( propertyNames, 'MoveElements' );
            if any( cmpResult )
                moveElementsMode = propertyValues{ cmpResult };
            else
                moveElementsMode = 'All';
            end

            for ii = 1:length( propertyNames )
                if any( strcmp( propertyNames{ ii }, [ { 'ComponentQualifiedName' } ...
                        , autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ] ) )

                    [ isMapped, ~, m3iComp ] = m3iModelContext.hasCompMapping(  );
                    assert( isMapped, '%s must be mapped!', m3iModelContext.getContextName(  ) );
                    m3iObj = m3iComp;
                else
                    m3iObj = m3iOrigObj;
                end



                needToOpenTran = m3iOrigObj.rootModel ~= m3iObj.rootModel;
                if needToOpenTran
                    tran = M3I.Transaction( m3iObj.rootModel );
                end

                if strcmp( 'ComponentQualifiedName', propertyNames{ ii } )


                    oldPropValue = autosar.api.Utils.getQualifiedName( m3iObj );
                else
                    autosar.api.getAUTOSARProperties.setProperty( m3iObj, propertyNames{ ii }, propertyValues{ ii }, m3iModelContext, moveElementsMode );
                end

                if strcmp( 'ComponentQualifiedName', propertyNames{ ii } )
                    autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                        propertyValues{ ii }, 'absPathShortName', m3iModelContext.getMaxShortNameLength(  ) );
                    autosar.api.Utils.syncComponentQualifiedName( m3iObj,  ...
                        oldPropValue, propertyValues{ ii } );

                    [ isMapped, modelMapping ] = m3iModelContext.hasCompMapping(  );
                    assert( isMapped, '%s must be mapped!', m3iModelContext.getContextName(  ) );
                    assert( ~isempty( modelMapping.MappedTo ), 'model is not mapped correctly' )

                    componentQName = strrep( propertyValues{ ii }, '/', '.' );
                    modelMapping.MappedTo.UUID = [ 'AUTOSAR', componentQName ];
                end

                if needToOpenTran
                    tran.commit(  );
                end
            end
        end

        function setProperty( m3iObj, extPropertyName, propertyValue, m3iModelContext, moveElementsMode )

            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.api.Utils;

            if nargin < 5
                moveElementsMode = 'All';
            end




            if ~autosar.mm.util.ExternalToolInfoAdapter.isProperty( m3iObj, extPropertyName )
                autosar.api.getAUTOSARProperties.errorOutIfReadOnlyObject( m3iObj );
            end

            if isa( m3iObj, 'Simulink.metamodel.arplatform.common.AUTOSAR' ) ||  ...
                    any( strcmp( extPropertyName,  ...
                    autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ) )
                autosar.api.getAUTOSARProperties.setXmlOptionProperty( m3iObj,  ...
                    extPropertyName, propertyValue, moveElementsMode, m3iModelContext );
                return ;
            end

            m3iModel = m3iModelContext.getM3IModel(  );
            if isa( m3iObj, 'Simulink.metamodel.arplatform.instance.TriggerInstanceRef' ) &&  ...
                    strcmp( extPropertyName, 'Trigger' )



                propertyName = extPropertyName;
            else
                propertyName = autosar.api.getAUTOSARProperties.getIntPropertyName( extPropertyName );
            end
            if autosar.mm.util.ExternalToolInfoAdapter.isProperty( m3iObj, extPropertyName )
                autosar.mm.util.ExternalToolInfoAdapter.set(  ...
                    m3iModelContext.getContextName(  ), m3iObj, extPropertyName, propertyValue );
                return ;
            end


            switch propertyName
                case 'Name'
                    autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                        propertyValue, 'shortname', m3iModelContext.getMaxShortNameLength(  ) );


                    m3iParentObj = m3iObj.containerM3I;
                    siblingSeq = m3iParentObj.containeeM3I;
                    for ii = 1:siblingSeq.size(  )
                        m3iSiblingObj = siblingSeq.at( ii );
                        if m3iSiblingObj == m3iObj
                            continue ;
                        end

                        if isa( m3iSiblingObj, 'Simulink.metamodel.foundation.NamedElement' )
                            if strcmp( propertyValue, m3iSiblingObj.Name )
                                siblingQName = autosar.api.Utils.getQualifiedName( m3iSiblingObj );
                                DAStudio.error( 'RTW:autosar:apiElementExists', siblingQName );
                            end
                        end
                    end
                case [ { 'ComponentQualifiedName' }, autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ]
                    autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                        propertyValue, 'absPathShortName', m3iModelContext.getMaxShortNameLength(  ) );

                case { 'symbol', 'Symbol' }




                    [ isValid, errmsg ] = autosar.validation.AutosarUtils.checkSymbol( propertyValue );
                    if ~isValid
                        error( 'RTW:autosar:invalidSymbol',  ...
                            errmsg );
                    end
                    if isa( m3iObj, 'Simulink.metamodel.arplatform.behavior.Runnable' )



                        hasClash =  ...
                            autosar.api.Utils.checkRunnableSymbolClash(  ...
                            m3iObj, propertyValue );
                        if hasClash
                            DAStudio.error(  ...
                                'RTW:autosar:runnableSymbolClash',  ...
                                propertyValue );
                        end
                    end
                case 'DisplayFormat'
                    if isa( m3iObj, 'Simulink.metamodel.types.CompuMethod' ) ||  ...
                            isa( m3iObj, 'Simulink.metamodel.arplatform.common.Data' )
                        [ isValid, ~ ] = autosar.validation.AutosarUtils.checkDisplayFormat(  ...
                            propertyValue, autosar.api.Utils.getQualifiedName( m3iObj ) );
                        if ~isValid
                            DAStudio.error( 'autosarstandard:ui:validateDisplayFormat', autosar.api.Utils.getQualifiedName( m3iObj ) );
                        end
                    end
                case 'Category'
                    if isa( m3iObj, 'Simulink.metamodel.types.CompuMethod' )
                        if strcmp( propertyValue, 'RatFunc' )
                            DAStudio.error( 'autosarstandard:common:CompuMethodCategoryRatFuncNotAllowed', m3iObj.Name )
                        elseif strcmp( propertyValue, 'LinearAndTextTable' )
                            DAStudio.error( 'autosarstandard:common:CompuMethodCategoryLinearAndTextTableNotAllowed', m3iObj.Name )
                        end
                    end
                case 'Interface'
                    if isa( m3iObj, 'Simulink.metamodel.arplatform.port.ModeSenderPort' )
                        msInterfaceObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, propertyValue );
                        errorIDAndHoles = autosar.validation.ClassicMetaModelValidator.verifyModeSwitchInterface( msInterfaceObj );
                        if ~isempty( errorIDAndHoles )
                            DAStudio.error( errorIDAndHoles{ : } );
                        end
                    end
                case autosar.ui.comspec.ComSpecPropertyHandler.getSupportedComSpecProperties(  )
                    [ errId, suggestion ] = autosar.ui.comspec.ComSpecPropertyHandler.checkComSpecPropertyValue(  ...
                        propertyName, propertyValue );
                    if ~isempty( errId )
                        DAStudio.error( errId, mat2str( propertyValue ), propertyName,  ...
                            suggestion )
                    end
                    if strcmp( propertyName, 'InitValue' ) || strcmp( propertyName, 'InitialValue' )



                        autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(  ...
                            m3iObj, propertyName, propertyValue );
                        return ;
                    end
                case 'InstanceIdentifier'
                    if isa( m3iObj, 'Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment' )
                        assert( isa( m3iModelContext, 'autosar.api.internal.M3IModelSLModelContext' ),  ...
                            'context for m3iModel should be a Simulink model' );
                        autosar.internal.adaptive.manifest.ManifestUtilities.setInstanceIdForDeploymentObj(  ...
                            m3iModelContext.getContextName(  ), m3iObj, propertyValue );
                        return ;
                    elseif isa( m3iObj, 'Simulink.metamodel.arplatform.manifest.DdsProvidedServiceInstance' ) ||  ...
                            isa( m3iObj, 'Simulink.metamodel.arplatform.manifest.DdsRequiredServiceInstance' )
                        propertyValue = strtrim( propertyValue );
                        [ isValid, ~ ] = autosar.validation.AutosarUtils.checkServiceInstanceId( propertyValue, class( m3iObj ) );
                        if ~isValid
                            DAStudio.error( 'autosarstandard:ui:validateServiceInstanceId', class( m3iObj ) );
                        end
                    end
                case 'Direction'
                    m3iItf = m3iObj.containerM3I.containerM3I;
                    validDirections = autosar.mm.util.ArgumentDirectionHelper.getValidDirectionsFor( m3iItf );

                    if ~ismember( propertyValue, validDirections )
                        DAStudio.error( 'RTW:autosar:apiInvalidPropertyValue',  ...
                            propertyValue, propertyName,  ...
                            autosar.api.Utils.cell2str( validDirections ) );
                    end
                case { 'MajorVersion', 'MinorVersion' }
                    [ isValid, errmsg ] = autosar.validation.AutosarUtils.checkVersion( propertyValue, 1 );
                    if ~isValid
                        DAStudio.error( errmsg{ 1 }, propertyValue, propertyName, errmsg{ 2 } );
                    end
                otherwise

            end


            m3iProperty = m3iObj.getMetaClass(  ).getProperty( propertyName );
            m3iPropertyType = m3iProperty.type;
            m3iPropertyTypeName = m3iPropertyType.name;


            if isa( m3iPropertyType, 'M3I.ImmutableEnumeration' )
                propertyValue =  ...
                    autosar.api.getAUTOSARProperties.checkAndConvertToEnumLiteral(  ...
                    m3iProperty, propertyValue );
            end

            if strcmp( m3iPropertyTypeName, 'FlowDataPortInstanceRef' ) ||  ...
                    strcmp( m3iPropertyTypeName, 'ModeDeclarationInstanceRef' ) ||  ...
                    strcmp( m3iPropertyTypeName, 'OperationPortInstanceRef' ) ||  ...
                    strcmp( m3iPropertyTypeName, 'TriggerInstanceRef' )







                isSeq = autosar.api.getAUTOSARProperties.isSequence( m3iProperty );
                propertyValues = cellstr( propertyValue );


                dataObj = autosar.api.getAUTOSARProperties( m3iModelContext.getContextName(  ) );

                compQName = dataObj.get( 'XmlOptions', 'ComponentQualifiedName' );
                m3iCompSeq = autosar.mm.Model.findObjectByName( m3iModel, compQName );
                assert( m3iCompSeq.size(  ) == 1 )
                m3iComp = m3iCompSeq.at( 1 );

                instanceRefMetaClassQualifiedName = m3iPropertyType.qualifiedName;
                instanceRefMetaClassName = m3iPropertyTypeName;


                if isSeq


                    m3iObj.( propertyName ).clear;
                end

                validTriggerIds = autosar.mm.util.InstanceRefAdapter.getValidShortIds( m3iComp, instanceRefMetaClassName );
                for ii = 1:length( propertyValues )
                    propertyValue = propertyValues{ ii };

                    m3iInstanceRef = feval( instanceRefMetaClassQualifiedName, m3iModel );
                    if ~m3iComp.instanceMapping.isvalid(  )
                        m3iComp.instanceMapping =  ...
                            Simulink.metamodel.arplatform.instance.ComponentInstanceRef( m3iModel );
                    end
                    m3iComp.instanceMapping.instance.append( m3iInstanceRef );


                    instanceRefId = propertyValue;

                    if ~any( strcmp( instanceRefId, validTriggerIds ) )

                        DAStudio.error( 'RTW:autosar:apiInvalidPropertyValue',  ...
                            instanceRefId,  ...
                            extPropertyName,  ...
                            autosar.api.Utils.cell2str( validTriggerIds ) );
                    end


                    dotIdx = find( instanceRefId == '.' );
                    portName = instanceRefId( 1:dotIdx - 1 );
                    arg2 = instanceRefId( dotIdx + 1:end  );

                    portQName = [ compQName, '/', portName ];
                    interfaceQName = dataObj.get( portQName, 'Interface', 'PathType', 'FullyQualified' );

                    autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'Port', portQName, m3iModelContext );
                    if strcmp( m3iPropertyTypeName, 'FlowDataPortInstanceRef' )
                        elementName = arg2;
                        elementQName = [ interfaceQName, '/', elementName ];
                        autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'DataElements', elementQName, m3iModelContext );
                    elseif strcmp( m3iPropertyTypeName, 'ModeDeclarationInstanceRef' )
                        modeDeclGroupElementQName = dataObj.get( interfaceQName, 'ModeGroup', 'PathType', 'FullyQualified' );
                        m3iModeDeclGroupElement = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, modeDeclGroupElementQName );
                        m3iModeGroup = m3iModeDeclGroupElement.ModeGroup;
                        modeGroupQName = autosar.api.Utils.getQualifiedName( m3iModeGroup );

                        modeName = arg2;
                        modeQName = [ modeGroupQName, '/', modeName ];

                        autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'Mode', modeQName, m3iModelContext );
                        autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'groupElement', modeDeclGroupElementQName, m3iModelContext );
                    elseif strcmp( m3iPropertyTypeName, 'TriggerInstanceRef' )
                        elementName = arg2;
                        elementQName = [ interfaceQName, '/', elementName ];
                        autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'Trigger', elementQName, m3iModelContext );
                    else
                        elementName = arg2;
                        elementQName = [ interfaceQName, '/', elementName ];
                        autosar.api.getAUTOSARProperties.setProperty( m3iInstanceRef, 'Operations', elementQName, m3iModelContext );
                    end


                    if isSeq
                        m3iObj.( propertyName ).append( m3iInstanceRef );
                    else
                        m3iObj.( propertyName ) = m3iInstanceRef;
                    end
                end
            elseif strcmp( m3iPropertyType.qualifiedName, autosar.ui.metamodel.PackageString.LongNameClass )
                autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3ILongName( m3iModel, m3iObj, propertyValue );
            elseif autosar.api.getAUTOSARProperties.isReference( m3iProperty )

                m3iModel = m3iObj.rootModel;
                isSeq = autosar.api.getAUTOSARProperties.isSequence( m3iProperty );
                propertyValues = cellstr( propertyValue );

                if isSeq


                    m3iObj.( propertyName ).clear;
                else
                    assert( isscalar( propertyValues ),  ...
                        'The property value for "%s" should be a scalar.', propertyName );
                end

                for ii = 1:numel( propertyValues )
                    propertyValue = propertyValues{ ii };
                    if ~isempty( propertyValue )
                        m3iRefObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, propertyValue );
                    else

                        m3iRefObj = feval( [ m3iProperty.type.qualifiedName, '.empty' ] );
                    end

                    if isSeq
                        m3iObj.( propertyName ).append( m3iRefObj );
                    else
                        m3iObj.( propertyName ) = m3iRefObj;
                    end
                end
            elseif autosar.api.getAUTOSARProperties.isSequence( m3iProperty )

                m3iObj.( propertyName ).clear;
                m3iObj.( propertyName ).append( propertyValue );
            else

                m3iObj.( propertyName ) = propertyValue;
            end

            if isa( m3iObj, autosar.ui.metamodel.PackageString.RunnableClass ) &&  ...
                    strcmp( propertyName, autosar.ui.metamodel.PackageString.SwAddrMethod )






                [ isMapped, modelMapping ] = m3iModelContext.hasCompMapping(  );
                assert( isMapped, '%s must be mapped!', m3iModelContext.getContextName(  ) );

                mappingObj = autosar.api.Utils.findMappingObjMappedToRunnable( modelMapping, m3iObj.Name );
                assert( length( mappingObj ) <= 1, 'Expected to find 1 at maximum mapping Object' );
                if isempty( mappingObj )

                    return ;
                end

                mappingObj.mapSwAddrMethod( m3iObj.( propertyName ).Name );
            end





            metaModelCommonValidator = autosar.validation.MetaModelCommonValidator(  ...
                m3iModelContext.getContextName(  ) );
            switch propertyName
                case 'LiteralPrefix'
                    metaModelCommonValidator.verifyProperties( m3iObj, { 'LiteralPrefix' } );
                case 'SwAddrMethod'
                    metaModelCommonValidator.verifyProperties( m3iObj, { 'SwAddrMethod' } );
                otherwise

            end
        end


        function propertyValue = getProperty( m3iObj, extPropertyName, pathType, m3iModelContext )

            import autosar.mm.util.XmlOptionsAdapter;
            extPropertyName = convertStringsToChars( extPropertyName );

            if isa( m3iObj, 'Simulink.metamodel.arplatform.common.AUTOSAR' ) ||  ...
                    any( strcmp( extPropertyName, autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ) )
                if XmlOptionsAdapter.isVisibleProperty( extPropertyName, m3iModelContext )
                    propertyValue = XmlOptionsAdapter.get( m3iObj, extPropertyName );
                    return ;
                end
            end

            propertyName = autosar.api.getAUTOSARProperties.getIntPropertyName( extPropertyName );

            if isa( m3iObj, 'Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment' )
                if strcmp( propertyName, 'InstanceIdentifier' )
                    assert( isa( m3iModelContext, 'autosar.api.internal.M3IModelSLModelContext' ),  ...
                        'context for m3iModel should be a Simulink model' );
                    propertyValue = autosar.internal.adaptive.manifest.ManifestUtilities.getInstanceIdForDeploymentObj(  ...
                        m3iModelContext.getContextName(  ), m3iObj );
                    return ;
                end
            end


            m3iProperty = m3iObj.getMetaClass(  ).getProperty( propertyName );
            if isempty( m3iProperty ) && autosar.mm.util.ExternalToolInfoAdapter.isProperty( m3iObj, extPropertyName )
                propertyValue = autosar.mm.util.ExternalToolInfoAdapter.get( m3iObj, extPropertyName );
                return ;
            end
            m3iPropertyType = m3iProperty.type;
            m3iPropertyTypeName = m3iPropertyType.name;
            isSeq = autosar.api.getAUTOSARProperties.isSequence( m3iProperty );


            if isa( m3iPropertyType, 'M3I.ImmutableEnumeration' )

                if isSeq
                    seqOfValues = m3iObj.get( propertyName );
                    propertyValue = m3i.mapcell( @toString, seqOfValues );
                else
                    propertyValue = m3iObj.getOne( propertyName ).toString(  );
                end

            elseif strcmp( m3iPropertyTypeName, 'FlowDataPortInstanceRef' )
                m3iChildObj = m3iObj.( propertyName );
                if m3iChildObj.isvalid(  ) && ~isempty( m3iChildObj.Port )
                    propertyValue = [ m3iChildObj.Port.Name, '.', m3iChildObj.DataElements.Name ];
                else
                    propertyValue = [  ];
                end
            elseif strcmp( m3iPropertyTypeName, 'OperationPortInstanceRef' )
                m3iChildObj = m3iObj.( propertyName );
                if m3iChildObj.isvalid(  ) && m3iChildObj.Port.isvalid(  ) && m3iChildObj.Operations.isvalid(  )
                    propertyValue = [ m3iChildObj.Port.Name, '.', m3iChildObj.Operations.Name ];
                else
                    propertyValue = [  ];
                end
            elseif strcmp( m3iPropertyTypeName, 'ModeDeclarationInstanceRef' )
                m3iChildObj = m3iObj.( propertyName );
                if m3iChildObj.isvalid(  )
                    propertyValue = cell( 1, m3iChildObj.size(  ) );
                    for ii = 1:m3iChildObj.size(  )
                        propertyValue{ ii } = [ m3iChildObj.at( ii ).Port.Name, '.', m3iChildObj.at( ii ).Mode.Name ];
                    end
                else
                    propertyValue = [  ];
                end
            elseif isa( m3iObj, 'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.PersistencyReceiverPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.PersistencyProvidedPortComSpec' )



                dataDictionary = m3iModelContext.getDataDictionaryName(  );
                propertyValueStr = autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr( m3iObj, propertyName, dataDictionary );
                if ~strcmp( propertyValueStr, DAStudio.message( 'autosarstandard:ui:uiCannotDisplayHeterogeneousData' ) )
                    propertyValue = autosar.ui.comspec.ComSpecPropertyHandler.convertPropertyValueFromUI(  ...
                        propertyName, propertyValueStr );
                else
                    DAStudio.error( 'autosarstandard:ui:uiCannotDisplayHeterogeneousData' );
                end
            elseif isa( m3iObj, autosar.ui.metamodel.PackageString.RunnableClass ) &&  ...
                    strcmp( propertyName, autosar.ui.metamodel.PackageString.SwAddrMethod )






                propertyValue = '';
                [ isMapped, modelMapping ] = m3iModelContext.hasCompMapping(  );
                assert( isMapped, '%s must be mapped!', m3iModelContext.getContextName(  ) );
                mappingObj = autosar.api.Utils.findMappingObjMappedToRunnable( modelMapping, m3iObj.Name );
                assert( length( mappingObj ) <= 1, 'Expected to find 1 at maximum mapping Object' );
                if isempty( mappingObj )

                    return ;
                end

                if isempty( mappingObj.MappedTo.SwAddrMethod )

                    propertyValue = '';
                    return ;
                end
                swAddrMethodName = mappingObj.MappedTo.SwAddrMethod;

                m3iModel = m3iObj.modelM3I;
                m3iMetaClass = Simulink.metamodel.arplatform.common.SwAddrMethod.MetaClass;
                m3iSeq =  ...
                    Simulink.metamodel.arplatform.ModelFinder.findObjectInModel( m3iModel.RootPackage.front, swAddrMethodName, m3iMetaClass );
                assert( m3iSeq.size(  ) == 1, 'Expected to find exactly 1 SwAddrMethod' );
                m3iSwAddrMethod = m3iSeq.at( 1 );

                switch pathType
                    case 'FullyQualified'
                        fh = @autosar.api.Utils.getQualifiedName;
                    case 'PartiallyQualified'
                        fh = @autosar.api.getAUTOSARProperties.getPartiallyQualifiedName;
                    otherwise
                        assert( false, 'Did not recognize pathType %s', pathType );
                end
                propertyValue = fh( m3iSwAddrMethod );
            elseif strcmp( m3iPropertyType.qualifiedName, autosar.ui.metamodel.PackageString.LongNameClass )

                propertyValue = autosar.ui.codemapping.PortCalibrationAttributeHandler.getLongNameValueFromMultiLanguageLongName(  ...
                    m3iObj.longName );
            elseif autosar.api.getAUTOSARProperties.isReference( m3iProperty )


                m3iChildObj = m3iObj.( propertyName );
                if ~m3iChildObj.isvalid(  )
                    propertyValue = [  ];
                    return
                end

                switch pathType
                    case 'FullyQualified'
                        fh = @autosar.api.Utils.getQualifiedName;
                    case 'PartiallyQualified'
                        fh = @autosar.api.getAUTOSARProperties.getPartiallyQualifiedName;
                    otherwise
                        assert( false, 'Did not recognize pathType %s', pathType );
                end


                if isSeq
                    propertyValue = m3i.mapcell( fh, m3iChildObj );
                else
                    propertyValue = fh( m3iChildObj );
                end
            else
                m3iChildObj = m3iObj.( propertyName );


                if isSeq
                    propertyValue = m3i.mapcell( @( x )x, m3iChildObj );


                    if length( propertyValue ) >= 1
                        if isnumeric( propertyValue{ 1 } )
                            propertyValue = cell2mat( propertyValue );
                        end
                    end

                else
                    propertyValue = m3iChildObj;
                end

            end

        end


        function validProperties( m3iObj, m3iModelContext, propertyNames, compositeType )


            propertyNames = cellstr( propertyNames );


            runChecks = false;
            for ii = 1:length( propertyNames )
                propertyName = propertyNames{ ii };

                if ~m3iObj.has( propertyName )

                    runChecks = true;
                    break
                end

                m3iProperty = m3iObj.getMetaClass(  ).getProperty( propertyName );
                switch compositeType
                    case 'composite'
                        isViewable = Simulink.metamodel.arplatform.ModelFinder.isViewableAttribute( m3iProperty, true );
                    case 'noncomposite'
                        isViewable = Simulink.metamodel.arplatform.ModelFinder.isViewableAttribute( m3iProperty, false ) ||  ...
                            strcmp( propertyName, 'ComponentQualifiedName' );
                    case 'mixed'
                        isViewable = Simulink.metamodel.arplatform.ModelFinder.isViewableAttribute( m3iProperty, true ) ||  ...
                            Simulink.metamodel.arplatform.ModelFinder.isViewableAttribute( m3iProperty, false );
                    otherwise
                        assert( false, 'Did not recognize compositeType %s', compositeType );
                end

                if ~isViewable

                    runChecks = true;
                    break
                end

            end

            if ~runChecks
                return
            end

            validAttributes = autosar.api.getAUTOSARProperties.getValidAttributes(  ...
                m3iObj, m3iModelContext, compositeType, propertyNames );

            invalidAttributes = setdiff( propertyNames, validAttributes );


            validHiddenAttributes = { 'packagedElement' };
            invalidAttributes = setdiff( invalidAttributes, validHiddenAttributes );
            if ~isempty( invalidAttributes )
                invalidAttributes = setdiff( invalidAttributes, validHiddenAttributes );
            end




            validDeprecatedAttributes = {  };
            if isa( m3iObj, autosar.ui.metamodel.PackageString.RunnableClass )

                validDeprecatedAttributes = [ validDeprecatedAttributes,  ...
                    { autosar.ui.metamodel.PackageString.SwAddrMethod } ];
            end



            if ~isempty( invalidAttributes )
                invalidAttributes = setdiff( invalidAttributes, validDeprecatedAttributes );
            end

            if ~isempty( invalidAttributes )
                elementName = autosar.api.Utils.getQualifiedName( m3iObj );
                DAStudio.error( 'RTW:autosar:apiInvalidProperties', elementName, autosar.api.Utils.cell2str( invalidAttributes ),  ...
                    autosar.api.Utils.cell2str( validAttributes ) );
            end
        end

        function intPropertyName = getIntPropertyName( extPropertyName )

            switch extPropertyName
                case 'Trigger'
                    intPropertyName = 'instanceRef';
                case 'Activation'
                    intPropertyName = 'activation';
                case 'LongName'
                    intPropertyName = 'longName';
                otherwise
                    intPropertyName = extPropertyName;
            end

        end


        function extPropertyName = getExtPropertyName( intPropertyName )

            switch intPropertyName
                case 'instanceRef'
                    extPropertyName = 'Trigger';
                case 'activation'
                    extPropertyName = 'Activation';
                otherwise
                    extPropertyName = intPropertyName;
            end

        end


        function metaClassNames = concreteMetaClassNames( metaClass )


            metaClassNames = {  };
            if metaClass.isAbstract

                subClassesSeq = metaClass.subClass;
                for ii = 1:subClassesSeq.size(  )
                    subClass = subClassesSeq.at( ii );
                    if subClass.has( 'extension_m3i_hide_in_mcos' )

                    else
                        subClassNames = autosar.api.getAUTOSARProperties.concreteMetaClassNames( subClass );



                        subClassNames = setdiff( subClassNames, metaClassNames );
                        metaClassNames = [ metaClassNames, subClassNames ];%#ok<AGROW>
                    end
                end
            else
                metaClassNames = { metaClass.name };
            end
        end


        function metaClassNames = abstractMetaClassNames( metaClass )


            metaClassNames = {  };
            if metaClass.isAbstract
                metaClassNames = { metaClass.name };

                subClassesSeq = metaClass.subClass;
                for ii = 1:subClassesSeq.size(  )
                    subClass = subClassesSeq.at( ii );
                    if subClass.has( 'extension_m3i_hide_in_mcos' )

                    else
                        subClassNames = autosar.api.getAUTOSARProperties.abstractMetaClassNames( subClass );



                        subClassNames = setdiff( subClassNames, metaClassNames );
                        metaClassNames = [ metaClassNames, subClassNames ];%#ok<AGROW>
                    end
                end
            end
        end

        function checkObjectIsNotReferenced( m3iObj )

            if isa( m3iObj, 'Simulink.metamodel.arplatform.interface.PortInterface' )
                m3iPorts = autosar.mm.Model.findPortsUsingInterface( m3iObj );
                if ~m3iPorts.isEmpty(  )
                    DAStudio.error( 'RTW:autosar:apiDeleteReferencedElementErr',  ...
                        'interface', m3iObj.Name, 'ports', 'interface' );
                end
            end



            m3iCompositions = autosar.api.Utils.findCompositionsUsingComponent( m3iObj );
            if ~isempty( m3iCompositions )
                DAStudio.error( 'RTW:autosar:apiDeleteReferencedElementErr', 'component', m3iObj.Name, 'compositions', 'component' );
            end
        end

        function checkIsNamedElement( methodName, elementName )

            if ~autosar.api.Utils.isNamedElement( elementName )
                DAStudio.error( 'RTW:autosar:apiUnnamedElementNotSupported', methodName, elementName );
            end
        end

        function checkNoObjByPartialOrFullPath( m3iModel, elementPath )


            m3iObjSeq = autosar.api.getAUTOSARProperties.findObjSeqByPartialOrFullPath( m3iModel, elementPath );
            if m3iObjSeq.size(  ) ~= 0
                DAStudio.error( 'RTW:autosar:apiElementExists', elementPath );
            end

        end

        function m3iObj = findObjByPartialOrFullPathForNamedElement( m3iModel, elementPath )
            m3iObjSeq = autosar.api.getAUTOSARProperties.findObjSeqByPartialOrFullPath( m3iModel, elementPath );
            switch m3iObjSeq.size(  )
                case 0
                    DAStudio.error( 'RTW:autosar:apiInvalidPath', elementPath );
                case 1
                    m3iObj = m3iObjSeq.at( 1 );
                otherwise
                    qnames = cell( 1, m3iObjSeq.size );
                    for ii = 1:m3iObjSeq.size(  )
                        qnames{ ii } = autosar.api.Utils.getQualifiedName( m3iObjSeq.at( ii ) );
                    end

                    DAStudio.error( 'RTW:autosar:apiNeedFullyQualifiedPath', elementPath,  ...
                        autosar.api.Utils.cell2str( qnames ) );
            end
        end

        function m3iObj = findObjByPartialOrFullPathForUnnamedElement( m3iModel, elementPath )



            propNames = [  ];
            elementIndices = [  ];
            parentPath = elementPath;
            while ( ~autosar.api.Utils.isNamedElement( parentPath ) )
                [ parentPath, childName ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( parentPath );
                [ propNames{ end  + 1 }, elementIndices{ end  + 1 } ] = autosar.api.UnnamedElement.decodeName( childName );%#ok<AGROW>
            end



            m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPathForNamedElement( m3iModel, parentPath );
            for unnamedIdx = length( propNames ): - 1:1
                propertyName = propNames{ unnamedIdx };
                elementIndex = elementIndices{ unnamedIdx };
                if ( elementIndex ~=  - 1 )

                    m3iSeq = m3iObj.( propertyName );
                    assert( elementIndex > 0 && elementIndex <= m3iSeq.size(  ),  ...
                        'Invalid access as index %d is out of bounds on %s, which is of size %d.',  ...
                        elementIndex, propertyName, m3iSeq.size(  ) );
                    m3iObj = m3iSeq.at( elementIndex );
                else
                    m3iObj = m3iObj.( propertyName );
                end
            end
        end

        function m3iObjSeq = findObjSeqByPartialOrFullPath( m3iModel, elementPath )



            if length( elementPath ) == 1 && strcmp( elementPath( 1 ), '/' )

                assert( m3iModel.RootPackage.size(  ) == 1 );
                m3iObjSeq = M3I.SequenceOfClassObject.make( m3iModel.rootModel );
                m3iObjSeq.append( m3iModel.RootPackage.front(  ) );
            elseif length( elementPath ) > 1 && strcmp( elementPath( 1 ), '/' )

                m3iObjSeq = autosar.mm.Model.findObjectByName( m3iModel, elementPath );
            else

                m3iObjSeq = autosar.api.getAUTOSARProperties.findPackagedObjSeqByName( m3iModel, elementPath );
            end

        end

        function m3iPackagedObjSeq = findPackagedObjSeqByName( m3iModel, name )
            m3iPackagedObjSeq = M3I.SequenceOfClassObject.make( m3iModel.rootModel );


            m3iPkgSeq = Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass( m3iModel, Simulink.metamodel.arplatform.common.Package.MetaClass, true );


            for ii = 1:m3iPkgSeq.size(  )
                m3iObjSeq = autosar.mm.Model.findObjectByName( m3iPkgSeq.at( ii ), name );

                for jj = 1:m3iObjSeq.size(  )
                    m3iPackagedObjSeq.append( m3iObjSeq.at( jj ) );
                end
            end
        end

        function isSeq = isSequence( m3iProperty )
            isSeq = ~strcmp( m3iProperty.upper, '1' );
        end

        function isRef = isReference( m3iProperty )
            isRef = ~isempty( m3iProperty.association );
        end

        function path = getPartiallyQualifiedName( m3iObj )
            qualifiedName = autosar.api.Utils.getQualifiedName( m3iObj );

            m3iPkgObj = m3iObj.containerM3I;
            if ~isa( m3iPkgObj, 'Simulink.metamodel.arplatform.common.AUTOSAR' )
                while ~isa( m3iPkgObj, 'Simulink.metamodel.arplatform.common.Package' )
                    m3iPkgObj = m3iPkgObj.containerM3I;
                end
            end

            packageQualifiedName = autosar.api.Utils.getQualifiedName( m3iPkgObj );
            path = regexprep( qualifiedName, [ '^', packageQualifiedName, '/' ], '' );
        end

        function isComplete( m3iObj )


            if isa( m3iObj, 'Simulink.metamodel.arplatform.port.Port' )


                if ~m3iObj.Type.isvalid(  )
                    DAStudio.error( 'RTW:autosar:apiInvalidObj', 'Interface',  ...
                        autosar.api.Utils.getQualifiedName( m3iObj ) );
                end
            end

        end


        function setPhysicalDimensionAttributes( m3iDim, exponents )
            m3iDim.BaseExponent.clear(  );
            symbol = '';
            if ( exponents.LengthExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.LengthExp );
                symbol = [ symbol, 'l' ];
            end
            if ( exponents.MassExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.MassExp );
                symbol = [ symbol, 'm' ];
            end
            if ( exponents.TimeExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.TimeExp );
                symbol = [ symbol, 't' ];
            end
            if ( exponents.CurrentExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.CurrentExp );
                symbol = [ symbol, 'I' ];
            end
            if ( exponents.TemperatureExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.TemperatureExp );
                symbol = [ symbol, 'T' ];
            end
            if ( exponents.MolarAmountExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.MolarAmountExp );
                symbol = [ symbol, 'n' ];
            end
            if ( exponents.LuminousIntensityExp ~= 0 )
                m3iDim.BaseExponent.append( exponents.LuminousIntensityExp );
                symbol = [ symbol, 'L' ];
            end
            m3iDim.Symbol = symbol;
        end

        function ret = getIsSharedElementFromCategory( category )


            m3iObjMetaClass = autosar.api.getAUTOSARProperties.getMetaClassFromCategory( category );

            m3iComponentMetaClass = Simulink.metamodel.arplatform.component.Component.MetaClass;
            ret = ~m3iObjMetaClass.isSpecializationOf( m3iComponentMetaClass );
        end

        function sharedM3IModel = getSharedM3IModel( localM3IModel )
            if autosar.dictionary.Utils.hasReferencedModels( localM3IModel )
                sharedM3IModel = autosar.dictionary.Utils.getUniqueReferencedModel( localM3IModel );
            else


                sharedM3IModel = localM3IModel;
            end
        end
    end

    methods ( Hidden, Access = public )





        function addSRInterface( this, qname, varargin )











            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qname, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );
            [ package, name ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );
            this.addPackageableElement( 'SenderReceiverInterface', package, name, varargin{ : } );
        end

        function addMSInterface( this, qname, varargin )













            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qname, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );
            [ package, name ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );
            this.addPackageableElement( 'ModeSwitchInterface', package, name, varargin{ : } );
        end

        function addSwAddrMethod( this, qname, varargin )















            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qname, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );
            [ package, name ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );
            this.addPackageableElement( 'SwAddrMethod', package, name, varargin{ : } );
        end

        function addComponent( this, qname, varargin )


            [ ~, modelMapping ] = this.M3IModelContext.hasCompMapping(  );
            if ~isempty( modelMapping.MappedTo )
                DAStudio.error( 'RTW:autosar:apiMappingAlreadyHasComponent', modelMapping.MappedTo.Name );
            end

            [ compPath, compName ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );

            m3iModel = this.M3IModelContext.getM3IModel(  );
            autosar.mm.Model.getOrAddARPackage( m3iModel, compPath );

            this.add( compPath, 'packagedElement', compName, varargin{ : } );
            m3iSWC = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, qname );


            if m3iSWC.getMetaClass(  ).getProperty( 'Behavior' ).isvalid(  )
                this.add( qname, 'Behavior', 'Behavior' );
            end


            if isa( m3iSWC, 'Simulink.metamodel.arplatform.composition.CompositionComponent' )
                compObj = Simulink.AutosarTarget.Composition( m3iSWC.qualifiedName, m3iSWC.Name );
                modelMapping.mapComposition( compObj );
            elseif isa( m3iSWC, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )
                compObj = Simulink.AutosarTarget.Application( m3iSWC.qualifiedName, m3iSWC.Name );
                modelMapping.mapApplication( compObj );


                this.set( 'XmlOptions', 'ComponentQualifiedName', qname );
            else
                componentId = m3iSWC.qualifiedName;
                compObj = Simulink.AutosarTarget.Component( componentId, m3iSWC.Name );
                modelMapping.mapComponent( compObj );


                this.set( 'XmlOptions', 'ComponentQualifiedName', qname );
            end
        end

        function moveElements( this, srcPkg, destPkg, category )














            m3iModel = this.M3IModelContext.getM3IModel(  );
            m3iSrcPkg = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, srcPkg );
            childMetaClass = m3iSrcPkg.getMetaClass(  ).getProperty( 'packagedElement' ).type;
            validCategoryNames = autosar.api.getAUTOSARProperties.concreteMetaClassNames( childMetaClass );
            invalidCategory = setdiff( category, validCategoryNames );
            if ~isempty( invalidCategory )
                DAStudio.error( 'RTW:autosar:apiInvalidCategory', invalidCategory{ 1 }, childPath,  ...
                    autosar.api.Utils.cell2str( validCategoryNames ) );
            end

            childMetaClass = autosar.api.getAUTOSARProperties.getMetaClassFromCategory( category );
            metaClsStr = childMetaClass.qualifiedName;
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before moveElements' );
            trans = M3I.Transaction( m3iModel );
            autosar.api.Utils.moveElementsByClassName( m3iModel, srcPkg, destPkg,  ...
                metaClsStr, 'All' )
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after moveElements' );
        end

        function moveElement( this, elementPath, dstPkg )












            elementPath = convertStringsToChars( elementPath );
            dstPkg = convertStringsToChars( dstPkg );


            m3iModel = this.M3IModelContext.getM3IModel(  );
            m3iObject = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, elementPath );

            if strcmp( [ dstPkg, '/', m3iObject.Name ], autosar.api.Utils.getQualifiedName( m3iObject ) )

                return ;
            end


            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                dstPkg, 'absPath', this.M3IModelContext.getMaxShortNameLength(  ) );


            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before moveElements' );
            trans = M3I.Transaction( m3iModel );

            m3iPkgDst = autosar.mm.Model.getOrAddARPackage( m3iModel, dstPkg );
            assert( m3iPkgDst.isvalid(  ) );


            if any( strcmp( m3i.mapcell( @( x )x.Name, m3iPkgDst.packagedElement ), m3iObject.Name ) )
                DAStudio.error( 'RTW:autosar:apiElementExists', elementPath );
            end


            m3iPkgDst.packagedElement.append( m3iObject );
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after moveElements' );
        end

        function addUnit( this, qname, varargin )











            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qname, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );


            argParser = inputParser;
            argParser.addParameter( 'DisplayName', '', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.addParameter( 'FactorSiToUnit', 1, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'OffsetSiToUnit', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'PhysicalDimension', '', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.parse( varargin{ : } );


            m3iModel = this.M3IModelContext.getM3IModel(  );
            dimQName = argParser.Results.PhysicalDimension;
            m3iDim = [  ];
            if ~isempty( dimQName )
                m3iDim = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel,  ...
                    dimQName );
                assert( ~isempty( m3iDim ), '%s element does not exist.', dimQName );
            end


            [ parentPath, childName ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before addUnit' );
            trans = M3I.Transaction( m3iModel );
            this.addPackageableElement( 'Unit', parentPath, childName );



            m3iUnit = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, qname );
            m3iUnit.Symbol = argParser.Results.DisplayName;
            m3iUnit.ConvFactor = argParser.Results.FactorSiToUnit;
            m3iUnit.ConvOffset = argParser.Results.OffsetSiToUnit;
            if ~isempty( m3iDim )
                m3iUnit.Dimension = m3iDim;
            end
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after addUnit' );
        end

        function addPhysicalDimension( this, qname, varargin )
















            autosarcore.ModelUtils.checkQualifiedName_impl(  ...
                qname, 'absPathShortName', this.M3IModelContext.getMaxShortNameLength(  ) );


            argParser = inputParser;
            argParser.addParameter( 'LengthExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'MassExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'TimeExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'CurrentExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'TemperatureExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'MolarAmountExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.addParameter( 'LuminousIntensityExp', 0, @( x )( ~isempty( x ) && isfloat( x ) ) );
            argParser.parse( varargin{ : } );


            m3iModel = this.M3IModelContext.getM3IModel(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects before addPhysicalDimension' );
            trans = M3I.Transaction( m3iModel );
            [ parentPath, childName ] = autosar.mm.sl2mm.ModelBuilder.getNodePathAndName( qname );
            this.addPackageableElement( 'Dimension', parentPath, childName );



            m3iDim = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, qname );
            autosar.api.getAUTOSARProperties.setPhysicalDimensionAttributes(  ...
                m3iDim, argParser.Results );
            trans.commit(  );
            assert( m3iModel.unparented.isEmpty(  ), 'Unparented objects after addPhysicalDimension' );
        end

        function m3iModel = getM3IModel( this, namedargs )
            arguments
                this
                namedargs.ForXmlOptions = false;
            end
            m3iModel = this.M3IModelContext.getM3IModel(  ...
                ForXmlOptions = namedargs.ForXmlOptions );
        end

        function context = getM3IModelContext( this )
            context = this.M3IModelContext;
        end

        function setDDSTopicForEvent( this, portName, eventName, topicName )












            this.checkAPIIsSupported( 'setDDSTopicForEvent' );


            autosar.api.Utils.autosarlicensed( true );


            if ~this.M3IModelContext.isContextMappedToAdaptiveApplication(  )
                DAStudio.error( 'autosarstandard:api:modelNotMappedToAdaptiveAUTOSAR',  ...
                    this.M3IModelContext.getContextName(  ) );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                autosar.internal.adaptive.manifest.ManifestUtilities.setTopicNameForEvent(  ...
                    this.M3IModelContext.getContextName(  ), portName, eventName, topicName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end

        function topicName = getDDSTopicForEvent( this, portName, eventName )












            this.checkAPIIsSupported( 'getDDSTopicForEvent' );


            autosar.api.Utils.autosarlicensed( true );


            if ~this.M3IModelContext.isContextMappedToAdaptiveApplication(  )
                DAStudio.error( 'autosarstandard:api:modelNotMappedToAdaptiveAUTOSAR',  ...
                    this.M3IModelContext.getContextName(  ) );
            end

            try

                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                topicName = autosar.internal.adaptive.manifest.ManifestUtilities.getTopicNameForEvent(  ...
                    this.M3IModelContext.getContextName(  ), portName, eventName );
            catch Me

                autosar.mm.util.MessageReporter.throwException( Me );
            end
        end
    end

    methods ( Static, Hidden, Access = public )
        function paths = find_impl( m3iModel, rootPath, category, m3iModelContext, varargin )
            persistent componentAttributes;
            persistent ibAttributes;

            argParser = inputParser;
            argParser.addRequired( 'RootPath', @( x )( ischar( x ) || isStringScalar( x ) || isempty( x ) ) );
            argParser.addRequired( 'Category', @( x )( ischar( x ) || isStringScalar( x ) ) );
            argParser.parse( rootPath, category );

            metaClass = autosar.api.getAUTOSARProperties.getMetaClassFromCategory( category );
            [ propertyNames, propertyValues, pathType, categoryProp, objName ] = autosar.api.getAUTOSARProperties.parseInputParams( varargin{ : } );
            if ~isempty( categoryProp )
                propertyNames{ end  + 1 } = 'Category';
                propertyValues{ end  + 1 } = categoryProp;
            end
            recursiveSearch = true;
            searchBySuperClass = true;
            if ~isempty( rootPath ) && ~strcmp( rootPath, '/' )
                m3iRootObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPath( m3iModel, rootPath );




                if isa( m3iRootObj, 'Simulink.metamodel.arplatform.component.Component' )
                    if isempty( componentAttributes )
                        attribs = Simulink.metamodel.arplatform.ModelFinder.getCompositeAttributes( m3iRootObj );
                        for ii = 1:attribs.size(  )
                            concreteClasses = autosar.api.getAUTOSARProperties.concreteMetaClassNames( attribs.at( ii ).type );
                            for jj = 1:numel( concreteClasses )
                                componentAttributes = [ componentAttributes, concreteClasses( jj ) ];%#ok<AGROW>
                            end
                        end
                        componentAttributes = setdiff( componentAttributes, autosar.api.getAUTOSARProperties.UnsupportedCategories );
                    end
                    componentHasBehavior = isa( m3iRootObj, 'Simulink.metamodel.arplatform.component.AtomicComponent' );
                    if componentHasBehavior && isempty( ibAttributes ) &&  ...
                            m3iRootObj.Behavior.isvalid(  )
                        attribs = Simulink.metamodel.arplatform.ModelFinder.getCompositeAttributes( m3iRootObj.Behavior );
                        for ii = 1:attribs.size(  )
                            concreteClasses = autosar.api.getAUTOSARProperties.concreteMetaClassNames( attribs.at( ii ).type );
                            for jj = 1:numel( concreteClasses )
                                ibAttributes = [ ibAttributes, concreteClasses( jj ) ];%#ok<AGROW>
                            end
                        end
                        ibAttributes = setdiff( ibAttributes, autosar.api.getAUTOSARProperties.UnsupportedCategories );
                    end
                    if any( strcmp( category, componentAttributes ) )
                        recursiveSearch = false;
                        searchBySuperClass = false;
                    elseif any( strcmp( category, ibAttributes ) )
                        recursiveSearch = false;
                        searchBySuperClass = false;
                        m3iRootObj = m3iRootObj.Behavior;
                    end
                elseif isa( m3iRootObj, 'Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior' )
                    if isempty( ibAttributes )
                        attribs = Simulink.metamodel.arplatform.ModelFinder.getCompositeAttributes( m3iRootObj );
                        for ii = 1:attribs.size(  )
                            concreteClasses = autosar.api.getAUTOSARProperties.concreteMetaClassNames( attribs.at( ii ).type );
                            for jj = 1:numel( concreteClasses )
                                ibAttributes = [ ibAttributes, concreteClasses( jj ) ];%#ok<AGROW>
                            end
                        end
                        ibAttributes = setdiff( ibAttributes, autosar.api.getAUTOSARProperties.UnsupportedCategories );
                    end
                    if any( strcmp( category, ibAttributes ) )
                        recursiveSearch = false;
                        searchBySuperClass = false;
                    end
                end
            else
                m3iRootObj = m3iModel;
            end

            if ~isempty( objName )

                m3iObjSeq = Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClassAndName( m3iRootObj, metaClass, objName, recursiveSearch );
            else
                m3iObjSeq = autosar.mm.Model.findObjectByMetaClass( m3iRootObj, metaClass, recursiveSearch, searchBySuperClass );
            end

            paths = cell( 1, m3iObjSeq.size(  ) );
            for ii = 1:m3iObjSeq.size(  )
                m3iObj = m3iObjSeq.at( ii );
                if strcmp( category, 'ImplementationDataType' ) && m3iObj.IsApplication
                    paths{ ii } = [  ];
                    continue ;
                end
                if strcmp( category, 'ApplicationDataType' ) && ~m3iObj.IsApplication
                    paths{ ii } = [  ];
                    continue ;
                end
                switch pathType
                    case 'FullyQualified'
                        paths{ ii } = autosar.api.Utils.getQualifiedName( m3iObj );
                    case 'PartiallyQualified'
                        paths{ ii } = autosar.api.getAUTOSARProperties.getPartiallyQualifiedName( m3iObj );
                    otherwise
                        assert( false, 'invalid pathType %s', pathType );
                end


                autosar.api.getAUTOSARProperties.validProperties( m3iObj, m3iModelContext, propertyNames, 'noncomposite' );


                for propIdx = 1:length( propertyNames )
                    propName = propertyNames{ propIdx };
                    actValue = autosar.api.getAUTOSARProperties.getProperty( m3iObj, propName, pathType, m3iModelContext );
                    expValue = propertyValues{ propIdx };

                    if isempty( actValue ) && ~isempty( expValue )

                        paths{ ii } = [  ];
                        break
                    elseif isnumeric( actValue ) || islogical( actValue )
                        if actValue ~= expValue

                            paths{ ii } = [  ];
                            break
                        end
                    elseif ischar( actValue ) || isStringScalar( actValue )
                        if ~strcmp( actValue, expValue )

                            paths{ ii } = [  ];
                            break
                        end
                    else
                        assert( false, 'Cannot compare property %s', propName );
                    end
                end
            end

            emptyIdx = cellfun( @isempty, paths );
            paths( emptyIdx ) = [  ];
        end

        function [ metaClass, validCategory ] = getDataTypeMetaClassFromCategory( category )
            import Simulink.metamodel.foundation.*;
            metaClass = [  ];
            if exist( category, 'class' ) && any( strcmp( methods( category ), 'MetaClass' ) )
                metaClass = eval( strcat( category, '.MetaClass' ) );

                if isa( metaClass, 'M3I.ImmutableClass' )
                    validCategory = true;
                end
            end
        end

        function metaClass = getMetaClassFromCategory( category )




            import Simulink.metamodel.arplatform.behavior.*;
            import Simulink.metamodel.arplatform.common.*;
            import Simulink.metamodel.arplatform.component.*;
            import Simulink.metamodel.arplatform.composition.*;
            import Simulink.metamodel.arplatform.documentation.*;
            import Simulink.metamodel.arplatform.instance.*;
            import Simulink.metamodel.arplatform.interface.*;
            import Simulink.metamodel.arplatform.manifest.*;
            import Simulink.metamodel.arplatform.port.*;
            import Simulink.metamodel.arplatform.timingExtension.*;
            import Simulink.metamodel.arplatform.variant.*;
            import Simulink.metamodel.types.*;
            import Simulink.metamodel.foundation.*;


            persistent category2MetaClassMap;
            if isempty( category2MetaClassMap )
                category2MetaClassMap = containers.Map(  );
            end

            if category2MetaClassMap.isKey( category )

                metaClass = category2MetaClassMap( category );
            else

                if any( strcmp( category, { 'ApplicationDataType', 'ImplementationDataType' } ) )

                    [ metaClass, validCategory ] = autosar.api.getAUTOSARProperties.getDataTypeMetaClassFromCategory( 'ValueType' );
                else

                    try
                        metaClass = eval( strcat( category, '.MetaClass' ) );
                        validCategory = isa( metaClass, 'M3I.ImmutableClass' );
                    catch
                        validCategory = false;
                    end
                end

                if validCategory

                    category2MetaClassMap( category ) = metaClass;
                else

                    validCategories = autosar.api.getAUTOSARProperties.getValidCategories(  );
                    DAStudio.error( 'RTW:autosar:apiInvalidCategory', category, '',  ...
                        autosar.api.Utils.cell2str( validCategories ) );
                end
            end
        end

        function validCategories = getValidCategories(  )


            validCategories = [ autosar.api.getAUTOSARProperties.concreteMetaClassNames(  ...
                Simulink.metamodel.arplatform.common.Identifiable.MetaClass ),  ...
                autosar.api.getAUTOSARProperties.abstractMetaClassNames(  ...
                Simulink.metamodel.arplatform.common.Identifiable.MetaClass ),  ...
                'CompuMethod', 'ApplicationDataType', 'ImplementationDataType' ];


            hidePackage = 'Simulink.metamodel.arplatform.ecuc';
            nonPublic = arrayfun( @( x )x.Name, meta.package.fromName( hidePackage ).ClassList, 'UniformOutput', false );
            nonPublic = strrep( nonPublic, [ hidePackage, '.' ], '' );
            validCategories = setdiff( validCategories, nonPublic );
        end

        function readOnly = isReadOnly( m3iObj )
            readOnly = autosar.mm.arxml.Exporter.isExternalReference( m3iObj );
        end

        function m3iObj = findObjByPartialOrFullPath( m3iModel, elementPath )
            if autosar.api.Utils.isNamedElement( elementPath )
                m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPathForNamedElement( m3iModel, elementPath );
            else
                m3iObj = autosar.api.getAUTOSARProperties.findObjByPartialOrFullPathForUnnamedElement( m3iModel, elementPath );
            end
        end

        function validAttributes = getValidAttributes( m3iObj, m3iModelContext, compositeType, propertyNames )

            if nargin < 4
                propertyNames = [  ];
            end

            switch compositeType
                case 'composite'
                    validAttributesSeq = autosar.api.getAUTOSARProperties.doFindCompositeAttributes( m3iObj );
                case 'noncomposite'
                    validAttributesSeq = autosar.api.getAUTOSARProperties.doFindNonCompositeAttributes( m3iObj );
                case 'mixed'
                    validAttributesSeq = autosar.api.getAUTOSARProperties.doFindCompositeAttributes( m3iObj );
                    validNonCompositeAttributesSeq = autosar.api.getAUTOSARProperties.doFindNonCompositeAttributes( m3iObj );

                    validAttributesSeq.addAll( validNonCompositeAttributesSeq );
                otherwise
                    assert( false, 'Did not recognize compositeType %s', compositeType );
            end

            validAttributes = cell( 1, validAttributesSeq.size(  ) );
            for ii = 1:validAttributesSeq.size(  )
                validAttributes{ ii } = autosar.api.getAUTOSARProperties.getExtPropertyName( validAttributesSeq.at( ii ).name );
            end

            if isa( m3iObj, 'Simulink.metamodel.arplatform.common.AUTOSAR' ) ||  ...
                    ~isempty( intersect( propertyNames,  ...
                    autosar.mm.util.XmlOptionsAdapter.ComponentSpecificXmlOptions ) )
                xmlProps = autosar.mm.util.XmlOptionsAdapter.getValidProperties( m3iModelContext );
                validAttributes = [ validAttributes, xmlProps{ : } ];
            end

            externalToolInfoProps = autosar.mm.util.ExternalToolInfoAdapter.getValidProperties( m3iObj );
            validAttributes = [ validAttributes, externalToolInfoProps{ : } ];


            if isa( m3iObj, 'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.PersistencyReceiverPortComSpec' ) ||  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.port.PersistencyProvidedPortComSpec' )
                validAttributes = [ validAttributes, 'InitValue' ];
                validAttributes = setdiff( validAttributes, 'InitialValue' );
            end





            if isa( m3iObj, 'Simulink.metamodel.arplatform.behavior.IrvData' )
                validAttributes = setdiff( validAttributes, 'InvalidationPolicy' );
            end


            if isa( m3iObj.containerM3I, 'Simulink.metamodel.arplatform.interface.NvDataInterface' ) &&  ...
                    isa( m3iObj, 'Simulink.metamodel.arplatform.interface.FlowData' )
                validAttributes = setdiff( validAttributes, 'InvalidationPolicy' );
            end


            validAttributes = setdiff( validAttributes, 'appliedStereotypeInstance' );


            if isa( m3iObj, 'Simulink.metamodel.arplatform.common.AUTOSAR' )
                validAttributes = setdiff( validAttributes, { 'Name', 'Domain', 'Category' } );

                if m3iModelContext.isContextArchitectureModel(  )

                    validAttributes = setdiff( validAttributes, { 'XmlOptionsSource',  ...
                        'InternalBehaviorQualifiedName', 'ImplementationQualifiedName',  ...
                        'ArxmlFilePackaging', 'ComponentQualifiedName' } );
                else



                    validAttributes = [ { 'ComponentQualifiedName' }, validAttributes ];


                    validAttributes = setdiff( validAttributes, { 'ComponentPackage' } );

                    if m3iModelContext.isContextMappedToAdaptiveApplication(  )


                        validHiddenAttributes = { 'ImplementationQualifiedName',  ...
                            'InternalBehaviorQualifiedName' };
                        validAttributes = setdiff( validAttributes, validHiddenAttributes );
                    end
                end
            end

            if isa( m3iObj, 'Simulink.metamodel.arplatform.manifest.UserDefinedServiceInterfaceDeployment' )
                validAttributes = [ validAttributes, autosar.internal.adaptive.manifest.ManifestUtilities.getSupportedProperties ];
            end

            if isa( m3iObj, 'Simulink.metamodel.foundation.ValueType' ) &&  ...
                    ~slfeature( "AdaptiveAutosarNamespacesOnTypes" )

                validAttributes = setdiff( validAttributes, 'Namespaces' );
            end

            if slfeature( 'AUTOSARLongNameAuthoring' )
                if isa( m3iObj, autosar.ui.configuration.PackageString.DataElement ) &&  ...
                        isa( m3iObj.containerM3I, autosar.ui.metamodel.PackageString.InterfacesCell{ 1 } )


                    validAttributes{ end  + 1 } = autosar.ui.metamodel.PackageString.LongName;
                end
            end

        end


        function errorOutIfReadOnlyObject( m3iObj )

            if autosar.api.getAUTOSARProperties.isReadOnly( m3iObj )
                DAStudio.error( 'autosarstandard:api:CannotChangeReadonlyElement',  ...
                    autosar.api.Utils.getQualifiedName( m3iObj ) );
            end
        end

        function isPackagedElement = isPackagedElement( m3iObj )

            isPackagedElement = isa( m3iObj.containerM3I,  ...
                'Simulink.metamodel.arplatform.common.Package' );
        end

        function setXmlOptionProperty( m3iObj, extPropertyName, propertyValue, moveElementsMode, m3iModelContext )
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.api.Utils;

            if ( m3iModelContext.isContextArchitectureModel )



                moveElementsMode = 'None';
            end

            if XmlOptionsAdapter.isVisibleProperty( extPropertyName, m3iModelContext )
                XmlOptionsAdapter.verify( m3iObj, extPropertyName, propertyValue );
                XmlOptionsAdapter.set( m3iObj, extPropertyName, propertyValue, moveElementsMode );
                return ;
            elseif strcmp( extPropertyName, 'DataTypePackage' )
                srcPkg = m3iObj.DataTypePackage;
                errArgs = Utils.verifyXmlOptionsPackage(  ...
                    m3iObj.modelM3I, srcPkg, propertyValue, extPropertyName );
                if isempty( errArgs{ 1 } )
                    Utils.moveImpDataTypes( m3iObj, srcPkg, propertyValue, moveElementsMode );
                else
                    DAStudio.error( errArgs{ : } );
                end
            elseif strcmp( extPropertyName, 'InterfacePackage' )
                intf = 'Simulink.metamodel.arplatform.interface';
                srcPkg = m3iObj.InterfacePackage;
                errArgs = Utils.verifyXmlOptionsPackage(  ...
                    m3iObj.modelM3I, srcPkg, propertyValue, extPropertyName );
                if isempty( errArgs{ 1 } )
                    Utils.moveElementsByClassName( m3iObj,  ...
                        srcPkg, propertyValue, [ intf, '.PortInterface' ], moveElementsMode );
                else
                    DAStudio.error( errArgs{ : } );
                end
            elseif strcmp( extPropertyName, 'ArxmlFilePackaging' )
                m3iProperty = m3iObj.getMetaClass(  ).getProperty( extPropertyName );
                propertyValue =  ...
                    autosar.api.getAUTOSARProperties.checkAndConvertToEnumLiteral(  ...
                    m3iProperty, propertyValue );
            else
                assert( false, "Invalid XmlOption specified" );
            end
            propertyName = autosar.api.getAUTOSARProperties.getIntPropertyName( extPropertyName );
            m3iObj.( propertyName ) = propertyValue;
        end

        function propertyValue = checkAndConvertToEnumLiteral( m3iProperty, propertyValue )
            m3iPropertyType = m3iProperty.type;
            assert( isa( m3iPropertyType, 'M3I.ImmutableEnumeration' ), 'Expected enum type' );

            validEnumerationLiterals = cell( 1, m3iPropertyType.ownedLiteral.size(  ) );
            for ii = 1:m3iPropertyType.ownedLiteral.size(  )
                validEnumerationLiterals{ ii } = m3iPropertyType.ownedLiteral.at( ii ).name;
            end

            invalidEnumerationLiterals = setdiff( propertyValue, validEnumerationLiterals );
            if ~isempty( invalidEnumerationLiterals )
                DAStudio.error( 'RTW:autosar:apiInvalidPropertyValue', propertyValue, m3iProperty.name,  ...
                    autosar.api.Utils.cell2str( validEnumerationLiterals ) );
            end

            propertyValue = feval( [ m3iPropertyType.qualifiedName, '.', propertyValue ] );
        end

        function packagePaths = getAllPackagePaths( m3iModel )

            pkgMetaCls = Simulink.metamodel.arplatform.common.Package.MetaClass;
            recursiveSearch = true;
            searchBySuperClass = true;
            m3iPkgs = autosar.mm.Model.findObjectByMetaClass( m3iModel,  ...
                pkgMetaCls, recursiveSearch, searchBySuperClass );

            packagePaths = m3i.mapcell( @( x )autosar.api.Utils.getQualifiedName( x ), m3iPkgs );
        end
    end
end



