function retVal = isArchitectureModel( modelHOrCBInfo, subDomain )

arguments
    modelHOrCBInfo
    subDomain = ''
end



if isa( modelHOrCBInfo, 'SLM3I.CallbackInfo' )
    activeEditor = modelHOrCBInfo.studio.App.getActiveEditor(  );
    modelH = activeEditor.blockDiagramHandle;
else
    modelH = modelHOrCBInfo;
    assert( strcmp( get_param( modelH, 'Type' ), 'block_diagram' ),  ...
        '%s is not a valid model!', getfullname( modelH ) );
    modelH = get_param( modelH, 'handle' );
end

if modelH <= 0
    retVal = false;
else
    modelDomain = get_param( modelH, 'SimulinkSubDomain' );
    supportedArchSubDomains = { 'AUTOSARArchitecture', 'Architecture', 'SoftwareArchitecture' };

    if isempty( subDomain )

        retVal = any( strcmp( modelDomain, supportedArchSubDomains ) );
    else
        assert( any( strcmp( subDomain, supportedArchSubDomains ) ),  ...
            'invalid subDomain: %s', subDomain );
        retVal = strcmp( modelDomain, subDomain );
    end
end

end


