function bool=isValidBlock(blockHandle)






    assert(isa(blockHandle,'double')&&ishandle(blockHandle)...
    &&isequal(get_param(blockHandle,'Type'),'block'),...
    message('Simulink:HiliteTool:ExpectedBlockHandle'));

    bool=false;
    try
        ports=get_param(blockHandle,'PortHandles');
        blockType=get_param(blockHandle,'BlockType');

        invalidList={
        'subsystem',...
        'modelreference',...
        'BusCreator',...
        'BusSelector',...
        'BusAssignment',...
        'VariantSource',...
'VariantSink'...
        };



        bool=(isempty(ports.LConn)&&isempty(ports.RConn))&&...
        ~any(strcmpi(blockType,invalidList));

        if(bool&&~isempty(Simulink.Structure.HiliteTool.getParentHiddenMask(blockHandle)))
            bool=false;
        end
    catch

    end

end
