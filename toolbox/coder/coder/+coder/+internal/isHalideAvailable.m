function is=isHalideAvailable()


%#codegen

    coder.allowpcode('plain');
    [arch,extn]=getArchitectureDetails;
    halideLibrary=['libmwhalideRuntime.',extn];
    libHalidePath=coder.const(feval('fullfile',matlabroot,'bin',arch,halideLibrary));

    is=coder.const(feval('isfile',libHalidePath));

end


function[arch,libExtn]=getArchitectureDetails()
    arch=coder.const(feval('computer','arch'));
    switch(arch)
    case 'win64'
        libExtn='dll';
    case 'glnxa64'
        libExtn='so';
    case 'maci64'
        libExtn='dylib';
    otherwise
        libExtn='';
    end
end
