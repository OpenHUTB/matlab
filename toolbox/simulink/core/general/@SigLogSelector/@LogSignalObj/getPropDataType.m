function varType=getPropDataType(~,prop)




    switch prop
    case{'Name','SourcePath','LoggingName'}
        varType='string';
    case{'DataLogging','DecimateData','LimitDataPoints'}
        varType='bool';
    case{'NameMode'}
        varType='enum';
    otherwise
        varType='double';
    end

end

