function VideoDisplayMSfcnWin(block)










    setup(block);
end

function setup(block)

    block.NumInputPorts=3;
    block.NumOutputPorts=0;


    block.SetPreCompInpPortInfoToDynamic;


    for k=1:3
        block.InputPort(k).DatatypeID=3;
        block.InputPort(k).Complexity='Real';
        block.InputPort(k).DimensionsMode='Inherited';
    end


    block.NumDialogPrms=1;
    block.DialogPrmsTunable={'Nontunable'};


    block.SampleTimes=[-1,0];


    block.SetSimViewingDevice(true);
    block.SetAccelRunOnTLC(false);
    block.SimStateCompliance='HasNoSimState';


    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
    block.RegBlockMethod('SetInputPortDimensions',@SetInpPortDims);
    block.RegBlockMethod('Start',@Start);
    block.RegBlockMethod('Outputs',@Outputs);
end


function SetInpPortDims(block,idx,di)
    block.InputPort(idx).Dimensions=di;
end








function DoPostPropSetup(block)

end










function Start(block)
    dims=block.InputPort(1).Dimensions;
    hFig=findobj('Name','SDL Video Display');
    if~isempty(hFig)
        hFig.NumberTitle='off';
        hFig.MenuBar='none';
        hFig.ToolBar='none';
    else



        scrsz=get(groot,'ScreenSize');
        hFig=figure('Name','SDL Video Display',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'ToolBar','none',...
        'Position',[100,scrsz(4)-(dims(1)+120),dims(2),dims(1)]);

    end
    ax=axes('Parent',hFig,'Visible','off');
    hIm=imshow(zeros([dims(1),dims(2)],'uint8'),'parent',ax,'border','tight');
    figure(hFig);


    obj.Fig=hFig;
    obj.Im=hIm;
    set_param(block.BlockHandle,'UserData',obj);
end








function Outputs(block)
    try
        obj=get_param(block.BlockHandle,'UserData');
        obj.Im.CData=cat(3,block.InputPort(1).Data,...
        block.InputPort(2).Data,...
        block.InputPort(3).Data);
        drawnow;
    catch
    end
end


