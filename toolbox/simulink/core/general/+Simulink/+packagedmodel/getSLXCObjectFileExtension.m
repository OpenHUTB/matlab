function omitExt=getSLXCObjectFileExtension(type,input,mdl)



    narginchk(2,3);

    toolchain=[];
    switch(type)
    case 'toolchain'
        toolchain=input;
    case 'buildargs'
        isSimBuild=slprivate('isSimulationBuild',mdl,...
        input.ModelReferenceTargetType);

        if isSimBuild

            field='BaDefaultCompInfo';
        else

            field='BaModelCompInfo';
        end

        if isfield(input,field)&&...
            ~isempty(input.(field))
            toolchain=input.(field).ToolchainInfo;
        end
    otherwise
        DAStudio.error('Simulink:cache:unknownType',type,mfilename);
    end

    if isempty(toolchain)
        omitExt={'.o','.obj'};
        return;
    end

    [~,objExt]=coder.make.internal.getFileExtensionsForToolchain(toolchain);
    omitExt=unique(objExt);
end
