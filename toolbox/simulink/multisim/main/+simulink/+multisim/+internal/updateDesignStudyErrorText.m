function updateDesignStudyErrorText( designStudy )

arguments
    designStudy( 1, 1 )simulink.multisim.mm.design.DesignStudy
end

designStudy.ErrorText = "";
updateDesignStudyErrorTextFromParameterTree( designStudy, designStudy.ParameterSpace );
end

function updateDesignStudyErrorTextFromParameterTree( designStudy, parameterSpaces )
for parameterSpace = parameterSpaces
    if ~isempty( parameterSpace.ErrorText )
        designStudy.ErrorText = parameterSpace.ErrorText;
    elseif isa( parameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
        childParameterSpaces = parameterSpace.ParameterSpaces.toArray(  );
        updateDesignStudyErrorTextFromParameterTree( designStudy, childParameterSpaces );
    end

    if ~isempty( designStudy.ErrorText )
        return ;
    end
end
end

