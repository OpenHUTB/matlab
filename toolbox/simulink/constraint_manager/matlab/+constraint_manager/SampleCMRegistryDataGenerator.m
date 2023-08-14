

pm1=Simulink.Mask.Constraints;
pm1.Name='Neagtive_Constraint';

pm1.addParameterConstraintRule('DataType','int8','Complexity',{'real'},...
'Dimension',{'scalar'},'Sign',{'zero','negative'},'Finiteness',{},...
'Minimum','0','Maximum','100','CustomConstraint','v>2','CustomErrorMessage','error1');

pm2=Simulink.Mask.Constraints;
pm2.Name='Scalar_Constraint';

pm2.addParameterConstraintRule('DataType','double','Complexity',{'real'},...
'Dimension',{'scalar'},'Sign',{'positive','negative'},'Finiteness',{'finite'},...
'Minimum','-200','Maximum','100','CustomConstraint','f>20','CustomErrorMessage','error2');

pm3=Simulink.Mask.Constraints;
pm3.Name='DataType_Constraint';

pm3.addParameterConstraintRule('DataType','double','Complexity',{'real'},...
'Dimension',{'scalar'},'Sign',{'positive','negative'},'Finiteness',{'finite'},...
'Minimum','-200','Maximum','100','CustomConstraint','f>20','CustomErrorMessage','error2');








matfile1constraints.(pm1.Name)=pm1;
matfile1constraints.(pm2.Name)=pm2;
save('matfile1.mat','-struct','matfile1constraints');


matfile2constraints.(pm3.Name)=pm3;
save('matfile2.mat','-struct','matfile2constraints');

Simulink.Mask.registerSharedConstraint('DSP','matfile1');
Simulink.Mask.registerSharedConstraint('Math','matfile2');



