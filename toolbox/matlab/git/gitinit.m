function repo = gitinit( folder, options )

arguments( Input )
    folder( 1, 1 )string{ mustBeNonzeroLengthText } = pwd
    options.bare( 1, 1 )logical = false
    options.reinit( 1, 1 )logical = false
    options.InitialBranch( 1, 1 )string{ mustBeNonzeroLengthText }
end

arguments( Output )
    repo( 1, 1 )matlab.git.GitRepository
end

if isfield( options, "InitialBranch" )
    matlab.internal.git.init( folder, options.bare, options.reinit, options.InitialBranch );
else
    matlab.internal.git.init( folder, options.bare, options.reinit );
end

repo = gitrepo( folder );

if matlab.internal.git.isJavaUI && isequal( repo.WorkingFolder, pwd )


    cd( fileparts( repo.WorkingFolder ) );
    cleanup = onCleanup( @(  )cd( repo.WorkingFolder ) );
end
end



