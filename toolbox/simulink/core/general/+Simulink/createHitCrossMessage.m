













if(exist('HitCrossMessage','var')==1)
    disp('HitCrossMessage exists in the workspace as a variable. Please delete/rename it.')
    return;
end

HitCrossMessage=Simulink.Bus;
HitCrossMessage.Elements(1)=Simulink.BusElement;
HitCrossMessage.Elements(1).Name='CrossingType';
HitCrossMessage.Elements(1).Dimensions=1;
HitCrossMessage.Elements(1).DimensionsMode='Fixed';
HitCrossMessage.Elements(1).DataType='Enum: slHitCrossingType';
HitCrossMessage.Elements(1).SampleTime=-1;
HitCrossMessage.Elements(1).Complexity='real';

HitCrossMessage.Elements(2)=Simulink.BusElement;
HitCrossMessage.Elements(2).Name='Index';
HitCrossMessage.Elements(2).Dimensions=1;
HitCrossMessage.Elements(2).DimensionsMode='Fixed';
HitCrossMessage.Elements(2).DataType='uint32';
HitCrossMessage.Elements(2).SampleTime=-1;
HitCrossMessage.Elements(2).Complexity='real';

HitCrossMessage.Elements(3)=Simulink.BusElement;
HitCrossMessage.Elements(3).Name='Time';
HitCrossMessage.Elements(3).Dimensions=1;
HitCrossMessage.Elements(3).DimensionsMode='Fixed';
HitCrossMessage.Elements(3).DataType='double';
HitCrossMessage.Elements(3).SampleTime=-1;
HitCrossMessage.Elements(3).Complexity='real';

HitCrossMessage.Elements(4)=Simulink.BusElement;
HitCrossMessage.Elements(4).Name='Offset';
HitCrossMessage.Elements(4).Dimensions=1;
HitCrossMessage.Elements(4).DimensionsMode='Fixed';
HitCrossMessage.Elements(4).DataType='double';
HitCrossMessage.Elements(4).SampleTime=-1;
HitCrossMessage.Elements(4).Complexity='real';

HitCrossMessage.DataScope='Exported';
