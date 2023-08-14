function[ioLibraries]=getViewersAndGenerators(ioType)







    ioLibraries=[];

    if strcmp(ioType,'viewer')
        ioLibraries=Simulink.scopes.ViewerUtil.getIOLibraries('viewer');




        IOType=Simulink.iomanager.IOType.findIOType('Scope');

        if isempty(IOType)
            Simulink.scopes.ViewerUtil.loadIOTypes(ioLibraries,0);
        end

    elseif strcmp(ioType,'siggen')
        ioLibraries=Simulink.scopes.ViewerUtil.getIOLibraries('siggen');


        IOType=Simulink.iomanager.IOType.findIOType('Clock');

        if isempty(IOType)
            Simulink.scopes.ViewerUtil.loadIOTypes(ioLibraries,1);
        end
    end

end

