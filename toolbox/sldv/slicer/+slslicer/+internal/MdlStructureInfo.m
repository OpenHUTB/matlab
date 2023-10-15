classdef MdlStructureInfo < handle





    properties

        mdlH


        refMdlToMdlBlk


        obsMdlToRefBlk




        signalObservers

        rootInportHandles


        alwaysExecutesCondSystems

        subordinateMergeBlks

        transformBlkMap

        globalDsmNames
        dsmHandles
    end

    methods
        function obj = MdlStructureInfo( mdlH, refMdlToMdlBlk, modelElements, obsMdlToRefBlk )
            arguments
                mdlH( 1, 1 )double
                refMdlToMdlBlk containers.Map
                modelElements struct
                obsMdlToRefBlk = containers.Map( 'KeyType', 'double',  ...
                    'ValueType', 'double' );
            end
            obj.mdlH = mdlH;
            obj.refMdlToMdlBlk = refMdlToMdlBlk;

            obj.signalObservers = modelElements.signalObservers;
            obj.rootInportHandles = modelElements.rootInportHandles;

            if isfield( modelElements, 'globalDsmNames' )
                obj.globalDsmNames = modelElements.globalDsmNames;
            end
            if isfield( modelElements, 'dsmHandles' )
                obj.dsmHandles = modelElements.dsmHandles;
            end
            obj.subordinateMergeBlks = containers.Map( 'KeyType', 'double', 'ValueType', 'uint8' );
            obj.alwaysExecutesCondSystems = containers.Map( 'KeyType', 'double',  ...
                'ValueType', 'uint8' );

            obj.transformBlkMap = [  ];

            obj.obsMdlToRefBlk = obsMdlToRefBlk;
        end

        function clearAfterSliceGeneration( obj )



            obj.subordinateMergeBlks = containers.Map( 'KeyType', 'double', 'ValueType', 'uint8' );
            obj.alwaysExecutesCondSystems = containers.Map( 'KeyType', 'double',  ...
                'ValueType', 'uint8' );
        end

        function map = getTransformBlkMap( obj, transforms )
            obj.buildTransformBlkMap( transforms );
            map = obj.transformBlkMap;
        end

        function buildTransformBlkMap( obj, transforms )
            if isempty( obj.transformBlkMap )
                obj.transformBlkMap = containers.Map( 'KeyType', 'char',  ...
                    'ValueType', 'any' );
            end

            mdlHs = [ obj.mdlH,  ...
                cell2mat( obj.refMdlToMdlBlk.keys ),  ...
                cell2mat( obj.obsMdlToRefBlk.keys ) ];

            transformPivotBlockTypes =  ...
                arrayfun( @( t )string( t.pivotBlockType ), transforms );
            transformPivotBlockTypes = unique( transformPivotBlockTypes )';

            for btype = transformPivotBlockTypes
                results = [  ];
                if ~isKey( obj.transformBlkMap, char( btype ) )
                    for mdl = mdlHs
                        result = Simulink.findBlocksOfType( mdl, btype );
                        results = [ results;result ];%#ok<AGROW>
                    end
                    obj.transformBlkMap( char( btype ) ) = results;
                end
            end
        end
    end
end

