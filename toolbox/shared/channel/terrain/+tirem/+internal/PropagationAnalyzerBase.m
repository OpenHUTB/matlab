classdef(Hidden)PropagationAnalyzerBase<handle




    properties(Access=protected)
pLibraryKey
pLibraryFolder
    end

    methods
        function analyzer=PropagationAnalyzerBase


            products={'Antenna_Toolbox','Phased_Array_System_Toolbox'};
            rfprop.PropagationModel.checkoutLicense(products);


            tirem.internal.Validators.validateSetup
            libFolder=tirem.internal.PropagationAnalyzer.libraryFolder;
            tirem.internal.PropagationAnalyzer.loadLibrary(libFolder)
            analyzer.pLibraryFolder=libFolder;


            s=settings;
            analyzer.pLibraryKey=s.shared.channel.tirem.LibraryKey.ActiveValue;
        end
    end

    methods(Hidden,Static)
        function buildHeader(libFolder)



            libPrototype=tirem.internal.PropagationAnalyzer.LibraryPrototype;
            libName=tirem.internal.PropagationAnalyzer.LibraryName;
            libAlias=tirem.internal.PropagationAnalyzer.LibraryAlias;
            if libisloaded(libAlias)
                unloadlibrary(libAlias)
            end


            tirem.internal.Validators.validateLibraryFolder(libFolder);
            tirem3Library=fullfile(libFolder,libName);



            tiremRootFolder=fileparts(libFolder);
            tirem3Header=fullfile(tiremRootFolder,'include','tirem3.h');



            oldDir=cd(libFolder);
            C=onCleanup(@()cd(oldDir));


            loadlibrary(tirem3Library,tirem3Header,'alias',libAlias,...
            'mfilename',libPrototype)
        end
    end
end