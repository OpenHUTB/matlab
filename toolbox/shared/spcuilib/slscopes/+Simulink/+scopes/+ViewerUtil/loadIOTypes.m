function result=loadIOTypes(ioLibraries,isGenerator)

    librariesLoad=[ioLibraries{:}];
    libs={librariesLoad.name}';
    libChildren={librariesLoad.children};
    try
        for i=1:length(libs)

            currentlibChildren=libChildren{i};
            currentlibChildren=[currentlibChildren{:}];


            blocksTree={currentlibChildren.label}';
            blockNames={currentlibChildren.path};




            ioType={currentlibChildren.ioType};
            ioRegCallbackFile={currentlibChildren.ioRegCallbackFile};
            ioRegIconDisplay={currentlibChildren.ioRegIconDisplay};
            ioRegSelectionMode={currentlibChildren.ioRegSelectionMode};
            ioRegPortPrefix={currentlibChildren.ioRegPortPrefix};

            ioRegPortPrefix=cellfun(@(x)getTranslatedString(slservices.StringOrID(x)),ioRegPortPrefix,'UniformOutput',false);

            for idx=1:length(blocksTree)
                block=blockNames{idx};
                Simulink.iomanager.IOType.createIOType(ioType{idx},...
                blocksTree{idx},...
                block,...
                ioRegCallbackFile{idx},...
                '',...
                ioRegIconDisplay{idx},...
                ioRegSelectionMode{idx},...
                ioRegPortPrefix{idx},...
                isGenerator);
            end
        end
        result=1;
    catch
        result=0;
    end

end