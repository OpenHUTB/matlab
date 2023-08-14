function aComp=getAnnotationComp(hN,compName,desc,slHandle)





    if nargin<4
        slHandle=-1;
    end

    if nargin<3
        desc='';
    end

    if nargin<2
        compName='annotation';
    end


    aComp=hN.addComponent2(...
    'kind','annotation',...
    'SimulinkHandle',slHandle,...
    'name',compName,...
    'BlockComment',desc);

end


