classdef(Sealed)LibraryBrowserUtils<handle


    methods(Access='private')
        function obj=LibraryBrowserUtils()
        end
    end

    methods(Static=true)

        function slxFile=saveAsSLX(lib,fileIn)
            if~bdIsLoaded(lib)
                load_system(lib);
                closesys=onCleanup(@()close_system(lib,0));
            end

            libH=get_param(lib,'Handle');
            set_param(libH,'Lock','off');
            set_param(libH,'EnableLBRepository','on');

            if isempty(fileIn)
                obj=LibraryBrowser.LibraryBrowserUtils();
                slxFile=obj.i_getSLXFile(lib);
            else
                slxFile=fileIn;
            end



            if exist(slxFile,'file')==4
                slxFileSaveStr='';
                [~,fileAttrib]=fileattrib(slxFile);
                if~fileAttrib.UserWrite
                    wStates=[warning;warning('query','backtrace')];
                    warning off backtrace;
                    [~,message,messageid]=fileattrib(slxFile,'+w');


                    if isequal(messageid,'MATLAB:FILEATTRIB:CouldNotSetAttributes')
                        ME=MException(messageid,message);
                        MSLDiagnostic('Simulink:Commands:FileMakeWritableError',...
                        slxFile,DAStudio.message('MATLAB:FILEATTRIB:CouldNotSetAttributes')).reportAsWarning;
                        warning(wStates);
                        throw(ME);
                    end
                    warning(wStates);
                end
            else
                slxFileSaveStr=slxFile;
            end
            save_system(lib,slxFileSaveStr,'OverwriteIfChangedOnDisk',true);




            if~isempty(slxFileSaveStr)
                rehash('toolboxreset');
            end
        end

        function slxFile=i_getSLXFile(lib)
            if strcmpi(lib,'simulink')





                slxFile=which('simulink.slx');
            else

                slxFile=which(lib);


                [pathstr,name,ext]=fileparts(slxFile);
                if(strcmp(ext,'.mdl'))
                    ext=strrep(ext,'mdl','slx');

                    slxFile=fullfile(pathstr,[name,ext]);
                end
            end
        end

        function[isPaletteList,paletteCallbackFcnList]=getPaletteLibInfo(aLibName)
            isPaletteList={};
            paletteCallbackFcnList={};
            slBlocksFile=LibraryBrowser.internal.getSLBlocksFile(aLibName);
            if~isempty(slBlocksFile)
                [~,~,~,~,type,~,~,~,fcns]=LibraryBrowser.internal.getLibInfo(slBlocksFile);
                assert((size(type,1)==size(fcns,1))&&(size(type,2)==size(fcns,2)));



                for libIdx=1:numel(type)
                    if~isempty(type{libIdx})&&strcmpi(type{libIdx},'Palette')
                        isPaletteList{end+1}=true;
                    else
                        isPaletteList{end+1}=false;
                    end
                end
                paletteCallbackFcnList=fcns;
            end
        end
    end
end
