function frameTbl=addFrameVariables_implementation(KS,groupName,type,baseFrame,folFrame,varargin)




    p=inputParser;
    p.addRequired('groupName',@validateScalarText);
    p.addRequired('type',@validateScalarText);
    p.addRequired('baseFrame',@validateScalarText);
    p.addRequired('folFrame',@validateScalarText);
    p.addParameter('LengthUnit',KS.DefaultLengthUnit,@validateLengthUnit);
    p.addParameter('AngleUnit',KS.DefaultAngleUnit,@validateAngleUnit);
    p.addParameter('LinearVelocityUnit',KS.DefaultLinearVelocityUnit,@validateLinearVelocityUnit);
    p.addParameter('AngularVelocityUnit',KS.DefaultAngularVelocityUnit,@validateAngularVelocityUnit);
    p.parse(groupName,type,baseFrame,folFrame,varargin{:});

    [groupName,type,baseFrame,folFrame]=...
    convertCharsToStrings(groupName,type,baseFrame,folFrame);
    baseFrame=baseFrame.replace(newline," ");
    folFrame=folFrame.replace(newline," ");
    KS.mSystem.addFrameVariables(...
    groupName,type,baseFrame,folFrame,...
    p.Results.LengthUnit,p.Results.AngleUnit,...
    p.Results.LinearVelocityUnit,p.Results.AngularVelocityUnit);
    frameTbl=KS.frameVariables;