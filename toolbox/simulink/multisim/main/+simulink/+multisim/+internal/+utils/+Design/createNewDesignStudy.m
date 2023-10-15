function designStudy = createNewDesignStudy( dataModel, designSuite, studyType )
arguments
    dataModel( 1, 1 )mf.zero.Model;
    designSuite( 1, 1 )simulink.multisim.mm.design.DesignSuite
    studyType( 1, 1 )simulink.multisim.mm.design.ParameterSpaceType
end

label = getUniqueDesignStudyLabel( designSuite );
parameterSpaceClass = string( studyType );

txn = dataModel.beginTransaction(  );
runOptions = simulink.multisim.mm.design.RunOptions( dataModel );
parallelOptions = simulink.multisim.mm.design.ParallelOptions( dataModel );
advancedRunOptions = simulink.multisim.mm.design.AdvancedRunOptions( dataModel );
runOptions.ParallelOptions = parallelOptions;
runOptions.AdvancedRunOptions = advancedRunOptions;
parameterSpace = simulink.multisim.mm.design.( parameterSpaceClass )( dataModel );
designStudy = simulink.multisim.mm.design.DesignStudy( dataModel );
designStudy.Label = label;
designStudy.RunOptions = runOptions;
designStudy.ParameterSpace = parameterSpace;
designSuite.DesignStudies.add( designStudy );
txn.commit(  );
end

function label = getUniqueDesignStudyLabel( designSuite )
designStudyArray = designSuite.DesignStudies.toArray(  );
existingLabels = arrayfun( @( x )x.Label, designStudyArray, "UniformOutput", false );
designStudyLabel = message( "multisim:SetupGUI:DesignStudyDefaultLabel" ).getString(  );
label = matlab.lang.makeUniqueStrings( designStudyLabel, existingLabels );
end
