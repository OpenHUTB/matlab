function pathItems=getPortMapping(~,~,~,outportNum)















    pathItems=cell(numel(outportNum),1);
    pathItems(outportNum==1)={'Metric output'};
    pathItems(outportNum~=1)={''};

end


