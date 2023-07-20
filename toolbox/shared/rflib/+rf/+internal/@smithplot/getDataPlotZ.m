function z=getDataPlotZ(p,datasetIndex)


    h=getDataWidgetHandles(p);
    if nargin>1

        z=getappdata(h(datasetIndex),'smithiZPlane');
    else

        Nh=numel(h);
        z=zeros(Nh,1);
        for i=1:Nh

            z(i)=getappdata(h(i),'smithiZPlane');
        end
    end