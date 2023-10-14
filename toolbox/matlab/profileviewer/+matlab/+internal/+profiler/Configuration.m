classdef Configuration < handle

    properties ( Access = private )
        Options

        ReplaceExistingOption
    end

    methods
        function obj = Configuration( options, replaceExistingOption )
            arguments
                options( 1, : )matlab.internal.profiler.interface.ConfigOption =  ...
                    matlab.internal.profiler.interface.ConfigOption.empty(  )
                replaceExistingOption( 1, 1 )logical = true
            end

            obj.Options = options;
            obj.ReplaceExistingOption = replaceExistingOption;
        end

        function addOption( obj, option )
            arguments
                obj
                option( 1, 1 )matlab.internal.profiler.interface.ConfigOption
            end


            if isa( option, 'matlab.internal.profiler.types.NullOption' )
                return ;
            end

            optionIdx = find( arrayfun( @( opt )opt.isTypeOf( option ), obj.Options ), 1 );
            if ~isempty( optionIdx )
                if obj.ReplaceExistingOption
                    obj.Options( optionIdx ) = option;
                    return ;
                else
                    error( message( 'MATLAB:profiler:ConfigOptionDuplicated' ) );
                end
            end
            obj.Options( end  + 1 ) = option;
        end

        function config = filterByProfilerType( obj, profilerType )
            arguments
                obj
                profilerType( 1, 1 )matlab.internal.profiler.ProfilerType
            end

            filteredOptions = obj.Options( arrayfun( @( opt )opt.isCompatible( profilerType ), obj.Options ) );
            config = matlab.internal.profiler.Configuration( filteredOptions, obj.ReplaceExistingOption );
        end

        function options = getOptions( obj )
            options = obj.Options;
        end

        function empty = isempty( obj )
            empty = isempty( obj.Options );
        end

        function [ isIn, option ] = containsOptionType( obj, optionType )
            arguments
                obj
                optionType{ mustBeTextScalar( optionType ) }
            end

            isIn = false;
            option = matlab.internal.profiler.interface.ConfigOption.empty;
            optionIdx = find( arrayfun( @( opt )isa( opt, optionType ), obj.Options ), 1 );
            if ~isempty( optionIdx )
                option = obj.Options( optionIdx );
                isIn = true;
            end
        end

        function isEq = isequal( obj, objCmp )


            if numel( obj.Options ) ~= numel( objCmp.Options )
                isEq = false;
                return ;
            end

            isEq = true;
            for optIdx = 1:numel( obj.Options )
                found = any( arrayfun( @( x )isequal( x, obj.Options( optIdx ) ), objCmp.Options ) );
                if ~found
                    isEq = false;
                end
            end
        end
    end
end

