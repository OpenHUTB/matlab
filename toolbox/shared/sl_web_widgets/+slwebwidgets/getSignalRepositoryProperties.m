function signalProperties=getSignalRepositoryProperties(sigID)



    signalProperties.dimensionsFromRepo='';
    signalProperties.signalTypeFromRepo='';

    repoUtil=starepository.RepositoryUtility;


    signalType=getMetaDataByName(repoUtil,sigID,'SignalType');
    WAS_REAL=strcmp(signalType,getString(message('sl_sta_general:common:Real')));



    currentDataType=getMetaDataByName(repoUtil,sigID,'DataType');

    dataformat=getMetaDataByName(repoUtil,sigID,'dataformat');

    currentDimensions=getMetaDataByName(repoUtil,sigID,'Dimension');

    if WAS_REAL
        signalProperties.signalTypeFromRepo=DAStudio.message('sl_sta_general:common:Real');
    else
        signalProperties.signalTypeFromRepo=DAStudio.message('sl_sta_general:common:Complex');
    end
    signalProperties.dimensionsFromRepo=currentDimensions;
