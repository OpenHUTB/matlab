classdef ReplacementConfig < matlab.mixin.SetGetExactNames & handle

    properties
        LibraryNameToAddSubsystemsTo
        IgnoredClones
        SubsystemReferenceFileNames
    end

    methods
        function obj = ReplacementConfig( libraryNameToAddSubsystemsTo,  ...
                ignoredClones )
            arguments
                libraryNameToAddSubsystemsTo = 'newLibraryFile'
                ignoredClones = {  }
            end

            if ~license( 'test', 'sl_verification_validation' )
                DAStudio.error( 'sl_pir_cpp:creator:CloneDetectionLicenseFail' );
            end

            obj.LibraryNameToAddSubsystemsTo = libraryNameToAddSubsystemsTo;
            obj.IgnoredClones = ignoredClones;
            obj.SubsystemReferenceFileNames = [  ];
        end

        function set.LibraryNameToAddSubsystemsTo( obj, libraryNameToAddSubsystemsTo )
            try
                if ~ischar( libraryNameToAddSubsystemsTo )
                    DAStudio.error( 'sl_pir_cpp:creator:IllegalName1_lib' );
                end
                [ ~, filename, ~ ] = fileparts( libraryNameToAddSubsystemsTo );

                if ~Simulink.CloneDetection.internal.util.isFileNameValid( filename )
                    DAStudio.error( 'sl_pir_cpp:creator:IllegalName1_lib' );
                end
                obj.LibraryNameToAddSubsystemsTo = libraryNameToAddSubsystemsTo;
            catch exception
                exception.throwAsCaller(  );
                return ;
            end
        end


        function set.IgnoredClones( obj, ignoredClones )
            try
                obj.IgnoredClones = {  };
                if ~isempty( ignoredClones )
                    if isa( ignoredClones, 'char' )
                        ignoredClones = { ignoredClones };
                    elseif ~isa( ignoredClones, 'cell' )
                        DAStudio.error( 'sl_pir_cpp:creator:IllegalCloneName' );
                    end

                    for cloneIndex = 1:numel( ignoredClones )
                        if ischar( ignoredClones{ cloneIndex } )
                            obj.IgnoredClones = [ obj.IgnoredClones;ignoredClones{ cloneIndex } ];
                        else
                            DAStudio.error( 'sl_pir_cpp:creator:IllegalCloneName' );
                        end
                    end
                end
            catch exception
                exception.throwAsCaller(  );
                return ;
            end
        end





        function obj = addCloneToIgnoreList( obj, cloneName )
            ignoredClonesList = [ obj.IgnoredClones;cloneName ];
            obj.IgnoredClones = ignoredClonesList;
        end


        function obj = removeCloneFromIgnoreList( obj, cloneName )
            try
                if ~isempty( cloneName )
                    if isa( cloneName, 'char' )
                        ignoredCloneName = { cloneName };
                    elseif isa( cloneName, 'cell' )
                        ignoredCloneName = cloneName;
                    else
                        DAStudio.error( 'sl_pir_cpp:creator:IllegalListFormat' );
                    end

                    updatedIgnoredClones = setdiff( obj.IgnoredClones, ignoredCloneName );
                    obj.IgnoredClones = updatedIgnoredClones;
                end
            catch exception
                exception.throwAsCaller(  );
                return ;
            end
        end


        function set.SubsystemReferenceFileNames( obj, subsystemReferenceFileNames )
            try
                obj.SubsystemReferenceFileNames = [  ];
                if ~isempty( subsystemReferenceFileNames )
                    if isa( subsystemReferenceFileNames, 'struct' )
                        obj.SubsystemReferenceFileNames = subsystemReferenceFileNames;
                    else
                        DAStudio.error( 'sl_pir_cpp:creator:IllegalInputForStruct' );
                    end
                end
            catch exception
                exception.throwAsCaller(  );
                return ;
            end
        end
    end
end

