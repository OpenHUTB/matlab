clc

BlockName=gcb;

ParaMatrix={...
'fsw','Switching frequency (Hz)';...
'SampleTime','Sample time in Constant/Sine block (s)';...
'Ts','Sample time';...
'Amplitude','Modulation index';...
'Value','Constant block, MinMax';...
'Frequency','Sine wave frequency (rad/s)';...
'Phase','Sine wave phase';...
'Tper','Time period';...
'Tdelay','Time delay';...
'Bias','Bias';...
'Gain','gain';...
};

ParaNameStr=ParaMatrix(:,1);
PromptStr=ParaMatrix(:,2);

paraNum=size(ParaNameStr,1);


thisMask=Simulink.Mask.get(BlockName);
if isempty(thisMask)
    thisMask=Simulink.Mask.create(BlockName);
else
    thisMask.delete;
    thisMask=Simulink.Mask.create(BlockName);
end




for i=1:paraNum
    thisParaName=ParaNameStr{i};
    thisPrompt=PromptStr{i};

    TypeOptions=getTypeOptions(thisParaName,BlockName);
    TypeOptionsNum=numel(TypeOptions);
    TypeOptionsList=strings(1,TypeOptionsNum);
    for j=1:TypeOptionsNum
        TypeOptionsList(j)=TypeOptions{j};
    end

    if TypeOptionsNum>0
        thisMask.addParameter('Type','promote',...
        'TypeOptions',TypeOptionsList(:),...
        'Name',thisParaName,...
        'Prompt',thisPrompt);
    else
        thisMask.addParameter('Type','edit',...
        'Name',thisParaName,...
        'Prompt',thisPrompt);
    end

end


