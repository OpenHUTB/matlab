function createNewDesignStudy( sessionDataModel, designSession, ~, studyType )

arguments
    sessionDataModel( 1, 1 )mf.zero.Model
    designSession( 1, 1 )simulink.multisim.mm.session.Session
    ~
    studyType( 1, 1 )simulink.multisim.mm.design.ParameterSpaceType
end

bdAssociatedDataId = simulink.multisim.internal.blockDiagramAssociatedDataId(  );
designSuiteMap = Simulink.BlockDiagramAssociatedData.get( designSession.ModelHandle, bdAssociatedDataId ).DesignSuiteMap;

if ~isKey( designSuiteMap, designSession.ActiveDesignSuiteUUID )
    createNewDesignSuite( sessionDataModel, designSession )
end

designSuiteInfo = designSuiteMap( designSession.ActiveDesignSuiteUUID );
designStudy = simulink.multisim.internal.utils.Design.createNewDesignStudy(  ...
    designSuiteInfo.DataModel, designSuiteInfo.DesignSuite, studyType );
selectDesignStudyForRun( designSuiteInfo.DataModel, designStudy, designSession.ModelHandle );
end

function createNewDesignSuite( sessionDataModel, designSession )
import simulink.multisim.internal.utils.Session.*

dataModel = mf.zero.Model;
designSuite = simulink.multisim.mm.design.DesignSuite( dataModel );
designSuite.ModelName = get_param( designSession.ModelHandle, "Name" );
designSuite.FeatureFaults = simulink.multisim.internal.isFaultInjectionAvailable(  );
designSuite.IsParameterCombinationsEnabled = slfeature( "ParameterCombinationsInRunAllUI" ) ~= 0;
designSuite.IsPreviewEnabled = slfeature( "MultipleSimulationsPreview" ) ~= 0;

modelHandle = designSession.ModelHandle;
dataModel.addObservingListener( @( ~, ~ )simulink.multisim.internal.setSessionDirtyState( modelHandle, true ) );
setDesignSuiteBdData( modelHandle, designSession, dataModel, designSuite );
setActiveDesignSuite( sessionDataModel, designSession, dataModel.UUID );
end

function selectDesignStudyForRun( dataModel, designStudy, modelHandle )
designStudy.SelectedForRun = true;
simulink.multisim.internal.utils.DesignStudy.handlePropertyChange( dataModel,  ...
    designStudy, "SelectedForRun", modelHandle );
end

